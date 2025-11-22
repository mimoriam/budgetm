import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/generated/i18n/app_localizations.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/models/firestore_transaction.dart';
import 'package:budgetm/models/firestore_task.dart';
import 'package:budgetm/models/firestore_account.dart';
import 'package:budgetm/models/category.dart';
import 'package:budgetm/models/transaction.dart' as model;
import 'package:budgetm/constants/transaction_type_enum.dart';
import 'package:budgetm/screens/dashboard/navbar/home/analytics/analytics_screen.dart';
import 'package:budgetm/screens/dashboard/navbar/home/expense_detail/expense_detail_screen.dart';
import 'package:budgetm/screens/dashboard/profile/profile_screen.dart';
import 'package:budgetm/viewmodels/vacation_mode_provider.dart';
import 'package:budgetm/viewmodels/home_screen_provider.dart';
import 'package:budgetm/viewmodels/currency_provider.dart';
import 'package:budgetm/viewmodels/navbar_visibility_provider.dart';
import 'package:budgetm/viewmodels/subscription_provider.dart';
import 'package:budgetm/screens/paywall/paywall_screen.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budgetm/utils/icon_utils.dart';
import 'package:budgetm/utils/appTheme.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Data structure to hold all data for a specific month page
class MonthPageData {
  final List<FirestoreTransaction> transactions;
  final double totalIncome;
  final double totalExpenses;
  final List<TransactionWithAccount> transactionsWithAccounts;
  final List<FirestoreTask> upcomingTasks;
  final bool isLoading;
  final String? error;
  final Map<String, double> incomeByCurrency;
  final Map<String, double> expensesByCurrency;

