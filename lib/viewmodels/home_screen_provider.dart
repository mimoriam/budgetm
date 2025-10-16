import 'package:flutter/material.dart';

class HomeScreenProvider with ChangeNotifier {
  bool _shouldRefresh = false;
  bool _shouldRefreshAccounts = false;
  bool _shouldRefreshTransactions = false;
  DateTime? _transactionDate;
  DateTime? _selectedDate;

  bool get shouldRefresh => _shouldRefresh;
  bool get shouldRefreshAccounts => _shouldRefreshAccounts;
  bool get shouldRefreshTransactions => _shouldRefreshTransactions;
  DateTime? get transactionDate => _transactionDate;
  DateTime? get selectedDate => _selectedDate;

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

  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  void completeRefresh() {
    _shouldRefresh = false;
    _shouldRefreshAccounts = false;
    _shouldRefreshTransactions = false;
    _transactionDate = null;
    // DEBUG
    print('DEBUG: HomeScreenProvider.completeRefresh()');
    notifyListeners();
  }
}