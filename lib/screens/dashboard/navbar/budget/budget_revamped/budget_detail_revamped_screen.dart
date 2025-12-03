import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/generated/i18n/app_localizations.dart';
import 'package:budgetm/models/revamped_budget.dart';
import 'package:budgetm/models/firestore_transaction.dart';
import 'package:budgetm/models/transaction.dart' as model;
import 'package:budgetm/models/category.dart';
import 'package:budgetm/constants/transaction_type_enum.dart';
import 'package:budgetm/screens/dashboard/navbar/home/expense_detail/expense_detail_screen.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/viewmodels/home_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:budgetm/viewmodels/revamped_budget_provider.dart';
import 'package:budgetm/utils/appTheme.dart';
import 'package:budgetm/utils/icon_utils.dart';
import 'package:budgetm/utils/currency_formatter.dart';
import 'package:intl/intl.dart';

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
    paid: firestoreTransaction.paid,
    currency: currencyCode,
  );
}

class BudgetDetailRevampedScreen extends StatefulWidget {
  final RevampedBudget revampedBudget;
  final List<String> categoryNames;

  const BudgetDetailRevampedScreen({
    super.key,
    required this.revampedBudget,
    required this.categoryNames,
  });

  @override
  State<BudgetDetailRevampedScreen> createState() => _BudgetDetailRevampedScreenState();
}

class _BudgetDetailRevampedScreenState extends State<BudgetDetailRevampedScreen> {
  final FirestoreService _firestoreService = FirestoreService.instance;
  List<_TransactionWithAccount> _detailedTransactions = [];
  bool _isLoading = true;
  RevampedBudgetProvider? _budgetProvider;
  
  late String _budgetCurrencyCode;
  Set<String> _visibleCategoryIds = {};
  Map<String, double> _categorySpending = {};
  bool _showAllLegend = false;