  MonthPageData({
    required this.transactions,
    required this.totalIncome,
    required this.totalExpenses,
    required this.transactionsWithAccounts,
    required this.upcomingTasks,
    required this.incomeByCurrency,
    required this.expensesByCurrency,
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
        incomeByCurrency: {},
        expensesByCurrency: {},
        isLoading: true,
      );

  // Create an error state
  factory MonthPageData.error(String error) => MonthPageData(
        transactions: [],
        totalIncome: 0.0,
        totalExpenses: 0.0,
        transactionsWithAccounts: [],
        upcomingTasks: [],
        incomeByCurrency: {},
        expensesByCurrency: {},
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
model.Transaction _convertToUiTransaction(
  FirestoreTransaction firestoreTransaction,
  BuildContext context, [
  Category? category,
]) {
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
    icon: HugeIcon(
      icon: getIcon(category?.icon),
      color: Colors.black87,
      size: 20,
    ),
    iconBackgroundColor: Colors.grey.shade100, // Default color
    accountId: firestoreTransaction
        .accountId, // Pass accountId from Firestore transaction
    categoryId: firestoreTransaction.categoryId, // Already String in Firestore
    paid: firestoreTransaction.paid, // CRITICAL: carry paid flag into UI model
    currency: firestoreTransaction.currency, // Use the actual currency from the transaction
  );
}

// Provider for managing state for a single month's page
class MonthPageProvider extends ChangeNotifier {
  List<TransactionWithAccount> _allTransactions = [];
  List<TransactionWithAccount> _paginatedTransactions = [];
  bool _isLoading = false;
  String _error = '';
  static const int _pageSize = 20;
  int _currentPage = 0;
  bool _hasReachedEnd = false;
  String _lastDataHash = ''; // Track the last data hash to detect changes
  bool _isInitialized =
      false; // Track if provider has been initialized at least once

  // Getters
  List<TransactionWithAccount> get allTransactions => _allTransactions;
  List<TransactionWithAccount> get paginatedTransactions =>
      _paginatedTransactions;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasReachedEnd => _hasReachedEnd;
  bool get isInitialized => _isInitialized;

  // Initialize with data from MonthPageData
  void initialize(MonthPageData data) {
    if (data.error != null) {
      _error = data.error!;
      notifyListeners();
      return;
    }

    // Create a hash of transaction IDs AND paid status to detect if data has actually changed
    final currentDataHash = data.transactionsWithAccounts
        .map((tx) => '${tx.transaction.id}:${tx.transaction.paid}')
        .join(',')
        .hashCode
        .toString();
    // DEBUG logging: hash and transaction IDs for initialization path
    try {
      final sampleIds = data.transactionsWithAccounts
          .map((tx) => '${tx.transaction.id}:${tx.transaction.paid}')
          .take(8)
          .toList();
      print(
          'DEBUG: MonthPageProvider.initialize - txWithAccounts=${data.transactionsWithAccounts.length}, newHash=$currentDataHash, lastHash=$_lastDataHash, isInitialized=$_isInitialized, hasReachedEnd=$_hasReachedEnd, currentPage=$_currentPage, sampleIds=$sampleIds');
    } catch (e) {
      print('DEBUG: MonthPageProvider.initialize - logging error: $e');
    }

    // Always reset state if this is the first initialization or if data has changed
    if (!_isInitialized || currentDataHash != _lastDataHash) {
      print('DEBUG: MonthPageProvider.initialize - RESETTING STATE: isInitialized=$_isInitialized, hashChanged=${currentDataHash != _lastDataHash}');
      _allTransactions = data.transactionsWithAccounts;
      _paginatedTransactions = [];
      _currentPage = 0;
      _hasReachedEnd = false;
      _error = '';
      _lastDataHash = currentDataHash;
      _isInitialized = true;

      // Load first page only if we have transactions
      if (_allTransactions.isNotEmpty) {
        fetchNextPage();
      }
    } else {
      print('DEBUG: MonthPageProvider.initialize - SKIPPING RESET: isInitialized=$_isInitialized, hashChanged=${currentDataHash != _lastDataHash}');
    }
  }

  // Force re-initialization (used when filter changes)
  void forceReinitialize(MonthPageData data) {
    print('DEBUG: MonthPageProvider.forceReinitialize - forcing complete reset');
    _allTransactions = data.transactionsWithAccounts;
    _paginatedTransactions = [];
    _currentPage = 0;
    _hasReachedEnd = false;
    _error = '';
    _lastDataHash = data.transactionsWithAccounts
        .map((tx) => '${tx.transaction.id}:${tx.transaction.paid}')
        .join(',')
        .hashCode
        .toString();
    _isInitialized = true;

    // Load first page only if we have transactions
    if (_allTransactions.isNotEmpty) {
      fetchNextPage();
    }
    notifyListeners();
  }

  // Clear all data and reset state (used when filter changes)
  void clearAllData() {
    print('DEBUG: MonthPageProvider.clearAllData - clearing all data');
    _allTransactions = [];
    _paginatedTransactions = [];
    _currentPage = 0;
    _hasReachedEnd = false;
    _error = '';
    _lastDataHash = '';
    _isInitialized = false;
    notifyListeners();
  }

  // Force complete reset and re-initialization (used when filter changes)
  void forceReset() {
    print('DEBUG: MonthPageProvider.forceReset - forcing complete reset');
    _allTransactions = [];
    _paginatedTransactions = [];
    _currentPage = 0;
    _hasReachedEnd = false;
    _error = '';
    _lastDataHash = '';
    _isInitialized = false;
    _isLoading = false;
    notifyListeners();
  }

  // Fetch next page of transactions
  Future<void> fetchNextPage() async {
    if (_isLoading || _hasReachedEnd || _allTransactions.isEmpty) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Calculate start and end indices for the current page
      final startIndex = _currentPage * _pageSize;
      final endIndex = math.min(
        startIndex + _pageSize,
        _allTransactions.length,
      );

      // Check if we've reached the end
      if (startIndex >= _allTransactions.length) {
        _isLoading = false;
        _hasReachedEnd = true;
        notifyListeners();
        return;
      }

      // Get the next page of transactions
      final nextPageItems = _allTransactions.sublist(startIndex, endIndex);

      // Simulate network delay for better UX (optional)
      await Future.delayed(const Duration(milliseconds: 300));

      _paginatedTransactions.addAll(nextPageItems);
      _currentPage++;
      _isLoading = false;

      // Check if we've reached the end
      if (endIndex >= _allTransactions.length) {
        _hasReachedEnd = true;
      }

      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Retry fetching after an error
  Future<void> retryFetch() async {
    _error = '';
    notifyListeners();
    await fetchNextPage();
  }

  // Reset the provider state
  void reset() {
    _allTransactions = [];
    _paginatedTransactions = [];
    _isLoading = false;
    _error = '';
    _currentPage = 0;
    _hasReachedEnd = false;
    _lastDataHash = ''; // Reset the data hash when resetting
    _isInitialized = false; // Reset initialization state
    print('DEBUG: MonthPageProvider.reset() - Provider state completely reset');
    notifyListeners();
  }

}

// Data manager for handling and caching month-specific data streams.
class MonthPageDataManager {
  final FirestoreService _firestoreService = FirestoreService.instance;
  final VacationProvider _vacationProvider;

  MonthPageDataManager(this._vacationProvider);

  Stream<MonthPageData> getStreamForMonth(
    int monthIndex,
    DateTime month,
    bool isVacation,
    bool includeVacationTransactions,
  ) {
    // Get the active vacation account ID when in vacation mode
    final activeVacationAccountId =
        isVacation ? _vacationProvider.activeVacationAccountId : null;

    print(
        'DEBUG: getStreamForMonth - monthIndex=$monthIndex, isVacation=$isVacation, accountId=$activeVacationAccountId, includeVacation=$includeVacationTransactions');

    // Create a new stream for the month.
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    // For vacation mode, fetch only vacation transactions
    // For normal mode, fetch normal transactions and optionally vacation transactions based on filter
    final Stream<List<FirestoreTransaction>> transactionStream = isVacation
        ? _firestoreService.streamTransactionsForDateRange(
            startOfMonth,
            endOfMonth,
            isVacation: true,
            accountId: activeVacationAccountId,
          )
        : (includeVacationTransactions
            ? Rx.combineLatest2(
                _firestoreService.streamTransactionsForDateRange(
                  startOfMonth,
                  endOfMonth,
                  isVacation: false,
                ),
                _firestoreService.streamTransactionsForDateRange(
                  startOfMonth,
                  endOfMonth,
                  isVacation: true,
                ),
                (List<FirestoreTransaction> normalTxns,
                    List<FirestoreTransaction> vacationTxns) {
                  // Combine both normal and vacation transactions
                  return [...normalTxns, ...vacationTxns];
                },
              )
            : _firestoreService.streamTransactionsForDateRange(
                startOfMonth,
                endOfMonth,
                isVacation: false,
              ));

    final stream = Rx.combineLatest4(
      transactionStream,
      _firestoreService.streamUpcomingTasksForDateRange(
        startOfMonth,
        endOfMonth,
      ),
      _firestoreService.streamAccounts(), // Fresh stream each time
      _firestoreService.streamCategories(), // Fresh stream each time
      (
        List<FirestoreTransaction> transactions,
        List<FirestoreTask> tasks,
        List<FirestoreAccount> accounts,
        List<Category> categories,
      ) {
        // Sort transactions by date in descending order (newest first)
        transactions.sort((a, b) => b.date.compareTo(a.date));

        // Create maps for accounts and categories
        final accountMap = {
          for (var account in accounts) account.id: account,
        };
        final categoryMap = {
          for (var category in categories) category.id: category,
        };

        // Create TransactionWithAccount objects
        final transactionsWithAccounts = transactions.map((
          transaction,
        ) {
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
        transactionsWithAccounts.sort(
          (a, b) => b.transaction.date.compareTo(a.transaction.date),
        );

        // Calculate totals client-side.
        // The 'paid' status of a transaction is for informational purposes only and does not
        // affect the calculation of total income and expenses. All transactions, paid or unpaid,
        // are included in these totals.
        // IMPORTANT: Only include transactions that match the current mode (vacation vs normal)
        final totalIncome = transactions
            .where((transaction) => transaction.type == 'income')
            .fold<double>(
                0.0, (sum, transaction) => sum + transaction.amount);

        final totalExpenses = transactions
            .where((transaction) => transaction.type == 'expense')
            .fold<double>(
                0.0, (sum, transaction) => sum + transaction.amount);

        // Group transactions by currency and calculate totals for each currency
        final Map<String, double> incomeByCurrency = {};
        final Map<String, double> expensesByCurrency = {};

        for (final transaction in transactions) {
          final currency = transaction.currency;
          if (currency.isEmpty) continue;

          if (transaction.type == 'income') {
            incomeByCurrency[currency] =
                (incomeByCurrency[currency] ?? 0.0) + transaction.amount;
          } else if (transaction.type == 'expense') {
            expensesByCurrency[currency] =
                (expensesByCurrency[currency] ?? 0.0) + transaction.amount;
          }
        }

        // DEBUG: emit stats before returning MonthPageData to validate stream updates
        try {
          final linkedCount = transactions
              .where((transaction) => transaction.linkedTransactionId != null)
              .length;
          final vacationCount =
              transactions.where((transaction) => transaction.isVacation == true).length;
          final normalCount =
              transactions.where((transaction) => transaction.isVacation != true).length;
          final sampleIds = transactions.map((t) => t.id).take(6).toList();
          print(
              'DEBUG: MonthPageDataManager.combine - monthIndex=$monthIndex, isVacation=$isVacation, accountId=$activeVacationAccountId, txCount=${transactions.length}, normalCount=$normalCount, vacationCount=$vacationCount, linkedCount=$linkedCount, totalIncome=$totalIncome, totalExpenses=$totalExpenses, sampleIds=$sampleIds');
        } catch (e) {
          print('DEBUG: MonthPageDataManager.combine - logging error: $e');
        }

        return MonthPageData(
          transactions: transactions,
          totalIncome: totalIncome,
          totalExpenses: totalExpenses,
          transactionsWithAccounts: transactionsWithAccounts,
          upcomingTasks: tasks,
          incomeByCurrency: incomeByCurrency,
          expensesByCurrency: expensesByCurrency,
        );
      },
    )
        .startWith(
          MonthPageData.loading(),
        ) // Immediately emit a loading state.
        .handleError((error) {
      return MonthPageData.error(error.toString());
    });

    return stream;
  }

  // Vacation mode: all currencies across all time, ignoring months
  Stream<MonthPageData> getVacationAllCurrenciesStream() {
    final isVacation = true;
    final activeVacationAccountId = _vacationProvider.activeVacationAccountId;

    print(
        'DEBUG: Creating vacation all currencies stream for accountId=$activeVacationAccountId');

    final stream = Rx.combineLatest3(
      _firestoreService.streamTransactionsForDateRange(
        DateTime(2020, 1, 1), // Start from beginning
        DateTime(2100, 12, 31), // End far in future
        isVacation: isVacation,
        accountId: activeVacationAccountId,
      ),
      _firestoreService.streamAccounts(), // Fresh stream each time
      _firestoreService.streamCategories(), // Fresh stream each time
      (
        List<FirestoreTransaction> transactions,
        List<FirestoreAccount> accounts,
        List<Category> categories,
      ) {
        // Sort transactions by date desc
        transactions.sort((a, b) => b.date.compareTo(a.date));

        final accountMap = {for (var a in accounts) a.id: a};
        final categoryMap = {for (var c in categories) c.id: c};

        final transactionsWithAccounts = transactions
            .map((t) => TransactionWithAccount(
                  transaction: t,
                  account: t.accountId != null ? accountMap[t.accountId] : null,
                  category:
                      t.categoryId != null ? categoryMap[t.categoryId] : null,
                ))
            .toList();

        // Multi-currency totals
        final Map<String, double> incomeByCurrency = {};
        final Map<String, double> expensesByCurrency = {};

        for (final transaction in transactions) {
          final currency = transaction.currency;
          if (currency.isEmpty) continue;

          if (transaction.type == 'income') {
            incomeByCurrency[currency] =
                (incomeByCurrency[currency] ?? 0.0) + transaction.amount;
          } else if (transaction.type == 'expense') {
            expensesByCurrency[currency] =
                (expensesByCurrency[currency] ?? 0.0) + transaction.amount;
          }
        }

        final totalIncome = incomeByCurrency.values
            .fold<double>(0.0, (sum, amount) => sum + amount);
        final totalExpenses = expensesByCurrency.values
            .fold<double>(0.0, (sum, amount) => sum + amount);

        try {
          final sampleIds = transactions.map((t) => t.id).take(6).toList();
          final vacationTxCount =
              transactions.where((t) => t.isVacation == true).length;
          print(
              'DEBUG: VacationAllCurrencies.combine - txCount=${transactions.length}, vacationTxCount=$vacationTxCount, currencies=${incomeByCurrency.keys.toSet().union(expensesByCurrency.keys.toSet()).toList()}, sampleIds=$sampleIds');
        } catch (_) {}

        return MonthPageData(
          transactions: transactions,
          totalIncome: totalIncome,
          totalExpenses: totalExpenses,
          transactionsWithAccounts: transactionsWithAccounts,
          upcomingTasks: const [], // No upcoming tasks in currency-wide view
          incomeByCurrency: incomeByCurrency,
          expensesByCurrency: expensesByCurrency,
        );
      },
    ).startWith(MonthPageData.loading());

    return stream;
  }

  // Method to invalidate cache for a specific month and vacation mode combination
  // No-op: Streams are now always fresh, no cache to invalidate
  void invalidateMonth(int monthIndex, [bool? isVacation]) {
    print(
        'DEBUG: invalidateMonth called (no-op) - monthIndex=$monthIndex, isVacation=$isVacation');
    // Streams are now always fresh, no cache to invalidate
  }

  // Method to clear the cache if a full refresh is needed (e.g., on user logout/login).
  // No-op: Streams are now always fresh, no cache to clear
  void clearCache() {
    print('DEBUG: clearCache called (no-op) - streams are always fresh');
    // Streams are now always fresh, no cache to clear
  }
}

// Widget for displaying a single month's page with pagination
class MonthPageView extends StatefulWidget {
  final int monthIndex;
  final DateTime month;
  final bool isVacation;
  final MonthPageDataManager dataManager;
  final MonthPageProvider provider; // Add provider parameter

  const MonthPageView({
    super.key,
    required this.monthIndex,
    required this.month,
    required this.isVacation,
    required this.dataManager,
    required this.provider, // Add required provider
  });

  @override
  State<MonthPageView> createState() => _MonthPageViewState();
}

class _MonthPageViewState extends State<MonthPageView> {
  late ScrollController _scrollController;
  late MonthPageProvider _provider;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Use the provider passed from the parent widget
    _provider = widget.provider;

    // Set up scroll listener for pagination only
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      // Trigger pagination when user scrolls to 80% of the list
      if (currentScroll >= maxScroll * 0.8 &&
          !_provider.isLoading &&
          !_provider.hasReachedEnd) {
        _provider.fetchNextPage();
      }
    });

    // Initialize the provider with data if it hasn't been initialized yet
    if (_provider.allTransactions.isEmpty) {
      // Get includeVacationTransactions from context
      final homeScreenProvider = Provider.of<HomeScreenProvider>(context, listen: false);
      widget.dataManager
          .getStreamForMonth(
            widget.monthIndex,
            widget.month,
            widget.isVacation,
            homeScreenProvider.includeVacationTransactions,
          )
          .first
          .then((data) {
        if (mounted) {
          _provider.initialize(data);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<MonthPageProvider>(
        builder: (context, provider, child) {
          final currencyProvider = context.watch<CurrencyProvider>();
          final homeScreenProvider = context.watch<HomeScreenProvider>();

          // Listen to the stream for data updates
          return StreamBuilder<MonthPageData>(
            stream: widget.dataManager.getStreamForMonth(
              widget.monthIndex,
              widget.month,
              widget.isVacation,
              homeScreenProvider.includeVacationTransactions,
            ),
            builder: (context, snapshot) {
              // Update provider when new data arrives
              if (snapshot.hasData &&
                  !snapshot.data!.isLoading &&
                  snapshot.data!.error == null) {
                // DEBUG: log incoming snapshot before provider.initialize to trace refresh
                try {
                  final txCount = snapshot.data!.transactionsWithAccounts.length;
                  final linkedCount = snapshot.data!.transactions
                      .where((t) => t.linkedTransactionId != null)
                      .length;
                  print(
                      'DEBUG: MonthPageView.StreamBuilder - monthIndex=${widget.monthIndex}, isVacation=${widget.isVacation}, txCount=$txCount, linkedCount=$linkedCount, providerInitialized=${provider.isInitialized}, paginatedCount=${provider.paginatedTransactions.length}');
                } catch (e) {
                  print(
                      'DEBUG: MonthPageView.StreamBuilder - logging error: $e');
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  provider.initialize(snapshot.data!);
                });
              }

              // Show loading state - unified logic to prevent double shimmer
              // Only show shimmer if the stream is still waiting OR if provider is loading pagination
              if (snapshot.connectionState == ConnectionState.waiting ||
                  !snapshot.hasData ||
                  (snapshot.hasData &&
                      snapshot.data!.isLoading &&
                      !provider.isInitialized)) {
                return _buildLoadingState();
              }

              // Show pagination loading indicator separately
              if (provider.isLoading && provider.isInitialized) {
                return _buildContentWithData(
                  snapshot.data!,
                  provider,
                  currencyProvider,
                );
              }

              // Show error state
              if (snapshot.hasError ||
                  (snapshot.hasData && snapshot.data!.error != null)) {
                return _buildErrorState(
                  snapshot.error?.toString() ?? snapshot.data!.error!,
                );
              }

              // Show content with pagination
              final data = snapshot.data!;
              return _buildContentWithData(data, provider, currencyProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildContentWithData(
    MonthPageData data,
    MonthPageProvider provider,
    CurrencyProvider currencyProvider,
  ) {
    // If there are no transactions for the selected period, show an empty state.
    if (provider.allTransactions.isEmpty) {
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
            padding: const EdgeInsets.all(20.0),
            child: _buildEmptyState(),
          ),
        ),
      );
    }

    Map<String, List<TransactionWithAccount>> groupedTransactions = {};
    for (var tx in provider.paginatedTransactions) {
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
        return dateB.compareTo(dateA);
      });

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Error state widget
          if (provider.error.isNotEmpty) _buildPaginationErrorWidget(provider),

          // Main content with ListView.builder for infinite scroll
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 16),
              itemCount: sortedKeys.length +
                  (provider.hasReachedEnd ? 1 : 0) +
                  (provider.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                // Show loading indicator at the bottom
                if (provider.isLoading &&
                    index == sortedKeys.length &&
                    provider.isInitialized) {
                  return _buildLoadingIndicator();
                }

                // Show end of list message
                if (provider.hasReachedEnd && index == sortedKeys.length) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.homeNoMoreTransactions,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }

                // Show transaction items grouped by date
                if (index < sortedKeys.length) {
                  final date = sortedKeys[index];
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
                }

                return const SizedBox.shrink();
              },
            ),
          ),

          // Upcoming tasks section
          _buildUpcomingTasksSectionWithData(
            data.upcomingTasks,
            currencyProvider,
          ),
          const SizedBox(height: 70), // To avoid FAB overlap
        ],
      ),
    );
  }

