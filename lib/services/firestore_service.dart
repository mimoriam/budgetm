import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Saves user data to a "users" collection in Firestore.
  /// The [uid] is used as the document ID.
  ///
  /// Throws a [FirebaseException] if there is an error.
 Future<void> saveUserData(String uid, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(uid).set(userData);
    } on FirebaseException catch (e) {
      // Re-throw the exception to be handled by the caller
      rethrow;
    }
  }
}