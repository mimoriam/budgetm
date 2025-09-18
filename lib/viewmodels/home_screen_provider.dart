import 'package:flutter/material.dart';

class HomeScreenProvider with ChangeNotifier {
  bool _shouldRefresh = false;

  bool get shouldRefresh => _shouldRefresh;

  void triggerRefresh() {
    _shouldRefresh = true;
    notifyListeners();
  }

  void completeRefresh() {
    _shouldRefresh = false;
    notifyListeners();
  }
}