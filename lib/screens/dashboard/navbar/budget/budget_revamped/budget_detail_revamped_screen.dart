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
import 'package:budgetm/screens/dashboard/navbar/budget/budget_revamped/add_budget_revamped_screen.dart';

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
  List<String>? _selectedCategoryIds;
  bool _showAllCategories = false;

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
    if (_selectedCategoryIds == null) {
      _displayedTransactions = List.from(_allTransactions);
    } else {
      _displayedTransactions = _allTransactions.where((t) {
        return _selectedCategoryIds!.contains(t.transaction.categoryId);
      }).toList();
    }
  }

  void _toggleCategoryFilter(String categoryId) {
    setState(() {
      if (_selectedCategoryIds == null) {
        // Transition from Implicit All to Explicit All minus one
        _selectedCategoryIds = _categorySpending.keys.toList();
        _selectedCategoryIds!.remove(categoryId);
      } else {
        if (_selectedCategoryIds!.contains(categoryId)) {
          _selectedCategoryIds!.remove(categoryId);
        } else {
          _selectedCategoryIds!.add(categoryId);
        }
      }
      
      // If all are selected, revert to Implicit All (optional, but keeps state clean)
      if (_selectedCategoryIds != null && _categorySpending.isNotEmpty && 
          _selectedCategoryIds!.length == _categorySpending.length) {
        _selectedCategoryIds = null;
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
                  // Edit button
                  IconButton(
                    icon: const Icon(Icons.edit),
                    color: Colors.black,
                    onPressed: _editBudget,
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
                        // const SizedBox(height: 10),

                        // const SizedBox(height: 20),
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
      ..sort((a, b) {
        // Prioritize selected categories
        if (_selectedCategoryIds != null) {
          final aSelected = _selectedCategoryIds!.contains(a.key);
          final bSelected = _selectedCategoryIds!.contains(b.key);
          if (aSelected && !bSelected) return -1;
          if (!aSelected && bSelected) return 1;
        }
        // Then sort by value descending
        return b.value.compareTo(a.value);
      });

    // Assign distinct colors to categories
    final Map<String, Color> categoryColors = {};
    for (int i = 0; i < sortedEntries.length; i++) {
      categoryColors[sortedEntries[i].key] = _chartColors[i % _chartColors.length];
    }

    final int maxVisible = 2;
    final bool hasMore = sortedEntries.length > maxVisible;
    final List<MapEntry<String, double>> visibleEntries = (_showAllCategories || !hasMore) 
        ? sortedEntries 
        : sortedEntries.take(maxVisible).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                  fontSize: 16,
                ),
              ),
              _buildFilterDropdown(),
            ],
          ),
          const SizedBox(height: 36),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 35,
                sections: sortedEntries.map((entry) {
                  final category = _getCategory(entry.key, provider);
                  final isSelected = _selectedCategoryIds == null || _selectedCategoryIds!.contains(entry.key);
                  final percentage = _totalSpent > 0 ? (entry.value / _totalSpent) * 100 : 0.0;
                  final color = categoryColors[entry.key]!;
                  final textColor = getContrastingColor(color);
                  
                  return PieChartSectionData(
                    color: color,
                    value: entry.value,
                    title: '${percentage.toStringAsFixed(0)}%',
                    radius: isSelected ? 55 : 45,
                    titleStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    badgeWidget: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        category.name ?? 'Unknown',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    badgePositionPercentageOffset: 1.5,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Detailed list below chart
          ...visibleEntries.map((entry) {
            final category = _getCategory(entry.key, provider);
            final amount = entry.value;
            final percentage = _totalSpent > 0 ? (amount / _totalSpent) : 0.0;
            final color = categoryColors[entry.key]!;
            final isSelected = _selectedCategoryIds == null || _selectedCategoryIds!.contains(entry.key);

            
            // Dim unselected items if there is an active filter (and we are not showing all)
            // If _selectedCategoryIds is null, all are selected, so no dimming.
            // If _selectedCategoryIds is not null, dim unselected.
            final double opacity = (isSelected) ? 1.0 : 0.4;
            
            return GestureDetector(
              onTap: () => _toggleCategoryFilter(entry.key),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: opacity,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6.0),
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.05) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected ? Border.all(color: color.withOpacity(0.3)) : Border.all(color: Colors.transparent),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: HugeIcon(
                          icon: getIcon(category.icon),
                          color: color,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 10),
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
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  formatCurrency(amount, widget.revampedBudget.currency),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: percentage,
                                backgroundColor: Colors.grey.shade100,
                                valueColor: AlwaysStoppedAnimation<Color>(color),
                                minHeight: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          
          if (hasMore)
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showAllCategories = !_showAllCategories;
                  });
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _showAllCategories ? "Show Less" : "Show More",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _showAllCategories ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Theme.of(context).primaryColor,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    if (_categorySpending.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _showFilterBottomSheet,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.filter_list, size: 20, color: Colors.black87),
      ),
    );
  }

  Future<void> _showFilterBottomSheet() async {
    final provider = Provider.of<RevampedBudgetProvider>(context, listen: false);
    final sortedEntries = _categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            // If null, all are selected (Implicit All).
            // If not null, check containment.
            final effectiveSelectedIds = _selectedCategoryIds ?? sortedEntries.map((e) => e.key).toSet();
            final allSelected = effectiveSelectedIds.length == sortedEntries.length;
            
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: 8 + MediaQuery.of(ctx).viewPadding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Filter Categories',
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  // Add All / Remove All Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        setModalState(() {
                          if (allSelected) {
                            // Remove All -> Explicit None
                            _selectedCategoryIds = [];
                          } else {
                            // Select All -> Implicit All (null)
                            _selectedCategoryIds = null;
                          }
                          _applyFilters();
                        });
                        setState(() {});
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color: allSelected 
                              ? AppColors.errorColor.withOpacity(0.1) 
                              : AppColors.buttonBackground.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: allSelected 
                                ? AppColors.errorColor.withOpacity(0.3) 
                                : AppColors.buttonBackground,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            allSelected ? 'Remove All Filters' : 'Select All Categories',
                            style: TextStyle(
                              color: allSelected ? AppColors.errorColor : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: sortedEntries.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final entry = sortedEntries[index];
                        final category = _getCategory(entry.key, provider);
                        final isSelected = _selectedCategoryIds == null || _selectedCategoryIds!.contains(entry.key);
                        
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              if (_selectedCategoryIds == null) {
                                // Implicit All -> Explicit All minus one
                                _selectedCategoryIds = sortedEntries.map((e) => e.key).toList();
                                _selectedCategoryIds!.remove(entry.key);
                              } else {
                                if (_selectedCategoryIds!.contains(entry.key)) {
                                  _selectedCategoryIds!.remove(entry.key);
                                } else {
                                  _selectedCategoryIds!.add(entry.key);
                                }
                                
                                // If all selected, revert to Implicit All
                                if (_selectedCategoryIds!.length == sortedEntries.length) {
                                  _selectedCategoryIds = null;
                                }
                              }
                              
                              _applyFilters();
                            });
                            setState(() {});
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? AppColors.buttonBackground.withOpacity(0.15) 
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected 
                                    ? AppColors.buttonBackground 
                                    : Colors.grey.shade200,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? AppColors.buttonBackground.withOpacity(0.3) 
                                        : Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: HugeIcon(
                                    icon: getIcon(category.icon),
                                    color: isSelected 
                                        ? Colors.black87 
                                        : Colors.grey.shade600,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    category.name ?? 'Unknown',
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      color: isSelected ? Colors.black87 : Colors.grey.shade800,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.black87,
                                    size: 22,
                                  )
                                else
                                  Icon(
                                    Icons.circle_outlined,
                                    color: Colors.grey.shade300,
                                    size: 22,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonBackground,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Done',
                            style: TextStyle(
                              color: Colors.black, 
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    setState(() {});
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

  void _editBudget() {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: AddBudgetRevampedScreen(
        budgetToEdit: widget.revampedBudget,
      ),
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    ).then((result) {
      if (result != null && result is String && mounted) {
        // Fetch the new/updated budget from provider
        final provider = Provider.of<RevampedBudgetProvider>(context, listen: false);
        try {
          final newBudget = provider.revampedBudgets.firstWhere((b) => b.id == result);
          
          // Get category names
          final categoryNames = newBudget.categoryIds.map((id) {
            final category = provider.expenseCategories.firstWhere(
              (c) => c.id == id,
              orElse: () => Category(id: '', name: 'Unknown', icon: '', color: '', displayOrder: 999),
            );
            return category.name ?? 'Unknown';
          }).toList();

          // Replace current screen with updated one to reflect changes (especially if ID changed or immutable fields changed)
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => BudgetDetailRevampedScreen(
                revampedBudget: newBudget,
                categoryNames: categoryNames,
              ),
            ),
          );
        } catch (e) {
          // Budget not found (maybe deleted or error), pop back
          Navigator.of(context).pop();
        }
      }
    });
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
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 12, right: 12),
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
