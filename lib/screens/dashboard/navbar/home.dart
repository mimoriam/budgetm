
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
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budgetm/utils/icon_utils.dart';
import 'package:budgetm/utils/appTheme.dart';
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

// Helper class to pass stream parameters
class MonthStreamParams {
  final int monthIndex;
  final bool isVacation;
  final int refreshTrigger;

  MonthStreamParams({
    required this.monthIndex,
    required this.isVacation,
    required this.refreshTrigger,
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

// Data manager for handling and caching month-specific data streams.
class MonthPageDataManager {
  final FirestoreService _firestoreService = FirestoreService.instance;

  // Streams for data that is constant across all months.
  // shareReplay(maxSize: 1) caches the last emitted value and shares it with new subscribers,
  // preventing redundant database calls.
  late final Stream<List<FirestoreAccount>> _allAccountsStream;
  late final Stream<List<Category>> _allCategoriesStream;

  // A cache to hold the data stream for each month index.
  final Map<int, Stream<MonthPageData>> _pageStreamCache = {};

  MonthPageDataManager() {
    // Initialize the shared streams immediately.
    _allAccountsStream = _firestoreService.streamAccounts().shareReplay(maxSize: 1);
    _allCategoriesStream = _firestoreService.streamCategories().shareReplay(maxSize: 1);
  }

  Stream<MonthPageData> getStreamForMonth(int monthIndex, DateTime month, bool isVacation) {
    // If a stream for this month is already in the cache, return it.
    if (_pageStreamCache.containsKey(monthIndex)) {
      print('DEBUG: Using cached stream for month index $monthIndex');
      return _pageStreamCache[monthIndex]!;
    }

    print('DEBUG: Creating new stream for month index $monthIndex, isVacation: $isVacation');
    
    // If not cached, create a new stream for the month.
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final stream = Rx.combineLatest4(
      _firestoreService.streamTransactionsForDateRange(startOfMonth, endOfMonth, isVacation: isVacation),
      _firestoreService.streamUpcomingTasksForDateRange(startOfMonth, endOfMonth),
      _allAccountsStream, // <-- Use the shared/replayed stream
      _allCategoriesStream, // <-- Use the shared/replayed stream
      (
        List<FirestoreTransaction> transactions,
        List<FirestoreTask> tasks,
        List<FirestoreAccount> accounts,
        List<Category> categories,
      ) {
        print('DEBUG: Stream data received for month index $monthIndex - transactions: ${transactions.length}, tasks: ${tasks.length}');
        
        // Sort transactions by date in descending order (newest first)
        transactions.sort((a, b) => b.date.compareTo(a.date));

        // Create maps for accounts and categories
        final accountMap = {for (var account in accounts) account.id: account};
        final categoryMap = {for (var category in categories) category.id: category};

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
        
        // Sort transactions within each date group by time in descending order
        transactionsWithAccounts.sort((a, b) => b.transaction.date.compareTo(a.transaction.date));

        // Calculate totals client-side
        double totalIncome = 0.0;
        double totalExpenses = 0.0;
        for (final transaction in transactions) {
          if (transaction.type == 'income') {
            totalIncome += transaction.amount;
          } else if (transaction.type == 'expense') {
            totalExpenses += transaction.amount;
          }
        }

        return MonthPageData(
          transactions: transactions,
          totalIncome: totalIncome,
          totalExpenses: totalExpenses,
          transactionsWithAccounts: transactionsWithAccounts,
          upcomingTasks: tasks,
        );
      },
    )
    .startWith(MonthPageData.loading()) // Immediately emit a loading state.
    .handleError((error) {
      print('DEBUG: Error in stream for month index $monthIndex: $error');
      return MonthPageData.error(error.toString());
    })
    .shareReplay(maxSize: 1); // Cache the result of this month's stream.

    // Store the newly created stream in the cache and return it.
    _pageStreamCache[monthIndex] = stream;
    return stream;
  }

  // Method to clear the cache if a full refresh is needed (e.g., on user logout/login).
  void clearCache() {
    print('DEBUG: Clearing stream cache, had ${_pageStreamCache.length} cached streams');
    _pageStreamCache.clear();
  }
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
  late final MonthPageDataManager _pageDataManager;
  List<DateTime> _months = [];
  int _selectedMonthIndex = 0;
  
  bool _isTogglingVacationMode = false;
  
  double _lastContentOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService.instance;
    _pageDataManager = MonthPageDataManager();
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
    WidgetsBinding.instance.addObserver(this);
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
    // Data refresh is now handled by other mechanisms
    // such as explicit user actions or navigation events
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
        
        // Update the selected date in HomeScreenProvider
        if (_selectedMonthIndex >= 0 && _selectedMonthIndex < _months.length) {
          final homeScreenProvider = Provider.of<HomeScreenProvider>(context, listen: false);
          homeScreenProvider.setSelectedDate(_months[_selectedMonthIndex]);
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
      print('DEBUG: HomeScreenProvider.shouldRefresh triggered');
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final transactionDate = homeScreenProvider.transactionDate;
        if (transactionDate != null) {
          final newMonthIndex = _months.indexWhere((month) =>
              month.year == transactionDate.year &&
              month.month == transactionDate.month);

          if (newMonthIndex != -1 && newMonthIndex != _selectedMonthIndex) {
            print('DEBUG: Switching to month index $newMonthIndex for new transaction');
            setState(() {
              _selectedMonthIndex = newMonthIndex;
            });
            _scrollToSelectedMonth();
          }
        }
        // Clear cache to force a refresh
        _pageDataManager.clearCache();
        // Mark refresh as complete
        homeScreenProvider.completeRefresh();
        // Trigger a rebuild
        if (mounted) setState(() {});
      });
    }
    // Check for account-specific refresh
    else if (homeScreenProvider.shouldRefreshAccounts) {
      print('DEBUG: HomeScreenProvider.shouldRefreshAccounts triggered');
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _pageDataManager.clearCache();
        homeScreenProvider.completeRefresh();
        if (mounted) setState(() {});
      });
    }
    // Check for transaction-specific refresh
    else if (homeScreenProvider.shouldRefreshTransactions) {
      print('DEBUG: HomeScreenProvider.shouldRefreshTransactions triggered');
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _pageDataManager.clearCache();
        homeScreenProvider.completeRefresh();
        if (mounted) setState(() {});
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
                         if (!mounted) return;
                         if (index < 0 || index >= _months.length) return;

                         setState(() {
                           _selectedMonthIndex = index;
                         });
                         
                         // Update the selected date in HomeScreenProvider
                         final homeScreenProvider = Provider.of<HomeScreenProvider>(context, listen: false);
                         homeScreenProvider.setSelectedDate(_months[index]);
                         
                         _scrollToSelectedMonth();

                         // Pre-load adjacent months
                          final isVacation = Provider.of<VacationProvider>(context, listen: false).isVacationMode;
                          print('DEBUG: Pre-loading adjacent months for index $index');
                          if (index + 1 < _months.length) {
                            print('DEBUG: Pre-loading next month index ${index + 1}');
                            _pageDataManager.getStreamForMonth(index + 1, _months[index + 1], isVacation);
                          }
                          if (index - 1 >= 0) {
                            print('DEBUG: Pre-loading previous month index ${index - 1}');
                            _pageDataManager.getStreamForMonth(index - 1, _months[index - 1], isVacation);
                          }
                        },
                        itemBuilder: (context, index) {
                          final isVacation = Provider.of<VacationProvider>(context, listen: false).isVacationMode;
                          return StreamBuilder<MonthPageData>(
                            stream: _pageDataManager.getStreamForMonth(index, _months[index], isVacation),
                            builder: (context, snapshot) {
                              final currencyProvider = context.watch<CurrencyProvider>();
                              
                              // DEBUG: Log loading state changes
                              print('DEBUG: StreamBuilder for month index $index - hasData: ${snapshot.hasData}, isLoading: ${snapshot.data?.isLoading}, error: ${snapshot.error}');
                              
                              // Check connection state and data availability
                              if (snapshot.connectionState == ConnectionState.waiting ||
                                  !snapshot.hasData ||
                                  (snapshot.hasData && snapshot.data!.isLoading)) {
                                // Show shimmer loading effect when waiting for data or when data is loading
                                print('DEBUG: Showing loading state for month index $index');
                                return _buildLoadingState();
                              } else if (snapshot.hasError) {
                                // Show error state if there's an error
                                print('DEBUG: Showing error state for month index $index: ${snapshot.error}');
                                return _buildErrorState(snapshot.error.toString());
                              } else {
                                // Pass the loaded data to the content widget
                                print('DEBUG: Building content for month index $index with ${snapshot.data!.transactions.length} transactions');
                                return _buildContentWithData(snapshot.data!, currencyProvider);
                              }
                            },
                          );
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
    final isVacation = vacationProvider.isVacationMode;
    
    return StreamBuilder<MonthPageData>(
      stream: _selectedMonthIndex >= 0 && _selectedMonthIndex < _months.length
          ? _pageDataManager.getStreamForMonth(_selectedMonthIndex, _months[_selectedMonthIndex], isVacation)
          : Stream.value(MonthPageData.loading()),
      builder: (context, snapshot) {
        final totalIncome = snapshot.data?.totalIncome ?? 0.0;
        final totalExpenses = snapshot.data?.totalExpenses ?? 0.0;

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
                              ? '${currencyProvider.currencySymbol} ${( -totalExpenses * currencyProvider.conversionRate).toStringAsFixed(2)}'
                              : '${currencyProvider.currencySymbol} ${((totalIncome - totalExpenses) * currencyProvider.conversionRate).toStringAsFixed(2)}',
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
                        final currentVacationMode = vacationProvider.isVacationMode;
                        if (currentVacationMode) {
                          // If vacation mode is active, deactivate it.
                          await Provider.of<VacationProvider>(context, listen: false).setVacationMode(false);
                        } else {
                          // If vacation mode is inactive, trigger the check and dialog flow.
                          await Provider.of<VacationProvider>(context, listen: false)
                              .checkAndShowVacationDialog(context);
                        }
                        
                        // After toggling vacation mode, clear the cache to force a refresh
                        print('DEBUG: Vacation mode toggled from $currentVacationMode to ${!currentVacationMode}, clearing cache');
                        _pageDataManager.clearCache();
                        // Trigger a rebuild to pick up the new data
                        if (mounted) setState(() {});
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
    final isVacation = vacationProvider.isVacationMode;

    return StreamBuilder<MonthPageData>(
      stream: _selectedMonthIndex >= 0 && _selectedMonthIndex < _months.length
          ? _pageDataManager.getStreamForMonth(_selectedMonthIndex, _months[_selectedMonthIndex], isVacation)
          : Stream.value(MonthPageData.loading()),
      builder: (context, snapshot) {
        final totalIncome = snapshot.data?.totalIncome ?? 0.0;
        final totalExpenses = snapshot.data?.totalExpenses ?? 0.0;
        
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              if (!vacationProvider.isVacationMode)
                Expanded(
                  child: _buildInfoCard(
                    'Income',
                    '+ ${currencyProvider.currencySymbol}${(totalIncome * currencyProvider.conversionRate).toStringAsFixed(2)}',
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
                  '- ${currencyProvider.currencySymbol}${(totalExpenses * currencyProvider.conversionRate).toStringAsFixed(2)}',
                  Colors.red,
                  HugeIcons.strokeRoundedChartDown,
                  AppColors.expenseBackground,
                ),
              ),
            ],
          ),
        );
      }
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
        return dateB.compareTo(dateA); // Sort dates in descending order (newest first)
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
    
    // Get the icon color from the transaction, fallback to default if null
    final Color iconBackgroundColor = hexToColor(transaction.icon_color);
    final Color iconForegroundColor = getContrastingColor(iconBackgroundColor);

    return InkWell(
      onTap: () async {
        final result = await PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: ExpenseDetailScreen(transaction: uiTransaction),
          withNavBar: false,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );

        if (result == true) {
          _pageDataManager.clearCache();
          if (mounted) setState(() {});
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
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: HugeIcon(icon: getIcon(transactionWithAccount.category?.icon), color: iconForegroundColor, size: 20),
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