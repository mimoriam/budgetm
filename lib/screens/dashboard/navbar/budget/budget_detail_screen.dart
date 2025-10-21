import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/models/category.dart';
import 'package:budgetm/models/budget.dart';
import 'package:budgetm/models/firestore_transaction.dart';
import 'package:budgetm/models/transaction.dart' as model;
import 'package:budgetm/constants/transaction_type_enum.dart';
import 'package:budgetm/screens/dashboard/navbar/home/expense_detail/expense_detail_screen.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/viewmodels/home_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:budgetm/viewmodels/budget_provider.dart';
import 'package:budgetm/viewmodels/vacation_mode_provider.dart';
import 'package:budgetm/utils/appTheme.dart';
import 'package:budgetm/utils/icon_utils.dart';
import 'package:intl/intl.dart';
import 'package:currency_picker/currency_picker.dart';

// Helper function to convert Firestore transaction to UI transaction
model.Transaction _convertToUiTransaction(FirestoreTransaction firestoreTransaction, BuildContext context, String currencyCode) {
  return model.Transaction(
    id: firestoreTransaction.id,
    title: firestoreTransaction.description,
    description: firestoreTransaction.description,
    amount: firestoreTransaction.amount,
    type: firestoreTransaction.type == 'income'
        ? TransactionType.income
        : TransactionType.expense,
    date: firestoreTransaction.date,
    icon: const Icon(Icons.account_balance),
    iconBackgroundColor: Colors.grey.shade100,
    accountId: firestoreTransaction.accountId,
    categoryId: firestoreTransaction.categoryId,
    currency: currencyCode,
  );
}

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
  BudgetProvider? _budgetProvider;
  
  // Currency-related variables
  late String _budgetCurrencyCode;
  late String _currencySymbol;

  @override
  void initState() {
    super.initState();
    // Load initial transactions, and register a listener on the BudgetProvider
    // to refresh when the selected period or vacation mode changes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransactions();
      _budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
      _budgetProvider?.addListener(_onProviderChanged);
    });
  }

  void _onProviderChanged() {
    // Reload transactions when provider selection or mode changes.
    // Throttle or debounce here if necessary to avoid rapid repeated reloads.
    if (!mounted) return;
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
    // Use the currently selected period from the BudgetProvider if available
    final provider = Provider.of<BudgetProvider>(context, listen: false);
    final start = provider.selectedPeriodStart ?? widget.budget.startDate;
    final end = provider.selectedPeriodEnd ?? widget.budget.endDate;

    // Check if we're in vacation mode and get the vacation account ID
    final vacationProvider = Provider.of<VacationProvider>(context, listen: false);
    final isVacationMode = vacationProvider.isVacationMode;
    final vacationAccountId = vacationProvider.activeVacationAccountId;

    // Debug logging for vacation mode
    print('BudgetDetail: Loading transactions for budget currency=${widget.budget.currency}, category=${widget.category.id}');
    print('BudgetDetail: isVacationMode=$isVacationMode, vacationAccountId=$vacationAccountId');

    final allTransactions = await _firestoreService
      .getTransactionsForDateRange(start, end, isVacation: isVacationMode);

      print('BudgetDetail: Total transactions found: ${allTransactions.length}');
      
      // For vacation mode, also filter by vacation account ID if available
      List<FirestoreTransaction> filteredTransactions = allTransactions;
      if (isVacationMode && vacationAccountId != null && vacationAccountId.isNotEmpty) {
        filteredTransactions = allTransactions
            .where((t) => t.accountId == vacationAccountId)
            .toList();
        print('BudgetDetail: After vacation account filter: ${filteredTransactions.length}');
      }
      
      final categoryTransactions = filteredTransactions
          .where(
            (t) => t.type == 'expense' && 
                   t.categoryId == widget.category.id &&
                   t.currency == widget.budget.currency,
          )
          .toList();
      
      print('BudgetDetail: Filtered transactions matching currency: ${categoryTransactions.length}');

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
    // Determine the correct currency symbol for the budget being viewed
    _budgetCurrencyCode = widget.budget.currency;
    final currency = CurrencyService().findByCode(_budgetCurrencyCode);
    _currencySymbol = currency?.symbol ?? '\$';
    
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
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
                      widget.category.name ?? 'Category Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  // Delete button for the budget (destructive action) - only show if budget has a real ID
                  if (widget.budget.id.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.delete_forever),
                      color: Colors.red,
                      onPressed: () async {
                      // Diagnostic log: user initiated delete
                      print('BudgetDetail: delete pressed for budgetId=${widget.budget.id}');
                      final result = await showDialog<Map<String, bool>>(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) {
                          return AlertDialog(
                            title: const Text('Delete Budget'),
                            content: Text('Are you sure you want to delete "${widget.category.name ?? 'this budget'}"? This action cannot be undone.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop({'confirmed': false, 'cascadeDelete': false}),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop({'confirmed': true, 'cascadeDelete': false}),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                        
                      // Diagnostic log: result from confirmation dialog
                      print('BudgetDetail: delete confirmed=${result?['confirmed']} for budgetId=${widget.budget.id}');
                        
                      if (result != null && result['confirmed'] == true) {
                        final cascadeDelete = result['cascadeDelete'] == true;
                        try {
                          // Attempt deletion and log outcome
                          // Determine effective budgetId for deletion, handling placeholder budgets and recurring budgets
                          final provider = Provider.of<BudgetProvider>(context, listen: false);
                          String effectiveBudgetId = widget.budget.id;
                          final bool isRecurring = widget.budget.isRecurring;
                          
                          // If budget ID is empty (placeholder budget), try to find a real budget
                          if (effectiveBudgetId.isEmpty) {
                            // For vacation mode, be more specific about which budget to find
                            final vacationProvider = Provider.of<VacationProvider>(context, listen: false);
                            Budget realBudget;
                            
                            if (vacationProvider.isVacationMode) {
                              // In vacation mode, look for vacation budgets specifically
                              realBudget = provider.budgets.firstWhere(
                                (b) => b.categoryId == widget.category.id &&
                                       b.type == widget.budget.type &&
                                       b.id.isNotEmpty &&
                                       b.isVacation == true &&
                                       b.currency == widget.budget.currency,
                                orElse: () => Budget(
                                  id: '',
                                  categoryId: '',
                                  limit: 0.0,
                                  type: BudgetType.monthly,
                                  year: 0,
                                  period: 0,
                                  startDate: DateTime.now(),
                                  endDate: DateTime.now(),
                                  userId: '',
                                  currency: '',
                                  spentAmount: 0.0,
                                  isRecurring: false,
                                ),
                              );
                            } else {
                              // In normal mode, look for normal budgets
                              realBudget = provider.budgets.firstWhere(
                                (b) => b.categoryId == widget.category.id &&
                                       b.type == widget.budget.type &&
                                       b.id.isNotEmpty &&
                                       b.isVacation == false,
                                orElse: () => Budget(
                                  id: '',
                                  categoryId: '',
                                  limit: 0.0,
                                  type: BudgetType.monthly,
                                  year: 0,
                                  period: 0,
                                  startDate: DateTime.now(),
                                  endDate: DateTime.now(),
                                  userId: '',
                                  currency: '',
                                  spentAmount: 0.0,
                                  isRecurring: false,
                                ),
                              );
                            }
                            
                            if (realBudget.id.isNotEmpty) {
                              effectiveBudgetId = realBudget.id;
                              print('BudgetDetail: found real budget for placeholder, using budgetId=$effectiveBudgetId');
                            } else {
                              // If no real budget exists, this is just a placeholder - show message and return
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('No budget to delete. This is just a placeholder for transactions.'),
                                  ),
                                );
                              }
                              return;
                            }
                          }
                          
                          // Handle recurring budgets that may pass a temporary empty ID
                          if (effectiveBudgetId.isEmpty && isRecurring) {
                            final fallbackList = provider.budgets
                                .where((b) =>
                                    b.isRecurring &&
                                    b.categoryId == widget.category.id &&
                                    b.type == widget.budget.type)
                                .toList();
                            if (fallbackList.isNotEmpty) {
                              effectiveBudgetId = fallbackList.first.id;
                              print('BudgetDetail: using fallback recurring budgetId=$effectiveBudgetId for category=${widget.category.id} type=${widget.budget.type}');
                            } else {
                              print('BudgetDetail: ERROR no recurring underlying budget found for category=${widget.category.id} type=${widget.budget.type}');
                            }
                          }
                          
                          if (effectiveBudgetId.isEmpty) {
                            throw Exception('Cannot delete budget: no valid budget found for this category');
                          }
                          await provider.deleteBudget(effectiveBudgetId, cascadeDelete: cascadeDelete);
                          print('BudgetDetail: delete succeeded for budgetId=$effectiveBudgetId');
                        
                          // Ensure budgets list is refreshed so UI shows deletion immediately
                          await Provider.of<BudgetProvider>(context, listen: false).initialize();
                        
                          // Trigger a refresh of transactions if cascade delete was performed
                          if (cascadeDelete) {
                            Provider.of<HomeScreenProvider>(context, listen: false).triggerTransactionsRefresh();
                          }
                        
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

  @override
  void dispose() {
    // Remove provider listener if set
    _budgetProvider?.removeListener(_onProviderChanged);
    super.dispose();
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
              'No transactions found for this category in ${widget.budget.currency} currency for the selected period',
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
    
    // Get the icon color from the transaction, fallback to default if null
    final Color iconBackgroundColor = hexToColor(transaction.icon_color);
    final Color iconForegroundColor = getContrastingColor(iconBackgroundColor);

    return GestureDetector(
      onTap: () async {
        // Convert FirestoreTransaction to Transaction for navigation
        final uiTransaction = _convertToUiTransaction(transaction, context, _budgetCurrencyCode);
        
        // Navigate to ExpenseDetailScreen
        final result = await PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: ExpenseDetailScreen(transaction: uiTransaction),
          withNavBar: false,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );

        // Refresh data if transaction was deleted
        if (result == true && mounted) {
          _loadTransactions();
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: HugeIcon(icon: getIcon(widget.category.icon), color: iconForegroundColor, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // Use budget category name as the main title (fallback to transaction.description)
                    widget.category.name ?? transaction.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    // "Account Name - Account Type" formatted, skipping empty parts
                    [accountName, accountType].where((s) => s.isNotEmpty).join(' - '),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
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
              // Match home.dart amount formatting and style (sign + space + currency)
              '${transaction.type == 'income' ? '+' : '-'} $_currencySymbol${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: transaction.type == 'income' ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
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