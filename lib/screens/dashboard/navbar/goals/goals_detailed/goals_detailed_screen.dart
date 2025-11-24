import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/generated/i18n/app_localizations.dart';
import 'package:budgetm/models/goal.dart';
import 'package:budgetm/models/firestore_transaction.dart';
import 'package:budgetm/models/transaction.dart' as model;
import 'package:budgetm/constants/transaction_type_enum.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/screens/dashboard/navbar/home/expense_detail/expense_detail_screen.dart';
import 'package:budgetm/viewmodels/currency_provider.dart';
import 'package:budgetm/viewmodels/home_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:budgetm/models/category.dart';
import 'package:budgetm/utils/icon_utils.dart';
import 'package:budgetm/utils/appTheme.dart';
import 'package:budgetm/utils/currency_formatter.dart';
import 'package:budgetm/viewmodels/goals_provider.dart';
import 'package:provider/provider.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class GoalDetailScreen extends StatefulWidget {
  final FirestoreGoal goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService.instance;
  List<_TransactionWithCategory> _detailedTransactions = [];
  bool _isLoading = true;
  double _calculatedCurrentAmount = 0.0;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransactions();
    });
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('GoalDetail: Loading transactions for goal=${widget.goal.id}');
      
      final allTransactions = await _firestoreService.getTransactionsForGoal(widget.goal.id).first;
      print('GoalDetail: Total transactions found: ${allTransactions.length}');

      // Calculate current amount from transactions
      _calculatedCurrentAmount = await _firestoreService.calculateGoalCurrentAmount(widget.goal.id);
      print('GoalDetail: Calculated current amount: $_calculatedCurrentAmount');

      // Create a list of futures to fetch category information for each transaction
      final detailedTransactionsFutures = allTransactions.map((t) async {
        Category? category;
        if (t.categoryId != null && t.categoryId!.isNotEmpty) {
          category = await _firestoreService.getCategoryById(t.categoryId!);
        }
        return _TransactionWithCategory(
          transaction: t,
          category: category,
        );
      }).toList();

      // Wait for all futures to complete
      _detailedTransactions = await Future.wait(detailedTransactionsFutures);

      // Sort by date descending
      _detailedTransactions.sort(
        (a, b) => b.transaction.date.compareTo(a.transaction.date),
      );
      
      print('GoalDetail: Loaded ${_detailedTransactions.length} transactions with categories');
    } catch (e) {
      print('Error loading transactions: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildCustomAppBar(context),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _detailedTransactions.isEmpty
                    ? _buildEmptyState()
                    : _buildTransactionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.savings, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.homeNoTransactionsRecorded,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Padding(
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
                  widget.goal.name,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                ),
                if (widget.goal.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.goal.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                formatCurrency(_calculatedCurrentAmount, widget.goal.currency),
              ),
              const SizedBox(width: 12),
              _buildInfoCard(
                context,
                'Total',
                formatCurrency(widget.goal.targetAmount, widget.goal.currency),
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
                DateFormat('MMMM d, yyyy').format(widget.goal.targetDate).toUpperCase(),
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
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _detailedTransactions.length,
              itemBuilder: (context, index) => _buildTransactionItem(context, _detailedTransactions[index]),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await showDialog<Map<String, bool>>(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) {
                        return AlertDialog(
                          title: Text(AppLocalizations.of(context)!.goalsDelete),
                          content: Text(AppLocalizations.of(context)!.goalsDeleteConfirm),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop({'confirmed': false, 'cascadeDelete': false}),
                              child: Text(AppLocalizations.of(context)!.cancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop({'confirmed': true, 'cascadeDelete': false}),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: Text(AppLocalizations.of(context)!.delete),
                            ),
                          ],
                        );
                      },
                    );

                    if (result != null && result['confirmed'] == true) {
                      final cascadeDelete = result['cascadeDelete'] == true;
                      try {
                        await context.read<GoalsProvider>().deleteGoal(widget.goal.id, cascadeDelete: cascadeDelete);
                        
                        // Trigger a refresh of transactions if cascade delete was performed
                        if (cascadeDelete) {
                          Provider.of<HomeScreenProvider>(context, listen: false).triggerTransactionsRefresh();
                        }
                        
                        if (mounted) {
                          Navigator.of(context).pop(true);
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppLocalizations.of(context)!.failedToDeleteGoal)),
                          );
                        }
                      }
                    }
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
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ],
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

  Widget _buildTransactionItem(BuildContext context, _TransactionWithCategory detailedTransaction) {
    final transaction = detailedTransaction.transaction;
    final category = detailedTransaction.category;
    final bool isIncome = transaction.type == 'income';
    
    // Get the icon color from the transaction, fallback to default if null
    final Color iconBackgroundColor = hexToColor(transaction.icon_color);
    final Color iconForegroundColor = getContrastingColor(iconBackgroundColor);

    return InkWell(
      onTap: () async {
        // Convert FirestoreTransaction to Transaction
        final uiTransaction = _convertToUiTransaction(transaction, context, category);
        
        // Navigate to ExpenseDetailScreen
        final result = await PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: ExpenseDetailScreen(transaction: uiTransaction),
          withNavBar: false,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
        
        // Refresh data if needed when returning from the detail screen
        if (result == true && mounted) {
          _loadTransactions();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200, width: 1),
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
                icon: getIcon(category?.icon ?? (isIncome ? 'icon_default_income' : 'icon_default_expense')),
                color: iconForegroundColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category?.name ?? 'Uncategorized',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM d, yyyy').format(transaction.date),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add paid/unpaid status icon
                Icon(
                  transaction.paid == true ? Icons.check_circle : Icons.circle_outlined,
                  color: transaction.paid == true ? Colors.green : Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${isIncome ? '+' : '-'} ${formatCurrency(transaction.amount, widget.goal.currency)}',
                  style: TextStyle(
                    color: isIncome ? Colors.green : Colors.red,
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

// Helper class to hold transaction and its category information
class _TransactionWithCategory {
  final FirestoreTransaction transaction;
  final Category? category;

  _TransactionWithCategory({
    required this.transaction,
    required this.category,
  });
}
