import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:url_launcher/url_launcher.dart';

/// Manages subscription state and handles in-app purchases for Google Play.
///
/// Key Features:
/// - Real-time subscription status via Firestore listener
/// - Proper user verification (subscription tied to Firebase UID)
/// - Automatic refresh on app resume
/// - No persistent caching of subscription status
///
/// Security:
/// - All purchases are verified server-side via Cloud Functions
/// - Subscription status always checked against authenticated user's UID
/// - Purchase tokens are validated with Google Play before granting access
class SubscriptionProvider extends ChangeNotifier with WidgetsBindingObserver {
  // --- In-App Purchase ---
  final InAppPurchase _iap = InAppPurchase.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _entitlementSubscription;
  StreamSubscription<User?>? _authSubscription;

  // Product IDs from Google Play Console
  static const String monthlyId = 'android_monthly_subs';
  static const String yearlyId = 'android_yearly_subs';

  // --- State ---
  List<ProductDetails> _products = [];
  bool _isStoreAvailable = false;
  bool _isSubscribed = false;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastRefreshTime;
  DateTime? _lastRefreshRequestTime;

  // --- Public Getters ---
  bool get isSubscribed => _isSubscribed;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ProductDetails> get products => _products;

  SubscriptionProvider() {
    // Listen to app lifecycle
    WidgetsBinding.instance.addObserver(this);
    // Listen to auth changes to reset subscription state
    _listenToAuthChanges();
  }

