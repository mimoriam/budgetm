import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/models/firestore_transaction.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/models/firestore_account.dart';
import 'package:budgetm/viewmodels/currency_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

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
  const _BalanceScreenState({super.key});

  @override
  State<_BalanceScreenState> createState() => _BalanceScreenStateInner();
}

class _BalanceScreenStateInner extends State<_BalanceScreenState> {
  int touchedIndex = -1;
  late FirestoreService _firestoreService;
  Stream<List<Map<String, dynamic>>>? _accountsWithTransactionsStream;

  StreamController<List<Map<String, dynamic>>>? _accountsWithTransactionsController;
  StreamSubscription<List<FirestoreAccount>>? _accountsSub;
  StreamSubscription<List<FirestoreTransaction>>? _transactionsSub;
  List<FirestoreAccount>? _latestAccounts;
  List<FirestoreTransaction>? _latestTransactions;

  @override
  void initState() {
    super.initState();
    _initStreams();
  }

  void _initStreams() {
    _firestoreService = FirestoreService.instance;

    _accountsWithTransactionsController = StreamController<List<Map<String, dynamic>>>.broadcast();
    _accountsWithTransactionsStream = _accountsWithTransactionsController!.stream;

    _accountsSub = _firestoreService.streamAccounts().listen((accounts) {
      _latestAccounts = accounts;
      _tryEmitCombined();
    });

    _transactionsSub = _firestoreService.streamTransactions().listen((transactions) {
      _latestTransactions = transactions;
      _tryEmitCombined();
    });
  }

  void _tryEmitCombined() {
    if (_latestAccounts == null || _latestTransactions == null) return;

    final transactions = _latestTransactions!;
    final transactionAmounts = <String, double>{};
    for (var transaction in transactions) {
      final accId = transaction.accountId;
      if (accId == null) continue;
      final isIncome = transaction.type != null &&
          transaction.type.toString().toLowerCase().contains('income');
      final txnAmount = isIncome ? transaction.amount : -transaction.amount;
      transactionAmounts.update(
        accId,
        (value) => value + txnAmount,
        ifAbsent: () => txnAmount,
      );
    }

    final accountsWithData = _latestAccounts!.map((account) {
      return {
        'account': account,
        'transactionsAmount': transactionAmounts[account.id] ?? 0.0,
      };
    }).toList();

    _accountsWithTransactionsController?.add(accountsWithData);
  }

  @override
  void dispose() {
    _accountsSub?.cancel();
    _transactionsSub?.cancel();
    _accountsWithTransactionsController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: _accountsWithTransactionsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No accounts found.'));
            }

            final accountsWithData = snapshot.data!;
            final accounts = accountsWithData.map((d) => d['account'] as FirestoreAccount).toList();

            return Scaffold(
              backgroundColor: AppColors.scaffoldBackground,
              body: Column(
                children: [
                  _buildCustomAppBar(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPieChart(accountsWithData),
                          const SizedBox(height: 16),
                          _buildLegend(accountsWithData, currencyProvider.currencySymbol),
                          const SizedBox(height: 24),
                          _buildSectionHeader('MY ACCOUNTS'),
                          const SizedBox(height: 12),
                          ...accountsWithData.map((accountData) => Column(
                                children: [
                                  Builder(builder: (context) {
                                    final account = accountData['account'] as FirestoreAccount;
                                    final transactionsAmount = (accountData['transactionsAmount'] as double?) ?? 0.0;
                                    return _buildAccountItem(
                                      icon: Icons.account_balance,
                                      iconColor: Colors.black,
                                      iconBackgroundColor: Colors.grey.shade200,
                                      accountName: account.name,
                                      amount: account.balance,
                                      accountType: account.accountType,
                                      creditLimit: account.creditLimit,
                                      balanceLimit: account.balanceLimit,
                                      currencySymbol: currencyProvider.currencySymbol,
                                    );
                                  }),
                                  const SizedBox(height: 12),
                                ],
                              )),
                        ],
                      ),
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

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
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
          padding: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Balance',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              // ElevatedButton.icon(
              //   onPressed: () {
              //     // TODO: Navigate to Add Account screen
              //   },
              //   icon: const Icon(Icons.add, color: Colors.white, size: 18),
              //   label: const Text('Add Account'),
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: AppColors.gradientEnd,
              //     foregroundColor: Colors.white,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(20),
              //     ),
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 14,
              //       vertical: 10,
              //     ),
              //     textStyle: const TextStyle(
              //       fontWeight: FontWeight.bold,
              //       fontSize: 12,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
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
            child: Image.asset(
              'images/launcher/logo.png',
              fit: BoxFit.contain,
            ),
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

  List<PieChartSectionData> showingSections(List<Map<String, dynamic>> accountsWithData) {
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
      final value = account.balance;
      
      return PieChartSectionData(
        color: colors[i % colors.length],
        value: value,
        title: '',
        radius: radius,
      );
    });
  }

  Widget _buildLegend(List<Map<String, dynamic>> accountsWithData, String currencySymbol) {
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
          return Column(
            children: [
              _buildLegendItem(
                colors[index % colors.length],
                account.name,
                account.balance,
                currencySymbol,
              ),
              if (index < accountsWithData.length - 1) const SizedBox(height: 12),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, double amount, String currencySymbol) {
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

  Widget _buildAccountItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBackgroundColor,
    required String accountName,
    required double amount,
    required String accountType,
    double? creditLimit,
    double? balanceLimit,
    required String currencySymbol,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 10,
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
            child: Icon(icon, size: 24, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accountName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
    );
  }
}