  Widget _buildPaginationErrorWidget(MonthPageProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.homeErrorLoadingMoreTransactions,
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  provider.error,
                  style: TextStyle(color: Colors.red.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => provider.retryFetch(),
            child: Text(
              AppLocalizations.of(context)!.homeRetry,
              style: TextStyle(
                color: Colors.red.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.grey.shade400,
          strokeWidth: 2.0,
        ),
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
                AppLocalizations.of(context)!.homeErrorLoadingData,
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

  Widget _buildEmptyState() {
    return Column(
      mainAxisSize: MainAxisSize.min, // Make column take minimum space
      children: [
        Image.asset(
          'images/launcher/logo.png',
          width: 80,
          height: 80,
          color: Colors.grey.shade300,
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.homeNoTransactionsRecorded,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.homeStartAddingTransactions,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(height: 50),
      ],
    );
  }

  Color _getTransactionBackgroundColor(
      FirestoreTransaction transaction, FirestoreAccount? account) {
    final vacationProvider =
        Provider.of<VacationProvider>(context, listen: false);
    final isVacationTransaction = transaction.isVacation == true;

    if (vacationProvider.isVacationMode) {
      // In vacation mode: all transactions are vacation transactions, use normal white background
      return Colors.white;
    } else {
      // In normal mode: differentiate vacation transactions with a light blue background
      if (isVacationTransaction) {
        return Colors.blue.shade50; // Light blue for vacation transactions in normal mode
      } else {
        return Colors.white; // Normal white background for regular transactions
      }
    }
  }

  Color _getTransactionBorderColor(FirestoreTransaction transaction) {
    final vacationProvider =
        Provider.of<VacationProvider>(context, listen: false);
    final isVacationTransaction = transaction.isVacation == true;

    if (vacationProvider.isVacationMode) {
      // In vacation mode: use normal grey border
      return Colors.grey.shade200;
    } else {
      // In normal mode: use blue border for vacation transactions
      if (isVacationTransaction) {
        return Colors.blue.shade300; // Blue border for vacation transactions in normal mode
      } else {
        return Colors.grey.shade200; // Normal grey border for regular transactions
      }
    }
  }

  Widget _buildTransactionItem(
    TransactionWithAccount transactionWithAccount,
    CurrencyProvider currencyProvider,
  ) {
    final transaction = transactionWithAccount.transaction;
    final account = transactionWithAccount.account;
    final uiTransaction = _convertToUiTransaction(
      transaction,
      context,
      transactionWithAccount.category,
    );

    // Get the icon color from the transaction, fallback to default if null
    final Color iconBackgroundColor = hexToColor(transaction.icon_color);
    final Color iconForegroundColor = getContrastingColor(iconBackgroundColor);

    // Determine if the transaction is a vacation transaction
    final bool isVacationTransaction = transaction.isVacation;
    // DEBUG: Log each transaction item render (may be verbose)
    try {
      print(
          'DEBUG: BuildTransactionItem - id=${transaction.id}, isVacationTxn=$isVacationTransaction, linkedId=${transaction.linkedTransactionId}, accountId=${account?.id}, date=${transaction.date.toIso8601String()}, type=${transaction.type}, amount=${transaction.amount}, paid=${transaction.paid}');
    } catch (e) {
      print('DEBUG: BuildTransactionItem - logging error: $e');
    }

    return InkWell(
      onTap: () async {
        // Navigate to detail screen for all transactions
        final result = await PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: ExpenseDetailScreen(transaction: uiTransaction),
          withNavBar: false,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );

        if (result == true) {
          // Trigger a refresh to get the updated transaction data from Firestore
          final homeScreenProvider = Provider.of<HomeScreenProvider>(context, listen: false);
          homeScreenProvider.triggerTransactionsRefresh();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _getTransactionBackgroundColor(transaction, account),
          borderRadius: BorderRadius.circular(18),
          border:
              Border.all(color: _getTransactionBorderColor(transaction), width: 1),
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
              child: HugeIcon(
                icon: getIcon(transactionWithAccount.category?.icon),
                color: iconForegroundColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          transactionWithAccount.category?.name ??
                              transaction.description,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  if (account != null && (account.isDefault != true))
                    Text(
                      [account.name, account.accountType]
                          .where((text) => text.isNotEmpty)
                          .join(' - '),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Show paid/unpaid icon for all transactions
                Icon(
                  transaction.paid == true
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: transaction.paid == true ? Colors.green : Colors.grey,
                  size: 16,
                ),
                // Add vacation icon for vacation transactions in normal mode
                if (transaction.isVacation == true &&
                    !Provider.of<VacationProvider>(context, listen: false)
                        .isVacationMode) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.flight_takeoff,
                    color: Colors.blue.shade600,
                    size: 14,
                  ),
                ],
                const SizedBox(width: 4),
                Text(
                  '${transaction.type == 'income' ? '+' : '-'} ${transaction.currency} ${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: transaction.type == 'income'
                        ? Colors.green
                        : Colors.red,
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

  Widget _buildUpcomingTasksSectionWithData(
    List<FirestoreTask> tasks,
    CurrencyProvider currencyProvider,
  ) {
    if (tasks.isEmpty) {
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

// Helper function to show currency change dialog
Future<void> _showCurrencyChangeDialog(
  BuildContext context,
  String currentCurrency,
  String vacationCurrency,
  CurrencyProvider currencyProvider,
) async {
  final navbarProvider =
      Provider.of<NavbarVisibilityProvider>(context, listen: false);

  // Enable dialog mode to allow navbar hiding on home screen
  navbarProvider.setDialogMode(true);
  navbarProvider.setNavBarVisibility(false);

  // Add a small delay to ensure navbar is hidden before showing dialog
  await Future.delayed(const Duration(milliseconds: 100));

  try {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.homeCurrencyChange),
          content: Text(
            'Do you want to change currencies because your old currency ($currentCurrency) differs from vacation currency ($vacationCurrency)?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(AppLocalizations.of(context)!.homeNo),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                // Show currency picker
                showCurrencyPicker(
                  context: context,
                  showFlag: true,
                  showSearchField: true,
                  onSelect: (Currency currency) async {
                    final currencyProvider =
                        Provider.of<CurrencyProvider>(context, listen: false);
                    await currencyProvider.setCurrency(currency, 1.0);
                  },
                );
              },
              child: Text(AppLocalizations.of(context)!.homeYes),
            ),
          ],
        );
      },
    );
  } finally {
    // Always restore navbar visibility and disable dialog mode, even if an error occurred
    if (context.mounted) {
      navbarProvider.setNavBarVisibility(true);
      navbarProvider.setDialogMode(false);
    }
  }
}

// Helper function to show currency breakdown dialog
Future<void> _showCurrencyBreakdownDialog(
  BuildContext context,
  Map<String, double> incomeByCurrency,
  Map<String, double> expensesByCurrency,
  CurrencyProvider currencyProvider,
  bool isVacationMode,
  double totalBudget,
  String? vacationAccountCurrency,
) async {
  final navbarProvider =
      Provider.of<NavbarVisibilityProvider>(context, listen: false);

  // Enable dialog mode to allow navbar hiding on home screen
  navbarProvider.setDialogMode(true);
  navbarProvider.setNavBarVisibility(false);

  // Add a small delay to ensure navbar is hidden before showing dialog
  await Future.delayed(const Duration(milliseconds: 100));

  try {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isVacationMode ? AppLocalizations.of(context)!.homeVacationBudgetBreakdown : AppLocalizations.of(context)!.homeBalanceBreakdown),
          content: SizedBox(
            width: double.maxFinite,
            child: _buildCurrencyBreakdownContent(
              context,
              incomeByCurrency,
              expensesByCurrency,
              currencyProvider,
              isVacationMode,
              totalBudget,
              vacationAccountCurrency,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(AppLocalizations.of(context)!.homeClose),
            ),
          ],
        );
      },
    );
  } finally {
    // Always restore navbar visibility and disable dialog mode, even if an error occurred
    if (context.mounted) {
      navbarProvider.setNavBarVisibility(true);
      navbarProvider.setDialogMode(false);
    }
  }
}

// Helper function to build currency breakdown content
Widget _buildCurrencyBreakdownContent(
  BuildContext context,
  Map<String, double> incomeByCurrency,
  Map<String, double> expensesByCurrency,
  CurrencyProvider currencyProvider,
  bool isVacationMode,
  double totalBudget,
  String? vacationAccountCurrency,
) {
  // Get all unique currencies
  final allCurrencies = <String>{}
    ..addAll(incomeByCurrency.keys)
    ..addAll(expensesByCurrency.keys);

  if (allCurrencies.isEmpty) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'No transactions found',
        style: TextStyle(color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Sort currencies: selected currency first, then alphabetically
  final sortedCurrencies = allCurrencies.toList()
    ..sort((a, b) {
      final selectedCurrency = currencyProvider.selectedCurrencyCode;
      final aIsSelected = a == selectedCurrency;
      final bIsSelected = b == selectedCurrency;
      
      if (aIsSelected && !bIsSelected) return -1;
      if (!aIsSelected && bIsSelected) return 1;
      return a.compareTo(b);
    });

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isVacationMode) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${AppLocalizations.of(context)!.homeTotalBudget}: ${vacationAccountCurrency ?? currencyProvider.selectedCurrencyCode} ${totalBudget.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        ...sortedCurrencies.map((currency) {
          final income = incomeByCurrency[currency] ?? 0.0;
          final expenses = expensesByCurrency[currency] ?? 0.0;
          final balance = income - expenses;
          final isSelectedCurrency = currency == currencyProvider.selectedCurrencyCode;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelectedCurrency ? Colors.grey.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelectedCurrency ? Colors.grey.shade400 : Colors.grey.shade200,
                width: isSelectedCurrency ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currency,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isSelectedCurrency ? Colors.black87 : Colors.black54,
                      ),
                    ),
                    if (isSelectedCurrency)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'SELECTED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Only show income row if not in vacation mode
                    if (!isVacationMode) ...[
                      Expanded(
                        child: _buildCurrencyRow(
                          AppLocalizations.of(context)!.analyticsIncome,
                          income,
                          currency,
                          Colors.green,
                          Icons.trending_up,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: _buildCurrencyRow(
                        AppLocalizations.of(context)!.analyticsExpenses,
                        expenses,
                        currency,
                        Colors.red,
                        Icons.trending_down,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: balance >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: balance >= 0 ? Colors.green.shade200 : Colors.red.shade200,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        balance >= 0 ? Icons.account_balance_wallet : Icons.warning,
                        color: balance >= 0 ? Colors.green.shade600 : Colors.red.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Balance: $currency ${balance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: balance >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    ),
  );
}

// Helper function to build individual currency row
Widget _buildCurrencyRow(
  String label,
  double amount,
  String currencyCode,
  Color color,
  IconData icon,
) {
  return Row(
    children: [
      Icon(icon, color: color, size: 16),
      const SizedBox(width: 4),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              '$currencyCode ${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// Helper function to show vacation mode currency change dialog
Future<void> _showVacationCurrencyDialog(
  BuildContext context,
  CurrencyProvider currencyProvider,
) async {
  final navbarProvider =
      Provider.of<NavbarVisibilityProvider>(context, listen: false);

  // Enable dialog mode to allow navbar hiding on home screen
  navbarProvider.setDialogMode(true);
  navbarProvider.setNavBarVisibility(false);

  // Add a small delay to ensure navbar is hidden before showing dialog
  await Future.delayed(const Duration(milliseconds: 100));

  try {
    // Get the previous currency from SharedPreferences
    String previousCurrency = 'USD'; // Default fallback
    try {
      final prefs = await SharedPreferences.getInstance();
      previousCurrency = prefs.getString('preVacationCurrencyCode') ?? 'USD';
    } catch (e) {
      // Non-fatal: use default currency
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.vacationCurrencyDialogTitle),
          content: Text(
            AppLocalizations.of(context)!.vacationCurrencyDialogMessage(previousCurrency),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(AppLocalizations.of(context)!.vacationCurrencyDialogKeepCurrent(previousCurrency)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                // Show currency picker
                showCurrencyPicker(
                  context: context,
                  showFlag: true,
                  showSearchField: true,
                  onSelect: (Currency currency) async {
                    final currencyProvider =
                        Provider.of<CurrencyProvider>(context, listen: false);
                    await currencyProvider.setCurrency(currency, 1.0);
                  },
                );
              },
              child: Text(AppLocalizations.of(context)!.changeCurrency),
            ),
          ],
        );
      },
    );
  } finally {
    // Always restore navbar visibility and disable dialog mode, even if an error occurred
    if (context.mounted) {
      navbarProvider.setNavBarVisibility(true);
      navbarProvider.setDialogMode(false);
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late ScrollController _monthScrollController;
  late PageController _pageController;
  late FirestoreService _firestoreService;
  late MonthPageDataManager _pageDataManager;
  List<DateTime> _months = [];
  int _selectedMonthIndex = 0;

  // Future month handling configuration
  static const int _baselineHorizonMonths = 6; // initial future months beyond current
  static const int _extensionStepMonths = 6; // extend in this many months when near end
  static const int _maxFutureMonths = 36; // cap to avoid infinite future

  // Removed unused field: _isTogglingVacationMode

  // Removed unused field: _lastContentOffset

  // Map to hold MonthPageProvider instances for each month
  final Map<int, MonthPageProvider> _monthProviders = {};

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService.instance;
    _monthScrollController = ScrollController();
    _pageController = PageController();

    // Initialize MonthPageDataManager with VacationProvider
    final vacationProvider = Provider.of<VacationProvider>(
      context,
      listen: false,
    );
    _pageDataManager = MonthPageDataManager(vacationProvider);

    _loadMonths();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _monthScrollController.dispose();
    _pageController.dispose();

    // Dispose all providers
    for (final provider in _monthProviders.values) {
      provider.dispose();
    }
    _monthProviders.clear();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Data refresh is now handled by other mechanisms
    // such as explicit user actions or navigation events
  }

  // Get or create a provider for a specific month
  MonthPageProvider _getOrCreateProvider(int monthIndex) {
    if (!_monthProviders.containsKey(monthIndex)) {
      _monthProviders[monthIndex] = MonthPageProvider();
    }
    return _monthProviders[monthIndex]!;
  }

  // Pre-load data for adjacent months
  void _preloadAdjacentMonths(int currentIndex) {
    final isVacation = Provider.of<VacationProvider>(
      context,
      listen: false,
    ).isVacationMode;
    final homeScreenProvider = Provider.of<HomeScreenProvider>(
      context,
      listen: false,
    );

    // Pre-load next month
    if (currentIndex + 1 < _months.length) {
      final nextProvider = _getOrCreateProvider(currentIndex + 1);
      if (nextProvider.allTransactions.isEmpty) {
        final nextStream = _pageDataManager.getStreamForMonth(
          currentIndex + 1,
          _months[currentIndex + 1],
          isVacation,
          homeScreenProvider.includeVacationTransactions,
        );
        nextStream.first.then((data) {
          if (mounted && !data.isLoading && data.error == null) {
            nextProvider.initialize(data);
          }
        });
      }
    }

    // Pre-load previous month
    if (currentIndex - 1 >= 0) {
      final prevProvider = _getOrCreateProvider(currentIndex - 1);
      if (prevProvider.allTransactions.isEmpty) {
        final prevStream = _pageDataManager.getStreamForMonth(
          currentIndex - 1,
          _months[currentIndex - 1],
          isVacation,
          homeScreenProvider.includeVacationTransactions,
        );
        prevStream.first.then((data) {
          if (mounted && !data.isLoading && data.error == null) {
            prevProvider.initialize(data);
          }
        });
      }
    }
  }

  // This method is no longer needed since the scroll listener is set up in initState
  // void _setupScrollListener(List<TransactionWithAccount> allTransactions) {
  //   _contentScrollController.addListener(() {
  //     if (!_contentScrollController.hasClients) return;
  //
  //     final maxScroll = _contentScrollController.position.maxScrollExtent;
  //     final currentScroll = _contentScrollController.position.pixels;
  //
  //     // Trigger pagination when user scrolls to 80% of the list
  //     if (currentScroll >= maxScroll * 0.8 && !_isLoading && !_hasReachedEnd) {
  //       _fetchNextPage(allTransactions);
  //     }
  //   });
  // }

  Future<void> _loadMonths() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final nowMonth = DateTime(now.year, now.month);

    // Provisional start: cached start or last 12 months
    DateTime provisionalStart;
    final cachedStartStr = prefs.getString('dataStartDate');
    if (cachedStartStr != null) {
      try {
        final parsed = DateTime.parse(cachedStartStr);
        provisionalStart = DateTime(parsed.year, parsed.month);
      } catch (_) {
        provisionalStart = DateTime(now.year, now.month - 12, 1);
      }
    } else {
      provisionalStart = DateTime(now.year, now.month - 12, 1);
    }

    // Provisional end: current + baseline horizon, capped
    DateTime provisionalEnd = DateTime(nowMonth.year, nowMonth.month + _baselineHorizonMonths, 1);
    final capEnd = DateTime(nowMonth.year, nowMonth.month + _maxFutureMonths, 1);
    if (provisionalEnd.isAfter(capEnd)) {
      provisionalEnd = capEnd;
    }

    // Build initial months for immediate rendering
    final initialMonths = _buildMonthRange(provisionalStart, provisionalEnd);

    if (mounted) {
      setState(() {
        _months = initialMonths;
        _selectedMonthIndex = _months.indexWhere(
          (m) => m.year == nowMonth.year && m.month == nowMonth.month,
        );
        if (_selectedMonthIndex < 0) {
          // If current month not in range (unlikely), default to last item
          _selectedMonthIndex = _months.length - 1;
        }

        final homeScreenProvider = Provider.of<HomeScreenProvider>(context, listen: false);
        homeScreenProvider.setSelectedDate(_months[_selectedMonthIndex]);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_monthScrollController.hasClients) {
        _scrollToSelectedMonth();
      }
      if (_pageController.hasClients &&
          _selectedMonthIndex >= 0 &&
          _selectedMonthIndex < _months.length) {
        try {
          _pageController.jumpToPage(_selectedMonthIndex);

          // Initialize provider for the initial month
          final isVacation = Provider.of<VacationProvider>(context, listen: false).isVacationMode;
          final homeScreenProvider = Provider.of<HomeScreenProvider>(context, listen: false);
          final provider = _getOrCreateProvider(_selectedMonthIndex);

          if (provider.allTransactions.isEmpty) {
            final stream = _pageDataManager.getStreamForMonth(
              _selectedMonthIndex,
              _months[_selectedMonthIndex],
              isVacation,
              homeScreenProvider.includeVacationTransactions,
            );
            stream.first.then((data) {
              if (mounted && !data.isLoading && data.error == null) {
                provider.initialize(data);
              }
            });
          }
        } catch (_) {}
      }

      // Background refinement: pull earliest transaction and latest task due date, then update months if needed
      try {
        final earliest = await _firestoreService.fetchEarliestTransactionDate();

        DateTime refinedStart = provisionalStart;
        if (earliest != null) {
          refinedStart = DateTime(earliest.year, earliest.month, 1);
          await prefs.setString('dataStartDate', refinedStart.toIso8601String());
        }

        // Determine refined end based on tasks and cap
        DateTime refinedEnd = DateTime(nowMonth.year, nowMonth.month + _baselineHorizonMonths, 1);
        try {
          final allTasks = await _firestoreService.getAllTasks();
          final latestDue = allTasks
              .where((t) => (t.isCompleted != true))
              .map((t) => t.dueDate)
              .fold<DateTime?>(null, (acc, d) => acc == null || d.isAfter(acc) ? d : acc);
          if (latestDue != null) {
            final latestTaskMonth = DateTime(latestDue.year, latestDue.month, 1);
            if (latestTaskMonth.isAfter(refinedEnd)) {
              refinedEnd = latestTaskMonth;
            }
          }
        } catch (e) {
          // Non-fatal: keep baseline horizon if tasks fetch fails
        }

        final capEnd2 = DateTime(nowMonth.year, nowMonth.month + _maxFutureMonths, 1);
        if (refinedEnd.isAfter(capEnd2)) {
          refinedEnd = capEnd2;
        }

        // If range changed, update months
        final newMonths = _buildMonthRange(refinedStart, refinedEnd);
        final needUpdate = _months.isEmpty ||
            _months.first.year != newMonths.first.year ||
            _months.first.month != newMonths.first.month ||
            _months.last.year != newMonths.last.year ||
            _months.last.month != newMonths.last.month;
        if (needUpdate && mounted) {
          setState(() {
            _months = newMonths;
            // Re-select current month (or closest)
            final idx = _months.indexWhere((m) => m.year == nowMonth.year && m.month == nowMonth.month);
            _selectedMonthIndex = idx >= 0 ? idx : (_months.length - 1);
          });
          if (_pageController.hasClients) {
            try {
              _pageController.jumpToPage(_selectedMonthIndex);
            } catch (_) {}
          }
          if (_monthScrollController.hasClients) {
            _scrollToSelectedMonth();
          }
        }
      } catch (e) {
        // ignore
      }
    });
  }

  // Build list of months inclusive of start and end (month precision)
  List<DateTime> _buildMonthRange(DateTime startInclusive, DateTime endInclusive) {
    final start = DateTime(startInclusive.year, startInclusive.month, 1);
    final end = DateTime(endInclusive.year, endInclusive.month, 1);
    final result = <DateTime>[];
    DateTime cursor = start;
    while (!DateTime(cursor.year, cursor.month, 1).isAfter(end)) {
      result.add(cursor);
      cursor = DateTime(cursor.year, cursor.month + 1, 1);
    }
    return result;
  }

  void _maybeExtendFutureMonths(int currentIndex) {
    if (_months.isEmpty) return;
    // If within 2 pages of the end, extend by step months up to cap
    if (currentIndex >= _months.length - 2) {
      final last = _months.last;
      final now = DateTime.now();
      final nowMonth = DateTime(now.year, now.month, 1);
      final capEnd = DateTime(nowMonth.year, nowMonth.month + _maxFutureMonths, 1);
      if (last.isBefore(capEnd)) {
        final newEnd = _minMonth(
          DateTime(last.year, last.month + _extensionStepMonths, 1),
          capEnd,
        );
        final append = _buildMonthRange(
          DateTime(last.year, last.month + 1, 1),
          newEnd,
        );
        if (append.isNotEmpty && mounted) {
          setState(() {
            _months = [..._months, ...append];
          });
        }
      }
    }
  }

  DateTime _minMonth(DateTime a, DateTime b) {
    return a.isBefore(b) ? a : b;
  }

  // Removed unused method: _toggleVacationModeWithDebounce

  void _scrollToSelectedMonth() {
    if (_selectedMonthIndex != -1) {
      final screenWidth = MediaQuery.of(context).size.width;
      const itemWidth = 85.0; // Adjusted width
      final offset = (_selectedMonthIndex * itemWidth) -
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

    // Handle transaction refresh
    if (homeScreenProvider.shouldRefreshTransactions) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // If a transactionDate is provided, jump to that month first
        final transactionDate = homeScreenProvider.transactionDate;
        if (transactionDate != null) {
          final newMonthIndex = _months.indexWhere(
            (month) =>
                month.year == transactionDate.year &&
                month.month == transactionDate.month,
          );

          if (newMonthIndex != -1 && newMonthIndex != _selectedMonthIndex) {
            setState(() {
              _selectedMonthIndex = newMonthIndex;
            });
            _scrollToSelectedMonth();
          }
        }

        // Clear cache and reset all providers
        _pageDataManager.clearCache();
        for (final provider in _monthProviders.values) {
          provider.forceReset();
        }

        // Mark refresh as complete and rebuild
        homeScreenProvider.completeRefresh();
        // Recompute month range in case data start/end changed
        await _loadMonths();
        if (mounted) setState(() {});
      });
    }
    // Check for account-specific refresh
    else if (homeScreenProvider.shouldRefreshAccounts) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Invalidate all cached months for current mode and also other mode internally
        final isVacation = Provider.of<VacationProvider>(
          context,
          listen: false,
        ).isVacationMode;
        for (final monthIndex in _monthProviders.keys) {
          _pageDataManager.invalidateMonth(monthIndex, isVacation);
          _monthProviders[monthIndex]!.forceReset();
        }
        homeScreenProvider.completeRefresh();
        // Recompute month range in case data start/end changed
        await _loadMonths();
        if (mounted) setState(() {});
      });
    }
    // Check for month-targeted refresh (e.g., jump to a different month)
    else if (homeScreenProvider.shouldRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final transactionDate = homeScreenProvider.transactionDate;
        if (transactionDate != null) {
          final newMonthIndex = _months.indexWhere(
            (month) =>
                month.year == transactionDate.year &&
                month.month == transactionDate.month,
          );

          if (newMonthIndex != -1 && newMonthIndex != _selectedMonthIndex) {
            setState(() {
              _selectedMonthIndex = newMonthIndex;
            });
            _scrollToSelectedMonth();
          }
        }
        // Invalidate the specific month to force a refresh
        _pageDataManager.invalidateMonth(_selectedMonthIndex, null);

        // Reset the provider for the current month
        if (_monthProviders.containsKey(_selectedMonthIndex)) {
          _monthProviders[_selectedMonthIndex]!.forceReset();
        }
        // Mark refresh as complete
        homeScreenProvider.completeRefresh();
        // Trigger a rebuild
        // Recompute month range in case data start/end changed
        await _loadMonths();
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
                    // Hide month selector and PageView in Vacation Mode
                    if (!vacationProvider.isVacationMode) _buildMonthSelector(),
                    _buildBalanceCards(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: vacationProvider.isVacationMode
                          ? _buildVacationCurrencyList()
                          : PageView.builder(
                              controller: _pageController,
                              itemCount: _months.length,
                              onPageChanged: (index) {
                                if (!mounted) return;
                                if (index < 0 || index >= _months.length)
                                  return;

                                setState(() {
                                  _selectedMonthIndex = index;
                                });

                                // Update the selected date in HomeScreenProvider
                                final homeScreenProvider =
                                    Provider.of<HomeScreenProvider>(
                                  context,
                                  listen: false,
                                );
                                homeScreenProvider.setSelectedDate(_months[index]);

                                _scrollToSelectedMonth();

                                // Extend future months lazily when approaching the end
                                _maybeExtendFutureMonths(index);

                                // Pre-load adjacent months after the page change is complete
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _preloadAdjacentMonths(index);
                                });
                              },
                              itemBuilder: (context, index) {
                                // Watch VacationProvider so that changes to activeVacationAccountId also rebuild
                                final vacationProvider =
                                    context.watch<VacationProvider>();
                                final isVacation =
                                    vacationProvider.isVacationMode;
                                final activeVacationAccountId =
                                    vacationProvider.activeVacationAccountId;
                                // Also watch includeVacation filter so that key changes and child remounts when filter toggles
                                final includeVacation = context
                                    .watch<HomeScreenProvider>()
                                    .includeVacationTransactions;
                                // Get or create provider for this month and pass it to MonthPageView
                                final provider = _getOrCreateProvider(index);
                                return MonthPageView(
                                  // Include activeVacationAccountId in the key to avoid stale cached children when account changes
                                  key: ValueKey<String>(
                                      '$index-$isVacation-${activeVacationAccountId ?? 'all'}-includeVac$includeVacation'),
                                  monthIndex: index,
                                  month: _months[index],
                                  isVacation: isVacation,
                                  dataManager: _pageDataManager,
                                  provider: provider,
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

  // Vacation Mode content: currency-only list with infinite scroll, reusing MonthPageProvider
  Widget _buildVacationCurrencyList() {
    final vacationProvider = context.watch<VacationProvider>();

    print(
        'DEBUG: _buildVacationCurrencyList - isVacationMode=${vacationProvider.isVacationMode}, activeVacationAccountId=${vacationProvider.activeVacationAccountId}');

    // Reuse a single MonthPageProvider under key -1 for vacation currency list
    final provider = _monthProviders.putIfAbsent(-1, () => MonthPageProvider());

    return StreamBuilder<MonthPageData>(
      stream: _pageDataManager.getVacationAllCurrenciesStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            !snapshot.data!.isLoading &&
            snapshot.data!.error == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            provider.initialize(snapshot.data!);
          });
        }

        return MonthPageView(
          key: ValueKey<String>(
              'vacation-all-${vacationProvider.activeVacationAccountId ?? 'all'}'),
          monthIndex: -1,
          month: DateTime.now(), // Unused in vacation view
          isVacation: true,
          dataManager: _pageDataManager,
          provider: provider,
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final vacationProvider = context.watch<VacationProvider>();
    final currencyProvider = context.watch<CurrencyProvider>();
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final isVacation = vacationProvider.isVacationMode;

    return StreamBuilder<List<FirestoreAccount>>(
      stream: _firestoreService.streamAccounts(),
      builder: (context, accountsSnapshot) {
        double totalBudget = 0.0;
        String? vacationAccountCurrency;

        if (accountsSnapshot.hasData &&
            vacationProvider.activeVacationAccountId != null) {
          final vacationAccounts = accountsSnapshot.data!
              .where((account) => account.isVacationAccount == true)
              .toList();

          final activeVacationAccount = vacationAccounts
              .where(
                (account) =>
                    account.id == vacationProvider.activeVacationAccountId,
              )
              .firstOrNull;

          if (activeVacationAccount != null) {
            totalBudget = activeVacationAccount.initialBalance;
            vacationAccountCurrency = activeVacationAccount.currency;
          }
        }

        final homeScreenProvider = context.read<HomeScreenProvider>();
        final Stream<MonthPageData> topStream = isVacation
            ? _pageDataManager.getVacationAllCurrenciesStream()
            : (_selectedMonthIndex >= 0 && _selectedMonthIndex < _months.length
                ? _pageDataManager.getStreamForMonth(
                    _selectedMonthIndex,
                    _months[_selectedMonthIndex],
                    isVacation,
                    homeScreenProvider.includeVacationTransactions,
                  )
                : Stream.value(MonthPageData.loading()));

        return StreamBuilder<MonthPageData>(
          stream: topStream,
          builder: (context, snapshot) {
            // Compute top balance
            final selectedCurrency = currencyProvider.selectedCurrencyCode;
            double topBalance;

            if (vacationProvider.isVacationMode) {
              // In vacation mode: show total budget minus all expenses across all currencies
              final totalExpenses = snapshot.data?.expensesByCurrency.values
                      .fold<double>(0.0, (sum, amount) => sum + amount) ??
                  0.0;
              topBalance = totalBudget - totalExpenses;
            } else {
              // In normal mode: show selected currency balance (includes both normal and vacation transactions)
              final incomeSelected =
                  (snapshot.data?.incomeByCurrency[selectedCurrency] ?? 0.0);
              final expensesSelected =
                  (snapshot.data?.expensesByCurrency[selectedCurrency] ?? 0.0);
              topBalance = incomeSelected - expensesSelected;
            }

            return Container(
              height: statusBarHeight +
                  80, // Match the toolbarHeight from SliverAppBar plus status bar height
              padding: const EdgeInsets.only(
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
                                  PageTransitionAnimation.slideRight,
                            );
                          },
                          child: CircleAvatar(
                            radius: 22,
                            backgroundImage: _getProfileImage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedMonthIndex < _months.length &&
                                      _selectedMonthIndex >= 0
                                  ? DateFormat(
                                      'MMMM',
                                    ).format(_months[_selectedMonthIndex])
                                  : 'Balance',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${vacationProvider.isVacationMode && vacationAccountCurrency != null ? vacationAccountCurrency : currencyProvider.selectedCurrencyCode} ${topBalance.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => _showCurrencyBreakdownDialog(
                                    context,
                                    snapshot.data?.incomeByCurrency ?? {},
                                    snapshot.data?.expensesByCurrency ?? {},
                                    currencyProvider,
                                    vacationProvider.isVacationMode,
                                    totalBudget,
                                    vacationAccountCurrency,
                                  ),
                                  child: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.black54,
                                    size: 20,
                                  ),
                                ),
                              ],
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
                            final vacationProvider =
                                Provider.of<VacationProvider>(
                              context,
                              listen: false,
                            );
                            final currentVacationMode =
                                vacationProvider.isVacationMode;

                            if (currentVacationMode) {
                              // Turning OFF vacation mode: show currency change dialog
                              await vacationProvider.setVacationMode(false);

                              // Show currency change dialog
                              if (context.mounted) {
                                final currencyProvider =
                                    Provider.of<CurrencyProvider>(context,
                                        listen: false);
                                final currentCode =
                                    currencyProvider.selectedCurrencyCode;

                                // Get the pre-vacation currency
                                final prefs =
                                    await SharedPreferences.getInstance();
                                final preVacationCode =
                                    prefs.getString('preVacationCurrencyCode');

                                if (preVacationCode != null &&
                                    preVacationCode != currentCode) {
                                  await _showCurrencyChangeDialog(
                                    context,
                                    preVacationCode,
                                    currentCode,
                                    currencyProvider,
                                  );
                                } else {
                                  // Show simple informational dialog if no currency change
                                  final navbarProvider =
                                      Provider.of<NavbarVisibilityProvider>(
                                          context,
                                          listen: false);
                                  navbarProvider.setDialogMode(true);
                                  navbarProvider.setNavBarVisibility(false);

                                  // Add a small delay to ensure navbar is hidden before showing dialog
                                  await Future.delayed(
                                      const Duration(milliseconds: 100));

                                  try {
                                    await showDialog<void>(
                                      context: context,
                                      builder: (ctx) {
                                        return AlertDialog(
                                          title: Text(AppLocalizations.of(context)!.normalMode),
                                          content: Text(
                                              AppLocalizations.of(context)!.normalModeWithCurrency(currentCode)),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(),
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } finally {
                                    if (context.mounted) {
                                      navbarProvider
                                          .setNavBarVisibility(true);
                                      navbarProvider.setDialogMode(false);
                                    }
                                  }
                                }
                              }
                            } else {
                              // Turning ON vacation mode: check subscription and existing accounts
                              final subscriptionProvider =
                                  Provider.of<SubscriptionProvider>(
                                context,
                                listen: false,
                              );
                              
                              // Only prevent vacation mode switching if unsubscribed AND no existing vacation accounts
                              // This allows users who created vacation accounts while subscribed
                              // to continue using them even after subscription expires
                              if (!subscriptionProvider.isSubscribed) {
                                final firestoreService = FirestoreService.instance;
                                final allAccounts = await firestoreService.getAllAccounts();
                                final vacationAccounts = allAccounts
                                    .where((a) => a.isVacationAccount == true)
                                    .toList();
                                
                                // If no existing vacation accounts, show paywall to prevent creation
                                if (vacationAccounts.isEmpty) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const PaywallScreen(),
                                    ),
                                  );
                                  return;
                                }
                                // If they have existing vacation accounts, allow switching to use them
                              }
                              
                              // Turning ON vacation mode: go through selection flow
                              await vacationProvider
                                  .checkAndShowVacationDialog(
                                context,
                              );

                              // Show currency change dialog after vacation mode is enabled
                              if (context.mounted &&
                                  vacationProvider.isVacationMode) {
                                final currencyProvider =
                                    Provider.of<CurrencyProvider>(context,
                                        listen: false);
                                await _showVacationCurrencyDialog(
                                  context,
                                  currencyProvider,
                                );
                              }
                            }

                            // It's crucial to read the new state *after* the async operations.
                            final newVacationMode =
                                vacationProvider.isVacationMode;

                            // Only proceed if the mode actually changed.
                            if (newVacationMode != currentVacationMode) {
                              // Trigger rebuild and data refresh.
                              setState(() {
                                // Reset all providers and clear the data manager cache to force fresh streams.
                                for (final provider
                                    in _monthProviders.values) {
                                  provider.forceReset();
                                }
                                // Prefer clearing cached page streams instead of recreating the manager
                                _pageDataManager.clearCache();
                                print(
                                    'DEBUG: Vacation mode changed -> cleared MonthPageDataManager cache and reset all MonthPageProviders');
                              });
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
                        // Only show 3-dot menu in normal mode
                        if (!vacationProvider.isVacationMode)
                          _build3DotMenuButton(context, homeScreenProvider),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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

  Widget _build3DotMenuButton(BuildContext context, HomeScreenProvider homeScreenProvider) {
    final isFilterActive = !homeScreenProvider.includeVacationTransactions;
    
    return Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(left: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              _show3DotMenu(context, homeScreenProvider);
            },
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedMoreVertical,
              color: Colors.black87,
              size: 22,
            ),
          ),
        ),
        // Notification badge when filter is active
        if (isFilterActive)
          Positioned(
            right: 6,
            top: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }

  void _show3DotMenu(BuildContext context, HomeScreenProvider homeScreenProvider) async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final Size overlaySize = overlay.size;
    final Offset buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);
    
    // Position menu to align from the right side of the screen
    // Menu width is approximately 280px, so we position it 16px from the right edge
    const double menuWidth = 280.0;
    const double rightPadding = 16.0;
    final double topPosition = buttonPosition.dy + button.size.height - 16; // -16px gap below button
    
    final RelativeRect position = RelativeRect.fromLTRB(
      overlaySize.width - menuWidth - rightPadding, // Left position to align right edge
      topPosition,
      rightPadding,
      overlaySize.height - topPosition - 100, // Bottom space (approximate)
    );

    final navbarProvider = Provider.of<NavbarVisibilityProvider>(context, listen: false);
    
    // Hide navbar while showing menu
    navbarProvider.setDialogMode(true);
    navbarProvider.setNavBarVisibility(false);

    try {
      await showMenu(
        context: context,
        position: position,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        items: [
          PopupMenuItem(
            enabled: false,
            padding: EdgeInsets.zero,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                final isEnabled = homeScreenProvider.includeVacationTransactions;
                return InkWell(
                  onTap: () async {
                    final newValue = !isEnabled;
                    // Update the filter state
                    await homeScreenProvider.setIncludeVacationTransactions(newValue);
                    
                    // Close the menu
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                    
                    // Force complete reset of all providers and cache
                    if (mounted) {
                      // Clear all cached streams first
                      _pageDataManager.clearCache();
                      // Dispose and recreate all month providers to avoid stale paginated data
                      for (final provider in _monthProviders.values) {
                        provider.dispose();
                      }
                      _monthProviders.clear();

                      // Trigger a rebuild to get fresh data
                      this.setState(() {});
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.includeVacationTransaction,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryTextColorLight,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppLocalizations.of(context)!.showVacationTransactions,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondaryTextColorLight,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Switch(
                          value: isEnabled,
                          onChanged: (bool value) async {
                            // Update the filter state
                            await homeScreenProvider.setIncludeVacationTransactions(value);
                            
                            // Close the menu
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                            
                            // Force complete reset of all providers and cache
                            if (mounted) {
                              // Clear all cached streams first
                              _pageDataManager.clearCache();
                              // Dispose and recreate all month providers to avoid stale paginated data
                              for (final provider in _monthProviders.values) {
                                provider.dispose();
                              }
                              _monthProviders.clear();

                              // Trigger a rebuild to get fresh data
                              this.setState(() {});
                            }
                          },
                          activeColor: AppColors.buttonBackground,
                          activeTrackColor: AppColors.gradientEnd2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        elevation: 8,
      );
    } finally {
      // Restore navbar visibility
      if (context.mounted) {
        navbarProvider.setNavBarVisibility(true);
        navbarProvider.setDialogMode(false);
      }
    }
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
    final homeScreenProvider = context.watch<HomeScreenProvider>();

    return StreamBuilder<MonthPageData>(
      stream: vacationProvider.isVacationMode
          ? _pageDataManager.getVacationAllCurrenciesStream()
          : (_selectedMonthIndex >= 0 && _selectedMonthIndex < _months.length
              ? _pageDataManager.getStreamForMonth(
                  _selectedMonthIndex,
                  _months[_selectedMonthIndex],
                  false, // Normal mode - will fetch normal or both based on filter
                  homeScreenProvider.includeVacationTransactions,
                )
              : Stream.value(MonthPageData.loading())),
      builder: (context, monthSnapshot) {
        // Get vacation accounts to find the active one
        return StreamBuilder<List<FirestoreAccount>>(
          stream: _firestoreService.streamAccounts(),
          builder: (context, accountsSnapshot) {
            double totalBudget = 0.0;
            String? vacationAccountCurrency;

            if (accountsSnapshot.hasData &&
                vacationProvider.activeVacationAccountId != null) {
              final vacationAccounts = accountsSnapshot.data!
                  .where((account) => account.isVacationAccount == true)
                  .toList();

              final activeVacationAccount = vacationAccounts
                  .where(
                    (account) =>
                        account.id == vacationProvider.activeVacationAccountId,
                  )
                  .firstOrNull;

              if (activeVacationAccount != null) {
                totalBudget = activeVacationAccount.initialBalance;
                vacationAccountCurrency = activeVacationAccount.currency;
              }
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        // Vacation mode: show horizontal expense cards per currency
                        if (vacationProvider.isVacationMode) ...[
                          Expanded(
                            child: _buildVacationExpenseCards(
                              monthSnapshot.data?.expensesByCurrency ?? {},
                              currencyProvider,
                              monthSnapshot.data,
                              totalBudget,
                              vacationAccountCurrency,
                            ),
                          ),
                        ],
                        // Income card - only shown in normal mode
                        if (!vacationProvider.isVacationMode) ...[
                          Expanded(
                            child: _buildBalanceCard(
                              AppLocalizations.of(context)!.homeIncomeCard,
                              Colors.green,
                              HugeIcons.strokeRoundedChartUp,
                              AppColors.incomeBackground,
                              monthSnapshot.data?.incomeByCurrency ?? {},
                              currencyProvider,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        // Expense card - only shown in normal mode
                        if (!vacationProvider.isVacationMode) ...[
                          Expanded(
                            child: _buildBalanceCard(
                              AppLocalizations.of(context)!.homeExpenseCard,
                              Colors.red,
                              HugeIcons.strokeRoundedChartDown,
                              AppColors.expenseBackground,
                              monthSnapshot.data?.expensesByCurrency ?? {},
                              currencyProvider,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
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
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
              HugeIcon(icon: icon, color: color, size: 28),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
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
        ],
      ),
    );
  }

  Widget _buildBalanceCard(
    String title,
    Color color,
    List<List<dynamic>> icon,
    Color backgroundColor,
    Map<String, double> amountsByCurrency,
    CurrencyProvider currencyProvider,
  ) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
              HugeIcon(icon: icon, color: color, size: 28),
            ],
          ),
          const SizedBox(height: 8),
          // Display currency breakdown
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (amountsByCurrency.isEmpty)
                  Text(
                    title == AppLocalizations.of(context)!.analyticsIncome ? '+ 0.00' : '- 0.00',
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  ...() {
                    // Sort currencies: active currency first, then alphabetically
                    final sortedEntries = amountsByCurrency.entries.toList()
                      ..sort((a, b) {
                        final activeCurrency = currencyProvider.selectedCurrencyCode;
                        final aIsActive = a.key == activeCurrency;
                        final bIsActive = b.key == activeCurrency;
                        
                        // If one is active and the other isn't, active comes first
                        if (aIsActive && !bIsActive) return -1;
                        if (!aIsActive && bIsActive) return 1;
                        
                        // If both are active or both are not active, sort alphabetically
                        return a.key.compareTo(b.key);
                      });
                    
                    return sortedEntries.map((entry) {
                      final currency = entry.key;
                      final amount = entry.value;
                      final isSelectedCurrency =
                          currency == currencyProvider.selectedCurrencyCode;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          '${title == AppLocalizations.of(context)!.analyticsIncome ? '+' : '-'} $currency ${amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: color,
                            fontSize: isSelectedCurrency ? 16 : 14,
                            fontWeight: isSelectedCurrency
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList();
                  }(),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildVacationExpenseCards(
    Map<String, double> expensesByCurrency,
    CurrencyProvider currencyProvider,
    MonthPageData? monthData,
    double totalBudget,
    String? vacationAccountCurrency,
  ) {
    // Sort currencies: selected currency first, then alphabetically
    final entries = expensesByCurrency.entries.toList()
      ..sort((a, b) {
        final selected = currencyProvider.selectedCurrencyCode;
        final aIsSelected = a.key == selected;
        final bIsSelected = b.key == selected;
        if (aIsSelected && !bIsSelected) return -1;
        if (!aIsSelected && bIsSelected) return 1;
        return a.key.compareTo(b.key);
      });
 
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }
 
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        children: entries.map((entry) {
          final currency = entry.key;
          final expenses = entry.value;
          final isSelected = currency == currencyProvider.selectedCurrencyCode;
 
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: InkWell(
              onTap: () {
                // Build single-currency maps for dialog
                final incomeMap = <String, double>{
                  currency: monthData?.incomeByCurrency[currency] ?? 0.0
                };
                final expensesMap = <String, double>{
                  currency: monthData?.expensesByCurrency[currency] ?? 0.0
                };
                _showCurrencyBreakdownDialog(
                  context,
                  incomeMap,
                  expensesMap,
                  currencyProvider,
                  true,
                  totalBudget,
                  vacationAccountCurrency,
                );
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 160,
                height: 120,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.vacationColor,
                      AppColors.vacationColor.withOpacity(0.85)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.vacationColor.withOpacity(0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            currency,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedChartDown,
                          color: Colors.white.withOpacity(0.95),
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.analyticsExpenses,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '- $currency ${expenses.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isSelected ? 16 : 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
 
  // Helper method to get the appropriate profile image
  ImageProvider _getProfileImage() {
    final user = FirebaseAuth.instance.currentUser;
    
    // Check if user is logged in via Google and has a photo URL
    if (user != null &&
        user.providerData.any((p) => p.providerId == 'google.com') &&
        user.photoURL != null) {
      return NetworkImage(user.photoURL!);
    }
    
    // Fall back to the default asset image
    return const AssetImage('images/backgrounds/onboarding1.png');
  }
}

