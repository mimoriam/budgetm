import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }
}
