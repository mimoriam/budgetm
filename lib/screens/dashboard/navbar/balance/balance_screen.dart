import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/models/firestore_transaction.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/models/firestore_account.dart';
import 'package:budgetm/viewmodels/currency_provider.dart';
import 'package:budgetm/viewmodels/home_screen_provider.dart';
import 'package:budgetm/viewmodels/navbar_visibility_provider.dart';
import 'package:budgetm/viewmodels/vacation_mode_provider.dart';
import 'package:budgetm/screens/dashboard/navbar/balance/balance_detail_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'dart:async';
import 'dart:math';

import 'package:budgetm/screens/dashboard/navbar/balance/add_account/add_account_screen.dart';
import 'package:budgetm/utils/account_icon_utils.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({super.key});

  @override
  State<BalanceScreen> createState() => _BalanceScreenHolderState();
}

/// A thin holder state that renders the actual stateful body widget.
/// This change converts the original `_BalanceScreenState` into a
/// `StatefulWidget` (`_BalanceScreenState`) as requested, while keeping
/// `BalanceScreen` as the entrypoint.
class _BalanceScreenHolderState extends State<BalanceScreen> {
  @override
  Widget build(BuildContext context) {
    return const _BalanceScreenState();
  }
}

/// Converted from the previous `_BalanceScreenState` `State` into a
/// `StatefulWidget`. Its `State` (`_BalanceScreenStateInner`) holds the
/// stream subscriptions and UI logic.
class _BalanceScreenState extends StatefulWidget {
  const _BalanceScreenState();

  @override
  State<_BalanceScreenState> createState() => _BalanceScreenStateInner();
}

class _BalanceScreenStateInner extends State<_BalanceScreenState> {
  int touchedIndex = -1;
  late ScrollController _scrollController;
  late FirestoreService _firestoreService;
  Stream<dynamic>? _accountsWithTransactionsStream;

  StreamController<dynamic>? _accountsWithTransactionsController;
  StreamSubscription<List<FirestoreAccount>>? _accountsSub;
  StreamSubscription<List<FirestoreTransaction>>? _transactionsSub;
  List<FirestoreAccount>? _latestAccounts;
  List<FirestoreTransaction>? _latestTransactions;

  // Keep a reference to the VacationProvider and a listener so we can
  // re-evaluate filtering when vacation mode changes.
  VacationProvider? _vacationProvider;
  VoidCallback? _vacationListener;
  String? _selectedChartCurrency; // For chart currency selection
  
  // Add HomeScreenProvider listener for transaction updates
  HomeScreenProvider? _homeScreenProvider;
  VoidCallback? _homeScreenListener;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final provider = Provider.of<NavbarVisibilityProvider>(
        context,
        listen: false,
      );
      final direction = _scrollController.position.userScrollDirection;

