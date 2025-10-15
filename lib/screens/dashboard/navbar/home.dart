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
import 'dart:math' as math;
import 'package:flutter/rendering.dart';
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
    currency: Provider.of<CurrencyProvider>(
      context,
      listen: false,
    ).selectedCurrencyCode, // New required field
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

    // Create a hash of transaction IDs to detect if data has actually changed
    final currentDataHash = data.transactionsWithAccounts
        .map((tx) => tx.transaction.id)
        .join(',')
        .hashCode
        .toString();

    // Always reset state if this is the first initialization or if data has changed
    if (!_isInitialized || currentDataHash != _lastDataHash) {
      _allTransactions = data.transactionsWithAccounts;
      _paginatedTransactions = [];
      _currentPage = 0;
      _hasReachedEnd = false;
      _error = '';
      _lastDataHash = currentDataHash;
      _isInitialized = true;

      // Load first page
      fetchNextPage();
    }
  }

  // Fetch next page of transactions
  Future<void> fetchNextPage() async {
    if (_isLoading || _hasReachedEnd) return;

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
    notifyListeners();
  }

  // Toggle paid status for a transaction locally
  void togglePaidStatus(String transactionId) {
    // Find and update in _allTransactions
    final allIndex = _allTransactions.indexWhere(
      (tx) => tx.transaction.id == transactionId,
    );
    if (allIndex != -1) {
      final oldTx = _allTransactions[allIndex];
      final updatedTransaction = oldTx.transaction.copyWith(
        paid: !(oldTx.transaction.paid ?? false),
      );
      _allTransactions[allIndex] = TransactionWithAccount(
        transaction: updatedTransaction,
        account: oldTx.account,
        category: oldTx.category,
      );
    }

    // Find and update in _paginatedTransactions
    final paginatedIndex = _paginatedTransactions.indexWhere(
      (tx) => tx.transaction.id == transactionId,
    );
    if (paginatedIndex != -1) {
      final oldTx = _paginatedTransactions[paginatedIndex];
      final updatedTransaction = oldTx.transaction.copyWith(
        paid: !(oldTx.transaction.paid ?? false),
      );
      _paginatedTransactions[paginatedIndex] = TransactionWithAccount(
        transaction: updatedTransaction,
        account: oldTx.account,
        category: oldTx.category,
      );
    }

    notifyListeners();
  }
}

// Data manager for handling and caching month-specific data streams.
class MonthPageDataManager {
  final FirestoreService _firestoreService = FirestoreService.instance;
  final VacationProvider _vacationProvider;

  // Streams for data that is constant across all months.
  // shareReplay(maxSize: 1) caches the last emitted value and shares it with new subscribers,
  // preventing redundant database calls.
  late final Stream<List<FirestoreAccount>> _allAccountsStream;
  late final Stream<List<Category>> _allCategoriesStream;

  // A cache to hold the data stream for each month index and vacation mode combination.
  final Map<String, Stream<MonthPageData>> _pageStreamCache = {};

  MonthPageDataManager(this._vacationProvider) {
    // Initialize the shared streams immediately.
    _allAccountsStream = _firestoreService.streamAccounts().shareReplay(
      maxSize: 1,
    );
    _allCategoriesStream = _firestoreService.streamCategories().shareReplay(
      maxSize: 1,
    );
  }

