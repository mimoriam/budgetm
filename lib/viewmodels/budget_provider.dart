import 'dart:async';
import 'package:flutter/material.dart';
import 'package:budgetm/models/budget.dart';
import 'package:budgetm/models/category.dart';
import 'package:budgetm/models/firestore_transaction.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/viewmodels/currency_provider.dart';
import 'package:budgetm/viewmodels/vacation_mode_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BudgetProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService.instance;
  final CurrencyProvider _currencyProvider;
  final VacationProvider _vacationProvider;
  
  // Selected budget type filter
  BudgetType _selectedBudgetType = BudgetType.monthly;
  
  // Selected time period filters
  int _selectedWeek = 1; // Week 1-5 of selected weekly month
  DateTime _selectedWeeklyMonth = DateTime.now(); // Track which month for weekly view
  DateTime _selectedMonth = DateTime.now();
  DateTime _selectedYear = DateTime.now();
  
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
  
  // Constructor
  BudgetProvider({
    required CurrencyProvider currencyProvider,
    required VacationProvider vacationProvider,
  })  : _currencyProvider = currencyProvider,
        _vacationProvider = vacationProvider {
    _vacationProvider.addListener(_onVacationModeChanged);
  }
  
  // Getters
  BudgetType get selectedBudgetType => _selectedBudgetType;
  int get selectedWeek => _selectedWeek;
  DateTime get selectedWeeklyMonth => _selectedWeeklyMonth;
  DateTime get selectedMonth => _selectedMonth;
  DateTime get selectedYear => _selectedYear;
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
      // Find budget for this category with selected type and period
      Budget? matchingBudget;
      
      switch (_selectedBudgetType) {
        case BudgetType.weekly:
          // Find budgets that fall within the selected week of the current month
          matchingBudget = _budgets.firstWhere(
            (b) => b.categoryId == category.id &&
                   b.type == _selectedBudgetType &&
                   _isWeekInSelectedPeriod(b),
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
              currency: _currencyProvider.selectedCurrencyCode, // New required field
              spentAmount: 0.0,
            ),
          );
          break;
          
        case BudgetType.monthly:
          // Find budget for the selected month
          matchingBudget = _budgets.firstWhere(
            (b) => b.categoryId == category.id &&
                   b.type == _selectedBudgetType &&
                   b.year == _selectedMonth.year &&
                   b.period == _selectedMonth.month,
            orElse: () => Budget(
              id: '',
              categoryId: category.id,
              limit: 0.0,
              type: _selectedBudgetType,
              year: _selectedMonth.year,
              period: _selectedMonth.month,
              startDate: DateTime(_selectedMonth.year, _selectedMonth.month, 1),
              endDate: DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59),
              userId: '',
              currency: _currencyProvider.selectedCurrencyCode, // New required field
              spentAmount: 0.0,
            ),
          );
          break;
          
        case BudgetType.yearly:
          // Find budget for the selected year
          matchingBudget = _budgets.firstWhere(
            (b) => b.categoryId == category.id &&
                   b.type == _selectedBudgetType &&
                   b.year == _selectedYear.year,
            orElse: () => Budget(
              id: '',
              categoryId: category.id,
              limit: 0.0,
              type: _selectedBudgetType,
              year: _selectedYear.year,
              period: _selectedYear.year,
              startDate: DateTime(_selectedYear.year, 1, 1),
              endDate: DateTime(_selectedYear.year, 12, 31, 23, 59, 59),
              userId: '',
              currency: _currencyProvider.selectedCurrencyCode, // New required field
              spentAmount: 0.0,
            ),
          );
          break;
      }
      
      // Calculate spent amount from transactions
      double spentAmount = 0.0;
      if (matchingBudget.id.isNotEmpty) {
        spentAmount = _calculateSpentAmount(matchingBudget);
      }
      
      return CategoryBudgetData(
        category: category,
        budget: matchingBudget.copyWith(spentAmount: spentAmount),
      );
    }).toList();
  }
  
  // Helper method to check if a weekly budget falls within the selected week period
  bool _isWeekInSelectedPeriod(Budget budget) {
    // Use provider's selectedWeeklyMonth instead of DateTime.now()
    final currentYear = _selectedWeeklyMonth.year;
    final currentMonth = _selectedWeeklyMonth.month;
    
    print('DEBUG _isWeekInSelectedPeriod: budget.id=${budget.id}, budget.period=${budget.period}, _selectedWeek=$_selectedWeek, selectedWeeklyMonth=$_selectedWeeklyMonth');
    
    // Calculate the date range for the selected week of the selected month
    final firstDayOfMonth = DateTime(currentYear, currentMonth, 1);
    
    // Find the first Sunday of the month
    final firstSunday = Budget.getStartOfWeek(firstDayOfMonth);
    
    // Calculate start and end of the selected week
    final weekStartDate = firstSunday.add(Duration(days: (_selectedWeek - 1) * 7));
    final weekEndDate = weekStartDate.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    
    print('DEBUG _isWeekInSelectedPeriod: weekStartDate=$weekStartDate, weekEndDate=$weekEndDate, budget.startDate=${budget.startDate}, budget.endDate=${budget.endDate}');
    
    // Check if the budget's date range overlaps with the selected week
    final overlaps = !(budget.endDate.isBefore(weekStartDate) || budget.startDate.isAfter(weekEndDate));
    print('DEBUG _isWeekInSelectedPeriod: overlaps=$overlaps');
    return overlaps;
  }
  
  // Calculate spent amount for a budget
  double _calculateSpentAmount(Budget budget) {
    return _allTransactions
        .where((t) =>
            t.type == 'expense' &&
            t.categoryId == budget.categoryId &&
            t.date.isAfter(budget.startDate.subtract(const Duration(seconds: 1))) &&
            t.date.isBefore(budget.endDate.add(const Duration(seconds: 1))) &&
            t.isVacation == budget.isVacation) // Match vacation status
        .fold(0.0, (sum, t) => sum + t.amount);
  }
  
  // Get transactions for a specific budget
  List<FirestoreTransaction> getTransactionsForBudget(Budget budget) {
    return _allTransactions
        .where((t) =>
            t.type == 'expense' &&
            t.categoryId == budget.categoryId &&
            t.date.isAfter(budget.startDate.subtract(const Duration(seconds: 1))) &&
            t.date.isBefore(budget.endDate.add(const Duration(seconds: 1))) &&
            t.isVacation == budget.isVacation) // Match vacation status
        .toList();
  }
  
  // Get total spent amount for selected budget type
  double get totalSpent {
    return categoryBudgetData.fold(0.0, (sum, data) => sum + data.spentAmount);
  }
  
  // Get formatted display text for current period
  String get currentPeriodDisplay {
    switch (_selectedBudgetType) {
      case BudgetType.weekly:
        // Calculate start and end dates for the selected week of the selected weekly month
        final currentYear = _selectedWeeklyMonth.year;
        final currentMonth = _selectedWeeklyMonth.month;
        final firstDayOfMonth = DateTime(currentYear, currentMonth, 1);
        final firstSunday = Budget.getStartOfWeek(firstDayOfMonth);
        final weekStartDate = firstSunday.add(Duration(days: (_selectedWeek - 1) * 7));
        final weekEndDate = weekStartDate.add(const Duration(days: 6));
        // Short month names for compact display
        const shortMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        String display;
        if (weekStartDate.month == weekEndDate.month && weekStartDate.year == weekEndDate.year) {
          display = '${shortMonths[weekStartDate.month - 1]} ${weekStartDate.day}-${weekEndDate.day}, ${weekEndDate.year}';
        } else if (weekStartDate.year == weekEndDate.year) {
          // Different months but same year: "Sep 29-Oct 5, 2025"
          display = '${shortMonths[weekStartDate.month - 1]} ${weekStartDate.day}-${shortMonths[weekEndDate.month - 1]} ${weekEndDate.day}, ${weekEndDate.year}';
        } else {
          // Different years: "Dec 29, 2024-Jan 4, 2025"
          display = '${shortMonths[weekStartDate.month - 1]} ${weekStartDate.day}, ${weekStartDate.year}-${shortMonths[weekEndDate.month - 1]} ${weekEndDate.day}, ${weekEndDate.year}';
        }
        print('DEBUG currentPeriodDisplay (weekly): selectedWeek=$_selectedWeek, selectedWeeklyMonth=$_selectedWeeklyMonth, weekStartDate=$weekStartDate, weekEndDate=$weekEndDate, display=$display');
        return display;
      case BudgetType.monthly:
        return _formatMonth(_selectedMonth);
      case BudgetType.yearly:
        return '${_selectedYear.year}';
    }
  }
  
  String _formatMonth(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
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
      
      // Load budgets based on current vacation mode
      _budgets = await _firestoreService.getAllBudgets(isVacation: _vacationProvider.isVacationMode);
      
      // Load all expense transactions based on current vacation mode
      final allTransactions = await _firestoreService.getAllTransactions(isVacation: _vacationProvider.isVacationMode);
      _allTransactions = allTransactions.where((t) => t.type == 'expense').toList();
      
    } catch (e) {
      print('Error loading budget data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Listener for vacation mode changes
  void _onVacationModeChanged() {
    loadData();
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
    
    // Initialize the appropriate selector based on type
    if (type == BudgetType.weekly) {
      // Calculate current week of the month
      final now = DateTime.now();
      _selectedWeeklyMonth = DateTime(now.year, now.month);
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final firstSunday = Budget.getStartOfWeek(firstDayOfMonth);
      final currentWeekStart = Budget.getStartOfWeek(now);
      final weeksDiff = currentWeekStart.difference(firstSunday).inDays ~/ 7;
      // Allow up to 5 weeks per month (some months span 5 weeks)
      _selectedWeek = (weeksDiff + 1).clamp(1, 5);
    } else if (type == BudgetType.monthly) {
      _selectedMonth = DateTime.now();
    } else if (type == BudgetType.yearly) {
      _selectedYear = DateTime.now();
    }
    
    notifyListeners();
  }
  
  // Change selected week (1-4)
  void changeSelectedWeek(int week) {
    if (week < 1 || week > 5) return;
    _selectedWeek = week;
    _selectedCategoryId = null;
    notifyListeners();
  }
  
  // Change selected month
  void changeSelectedMonth(DateTime month) {
    _selectedMonth = month;
    _selectedCategoryId = null;
    notifyListeners();
  }
  
  // Change selected year
  void changeSelectedYear(DateTime year) {
    _selectedYear = year;
    _selectedCategoryId = null;
    notifyListeners();
  }
  
  // Navigation methods for weekly budget
  void goToNextWeek() {
    // Use provider's selectedWeeklyMonth instead of DateTime.now()
    final weeksInMonth = _getWeeksInMonth(_selectedWeeklyMonth);
    
    print('DEBUG goToNextWeek: before - selectedWeek=$_selectedWeek, weeksInMonth=$weeksInMonth, selectedWeeklyMonth=$_selectedWeeklyMonth');
    
    if (_selectedWeek < weeksInMonth) {
      _selectedWeek++;
    } else {
      // Move to next month
      _selectedWeeklyMonth = DateTime(_selectedWeeklyMonth.year, _selectedWeeklyMonth.month + 1);
      _selectedWeek = 1;
      print('DEBUG goToNextWeek: moving to next month=$_selectedWeeklyMonth, resetting to week 1');
    }
    print('DEBUG goToNextWeek: after - selectedWeek=$_selectedWeek, selectedWeeklyMonth=$_selectedWeeklyMonth');
    _selectedCategoryId = null;
    notifyListeners();
  }
  
  void goToPreviousWeek() {
    print('DEBUG goToPreviousWeek: before - selectedWeek=$_selectedWeek, selectedWeeklyMonth=$_selectedWeeklyMonth');
    
    if (_selectedWeek > 1) {
      _selectedWeek--;
    } else {
      // Move to previous month
      _selectedWeeklyMonth = DateTime(_selectedWeeklyMonth.year, _selectedWeeklyMonth.month - 1);
      _selectedWeek = _getWeeksInMonth(_selectedWeeklyMonth);
      print('DEBUG goToPreviousWeek: moving to previous month=$_selectedWeeklyMonth, week=$_selectedWeek');
    }
    print('DEBUG goToPreviousWeek: after - selectedWeek=$_selectedWeek, selectedWeeklyMonth=$_selectedWeeklyMonth');
    _selectedCategoryId = null;
    notifyListeners();
  }
  
  // Navigation methods for monthly budget
  void goToNextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    _selectedCategoryId = null;
    notifyListeners();
  }
  
  void goToPreviousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    _selectedCategoryId = null;
    notifyListeners();
  }
  
  // Navigation methods for yearly budget
  void goToNextYear() {
    _selectedYear = DateTime(_selectedYear.year + 1);
    _selectedCategoryId = null;
    notifyListeners();
  }
  
  void goToPreviousYear() {
    _selectedYear = DateTime(_selectedYear.year - 1);
    _selectedCategoryId = null;
    notifyListeners();
  }
  
  // Set selected date (for quick jump functionality)
  void setSelectedDate(DateTime date) {
    switch (_selectedBudgetType) {
      case BudgetType.weekly:
        // Calculate week of month for the selected date and update the month
        _selectedWeeklyMonth = DateTime(date.year, date.month);
        _selectedWeek = Budget.getWeekOfMonth(date);
        print('DEBUG setSelectedDate (weekly): date=$date, selectedWeeklyMonth=$_selectedWeeklyMonth, selectedWeek=$_selectedWeek');
        break;
      case BudgetType.monthly:
        _selectedMonth = date;
        break;
      case BudgetType.yearly:
        _selectedYear = date;
        break;
    }
    _selectedCategoryId = null;
    notifyListeners();
  }
  
  // Helper method to calculate number of weeks in a month
  int _getWeeksInMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final firstSunday = Budget.getStartOfWeek(firstDayOfMonth);
    final lastSunday = Budget.getStartOfWeek(lastDayOfMonth);
    final weeksDiff = lastSunday.difference(firstSunday).inDays ~/ 7;
    return (weeksDiff + 1).clamp(1, 5);
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
  Future<void> addBudget(String categoryId, double limit, BudgetType type, {bool isVacation = false}) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        print('BudgetProvider.addBudget: aborted - user not authenticated');
        throw Exception('User not authenticated');
      }
      
      print('BudgetProvider.addBudget called: category=$categoryId limit=$limit type=$type isVacation=$isVacation');
      final now = DateTime.now();
      int year;
      int period;
      Map<String, DateTime> dateRange;
      
      switch (type) {
        case BudgetType.weekly:
          year = now.year;
          // Encode weekly period as (month * 10 + weekOfMonth) so weeks are scoped to a month
          final weekOfMonth = Budget.getWeekOfMonth(now);
          period = now.month * 10 + weekOfMonth;
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
      
      final budgetId = Budget.generateId(userId, categoryId, type, year, period, isVacation);
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
          currency: _currencyProvider.selectedCurrencyCode, // New required field
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
        currency: _currencyProvider.selectedCurrencyCode,
        isVacation: isVacation, // New field
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
  Future<void> deleteBudget(String budgetId, {bool cascadeDelete = false}) async {
    try {
      await _firestoreService.deleteBudget(budgetId, cascadeDelete: cascadeDelete);
      await loadData();
    } catch (e) {
      print('Error deleting budget: $e');
      rethrow;
    }
  }
  
  @override
  void dispose() {
    _transactionsSubscription?.cancel();
    _vacationProvider.removeListener(_onVacationModeChanged);
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