import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference for user subscription data
  CollectionReference get _usersCollection => _firestore.collection('users');

  /// Check if the current user is subscribed
  Future<bool> isUserSubscribed() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _usersCollection.doc(user.uid).get();
      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>?;
      return data?['subscribed'] == true;
    } catch (e) {
      print('Error checking subscription status: $e');
      return false;
    }
  }

  /// Set subscription status for the current user
  Future<bool> setSubscriptionStatus(bool subscribed) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _usersCollection.doc(user.uid).set({
        'subscribed': subscribed,
        'subscriptionUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('Error setting subscription status: $e');
      return false;
    }
  }

  /// Subscribe the current user (for development/testing)
  Future<bool> subscribeUser() async {
    return await setSubscriptionStatus(true);
  }

  /// Unsubscribe the current user (for development/testing)
  Future<bool> unsubscribeUser() async {
    return await setSubscriptionStatus(false);
  }

  /// Get subscription data for the current user
  Future<Map<String, dynamic>?> getSubscriptionData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _usersCollection.doc(user.uid).get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>?;
      return {
        'subscribed': data?['subscribed'] ?? false,
        'subscriptionUpdatedAt': data?['subscriptionUpdatedAt'],
      };
    } catch (e) {
      print('Error getting subscription data: $e');
      return null;
    }
  }

  /// Stream subscription status for real-time updates
  Stream<bool> getSubscriptionStatusStream() {
    try {
      final user = _auth.currentUser;
      if (user == null) return Stream.value(false);

      return _usersCollection.doc(user.uid).snapshots().map((doc) {
        if (!doc.exists) return false;
        final data = doc.data() as Map<String, dynamic>?;
        return data?['subscribed'] == true;
      });
    } catch (e) {
      print('Error creating subscription status stream: $e');
      return Stream.value(false);
    }
  }
}
