import 'package:flutter/foundation.dart';
 
class NavbarVisibilityProvider extends ChangeNotifier {
  bool _isNavBarVisible = true;
  int _currentIndex = 0;
  bool _isDialogMode = false; // New flag to indicate when dialogs are shown

  bool get isNavBarVisible => _isNavBarVisible;
  int get currentIndex => _currentIndex;
  bool get isDialogMode => _isDialogMode;

  void setNavBarVisibility(bool isVisible) {
    // Don't allow hiding navbar when on home screen (index 0) unless in dialog mode
    if (_currentIndex == 0 && !_isDialogMode && !isVisible) {
      return; // Ignore hide requests on home screen when not in dialog mode
    }
    
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
      // Ensure navbar is visible when switching to home screen
      if (index == 0) {
        _isNavBarVisible = true;
      }
      notifyListeners();
    }
  }

  /// Enable dialog mode to allow navbar hiding on home screen
  void setDialogMode(bool isDialogMode) {
    if (_isDialogMode != isDialogMode) {
      _isDialogMode = isDialogMode;
      notifyListeners();
    }
  }
}