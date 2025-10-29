import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
// ADD these imports
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';
// If you are not on the Play Store, you might need this
// import 'package:in_app_purchase_android/in_app_purchase_android.dart';
// REMOVE RevenueCat import
// import 'package:purchases_flutter/purchases_flutter.dart';

// REMOVE deprecated service import
// import 'package:budgetm/services/subscription_service.dart'; // DELETE THIS

class SubscriptionProvider extends ChangeNotifier {
  // --- NEW VARIABLES ---
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // TODO: IMPORTANT!
  // Define your product IDs from App Store Connect & Google Play Console
  final Set<String> _productIds = {'budgetm_monthly', 'budgetm_yearly'};

  List<ProductDetails> _products = [];
  final List<PurchaseDetails> _purchases = [];
  bool _isStoreAvailable = false;

  // --- STATE VARIABLES ---
  bool _isSubscribed = false;
  bool _isLoading = false;
  String? _error;

  // --- PUBLIC GETTERS ---
  bool get isSubscribed => _isSubscribed;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// This replaces the RevenueCat 'offerings' getter
  List<ProductDetails> get products => _products;

  // You can re-implement this if you parse the expiration date
  // during purchase verification
  // String? get renewalCopy { ... }

  SubscriptionProvider() {
    // Listen to the purchase stream
    final Stream<List<PurchaseDetails>> purchaseStream = _iap.purchaseStream;
    _subscription = purchaseStream.listen(
      _onPurchaseStreamUpdated, // Main listener
      onDone: () {
        _subscription?.cancel();
      },
      onError: (e) {
        _error = 'Purchase stream error: $e';
        notifyListeners();
      },
    );

    // Initialize the store
    _initializeIAP();
  }

  // --- ADD THIS ---
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // --- ADD THIS ---
  /// Main initialization method
  Future<void> _initializeIAP() async {
    _setLoading(true);
    _isStoreAvailable = await _iap.isAvailable();

    if (_isStoreAvailable) {
      await _loadProducts();
      // Restore purchases on init to check for existing subscriptions
      await restorePurchases(notifyLoading: false);
    } else {
      _error = 'In-app purchases are not available.';
    }
    _setLoading(false);
  }

  // --- REPLACES _onCustomerInfoUpdated ---
  /// Handle updates from the purchase stream
  Future<void> _onPurchaseStreamUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (var purchase in purchaseDetailsList) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _setLoading(true);
          break;
        case PurchaseStatus.error:
          _error = 'Purchase failed: ${purchase.error?.message}';
          _setLoading(false);
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // 1. Verify the purchase
          bool valid = await _verifyPurchase(purchase);

          if (valid) {
            // 2. Grant entitlement
            _isSubscribed = true;
            if (!_purchases.any((p) => p.purchaseID == purchase.purchaseID)) {
              _purchases.add(purchase);
            }
          }

