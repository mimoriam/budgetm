import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/models/firestore_account.dart';
import 'package:budgetm/viewmodels/currency_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({super.key});

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  int touchedIndex = -1;
  late FirestoreService _firestoreService;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        return StreamBuilder<List<FirestoreAccount>>(
          stream: _firestoreService.streamAccounts(),
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

            final _accounts = snapshot.data!;

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
                          _buildPieChart(_accounts),
                          const SizedBox(height: 16),
                          _buildLegend(_accounts, currencyProvider.currencySymbol),
                          const SizedBox(height: 24),
                          _buildSectionHeader('MY ACCOUNTS'),
                          const SizedBox(height: 12),
                          ..._accounts.map((account) => Column(
                                children: [
                                  _buildAccountItem(
                                    icon: Icons.account_balance,
                                    iconColor: Colors.black,
                                    iconBackgroundColor: Colors.grey.shade200,
                                    accountName: account.name,
                                    amount: account.balance,
                                    accountType: account.accountType,
                                    creditLimit: account.creditLimit,
                                    balanceLimit: account.balanceLimit,
                                    currencySymbol: currencyProvider.currencySymbol,
                                  ),
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

  Widget _buildPieChart(List<FirestoreAccount> accounts) {
    if (accounts.isEmpty) {
      return const SizedBox(height: 250);
    }
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
          sections: showingSections(accounts),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections(List<FirestoreAccount> accounts) {
    if (accounts.isEmpty) {
      return [];
    }

    // Calculate total balance
    final totalBalance = accounts.fold<double>(0.0, (sum, account) => sum + account.balance);
    
    // Define a list of colors for the pie chart sections
    final colors = [
      const Color(0xFF2563EB),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
    ];

    return List.generate(accounts.length, (i) {
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 120.0 : 100.0;
      final account = accounts[i];
      
      return PieChartSectionData(
        color: colors[i % colors.length],
        value: account.balance,
        title: '',
        radius: radius,
      );
    });
  }

  Widget _buildLegend(List<FirestoreAccount> accounts, String currencySymbol) {
    if (accounts.isEmpty) {
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
        ...accounts.asMap().entries.map((entry) {
          final index = entry.key;
          final account = entry.value;
          return Column(
            children: [
              _buildLegendItem(
                colors[index % colors.length],
                account.name,
                account.balance,
                currencySymbol,
              ),
              if (index < accounts.length - 1) const SizedBox(height: 12),
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