      if (direction == ScrollDirection.reverse) {
        provider.setNavBarVisibility(false);
      } else if (direction == ScrollDirection.forward) {
        provider.setNavBarVisibility(true);
      }
    });

    _initStreams();

    // Subscribe to VacationProvider changes so the account list is re-filtered
    // immediately when vacation mode toggles. We use listen: false here and
    // add a ChangeNotifier listener to avoid rebuilding the whole widget.
    _vacationProvider = Provider.of<VacationProvider>(context, listen: false);
    _vacationListener = () {
      if (!mounted) return;
      // Recompute and emit combined data using the latest cached accounts/transactions.
      _tryEmitCombined();
    };
    _vacationProvider?.addListener(_vacationListener!);
    
    // Subscribe to HomeScreenProvider changes for transaction updates
    _homeScreenProvider = Provider.of<HomeScreenProvider>(context, listen: false);
    _homeScreenListener = () {
      if (!mounted) return;
      // Force recomputation when transactions are updated
      if (_homeScreenProvider!.shouldRefreshTransactions || _homeScreenProvider!.shouldRefresh) {
        _tryEmitCombined();
        _homeScreenProvider!.completeRefresh();
      }
    };
    _homeScreenProvider?.addListener(_homeScreenListener!);
  }

  void _initStreams() {
    _firestoreService = FirestoreService.instance;

    _accountsWithTransactionsController = StreamController<dynamic>.broadcast();
    _accountsWithTransactionsStream =
        _accountsWithTransactionsController!.stream;

    _accountsSub = _firestoreService.streamAccounts().listen((accounts) {
      _latestAccounts = accounts;
      _tryEmitCombined();
    });

    _transactionsSub = _firestoreService.streamTransactions().listen((
      transactions,
    ) {
      _latestTransactions = transactions;
      _tryEmitCombined();
    });
  }

  void _tryEmitCombined() {
    if (_latestAccounts == null || _latestTransactions == null) return;

    // Check if HomeScreenProvider has refresh flags set and trigger refresh if needed
    final homeScreenProvider = Provider.of<HomeScreenProvider>(context, listen: false);
    if (homeScreenProvider.shouldRefreshTransactions || homeScreenProvider.shouldRefresh) {
      homeScreenProvider.completeRefresh();
      // Force a fresh data fetch by re-emitting
      _tryEmitCombined();
      return;
    }

    final transactions = _latestTransactions!;
    final allAccounts = _latestAccounts!;
    final defaultAccountIds = allAccounts
        .where((acc) => acc.isDefault ?? false)
        .map((acc) => acc.id)
        .toSet();

    // Read vacation mode state
    final vacationProvider = Provider.of<VacationProvider>(
      context,
      listen: false,
    );
    final isVacationMode = vacationProvider.isVacationMode;

    // For normal mode: compute net transaction amounts (income positive, expense negative) for paid txns
    final transactionAmounts = <String, double>{};
    final transactionCounts = <String, int>{};
    for (var transaction in transactions) {
      final accId = transaction.accountId;
      if (accId == null || defaultAccountIds.contains(accId)) continue;
      if (transaction.paid == true) {
        final isIncome =
            transaction.type.toString().toLowerCase().contains('income');
        final txnAmount = isIncome ? transaction.amount : -transaction.amount;
        transactionAmounts.update(
          accId,
          (v) => v + txnAmount,
          ifAbsent: () => txnAmount,
        );
        transactionCounts.update(
          accId,
          (v) => v + 1,
          ifAbsent: () => 1,
        );
      }
    }

    // For vacation mode: compute total expenses ever made for each account (only paid transactions)
    final expenseSums = <String, double>{};
    final vacationTransactionCounts = <String, int>{};
    for (var transaction in transactions) {
      final accId = transaction.accountId;
      if (accId == null) continue;
      
      final isExpense =
          transaction.type.toString().toLowerCase().contains('expense');
      
      // For vacation mode, we need to process ALL transactions, including those on default accounts
      // if they are linked to vacation accounts
      
      // Count all transactions (paid and unpaid) for transaction count
      vacationTransactionCounts.update(
        accId,
        (v) => v + 1,
        ifAbsent: () => 1,
      );
      
      // Only count paid expenses for balance calculation
      if (isExpense && transaction.paid == true) {
        // For vacation transactions, count expenses for both normal and vacation accounts (only paid)
        expenseSums.update(
          accId,
          (v) => v + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
        // If this is a vacation transaction, also count it for the linked vacation account
        if (transaction.isVacation == true &&
            transaction.linkedVacationAccountId != null) {
          final vacationAccId = transaction.linkedVacationAccountId!;
          expenseSums.update(
            vacationAccId,
            (v) => v + transaction.amount,
            ifAbsent: () => transaction.amount,
          );
          vacationTransactionCounts.update(
            vacationAccId,
            (v) => v + 1,
            ifAbsent: () => 1,
          );
        }
      }
    }

    // In vacation mode, separate normal and vacation accounts (same as normal mode)
    if (isVacationMode) {
      final nonDefaultAccounts = allAccounts
          .where((account) => !(account.isDefault ?? false))
          .toList();

      final normalAccounts = nonDefaultAccounts
          .where((account) => (account.isVacationAccount != true))
          .map((account) {
        final transactionsAmount = transactionAmounts[account.id] ?? 0.0;
        // Calculate balance from initial balance + paid transactions
        final finalBalance = account.initialBalance + transactionsAmount;
        return {
          'account': account,
          'transactionsAmount': transactionsAmount,
          'finalBalance': finalBalance,
          'transactionCount': transactionCounts[account.id] ?? 0,
        };
      }).toList();

      final vacationAccounts = nonDefaultAccounts
          .where((account) => (account.isVacationAccount == true))
          .map((account) {
        final totalExpenses = expenseSums[account.id] ?? 0.0;
        final finalBalance = max(0.0, account.initialBalance - totalExpenses);
        // Diagnostics to confirm all values are doubles at runtime
        print(
            'DEBUG BalanceScreen: vacationMode vacation finalBalance accountId=${account.id} '
            'initial=${account.initialBalance}(${account.initialBalance.runtimeType}) '
            'totalExpenses=$totalExpenses(${totalExpenses.runtimeType}) '
            'final=$finalBalance(${finalBalance.runtimeType})');
        return {
          'account': account,
          'transactionsAmount': finalBalance,
          'finalBalance': finalBalance,
          'transactionCount': vacationTransactionCounts[account.id] ?? 0,
        };
      }).toList();

      // Emit a Map with both lists (same structure as normal mode)
      _accountsWithTransactionsController?.add({
        'normal_accounts': normalAccounts,
        'vacation_accounts': vacationAccounts,
      });
      return;
    }

    // In normal mode, separate normal and vacation accounts
    final nonDefaultAccounts = allAccounts
        .where((account) => !(account.isDefault ?? false))
        .toList();

    final normalAccounts = nonDefaultAccounts
        .where((account) => (account.isVacationAccount != true))
        .map((account) {
      final transactionsAmount = transactionAmounts[account.id] ?? 0.0;
      // Calculate balance from initial balance + paid transactions
      final finalBalance = account.initialBalance + transactionsAmount;
      return {
        'account': account,
        'transactionsAmount': transactionsAmount,
        'finalBalance': finalBalance,
        'transactionCount': transactionCounts[account.id] ?? 0,
      };
    }).toList();

    final vacationAccounts = nonDefaultAccounts
        .where((account) => (account.isVacationAccount == true))
        .map((account) {
      final totalExpenses = expenseSums[account.id] ?? 0.0;
      final finalBalance = max(0.0, account.initialBalance - totalExpenses);
      // Diagnostics to confirm all values are doubles at runtime
      print(
          'DEBUG BalanceScreen: normalMode vacation finalBalance accountId=${account.id} '
          'initial=${account.initialBalance}(${account.initialBalance.runtimeType}) '
          'totalExpenses=$totalExpenses(${totalExpenses.runtimeType}) '
          'final=$finalBalance(${finalBalance.runtimeType})');
      return {
        'account': account,
        'transactionsAmount': finalBalance,
        'finalBalance': finalBalance,
        'transactionCount': vacationTransactionCounts[account.id] ?? 0,
      };
    }).toList();

    // Emit a Map with both lists
    _accountsWithTransactionsController?.add({
      'normal_accounts': normalAccounts,
      'vacation_accounts': vacationAccounts,
    });
  }

  @override
  void dispose() {
    // Remove vacation listener if attached
    if (_vacationProvider != null && _vacationListener != null) {
      _vacationProvider!.removeListener(_vacationListener!);
    }
    
    // Remove home screen listener if attached
    if (_homeScreenProvider != null && _homeScreenListener != null) {
      _homeScreenProvider!.removeListener(_homeScreenListener!);
    }

    _scrollController.dispose();
    _accountsSub?.cancel();
    _transactionsSub?.cancel();
    _accountsWithTransactionsController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: _buildCustomAppBar(context),
          ),
          body: StreamBuilder<dynamic>(
            stream: _accountsWithTransactionsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              // If there's no data at all, fall back to a simple message
              if (!snapshot.hasData) {
                return const Center(child: Text('No accounts found.'));
              }

              final vacationProvider = Provider.of<VacationProvider>(
                context,
                listen: false,
              );
              final isVacationMode = vacationProvider.isVacationMode;

              List<Map<String, dynamic>> normalAccounts = [];
              List<Map<String, dynamic>> vacationAccounts = [];

              if (isVacationMode) {
                // In vacation mode, data is now a Map with two lists (same as normal mode)
                if (snapshot.data is Map) {
                  final data = snapshot.data as Map<String, dynamic>;
                  normalAccounts =
                      data['normal_accounts'] as List<Map<String, dynamic>>;
                  vacationAccounts =
                      data['vacation_accounts'] as List<Map<String, dynamic>>;

                  // Show new empty state structure if both lists are empty
                  if (normalAccounts.isEmpty && vacationAccounts.isEmpty) {
                    return _buildNewEmptyState();
                  }
                }
              } else {
                // In normal mode, data is a Map with two lists
                if (snapshot.data is Map) {
                  final data = snapshot.data as Map<String, dynamic>;
                  normalAccounts =
                      data['normal_accounts'] as List<Map<String, dynamic>>;
                  vacationAccounts =
                      data['vacation_accounts'] as List<Map<String, dynamic>>;

                  // Show new empty state structure if both lists are empty
                  if (normalAccounts.isEmpty && vacationAccounts.isEmpty) {
                    return _buildNewEmptyState();
                  }
                }
              }

              // Check if we should show charts (2+ accounts for same currency)
              final allAccounts = [...normalAccounts, ...vacationAccounts];
              final shouldShowCharts = _shouldShowCharts(allAccounts);

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Show chart only if 2+ accounts exist for same currency
                          if (shouldShowCharts) ...[
                            _buildPieChart(allAccounts),
                            const SizedBox(height: 16),
                            _buildLegend(allAccounts),
                            const SizedBox(height: 24),
                          ] else if (allAccounts.isNotEmpty) ...[
                            // Show logo with currency picker when 1 account exists
                            _buildSingleAccountView(allAccounts),
                            const SizedBox(height: 24),
                          ],
                          // My Accounts section
                          _buildSectionHeaderWithButton(
                            'MY ACCOUNTS',
                            () async {
                              final vacationProvider =
                                  Provider.of<VacationProvider>(
                                context,
                                listen: false,
                              );
                              final isVacationMode =
                                  vacationProvider.isVacationMode;
                              final result =
                                  await PersistentNavBarNavigator.pushNewScreen(
                                context,
                                screen: AddAccountScreen(
                                    isCreatingVacationAccount:
                                        isVacationMode),
                                withNavBar: false,
                                pageTransitionAnimation:
                                    PageTransitionAnimation.cupertino,
                              );
                              if (result == true) {
                                if (mounted) setState(() {});
                              }
                            },
                          ),
                          const SizedBox(height: 6),
                          if (normalAccounts.isEmpty)
                            _buildMyAccountsEmptyCard()
                          else
                            ...normalAccounts.asMap().entries.map(
                                  (entry) => Column(
                                    children: [
                                      Builder(
                                        builder: (context) {
                                          final index = entry.key;
                                          final accountData = entry.value;
                                          final account =
                                              accountData['account']
                                                  as FirestoreAccount;
                                          final finalBalance =
                                              accountData['finalBalance']
                                                  as double;
                                          final isHighlighted =
                                              index == touchedIndex;
                                          return _buildAccountCard(
                                            context: context,
                                            account: account,
                                            icon: getAccountIcon(
                                              account.accountType,
                                            )[0][0],
                                            iconColor: Colors.black,
                                            iconBackgroundColor:
                                                Colors.grey.shade200,
                                            accountName: account.name,
                                            amount: finalBalance,
                                            accountType: account.accountType,
                                            creditLimit: account.creditLimit,
                                            balanceLimit: account.balanceLimit,
                                            currencySymbol:
                                                _getAccountCurrencySymbol(
                                                    account),
                                            isHighlighted: isHighlighted,
                                            accountsCount:
                                                normalAccounts.length,
                                            transactionCount:
                                                accountData['transactionCount']
                                                    as int,
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 6),
                                    ],
                                  ),
                                ),

                          // Vacation Accounts section (always shown)
                          const SizedBox(height: 24),
                          _buildSectionHeaderWithButton(
                            'VACATION',
                            () async {
                              final result =
                                  await PersistentNavBarNavigator.pushNewScreen(
                                context,
                                screen: const AddAccountScreen(
                                    isCreatingVacationAccount: true),
                                withNavBar: false,
                                pageTransitionAnimation:
                                    PageTransitionAnimation.cupertino,
                              );
                              if (result == true) {
                                if (mounted) setState(() {});
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          if (vacationAccounts.isEmpty)
                            _buildVacationEmptyCard()
                          else
                            ...vacationAccounts.map(
                              (accountData) => Column(
                                children: [
                                  _buildAccountCard(
                                    context: context,
                                    account: accountData['account']
                                        as FirestoreAccount,
                                    icon: getAccountIcon(
                                      (accountData['account']
                                              as FirestoreAccount)
                                          .accountType,
                                    )[0][0],
                                    iconColor: Colors.black,
                                    iconBackgroundColor: Colors.grey.shade200,
                                    accountName: (accountData['account']
                                            as FirestoreAccount)
                                        .name,
                                    amount:
                                        accountData['finalBalance'] as double,
                                    accountType: (accountData['account']
                                            as FirestoreAccount)
                                        .accountType,
                                    creditLimit: (accountData['account']
                                            as FirestoreAccount)
                                        .creditLimit,
                                    balanceLimit: (accountData['account']
                                            as FirestoreAccount)
                                        .balanceLimit,
                                    currencySymbol: _getAccountCurrencySymbol(
                                        accountData['account']
                                            as FirestoreAccount),
                                    isHighlighted: false,
                                    accountsCount: vacationAccounts.length,
                                    transactionCount:
                                        accountData['transactionCount'] as int,
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Consumer<VacationProvider>(
      builder: (context, vacationProvider, child) {
        return Container(
          padding: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            border: Border.all(color: Colors.grey.shade300, width: 1.0),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Balance',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                  ),
                  // Add Account button - only visible in normal mode
                  if (!vacationProvider.isVacationMode)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        shape: BoxShape.rectangle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.gradientStart,
                            AppColors.gradientEnd,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add,
                              size: 16,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              "Add Account",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        onPressed: () async {
                          final result =
                              await PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: const AddAccountScreen(),
                            withNavBar: false,
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                          if (result == true) {
                            if (mounted) setState(() {});
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPieChart(List<Map<String, dynamic>> accountsWithData) {
    if (accountsWithData.isEmpty) {
      return const SizedBox(height: 250);
    }

    // Get available currencies from the data
    final availableCurrencies = _getAvailableCurrencies(accountsWithData);
    // Set default chart currency if not set
    if (_selectedChartCurrency == null && availableCurrencies.isNotEmpty) {
      _selectedChartCurrency = availableCurrencies.first;
    }

    // Filter data to only include accounts with the selected currency
    final filteredData = _selectedChartCurrency != null
        ? accountsWithData.where((accountData) {
            final account = accountData['account'] as FirestoreAccount;
            return account.currency == _selectedChartCurrency;
          }).toList()
        : accountsWithData;

    if (filteredData.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 200),
          Center(
            child: Text(
              'No accounts found for selected currency',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Account Balance',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Currency dropdown
                  if (availableCurrencies.length > 1)
                    _buildCompactCurrencyDropdown(availableCurrencies),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 0,
                centerSpaceRadius: 0,
                sections: showingSections(filteredData),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections(
    List<Map<String, dynamic>> accountsWithData,
  ) {
    if (accountsWithData.isEmpty) {
      return [];
    }

    // Define a list of colors for the pie chart sections
    final colors = [
      const Color(0xFF2563EB),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
    ];

    return List.generate(accountsWithData.length, (i) {
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 120.0 : 100.0;
      final accountData = accountsWithData[i];
      final account = accountData['account'] as FirestoreAccount;
      final value = account.isVacationAccount == true 
        ? account.initialBalance 
        : accountData['finalBalance'] as double;

      return PieChartSectionData(
        color: colors[i % colors.length],
        value: value,
        title: '',
        radius: radius,
      );
    });
  }

  Widget _buildLegend(
    List<Map<String, dynamic>> accountsWithData,
  ) {
    if (accountsWithData.isEmpty) {
      return const SizedBox.shrink();
    }

    // Filter data to only include accounts with the selected currency
    final filteredData = _selectedChartCurrency != null
        ? accountsWithData.where((accountData) {
            final account = accountData['account'] as FirestoreAccount;
            return account.currency == _selectedChartCurrency;
          }).toList()
        : accountsWithData;

    if (filteredData.isEmpty) {
      return const SizedBox.shrink();
    }

    // Define a list of colors for the legend items
    final colors = [
      const Color(0xFF2563EB),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
    ];

    return Column(
      children: [
        ...filteredData.asMap().entries.map((entry) {
          final index = entry.key;
          final accountData = entry.value;
          final account = accountData['account'] as FirestoreAccount;
          final finalBalance = accountData['finalBalance'] as double;
          return Column(
            children: [
              _buildLegendItem(
                colors[index % colors.length],
                account.name,
                account.isVacationAccount == true ? account.initialBalance : finalBalance,
                _getAccountCurrencySymbol(account),
              ),
              if (index < filteredData.length - 1)
                const SizedBox(height: 12),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildLegendItem(
    Color color,
    String label,
    double amount,
    String currencySymbol,
  ) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        const Spacer(),
        Text(
          '$currencySymbol${amount.toStringAsFixed(2)}',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSectionHeaderWithButton(String title, VoidCallback onPressed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryTextColorLight,
                fontWeight: FontWeight.bold,
              ),
        ),
        Semantics(
          button: true,
          label: 'Add new account',
          child: IconButton(
            onPressed: onPressed,
            icon: const Icon(Icons.add, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountCard({
    required BuildContext context,
    required FirestoreAccount account,
    required dynamic icon,
    required Color iconColor,
    required Color iconBackgroundColor,
    required String accountName,
    required double amount,
    required String accountType,
    double? creditLimit,
    double? balanceLimit,
    required String currencySymbol,
    required bool isHighlighted,
    required int accountsCount,
    required int transactionCount,
  }) {
    // Check if this is a vacation account
    final isVacationAccount = account.isVacationAccount == true;
    // Use vacation-specific icon and styling for vacation accounts
    final vacationIcon = HugeIcons.strokeRoundedAirplaneMode;
    final displayIcon = isVacationAccount ? vacationIcon : icon;
    final displayIconColor =
        isVacationAccount ? Colors.blue.shade600 : iconColor;
    final displayIconBackgroundColor =
        isVacationAccount ? Colors.blue.shade50 : iconBackgroundColor;
    // Apply vacation styling similar to home.dart
    final cardBackgroundColor = isVacationAccount
        ? Colors.blue.shade50 // Light blue background for vacation accounts
        : (isHighlighted
            ? AppColors.gradientStart.withOpacity(0.08)
            : Colors.white);
    final cardBorderColor = isVacationAccount
        ? Colors.blue.shade300 // Blue border for vacation accounts
        : (isHighlighted
            ? AppColors.gradientStart
            : Colors.grey.shade200);
    final cardBorderWidth =
        isVacationAccount ? 1.5 : (isHighlighted ? 2.0 : 1.0);
    return GestureDetector(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: BalanceDetailScreen(
            account: account,
            accountsCount: accountsCount,
          ),
          withNavBar: false,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: cardBorderColor,
            width: cardBorderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(isHighlighted ? 0.12 : 0.08),
              spreadRadius: 1,
              blurRadius: isHighlighted ? 12 : 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: displayIconBackgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child:
                  HugeIcon(icon: displayIcon, size: 24, color: displayIconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    accountName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    accountType,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.secondaryTextColorLight,
                        ),
                  ),
                  // Text(
                  //   '$transactionCount transactions',
                  //   style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  //         color: AppColors.secondaryTextColorLight,
                  //       ),
                  // ),
                  if (creditLimit != null)
                    Text(
                      'Credit Limit: ${_getAccountCurrencySymbol(account)}${creditLimit.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.secondaryTextColorLight,
                          ),
                    )
                  else if (balanceLimit != null)
                    Text(
                      'Balance Limit: ${_getAccountCurrencySymbol(account)}${balanceLimit.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.secondaryTextColorLight,
                          ),
                    ),
                ],
              ),
            ),
            Text(
              isVacationAccount 
                ? account.initialBalance.toStringAsFixed(2)
                : '${_getAccountCurrencySymbol(account)} ${amount.toStringAsFixed(2)}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  String _getAccountCurrencySymbol(FirestoreAccount account) {
    // For vacation accounts, don't show currency symbol as they are multi-currency
    if (account.isVacationAccount == true) {
      return '';
    }
    // Return currency code instead of symbol
    return account.currency;
  }


  Widget _buildNewEmptyState() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account Balance card with currency selector
          _buildEmptyAccountBalanceCard(),
          const SizedBox(height: 24),
          
          // MY ACCOUNTS section
          _buildSectionHeaderWithButton(
            'MY ACCOUNTS',
            () async {
              final vacationProvider =
                  Provider.of<VacationProvider>(
                context,
                listen: false,
              );
              final isVacationMode =
                  vacationProvider.isVacationMode;
              final result =
                  await PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: AddAccountScreen(
                    isCreatingVacationAccount:
                        isVacationMode),
                withNavBar: false,
                pageTransitionAnimation:
                    PageTransitionAnimation.cupertino,
              );
              if (result == true) {
                if (mounted) setState(() {});
              }
            },
          ),
          const SizedBox(height: 6),
          _buildMyAccountsEmptyCard(),
          
          // VACATION section
          const SizedBox(height: 24),
          _buildSectionHeaderWithButton(
            'VACATION',
            () async {
              final result =
                  await PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: const AddAccountScreen(
                    isCreatingVacationAccount: true),
                withNavBar: false,
                pageTransitionAnimation:
                    PageTransitionAnimation.cupertino,
              );
              if (result == true) {
                if (mounted) setState(() {});
              }
            },
          ),
          const SizedBox(height: 12),
          _buildVacationEmptyCard(),
        ],
      ),
    );
  }

  Widget _buildEmptyAccountBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Account Balance',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              // Currency dropdown placeholder - could be enhanced later
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              //   decoration: BoxDecoration(
              //     color: Colors.grey.shade100,
              //     borderRadius: BorderRadius.circular(8),
              //     border: Border.all(color: Colors.grey.shade300),
              //   ),
              //   child: Text(
              //     'USD',
              //     style: const TextStyle(
              //       fontSize: 11,
              //       fontWeight: FontWeight.w600,
              //       color: Colors.black,
              //     ),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 20),
          // Show app logo
          Image.asset(
            'images/launcher/logo.png',
            width: 120,
            height: 120,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No accounts created',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first account to start tracking balances',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyAccountsEmptyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No accounts created',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first account to start tracking your finances',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVacationEmptyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.flight_takeoff_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No vacations yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first vacation account to start planning your trips',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get available currencies from account data
  List<String> _getAvailableCurrencies(
      List<Map<String, dynamic>> accountsWithData) {
    final currencies = accountsWithData.map((accountData) {
      final account = accountData['account'] as FirestoreAccount;
      return account.currency;
    }).toSet().toList();
    // Filter out "MULTI" currencies to prevent showing "MULTI MULTI" in vacation mode
    currencies
        .removeWhere((currency) => currency.toUpperCase().contains('MULTI'));
    currencies.sort(); // Sort for consistent ordering
    return currencies;
  }

  // Helper method to build compact currency dropdown
  Widget _buildCompactCurrencyDropdown(List<String> availableCurrencies) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedChartCurrency,
          isDense: true,
          isExpanded: false,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          items: availableCurrencies.map((String currency) {
            return DropdownMenuItem<String>(
              value: currency,
              child: Text(currency),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedChartCurrency = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  // Helper method to determine if charts should be shown
  bool _shouldShowCharts(List<Map<String, dynamic>> accountsWithData) {
    if (accountsWithData.isEmpty) return false;
    
    // Get available currencies from the data
    final availableCurrencies = _getAvailableCurrencies(accountsWithData);
    
    // Check if any currency has 2+ accounts
    for (final currency in availableCurrencies) {
      final accountsForCurrency = accountsWithData.where((accountData) {
        final account = accountData['account'] as FirestoreAccount;
        return account.currency == currency;
      }).toList();
      
      if (accountsForCurrency.length >= 2) {
        return true;
      }
    }
    
    return false;
  }

  // Widget to show when there's only 1 account (logo with currency picker)
  Widget _buildSingleAccountView(List<Map<String, dynamic>> accountsWithData) {
    // Get available currencies from the data
    final availableCurrencies = _getAvailableCurrencies(accountsWithData);
    // Set default chart currency if not set
    if (_selectedChartCurrency == null && availableCurrencies.isNotEmpty) {
      _selectedChartCurrency = availableCurrencies.first;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Account Balance',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Currency dropdown
                  if (availableCurrencies.length > 1)
                    _buildCompactCurrencyDropdown(availableCurrencies),
                ],
              ),
            ],
          ),
          // const SizedBox(height: 20),
          // Show app logo
          // Image.asset(
          //   'images/launcher/logo.png',
          //   width: 120,
          //   height: 120,
          //   color: Colors.grey.shade400,
          // ),
          const SizedBox(height: 16),
          Text(
            'Single Account View',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add more accounts to see charts',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
