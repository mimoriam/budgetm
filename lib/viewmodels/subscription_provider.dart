import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart'; // Import RevenueCat
import 'package:url_launcher/url_launcher.dart';
// import 'package:budgetm/services/subscription_service.dart'; // DELETE THIS

class SubscriptionProvider extends ChangeNotifier {
  // final SubscriptionService _subscriptionService = SubscriptionService(); // DELETE THIS

  bool _isSubscribed = false;
  bool _isLoading = false;
  String? _error;

  // --- ADD THIS ---
  Offerings? _offerings;
  DateTime? _expirationDate;
  bool? _willRenew;

  bool get isSubscribed => _isSubscribed;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // --- ADD THIS ---
  Offerings? get offerings => _offerings;
  DateTime? get expirationDate => _expirationDate;
  bool? get willRenew => _willRenew;

  /// Returns a short copy suitable for UI showing renew/expiry status
  String? get renewalCopy {
    if (_expirationDate == null) return null;
    final date = _expirationDate!;
    final renewing = _willRenew ?? true;
    final dateStr = date.toLocal().toIso8601String().split('T').first;
    return renewing ? 'Renews on $dateStr' : 'Expires on $dateStr (not renewing)';
  }

  SubscriptionProvider() {
    // _initializeSubscriptionStatus(); // DELETE THIS

    // --- ADD THESE ---
    // Listen for subscription changes
    Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);
    // Check initial subscription status
    _checkSubscriptionStatus();
    // Load products
    loadOfferings();
  }

  // --- ADD THIS ---
  @override
  void dispose() {
    Purchases.removeCustomerInfoUpdateListener(_onCustomerInfoUpdated);
    super.dispose();
  }

  // --- ADD THIS ---
  /// Handle real-time updates from RevenueCat
  void _onCustomerInfoUpdated(CustomerInfo customerInfo) {
    _updateSubscriptionStatus(customerInfo);
  }

  // --- ADD THIS ---
  /// Helper to check entitlement status
  void _updateSubscriptionStatus(CustomerInfo customerInfo) {
    // Get the active entitlement for "pro"
    final proEntitlement = customerInfo.entitlements.active['pro'];

    // Set status based on whether the "pro" entitlement is active
    _isSubscribed = proEntitlement != null;

    // Capture entitlement details for UI
    final String? expirationIsoString = proEntitlement?.expirationDate;
    _expirationDate =
        expirationIsoString != null ? DateTime.tryParse(expirationIsoString) : null;
    _willRenew = proEntitlement?.willRenew;

    notifyListeners();
  }

  /// Load subscription status from RevenueCat
  Future<void> _checkSubscriptionStatus() async {
    // Renamed from _loadSubscriptionStatus
    _setLoading(true);
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      _updateSubscriptionStatus(customerInfo); // Use the helper
      _error = null;
    } catch (e) {
      _error = 'Failed to load subscription status: $e';
      _isSubscribed = false;
    } finally {
      _setLoading(false);
    }
  }

  // --- ADD THIS ---
  /// Load available products (Offerings) from RevenueCat
  Future<void> loadOfferings() async {
    _setLoading(true);
    try {
      _offerings = await Purchases.getOfferings();
      _error = null;
    } catch (e) {
      _error = 'Failed to load offerings: $e';
      _offerings = null;
    } finally {
      _setLoading(false);
    }
  }

  // --- DELETE THESE METHODS ---
  // Future<bool> subscribeUser() async { ... }
  // Future<bool> unsubscribeUser() async { ... }

  /// Open the native subscription management page
  Future<void> openManagementPage() async {
    try {
      final info = await Purchases.getCustomerInfo();
      // managementURL may be a Uri or String depending on SDK version
      final Object? mgmt = info.managementURL;
      final Uri? rcUri = mgmt is Uri
          ? mgmt
          : (mgmt is String ? Uri.tryParse(mgmt) : null);
      final Uri uri = rcUri ??
          (Platform.isIOS
              ? Uri.parse('https://apps.apple.com/account/subscriptions')
              : Uri.parse('https://play.google.com/store/account/subscriptions'));
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
    await _checkSubscriptionStatus(); // This method is now correct
    // notifyListeners(); // _checkSubscriptionStatus already notifies
  }

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

  /// Restore purchases
  Future<bool> restorePurchases() async {
    _setLoading(true);
    try {
      // First restore purchases
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      
      // Force a fresh check of customer info to get the latest status
      customerInfo = await Purchases.getCustomerInfo();
      
      // Update subscription status based on the fresh data
      _updateSubscriptionStatus(customerInfo);
      
      // Check if user actually has an active subscription
      final proEntitlement = customerInfo.entitlements.active['pro'];
      final hasActiveSubscription = proEntitlement != null;
      
      _error = null;
      return hasActiveSubscription;
    } catch (e) {
      _error = 'Failed to restore purchases: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
