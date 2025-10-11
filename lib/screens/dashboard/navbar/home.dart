
import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/models/firestore_transaction.dart';
import 'package:budgetm/models/firestore_task.dart';
import 'package:budgetm/models/firestore_account.dart';
import 'package:budgetm/models/category.dart';
import 'package:budgetm/models/transaction.dart' as model;
import 'package:budgetm/constants/transaction_type_enum.dart';
import 'package:budgetm/screens/dashboard/navbar/feedback_modal.dart';
import 'package:budgetm/screens/dashboard/navbar/home/analytics/analytics_screen.dart';
import 'package:budgetm/screens/dashboard/navbar/home/expense_detail/expense_detail_screen.dart';
import 'package:budgetm/screens/dashboard/profile/profile_screen.dart';
import 'package:budgetm/screens/dashboard/navbar/home/vacation_dialog.dart';
import 'package:budgetm/viewmodels/vacation_mode_provider.dart';
import 'package:budgetm/viewmodels/home_screen_provider.dart';
import 'package:budgetm/viewmodels/navbar_visibility_provider.dart';
import 'package:budgetm/viewmodels/currency_provider.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budgetm/utils/icon_utils.dart';
import 'package:shimmer/shimmer.dart';

// Data structure to hold all data for a specific month page
class MonthPageData {
  final List<FirestoreTransaction> transactions;
  final double totalIncome;
  final double totalExpenses;
  final List<TransactionWithAccount> transactionsWithAccounts;
  final List<FirestoreTask> upcomingTasks;
  final bool isLoading;
  final String? error;

  MonthPageData({
    required this.transactions,
    required this.totalIncome,
    required this.totalExpenses,
    required this.transactionsWithAccounts,
    required this.upcomingTasks,
    this.isLoading = false,
    this.error,
  });

  // Create a loading state
  factory MonthPageData.loading() => MonthPageData(
    transactions: [],
    totalIncome: 0.0,
    totalExpenses: 0.0,
    transactionsWithAccounts: [],
    upcomingTasks: [],
    isLoading: true,
  );

  // Create an error state
  factory MonthPageData.error(String error) => MonthPageData(
    transactions: [],
    totalIncome: 0.0,
    totalExpenses: 0.0,
    transactionsWithAccounts: [],
    upcomingTasks: [],
    error: error,
  );
}

// Data structure to hold a transaction with its associated account and category
class TransactionWithAccount {
  final FirestoreTransaction transaction;
  final FirestoreAccount? account;
  final Category? category;

  TransactionWithAccount({
    required this.transaction,
    this.account,
    this.category,
  });
}

