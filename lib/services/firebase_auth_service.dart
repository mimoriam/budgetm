import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:budgetm/services/firestore_service.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService.instance;

  /// Registers a new user with email and password
  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle specific FirebaseAuthException errors
      if (e.code == 'email-already-in-use') {
        throw Exception('The email address is already registered.');
      } else if (e.code == 'invalid-email') {
        throw Exception('The email address is invalid.');
      } else if (e.code == 'operation-not-allowed') {
        throw Exception('Email/password accounts are not enabled.');
      } else if (e.code == 'weak-password') {
        throw Exception('The password is too weak.');
      } else {
        throw Exception('An unknown error occurred: ${e.message}');
      }
    } catch (e) {
      // Handle any other errors
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Signs in an existing user with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle specific FirebaseAuthException errors
      if (e.code == 'invalid-email') {
        throw Exception('The email address is invalid.');
      } else if (e.code == 'user-disabled') {
        throw Exception('This user has been disabled.');
      } else if (e.code == 'user-not-found') {
        throw Exception('No user found with this email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Incorrect password.');
      } else {
        throw Exception('An unknown error occurred: ${e.message}');
      }
    } catch (e) {
      // Handle any other errors
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Sends a password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      // Handle specific FirebaseAuthException errors
      if (e.code == 'invalid-email') {
        throw Exception('The email address is invalid.');
      } else if (e.code == 'user-not-found') {
        throw Exception('No user found with this email.');
      } else {
        throw Exception('An unknown error occurred: ${e.message}');
      }
    } catch (e) {
      // Handle any other errors
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Handles Google Sign-In
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      // If the user cancels the sign-in, googleUser will be null
      if (googleUser == null) {
        throw Exception('Google Sign-In was canceled by the user.');
      }
      
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle specific FirebaseAuthException errors
      throw Exception('Firebase Auth error: ${e.message}');
    } catch (e) {
      // Handle any other errors
      throw Exception('An unexpected error occurred during Google Sign-In: $e');
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      throw Exception('An error occurred while signing out: $e');
    }
  }

  /// Returns a stream that emits User objects when the user's sign-in state changes
  Stream<User?> userChanges() {
    return _auth.userChanges();
  }
  
  /// Checks if the user is logging in for the first time
  /// Returns true if the user document doesn't exist in Firestore, false otherwise
  Future<bool> isFirstTimeUser(String uid) async {
    try {
      final exists = await _firestoreService.doesUserDocumentExist(uid);
      return !exists; // If document doesn't exist, it's a first-time user
    } catch (e) {
      // If there's an error checking, we assume it's not a first-time user
      return false;
    }
  }
}