import 'package:flutter/foundation.dart';
 
class NavbarVisibilityProvider extends ChangeNotifier {
  bool _isNavBarVisible = true;
  int _currentIndex = 0;
 
  bool get isNavBarVisible => _isNavBarVisible;
  int get currentIndex => _currentIndex;
 
  void setNavBarVisibility(bool isVisible) {
    if (_isNavBarVisible != isVisible) {
      _isNavBarVisible = isVisible;
      notifyListeners();
    }
  }
 
  /// Keep track of the currently selected tab index in MainScreen.
  /// BudgetScreen will use this to decide whether it is the active tab
  /// before showing the vacation dialog.
  void setCurrentIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }
}