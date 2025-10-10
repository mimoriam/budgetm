import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/constants/transaction_type_enum.dart';
import 'package:budgetm/models/category.dart';
import 'package:budgetm/models/firestore_account.dart';
import 'package:budgetm/models/firestore_transaction.dart';
import 'package:budgetm/models/transaction.dart';
import 'package:budgetm/screens/dashboard/navbar/home/expense_detail/expense_detail_screen.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/viewmodels/home_screen_provider.dart';
import 'package:budgetm/viewmodels/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BalanceDetailScreen extends StatefulWidget {
  final FirestoreAccount account;
  final int accountsCount;

  const BalanceDetailScreen({super.key, required this.account, required this.accountsCount});

  @override
  State<BalanceDetailScreen> createState() => _BalanceDetailScreenState();
}

class _BalanceDetailScreenState extends State<BalanceDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService.instance;
  NumberFormat get _currencyFormat => NumberFormat.currency(symbol: Provider.of<CurrencyProvider>(context, listen: false).currencySymbol);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
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
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.account.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_forever, color: widget.accountsCount == 1 ? Colors.grey : Colors.red),
                    onPressed: widget.accountsCount == 1 ? null : () => _showDeleteConfirmationDialog(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<FirestoreTransaction>>(
        future: _firestoreService.getTransactionsForAccount(widget.account.id),
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Handle error state
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading transactions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Handle empty state
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Transactions for this account will appear here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            );
          }

          // Display transactions
          final transactions = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return _buildTransactionCard(transaction);
            },
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard(FirestoreTransaction transaction) {
    final isIncome = transaction.type == 'income';

    return GestureDetector(
      onTap: () async {
        // Convert FirestoreTransaction to Transaction for ExpenseDetailScreen
        final uiTransaction = await _convertToUiTransaction(transaction);
        if (mounted) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExpenseDetailScreen(transaction: uiTransaction),
            ),
          );
          // Refresh if transaction was deleted
          if (result == true && mounted) {
            setState(() {});
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Row(
          children: [
            Checkbox(
              value: transaction.paid ?? true,
              onChanged: (bool? value) async {
                if (value == null) return;
                try {
                  await _firestoreService.toggleTransactionPaidStatus(
                    transaction.id,
                    value,
                  );
                  if (mounted) {
                    Provider.of<HomeScreenProvider>(context, listen: false)
                        .triggerTransactionsRefresh();
                    setState(() {}); // Refresh current screen
                  }
                } catch (e) {
                  // Optionally show an error message
                  print('Error toggling paid status: $e');
                }
              },
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<Category?>(
                    future: transaction.categoryId != null
                        ? _firestoreService.getCategoryById(transaction.categoryId!)
                        : null,
                    builder: (context, categorySnapshot) {
                      String categoryName = 'Uncategorized';
                      if (categorySnapshot.connectionState == ConnectionState.waiting) {
                        categoryName = '...';
                      } else if (categorySnapshot.hasData && categorySnapshot.data != null) {
                        categoryName = categorySnapshot.data!.name ?? 'Uncategorized';
                      }
                      
                      return Text(
                        categoryName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM d, yyyy').format(transaction.date),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'} ${Provider.of<CurrencyProvider>(context).currencySymbol}${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog() async {
    final result = await showDialog<Map<String, bool>>(
      context: context,
      builder: (BuildContext context) {
        bool cascadeDelete = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Delete Account'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Are you sure you want to delete "${widget.account.name}"? This action cannot be undone.'),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('Cascade delete transactions'),
                    value: cascadeDelete,
                    onChanged: (val) => setState(() => cascadeDelete = val ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop({'confirmed': false, 'cascadeDelete': false}),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop({'confirmed': true, 'cascadeDelete': cascadeDelete}),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && result['confirmed'] == true && mounted) {
      final cascadeDelete = result['cascadeDelete'] == true;
      try {
        await _firestoreService.deleteAccount(widget.account.id, cascadeDelete: cascadeDelete);
        Provider.of<HomeScreenProvider>(context, listen: false).triggerTransactionsRefresh();
        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate deletion
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete account: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<Transaction> _convertToUiTransaction(FirestoreTransaction firestoreTransaction) async {
    final isIncome = firestoreTransaction.type == 'income';
    
    // Get category name for title
    String title = 'Uncategorized';
    if (firestoreTransaction.categoryId != null) {
      final category = await _firestoreService.getCategoryById(firestoreTransaction.categoryId!);
      if (category != null && category.name != null) {
        title = category.name!;
      }
    }

    return Transaction(
      id: firestoreTransaction.id,
      title: title,
      description: firestoreTransaction.description,
      amount: firestoreTransaction.amount,
      type: isIncome ? TransactionType.income : TransactionType.expense,
      date: firestoreTransaction.date,
      icon: Icon(
        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
        color: isIncome ? Colors.green : Colors.red,
      ),
      iconBackgroundColor: (isIncome ? Colors.green : Colors.red).withOpacity(0.1),
      accountId: firestoreTransaction.accountId,
      categoryId: firestoreTransaction.categoryId,
      paid: firestoreTransaction.paid,
      currency: Provider.of<CurrencyProvider>(context, listen: false).selectedCurrencyCode, // New required field
    );
  }
}