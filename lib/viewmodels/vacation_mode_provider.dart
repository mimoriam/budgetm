import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
 
class VacationProvider with ChangeNotifier {
  bool _isVacationMode = false;
  bool _isAiMode = false;
  String? _activeVacationAccountId;
 
  bool get isVacationMode => _isVacationMode;
  bool get isAiMode => _isAiMode;
  String? get activeVacationAccountId => _activeVacationAccountId;
 
  VacationProvider() {
    _loadVacationMode();
  }
 
  Future<void> _loadVacationMode() async {
    final prefs = await SharedPreferences.getInstance();
    _isVacationMode = prefs.getBool('vacationMode') ?? false;
    _isAiMode = _isVacationMode; // Sync AI mode on initial load
    _activeVacationAccountId = prefs.getString('activeVacationAccountId');
    notifyListeners();
  }
 
  Future<void> setVacationMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _isVacationMode = value;
    _isAiMode = value;
    await prefs.setBool('vacationMode', _isVacationMode);
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
 
  Future<void> setActiveVacationAccountId(String? accountId) async {
    final prefs = await SharedPreferences.getInstance();
    _activeVacationAccountId = accountId;
    if (accountId == null) {
      await prefs.remove('activeVacationAccountId');
    } else {
      await prefs.setString('activeVacationAccountId', accountId);
    }
    notifyListeners();
  }
 
  void toggleAiMode() {
    // This function now correctly serves as an alias for the main toggle
    toggleVacationMode();
  }
}
