import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:budgetm/services/firestore_service.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _firestoreName; // Cache for name from Firestore

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  UserProvider() {
    _initializeUser();
  }

  void _initializeUser() {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _loadUserDataFromFirestore();
    }
    notifyListeners();
  }

  void setUser(User? user) {
    if (_currentUser != user) {
      _currentUser = user;
      _firestoreName = null; // Reset cache when user changes
      if (user != null) {
        _loadUserDataFromFirestore();
      }
      notifyListeners();
    }
  }

  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Loads user data from Firestore to get the name field
  Future<void> _loadUserDataFromFirestore() async {
    if (_currentUser == null) return;
    
    try {
      final userData = await FirestoreService.instance.getUserData(_currentUser!.uid);
      if (userData != null && userData.containsKey('name')) {
        final name = userData['name'] as String?;
        if (name != null && name.isNotEmpty) {
          _firestoreName = name;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading user data from Firestore: $e');
      // Silently fail - we'll just use the fallback displayName
    }
  }

  /// Refreshes user data from Firestore (useful after updating display name)
  Future<void> refreshUserData() async {
    await _loadUserDataFromFirestore();
  }

  String get displayName {
    // Priority: Firebase Auth displayName > Firestore name > email > fallback
    if (_currentUser?.displayName != null && _currentUser!.displayName!.isNotEmpty) {
      return _currentUser!.displayName!;
    }
    if (_firestoreName != null && _firestoreName!.isNotEmpty) {
      return _firestoreName!;
    }
    return _currentUser?.email ?? 'User Name';
  }
  
  String get email => _currentUser?.email ?? 'No email available';
  String? get photoURL => _currentUser?.photoURL;
  
  bool get hasGoogleProvider => _currentUser?.providerData.any((p) => p.providerId == 'google.com') ?? false;
}