  Stream<MonthPageData> getStreamForMonth(
    int monthIndex,
    DateTime month,
    bool isVacation,
  ) {
    // Get the active vacation account ID when in vacation mode
    final activeVacationAccountId = isVacation
        ? _vacationProvider.activeVacationAccountId
        : null;

    // Create a composite key that includes monthIndex, isVacation status, and accountId
    final cacheKey =
        '$monthIndex-$isVacation-${activeVacationAccountId ?? 'all'}';

    print('DEBUG: getStreamForMonth - monthIndex=$monthIndex, isVacation=$isVacation, accountId=$activeVacationAccountId');
    print('DEBUG: Cache key: $cacheKey');

    // If a stream for this specific combination is already in the cache, return it.
    if (_pageStreamCache.containsKey(cacheKey)) {
      print('DEBUG: Using cached stream for key: $cacheKey');
      return _pageStreamCache[cacheKey]!;
    }
    
    print('DEBUG: Creating new stream for key: $cacheKey');

    // If not cached, create a new stream for the month.
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final stream =
        Rx.combineLatest4(
              _firestoreService.streamTransactionsForDateRange(
                startOfMonth,
                endOfMonth,
                isVacation: isVacation,
                accountId: activeVacationAccountId,
              ),
              _firestoreService.streamUpcomingTasksForDateRange(
                startOfMonth,
                endOfMonth,
              ),
              _allAccountsStream, // <-- Use the shared/replayed stream
              _allCategoriesStream, // <-- Use the shared/replayed stream
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
                final totalIncome = transactions
                    .where((transaction) => transaction.type == 'income')
                    .fold<double>(
                        0.0, (sum, transaction) => sum + transaction.amount);

                final totalExpenses = transactions
                    .where((transaction) => transaction.type == 'expense')
                    .fold<double>(
                        0.0, (sum, transaction) => sum + transaction.amount);

                return MonthPageData(
                  transactions: transactions,
                  totalIncome: totalIncome,
                  totalExpenses: totalExpenses,
                  transactionsWithAccounts: transactionsWithAccounts,
                  upcomingTasks: tasks,
                );
              },
            )
            .startWith(
              MonthPageData.loading(),
            ) // Immediately emit a loading state.
            .handleError((error) {
              return MonthPageData.error(error.toString());
            })
            .shareReplay(
              maxSize: 1,
            ); // Cache the result of this month's stream.

