import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Service to manage in-app review functionality
/// 
/// Handles:
/// - Tracking if user has already reviewed
/// - Counting consecutive transactions in a session
/// - Requesting review at appropriate times
class ReviewService {
  static ReviewService? _instance;
  static ReviewService get instance {
    _instance ??= ReviewService._internal();
    return _instance!;
  }

  ReviewService._internal();

  // SharedPreferences keys
  static const String _hasUserReviewedKey = 'hasUserReviewed';
  static const String _consecutiveTransactionCountKey = 'consecutiveTransactionCount';

  /// Check if user has already reviewed
  Future<bool> hasUserReviewed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_hasUserReviewedKey) ?? false;
    } catch (e) {
      if (kDebugMode) print('Error checking review status: $e');
      return false;
    }
  }

  /// Request review if eligible (user hasn't reviewed yet)
  /// Returns true if review was requested, false otherwise
  Future<bool> requestReviewIfEligible() async {
    try {
      // Check if user has already reviewed
      if (await hasUserReviewed()) {
        if (kDebugMode) print('User has already reviewed, skipping review request');
        return false;
      }

      // Check if in-app review is available
      final InAppReview inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        if (kDebugMode) print('Requesting in-app review');
        await inAppReview.requestReview();
        
        // Mark as reviewed (even if user didn't submit, to avoid spamming)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_hasUserReviewedKey, true);
        
        if (kDebugMode) print('Review prompt shown, marked as reviewed');
        return true;
      } else {
        if (kDebugMode) print('In-app review is not available');
        return false;
      }
    } catch (e) {
      if (kDebugMode) print('Error requesting review: $e');
      return false;
    }
  }

  /// Increment transaction count and check if review should be shown
  /// Returns true if review was requested (after 3 consecutive transactions)
  Future<bool> incrementTransactionCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCount = prefs.getInt(_consecutiveTransactionCountKey) ?? 0;
      final newCount = currentCount + 1;
      
      await prefs.setInt(_consecutiveTransactionCountKey, newCount);
      
      if (kDebugMode) {
        print('Transaction count incremented: $newCount');
      }

      // If we've reached 3 consecutive transactions, request review
      if (newCount >= 3) {
        if (kDebugMode) print('Reached 3 consecutive transactions, requesting review');
        final reviewRequested = await requestReviewIfEligible();
        
        // Reset counter after showing review (regardless of whether review was shown)
        await resetTransactionCount();
        
        return reviewRequested;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) print('Error incrementing transaction count: $e');
      return false;
    }
  }

  /// Reset transaction count
  Future<void> resetTransactionCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_consecutiveTransactionCountKey, 0);
      if (kDebugMode) print('Transaction count reset');
    } catch (e) {
      if (kDebugMode) print('Error resetting transaction count: $e');
    }
  }

  /// Get current transaction count (for debugging)
  Future<int> getTransactionCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_consecutiveTransactionCountKey) ?? 0;
    } catch (e) {
      if (kDebugMode) print('Error getting transaction count: $e');
      return 0;
    }
  }
}










