import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/models/firestore_transaction.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/models/firestore_account.dart';
import 'package:budgetm/viewmodels/currency_provider.dart';
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
    for (var transaction in transactions) {
      final accId = transaction.accountId;
      if (accId == null || defaultAccountIds.contains(accId)) continue;
      if (transaction.paid ?? true) {
        final isIncome =
            transaction.type != null &&
            transaction.type.toString().toLowerCase().contains('income');
        final txnAmount = isIncome ? transaction.amount : -transaction.amount;
        transactionAmounts.update(
          accId,
          (v) => v + txnAmount,
          ifAbsent: () => txnAmount,
        );
      }
    }

    // For vacation mode: compute total expenses ever made for each account (ignore paid flag; include all expense transactions)
    final expenseSums = <String, double>{};
    for (var transaction in transactions) {
      final accId = transaction.accountId;
      if (accId == null || defaultAccountIds.contains(accId)) continue;
      final isExpense =
          transaction.type != null &&
          transaction.type.toString().toLowerCase().contains('expense');
      if (isExpense) {
        expenseSums.update(
          accId,
          (v) => v + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }

    // In vacation mode, behavior remains the same
    if (isVacationMode) {
      final accountsWithData = allAccounts
          .where((account) => !(account.isDefault ?? false))
          .where((account) => (account.isVacationAccount == true))
          .map((account) {
            final totalExpenses = expenseSums[account.id] ?? 0.0;
            // For vacation accounts the final balance should represent the negative
            // sum of expenses (not account.balance - totalExpenses).
            final finalBalance = -totalExpenses;
            return {
              'account': account,
              'transactionsAmount':
                  -totalExpenses, // keep sign for consistency (expenses as negative)
              'finalBalance': finalBalance,
            };
          })
          .toList();

      _accountsWithTransactionsController?.add(accountsWithData);
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
          // Use account.balance directly as it's the single source of truth from Firestore
          final finalBalance = account.balance;
          return {
            'account': account,
            'transactionsAmount': transactionsAmount,
            'finalBalance': finalBalance,
          };
        })
        .toList();

    final vacationAccounts = nonDefaultAccounts
        .where((account) => (account.isVacationAccount == true))
        .map((account) {
          final transactionsAmount = transactionAmounts[account.id] ?? 0.0;
          // Use account.balance directly as it's the single source of truth from Firestore
          final finalBalance = account.balance;
          return {
            'account': account,
            'transactionsAmount': transactionsAmount,
            'finalBalance': finalBalance,
          };
        })
        .toList();

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
                // In vacation mode, data is a List
                if (snapshot.data is List && snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }
                normalAccounts = snapshot.data as List<Map<String, dynamic>>;
              } else {
                // In normal mode, data is a Map with two lists
                if (snapshot.data is Map) {
                  final data = snapshot.data as Map<String, dynamic>;
                  normalAccounts =
                      data['normal_accounts'] as List<Map<String, dynamic>>;
                  vacationAccounts =
                      data['vacation_accounts'] as List<Map<String, dynamic>>;

                  // Show empty state if both lists are empty
                  if (normalAccounts.isEmpty && vacationAccounts.isEmpty) {
                    return _buildEmptyState();
                  }
                }
              }

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
                          _buildPieChart(normalAccounts),
                          const SizedBox(height: 16),
                          _buildLegend(
                            normalAccounts,
                            currencyProvider.currencySymbol,
                          ),
                          const SizedBox(height: 24),
                          _buildSectionHeaderWithButton(
                            'MY ACCOUNTS',
                            () async {
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
                          const SizedBox(height: 12),
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
                                        accountData['finalBalance'] as double;
                                    final isHighlighted = index == touchedIndex;
                                    return _buildAccountCard(
                                      context: context,
                                      account: account,
                                      icon: getAccountIcon(
                                        account.accountType,
                                      )[0][0],
                                      iconColor: Colors.black,
                                      iconBackgroundColor: Colors.grey.shade200,
                                      accountName: account.name,
                                      amount: finalBalance,
                                      accountType: account.accountType,
                                      creditLimit: account.creditLimit,
                                      balanceLimit: account.balanceLimit,
                                      currencySymbol:
                                          currencyProvider.currencySymbol,
                                      isHighlighted: isHighlighted,
                                      accountsCount: normalAccounts.length,
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),

                          // Vacation Accounts section (only in normal mode)
                          if (!isVacationMode) ...[
                            const SizedBox(height: 24),
                            _buildSectionHeader('VACATION ACCOUNTS'),
                            const SizedBox(height: 12),
                            if (vacationAccounts.isEmpty)
                              Text(
                                'No vacation accounts',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.secondaryTextColorLight,
                                    ),
                              )
                            else
                              ...vacationAccounts.map(
                                (accountData) => Column(
                                  children: [
                                    _buildAccountCard(
                                      context: context,
                                      account:
                                          accountData['account']
                                              as FirestoreAccount,
                                      icon: getAccountIcon(
                                        (accountData['account']
                                                as FirestoreAccount)
                                            .accountType,
                                      )[0][0],
                                      iconColor: Colors.black,
                                      iconBackgroundColor: Colors.grey.shade200,
                                      accountName:
                                          (accountData['account']
                                                  as FirestoreAccount)
                                              .name,
                                      amount:
                                          accountData['finalBalance'] as double,
                                      accountType:
                                          (accountData['account']
                                                  as FirestoreAccount)
                                              .accountType,
                                      creditLimit:
                                          (accountData['account']
                                                  as FirestoreAccount)
                                              .creditLimit,
                                      balanceLimit:
                                          (accountData['account']
                                                  as FirestoreAccount)
                                              .balanceLimit,
                                      currencySymbol:
                                          currencyProvider.currencySymbol,
                                      isHighlighted: false,
                                      accountsCount: vacationAccounts.length,
                                    ),
                                    const SizedBox(height: 12),
                                  ],
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

    // If there's only one account, show the app logo instead of the pie chart
    if (accountsWithData.length == 1) {
      return SizedBox(
        height: 250,
        child: Center(
          child: SizedBox(
            width: 150,
            height: 150,
            child: Image.asset('images/launcher/logo.png', fit: BoxFit.contain),
          ),
        ),
      );
    }

    // For two or more accounts, show the pie chart as before
    return SizedBox(
      height: 250,
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
          sections: showingSections(accountsWithData),
        ),
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
      final value = accountData['finalBalance'] as double;

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
    String currencySymbol,
  ) {
    if (accountsWithData.isEmpty) {
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
        ...accountsWithData.asMap().entries.map((entry) {
          final index = entry.key;
          final accountData = entry.value;
          final account = accountData['account'] as FirestoreAccount;
          final finalBalance = accountData['finalBalance'] as double;
          return Column(
            children: [
              _buildLegendItem(
                colors[index % colors.length],
                account.name,
                finalBalance,
                currencySymbol,
              ),
              if (index < accountsWithData.length - 1)
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppColors.secondaryTextColorLight,
        fontWeight: FontWeight.bold,
      ),
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
  }) {
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
          color: isHighlighted
              ? AppColors.gradientStart.withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isHighlighted
                ? AppColors.gradientStart
                : Colors.grey.shade200,
            width: isHighlighted ? 2.0 : 1.0,
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
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: HugeIcon(icon: icon, size: 24, color: iconColor),
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
                  if (creditLimit != null)
                    Text(
                      'Credit Limit: $currencySymbol${creditLimit.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryTextColorLight,
                      ),
                    )
                  // else if (account.isVacationAccount == true)
                  // Text(
                  //   'Credit Limit: Unlimited',
                  //   style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  //     color: AppColors.secondaryTextColorLight,
                  //     fontStyle: FontStyle.italic,
                  //   ),
                  // )
                  else if (balanceLimit != null)
                    Text(
                      'Balance Limit: $currencySymbol${balanceLimit.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryTextColorLight,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              '$currencySymbol${amount.toStringAsFixed(2)}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Image.asset('images/launcher/logo.png', fit: BoxFit.contain),
          ),
          const SizedBox(height: 16),
          Text(
            'No accounts found. Add one to get started.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