// Helper function to convert Firestore transaction to UI transaction
model.Transaction _convertToUiTransaction(FirestoreTransaction firestoreTransaction, BuildContext context, [Category? category]) {
  return model.Transaction(
    id: firestoreTransaction.id, // ID is already String in Firestore
    title: firestoreTransaction.description,
    description: firestoreTransaction.description,
    amount: firestoreTransaction.amount,
    type: firestoreTransaction.type == 'income'
        ? TransactionType.income
        : TransactionType.expense,
    date: firestoreTransaction.date,
    // Use category (when available) to resolve the correct icon via getIcon.
    icon: HugeIcon(icon: getIcon(category?.icon), color: Colors.black87, size: 20),
    iconBackgroundColor: Colors.grey.shade100, // Default color
    accountId: firestoreTransaction.accountId, // Pass accountId from Firestore transaction
    categoryId: firestoreTransaction.categoryId, // Already String in Firestore
    paid: firestoreTransaction.paid, // CRITICAL: carry paid flag into UI model
    currency: Provider.of<CurrencyProvider>(context, listen: false).selectedCurrencyCode, // New required field
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late ScrollController _monthScrollController;
  late ScrollController _contentScrollController;
  late PageController _pageController;
  late FirestoreService _firestoreService;
  List<DateTime> _months = [];
  int _selectedMonthIndex = 0;

  List<FirestoreTransaction> _transactions = [];
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  List<TransactionWithAccount> _transactionsWithAccounts = [];
  List<FirestoreTask> _upcomingTasks = [];
  bool? _previousVacationMode;
  bool _isTogglingVacationMode = false;
  
  double _lastContentOffset = 0.0;
  // Debounce timer to delay loads until after page settling
  Timer? _settleTimer;
  // Prevent duplicate loads for the same target month
  int? _loadingMonthIndex;
  
  // New variables for pre-loading
  Map<int, MonthPageData> _pageDataMap = {};
  List<FirestoreAccount> _allAccounts = [];
  List<Category> _allCategories = [];
  Set<int> _loadingIndices = {};

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService.instance;
    _monthScrollController = ScrollController();
    _contentScrollController = ScrollController();
    _pageController = PageController();
    _lastContentOffset = 0.0;

    // Listen to vertical content scrolls to toggle navbar visibility.
    _contentScrollController.addListener(() {
      if (!_contentScrollController.hasClients) return;
      final provider =
          Provider.of<NavbarVisibilityProvider>(context, listen: false);
      final direction = _contentScrollController.position.userScrollDirection;

      if (direction == ScrollDirection.reverse) {
        provider.setNavBarVisibility(false);
      } else if (direction == ScrollDirection.forward) {
        provider.setNavBarVisibility(true);
      }
    });

    _loadMonths();

    // Defer data loads until after build so we can read VacationProvider from context.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStaticData().then((_) {
        final isVacationMode =
            Provider.of<VacationProvider>(context, listen: false).isVacationMode;
        _previousVacationMode = isVacationMode;
        
        // Load the current month data using the new unified loading method
        _loadDataForCurrentMonth(isVacation: isVacationMode);
        
        // Preload surrounding months after current month is loaded
        _preloadSurroundingMonths(_selectedMonthIndex);
      });
    });

    WidgetsBinding.instance.addObserver(this);
  }

  // New function to load static data once
  Future<void> _loadStaticData() async {
    try {
      final accounts = await _firestoreService.getAllAccounts();
      final categories = await _firestoreService.getAllCategories();
      if (mounted) {
        setState(() {
          _allAccounts = accounts;
          _allCategories = categories;
        });
      }
    } catch (e) {
      print('Error loading static data: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _monthScrollController.dispose();
    _contentScrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh data when app resumes
    if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentVacationMode =
        Provider.of<VacationProvider>(context, listen: false).isVacationMode;
    // If we have a previous value and it differs from current, vacation mode was toggled
    if (_previousVacationMode != null && currentVacationMode != _previousVacationMode) {
      // Only refresh if this screen is currently visible
      if (ModalRoute.of(context)?.isCurrent == true) {
        _refreshData();
      }
    }
    // Update previous state for future comparisons
    _previousVacationMode = currentVacationMode;
  }

  Future<void> _refreshData() async {
    final isVacationMode =
        Provider.of<VacationProvider>(context, listen: false).isVacationMode;
    
    // Clear the cache for the current month to force refresh
    if (_pageDataMap.containsKey(_selectedMonthIndex)) {
      setState(() {
        _pageDataMap.remove(_selectedMonthIndex);
      });
    }
    
    await _loadDataForCurrentMonth(isVacation: isVacationMode);
  }

  Future<void> _refreshAccountData() async {
    final isVacationMode =
        Provider.of<VacationProvider>(context, listen: false).isVacationMode;
    
    // Reload static data
    await _loadStaticData();
    
    // Clear all cached data to force refresh with new account data
    setState(() {
      _pageDataMap.clear();
    });
    
    // Reload current month
    await _loadDataForCurrentMonth(isVacation: isVacationMode);
  }

  Future<void> _loadMonths() async {
    final prefs = await SharedPreferences.getInstance();
    final firstLoginDateString = prefs.getString('firstLoginDate');
    final firstLoginDate = firstLoginDateString != null
        ? DateTime.parse(firstLoginDateString)
        : DateTime.now();

    final now = DateTime.now();
    List<DateTime> generatedMonths = [];
    DateTime currentDate = DateTime(firstLoginDate.year, firstLoginDate.month);

    while (currentDate.isBefore(
      DateTime(now.year, now.month).add(const Duration(days: 365)),
    )) {
      generatedMonths.add(currentDate);
      currentDate = DateTime(currentDate.year, currentDate.month + 1);
    }
    if (mounted) {
      setState(() {
        _months = generatedMonths;
        _selectedMonthIndex = _months.indexWhere(
          (month) => month.year == now.year && month.month == now.month,
        );
        if (_selectedMonthIndex == -1) {
          _selectedMonthIndex = _months.length - 13;
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_monthScrollController.hasClients) {
        _scrollToSelectedMonth();
      }
      // Align PageView to the determined initial month once months are ready
      if (_pageController.hasClients &&
          _selectedMonthIndex >= 0 &&
          _selectedMonthIndex < _months.length) {
        try {
          _pageController.jumpToPage(_selectedMonthIndex);
        } catch (_) {
          // no-op: safe guard against rare cases before attachment
        }
      }
    });
  }

  // These methods are now deprecated - we use the unified _loadDataForMonth approach
  // Keeping them for reference but they're no longer called
  
  void _toggleVacationModeWithDebounce() {
    setState(() {
      _isTogglingVacationMode = true;
    });
  
    Provider.of<VacationProvider>(context, listen: false).toggleVacationMode();
  
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isTogglingVacationMode = false;
        });
      }
    });
  }

  // New efficient data loading function that returns MonthPageData
  Future<MonthPageData> _loadDataForMonth(DateTime month, {required bool isVacation}) async {
    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 1);
      
      // Load all data concurrently for better performance
      final results = await Future.wait([
        // Load transactions for the month
        _firestoreService.getTransactionsForDateRange(
          startOfMonth,
          endOfMonth,
          isVacation: isVacation,
        ),
        // Load income and expenses for the month (only if not in vacation mode)
        isVacation 
          ? Future.value({'income': 0.0, 'expenses': 0.0})
          : _firestoreService.getIncomeAndExpensesForDateRange(
              startOfMonth,
              endOfMonth,
              isVacation: isVacation,
            ),
        // Load upcoming tasks for the month
        _firestoreService.getUpcomingTasksForDateRange(startOfMonth, endOfMonth),
      ]);
      
      final transactions = results[0] as List<FirestoreTransaction>;
      final totals = results[1] as Map<String, double>;
      final tasks = results[2] as List<FirestoreTask>;
      
      // Sort transactions by date
      transactions.sort((a, b) => a.date.compareTo(b.date));
      
      // Create maps for accounts and categories (already loaded once)
      final accountMap = {for (var account in _allAccounts) account.id: account};
      final categoryMap = {for (var category in _allCategories) category.id: category};
      
      // Create TransactionWithAccount objects
      final transactionsWithAccounts = transactions.map((transaction) {
        return TransactionWithAccount(
          transaction: transaction,
          account: transaction.accountId != null
              ? accountMap[transaction.accountId]
              : null,
          category: transaction.categoryId != null
              ? categoryMap[transaction.categoryId]
              : null,
        );
      }).toList();
      
      return MonthPageData(
        transactions: transactions,
        totalIncome: totals['income'] ?? 0.0,
        totalExpenses: totals['expenses'] ?? 0.0,
        transactionsWithAccounts: transactionsWithAccounts,
        upcomingTasks: tasks,
      );
    } catch (e) {
      print('Error loading data for month: $e');
      return MonthPageData.error('Failed to load data');
    }
  }

  // Function to load data for the current month and update the display
  Future<void> _loadDataForCurrentMonth({required bool isVacation}) async {
    if (_months.isEmpty || _selectedMonthIndex < 0 || _selectedMonthIndex >= _months.length) {
      return;
    }
    
    final month = _months[_selectedMonthIndex];
    
    // Check if data is already in cache
    if (_pageDataMap.containsKey(_selectedMonthIndex)) {
      final data = _pageDataMap[_selectedMonthIndex]!;
      if (!data.isLoading && data.error == null) {
        // Update the display with cached data
        if (mounted) {
          setState(() {
            _transactions = data.transactions;
            _totalIncome = data.totalIncome;
            _totalExpenses = data.totalExpenses;
            _transactionsWithAccounts = data.transactionsWithAccounts;
            _upcomingTasks = data.upcomingTasks;
          });
        }
        return;
      }
    }
    
    // Set loading state without updating the UI (let shimmer handle the visual loading)
    if (!_pageDataMap.containsKey(_selectedMonthIndex)) {
      _pageDataMap[_selectedMonthIndex] = MonthPageData.loading();
    }
    
    final data = await _loadDataForMonth(month, isVacation: isVacation);
    
    if (mounted) {
      setState(() {
        _pageDataMap[_selectedMonthIndex] = data;
        _transactions = data.transactions;
        _totalIncome = data.totalIncome;
        _totalExpenses = data.totalExpenses;
        _transactionsWithAccounts = data.transactionsWithAccounts;
        _upcomingTasks = data.upcomingTasks;
      });
    }
  }

  // Function to pre-load data for surrounding months
  void _preloadSurroundingMonths(int currentIndex) {
    final isVacationMode = Provider.of<VacationProvider>(context, listen: false).isVacationMode;
    
    // Always load 2 months behind and 2 months ahead for seamless swiping
    List<int> indicesToPreload = [];
    for (int i = -2; i <= 2; i++) {
      if (i != 0 && currentIndex + i >= 0 && currentIndex + i < _months.length) {
        indicesToPreload.add(currentIndex + i);
      }
    }
    
    // Start loading data for each index
    for (int index in indicesToPreload) {
      if (!_pageDataMap.containsKey(index) && !_loadingIndices.contains(index)) {
        _loadingIndices.add(index);
        
        // Add loading state
        _pageDataMap[index] = MonthPageData.loading();
        
        // Load data in background
        _loadDataForMonth(_months[index], isVacation: isVacationMode)
          .then((data) {
            if (mounted) {
              setState(() {
                _pageDataMap[index] = data;
                _loadingIndices.remove(index);
              });
            }
          })
          .catchError((error) {
            if (mounted) {
              setState(() {
                _pageDataMap[index] = MonthPageData.error(error.toString());
                _loadingIndices.remove(index);
              });
            }
          });
      }
    }
    
    // Evict data that is outside the preload window (keep 3 months on each side)
    _evictDistantMonths(currentIndex);
  }
  
  // Function to evict data for months that are too far from current
  void _evictDistantMonths(int currentIndex) {
    Set<int> indicesToEvict = {};
    
    for (int index in _pageDataMap.keys) {
      // If the index is more than 4 months away, evict it (keep a wider cache)
      if ((index - currentIndex).abs() > 4) {
        indicesToEvict.add(index);
      }
    }
    
    if (indicesToEvict.isNotEmpty) {
      setState(() {
        for (int index in indicesToEvict) {
          _pageDataMap.remove(index);
        }
      });
    }
  }

  void _scrollToSelectedMonth() {
    if (_selectedMonthIndex != -1) {
      final screenWidth = MediaQuery.of(context).size.width;
      const itemWidth = 85.0; // Adjusted width
      final offset =
          (_selectedMonthIndex * itemWidth) -
          (screenWidth / 2) +
          (itemWidth / 2);
      _monthScrollController.animateTo(
        offset.clamp(0.0, _monthScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vacationProvider = context.watch<VacationProvider>();
    final homeScreenProvider = context.watch<HomeScreenProvider>();

    // Check if we should refresh the data
    if (homeScreenProvider.shouldRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final transactionDate = homeScreenProvider.transactionDate;
        if (transactionDate != null) {
          final newMonthIndex = _months.indexWhere((month) =>
              month.year == transactionDate.year &&
              month.month == transactionDate.month);

          if (newMonthIndex != -1) {
            // Clear current transactions before switching month
            setState(() {
              _transactionsWithAccounts = [];
              _selectedMonthIndex = newMonthIndex;
            });
            _scrollToSelectedMonth();
            await _refreshData();
          } else {
            await _refreshData();
          }
        } else {
          await _refreshData();
        }
        // Mark refresh as complete
        homeScreenProvider.completeRefresh();
      });
    }
    // Check for account-specific refresh
    else if (homeScreenProvider.shouldRefreshAccounts) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _refreshAccountData(); // Refresh account-related data
        // Mark refresh as complete
        homeScreenProvider.completeRefresh();
      });
    }
    // Check for transaction-specific refresh
    else if (homeScreenProvider.shouldRefreshTransactions) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _refreshData();
        homeScreenProvider.completeRefresh();
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          TweenAnimationBuilder<Color?>(
            tween: ColorTween(
              end: vacationProvider.isAiMode
                  ? AppColors.aiGradientStart
                  : AppColors.gradientStart,
            ),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            builder: (context, color, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color ?? AppColors.gradientStart,
                      AppColors.gradientEnd2,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.3, 1.0],
                  ),
                ),
                child: Column(
                  children: [
                    _buildAppBar(context),
                    _buildMonthSelector(),
                    _buildBalanceCards(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _months.length,
                        onPageChanged: (index) {
                          // Debounce loads to fire only after page settle/animation completion
                          _settleTimer?.cancel();
                          _settleTimer = Timer(const Duration(milliseconds: 150), () async {
                            if (!mounted) return;
                            if (index < 0 || index >= _months.length) return;
    
                            if (index != _selectedMonthIndex) {
                              setState(() {
                                _selectedMonthIndex = index;
                              });
                              _scrollToSelectedMonth();
                            }
    
                            // Avoid starting a second load for the same index
                            if (_loadingMonthIndex == index) return;
                            _loadingMonthIndex = index;
    
                            final isVacationMode =
                                Provider.of<VacationProvider>(context, listen: false).isVacationMode;
    
                            // Load data for the selected month (will use cache if available)
                            await _loadDataForCurrentMonth(isVacation: isVacationMode);
                            
                            // Preload surrounding months in background
                            _preloadSurroundingMonths(index);
                            
                            _loadingMonthIndex = null;
                          });
                        },
                        itemBuilder: (context, index) {
                          return _buildTransactionSectionContent(index);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final vacationProvider = context.watch<VacationProvider>();
    final currencyProvider = context.watch<CurrencyProvider>();
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      height:
          statusBarHeight +
          80, // Match the toolbarHeight from SliverAppBar plus status bar height
      padding: EdgeInsets.only(
        top: 20,
        left: 10,
        right: 6,
      ), // Match the padding from SliverAppBar plus status bar height
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: const ProfileScreen(),
                      withNavBar: false,
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    );
                  },
                  child: const CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage(
                      'images/backgrounds/onboarding1.png',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedMonthIndex < _months.length && _selectedMonthIndex >= 0 ? DateFormat('MMMM').format(_months[_selectedMonthIndex]) : 'Balance',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vacationProvider.isVacationMode
                          ? '${currencyProvider.currencySymbol} ${( -_totalExpenses * currencyProvider.conversionRate).toStringAsFixed(2)}'
                          : '${currencyProvider.currencySymbol} ${((_totalIncome - _totalExpenses) * currencyProvider.conversionRate).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAppBarButton(
                  HugeIcons.strokeRoundedAirplaneMode,
                  onPressed: () async {
                    if (vacationProvider.isVacationMode) {
                      // If vacation mode is active, deactivate it.
                      await Provider.of<VacationProvider>(context, listen: false).setVacationMode(false);
                    } else {
                      // If vacation mode is inactive, trigger the check and dialog flow.
                      await Provider.of<VacationProvider>(context, listen: false)
                          .checkAndShowVacationDialog(context);
                    }
                  },
                  isActive: vacationProvider.isVacationMode,
                ),
                _buildAppBarButton(
                  HugeIcons.strokeRoundedAnalytics02,
                  onPressed: () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: const AnalyticsScreen(),
                      withNavBar: false,
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    );
                  },
                ),
                _buildAppBarButton(
                  HugeIcons.strokeRoundedStar,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const FeedbackModal();
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarButton(
    List<List<dynamic>> icon, {
    VoidCallback? onPressed,
    bool isActive = false,
  }) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(left: 6),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.gradientEnd.withOpacity(0.7)
            : Colors.white.withOpacity(0.5),
        shape: BoxShape.circle,
        border: isActive
            ? Border.all(color: AppColors.gradientEnd, width: 2)
            : null,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: HugeIcon(icon: icon, color: Colors.black87, size: 22),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        controller: _monthScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _months.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          final month = _months[index];
          final isSelected = index == _selectedMonthIndex;
          return GestureDetector(
            onTap: () {
              // Animate PageController to selected month; actual data loads after scroll settles
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              width: 85,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.buttonBackground
                    : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  DateFormat('MMM yyyy').format(month),
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCards() {
    final currencyProvider = context.watch<CurrencyProvider>();
    final vacationProvider = context.watch<VacationProvider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          if (!vacationProvider.isVacationMode)
            Expanded(
              child: _buildInfoCard(
                'Income',
                '+ ${currencyProvider.currencySymbol}${(_totalIncome * currencyProvider.conversionRate).toStringAsFixed(2)}',
                Colors.green,
                HugeIcons.strokeRoundedChartUp,
                AppColors.incomeBackground,
              ),
            ),
          if (!vacationProvider.isVacationMode)
            const SizedBox(width: 12),
          Expanded(
            child: _buildInfoCard(
              'Expense',
              '- ${currencyProvider.currencySymbol}${(_totalExpenses * currencyProvider.conversionRate).toStringAsFixed(2)}',
              Colors.red,
              HugeIcons.strokeRoundedChartDown,
              AppColors.expenseBackground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String amount,
    Color color,
    List<List<dynamic>> icon,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          HugeIcon(icon: icon, color: color, size: 28),
        ],
      ),
    );
  }

  Widget _buildTransactionSection() {
    return SliverList(
      delegate: SliverChildListDelegate([_buildTransactionSectionContent(_selectedMonthIndex)]),
    );
  }

  Widget _buildTransactionSectionContent(int monthIndex) {
    final currencyProvider = context.watch<CurrencyProvider>();
    
    // Check if we have preloaded data for this month
    if (_pageDataMap.containsKey(monthIndex)) {
      final monthData = _pageDataMap[monthIndex]!;
      
      if (monthData.isLoading) {
        return _buildLoadingState();
      }
      
      if (monthData.error != null) {
        return _buildErrorState(monthData.error!);
      }
      
      return _buildContentWithData(monthData, currencyProvider);
    }
    
    // If no preloaded data, load it now but show shimmer immediately
    if (!_loadingIndices.contains(monthIndex)) {
      // Add to loading indices to prevent duplicate loads
      _loadingIndices.add(monthIndex);
      
      // Add loading state
      _pageDataMap[monthIndex] = MonthPageData.loading();
      
      // Load data in background
      _loadDataForMonth(_months[monthIndex], isVacation: Provider.of<VacationProvider>(context, listen: false).isVacationMode)
        .then((data) {
          if (mounted) {
            setState(() {
              _pageDataMap[monthIndex] = data;
              _loadingIndices.remove(monthIndex);
            });
          }
        })
        .catchError((error) {
          if (mounted) {
            setState(() {
              _pageDataMap[monthIndex] = MonthPageData.error(error.toString());
              _loadingIndices.remove(monthIndex);
            });
          }
        });
    }
    
    // Always show shimmer while loading
    return _buildLoadingState();
  }
  
  Widget _buildContentWithData(MonthPageData data, CurrencyProvider currencyProvider) {
    // If there are no transactions for the selected period, show an empty state.
    if (data.transactionsWithAccounts.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SizedBox(
          // Ensure the empty state fills available vertical space so it's centered nicely
          height: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 130.0),
            child: _buildEmptyState(),
          ),
        ),
      );
    }

    Map<String, List<TransactionWithAccount>> groupedTransactions = {};
    for (var tx in data.transactionsWithAccounts) {
      String dateKey = DateFormat('MMM d, yyyy').format(tx.transaction.date);
      if (groupedTransactions[dateKey] == null) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(tx);
    }
    List<String> sortedKeys = groupedTransactions.keys.toList()
      ..sort((a, b) {
        DateTime dateA = DateFormat('MMM d, yyyy').parse(a);
        DateTime dateB = DateFormat('MMM d, yyyy').parse(b);
        return dateA.compareTo(dateB);
      });

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            controller: _contentScrollController,
            padding: const EdgeInsets.only(top: 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    ...sortedKeys.map((date) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                            child: Text(
                              date.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          ...groupedTransactions[date]!.map(
                            (tx) => _buildTransactionItem(tx, currencyProvider),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 16),
                    _buildUpcomingTasksSectionWithData(data.upcomingTasks, currencyProvider),
                    const SizedBox(height: 70), // To avoid FAB overlap
                    // Fills remaining space when content is short
                    const SizedBox(height: 0),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildLoadingState() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          children: [
            // Shimmer for date header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 12,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            // Shimmer for transaction items
            ...List.generate(5, (index) => _buildTransactionShimmer()),
            const SizedBox(height: 16),
            // Shimmer for upcoming tasks section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 18,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTaskShimmer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTransactionShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Row(
          children: [
            // Icon placeholder
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 8),
            // Text placeholders
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 15,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    height: 12,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            // Amount placeholder
            Container(
              height: 15,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTaskShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Row(
          children: [
            // Icon placeholder
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 8),
            // Text placeholders
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 15,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    height: 12,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            // Amount placeholder
            Container(
              height: 15,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildErrorState(String error) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error loading data',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Empty state shown when there are no transactions for the selected period.
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'images/launcher/logo.png',
            width: 80,
            height: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions recorded for this period.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(TransactionWithAccount transactionWithAccount, CurrencyProvider currencyProvider) {
    final transaction = transactionWithAccount.transaction;
    final account = transactionWithAccount.account;
    final uiTransaction = _convertToUiTransaction(transaction, context, transactionWithAccount.category);

    return InkWell(
      onTap: () async {
        final result = await PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: ExpenseDetailScreen(transaction: uiTransaction),
          withNavBar: false,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );

        if (result == true) {
          _refreshData();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100, // Default color
                borderRadius: BorderRadius.circular(14),
              ),
              child: HugeIcon(icon: getIcon(transactionWithAccount.category?.icon), color: Colors.black87, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transactionWithAccount.category?.name ??
                        transaction
                            .description, // Use category name as title, fallback to description
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (account != null && !(account.isDefault ?? false))
                    Text(
                      [account.name, account.accountType]
                          .where((text) => text != null && text.isNotEmpty)
                          .join(' - '),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  transaction.paid == true ? Icons.check_circle : Icons.circle_outlined,
                  color: transaction.paid == true ? Colors.green : Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${transaction.type == 'income' ? '+' : '-'} ${currencyProvider.currencySymbol}${(transaction.amount * currencyProvider.conversionRate).toStringAsFixed(2)}',
                  style: TextStyle(
                    color: transaction.type == 'income' ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTasksSection() {
    final currencyProvider = context.watch<CurrencyProvider>();
    if (_upcomingTasks.isEmpty) {
      // Return a minimal height widget so the parent Column does not collapse
      return const SizedBox(height: 1);
    }

    return _buildUpcomingTasksSectionWithData(_upcomingTasks, currencyProvider);
  }
  
  Widget _buildUpcomingTasksSectionWithData(List<FirestoreTask> tasks, CurrencyProvider currencyProvider) {
    if (tasks.isEmpty) {
      // Return a minimal height widget so the parent Column does not collapse
      return const SizedBox(height: 1);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Tasks',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...tasks.map((task) => _buildTaskItem(task, currencyProvider)),
        ],
      ),
    );
  }

  Widget _buildTaskItem(FirestoreTask task, CurrencyProvider currencyProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: task.type == 'income'
                  ? AppColors.incomeBackground
                  : AppColors.expenseBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              task.type == 'income' ? Icons.trending_up : Icons.trending_down,
              color: task.type == 'income' ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMM d, yyyy').format(task.dueDate),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${task.type == 'income' ? '+' : '-'} ${currencyProvider.currencySymbol}${(task.amount * currencyProvider.conversionRate).toStringAsFixed(2)}',
            style: TextStyle(
              color: task.type == 'income' ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}