  /// Initialize the provider (call from main.dart after Firebase init)
  Future<void> init() async {
    _setLoading(true);
    try {
      // Check if store is available
      _isStoreAvailable = await _iap.isAvailable();

      if (_isStoreAvailable) {
        // Load products from store
        await _loadProducts();

        // Start listening to purchase stream
        _listenToPurchases();

        // Start listening to Firestore entitlement (if user is logged in)
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          _listenToEntitlement();
          // Refresh subscription status on init
          await refreshSubscriptionStatus();
        }
      } else {
        _error = 'In-app purchases are not available.';
      }
    } catch (e) {
      _error = 'Failed to initialize subscriptions: $e';
      if (kDebugMode) print(_error);
    } finally {
      _setLoading(false);
    }
  }

  /// Listen to authentication changes to reset subscription state
  void _listenToAuthChanges() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        // User logged out - reset subscription state
        _isSubscribed = false;
        _entitlementSubscription?.cancel();
        _entitlementSubscription = null;
        _lastRefreshTime = null;
        _lastRefreshRequestTime = null; // Reset debounce timer
        notifyListeners();
        if (kDebugMode) print('User logged out - subscription state reset');
      } else {
        // User logged in - start listening to their subscription
        _listenToEntitlement();
        // Refresh to ensure we have latest status
        refreshSubscriptionStatus();
        if (kDebugMode) print('User logged in - refreshing subscription');
      }
    });
  }

  /// Load products from the store
  Future<void> _loadProducts() async {
    _setLoading(true);
    try {
      final response = await _iap.queryProductDetails({monthlyId, yearlyId});

      if (response.error != null) {
        _error = 'Failed to load products: ${response.error!.message}';
        _products = [];
      } else {
        _products = response.productDetails.toList();
        // Sort by price (ascending)
        _products.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
        _error = null;
      }

      // Debug: Check for missing product IDs
      if (response.notFoundIDs.isNotEmpty && kDebugMode) {
        print('Missing product IDs: ${response.notFoundIDs.join(', ')}');
      }
    } catch (e) {
      _error = 'Failed to load products: $e';
      _products = [];
      if (kDebugMode) print(_error);
    } finally {
      _setLoading(false);
    }
  }

  /// Public method to reload products
  Future<void> reloadProducts() async {
    await _loadProducts();
    notifyListeners();
  }

  /// Listen to purchase stream from the store
  void _listenToPurchases() {
    _purchaseSubscription?.cancel();
    _purchaseSubscription = _iap.purchaseStream.listen(
      _onPurchaseStreamUpdated,
      onError: (e) {
        _error = 'Purchase stream error: $e';
        if (kDebugMode) print(_error);
        notifyListeners();
      },
      onDone: () {
        if (kDebugMode) print('Purchase stream closed');
      },
    );
  }

  /// Handle purchase stream updates
  Future<void> _onPurchaseStreamUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchase in purchaseDetailsList) {
      if (kDebugMode) {
        print('Purchase update: ${purchase.productID} - ${purchase.status}');
      }

      switch (purchase.status) {
        case PurchaseStatus.pending:
          _setLoading(true);
          break;

        case PurchaseStatus.error:
          final errorCode = purchase.error?.code;
          final errorMessage = purchase.error?.message ?? '';
          
          // Check if error is "itemAlreadyOwned" (billing response code 7)
          // This happens when user already owns the subscription but it's not verified
          if (errorMessage.contains('itemAlreadyOwned') || 
              errorMessage.contains('BillingResponse.itemAlreadyOwned') ||
              errorCode == 'purchase_error' && errorMessage.contains('7')) {
            if (kDebugMode) {
              print('Item already owned. Attempting to restore purchases...');
            }
            _error = null; // Clear error since we're handling it
            
            // Automatically trigger restore purchases to re-verify the existing subscription
            await restorePurchases(notifyLoading: false);
          } else {
            // Handle other errors normally
            _error = 'Purchase failed: $errorMessage';
            if (kDebugMode) print(_error);
          }
          
          _setLoading(false);
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          notifyListeners();
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // Verify purchase with Firebase Cloud Function
          await _verifyPurchaseWithServer(purchase);

          // Complete purchase
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }

          // Note: No need to call refreshSubscriptionStatus() here.
          // The verifyPurchaseWithServer() function already writes correct data to Firestore,
          // and the Firestore listener will automatically update _isSubscribed.
          // Calling refresh immediately can cause a race condition where Google Play
          // hasn't propagated the purchase yet, returning stale data.

          _setLoading(false);
          notifyListeners();
          break;

        case PurchaseStatus.canceled:
          _setLoading(false);
          notifyListeners();
          break;
      }
    }
  }

  /// Verify purchase with server via Cloud Function
  ///
  /// Returns true if verification succeeded, false otherwise.
  Future<bool> _verifyPurchaseWithServer(PurchaseDetails purchase) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (kDebugMode) print('Skip verify: no authenticated user');
        _error = 'Please sign in to verify purchase';
        return false;
      }

      final token = purchase.verificationData.serverVerificationData;

      if (kDebugMode) {
        print('Verifying purchase: ${purchase.productID}');
      }

      // Call Firebase Cloud Function to verify with Google Play
      // This also links the purchase to the user's UID
      final result = await _functions.httpsCallable('verifyPlayPurchase').call({
        'productId': purchase.productID,
        'purchaseToken': token,
      });

      if (kDebugMode) {
        print('Purchase verification result: ${result.data}');
      }

      _error = null;
      return true;
    } catch (e) {
      _error = 'Failed to verify purchase: $e';
      if (kDebugMode) print(_error);
      return false;
    }
  }

  /// Listen to Firestore entitlement document for real-time updates
  ///
  /// This provides instant updates when:
  /// - A purchase is verified
  /// - Subscription expires
  /// - Subscription is cancelled
  /// - Subscription enters grace period
  void _listenToEntitlement() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (kDebugMode) print('No user logged in - cannot listen to entitlement');
      return;
    }

    _entitlementSubscription?.cancel();
    _entitlementSubscription = _firestore
        .doc('users/$uid/subscriptions/current')
        .snapshots()
        .listen(
          (snap) {
            if (!snap.exists) {
              if (kDebugMode) print('No subscription document found');
              _isSubscribed = false;
              notifyListeners();
              return;
            }

            final data = snap.data();
            if (data == null) {
              if (kDebugMode) print('Subscription document is empty');
              _isSubscribed = false;
              notifyListeners();
              return;
            }

            // CRITICAL SECURITY CHECK:
            // Verify that the subscription belongs to the current user
            final docUserId = data['userId'] as String?;
            if (docUserId != null && docUserId != uid) {
              if (kDebugMode) {
                print(
                  'WARNING: Subscription userId mismatch! '
                  'Current: $uid, Document: $docUserId',
                );
              }
              _isSubscribed = false;
              _error = 'Subscription verification failed';
              notifyListeners();
              return;
            }

            final previousStatus = _isSubscribed;
            _isSubscribed = (data['isEntitled'] as bool?) ?? false;

            if (kDebugMode) {
              print('Entitlement status updated: $_isSubscribed');
              print('Subscription state: ${data['subscriptionState']}');
              if (data['expiryTimeMillis'] != null) {
                final expiryDate = DateTime.fromMillisecondsSinceEpoch(
                  data['expiryTimeMillis'] as int,
                );
                print('Expires at: $expiryDate');
              }
            }

            // Clear any previous errors if subscription is active
            if (_isSubscribed) {
              _error = null;
            }

            // Notify listeners if status changed
            if (previousStatus != _isSubscribed) {
              notifyListeners();
            }
          },
          onError: (e) {
            _error = 'Failed to listen to entitlement: $e';
            if (kDebugMode) print(_error);
            _isSubscribed = false;
            notifyListeners();
          },
        );
  }

  /// Refresh subscription status from Google Play via Cloud Function
  ///
  /// This should be called:
  /// - On app resume (handled automatically)
  /// - When user logs in
  /// - When user cancels subscription in Play Store (detected on next refresh)
  /// - When user wants to manually check subscription status
  /// 
  /// Note: This method includes debouncing to prevent rapid successive calls.
  /// Multiple calls within 5 seconds will be ignored to avoid hitting the API
  /// during Google Play's propagation window.
  Future<void> refreshSubscriptionStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (kDebugMode) print('Skip refresh: no authenticated user');
      return;
    }

    // DEBOUNCING: Prevent multiple refresh calls within 5 seconds
    final now = DateTime.now();
    if (_lastRefreshRequestTime != null) {
      final timeSinceLastRequest = now.difference(_lastRefreshRequestTime!);
      if (timeSinceLastRequest.inSeconds < 5) {
        if (kDebugMode) {
          print(
            'Refresh debounced: Last request was ${timeSinceLastRequest.inSeconds}s ago. '
            'Waiting ${5 - timeSinceLastRequest.inSeconds}s before next refresh.',
          );
        }
        return;
      }
    }
    _lastRefreshRequestTime = now;

    _setLoading(true);
    try {
      if (kDebugMode) print('Refreshing subscription status...');

      // Call Cloud Function to refresh subscription status from Google Play
      final result = await _functions
          .httpsCallable('refreshPlayPurchase')
          .call({});

      if (kDebugMode) {
        print('Subscription refresh result: ${result.data}');
      }

      _error = null;
      _lastRefreshTime = DateTime.now();
    } catch (e) {
      // If user has no subscription, this will throw an error
      // This is expected behavior - don't show error to user
      if (kDebugMode) print('Subscription refresh: $e');

      // Only set error if it's not a "no subscription" scenario
      if (e.toString().contains('not found') ||
          e.toString().contains('No subscription')) {
        _error = null;
      } else {
        _error = 'Failed to refresh subscription status';
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Ensure fresh subscription status with optional force refresh
  ///
  /// If force is true, always refreshes.
  /// If force is false, only refreshes if last refresh was more than 5 minutes ago.
  Future<void> ensureFreshStatus({bool force = false}) async {
    if (force) {
      await refreshSubscriptionStatus();
      return;
    }

    // Check if we need to refresh (last refresh was more than 5 minutes ago)
    if (_lastRefreshTime == null ||
        DateTime.now().difference(_lastRefreshTime!) >
            const Duration(minutes: 5)) {
      await refreshSubscriptionStatus();
    }
  }

  /// Restore purchases from the store
  ///
  /// This triggers the purchase stream to re-deliver any active purchases,
  /// which will then be verified with the server.
  Future<bool> restorePurchases({bool notifyLoading = true}) async {
    if (notifyLoading) _setLoading(true);
    try {
      await _iap.restorePurchases();
      _error = null;
      if (kDebugMode) print('Restore purchases initiated');
      return true;
    } catch (e) {
      _error = 'Failed to restore purchases: $e';
      if (kDebugMode) print(_error);
      return false;
    } finally {
      if (notifyLoading) _setLoading(false);
    }
  }

  /// Purchase a product
  ///
  /// Returns true if purchase was initiated successfully, false otherwise.
  /// The actual purchase result will come through the purchase stream.
  Future<bool> purchaseProduct(ProductDetails product) async {
    _setLoading(true);
    try {
      if (defaultTargetPlatform == TargetPlatform.android &&
          product is GooglePlayProductDetails) {
        final param = GooglePlayPurchaseParam(productDetails: product);
        await _iap.buyNonConsumable(purchaseParam: param);
      } else {
        final param = PurchaseParam(productDetails: product);
        await _iap.buyNonConsumable(purchaseParam: param);
      }
      return true;
    } catch (e) {
      _error = 'Purchase failed: $e';
      _setLoading(false);
      if (kDebugMode) print(_error);
      notifyListeners();
      return false;
    }
  }

  /// Open subscription management page in Play Store
  Future<void> openManagementPage() async {
    try {
      final uri = Platform.isIOS
          ? Uri.parse('https://apps.apple.com/account/subscriptions')
          : Uri.parse('https://play.google.com/store/account/subscriptions');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _error = 'Could not open subscription management';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to open management page: $e';
      if (kDebugMode) print(_error);
      notifyListeners();
    }
  }

  /// Observe app lifecycle to refresh subscription on resume
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh subscription status when app resumes
      // This catches subscription cancellations made in Play Store
      refreshSubscriptionStatus();
    }
    super.didChangeAppLifecycleState(state);
  }

  /// Check if user can access premium features
  bool canAccessPremiumFeature() => _isSubscribed;
  bool canCreateMultipleVacationAccounts() => _isSubscribed;
  bool canUseColorPicker() => _isSubscribed;
  bool canCreateRecurringBudgets() => _isSubscribed;

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    _entitlementSubscription?.cancel();
    _authSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
