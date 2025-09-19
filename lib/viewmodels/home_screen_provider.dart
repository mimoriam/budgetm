import 'package:flutter/material.dart';

class HomeScreenProvider with ChangeNotifier {
  bool _shouldRefresh = false;
  bool _shouldRefreshAccounts = false; // New field

  bool get shouldRefresh => _shouldRefresh;
  bool get shouldRefreshAccounts => _shouldRefreshAccounts; // New getter

  void triggerRefresh() {
    _shouldRefresh = true;
    notifyListeners();
  }

  void triggerAccountRefresh() { // New method
    _shouldRefreshAccounts = true;
    notifyListeners();
  }

  void completeRefresh() {
    _shouldRefresh = false;
    _shouldRefreshAccounts = false; // Reset the new flag
    notifyListeners();
  }
}