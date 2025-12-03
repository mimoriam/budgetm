import 'dart:async';
import 'package:flutter/material.dart';
import 'package:budgetm/models/revamped_budget.dart';
import 'package:budgetm/models/budget.dart';
import 'package:budgetm/models/category.dart';
import 'package:budgetm/models/firestore_transaction.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/viewmodels/currency_provider.dart';
import 'package:budgetm/viewmodels/home_screen_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RevampedBudgetProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService.instance;
  final CurrencyProvider _currencyProvider;
  final HomeScreenProvider _homeScreenProvider;
  
  // Selected budget type filter
  BudgetType _selectedBudgetType = BudgetType.monthly;
  
  // Selected time period filters
  int _selectedWeek = 1; // Week 1-5 of selected weekly month
  DateTime _selectedWeeklyMonth = DateTime.now(); // Track which month for weekly view
  DateTime _selectedMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now(); // Track selected day for daily view
  DateTime _selectedDailyWeek = DateTime.now(); // Track which week to show days for
  
  // Data
  List<RevampedBudget> _revampedBudgets = [];
  List<Category> _allCategories = [];
  List<Category> _expenseCategories = [];
  List<FirestoreTransaction> _allTransactions = [];
  
  // Selected category for pie chart drill-down (not used in revamped, but kept for compatibility)
  String? _selectedCategoryId;
  
  // Loading state
  bool _isLoading = false;
  
  // Stream subscription for auto-refresh
  StreamSubscription<List<FirestoreTransaction>>? _transactionsSubscription;
  
  // Constructor
  RevampedBudgetProvider({
    required CurrencyProvider currencyProvider,
    required HomeScreenProvider homeScreenProvider,
  })  : _currencyProvider = currencyProvider,
        _homeScreenProvider = homeScreenProvider {
    _homeScreenProvider.addListener(_onHomeScreenProviderChanged);
    _currencyProvider.addListener(_onCurrencyChanged);
  }
  
  // Getters
  BudgetType get selectedBudgetType => _selectedBudgetType;
  int get selectedWeek => _selectedWeek;
  DateTime get selectedWeeklyMonth => _selectedWeeklyMonth;
  DateTime get selectedMonth => _selectedMonth;
  DateTime get selectedDay => _selectedDay;
  DateTime get selectedDailyWeek => _selectedDailyWeek;
  List<RevampedBudget> get revampedBudgets => _revampedBudgets;
  List<Category> get allCategories => _allCategories;
  List<Category> get expenseCategories => _expenseCategories;
  List<FirestoreTransaction> get allTransactions => _allTransactions;
  String? get selectedCategoryId => _selectedCategoryId;
  bool get isLoading => _isLoading;
  
  // Get combined revamped budget data
  List<RevampedCategoryBudgetData> get revampedCategoryBudgetData {
    return _getRevampedBudgetData();
  }
  
  // Get revamped budget data filtered by selected period and type
  // Budgets appear as "recurring" - show all budgets of matching type regardless of original period
  // Transactions are filtered by the selected period date range
  List<RevampedCategoryBudgetData> _getRevampedBudgetData() {
    // Get date range for selected period (used for transaction filtering)
    final periodRange = _getSelectedPeriodRange();
    final startDate = periodRange['start'];
    final endDate = periodRange['end'];
    
    if (startDate == null || endDate == null) {
      return [];
    }
    
    // Filter revamped budgets by type only (recurring UI behavior)
    // Show ALL budgets of matching type, regardless of original period/year
    // This makes budgets appear as recurring - a November monthly budget shows in December too
    final filteredBudgets = _revampedBudgets.where((budget) {
      // Must match budget type
      return budget.type == _selectedBudgetType;
      // No period/year filtering - budgets appear for all periods of the same type
    }).toList();
    
    // Create budget data for each revamped budget
    final budgetDataList = <RevampedCategoryBudgetData>[];
    
    for (final budget in filteredBudgets) {
      // Calculate spent amount for this budget
      final spentAmount = _calculateSpentAmountForRevampedBudget(budget);
      
      // Get category names
      final categoryNames = budget.categoryIds.map((categoryId) {
        final category = _expenseCategories.firstWhere(
          (c) => c.id == categoryId,
          orElse: () => Category(id: '', name: 'Unknown', icon: '', color: '', displayOrder: 999),
        );
        return category.name ?? 'Unknown';
      }).toList();
      
      // Get first category for display (icon, color)
      final firstCategory = _expenseCategories.firstWhere(
        (c) => c.id == budget.categoryIds.first,
        orElse: () => Category(id: '', name: 'Unknown', icon: 'category', color: 'grey', displayOrder: 999),
      );
      
      budgetDataList.add(RevampedCategoryBudgetData(
        categoryIds: budget.categoryIds,
        categoryNames: categoryNames,
        revampedBudget: budget.copyWith(spentAmount: spentAmount),
        spentAmount: spentAmount,
        limit: budget.limit,
        firstCategory: firstCategory,
        budgetName: budget.name,
      ));
    }
    
    // Sort by first category display order
    budgetDataList.sort((a, b) {
      return a.firstCategory.displayOrder.compareTo(b.firstCategory.displayOrder);
    });
    
    return budgetDataList;
  }
  
  // Calculate spent amount for a revamped budget
  // CRITICAL: Uses SELECTED period date range, not budget's original period
  // This allows filtering transactions by the currently selected month/week/day
  double _calculateSpentAmountForRevampedBudget(RevampedBudget budget) {
    // Get selected period date range (not budget's date range)
    final periodRange = _getSelectedPeriodRange();
    final startDate = periodRange['start'];
    final endDate = periodRange['end'];
    
    if (startDate == null || endDate == null) {
      return 0.0;
    }
    
    // Filter transactions by selected period date range
    final transactions = _allTransactions.where((t) {
      return t.type == 'expense' &&
             t.isVacation == false &&
             budget.categoryIds.contains(t.categoryId) &&
             t.currency == budget.currency &&
             t.currency == budget.currency &&
             !t.date.isBefore(startDate) &&
             !t.date.isAfter(endDate);
    }).toList();
    
    return transactions.fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  // Get transactions for a revamped budget
  // CRITICAL: Uses SELECTED period date range, not budget's original period
  // This allows filtering transactions by the currently selected month/week/day
  List<FirestoreTransaction> getTransactionsForBudget(RevampedBudget budget) {
    // Get selected period date range (not budget's date range)
    final periodRange = _getSelectedPeriodRange();
    final startDate = periodRange['start'];
    final endDate = periodRange['end'];

    if (startDate == null || endDate == null) {
      return [];
    }

    // Filter transactions by selected period date range
    return _allTransactions.where((t) {
      return t.type == 'expense' &&
             t.isVacation == false &&
             budget.categoryIds.contains(t.categoryId) &&
             t.currency == budget.currency &&
             !t.date.isBefore(startDate) &&
             !t.date.isAfter(endDate);
    }).toList();
  }
  
  // Get current period display text
  String get currentPeriodDisplay {
    switch (_selectedBudgetType) {
      case BudgetType.weekly:
        final firstDayOfMonth = DateTime(_selectedWeeklyMonth.year, _selectedWeeklyMonth.month, 1);
        final firstSunday = Budget.getStartOfWeek(firstDayOfMonth);
        final weekStartDate = firstSunday.add(Duration(days: (_selectedWeek - 1) * 7));
        final weekEndDate = weekStartDate.add(const Duration(days: 6));
        return '${_formatDate(weekStartDate)} - ${_formatDate(weekEndDate)}';
      case BudgetType.monthly:
        return '${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}';
      case BudgetType.daily:
        return _formatDate(_selectedDay);
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
  
  // Get selected period range
  // Handles edge cases: year boundaries, invalid months, week calculations spanning months
  Map<String, DateTime?> _getSelectedPeriodRange() {
    try {
      switch (_selectedBudgetType) {
        case BudgetType.weekly:
          final currentYear = _selectedWeeklyMonth.year;
          final currentMonth = _selectedWeeklyMonth.month;
          
          // Validate month (1-12)
          if (currentMonth < 1 || currentMonth > 12) {
            print('Invalid month in weekly period: $currentMonth');
            return {'start': null, 'end': null};
          }
          
          // Validate week (1-5)
          if (_selectedWeek < 1 || _selectedWeek > 5) {
            print('Invalid week in weekly period: ${_selectedWeek}');
            return {'start': null, 'end': null};
          }
          
          final firstDayOfMonth = DateTime(currentYear, currentMonth, 1);
          final firstSunday = Budget.getStartOfWeek(firstDayOfMonth);
          final weekStartDate = firstSunday.add(Duration(days: (_selectedWeek - 1) * 7));
          // Week can span into next month - this is handled correctly by DateTime
          final weekEndDate = weekStartDate.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
          return {'start': weekStartDate, 'end': weekEndDate};
          
        case BudgetType.monthly:
          // Validate month (1-12) - DateTime handles month+1=13 as January of next year
          if (_selectedMonth.month < 1 || _selectedMonth.month > 12) {
            print('Invalid month in monthly period: ${_selectedMonth.month}');
            return {'start': null, 'end': null};
          }
          
          final start = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
          // DateTime(year, month+1, 0) correctly gets last day of month, even for December (year boundary)
          final end = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);
          return {'start': start, 'end': end};
          
        case BudgetType.daily:
          // Validate month and day
          if (_selectedDay.month < 1 || _selectedDay.month > 12) {
            print('Invalid month in daily period: ${_selectedDay.month}');
            return {'start': null, 'end': null};
          }
          
          // DateTime constructor will throw if day is invalid (e.g., Feb 30), caught by try-catch
          final start = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
          final end = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 23, 59, 59);
          return {'start': start, 'end': end};
      }
    } catch (e) {
      print('Error computing selected period range: $e');
    }
    return {'start': null, 'end': null};
  }
  
  // Public getters to expose the currently-selected period's start and end
  DateTime? get selectedPeriodStart => _getSelectedPeriodRange()['start'];
  DateTime? get selectedPeriodEnd => _getSelectedPeriodRange()['end'];
  
  // Initialize and load data
  Future<void> initialize() async {
    print('DEBUG RevampedBudgetProvider.initialize: start');
    await loadData();
    print('DEBUG RevampedBudgetProvider.initialize: loadData completed, setting up transactions listener');
    _setupTransactionsListener();
    print('DEBUG RevampedBudgetProvider.initialize: listener setup complete');
  }
  
  // Set up listener for transactions stream
  void _setupTransactionsListener() {
    // Cancel existing subscription if any
    _transactionsSubscription?.cancel();
    // Subscribe to transactions stream for normal mode only (isVacation = false)
    _transactionsSubscription = _firestoreService
        .streamTransactions(
          vacationAccountId: null,
          isVacation: false,
        )
        .listen((transactions) {
      try {
        final filtered = transactions.where((t) =>
          t.type == 'expense' && t.isVacation == false
        ).toList();
        print('DEBUG RevampedBudgetProvider.stream: received ${transactions.length} tx, filtered ${filtered.length}');
        _allTransactions = filtered;
        notifyListeners();
      } catch (e) {
        print('Error processing transactions stream: $e');
      }
    }, onError: (err) {
      print('Transactions stream error: $err');
    });
  }
  
  // Load all data
  Future<void> loadData() async {
    print('DEBUG RevampedBudgetProvider.loadData: start');
    _isLoading = true;
    notifyListeners();
    
    try {
      // Fetch categories
      print('DEBUG RevampedBudgetProvider.loadData: fetching categories');
      await _fetchCategories();
      print('DEBUG RevampedBudgetProvider.loadData: fetched ${_allCategories.length} categories, expenseCategories=${_expenseCategories.length}');
      
      // Load revamped budgets
      print('DEBUG RevampedBudgetProvider.loadData: fetching revamped budgets');
      _revampedBudgets = await _firestoreService.getAllRevampedBudgets();
      print('DEBUG RevampedBudgetProvider.loadData: fetched ${_revampedBudgets.length} revamped budgets');
      
      // Load all expense transactions (normal mode only)
      print('DEBUG RevampedBudgetProvider.loadData: fetching transactions (normal mode)');
      final allTransactions = await _firestoreService.getAllTransactions(
        isVacation: false,
        vacationAccountId: null,
      );
      _allTransactions = allTransactions.where((t) => t.type == 'expense').toList();
      print('DEBUG RevampedBudgetProvider.loadData: fetched ${_allTransactions.length} expense transactions');
      
    } catch (e) {
      print('Error loading revamped budget data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      print('DEBUG RevampedBudgetProvider.loadData: completed');
    }
  }
  
  // Listener for currency changes
  void _onCurrencyChanged() {
    print('DEBUG RevampedBudgetProvider: Currency changed, reloading data');
    loadData();
  }
  
  // Listener for HomeScreenProvider changes
  void _onHomeScreenProviderChanged() {
    if (_homeScreenProvider.shouldRefreshTransactions || _homeScreenProvider.shouldRefresh) {
      print('DEBUG: RevampedBudgetProvider detected refresh trigger, reloading data');
      loadData();
      _homeScreenProvider.completeRefresh();
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
    
    // Initialize the appropriate selector based on type
    if (type == BudgetType.weekly) {
      final now = DateTime.now();
      _selectedWeeklyMonth = DateTime(now.year, now.month);
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final firstSunday = Budget.getStartOfWeek(firstDayOfMonth);
      final currentWeekStart = Budget.getStartOfWeek(now);
      final weeksDiff = currentWeekStart.difference(firstSunday).inDays ~/ 7;
      _selectedWeek = (weeksDiff + 1).clamp(1, 5);
    } else if (type == BudgetType.monthly) {
      _selectedMonth = DateTime.now();
    } else if (type == BudgetType.daily) {
      _selectedDay = DateTime.now();
    }
    
    notifyListeners();
  }
  
  // Change selected week (1-5)
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
  
  // Change selected day
  void changeSelectedDay(DateTime day) {
    _selectedDay = day;
    _selectedCategoryId = null;
    notifyListeners();
  }
  
  // Navigation methods for weekly budget
  void goToNextWeek() {
    final weeksInMonth = _getWeeksInMonth(_selectedWeeklyMonth);
    
    if (_selectedWeek < weeksInMonth) {
      _selectedWeek++;
    } else {
      _selectedWeeklyMonth = DateTime(_selectedWeeklyMonth.year, _selectedWeeklyMonth.month + 1);
      _selectedWeek = 1;
    }
    _selectedCategoryId = null;
    notifyListeners();
  }
  
  void goToPreviousWeek() {
    if (_selectedWeek > 1) {
      _selectedWeek--;
    } else {
      _selectedWeeklyMonth = DateTime(_selectedWeeklyMonth.year, _selectedWeeklyMonth.month - 1);
      _selectedWeek = _getWeeksInMonth(_selectedWeeklyMonth);
    }
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
  
  // Navigation methods for daily budget
  void goToNextDay() {
    _selectedDay = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day + 1);
    _selectedCategoryId = null;
    notifyListeners();
  }
  
  void goToPreviousDay() {
    _selectedDay = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day - 1);
    _selectedCategoryId = null;
    notifyListeners();
  }
  
  void goToNextDailyWeek() {
    _selectedDailyWeek = DateTime(_selectedDailyWeek.year, _selectedDailyWeek.month, _selectedDailyWeek.day + 7);
    _selectedCategoryId = null;
    notifyListeners();
  }
  
  void goToPreviousDailyWeek() {
    _selectedDailyWeek = DateTime(_selectedDailyWeek.year, _selectedDailyWeek.month, _selectedDailyWeek.day - 7);
    _selectedCategoryId = null;
    notifyListeners();
  }
  
  // Set selected date (for quick jump functionality)
  void setSelectedDate(DateTime date) {
    switch (_selectedBudgetType) {
      case BudgetType.weekly:
        _selectedWeeklyMonth = DateTime(date.year, date.month);
        _selectedWeek = Budget.getWeekOfMonth(date);
        break;
      case BudgetType.monthly:
        _selectedMonth = date;
        break;
      case BudgetType.daily:
        _selectedDay = date;
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
  
  // Select category for pie chart drill-down (not used in revamped, but kept for compatibility)
  void selectCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }
  
  // Clear category selection
  void clearCategorySelection() {
    _selectedCategoryId = null;
    notifyListeners();
  }

  // Check if a duplicate budget already exists (public method for UI validation)
  // Duplicates are defined as: same category combination, same type, same currency
  // Since budgets are recurring, we don't check period/year
  bool hasDuplicateBudget(List<String> categoryIds, BudgetType type, String currency) {
    return _hasDuplicateBudget(categoryIds, type, currency);
  }
  
  // Check if a duplicate budget already exists (private implementation)
  // Duplicates are defined as: same category combination, same type, same currency
  // Since budgets are recurring, we don't check period/year
  bool _hasDuplicateBudget(List<String> categoryIds, BudgetType type, String currency) {
    // Handle edge cases: empty or null category lists
    if (categoryIds.isEmpty) {
      return false; // Empty lists are already validated elsewhere
    }
    
    // Filter out any null or empty category IDs
    final validCategoryIds = categoryIds.where((id) => id.isNotEmpty).toList();
    if (validCategoryIds.isEmpty) {
      return false;
    }
    
    // Sort category IDs for comparison (matching ID generation logic)
    final sortedNewCategories = List<String>.from(validCategoryIds)..sort();
    
    // Check all existing budgets
    for (final budget in _revampedBudgets) {
      // Must match type and currency exactly
      if (budget.type != type || budget.currency != currency) {
        continue;
      }
      
      // Filter out null/empty category IDs from existing budget
      final validExistingCategories = budget.categoryIds.where((id) => id.isNotEmpty).toList();
      if (validExistingCategories.isEmpty) {
        continue;
      }
      
      // Sort and compare category sets
      final sortedExistingCategories = List<String>.from(validExistingCategories)..sort();
      
      // Check if category sets match exactly (same length and all items match)
      if (sortedNewCategories.length == sortedExistingCategories.length &&
          sortedNewCategories.length > 0 &&
          sortedNewCategories.every((id) => sortedExistingCategories.contains(id)) &&
          sortedExistingCategories.every((id) => sortedNewCategories.contains(id))) {
        return true; // Duplicate found
      }
    }
    
    return false; // No duplicate found
  }
  
  // Get category names for error messages
  String _getCategoryNamesString(List<String> categoryIds) {
    final names = categoryIds.map((categoryId) {
      final category = _expenseCategories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => Category(id: '', name: 'Unknown', icon: '', color: '', displayOrder: 999),
      );
      return category.name ?? 'Unknown';
    }).toList();
    return names.join(', ');
  }

  // Add a new revamped budget
  Future<void> addRevampedBudget(
    List<String> categoryIds,
    double limit,
    BudgetType type,
    DateTime dateTime,
    String currency, {
    String? name,
  }) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        print('RevampedBudgetProvider.addRevampedBudget: aborted - user not authenticated');
        throw Exception('User not authenticated');
      }
      
      if (categoryIds.isEmpty) {
        throw Exception('At least one category must be selected');
      }
      
      // Check for duplicate budget (same category combination, type, and currency)
      if (_hasDuplicateBudget(categoryIds, type, currency)) {
        final categoryNames = _getCategoryNamesString(categoryIds);
        final typeName = type.toString().split('.').last;
        throw Exception('A $typeName budget for $categoryNames already exists');
      }
      
      print('RevampedBudgetProvider.addRevampedBudget called: categoryIds=$categoryIds limit=$limit type=$type dateTime=$dateTime currency=$currency');
      
      int year;
      int period;
      
      switch (type) {
        case BudgetType.weekly:
          year = dateTime.year;
          final weekOfMonth = Budget.getWeekOfMonth(dateTime);
          period = dateTime.month * 10 + weekOfMonth;
          break;
        case BudgetType.monthly:
          year = dateTime.year;
          period = dateTime.month;
          break;
        case BudgetType.daily:
          year = dateTime.year;
          period = dateTime.month * 100 + dateTime.day;
          break;
      }
      
      final budgetId = RevampedBudget.generateId(
        userId,
        categoryIds,
        type,
        year,
        period,
        currency: currency,
      );
      
      final revampedBudget = RevampedBudget(
        id: budgetId,
        categoryIds: categoryIds,
        limit: limit,
        type: type,
        year: year,
        period: period,
        dateTime: dateTime,
        userId: userId,
        currency: currency,
        spentAmount: 0.0,
        name: name,
      );
      
      await _firestoreService.addRevampedBudget(revampedBudget);
      print('RevampedBudgetProvider.addRevampedBudget: successfully added revamped budget id=$budgetId');
      
      await loadData();
      print('RevampedBudgetProvider.addRevampedBudget: loadData completed, revamped budgets count=${_revampedBudgets.length}');
    } catch (e) {
      print('Error adding revamped budget: $e');
      rethrow;
    }
  }
  
  // Update revamped budget limit
  Future<void> updateRevampedBudgetLimit(String id, double limit) async {
    try {
      final budget = _revampedBudgets.firstWhere((b) => b.id == id);
      final updated = budget.copyWith(limit: limit);
      await _firestoreService.updateRevampedBudget(id, updated);
      await loadData();
    } catch (e) {
      print('Error updating revamped budget limit: $e');
      rethrow;
    }
  }
  
  // Delete a revamped budget
  Future<void> deleteRevampedBudget(String id) async {
    try {
      await _firestoreService.deleteRevampedBudget(id);
      await loadData();
    } catch (e) {
      print('Error deleting revamped budget: $e');
      rethrow;
    }
  }
  
  // Get transaction count for a revamped budget
  // CRITICAL: Uses SELECTED period date range, not budget's original period
  // This allows filtering transactions by the currently selected month/week/day
  int getTransactionCountForRevampedBudget(RevampedBudget budget) {
    // Get selected period date range (not budget's date range)
    final periodRange = _getSelectedPeriodRange();
    final startDate = periodRange['start'];
    final endDate = periodRange['end'];
    
    if (startDate == null || endDate == null) {
      return 0;
    }
    
    // Filter transactions by selected period date range
    final transactions = _allTransactions.where((t) {
      return t.type == 'expense' &&
             t.isVacation == false &&
             budget.categoryIds.contains(t.categoryId) &&
             t.currency == budget.currency &&
             t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             t.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
    
    return transactions.length;
  }
  
  @override
  void dispose() {
    _transactionsSubscription?.cancel();
    _homeScreenProvider.removeListener(_onHomeScreenProviderChanged);
    _currencyProvider.removeListener(_onCurrencyChanged);
    super.dispose();
  }
}

// Helper class to combine revamped budget data with category information
class RevampedCategoryBudgetData {
  final List<String> categoryIds;
  final List<String> categoryNames;
  final RevampedBudget revampedBudget;
  final double spentAmount;
  final double limit;
  final Category firstCategory; // For display purposes (icon, color)
  final String? budgetName;
  
  RevampedCategoryBudgetData({
    required this.categoryIds,
    required this.categoryNames,
    required this.revampedBudget,
    required this.spentAmount,
    required this.limit,
    required this.firstCategory,
    this.budgetName,
  });
  
  String get displayName => budgetName != null && budgetName!.isNotEmpty 
      ? budgetName! 
      : categoryNames.join(', ');
  String get categoryIcon => firstCategory.icon ?? 'category';
  String get categoryColor => firstCategory.color ?? 'grey';
}

