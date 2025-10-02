import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VacationProvider with ChangeNotifier {
  bool _isVacationMode = false;
  bool _isAiMode = false;

  bool get isVacationMode => _isVacationMode;
  bool get isAiMode => _isAiMode;

  VacationProvider() {
    _loadVacationMode();
  }

  Future<void> _loadVacationMode() async {
    final prefs = await SharedPreferences.getInstance();
    _isVacationMode = prefs.getBool('vacationMode') ?? false;
    _isAiMode = _isVacationMode; // Sync AI mode on initial load
    notifyListeners();
  }

  Future<void> toggleVacationMode() async {
    final prefs = await SharedPreferences.getInstance();
    _isVacationMode = !_isVacationMode;
    _isAiMode = _isVacationMode; // Keep AI mode in sync with vacation mode
    await prefs.setBool('vacationMode', _isVacationMode);
    // Diagnostic log to observe when vacation mode toggles
    print('Vacation toggled -> $_isVacationMode (isAiMode=$_isAiMode)');
    notifyListeners();
  }

  void toggleAiMode() {
    // This function now correctly serves as an alias for the main toggle
    toggleVacationMode();
  }
}
