import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/constants/transaction_type_enum.dart';
import 'package:budgetm/models/category.dart';
import 'package:budgetm/models/firestore_account.dart';
import 'package:budgetm/models/firestore_transaction.dart';
import 'package:budgetm/models/transaction.dart';
import 'package:budgetm/screens/dashboard/navbar/home/expense_detail/expense_detail_screen.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/viewmodels/home_screen_provider.dart';
import 'package:budgetm/viewmodels/vacation_mode_provider.dart';
import 'package:budgetm/utils/appTheme.dart';
import 'package:budgetm/utils/icon_utils.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:currency_picker/currency_picker.dart';

class BalanceDetailScreen extends StatefulWidget {
  final FirestoreAccount account;
  final int accountsCount;

  const BalanceDetailScreen({super.key, required this.account, required this.accountsCount});

  @override
  State<BalanceDetailScreen> createState() => _BalanceDetailScreenState();
}

class _BalanceDetailScreenState extends State<BalanceDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService.instance;
  DateTimeRange? _selectedDateRange;

  // Group transactions by date
  Map<DateTime, List<FirestoreTransaction>> _groupTransactionsByDate(List<FirestoreTransaction> transactions) {
    final Map<DateTime, List<FirestoreTransaction>> groupedTransactions = {};
    
    for (final transaction in transactions) {
      // Normalize date to midnight to ensure all transactions from the same day are grouped together
      final normalizedDate = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      
      if (groupedTransactions.containsKey(normalizedDate)) {
        groupedTransactions[normalizedDate]!.add(transaction);
      } else {
        groupedTransactions[normalizedDate] = [transaction];
      }
    }
    
    return groupedTransactions;
  }

  // Format date in a user-friendly way
  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (date.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (date.isAtSameMomentAs(yesterday)) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the correct currency symbol for the account being viewed
    final accountCurrencyCode = widget.account.currency;
    final currency = CurrencyService().findByCode(accountCurrencyCode);
    final currencySymbol = currency?.symbol ?? '\$';
    final currencyFormat = NumberFormat.currency(symbol: currencySymbol);
    
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
                    icon: const Icon(Icons.filter_list, color: Colors.black),
                    onPressed: _selectDateRange,
                  ),
                  IconButton(
                    icon: HugeIcon(icon: HugeIcons.strokeRoundedDelete04, color: Colors.red, size: 24),
                    onPressed: () => _showDeleteConfirmationDialog(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<FirestoreTransaction>>(
        stream: _firestoreService.getTransactionsForAccountStream(widget.account.id),
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

          // Calculate current balance
          double currentBalance = widget.account.initialBalance;
          if (snapshot.hasData) {
            // For vacation accounts, calculate remaining balance (initial - expenses)
            if (widget.account.isVacationAccount == true) {
              double totalExpenses = 0.0;
              for (final transaction in snapshot.data!) {
                final isExpense = transaction.type.toString().toLowerCase().contains('expense');
                if (isExpense) {
                  totalExpenses += transaction.amount;
                }
              }
              currentBalance = (widget.account.initialBalance - totalExpenses).clamp(0.0, double.infinity);
            } else {
              // For normal accounts, calculate balance from all transactions
              for (final transaction in snapshot.data!) {
                if (transaction.type == 'income') {
                  currentBalance += transaction.amount;
                } else {
                  currentBalance -= transaction.amount;
                }
              }
            }
          }
          
          // Filter transactions based on selected date range
          List<FirestoreTransaction> filteredTransactions = [];
          if (snapshot.hasData) {
            filteredTransactions = snapshot.data!;
            if (_selectedDateRange != null) {
              filteredTransactions = snapshot.data!.where((transaction) {
                final transactionDate = DateTime(
                  transaction.date.year,
                  transaction.date.month,
                  transaction.date.day,
                );
                final startDate = DateTime(
                  _selectedDateRange!.start.year,
                  _selectedDateRange!.start.month,
                  _selectedDateRange!.start.day,
                );
                final endDate = DateTime(
                  _selectedDateRange!.end.year,
                  _selectedDateRange!.end.month,
                  _selectedDateRange!.end.day,
                );
                return !transactionDate.isBefore(startDate) && !transactionDate.isAfter(endDate);
              }).toList();
            }
          }
          
          // Calculate filtered subtotal
          double filteredSubtotal = 0;
          for (final transaction in filteredTransactions) {
            if (widget.account.isVacationAccount == true) {
              // For vacation accounts, only count expenses
              final isExpense = transaction.type.toString().toLowerCase().contains('expense');
              if (isExpense) {
                filteredSubtotal -= transaction.amount;
              }
            } else {
              // For normal accounts, count both income and expenses
              if (transaction.type == 'income') {
                filteredSubtotal += transaction.amount;
              } else {
                filteredSubtotal -= transaction.amount;
              }
            }
          }

          return Column(
            children: [
              // Balance display section
              Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Row for Initial Balance and Current Balance
                    Row(
                      children: [
                        Expanded(
                          child: Semantics(
                            label: 'Initial Balance',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Initial Balance',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currencyFormat.format(widget.account.initialBalance),
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: Colors.black.withOpacity(0.2),
                        ),
                        Expanded(
                          child: Semantics(
                            label: 'Current Balance',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Current Balance',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currencyFormat.format(currentBalance),
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: currentBalance >= 0 ? Colors.black : Colors.red[300],
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Display filtered subtotal if a date range is selected
                    if (_selectedDateRange != null)
                      Semantics(
                        label: 'Filtered Total',
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Total for Selected Period',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedDateRange = null;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: Colors.red[400],
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currencyFormat.format(filteredSubtotal),
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: filteredSubtotal >= 0 ? Colors.black : Colors.red[300],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${DateFormat('MMM d').format(_selectedDateRange!.start)} - ${DateFormat('MMM d, yyyy').format(_selectedDateRange!.end)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              
              // Transactions list
              Expanded(
                child: (!snapshot.hasData || snapshot.data!.isEmpty)
                    ? Center(
                        child: SingleChildScrollView(
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
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Transactions for this account will appear here',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[500],
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : filteredTransactions.isEmpty
                        ? Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.filter_list_off,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No transactions found for the selected period',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try adjusting the date range filter',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey[500],
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _selectedDateRange = null;
                                      });
                                    },
                                    icon: const Icon(Icons.refresh, color: Colors.black,),
                                    label: const Text('Clear Filter', style: TextStyle(
                                      color: Colors.black
                                    ),),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.gradientStart,
                                      side: BorderSide(color: AppColors.gradientStart),
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _buildGroupedTransactionsList(filteredTransactions),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard(FirestoreTransaction transaction) {
    final isIncome = transaction.type == 'income';
    final isVacationTransaction = transaction.isVacation == true;
    
    // Determine the correct currency symbol for the account being viewed
    final accountCurrencyCode = widget.account.currency;
    final currency = CurrencyService().findByCode(accountCurrencyCode);
    final currencySymbol = currency?.symbol ?? '\$';
    
    // Get the icon color from the transaction, fallback to default if null
    final Color iconBackgroundColor = hexToColor(transaction.icon_color);
    final Color iconForegroundColor = getContrastingColor(iconBackgroundColor);

    // Apply vacation styling similar to home.dart
    final cardBackgroundColor = isVacationTransaction 
        ? Colors.blue.shade50  // Light blue background for vacation transactions
        : Colors.white;
    
    final cardBorderColor = isVacationTransaction
        ? Colors.blue.shade300  // Blue border for vacation transactions
        : Colors.grey.shade200;

    return GestureDetector(
      onTap: () async {
        // Convert FirestoreTransaction to Transaction for ExpenseDetailScreen
        final uiTransaction = await _convertToUiTransaction(transaction, accountCurrencyCode);
        if (mounted) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExpenseDetailScreen(transaction: uiTransaction),
            ),
          );
          // Check if result is true (indicating a change was made)
          if (result == true) {
            Provider.of<HomeScreenProvider>(context, listen: false).triggerTransactionsRefresh();
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cardBorderColor, width: 1),
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
              child: FutureBuilder<Category?>(
                future: transaction.categoryId != null
                    ? _firestoreService.getCategoryById(transaction.categoryId!)
                    : null,
                builder: (context, categorySnapshot) {
                  // Use category icon if available, otherwise use default income/expense icon
                  Widget iconWidget;
                  if (categorySnapshot.hasData && categorySnapshot.data != null) {
                    iconWidget = HugeIcon(
                      icon: getIcon(categorySnapshot.data!.icon),
                      color: iconForegroundColor,
                      size: 20,
                    );
                  } else {
                    iconWidget = Icon(
                      isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                      color: iconForegroundColor,
                      size: 20,
                    );
                  }
                  return iconWidget;
                },
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  transaction.paid == true ? Icons.check_circle : Icons.circle_outlined,
                  color: transaction.paid == true ? Colors.green : Colors.grey,
                  size: 16,
                ),
                // Add vacation icon for vacation transactions
                if (isVacationTransaction) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.flight_takeoff,
                    color: Colors.blue.shade600,
                    size: 14,
                  ),
                ],
                const SizedBox(width: 4),
                Text(
                  '${isIncome ? '+' : '-'} $currencySymbol${transaction.amount.toStringAsFixed(2)}',
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
                    title: const Text('Delete all associated transactions'),
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

  Future<Transaction> _convertToUiTransaction(FirestoreTransaction firestoreTransaction, String currencyCode) async {
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
      currency: currencyCode, // Use the passed-in currency code
    );
  }

  Widget _buildGroupedTransactionsList(List<FirestoreTransaction> transactions) {
    // Group transactions by date
    final groupedTransactions = _groupTransactionsByDate(transactions);
    
    // Sort dates in descending order (newest first)
    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dateTransactions = groupedTransactions[date]!;
        
        // Sort transactions for this date by date/time in descending order
        dateTransactions.sort((a, b) => b.date.compareTo(a.date));
        
       return StickyHeader(
         header: Container(
           padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
           decoration: BoxDecoration(
             color: Theme.of(context).scaffoldBackgroundColor,
           ),
            child: Row(
              children: [
                Text(
                  _formatDateHeader(date),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: AppColors.gradientStart.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    '${dateTransactions.length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: Column(
            children: dateTransactions.map((transaction) {
              return _buildTransactionCard(transaction);
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.gradientStart,
              secondary: AppColors.gradientEnd2,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.gradientStart,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }
}