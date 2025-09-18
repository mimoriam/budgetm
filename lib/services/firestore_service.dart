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

  /// Checks if a user document exists in Firestore.
  /// Returns true if the document exists, false otherwise.
  Future<bool> doesUserDocumentExist(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      return docSnapshot.exists;
    } catch (e) {
      // If there's an error, we assume the document doesn't exist
      return false;
    }
  }
}