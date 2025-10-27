import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  UserProvider() {
    _initializeUser();
  }

  void _initializeUser() {
    _currentUser = FirebaseAuth.instance.currentUser;
    notifyListeners();
  }

  void setUser(User? user) {
    if (_currentUser != user) {
      _currentUser = user;
      notifyListeners();
    }
  }

  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  String get displayName => _currentUser?.displayName ?? _currentUser?.email ?? 'User Name';
  String get email => _currentUser?.email ?? 'No email available';
  String? get photoURL => _currentUser?.photoURL;
  
  bool get hasGoogleProvider => _currentUser?.providerData.any((p) => p.providerId == 'google.com') ?? false;
}