  @override
  void initState() {
    super.initState();
    _budgetCurrencyCode = widget.revampedBudget.currency;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransactions();
      _budgetProvider = Provider.of<RevampedBudgetProvider>(context, listen: false);
      _budgetProvider?.addListener(_onProviderChanged);
    });
  }

  void _onProviderChanged() {
    if (!mounted) return;
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<RevampedBudgetProvider>(context, listen: false);
      
      // Get filtered transactions directly from provider (uses same logic as budget card)
      final filteredTransactions = provider.getTransactionsForBudget(widget.revampedBudget);
      
      print('BudgetDetailRevamped: Found ${filteredTransactions.length} transactions from provider');

      // Fetch all accounts once to avoid N+1 queries
      final allAccounts = await _firestoreService.getAllAccounts();
      final accountMap = {for (var a in allAccounts) a.id: a};

      // Map transactions to include account details
      _detailedTransactions = filteredTransactions.map((t) {
        String accountName = 'Unknown';
        String accountType = '';
        
        if (t.accountId != null && t.accountId!.isNotEmpty) {
          final account = accountMap[t.accountId];
          if (account != null) {
            accountName = account.name;
            accountType = account.accountType;
          }
        }
        
        return _TransactionWithAccount(
          transaction: t,
          accountName: accountName,
          accountType: accountType,
        );
      }).toList();

      // Sort by date descending
      _detailedTransactions.sort(
        (a, b) => b.transaction.date.compareTo(a.transaction.date),
      );

      // Calculate category spending
      _categorySpending.clear();
      for (var t in _detailedTransactions) {
        _categorySpending[t.transaction.categoryId] = 
            (_categorySpending[t.transaction.categoryId] ?? 0) + t.transaction.amount;
      }

      // Initialize visible categories if empty (first load)
      if (_visibleCategoryIds.isEmpty) {
        _visibleCategoryIds = widget.revampedBudget.categoryIds.toSet();
      }
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.revampedBudget.name ?? widget.categoryNames.join(', '),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${widget.revampedBudget.type.toString().split('.').last.capitalize()} • ${widget.revampedBudget.currency}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete_forever),
                    color: Colors.red,
                    onPressed: () async {
                      final result = await showDialog<Map<String, bool>>(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) {
                          return AlertDialog(
                            title: Text(AppLocalizations.of(context)!.budgetDetailDelete),
                            content: Text(AppLocalizations.of(context)!.budgetDetailDeleteConfirm),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop({'confirmed': false}),
                                child: Text(AppLocalizations.of(context)!.budgetDetailCancel),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop({'confirmed': true}),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: Text(AppLocalizations.of(context)!.budgetDetailDelete),
                              ),
                            ],
                          );
                        },
                      );
                        
                      if (result != null && result['confirmed'] == true) {
                        try {
                          await Provider.of<RevampedBudgetProvider>(
                            context,
                            listen: false,
                          ).deleteRevampedBudget(widget.revampedBudget.id);
                          
                          await Provider.of<RevampedBudgetProvider>(
                            context,
                            listen: false,
                          ).initialize();
                          
                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context)!.failedToDeleteBudget)),
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
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildCategorySpendingCard(),
                  _buildPieChartSection(),
                  _buildTransactionsList(),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
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

  Widget _buildCategorySpendingCard() {
    final provider = Provider.of<RevampedBudgetProvider>(context, listen: false);
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.budgetCategorySpending ?? 'Category Breakdown',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.revampedBudget.categoryIds.map((categoryId) {
            final category = provider.expenseCategories.firstWhere(
              (c) => c.id == categoryId,
              orElse: () => Category(id: '', name: 'Unknown', icon: '', color: '', displayOrder: 999),
            );
            final spent = _categorySpending[categoryId] ?? 0.0;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: hexToColor(category.color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: HugeIcon(
                      icon: getIcon(category.icon),
                      color: hexToColor(category.color),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category.name ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    formatCurrency(spent, _budgetCurrencyCode),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPieChartSection() {
    final provider = Provider.of<RevampedBudgetProvider>(context, listen: false);
    final visibleCategories = widget.revampedBudget.categoryIds
        .where((id) => _visibleCategoryIds.contains(id))
        .toList();
        
    if (visibleCategories.isEmpty) return const SizedBox.shrink();

    final totalVisibleSpent = visibleCategories.fold(0.0, (sum, id) => sum + (_categorySpending[id] ?? 0));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spending Analysis',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Filter Button
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: (value) {
                  setState(() {
                    if (_visibleCategoryIds.contains(value)) {
                      if (_visibleCategoryIds.length > 1) {
                        _visibleCategoryIds.remove(value);
                      }
                    } else {
                      _visibleCategoryIds.add(value);
                    }
                  });
                },
                itemBuilder: (context) {
                  return widget.revampedBudget.categoryIds.map((id) {
                    final category = provider.expenseCategories.firstWhere(
                      (c) => c.id == id,
                      orElse: () => Category(id: '', name: 'Unknown', icon: '', color: '', displayOrder: 999),
                    );
                    return CheckedPopupMenuItem<String>(
                      value: id,
                      checked: _visibleCategoryIds.contains(id),
                      child: Text(category.name ?? 'Unknown'),
                    );
                  }).toList();
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (totalVisibleSpent > 0)
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: visibleCategories.map((id) {
                    final category = provider.expenseCategories.firstWhere(
                      (c) => c.id == id,
                      orElse: () => Category(id: '', name: 'Unknown', icon: '', color: '', displayOrder: 999),
                    );
                    final spent = _categorySpending[id] ?? 0.0;
                    final percentage = (spent / totalVisibleSpent) * 100;
                    
                    return PieChartSectionData(
                      color: hexToColor(category.color),
                      value: spent,
                      title: '${percentage.toStringAsFixed(0)}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            )
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('No spending data for selected categories'),
              ),
            ),
          const SizedBox(height: 20),
          _buildLegend(provider),
        ],
      ),
    );
  }

  Widget _buildLegend(RevampedBudgetProvider provider) {
    final categories = widget.revampedBudget.categoryIds;
    final showCount = _showAllLegend ? categories.length : 3;
    final displayCategories = categories.take(showCount).toList();
    final hasMore = categories.length > 3;

    return Column(
      children: [
        ...displayCategories.map((id) {
          final category = provider.expenseCategories.firstWhere(
            (c) => c.id == id,
            orElse: () => Category(id: '', name: 'Unknown', icon: '', color: '', displayOrder: 999),
          );
          final spent = _categorySpending[id] ?? 0.0;
          final isVisible = _visibleCategoryIds.contains(id);

          return InkWell(
            onTap: () {
              setState(() {
                if (isVisible) {
                  if (_visibleCategoryIds.length > 1) {
                    _visibleCategoryIds.remove(id);
                  }
                } else {
                  _visibleCategoryIds.add(id);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isVisible ? hexToColor(category.color) : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      category.name ?? 'Unknown',
                      style: TextStyle(
                        color: isVisible ? Colors.black : Colors.grey,
                        decoration: isVisible ? null : TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                  Text(
                    formatCurrency(spent, _budgetCurrencyCode),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isVisible ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        if (hasMore)
          TextButton(
            onPressed: () {
              setState(() {
                _showAllLegend = !_showAllLegend;
              });
            },
            child: Text(_showAllLegend ? 'Show Less' : 'Show More'),
          ),
      ],
    );
  }

  Widget _buildTransactionsList() {
    final filteredTransactions = _detailedTransactions
        .where((t) => _visibleCategoryIds.contains(t.transaction.categoryId))
        .toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        final detailedTransaction = filteredTransactions[index];
        return _buildTransactionCard(detailedTransaction);
      },
    );
  }

  Widget _buildTransactionCard(_TransactionWithAccount detailedTransaction) {
    final transaction = detailedTransaction.transaction;
    
    // Get category name from the transaction's categoryId
    final provider = Provider.of<RevampedBudgetProvider>(context, listen: false);
    final category = provider.expenseCategories.firstWhere(
      (c) => c.id == transaction.categoryId,
      orElse: () => provider.allCategories.firstWhere(
        (c) => c.id == transaction.categoryId,
        orElse: () => Category(id: '', name: 'Unknown', icon: '', color: '', displayOrder: 999),
      ),
    );
    
    final Color iconBackgroundColor = hexToColor(transaction.icon_color);
    final Color iconForegroundColor = getContrastingColor(iconBackgroundColor);

    return GestureDetector(
      onTap: () async {
        final uiTransaction = _convertToUiTransaction(transaction, context, _budgetCurrencyCode);
        
        final result = await PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: ExpenseDetailScreen(transaction: uiTransaction),
          withNavBar: false,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );

        if (result == true && mounted) {
          _loadTransactions();
          Provider.of<HomeScreenProvider>(context, listen: false).triggerTransactionsRefresh();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200, width: 1),
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
              child: HugeIcon(
                icon: getIcon(category.icon),
                color: iconForegroundColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name ?? transaction.description,
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
                Icon(
                  transaction.paid == true ? Icons.check_circle : Icons.circle_outlined,
                  color: transaction.paid == true ? Colors.green : Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${transaction.type == 'income' ? '+' : '-'} ${formatCurrency(transaction.amount, transaction.currency)}',
                  style: TextStyle(
                    color: transaction.type == 'income' ? Colors.green : Colors.red,
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

