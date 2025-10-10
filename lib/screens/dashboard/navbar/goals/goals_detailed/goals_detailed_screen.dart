import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/models/goal.dart';
import 'package:budgetm/models/firestore_transaction.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/viewmodels/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:budgetm/models/category.dart';
import 'package:budgetm/utils/icon_utils.dart';
import 'package:budgetm/viewmodels/goals_provider.dart';
import 'package:provider/provider.dart';

class GoalDetailScreen extends StatelessWidget {
  final FirestoreGoal goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildCustomAppBar(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(
                          goal.name,
                          style: Theme.of(
                            context,
                          ).textTheme.displayLarge?.copyWith(fontSize: 28),
                        ),
                        if (goal.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            goal.description!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.secondaryTextColorLight,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoCard(
                        context,
                        'Accumulated Amount',
                        '${Provider.of<CurrencyProvider>(context).currencySymbol}${NumberFormat('#,##0').format(goal.currentAmount)}',
                      ),
                      const SizedBox(width: 12),
                      _buildInfoCard(
                        context,
                        'Total',
                        '${Provider.of<CurrencyProvider>(context).currencySymbol}${NumberFormat('#,##0').format(goal.targetAmount)}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'DATE',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.secondaryTextColorLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat(
                          'MMMM d, yyyy',
                        ).format(goal.targetDate).toUpperCase(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    'TRANSACTIONS',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryTextColorLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // const SizedBox(height: 8),
                  Expanded(
                    child: StreamBuilder<List<FirestoreTransaction>>(
                      stream: FirestoreService.instance.getTransactionsForGoal(goal.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final transactions = snapshot.data ?? const <FirestoreTransaction>[];
                        if (transactions.isEmpty) {
                          return Center(
                            child: Text(
                              'No transactions yet',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.secondaryTextColorLight,
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: transactions.length,
                          // separatorBuilder: (_, __) => Divider(color: Colors.grey.shade200),
                          itemBuilder: (context, index) => _buildTransactionItem(context, transactions[index]),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await context.read<GoalsProvider>().deleteGoal(goal.id);
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: Text(
                            'Delete',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String amount) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryTextColorLight,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              amount,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primaryTextColorLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, FirestoreTransaction txn) {
    final bool isIncome = txn.type == 'income';

    return Container(
      // margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: FutureBuilder<Category?>(
        future: txn.categoryId != null
            ? FirestoreService.instance.getCategoryById(txn.categoryId!)
            : Future.value(null),
        builder: (context, categorySnapshot) {
          String categoryName = 'Uncategorized';
          String iconId = isIncome ? 'icon_default_income' : 'icon_default_expense';

          if (categorySnapshot.connectionState == ConnectionState.waiting) {
            categoryName = '...';
          } else if (categorySnapshot.hasData && categorySnapshot.data != null) {
            categoryName = categorySnapshot.data!.name ?? 'Uncategorized';
            if (categorySnapshot.data!.icon != null) {
              iconId = categorySnapshot.data!.icon!;
            }
          }

          return Row(
            children: [
              Container(
                // padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: HugeIcon(
                  icon: getIcon(iconId),
                  color: Colors.black87,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMM d, yyyy').format(txn.date),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                '${isIncome ? '+' : '-'} ${Provider.of<CurrencyProvider>(context).currencySymbol}${txn.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isIncome ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 14),
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
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowLeft01,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Savings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 36),
            ],
          ),
        ),
      ),
    );
  }
}
