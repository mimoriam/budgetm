import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/models/category.dart';
import 'package:budgetm/models/budget.dart';
import 'package:budgetm/models/firestore_transaction.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budgetm/viewmodels/budget_provider.dart';
import 'package:intl/intl.dart';

class BudgetDetailScreen extends StatefulWidget {
  final Category category;
  final Budget budget;

  const BudgetDetailScreen({
    super.key,
    required this.category,
    required this.budget,
  });

  @override
  State<BudgetDetailScreen> createState() => _BudgetDetailScreenState();
}

class _BudgetDetailScreenState extends State<BudgetDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService.instance;
  List<_TransactionWithAccount> _detailedTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allTransactions = await _firestoreService
          .getTransactionsForDateRange(widget.budget.startDate, widget.budget.endDate);

      final categoryTransactions = allTransactions
          .where(
            (t) => t.type == 'expense' && t.categoryId == widget.category.id,
          )
          .toList();

      // Create a list of futures to fetch account names and types
      final detailedTransactionsFutures = categoryTransactions.map((t) async {
        String accountName = 'Unknown';
        String accountType = '';
        if (t.accountId != null && t.accountId!.isNotEmpty) {
          final account = await _firestoreService.getAccountById(t.accountId!);
          accountName = account?.name ?? 'Unknown';
          accountType = account?.accountType ?? '';
        }
        return _TransactionWithAccount(
          transaction: t,
          accountName: accountName,
          accountType: accountType,
        );
      }).toList();

      // Wait for all futures to complete
      _detailedTransactions = await Future.wait(detailedTransactionsFutures);

      // Sort by date descending
      _detailedTransactions.sort(
        (a, b) => b.transaction.date.compareTo(a.transaction.date),
      );
    } catch (e) {
      print('Error loading transactions: $e');
      // Optionally show an error message to the user
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
      backgroundColor: AppColors.scaffoldBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
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
              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      widget.category.name ?? 'Category Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  // Delete button for the budget (destructive action)
                  IconButton(
                    icon: const Icon(Icons.delete_forever),
                    color: Colors.red,
                    onPressed: () async {
                      // Diagnostic log: user initiated delete
                      print('BudgetDetail: delete pressed for budgetId=${widget.budget.id}');
                      final confirmed = await showDialog<bool>(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete budget'),
                          content: const Text('Are you sure you want to delete this budget? This action cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
      
                      // Diagnostic log: result from confirmation dialog
                      print('BudgetDetail: delete confirmed=$confirmed for budgetId=${widget.budget.id}');
      
                      if (confirmed == true) {
                        try {
                          // Attempt deletion and log outcome
                          await Provider.of<BudgetProvider>(context, listen: false)
                              .deleteBudget(widget.budget.id);
                          print('BudgetDetail: delete succeeded for budgetId=${widget.budget.id}');
      
                          // Ensure budgets list is refreshed so UI shows deletion immediately
                          await Provider.of<BudgetProvider>(context, listen: false).initialize();
      
                          if (mounted) {
                            // Navigate back after deletion
                            Navigator.of(context).pop();
                          }
                        } catch (e) {
                          print('BudgetDetail: delete failed for budgetId=${widget.budget.id} error=$e');
                          // Optionally show an error
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to delete budget')),
                            );
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _detailedTransactions.isEmpty
          ? _buildEmptyState()
          : _buildTransactionsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'No transactions found for this category in the selected period',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: _detailedTransactions.length,
      itemBuilder: (context, index) {
        final detailedTransaction = _detailedTransactions[index];
        return _buildTransactionCard(detailedTransaction);
      },
    );
  }

  Widget _buildTransactionCard(_TransactionWithAccount detailedTransaction) {
    final transaction = detailedTransaction.transaction;
    final accountName = detailedTransaction.accountName;
    final accountType = detailedTransaction.accountType;
  
    final dateFormatter = DateFormat('MMM dd, yyyy');
    final timeFormatter = DateFormat('hh:mm a');

    String formattedTime = '';
    if (transaction.time != null && transaction.time!.isNotEmpty) {
      try {
        final timeParts = transaction.time!.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final time = TimeOfDay(hour: hour, minute: minute);
        formattedTime = time.format(context);
      } catch (e) {
        formattedTime = transaction.time!;
      }
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _getCategoryColor().withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getCategoryIcon(),
                        color: _getCategoryColor(),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Text(
                        transaction.description,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  '- \$${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.scaffoldBackground),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Account name
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "$accountName (${accountType.isNotEmpty ? accountType : 'Unknown'})",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                // Date and time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      dateFormatter.format(transaction.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    if (widget.category.color == null) return Colors.grey;

    switch (widget.category.color!.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'yellow':
        return Colors.yellow.shade700;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'teal':
        return Colors.teal;
      case 'brown':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon() {
    if (widget.category.icon == null) return Icons.category;

    switch (widget.category.icon!.toLowerCase()) {
      case 'restaurant':
      case 'food':
        return Icons.restaurant;
      case 'directions_car':
      case 'car':
      case 'transport':
        return Icons.directions_car;
      case 'shopping_cart':
      case 'shopping':
        return Icons.shopping_cart;
      case 'movie':
      case 'entertainment':
        return Icons.movie;
      case 'receipt':
      case 'bills':
        return Icons.receipt;
      case 'work':
      case 'salary':
        return Icons.work;
      case 'business':
      case 'freelance':
        return Icons.business;
      case 'trending_up':
      case 'investment':
        return Icons.trending_up;
      case 'home':
        return Icons.home;
      case 'health':
      case 'medical':
        return Icons.local_hospital;
      case 'education':
      case 'school':
        return Icons.school;
      default:
        return Icons.category;
    }
  }
}

 // Helper class to hold transaction and its account name and type
 class _TransactionWithAccount {
   final FirestoreTransaction transaction;
   final String accountName;
   final String accountType;
 
   _TransactionWithAccount({
     required this.transaction,
     required this.accountName,
     required this.accountType,
   });
 }
