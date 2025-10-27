// DEPRECATED: Do not use for gating subscription features.
// RevenueCat entitlements (via SubscriptionProvider) are the single source of truth.
// This file is kept only as a stub for backward compatibility and potential analytics mirroring.

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  @Deprecated('Use RevenueCat via SubscriptionProvider instead')
  Future<bool> isUserSubscribed() async => false;

  @Deprecated('Use RevenueCat via SubscriptionProvider instead')
  Future<bool> setSubscriptionStatus(bool subscribed) async => false;

  @Deprecated('Use RevenueCat via SubscriptionProvider instead')
  Future<bool> subscribeUser() async => false;

  @Deprecated('Use RevenueCat via SubscriptionProvider instead')
  Future<bool> unsubscribeUser() async => false;

  @Deprecated('Use RevenueCat via SubscriptionProvider instead')
  Future<Map<String, dynamic>?> getSubscriptionData() async => null;

  @Deprecated('Use RevenueCat via SubscriptionProvider instead')
  Stream<bool> getSubscriptionStatusStream() => Stream<bool>.value(false);
}
