import 'dart:async';
import 'package:flutter/material.dart';
import 'package:budgetm/models/budget.dart';
import 'package:budgetm/models/category.dart';
import 'package:budgetm/models/firestore_transaction.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/viewmodels/currency_provider.dart';
import 'package:budgetm/viewmodels/vacation_mode_provider.dart';
import 'package:budgetm/viewmodels/home_screen_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BudgetProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService.instance;
  final CurrencyProvider _currencyProvider;
  final VacationProvider _vacationProvider;
  final HomeScreenProvider _homeScreenProvider;
  
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
    required HomeScreenProvider homeScreenProvider,
  })  : _currencyProvider = currencyProvider,
        _vacationProvider = vacationProvider,
        _homeScreenProvider = homeScreenProvider {
    _vacationProvider.addListener(_onVacationModeChanged);
    _homeScreenProvider.addListener(_onHomeScreenProviderChanged);
    _currencyProvider.addListener(_onCurrencyChanged);
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
    if (_vacationProvider.isVacationMode) {
      // Vacation mode: show all categories with transactions, create placeholder budgets
      return _getVacationModeBudgetData();
    } else {
      // Normal mode: only show categories that have real budgets created by user
      return _getNormalModeBudgetData();
    }
  }
  
  // Vacation mode: show categories with transactions and create placeholder budgets per currency
  List<CategoryBudgetData> _getVacationModeBudgetData() {
    // Get categories and currencies that have transactions in vacation mode
    final categoryCurrencyMap = <String, Set<String>>{};
    
    // Collect all category IDs and their currencies that have transactions in vacation mode
    for (final transaction in _allTransactions) {
      if (transaction.type == 'expense' && 
          transaction.isVacation == _vacationProvider.isVacationMode &&
          transaction.categoryId != null &&
          transaction.categoryId!.isNotEmpty &&
          transaction.currency.isNotEmpty) {
        
        if (!categoryCurrencyMap.containsKey(transaction.categoryId!)) {
          categoryCurrencyMap[transaction.categoryId!] = <String>{};
        }
        categoryCurrencyMap[transaction.categoryId!]!.add(transaction.currency);
      }
    }
    
    // Create budget data for each category-currency combination
    final budgetDataList = <CategoryBudgetData>[];
    
    for (final entry in categoryCurrencyMap.entries) {
      final categoryId = entry.key;
      final currencies = entry.value;
      
      // Find the category
      final category = _expenseCategories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => Category(id: '', name: 'Unknown', icon: '', color: '', displayOrder: 999),
      );
      
      // Create budget data for each currency
      for (final currency in currencies) {
        final budgetData = _createVacationBudgetForCategoryCurrency(category, currency);
        budgetDataList.add(budgetData);
      }
    }
    
    // Sort by category display order, then by currency
    budgetDataList.sort((a, b) {
      final categoryComparison = a.category.displayOrder.compareTo(b.category.displayOrder);
      if (categoryComparison != 0) return categoryComparison;
      return a.budget.currency.compareTo(b.budget.currency);
    });
    
    return budgetDataList;
  }
  
  // Create vacation budget data for a specific category and currency
  CategoryBudgetData _createVacationBudgetForCategoryCurrency(Category category, String currency) {
    // Find budget for this category with selected type, period, and currency
    Budget? matchingBudget;
    
    switch (_selectedBudgetType) {
      case BudgetType.weekly:
        // First try to find a non-recurring budget for the selected week
        matchingBudget = _budgets.firstWhere(
          (b) => b.categoryId == category.id &&
                 b.type == _selectedBudgetType &&
                 b.currency == currency &&
                 b.isVacation == true &&
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
            currency: currency,
            spentAmount: 0.0,
            isRecurring: false,
            isVacation: true,
          ),
        );
        
        // If no non-recurring budget found, try to find a recurring budget
        if (matchingBudget.id.isEmpty) {
          final recurringBudget = _budgets.firstWhere(
            (b) => b.categoryId == category.id &&
                   b.type == _selectedBudgetType &&
                   b.currency == currency &&
                   b.isVacation == true &&
                   b.isRecurring,
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
              currency: currency,
              spentAmount: 0.0,
              isRecurring: false,
              isVacation: true,
            ),
          );
          
          // If a recurring budget is found, create a temporary budget with the correct date range
          if (recurringBudget.id.isNotEmpty) {
            final periodRange = _getSelectedPeriodRange();
            // Preserve the underlying recurring budget's ID so operations (e.g., delete) have a valid document path.
            matchingBudget = recurringBudget.copyWith(
              id: recurringBudget.id, // Use real ID for recurring budget instance
              startDate: periodRange['start'],
              endDate: periodRange['end'],
            );
          }
        }
        break;
      case BudgetType.monthly:
        // First try to find a non-recurring budget for the selected month
        matchingBudget = _budgets.firstWhere(
          (b) => b.categoryId == category.id &&
                 b.type == _selectedBudgetType &&
                 b.currency == currency &&
                 b.isVacation == true &&
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
            currency: currency,
            spentAmount: 0.0,
            isRecurring: false,
            isVacation: true,
          ),
        );
        
        // If no non-recurring budget found, try to find a recurring budget
        if (matchingBudget.id.isEmpty) {
          final recurringBudget = _budgets.firstWhere(
            (b) => b.categoryId == category.id &&
                   b.type == _selectedBudgetType &&
                   b.currency == currency &&
                   b.isVacation == true &&
                   b.isRecurring,
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
              currency: currency,
              spentAmount: 0.0,
              isRecurring: false,
              isVacation: true,
            ),
          );
          
          // If a recurring budget is found, create a temporary budget with the correct date range
          if (recurringBudget.id.isNotEmpty) {
            final periodRange = _getSelectedPeriodRange();
            // Preserve the underlying recurring budget's ID so operations (e.g., delete) have a valid document path.
            matchingBudget = recurringBudget.copyWith(
              id: recurringBudget.id, // Use real ID for recurring budget instance
              startDate: periodRange['start'],
              endDate: periodRange['end'],
            );
          }
        }
        break;
      case BudgetType.yearly:
        // First try to find a non-recurring budget for the selected year
        matchingBudget = _budgets.firstWhere(
          (b) => b.categoryId == category.id &&
                 b.type == _selectedBudgetType &&
                 b.currency == currency &&
                 b.isVacation == true &&
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
            currency: currency,
            spentAmount: 0.0,
            isRecurring: false,
            isVacation: true,
          ),
        );
        
        // If no non-recurring budget found, try to find a recurring budget
        if (matchingBudget.id.isEmpty) {
          final recurringBudget = _budgets.firstWhere(
            (b) => b.categoryId == category.id &&
                   b.type == _selectedBudgetType &&
                   b.currency == currency &&
                   b.isVacation == true &&
                   b.isRecurring,
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
              currency: currency,
              spentAmount: 0.0,
              isRecurring: false,
              isVacation: true,
            ),
          );
          
          // If a recurring budget is found, create a temporary budget with the correct date range
          if (recurringBudget.id.isNotEmpty) {
            final periodRange = _getSelectedPeriodRange();
            // Preserve the underlying recurring budget's ID so operations (e.g., delete) have a valid document path.
            matchingBudget = recurringBudget.copyWith(
              id: recurringBudget.id, // Use real ID for recurring budget instance
              startDate: periodRange['start'],
              endDate: periodRange['end'],
            );
          }
        }
        break;
    }
    
    // Always calculate spent amount from transactions for this specific currency
    final adjustedBudget = matchingBudget.copyWith(isVacation: true);
    final spentAmount = _calculateSpentAmountForCurrency(adjustedBudget, currency);
    
    return CategoryBudgetData(
      category: category,
      budget: matchingBudget.copyWith(spentAmount: spentAmount),
    );
  }
  
  // Calculate spent amount for a specific currency in vacation mode
  double _calculateSpentAmountForCurrency(Budget budget, String currency) {
    final transactions = _allTransactions.where((t) {
      return t.type == 'expense' &&
             t.isVacation == _vacationProvider.isVacationMode &&
             t.categoryId == budget.categoryId &&
             t.currency == currency &&
             t.date.isAfter(budget.startDate.subtract(const Duration(days: 1))) &&
             t.date.isBefore(budget.endDate.add(const Duration(days: 1)));
    }).toList();
    
    return transactions.fold(0.0, (sum, transaction) => sum + transaction.amount);
  }
  
  // Normal mode: only show categories that have real budgets created by user
  List<CategoryBudgetData> _getNormalModeBudgetData() {
    // Get categories and currencies that have real budgets (not placeholder budgets)
    final categoryCurrencyMap = <String, Set<String>>{};
    
    // Collect all category IDs and their currencies that have real budgets
    for (final budget in _budgets) {
      if (budget.id.isNotEmpty && budget.isVacation == false) { // Only real budgets in normal mode
        if (!categoryCurrencyMap.containsKey(budget.categoryId)) {
          categoryCurrencyMap[budget.categoryId] = <String>{};
        }
        categoryCurrencyMap[budget.categoryId]!.add(budget.currency);
      }
    }
    
    // Create budget data for each category-currency combination
    final budgetDataList = <CategoryBudgetData>[];
    
    for (final entry in categoryCurrencyMap.entries) {
      final categoryId = entry.key;
      final currencies = entry.value;
      
      // Find the category
      final category = _expenseCategories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => Category(id: '', name: 'Unknown', icon: '', color: '', displayOrder: 999),
      );
      
      // Create budget data for each currency
      for (final currency in currencies) {
        final budgetData = _createNormalBudgetForCategoryCurrency(category, currency);
        budgetDataList.add(budgetData);
      }
    }
    
    // Sort by category display order, then by currency
    budgetDataList.sort((a, b) {
      final categoryComparison = a.category.displayOrder.compareTo(b.category.displayOrder);
      if (categoryComparison != 0) return categoryComparison;
      return a.budget.currency.compareTo(b.budget.currency);
    });
    
    return budgetDataList;
  }
  
  // Create normal budget data for a specific category and currency with hierarchical display
  CategoryBudgetData _createNormalBudgetForCategoryCurrency(Category category, String currency) {
    // Find the most relevant budget for this category and currency
    // Priority: Exact match > Recurring match > Placeholder
    Budget? matchingBudget;
    
    // Get all budgets for this category and currency
    final relevantBudgets = _budgets.where((b) => 
      b.categoryId == category.id &&
      b.currency == currency &&
      b.isVacation == false &&
      b.id.isNotEmpty
    ).toList();
    
    // Find the best matching budget based on selected period
    switch (_selectedBudgetType) {
      case BudgetType.weekly:
        matchingBudget = _findBestWeeklyBudget(relevantBudgets);
        break;
      case BudgetType.monthly:
        matchingBudget = _findBestMonthlyBudget(relevantBudgets);
        break;
      case BudgetType.yearly:
        matchingBudget = _findBestYearlyBudget(relevantBudgets);
        break;
    }
    
    // If no budget found, create a placeholder
    if (matchingBudget == null || matchingBudget.id.isEmpty) {
      final periodRange = _getSelectedPeriodRange();
      matchingBudget = Budget(
        id: '',
        categoryId: category.id,
        limit: 0.0,
        type: _selectedBudgetType,
        year: _getCurrentYear(),
        period: _getCurrentPeriod(),
        startDate: periodRange['start'] ?? DateTime.now(),
        endDate: periodRange['end'] ?? DateTime.now(),
        userId: '',
        currency: currency,
        spentAmount: 0.0,
        isRecurring: false,
        isVacation: false,
      );
    }
    
    // Calculate spent amount for this specific currency and period
    final spentAmount = _calculateSpentAmountForCurrency(matchingBudget, currency);
    
    return CategoryBudgetData(
      category: category,
      budget: matchingBudget.copyWith(spentAmount: spentAmount),
    );
  }
  
  // Find the best weekly budget for the selected week
  Budget? _findBestWeeklyBudget(List<Budget> budgets) {
    // Priority 1: Exact weekly budget for the selected week
    for (final budget in budgets) {
      if (budget.type == BudgetType.weekly && _isWeekInSelectedPeriod(budget)) {
        return budget;
      }
    }
    
    // Priority 2: Recurring weekly budget
    for (final budget in budgets) {
      if (budget.type == BudgetType.weekly && budget.isRecurring) {
        final periodRange = _getSelectedPeriodRange();
        return budget.copyWith(
          id: budget.id, // Keep original ID for deletion
          startDate: periodRange['start'],
          endDate: periodRange['end'],
        );
      }
    }
    
    // Priority 3: Monthly budget that covers this week
    for (final budget in budgets) {
      if (budget.type == BudgetType.monthly && _isWeekInMonthlyPeriod(budget)) {
        return budget.copyWith(
          id: budget.id, // Keep original ID for deletion
          type: BudgetType.weekly, // Mark as weekly for display
        );
      }
    }
    
    // Priority 4: Yearly budget that covers this week
    for (final budget in budgets) {
      if (budget.type == BudgetType.yearly && _isWeekInYearlyPeriod(budget)) {
        return budget.copyWith(
          id: budget.id, // Keep original ID for deletion
          type: BudgetType.weekly, // Mark as weekly for display
        );
      }
    }
    
    return null;
  }
  
  // Find the best monthly budget for the selected month
  Budget? _findBestMonthlyBudget(List<Budget> budgets) {
    // Priority 1: Exact monthly budget for the selected month
    for (final budget in budgets) {
      if (budget.type == BudgetType.monthly && 
          budget.year == _selectedMonth.year && 
          budget.period == _selectedMonth.month) {
        return budget;
      }
    }
    
    // Priority 2: Recurring monthly budget
    for (final budget in budgets) {
      if (budget.type == BudgetType.monthly && budget.isRecurring) {
        final periodRange = _getSelectedPeriodRange();
        return budget.copyWith(
          id: budget.id, // Keep original ID for deletion
          startDate: periodRange['start'],
          endDate: periodRange['end'],
        );
      }
    }
    
    // Priority 3: Weekly budgets that fall within this month
    final weeklyBudgets = budgets.where((b) => 
      b.type == BudgetType.weekly && _isWeekInMonthlyPeriod(b)
    ).toList();
    
    if (weeklyBudgets.isNotEmpty) {
      // Combine weekly budgets or return the first one
      final firstWeekly = weeklyBudgets.first;
      return firstWeekly.copyWith(
        id: firstWeekly.id, // Keep original ID for deletion
        type: BudgetType.monthly, // Mark as monthly for display
      );
    }
    
    // Priority 4: Yearly budget that covers this month
    for (final budget in budgets) {
      if (budget.type == BudgetType.yearly && _isMonthInYearlyPeriod(budget)) {
        return budget.copyWith(
          id: budget.id, // Keep original ID for deletion
          type: BudgetType.monthly, // Mark as monthly for display
        );
      }
    }
    
    return null;
  }
  
  // Find the best yearly budget for the selected year
  Budget? _findBestYearlyBudget(List<Budget> budgets) {
    // Priority 1: Exact yearly budget for the selected year
    for (final budget in budgets) {
      if (budget.type == BudgetType.yearly && budget.year == _selectedYear.year) {
        return budget;
      }
    }
    
    // Priority 2: Recurring yearly budget
    for (final budget in budgets) {
      if (budget.type == BudgetType.yearly && budget.isRecurring) {
        final periodRange = _getSelectedPeriodRange();
        return budget.copyWith(
          id: budget.id, // Keep original ID for deletion
          startDate: periodRange['start'],
          endDate: periodRange['end'],
        );
      }
    }
    
    // Priority 3: Monthly budgets that fall within this year
    final monthlyBudgets = budgets.where((b) => 
      b.type == BudgetType.monthly && _isMonthInYearlyPeriod(b)
    ).toList();
    
    if (monthlyBudgets.isNotEmpty) {
      // Combine monthly budgets or return the first one
      final firstMonthly = monthlyBudgets.first;
      return firstMonthly.copyWith(
        id: firstMonthly.id, // Keep original ID for deletion
        type: BudgetType.yearly, // Mark as yearly for display
      );
    }
    
    // Priority 4: Weekly budgets that fall within this year
    final weeklyBudgets = budgets.where((b) => 
      b.type == BudgetType.weekly && _isWeekInYearlyPeriod(b)
    ).toList();
    
    if (weeklyBudgets.isNotEmpty) {
      // Combine weekly budgets or return the first one
      final firstWeekly = weeklyBudgets.first;
      return firstWeekly.copyWith(
        id: firstWeekly.id, // Keep original ID for deletion
        type: BudgetType.yearly, // Mark as yearly for display
      );
    }
    
    return null;
  }
  
  // Helper methods for period checking
  bool _isWeekInMonthlyPeriod(Budget budget) {
    if (budget.type != BudgetType.weekly) return false;
    return budget.startDate.year == _selectedMonth.year && 
           budget.startDate.month == _selectedMonth.month;
  }
  
  bool _isWeekInYearlyPeriod(Budget budget) {
    if (budget.type != BudgetType.weekly) return false;
    return budget.startDate.year == _selectedYear.year;
  }
  
  bool _isMonthInYearlyPeriod(Budget budget) {
    if (budget.type != BudgetType.monthly) return false;
    return budget.year == _selectedYear.year;
  }
  
  int _getCurrentYear() {
    switch (_selectedBudgetType) {
      case BudgetType.weekly:
        return _selectedWeeklyMonth.year;
      case BudgetType.monthly:
        return _selectedMonth.year;
      case BudgetType.yearly:
        return _selectedYear.year;
    }
  }
  
  int _getCurrentPeriod() {
    switch (_selectedBudgetType) {
      case BudgetType.weekly:
        return _selectedWeek;
      case BudgetType.monthly:
        return _selectedMonth.month;
      case BudgetType.yearly:
        return _selectedYear.year;
    }
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
  // Use the budget's own startDate and endDate. For recurring budgets,
  // this will be the correct date range from the temporary budget object.
  final start = budget.startDate;
  final end = budget.endDate;

  return _allTransactions
    .where((t) =>
      t.type == 'expense' &&
      t.categoryId == budget.categoryId &&
      // Include transactions on the boundary
      t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
      t.date.isBefore(end.add(const Duration(seconds: 1))) &&
      t.isVacation == budget.isVacation && // Match vacation status
      t.currency == budget.currency) // Match currency
    .fold(0.0, (sum, t) => sum + t.amount);
  }
  
  // Get transaction count for a specific budget
  int getTransactionCountForBudget(Budget budget) {
    return _allTransactions
        .where((t) =>
            t.type == 'expense' &&
            t.categoryId == budget.categoryId &&
            t.date.isAfter(budget.startDate.subtract(const Duration(seconds: 1))) &&
            t.date.isBefore(budget.endDate.add(const Duration(seconds: 1))) &&
            t.isVacation == budget.isVacation && // Match vacation status
            t.currency == budget.currency) // Match currency
        .length;
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

  // Compute the currently selected period's start and end DateTime based on
  // the provider's selection fields and _selectedBudgetType.
  // Returns a map with keys 'start' and 'end'. Values may be null if unable
  // to determine and caller should fall back to budget values.
  Map<String, DateTime?> _getSelectedPeriodRange() {
    try {
      switch (_selectedBudgetType) {
        case BudgetType.weekly:
          final currentYear = _selectedWeeklyMonth.year;
          final currentMonth = _selectedWeeklyMonth.month;
          final firstDayOfMonth = DateTime(currentYear, currentMonth, 1);
          final firstSunday = Budget.getStartOfWeek(firstDayOfMonth);
          final weekStartDate = firstSunday.add(Duration(days: (_selectedWeek - 1) * 7));
          final weekEndDate = weekStartDate.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
          return {'start': weekStartDate, 'end': weekEndDate};
        case BudgetType.monthly:
          final start = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
          final end = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);
          return {'start': start, 'end': end};
        case BudgetType.yearly:
          final start = DateTime(_selectedYear.year, 1, 1);
          final end = DateTime(_selectedYear.year, 12, 31, 23, 59, 59);
          return {'start': start, 'end': end};
      }
    } catch (e) {
      print('Error computing selected period range: $e');
    }
    return {'start': null, 'end': null};
  }

  // Public getters to expose the currently-selected period's start and end
  // for other UI code (e.g., detail screens) to use when fetching data.
  DateTime? get selectedPeriodStart => _getSelectedPeriodRange()['start'];
  DateTime? get selectedPeriodEnd => _getSelectedPeriodRange()['end'];
  
  // Get transactions for selected category
  List<FirestoreTransaction> get filteredTransactions {
    if (_selectedCategoryId == null) return _allTransactions;
    return _allTransactions.where((t) => t.categoryId == _selectedCategoryId).toList();
  }
  
  // Initialize and load data
  Future<void> initialize() async {
    print('DEBUG BudgetProvider.initialize: start (isVacation=${_vacationProvider.isVacationMode})');
    await loadData();
    print('DEBUG BudgetProvider.initialize: loadData completed, setting up transactions listener');
    _setupTransactionsListener();
    print('DEBUG BudgetProvider.initialize: listener setup complete');
  }
  
  // Set up listener for transactions stream
  void _setupTransactionsListener() {
    // Cancel existing subscription if any
    _transactionsSubscription?.cancel();
    // Subscribe to transactions stream and locally filter by current vacation mode.
    // If FirestoreService supports passing vacation params to the stream, it
    // should be used instead for server-side filtering.
    _transactionsSubscription = _firestoreService
        .streamTransactions(
          vacationAccountId: _vacationProvider.isVacationMode
            ? _vacationProvider.activeVacationAccountId
            : null,
        )
        .listen((transactions) {
      try {
        final filtered = transactions.where((t) =>
          t.type == 'expense' && (t.isVacation == _vacationProvider.isVacationMode)
        ).toList();
        print('DEBUG BudgetProvider.stream: received ${transactions.length} tx, filtered ${filtered.length} for isVacation=${_vacationProvider.isVacationMode}');
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
    print('DEBUG BudgetProvider.loadData: start (isVacation=${_vacationProvider.isVacationMode})');
    _isLoading = true;
    notifyListeners();
    
    try {
      // Fetch categories
      print('DEBUG BudgetProvider.loadData: fetching categories');
      await _fetchCategories();
      print('DEBUG BudgetProvider.loadData: fetched ${_allCategories.length} categories, expenseCategories=${_expenseCategories.length}');
      
      // Load budgets based on current vacation mode
      if (_vacationProvider.isVacationMode) {
        print('DEBUG BudgetProvider.loadData: fetching vacation budgets for vacationAccountId=${_vacationProvider.activeVacationAccountId}');
        _budgets = await _firestoreService.getAllVacationBudgets(
          vacationAccountId: _vacationProvider.activeVacationAccountId
        );
      } else {
        print('DEBUG BudgetProvider.loadData: fetching regular budgets');
        _budgets = await _firestoreService.getAllBudgets(isVacation: false);
      }
      print('DEBUG BudgetProvider.loadData: fetched ${_budgets.length} budgets (sample ids: ${_budgets.take(5).map((b)=>b.id).toList()})');
      
      // Load all expense transactions based on current vacation mode
      print('DEBUG BudgetProvider.loadData: fetching transactions isVacation=${_vacationProvider.isVacationMode}');
      final allTransactions = await _firestoreService.getAllTransactions(
        isVacation: _vacationProvider.isVacationMode,
        vacationAccountId: _vacationProvider.isVacationMode
          ? _vacationProvider.activeVacationAccountId
          : null
      );
      _allTransactions = allTransactions.where((t) => t.type == 'expense').toList();
      print('DEBUG BudgetProvider.loadData: fetched ${_allTransactions.length} expense transactions (sample ids: ${_allTransactions.take(5).map((t)=>t.id).toList()})');
      
    } catch (e) {
      print('Error loading budget data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      print('DEBUG BudgetProvider.loadData: completed (isVacation=${_vacationProvider.isVacationMode})');
    }
  }

  // Listener for vacation mode changes
  void _onVacationModeChanged() {
    // Recreate subscription and reload data when vacation mode flips so the
    // provider state always reflects the currently-selected mode. We cancel
    // first, then reinitialize everything.
    _transactionsSubscription?.cancel();
    // Reload budgets and transactions for the new mode, then recreate stream
    // to keep everything in sync.
    loadData().then((_) {
      _setupTransactionsListener();
    });
  }
  
  // Listener for currency changes
  void _onCurrencyChanged() {
    print('DEBUG BudgetProvider: Currency changed, reloading data');
    loadData();
  }
  
  // Listener for HomeScreenProvider changes
  void _onHomeScreenProviderChanged() {
    if (_homeScreenProvider.shouldRefreshTransactions || _homeScreenProvider.shouldRefresh) {
      print('DEBUG: BudgetProvider detected refresh trigger, reloading data');
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
  Future<void> addBudget(String categoryId, double limit, BudgetType type, {bool isVacation = false, bool isRecurring = false, String? currency}) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        print('BudgetProvider.addBudget: aborted - user not authenticated');
        throw Exception('User not authenticated');
      }
      
      print('BudgetProvider.addBudget called: category=$categoryId limit=$limit type=$type isVacation=$isVacation isRecurring=$isRecurring');
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
      
      // Use provided currency or fall back to provider's currency
      final budgetCurrency = currency ?? _currencyProvider.selectedCurrencyCode;
      
      final budgetId = Budget.generateId(userId, categoryId, type, year, period, isVacation, isRecurring, currency: budgetCurrency);
      print('BudgetProvider.addBudget: generated budgetId=$budgetId');
      
      // Check for duplicate budget (same category, type, period, AND currency)
      final existingBudget = _budgets.firstWhere(
        (b) => b.categoryId == categoryId &&
               b.type == type &&
               b.year == year &&
               b.period == period &&
               b.currency == budgetCurrency &&
               b.isVacation == isVacation, // Also check vacation mode to prevent conflicts
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
          currency: budgetCurrency,
        ),
      );
      
      if (existingBudget.id.isNotEmpty) {
        print('BudgetProvider.addBudget: duplicate budget found for category=$categoryId, type=$type, year=$year, period=$period, currency=$budgetCurrency, isVacation=$isVacation');
        throw Exception('A budget for this category and currency already exists for this period.');
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
        currency: budgetCurrency,
        isVacation: isVacation, // New field
        isRecurring: isRecurring,
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
    _homeScreenProvider.removeListener(_onHomeScreenProviderChanged);
    _currencyProvider.removeListener(_onCurrencyChanged);
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