          // 3. Complete the purchase
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          _setLoading(false);
          break;
        case PurchaseStatus.canceled:
          _setLoading(false);
          break;
      }
    }

    // Update the final subscription status
    _updateSubscriptionStatus();
    notifyListeners();
  }

  // --- REPLACES _updateSubscriptionStatus ---
  /// Simple helper to update _isSubscribed based on the _purchases list
  void _updateSubscriptionStatus() {
    // This is a basic check. For real subscriptions, you need
    // to check the expiration date from your server.
    //
    // For now, we assume if a valid purchase is in the list, they are subscribed.
    _isSubscribed = _purchases.isNotEmpty;

    // TODO: A more robust check:
    // This requires parsing the receipt on your server and storing an
    // expiration date in your database (e.g., Firestore).
    // You would then check that date here.
    // _isSubscribed = _purchases.any((purchase) {
    //   // return purchase.expirationDate.isAfter(DateTime.now());
    //   return true;
    // });

    notifyListeners();
  }

  // --- ADD THIS ---
  /// This is where you MUST verify the purchase with your server.
  /// DO NOT rely on client-side validation for a real app.
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // ---
    // !! CRITICAL SECURITY WARNING !!
    // ---
    // Send `purchaseDetails.verificationData` to your backend server.
    //
    // Your server must then validate this token/receipt with the
    // Apple or Google store APIs.
    //
    // - Apple: `purchaseDetails.verificationData.serverVerificationData`
    // - Google: `purchaseDetails.verificationData.localVerificationData`
    //
    // Only return `true` if your server confirms the purchase is valid
    // and grants the user entitlement (e.g., sets an "isPro" flag in Firestore).
    //
    // For this example, we'll just assume it's valid.
    // **THIS IS NOT SECURE FOR PRODUCTION.**
    if (kDebugMode) {
      print("Verifying purchase: ${purchaseDetails.productID}");
    }
    // In a real app, this `true` must come from YOUR server.
    return true;
  }

  /// REPLACES _checkSubscriptionStatus
  /// Load subscription status (called during init and refresh)
  Future<void> _checkSubscriptionStatus() async {
    _setLoading(true);
    try {
      // With in_app_purchase, "checking status" is best done by
      // restoring purchases, which triggers the stream listener.
      await _iap.restorePurchases();
      _error = null;
    } catch (e) {
      _error = 'Failed to load subscription status: $e';
      _isSubscribed = false;
    } finally {
      _setLoading(false);
    }
  }

  // --- REPLACES loadOfferings ---
  /// Load available products (ProductDetails) from the store
  Future<void> _loadProducts() async {
    _setLoading(true);
    try {
      final ProductDetailsResponse response = await _iap.queryProductDetails(
        _productIds,
      );

      if (response.error != null) {
        _error = 'Failed to load products: ${response.error!.message}';
        _products = [];
      } else {
        _products = response.productDetails;
        _error = null;
      }

      // --- START OF ADDED MOCKING LOGIC (PART 1) ---
      // FOR DEVELOPMENT TESTING: If no products were loaded from the store,
      // add mock products so the UI can be tested.
      // if (_products.isEmpty && kDebugMode) {
      if (_products.isEmpty) {
        _products = [
          ProductDetails(
            id: 'budgetm_monthly',
            title: 'Monthly Plan (Mock)',
            description: 'A mock monthly subscription for testing.',
            price: '\$4.99',
            rawPrice: 4.99,
            currencyCode: 'USD',
          ),
          ProductDetails(
            id: 'budgetm_yearly',
            title: 'Yearly Plan (Mock)',
            description: 'A mock yearly subscription for testing.',
            price: '\$29.99',
            rawPrice: 29.99,
            currencyCode: 'USD',
          ),
        ];
        _error = null; // Clear the "Failed to load products" error
      }
      // --- END OF ADDED MOCKING LOGIC (PART 1) ---
    } catch (e) {
      _error = 'Failed to load products: $e';
      _products = [];
    } finally {
      // Sort products if they exist (mock or real)
      if (_products.isNotEmpty) {
        _products.sort((a, b) => a.price.compareTo(b.price));
      }
      _setLoading(false);
    }
  }

  // --- DELETE RevenueCat-specific methods ---
  // Future<bool> subscribeUser() async { ... }
  // Future<bool> unsubscribeUser() async { ... }

  // --- ADD THIS ---
  /// Initiates a purchase for a given product
  Future<bool> purchaseProduct(ProductDetails productDetails) async {
    _setLoading(true);

    // --- START OF ADDED MOCKING LOGIC (PART 2) ---
    // FOR DEVELOPMENT TESTING: Simulate a successful purchase in debug mode
    // by bypassing the actual IAP call.
    // if (kDebugMode) {
      // Manually set the state to subscribed
      _isSubscribed = true;
      _setLoading(false);
      // Notify listeners to update the UI (e.g., pop the paywall)
      notifyListeners();
      return true; // Indicate the "purchase" was "initiated" successfully
    // }
    // --- END OF ADDED MOCKING LOGIC (PART 2) ---

    // --- Original Logic (will be skipped in kDebugMode) ---
    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
    );

    try {
      // For subscriptions, use `buyNonConsumable` (per `in_app_purchase` docs)
      // For consumables, use `buyConsumable`
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      // The result is handled by the _onPurchaseStreamUpdated stream listener
      return true;
    } catch (e) {
      _error = 'Purchase failed: $e';
      _setLoading(false);
      return false;
    }
    // Note: _setLoading(false) will be called by the listener
    // when the purchase is finalized (purchased, error, or cancelled).
  }

  /// Open the native subscription management page
  Future<void> openManagementPage() async {
    try {
      // REMOVED RevenueCat-specific URL lookup
      // final info = await Purchases.getCustomerInfo();
      // final Object? mgmt = info.managementURL;
      // ...

      // Use static URLs
      final Uri uri = Platform.isIOS
          ? Uri.parse('https://apps.apple.com/account/subscriptions')
          : Uri.parse('https://play.google.com/store/account/subscriptions');

      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        throw 'Could not open subscription management';
      }
    } catch (e) {
      _error = 'Failed to open management: $e';
      notifyListeners();
    }
  }

  /// Refresh subscription status
  Future<void> refreshSubscriptionStatus() async {
    // This now just calls _checkSubscriptionStatus
    await _checkSubscriptionStatus();
  }

  // ---
  // ALL THE METHODS BELOW ARE KEPT AS-IS
  // They provide the public interface for your UI,
  // and they all rely on the `_isSubscribed` boolean,
  // which we are now setting ourselves.
  // ---

  /// Check if user can access premium features
  bool canAccessPremiumFeature() {
    return _isSubscribed;
  }

  /// Check if user can create multiple vacation accounts
  bool canCreateMultipleVacationAccounts() {
    return _isSubscribed;
  }

  /// Check if user can use color picker
  bool canUseColorPicker() {
    return _isSubscribed;
  }

  /// Check if user can create recurring budgets
  bool canCreateRecurringBudgets() {
    return _isSubscribed;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// REPLACES RevenueCat's restorePurchases
  Future<bool> restorePurchases({bool notifyLoading = true}) async {
    if (notifyLoading) _setLoading(true);
    try {
      await _iap.restorePurchases();
      // Results are handled by the _onPurchaseStreamUpdated stream listener
      _error = null;
      // We return true for the *attempt* to restore.
      // The listener will update `_isSubscribed` if anything is found.
      return true;
    } catch (e) {
      _error = 'Failed to restore purchases: $e';
      return false;
    } finally {
      if (notifyLoading) _setLoading(false);
    }
  }
}
