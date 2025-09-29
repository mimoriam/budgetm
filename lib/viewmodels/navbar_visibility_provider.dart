import 'package:flutter/foundation.dart';

class NavbarVisibilityProvider extends ChangeNotifier {
  bool _isNavBarVisible = true;

  bool get isNavBarVisible => _isNavBarVisible;

  void setNavBarVisibility(bool isVisible) {
    if (_isNavBarVisible != isVisible) {
      _isNavBarVisible = isVisible;
      notifyListeners();
    }
  }
}