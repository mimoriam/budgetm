import 'dart:async';
import 'package:flutter/material.dart';
import 'package:budgetm/models/budget.dart';
import 'package:budgetm/models/category.dart';
import 'package:budgetm/models/firestore_transaction.dart';
import 'package:budgetm/services/firestore_service.dart';

class BudgetProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService.instance;
  
  // Selected date
  DateTime _selectedDate = DateTime.now();
  
  // Data
  List<Budget> _budgets = [];
  List<Category> _allCategories = [];
  List<Category> _expenseCategories = [];
  List<FirestoreTransaction> _transactions = [];
  
  // Selected category for pie chart drill-down
  String? _selectedCategoryId;
  
  // Loading state
  bool _isLoading = false;
  
  // Stream subscription for auto-refresh
  StreamSubscription<List<FirestoreTransaction>>? _transactionsSubscription;
  
  // Getters
  DateTime get selectedDate => _selectedDate;
  int get selectedYear => _selectedDate.year;
  int get selectedMonth => _selectedDate.month;
  List<Budget> get budgets => _budgets;
  List<Category> get allCategories => _allCategories;
  List<Category> get expenseCategories => _expenseCategories;
  List<FirestoreTransaction> get transactions => _transactions;
  String? get selectedCategoryId => _selectedCategoryId;
  bool get isLoading => _isLoading;
  
  // Get combined budget data (categories with their budgets)
  List<CategoryBudgetData> get categoryBudgetData {
    // Sort categories by displayOrder (0 first) without mutating the original list
    final sortedCategories = [..._expenseCategories]..sort((a, b) {
      final aOrder = a.displayOrder ?? 0;
      final bOrder = b.displayOrder ?? 0;
      return aOrder.compareTo(bOrder);
    });

    return sortedCategories.map((category) {
      final budget = _budgets.firstWhere(
        (b) => b.categoryId == category.id,
        orElse: () => Budget(
          id: '',
          categoryId: category.id,
          year: selectedYear,
          month: selectedMonth,
          spentAmount: 0.0,
          userId: '',
        ),
      );
      return CategoryBudgetData(
        category: category,
        budget: budget,
      );
    }).toList();
  }
  
  // Get total spent amount
  double get totalSpent {
    return _budgets.fold(0.0, (sum, budget) => sum + budget.spentAmount);
  }
  
  // Get transactions for selected category
  List<FirestoreTransaction> get filteredTransactions {
    if (_selectedCategoryId == null) return _transactions;
    return _transactions.where((t) => t.categoryId == _selectedCategoryId).toList();
  }
  
  // Initialize and load data
  Future<void> initialize() async {
    await loadData();
    _setupTransactionsListener();
  }
  
  // Set up listener for transactions stream
  void _setupTransactionsListener() {
    // Cancel existing subscription if any
    _transactionsSubscription?.cancel();
    
    // Subscribe to all transactions stream and filter for current month
    _transactionsSubscription = _firestoreService
        .streamTransactions()
        .listen((transactions) {
      // Filter for expenses in the selected month
      final startDate = DateTime(selectedYear, selectedMonth, 1);
      final endDate = DateTime(selectedYear, selectedMonth + 1, 0, 23, 59, 59);
      
      _transactions = transactions.where((t) {
        return t.type == 'expense' &&
            t.date.isAfter(startDate) &&
            t.date.isBefore(endDate);
      }).toList();
      
      // Reload budgets to recalculate spent amounts
      _reloadBudgets();
    });
  }
  
  // Reload budgets without full data refresh
  Future<void> _reloadBudgets() async {
    try {
      _budgets = await _firestoreService.getBudgetsForMonth(selectedYear, selectedMonth);
      notifyListeners();
    } catch (e) {
      print('Error reloading budgets: $e');
    }
  }
  
  Future<void> _fetchCategories() async {
    final allCategories = await _firestoreService.getAllCategories();
    _allCategories = allCategories;
    _expenseCategories = allCategories.where((cat) => cat.type == 'expense').toList();
  }

  Future<void> refreshCategories() async {
    _isLoading = true;
    notifyListeners();

    await _fetchCategories();

    _isLoading = false;
    notifyListeners();
  }
  
  // Load all data for the selected month
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _fetchCategories();
      
      // Load budgets for selected month
      _budgets = await _firestoreService.getBudgetsForMonth(selectedYear, selectedMonth);
      
      // Load transactions for selected month
      final startDate = DateTime(selectedYear, selectedMonth, 1);
      final endDate = DateTime(selectedYear, selectedMonth + 1, 0, 23, 59, 59);
      final allTransactions = await _firestoreService.getTransactionsForDateRange(startDate, endDate);
      _transactions = allTransactions.where((t) => t.type == 'expense').toList();
      
    } catch (e) {
      print('Error loading budget data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Change selected month/year
  void changeMonth(int year, int month) {
    _selectedDate = DateTime(year, month);
    _selectedCategoryId = null; // Reset selection when changing month
    loadData();
    _setupTransactionsListener(); // Re-setup listener for new month
  }
  
  // Navigate to previous month
  void previousMonth() {
    final newDate = DateTime(selectedYear, selectedMonth - 1);
    changeMonth(newDate.year, newDate.month);
  }
  
  // Navigate to next month
  void nextMonth() {
    final newDate = DateTime(selectedYear, selectedMonth + 1);
    changeMonth(newDate.year, newDate.month);
  }
  
  // Select category for pie chart drill-down
  void selectCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }
  
  // Clear category selection
  void clearCategorySelection() {
    _selectedCategoryId = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _transactionsSubscription?.cancel();
    super.dispose();
  }
}

// Helper class to combine category and budget data
class CategoryBudgetData {
  final Category category;
  final Budget budget;
  
  CategoryBudgetData({
    required this.category,
    required this.budget,
  });
  
  String get categoryName => category.name ?? 'Unnamed';
  String get categoryIcon => category.icon ?? 'category';
  String get categoryColor => category.name ?? 'grey';
  double get spentAmount => budget.spentAmount;
}