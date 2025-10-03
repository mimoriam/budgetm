import 'package:flutter/material.dart';

class HomeScreenProvider with ChangeNotifier {
  bool _shouldRefresh = false;
  bool _shouldRefreshAccounts = false;
  bool _shouldRefreshTransactions = false;
  DateTime? _transactionDate;

  bool get shouldRefresh => _shouldRefresh;
  bool get shouldRefreshAccounts => _shouldRefreshAccounts;
  bool get shouldRefreshTransactions => _shouldRefreshTransactions;
  DateTime? get transactionDate => _transactionDate;

  void triggerRefresh({DateTime? transactionDate}) {
    _shouldRefresh = true;
    _transactionDate = transactionDate;
    notifyListeners();
  }

  void triggerAccountRefresh() {
    _shouldRefreshAccounts = true;
    notifyListeners();
  }

  void triggerTransactionsRefresh() {
    _shouldRefreshTransactions = true;
    notifyListeners();
  }

  void completeRefresh() {
    _shouldRefresh = false;
    _shouldRefreshAccounts = false;
    _shouldRefreshTransactions = false;
    _transactionDate = null;
    notifyListeners();
  }
}