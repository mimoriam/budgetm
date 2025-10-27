import 'package:flutter/foundation.dart';
import 'package:budgetm/services/subscription_service.dart';

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionService _subscriptionService = SubscriptionService();
  
  bool _isSubscribed = false;
  bool _isLoading = false;
  String? _error;

  bool get isSubscribed => _isSubscribed;
  bool get isLoading => _isLoading;
  String? get error => _error;

  SubscriptionProvider() {
    _initializeSubscriptionStatus();
  }

  /// Initialize subscription status on app start
  Future<void> _initializeSubscriptionStatus() async {
    await _loadSubscriptionStatus();
  }

  /// Load subscription status from database
  Future<void> _loadSubscriptionStatus() async {
    _setLoading(true);
    try {
      _isSubscribed = await _subscriptionService.isUserSubscribed();
      _error = null;
    } catch (e) {
      _error = 'Failed to load subscription status: $e';
      _isSubscribed = false;
    } finally {
      _setLoading(false);
    }
  }

  /// Subscribe user (for development/testing)
  Future<bool> subscribeUser() async {
    _setLoading(true);
    try {
      final success = await _subscriptionService.subscribeUser();
      if (success) {
        _isSubscribed = true;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to subscribe user';
        return false;
      }
    } catch (e) {
      _error = 'Error subscribing user: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Unsubscribe user (for development/testing)
  Future<bool> unsubscribeUser() async {
    _setLoading(true);
    try {
      final success = await _subscriptionService.unsubscribeUser();
      if (success) {
        _isSubscribed = false;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to unsubscribe user';
        return false;
      }
    } catch (e) {
      _error = 'Error unsubscribing user: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh subscription status
  Future<void> refreshSubscriptionStatus() async {
    await _loadSubscriptionStatus();
    notifyListeners();
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
}
