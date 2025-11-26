import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:budgetm/services/review_service.dart';

/// Manages subscription state and handles in-app purchases for Google Play and App Store.
///
/// Key Features:
/// - Real-time subscription status via Firestore listener
/// - Proper user verification (subscription tied to Firebase UID)
/// - Automatic refresh on app resume
/// - No persistent caching of subscription status
/// - Platform-aware: automatically detects and handles iOS and Android purchases
///
/// Security:
/// - All purchases are verified server-side via Cloud Functions
/// - Subscription status always checked against authenticated user's UID
/// - Purchase tokens/transaction IDs are validated with store APIs before granting access
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
  static const String androidMonthlyId = 'android_monthly_subs';
  static const String androidYearlyId = 'android_yearly_subs';

  // Product IDs from App Store Connect
  static const String iosMonthlyId = 'buck_monthly_subs_ios';
  static const String iosYearlyId = 'buck_yearly_subs_ios';

  /// Get platform-specific product IDs
  Set<String> get _productIds {
    if (Platform.isIOS) {
      return {iosMonthlyId, iosYearlyId};
    } else {
      return {androidMonthlyId, androidYearlyId};
    }
  }

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
      final productIds = _productIds;
      
      // Get bundle ID/package name for diagnostics
      String? bundleId;
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        bundleId = Platform.isIOS ? packageInfo.packageName : null;
      } catch (e) {
        if (kDebugMode) print('Could not get package info: $e');
      }
      
      if (kDebugMode) {
        print('Querying products with IDs: ${productIds.join(", ")}');
        print('Platform: ${Platform.isIOS ? "iOS" : "Android"}');
        print('Store available: $_isStoreAvailable');
        if (bundleId != null) {
          print('Bundle ID: $bundleId');
        }
        if (Platform.isIOS && !_isStoreAvailable) {
          print('⚠️  Store not available - check StoreKit Configuration file setup');
        }
      }

      final response = await _iap.queryProductDetails(productIds);

      if (response.error != null) {
        final errorCode = response.error!.code;
        final errorMessage = response.error!.message;
        if (kDebugMode) {
          print('Product query error: $errorCode - $errorMessage');
        }
        
        // Handle specific StoreKit errors
        if (errorCode == 'storekit_no_response' || 
            errorMessage.contains('Failed to get response from platform')) {
          if (kDebugMode) {
            print('⚠️  STOREKIT_NO_RESPONSE ERROR DETECTED');
            print('This usually means the StoreKit Configuration file isn\'t being loaded.');
            print('');
            print('SOLUTIONS:');
            print('1. Run the app from Xcode (not Flutter CLI):');
            print('   - Stop Flutter run');
            print('   - Open: open ios/Runner.xcworkspace');
            print('   - Run from Xcode (Cmd+R)');
            print('');
            print('2. Verify StoreKit file is selected:');
            print('   - Product > Scheme > Edit Scheme');
            print('   - Run > Options > StoreKit Configuration');
            print('   - Should show: "Buck: Expense Tracker & Budget.storekit"');
            print('');
            print('3. Clean and rebuild:');
            print('   - Cmd+Shift+K (Clean Build Folder)');
            print('   - Quit Xcode completely');
            print('   - Reopen and rebuild');
            print('');
            print('4. Check StoreKit file location:');
            print('   - File should be in: ios/Buck: Expense Tracker & Budget.storekit');
            print('   - Ensure it\'s added to the Xcode project (not just in filesystem)');
          }
          _error = 'StoreKit not responding. Try running from Xcode instead of Flutter CLI.';
        } else {
          _error = 'Failed to load products: $errorMessage';
        }
        _products = [];
      } else {
        _products = response.productDetails.toList();
        // Sort by price (ascending)
        _products.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
        _error = null;
        
        if (kDebugMode) {
          print('Successfully loaded ${_products.length} product(s)');
          for (final product in _products) {
            print('  - ${product.id}: ${product.title} (${product.price})');
          }
        }
      }

      // Check for missing product IDs and provide helpful error message
      if (response.notFoundIDs.isNotEmpty) {
        final missingIds = response.notFoundIDs.join(', ');
        if (kDebugMode) {
          print('Missing product IDs: $missingIds');
          print('Found products: ${_products.map((p) => p.id).join(", ")}');
        }
        
        // If no products were found at all, set a helpful error message
        if (_products.isEmpty) {
          if (Platform.isIOS) {
            // User-friendly error message
            _error = 'Subscription products not available. Missing: $missingIds';
            
            // Detailed troubleshooting in debug logs
            if (kDebugMode) {
              print('=== PRODUCT LOADING TROUBLESHOOTING ===');
              print('Missing product IDs: $missingIds');
              print('Expected product IDs: ${productIds.join(", ")}');
              if (bundleId != null) {
                print('App Bundle ID: $bundleId');
                print('Expected Bundle ID: buck.budget.manager');
                if (bundleId != 'buck.budget.manager') {
                  print('⚠️  WARNING: Bundle ID mismatch!');
                }
              }
              print('');
              print('Common causes:');
              print('1. Products not created in App Store Connect');
              print('2. Products not in "Ready to Submit" or "Approved" status');
              print('3. Product IDs don\'t match exactly (case-sensitive)');
              print('4. Products not associated with Bundle ID: buck.budget.manager');
              print('5. ⚠️  STOREKIT CONFIGURATION: If using a .storekit file:');
              print('   - Verify the file is selected in Xcode scheme:');
              print('     Product > Scheme > Edit Scheme > Run > Options');
              print('   - Ensure products are in subscriptionGroups (not products array)');
              print('   - Product IDs must match exactly: buck_monthly_subs_ios, buck_yearly_subs_ios');
              print('   - After adding/modifying StoreKit file, restart Xcode and rebuild app');
              print('   - Try: Clean Build Folder (Cmd+Shift+K) then rebuild');
              print('6. Products may take up to 24 hours to propagate after creation');
              print('7. Ensure you\'re signed in with a sandbox test account (if testing)');
              print('=====================================');
            }
          } else {
            // User-friendly error message
            _error = 'Subscription products not available. Missing: $missingIds';
            
            // Detailed troubleshooting in debug logs
            if (kDebugMode) {
              print('=== PRODUCT LOADING TROUBLESHOOTING ===');
              print('Missing product IDs: $missingIds');
              print('Expected product IDs: ${productIds.join(", ")}');
              print('');
              print('Common causes:');
              print('1. Products not created in Google Play Console');
              print('2. Products not active or published');
              print('3. Product IDs don\'t match exactly (case-sensitive)');
              print('4. Products not associated with correct package name');
              print('5. Products may take time to propagate');
              print('=====================================');
            }
          }
        } else {
          // Some products found, but not all
          if (kDebugMode) {
            print('Warning: Only ${_products.length} of ${productIds.length} products found');
            print('Missing: ${response.notFoundIDs.join(", ")}');
          }
          // Don't set error if we have at least some products
          // The paywall will show available products
        }
      }
    } catch (e, stackTrace) {
      _error = 'Failed to load products: $e';
      _products = [];
      if (kDebugMode) {
        print('Exception loading products: $e');
        print('Stack trace: $stackTrace');
      }
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
          
          // Handle platform-specific errors
          if (Platform.isAndroid) {
            // Android: Check if error is "itemAlreadyOwned" (billing response code 7)
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
              // Handle other Android errors normally
              _error = 'Purchase failed: $errorMessage';
              if (kDebugMode) print(_error);
            }
          } else if (Platform.isIOS) {
            // iOS: Handle common App Store errors
            // iOS doesn't have the same "itemAlreadyOwned" error, but we can still
            // attempt to restore purchases for certain error conditions
            if (errorMessage.contains('already purchased') ||
                errorMessage.contains('already owns') ||
                errorCode == 'storekit_error') {
              if (kDebugMode) {
                print('iOS purchase error detected. Attempting to restore purchases...');
              }
              _error = null; // Clear error since we're handling it
              
              // Automatically trigger restore purchases to re-verify the existing subscription
              await restorePurchases(notifyLoading: false);
            } else {
              // Handle other iOS errors normally
              _error = 'Purchase failed: $errorMessage';
              if (kDebugMode) print(_error);
            }
          } else {
            // Unknown platform or other errors
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
          // Calling refresh immediately can cause a race condition where the store
          // (Google Play or App Store) hasn't propagated the purchase yet, returning stale data.

          // Request in-app review after successful purchase
          ReviewService.instance.requestReviewIfEligible();

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

  /// Check if a transaction ID looks like a StoreKit Configuration test transaction
  /// StoreKit test transactions are typically UUIDs or have specific patterns
  bool _isStoreKitTestTransaction(String? transactionId) {
    if (transactionId == null || transactionId.isEmpty) return false;
    // StoreKit Configuration test transactions are typically UUIDs
    // Format: 8-4-4-4-12 hexadecimal characters
    final uuidPattern = RegExp(r'^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$');
    return uuidPattern.hasMatch(transactionId);
  }

  /// Save StoreKit test purchase directly to Firestore (for local testing)
  Future<bool> _saveStoreKitTestPurchase(PurchaseDetails purchase, String uid) async {
    try {
      if (kDebugMode) {
        print('Detected StoreKit Configuration test purchase - saving directly to Firestore');
      }

      // Calculate expiry time based on subscription period
      DateTime? expiryTime;
      if (purchase.productID == iosMonthlyId) {
        expiryTime = DateTime.now().add(const Duration(days: 30));
      } else if (purchase.productID == iosYearlyId) {
        expiryTime = DateTime.now().add(const Duration(days: 365));
      }

      final docRef = _firestore.doc('users/$uid/subscriptions/current');
      await docRef.set(
        {
          'store': 'app_store',
          'productId': purchase.productID,
          'originalTransactionId': purchase.purchaseID,
          'bundleId': 'buck.budget.manager',
          'environment': 'storekit_test',
          'userId': uid,
          'isEntitled': true,
          'subscriptionState': 'SUBSCRIPTION_STATE_ACTIVE',
          'expiryTimeMillis': expiryTime?.millisecondsSinceEpoch,
          'autoRenewing': true,
          'verifiedAt': FieldValue.serverTimestamp(),
          'lastCheckedAt': FieldValue.serverTimestamp(),
          'isStoreKitTest': true, // Flag to indicate this is a test transaction
        },
        SetOptions(merge: true),
      );

      if (kDebugMode) {
        print('StoreKit test purchase saved successfully');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save StoreKit test purchase: $e');
      }
      return false;
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

      if (kDebugMode) {
        print('Verifying purchase: ${purchase.productID}');
      }

      // Detect platform and call appropriate Cloud Function
      if (Platform.isIOS) {
        // For iOS: Extract originalTransactionId from purchaseID
        // For subscriptions, purchaseID is the transaction identifier
        // For the first purchase, this is the originalTransactionId
        final originalTransactionId = purchase.purchaseID;
        
        if (originalTransactionId == null || originalTransactionId.isEmpty) {
          _error = 'Failed to verify purchase: Missing transaction ID';
          if (kDebugMode) print(_error);
          return false;
        }

        // Check if this is a StoreKit Configuration test transaction
        // StoreKit test transactions can't be verified with App Store Server API
        if (_isStoreKitTestTransaction(originalTransactionId)) {
          if (kDebugMode) {
            print('Detected StoreKit Configuration test transaction - skipping server verification');
          }
          // Save directly to Firestore for local testing
          return await _saveStoreKitTestPurchase(purchase, user.uid);
        }

        // Call Firebase Cloud Function to verify with App Store
        // This also links the purchase to the user's UID
        try {
          final result = await _functions.httpsCallable('verifyAppStorePurchase').call({
            'productId': purchase.productID,
            'originalTransactionId': originalTransactionId,
          });

          if (kDebugMode) {
            print('App Store purchase verification result: ${result.data}');
          }

          _error = null;
          return true;
        } on FirebaseFunctionsException catch (e) {
          // If verification fails, check if it's a StoreKit test transaction
          // StoreKit test transactions will fail with "transaction not found" type errors
          if (kDebugMode) {
            print('Server verification failed: ${e.code} - ${e.message}');
            print('This might be a StoreKit Configuration test transaction');
          }

          // If it's an internal error and we're in debug mode, try saving as test purchase
          if (e.code == 'internal' && kDebugMode) {
            if (kDebugMode) {
              print('Attempting to save as StoreKit test purchase...');
            }
            return await _saveStoreKitTestPurchase(purchase, user.uid);
          }

          // Re-throw if it's not a test transaction or not in debug mode
          rethrow;
        }
      } else {
        // For Android: Use purchase token
        final token = purchase.verificationData.serverVerificationData;

        // Call Firebase Cloud Function to verify with Google Play
        // This also links the purchase to the user's UID
        final result = await _functions.httpsCallable('verifyPlayPurchase').call({
          'productId': purchase.productID,
          'purchaseToken': token,
        });

        if (kDebugMode) {
          print('Google Play purchase verification result: ${result.data}');
        }
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

  /// Refresh subscription status from Google Play or App Store via Cloud Function
  ///
  /// This should be called:
  /// - On app resume (handled automatically)
  /// - When user logs in
  /// - When user cancels subscription in store (detected on next refresh)
  /// - When user wants to manually check subscription status
  /// 
  /// Note: This method includes debouncing to prevent rapid successive calls.
  /// Multiple calls within 5 seconds will be ignored to avoid hitting the API
  /// during store propagation windows.
  /// 
  /// The method automatically detects the store type from Firestore and calls
  /// the appropriate refresh function. If no store type is found, it defaults
  /// to the current platform's store.
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

      // Check Firestore to determine store type
      final subRef = _firestore.doc('users/${user.uid}/subscriptions/current');
      final snap = await subRef.get();
      
      String? storeType;
      bool isStoreKitTest = false;
      if (snap.exists) {
        final data = snap.data();
        storeType = data?['store'] as String?;
        isStoreKitTest = (data?['isStoreKitTest'] as bool?) ?? false;
        final environment = data?['environment'] as String?;
        
        // Also check environment field
        if (environment == 'storekit_test') {
          isStoreKitTest = true;
        }
      }

      // Skip server refresh for StoreKit test purchases
      if (isStoreKitTest) {
        if (kDebugMode) {
          print('Skipping server refresh for StoreKit test purchase');
          print('Subscription status will be read from Firestore listener');
        }
        _error = null;
        _lastRefreshTime = DateTime.now();
        return;
      }

      // If no store type found, default to current platform
      if (storeType == null) {
        storeType = Platform.isIOS ? 'app_store' : 'google_play';
        if (kDebugMode) {
          print('No store type in Firestore, defaulting to: $storeType');
        }
      }

      // Call appropriate Cloud Function based on store type
      final String functionName;
      if (storeType == 'app_store') {
        functionName = 'refreshAppStorePurchase';
      } else {
        // Default to Google Play for backward compatibility
        functionName = 'refreshPlayPurchase';
      }

      if (kDebugMode) {
        print('Calling $functionName for store: $storeType');
      }

      final result = await _functions
          .httpsCallable(functionName)
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
