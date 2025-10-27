import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreenProvider with ChangeNotifier {
  bool _shouldRefresh = false;
  bool _shouldRefreshAccounts = false;
  bool _shouldRefreshTransactions = false;
  bool _shouldRefreshBothModes = false;
  DateTime? _transactionDate;
  DateTime? _selectedDate;
  bool _includeVacationTransactions = true;

  bool get shouldRefresh => _shouldRefresh;
  bool get shouldRefreshAccounts => _shouldRefreshAccounts;
  bool get shouldRefreshTransactions => _shouldRefreshTransactions;
  bool get shouldRefreshBothModes => _shouldRefreshBothModes;
  DateTime? get transactionDate => _transactionDate;
  DateTime? get selectedDate => _selectedDate;
  bool get includeVacationTransactions => _includeVacationTransactions;

  HomeScreenProvider() {
    _loadIncludeVacationTransactions();
  }

  Future<void> _loadIncludeVacationTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _includeVacationTransactions = prefs.getBool('includeVacationTransactions') ?? true;
      notifyListeners();
    } catch (e) {
      print('Error loading includeVacationTransactions preference: $e');
    }
  }

  Future<void> setIncludeVacationTransactions(bool value) async {
    try {
      _includeVacationTransactions = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('includeVacationTransactions', value);
      print('DEBUG: HomeScreenProvider.setIncludeVacationTransactions($value)');
      notifyListeners();
    } catch (e) {
      print('Error saving includeVacationTransactions preference: $e');
    }
  }

  void triggerRefresh({DateTime? transactionDate}) {
    _shouldRefresh = true;
    _transactionDate = transactionDate;
    // DEBUG
    print('DEBUG: HomeScreenProvider.triggerRefresh(date=$_transactionDate)');
    notifyListeners();
  }

  void triggerAccountRefresh() {
    _shouldRefreshAccounts = true;
    // DEBUG
    print('DEBUG: HomeScreenProvider.triggerAccountRefresh()');
    notifyListeners();
  }

  void triggerTransactionsRefresh() {
    _shouldRefreshTransactions = true;
    // DEBUG
    print('DEBUG: HomeScreenProvider.triggerTransactionsRefresh()');
    notifyListeners();
  }

  void requestRefreshForBothModes({DateTime? transactionDate}) {
    _shouldRefresh = true;
    _transactionDate = transactionDate;
    _shouldRefreshBothModes = true;
    print('DEBUG: HomeScreenProvider.requestRefreshForBothModes(date=$_transactionDate)');
    notifyListeners();
  }

  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  void completeRefresh() {
    _shouldRefresh = false;
    _shouldRefreshAccounts = false;
    _shouldRefreshTransactions = false;
    _shouldRefreshBothModes = false; // Add this line
    _transactionDate = null;
    // DEBUG
    print('DEBUG: HomeScreenProvider.completeRefresh()');
    notifyListeners();
  }
}