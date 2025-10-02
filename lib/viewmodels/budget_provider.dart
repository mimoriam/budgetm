import 'dart:async';
import 'package:flutter/material.dart';
import 'package:budgetm/models/budget.dart';
import 'package:budgetm/models/category.dart';
import 'package:budgetm/models/firestore_transaction.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BudgetProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService.instance;
  
  // Selected budget type filter
  BudgetType _selectedBudgetType = BudgetType.monthly;
  
  // Data
  List<Budget> _budgets = [];
  List<Category> _allCategories = [];
  List<Category> _expenseCategories = [];
  List<FirestoreTransaction> _allTransactions = [];
  
  // Selected category for pie chart drill-down
  String? _selectedCategoryId;
  
  // Loading state
  bool _isLoading = false;
  
  // Stream subscription for auto-refresh
  StreamSubscription<List<FirestoreTransaction>>? _transactionsSubscription;
  
  // Getters
  BudgetType get selectedBudgetType => _selectedBudgetType;
  List<Budget> get budgets => _budgets;
  List<Category> get allCategories => _allCategories;
  List<Category> get expenseCategories => _expenseCategories;
  List<FirestoreTransaction> get allTransactions => _allTransactions;
  String? get selectedCategoryId => _selectedCategoryId;
  bool get isLoading => _isLoading;
  
  // Get combined budget data (categories with their budgets and calculated spent amounts)
  List<CategoryBudgetData> get categoryBudgetData {
    // Sort categories by displayOrder
    final sortedCategories = [..._expenseCategories]..sort((a, b) {
      final aOrder = a.displayOrder ?? 0;
      final bOrder = b.displayOrder ?? 0;
      return aOrder.compareTo(bOrder);
    });

    return sortedCategories.map((category) {
      // Find budget for this category with selected type
      final budget = _budgets.firstWhere(
        (b) => b.categoryId == category.id && b.type == _selectedBudgetType,
        orElse: () => Budget(
          id: '',
          categoryId: category.id,
          limit: 0.0,
          type: _selectedBudgetType,
          year: DateTime.now().year,
          period: 0,
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          userId: '',
          spentAmount: 0.0,
        ),
      );
      
      // Calculate spent amount from transactions
      double spentAmount = 0.0;
      if (budget.id.isNotEmpty) {
        spentAmount = _calculateSpentAmount(budget);
      }
      
      return CategoryBudgetData(
        category: category,
        budget: budget.copyWith(spentAmount: spentAmount),
      );
    }).toList();
  }
  
  // Calculate spent amount for a budget
  double _calculateSpentAmount(Budget budget) {
    return _allTransactions
        .where((t) => 
            t.type == 'expense' &&
            t.categoryId == budget.categoryId &&
            t.date.isAfter(budget.startDate.subtract(const Duration(seconds: 1))) &&
            t.date.isBefore(budget.endDate.add(const Duration(seconds: 1))))
        .fold(0.0, (sum, t) => sum + t.amount);
  }
  
  // Get transactions for a specific budget
  List<FirestoreTransaction> getTransactionsForBudget(Budget budget) {
    return _allTransactions
        .where((t) => 
            t.type == 'expense' &&
            t.categoryId == budget.categoryId &&
            t.date.isAfter(budget.startDate.subtract(const Duration(seconds: 1))) &&
            t.date.isBefore(budget.endDate.add(const Duration(seconds: 1))))
        .toList();
  }
  
  // Get total spent amount for selected budget type
  double get totalSpent {
    return categoryBudgetData.fold(0.0, (sum, data) => sum + data.spentAmount);
  }
  
  // Get transactions for selected category
  List<FirestoreTransaction> get filteredTransactions {
    if (_selectedCategoryId == null) return _allTransactions;
    return _allTransactions.where((t) => t.categoryId == _selectedCategoryId).toList();
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
    
    // Subscribe to all transactions stream
    _transactionsSubscription = _firestoreService
        .streamTransactions()
        .listen((transactions) {
      _allTransactions = transactions.where((t) => t.type == 'expense').toList();
      notifyListeners();
    });
  }
  
  // Load all data
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Fetch categories
      await _fetchCategories();
      
      // Load all budgets
      _budgets = await _firestoreService.getAllBudgets();
      
      // Load all expense transactions
      final allTransactions = await _firestoreService.getAllTransactions();
      _allTransactions = allTransactions.where((t) => t.type == 'expense').toList();
      
    } catch (e) {
      print('Error loading budget data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
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
  
  // Change selected budget type
  void changeBudgetType(BudgetType type) {
    _selectedBudgetType = type;
    _selectedCategoryId = null; // Reset selection when changing type
    notifyListeners();
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

  // Add a new budget
  Future<void> addBudget(String categoryId, double limit, BudgetType type) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        print('BudgetProvider.addBudget: aborted - user not authenticated');
        throw Exception('User not authenticated');
      }
      
      print('BudgetProvider.addBudget called: category=$categoryId limit=$limit type=$type');
      final now = DateTime.now();
      int year;
      int period;
      Map<String, DateTime> dateRange;
      
      switch (type) {
        case BudgetType.weekly:
          year = now.year;
          period = Budget.getWeekNumber(now);
          dateRange = Budget.getDateRange(type, year, period);
          break;
        case BudgetType.monthly:
          year = now.year;
          period = now.month;
          dateRange = Budget.getDateRange(type, year, period);
          break;
        case BudgetType.yearly:
          year = now.year;
          period = year;
          dateRange = Budget.getDateRange(type, year, period);
          break;
      }
      
      final budgetId = Budget.generateId(userId, categoryId, type, year, period);
      print('BudgetProvider.addBudget: generated budgetId=$budgetId');
      
      // Check for duplicate budget
      final existingBudget = _budgets.firstWhere(
        (b) => b.categoryId == categoryId &&
               b.type == type &&
               b.year == year &&
               b.period == period,
        orElse: () => Budget(
          id: '',
          categoryId: '',
          limit: 0.0,
          type: type,
          year: 0,
          period: 0,
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          userId: '',
        ),
      );
      
      if (existingBudget.id.isNotEmpty) {
        print('BudgetProvider.addBudget: duplicate budget found for category=$categoryId, type=$type, year=$year, period=$period');
        throw Exception('A budget for this category already exists for this period.');
      }
      
      final newBudget = Budget(
        id: budgetId,
        categoryId: categoryId,
        limit: limit,
        type: type,
        year: year,
        period: period,
        startDate: dateRange['startDate']!,
        endDate: dateRange['endDate']!,
        userId: userId,
      );
      
      print('BudgetProvider.addBudget: calling FirestoreService.addBudget with ${newBudget.toString()}');
      await _firestoreService.addBudget(newBudget);
      print('BudgetProvider.addBudget: FirestoreService.addBudget completed for id=$budgetId');
      await loadData();
      print('BudgetProvider.addBudget: loadData completed, budgets count=${_budgets.length}');
    } catch (e) {
      print('Error adding budget: $e');
      rethrow;
    }
  }
  
  // Update budget limit
  Future<void> updateBudgetLimit(String budgetId, double limit) async {
    try {
      final budget = _budgets.firstWhere((b) => b.id == budgetId);
      final updated = budget.copyWith(limit: limit);
      await _firestoreService.updateBudget(budgetId, updated);
      await loadData();
    } catch (e) {
      print('Error updating budget limit: $e');
      rethrow;
    }
  }
  
  // Delete a budget
  Future<void> deleteBudget(String budgetId) async {
    try {
      await _firestoreService.deleteBudget(budgetId);
      await loadData();
    } catch (e) {
      print('Error deleting budget: $e');
      rethrow;
    }
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
  String get categoryColor => category.color ?? 'grey';
  double get spentAmount => budget.spentAmount;
  double get limit => budget.limit;
}