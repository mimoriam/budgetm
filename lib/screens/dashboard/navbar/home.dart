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
import 'package:budgetm/viewmodels/vacation_mode_provider.dart';
import 'package:budgetm/viewmodels/home_screen_provider.dart';
import 'package:budgetm/viewmodels/navbar_visibility_provider.dart';
import 'package:budgetm/viewmodels/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
model.Transaction _convertToUiTransaction(FirestoreTransaction firestoreTransaction) {
  return model.Transaction(
    id: firestoreTransaction.id, // ID is already String in Firestore
    title: firestoreTransaction.description,
    description: firestoreTransaction.description,
    amount: firestoreTransaction.amount,
    type: firestoreTransaction.type == 'income'
        ? TransactionType.income
        : TransactionType.expense,
    date: firestoreTransaction.date,
    icon: const Icon(Icons.account_balance), // Default icon
    iconBackgroundColor: Colors.grey.shade100, // Default color
    accountId: firestoreTransaction.accountId, // Pass accountId from Firestore transaction
    categoryId: firestoreTransaction.categoryId, // Already String in Firestore
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
  late FirestoreService _firestoreService;
  List<DateTime> _months = [];
  int _selectedMonthIndex = 0;

  List<FirestoreTransaction> _transactions = [];
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  List<TransactionWithAccount> _transactionsWithAccounts = [];
  List<FirestoreTask> _upcomingTasks = [];
  bool? _previousVacationMode;

  double _lastContentOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService.instance;
    _monthScrollController = ScrollController();
    _contentScrollController = ScrollController();
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
      final isVacationMode =
          Provider.of<VacationProvider>(context, listen: false).isVacationMode;
      _previousVacationMode = isVacationMode;
      _loadIncomeAndExpenses(isVacation: isVacationMode);
      _loadCurrentMonthTransactions(isVacation: isVacationMode);
      _loadUpcomingTasks();
    });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _monthScrollController.dispose();
    _contentScrollController.dispose();
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
      _refreshData();
    }
    // Update previous state for future comparisons
    _previousVacationMode = currentVacationMode;
  }

  Future<void> _refreshData() async {
    final isVacationMode =
        Provider.of<VacationProvider>(context, listen: false).isVacationMode;
    await _loadIncomeAndExpensesForMonth(
      _months[_selectedMonthIndex],
      isVacation: isVacationMode,
    );
    await _loadTransactionsForMonth(
      _months[_selectedMonthIndex],
      isVacation: isVacationMode,
    );
    await _loadUpcomingTasksForMonth(_months[_selectedMonthIndex]);
  }

  Future<void> _refreshAccountData() async {
    final isVacationMode =
        Provider.of<VacationProvider>(context, listen: false).isVacationMode;
    await _loadIncomeAndExpenses(isVacation: isVacationMode);
    // Add any other account-specific data loading if necessary
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
    });
  }


  Future<void> _loadIncomeAndExpenses({required bool isVacation}) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0).add(const Duration(days: 1));
  
      // Get income and expense totals using Firestore helper method
      final totals = await _firestoreService.getIncomeAndExpensesForDateRange(
        startOfMonth,
        endOfMonth,
        isVacation: isVacation,
      );
  
      setState(() {
        _totalIncome = totals['income'] ?? 0.0;
        _totalExpenses = totals['expenses'] ?? 0.0;
      });
    } catch (e) {
      print('Error loading income and expenses: $e');
      setState(() {
        _totalIncome = 0.0;
        _totalExpenses = 0.0;
      });
    }
  }

  Future<void> _loadCurrentMonthTransactions({required bool isVacation}) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 1);
  
      // Get transactions for current month
      final transactions = await _firestoreService.getTransactionsForDateRange(
        startOfMonth,
        endOfMonth,
        isVacation: isVacation,
      );
      transactions.sort((a, b) => a.date.compareTo(b.date));
  
      // Load all accounts for mapping
      final accounts = await _firestoreService.getAllAccounts();
      final accountMap = {for (var account in accounts) account.id: account};
  
      // Load all categories for mapping
      final categories = await _firestoreService.getAllCategories();
      final categoryMap = {
        for (var category in categories) category.id: category,
      };
  
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
  
      setState(() {
        _transactions = transactions;
        _transactionsWithAccounts = transactionsWithAccounts;
      });
    } catch (e) {
      print('Error loading current month transactions: $e');
    }
  }

  Future<void> _loadUpcomingTasks() async {
    try {
      final now = DateTime.now();
      final endOfMonth = DateTime(now.year, now.month + 1, 0).add(const Duration(days: 1));

      // Get upcoming tasks using Firestore helper method
      final tasks = await _firestoreService.getUpcomingTasksForDateRange(now, endOfMonth);

      setState(() {
        _upcomingTasks = tasks;
      });
    } catch (e) {
      print('Error loading upcoming tasks: $e');
    }
  }

  Future<void> _loadIncomeAndExpensesForMonth(
    DateTime month, {
    required bool isVacation,
  }) async {
    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0).add(const Duration(days: 1));
  
      // Get income and expense totals using Firestore helper method
      final totals = await _firestoreService.getIncomeAndExpensesForDateRange(
        startOfMonth,
        endOfMonth,
        isVacation: isVacation,
      );
  
      setState(() {
        _totalIncome = totals['income'] ?? 0.0;
        _totalExpenses = totals['expenses'] ?? 0.0;
      });
    } catch (e) {
      print('Error loading income and expenses for month: $e');
      setState(() {
        _totalIncome = 0.0;
        _totalExpenses = 0.0;
      });
    }
  }

  Future<void> _loadTransactionsForMonth(DateTime month,
      {required bool isVacation}) async {
    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 1);
  
      // Get transactions for the specified month
      final transactions = await _firestoreService.getTransactionsForDateRange(
        startOfMonth,
        endOfMonth,
        isVacation: isVacation,
      );
      transactions.sort((a, b) => a.date.compareTo(b.date));
  
      // Load all accounts for mapping
      final accounts = await _firestoreService.getAllAccounts();
      final accountMap = {for (var account in accounts) account.id: account};
  
      // Load all categories for mapping
      final categories = await _firestoreService.getAllCategories();
      final categoryMap = {
        for (var category in categories) category.id: category,
      };
  
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
  
      setState(() {
        _transactions = transactions;
        _transactionsWithAccounts = transactionsWithAccounts;
      });
    } catch (e) {
      print('Error loading transactions for month: $e');
    }
  }

  Future<void> _loadUpcomingTasksForMonth(DateTime month) async {
    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0).add(const Duration(days: 1));

      // Get upcoming tasks for the specified month using Firestore helper method
      final tasks = await _firestoreService.getUpcomingTasksForDateRange(startOfMonth, endOfMonth);

      setState(() {
        _upcomingTasks = tasks;
      });
    } catch (e) {
      print('Error loading upcoming tasks for month: $e');
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
    // SystemChrome.setSystemUIOverlayStyle(
    //   SystemUiOverlayStyle(statusBarColor: Colors.red, statusBarIconBrightness: Brightness.dark),
    // );
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
        final isVacationMode = vacationProvider.isVacationMode;
        await _refreshAccountData(); // Refresh account-related data
        // Re-filter transactions for the currently selected month after account changes
        if (_months.isNotEmpty &&
            _selectedMonthIndex >= 0 &&
            _selectedMonthIndex < _months.length) {
          await _loadTransactionsForMonth(
            _months[_selectedMonthIndex],
            isVacation: isVacationMode,
          );
        }
        // Mark refresh as complete
        homeScreenProvider.completeRefresh();
      });
    }

    return Scaffold(
      body: TweenAnimationBuilder<Color?>(
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
                Expanded(child: _buildTransactionSectionContent()),
              ],
            ),
          );
        },
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
                      '${currencyProvider.currencySymbol} ${(( _totalIncome - _totalExpenses ) * currencyProvider.conversionRate).toStringAsFixed(2)}',
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
                  onPressed: Provider.of<VacationProvider>(
                    context,
                    listen: false,
                  ).toggleAiMode,
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
        onPressed: onPressed ?? () {},
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
              setState(() {
                _selectedMonthIndex = index;
              });
              final isVacationMode =
                  Provider.of<VacationProvider>(context, listen: false)
                      .isVacationMode;
              _loadIncomeAndExpensesForMonth(
                _months[index],
                isVacation: isVacationMode,
              );
              _loadTransactionsForMonth(
                _months[index],
                isVacation: isVacationMode,
              );
              _loadUpcomingTasksForMonth(_months[index]);
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoCard(
              'Income',
              '+ ${currencyProvider.currencySymbol}${(_totalIncome * currencyProvider.conversionRate).toStringAsFixed(2)}',
              Colors.green,
              HugeIcons.strokeRoundedChartUp,
              AppColors.incomeBackground,
            ),
          ),
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
      delegate: SliverChildListDelegate([_buildTransactionSectionContent()]),
    );
  }

  Widget _buildTransactionSectionContent() {
    final currencyProvider = context.watch<CurrencyProvider>();
    Map<String, List<TransactionWithAccount>> groupedTransactions = {};
    for (var tx in _transactionsWithAccounts) {
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
                    _buildUpcomingTasksSection(),
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

  Widget _buildTransactionItem(TransactionWithAccount transactionWithAccount, CurrencyProvider currencyProvider) {
    final transaction = transactionWithAccount.transaction;
    final account = transactionWithAccount.account;
    final uiTransaction = _convertToUiTransaction(transaction);

    return InkWell(
      onTap: () async {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) =>
        //         ExpenseDetailScreen(transaction: uiTransaction),
        //   ),
        // );
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
              child: const Icon(Icons.account_balance), // Default icon
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
                  Text(
                    // "${account?.name ?? ''} - ${account?.accountType ?? ''}", // Only display account name
                    [account?.name, account?.accountType]
                        .where((text) => text != null && text.isNotEmpty)
                        .join(' - '),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
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
      ),
    );
  }

  Widget _buildUpcomingTasksSection() {
    final currencyProvider = context.watch<CurrencyProvider>();
    if (_upcomingTasks.isEmpty) {
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
          ..._upcomingTasks.map((task) => _buildTaskItem(task, currencyProvider)),
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