    // Store the newly created stream in the cache with the composite key and return it.
    _pageStreamCache[cacheKey] = stream;
    return stream;
  }

  // Method to invalidate cache for a specific month and vacation mode combination
  void invalidateMonth(int monthIndex, [bool? isVacation]) {
    print('DEBUG: Invalidating cache for monthIndex=$monthIndex, isVacation=$isVacation');
    print('DEBUG: Active vacation accountId=${_vacationProvider.activeVacationAccountId}');
    
    if (isVacation != null) {
      // Invalidate only the specific combination
      // We need to invalidate both with and without accountId to be safe
      final normalKey = '$monthIndex-$isVacation';
      final withAccountKey = '$monthIndex-$isVacation-${_vacationProvider.activeVacationAccountId ?? 'all'}';
      
      print('DEBUG: Removing cache keys: $normalKey, $withAccountKey');
      _pageStreamCache.remove(normalKey);
      _pageStreamCache.remove(withAccountKey);
      
      // Also invalidate any other vacation account keys to prevent data leakage
      if (isVacation) {
        final keysToRemove = <String>[];
        _pageStreamCache.forEach((key, value) {
          if (key.startsWith('$monthIndex-true-') && key != withAccountKey) {
            keysToRemove.add(key);
          }
        });
        print('DEBUG: Removing additional vacation account keys to prevent leakage: $keysToRemove');
        for (final key in keysToRemove) {
          _pageStreamCache.remove(key);
        }
      }
    } else {
      // Invalidate both vacation and normal mode for this month
      final normalKey = '$monthIndex-false';
      final vacationKey = '$monthIndex-true';
      print('DEBUG: Removing cache keys: $normalKey, $vacationKey');
      _pageStreamCache.remove(normalKey);
      _pageStreamCache.remove(vacationKey);
      
      // Also invalidate all account-specific keys
      final keysToRemove = <String>[];
      _pageStreamCache.forEach((key, value) {
        if (key.startsWith('$monthIndex-')) {
          keysToRemove.add(key);
        }
      });
      print('DEBUG: Removing all account-specific keys for month $monthIndex: $keysToRemove');
      for (final key in keysToRemove) {
        _pageStreamCache.remove(key);
      }
    }
    
    print('DEBUG: Cache invalidation complete. Remaining cache keys: ${_pageStreamCache.keys.toList()}');
  }

  // Method to clear the cache if a full refresh is needed (e.g., on user logout/login).
  void clearCache() {
    _pageStreamCache.clear();
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

    // Set up scroll listener for pagination
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
      widget.dataManager
          .getStreamForMonth(widget.monthIndex, widget.month, widget.isVacation)
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

          // Listen to the stream for data updates
          return StreamBuilder<MonthPageData>(
            stream: widget.dataManager.getStreamForMonth(
              widget.monthIndex,
              widget.month,
              widget.isVacation,
            ),
            builder: (context, snapshot) {
              // Update provider when new data arrives
              if (snapshot.hasData &&
                  !snapshot.data!.isLoading &&
                  snapshot.data!.error == null) {
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
        child: SizedBox(
          height: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30.0,
              vertical: 130.0,
            ),
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
              itemCount:
                  sortedKeys.length +
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
                        'No more transactions',
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
                  'Error loading more transactions',
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
              'Retry',
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white),
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
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
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
    final bool isVacationTransaction = account?.isVacationAccount ?? false;

    return InkWell(
      onTap: () async {
        final result = await PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: ExpenseDetailScreen(transaction: uiTransaction),
          withNavBar: false,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );

        if (result == true) {
          // Use local state update instead of full data refresh
          _provider.togglePaidStatus(uiTransaction.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // color: isVacationTransaction ? Colors.blue.shade50 : Colors.white,
          color: transaction.linkedTransactionId != null ? Colors.blue.shade50 : Colors.white,
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
                  Text(
                    transactionWithAccount.category?.name ??
                        transaction.description,
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
                  transaction.paid == true
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: transaction.paid == true ? Colors.green : Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${transaction.type == 'income' ? '+' : '-'} ${currencyProvider.currencySymbol}${(transaction.amount * currencyProvider.conversionRate).toStringAsFixed(2)}',
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

  bool _isTogglingVacationMode = false;

  double _lastContentOffset = 0.0;

  // Map to hold MonthPageProvider instances for each month
  final Map<int, MonthPageProvider> _monthProviders = {};

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService.instance;
    _monthScrollController = ScrollController();
    _pageController = PageController();
    _lastContentOffset = 0.0;

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

    // Pre-load next month
    if (currentIndex + 1 < _months.length) {
      final nextProvider = _getOrCreateProvider(currentIndex + 1);
      if (nextProvider.allTransactions.isEmpty) {
        final nextStream = _pageDataManager.getStreamForMonth(
          currentIndex + 1,
          _months[currentIndex + 1],
          isVacation,
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
          final homeScreenProvider = Provider.of<HomeScreenProvider>(
            context,
            listen: false,
          );
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

          // Initialize provider for the initial month
          final isVacation = Provider.of<VacationProvider>(
            context,
            listen: false,
          ).isVacationMode;
          final provider = _getOrCreateProvider(_selectedMonthIndex);

          // Only initialize if the provider hasn't been initialized yet
          if (provider.allTransactions.isEmpty) {
            final stream = _pageDataManager.getStreamForMonth(
              _selectedMonthIndex,
              _months[_selectedMonthIndex],
              isVacation,
            );
            stream.first.then((data) {
              if (mounted && !data.isLoading && data.error == null) {
                provider.initialize(data);
              }
            });
          }
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
        final isVacation = Provider.of<VacationProvider>(
          context,
          listen: false,
        ).isVacationMode;
        _pageDataManager.invalidateMonth(_selectedMonthIndex, isVacation);

        // Reset the provider for the current month
        if (_monthProviders.containsKey(_selectedMonthIndex)) {
          _monthProviders[_selectedMonthIndex]!.reset();
        }
        // Mark refresh as complete
        homeScreenProvider.completeRefresh();
        // Trigger a rebuild
        if (mounted) setState(() {});
      });
    }
    // Check for account-specific refresh
    else if (homeScreenProvider.shouldRefreshAccounts) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Invalidate all cached months
        final isVacation = Provider.of<VacationProvider>(
          context,
          listen: false,
        ).isVacationMode;
        for (final monthIndex in _monthProviders.keys) {
          _pageDataManager.invalidateMonth(monthIndex, isVacation);
          _monthProviders[monthIndex]!.reset();
        }
        homeScreenProvider.completeRefresh();
        if (mounted) setState(() {});
      });
    }
    // Check for transaction-specific refresh
    else if (homeScreenProvider.shouldRefreshTransactions) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Invalidate all cached months
        final isVacation = Provider.of<VacationProvider>(
          context,
          listen: false,
        ).isVacationMode;
        for (final monthIndex in _monthProviders.keys) {
          _pageDataManager.invalidateMonth(monthIndex, isVacation);
          _monthProviders[monthIndex]!.reset();
        }
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
                          final homeScreenProvider =
                              Provider.of<HomeScreenProvider>(
                                context,
                                listen: false,
                              );
                          homeScreenProvider.setSelectedDate(_months[index]);

                          _scrollToSelectedMonth();

                          // Pre-load adjacent months after the page change is complete
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _preloadAdjacentMonths(index);
                          });
                        },
                        itemBuilder: (context, index) {
                          final vacationProvider =
                              Provider.of<VacationProvider>(
                                context,
                                listen: false,
                              );
                          final isVacation = vacationProvider.isVacationMode;
                          // Get or create provider for this month and pass it to MonthPageView
                          final provider = _getOrCreateProvider(index);
                          return MonthPageView(
                            key: ValueKey<String>('$index-$isVacation'),
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

  Widget _buildAppBar(BuildContext context) {
    final vacationProvider = context.watch<VacationProvider>();
    final currencyProvider = context.watch<CurrencyProvider>();
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final isVacation = vacationProvider.isVacationMode;

    return StreamBuilder<List<FirestoreAccount>>(
      stream: _firestoreService.streamAccounts(),
      builder: (context, accountsSnapshot) {
        double totalBudget = 0.0;

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
          }
        }

        return StreamBuilder<MonthPageData>(
          stream:
              _selectedMonthIndex >= 0 && _selectedMonthIndex < _months.length
              ? _pageDataManager.getStreamForMonth(
                  _selectedMonthIndex,
                  _months[_selectedMonthIndex],
                  isVacation,
                )
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
                                  PageTransitionAnimation.slideRight,
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
                              _selectedMonthIndex < _months.length &&
                                      _selectedMonthIndex >= 0
                                  ? DateFormat(
                                      'MMMM',
                                    ).format(_months[_selectedMonthIndex])
                                  : 'Balance',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              vacationProvider.isVacationMode
                                  ? '${currencyProvider.currencySymbol} ${((totalBudget - totalExpenses) * currencyProvider.conversionRate).toStringAsFixed(2)}'
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
                            final vacationProvider =
                                Provider.of<VacationProvider>(
                                  context,
                                  listen: false,
                                );
                            final currentVacationMode =
                                vacationProvider.isVacationMode;

                            if (currentVacationMode) {
                              await vacationProvider.setVacationMode(false);
                            } else {
                              await vacationProvider.checkAndShowVacationDialog(
                                context,
                              );
                            }

                            // It's crucial to read the new state *after* the async operations.
                            final newVacationMode =
                                vacationProvider.isVacationMode;

                            // Only proceed if the mode actually changed.
                            if (newVacationMode != currentVacationMode) {
                              // NOW, we trigger the rebuild and data refresh.
                              setState(() {
                                // Reset all providers and clear the entire page cache to force a full refresh.
                                for (final provider in _monthProviders.values) {
                                  provider.reset();
                                }

                                // Recreate the MonthPageDataManager to force stream re-creation
                                final vacationProvider =
                                    Provider.of<VacationProvider>(
                                      context,
                                      listen: false,
                                    );
                                _pageDataManager = MonthPageDataManager(
                                  vacationProvider,
                                );
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
          ? _pageDataManager.getStreamForMonth(
              _selectedMonthIndex,
              _months[_selectedMonthIndex],
              isVacation,
            )
          : Stream.value(MonthPageData.loading()),
      builder: (context, monthSnapshot) {
        final totalIncome = monthSnapshot.data?.totalIncome ?? 0.0;
        final totalExpenses = monthSnapshot.data?.totalExpenses ?? 0.0;

        // Get vacation accounts to find the active one
        return StreamBuilder<List<FirestoreAccount>>(
          stream: _firestoreService.streamAccounts(),
          builder: (context, accountsSnapshot) {
            double totalBudget = 0.0;

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
              }
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  // Total Budget card - only shown in vacation mode
                  if (vacationProvider.isVacationMode)
                    Expanded(
                      child: _buildInfoCard(
                        'Total Budget',
                        '${currencyProvider.currencySymbol}${(totalBudget * currencyProvider.conversionRate).toStringAsFixed(2)}',
                        Colors.blue,
                        HugeIcons.strokeRoundedWallet01,
                        Colors.blue.shade50,
                      ),
                    ),
                  if (vacationProvider.isVacationMode)
                    const SizedBox(width: 12),
                  // Income card - only shown in normal mode
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
                  // Expense card - shown in both modes
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
}
