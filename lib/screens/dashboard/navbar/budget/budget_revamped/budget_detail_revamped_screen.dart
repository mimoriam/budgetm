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
import 'package:hugeicons/hugeicons.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:budgetm/viewmodels/revamped_budget_provider.dart';
import 'package:budgetm/utils/appTheme.dart';
import 'package:budgetm/utils/icon_utils.dart';
import 'package:budgetm/utils/currency_formatter.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

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
  List<_TransactionWithAccount> _allTransactions = []; // Store all to filter locally
  List<_TransactionWithAccount> _displayedTransactions = [];
  bool _isLoading = true;
  RevampedBudgetProvider? _budgetProvider;
  
  late String _budgetCurrencyCode;
  
  // New state variables for charts and filters
  Map<String, double> _categorySpending = {};
  List<String> _selectedCategoryIds = [];

  double _totalSpent = 0.0;

  final List<Color> _chartColors = [
    const Color(0xFF4361EE), // Blue
    const Color(0xFFF72585), // Pink
    const Color(0xFF4CC9F0), // Light Blue
    const Color(0xFF7209B7), // Purple
    const Color(0xFF3A0CA3), // Dark Blue
    const Color(0xFFFFB703), // Orange/Yellow
    const Color(0xFFFB8500), // Orange
    const Color(0xFF06D6A0), // Teal
    const Color(0xFFEF476F), // Red/Pink
    const Color(0xFF118AB2), // Blue
    const Color(0xFF073B4C), // Dark
  ];

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
      
      // Get filtered transactions directly from provider
      final filteredTransactions = provider.getTransactionsForBudget(widget.revampedBudget);
      
      // Calculate category spending and total
      _categorySpending.clear();
      _totalSpent = 0.0;
      for (var t in filteredTransactions) {
        if (t.type == 'expense') {
          final catId = t.categoryId ?? 'unknown';
          _categorySpending[catId] = (_categorySpending[catId] ?? 0.0) + t.amount;
          _totalSpent += t.amount;
        }
      }

      // Fetch all accounts once
      final allAccounts = await _firestoreService.getAllAccounts();
      final accountMap = {for (var a in allAccounts) a.id: a};

      // Map transactions
      _allTransactions = filteredTransactions.map((t) {
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
      _allTransactions.sort(
        (a, b) => b.transaction.date.compareTo(a.transaction.date),
      );

      _applyFilters();

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

  void _applyFilters() {
    if (_selectedCategoryIds.isEmpty) {
      _displayedTransactions = List.from(_allTransactions);
    } else {
      _displayedTransactions = _allTransactions.where((t) {
        return _selectedCategoryIds.contains(t.transaction.categoryId);
      }).toList();
    }
  }

  void _toggleCategoryFilter(String categoryId) {
    setState(() {
      if (_selectedCategoryIds.contains(categoryId)) {
        _selectedCategoryIds.remove(categoryId);
      } else {
        _selectedCategoryIds.add(categoryId);
      }
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
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
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${widget.revampedBudget.currency} • ${widget.revampedBudget.type.toString().split('.').last}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade800,
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
                    onPressed: _confirmDelete,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPieChartSection(),
                        const SizedBox(height: 20),

                        const SizedBox(height: 20),
                        Text(
                          "Transactions",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _displayedTransactions.isEmpty
                    ? SliverToBoxAdapter(child: _buildEmptyState())
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return _buildTransactionCard(_displayedTransactions[index]);
                          },
                          childCount: _displayedTransactions.length,
                        ),
                      ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
              ],
            ),
    );
  }



  Widget _buildPieChartSection() {
    if (_categorySpending.isEmpty) return const SizedBox.shrink();

    final provider = Provider.of<RevampedBudgetProvider>(context, listen: false);
    final sortedEntries = _categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Assign distinct colors to categories
    final Map<String, Color> categoryColors = {};
    for (int i = 0; i < sortedEntries.length; i++) {
      categoryColors[sortedEntries[i].key] = _chartColors[i % _chartColors.length];
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Spending Distribution",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              _buildFilterDropdown(),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: sortedEntries.map((entry) {
                  final category = _getCategory(entry.key, provider);
                  final isSelected = _selectedCategoryIds.contains(entry.key);
                  final percentage = _totalSpent > 0 ? (entry.value / _totalSpent) * 100 : 0.0;
                  final color = categoryColors[entry.key]!;
                  final textColor = getContrastingColor(color);
                  
                  return PieChartSectionData(
                    color: color,
                    value: entry.value,
                    title: '${percentage.toStringAsFixed(0)}%',
                    radius: isSelected ? 60 : 50,
                    titleStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    badgeWidget: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: HugeIcon(
                        icon: getIcon(category.icon),
                        color: color,
                        size: 14,
                      ),
                    ),
                    badgePositionPercentageOffset: 1.3,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Detailed list below chart
          ...sortedEntries.map((entry) {
            final category = _getCategory(entry.key, provider);
            final amount = entry.value;
            final percentage = _totalSpent > 0 ? (amount / _totalSpent) : 0.0;
            final color = categoryColors[entry.key]!;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: HugeIcon(
                      icon: getIcon(category.icon),
                      color: color,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              category.name ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              formatCurrency(amount, widget.revampedBudget.currency),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: percentage,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    if (_categorySpending.isEmpty) return const SizedBox.shrink();

    final provider = Provider.of<RevampedBudgetProvider>(context, listen: false);
    final sortedEntries = _categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.filter_list, size: 20, color: Colors.black87),
      ),
      tooltip: 'Filter by Category',
      onSelected: _toggleCategoryFilter,
      itemBuilder: (BuildContext context) {
        return sortedEntries.map((entry) {
          final category = _getCategory(entry.key, provider);
          return CheckedPopupMenuItem<String>(
            value: entry.key,
            checked: _selectedCategoryIds.contains(entry.key),
            child: Text(
              category.name ?? 'Unknown',
              style: const TextStyle(fontSize: 14),
            ),
          );
        }).toList();
      },
    );
  }



  Category _getCategory(String? categoryId, RevampedBudgetProvider provider) {
    if (categoryId == null) return Category(id: '', name: 'Unknown', icon: '', color: '', displayOrder: 999);
    
    return provider.expenseCategories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => provider.allCategories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => Category(id: '', name: 'Unknown', icon: '', color: '', displayOrder: 999),
      ),
    );
  }

  Future<void> _confirmDelete() async {
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

  Widget _buildTransactionCard(_TransactionWithAccount detailedTransaction) {
    final transaction = detailedTransaction.transaction;
    final provider = Provider.of<RevampedBudgetProvider>(context, listen: false);
    final category = _getCategory(transaction.categoryId, provider);
    
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
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
