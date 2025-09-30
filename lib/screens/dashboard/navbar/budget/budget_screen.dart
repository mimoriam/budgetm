import 'package:budgetm/constants/appColors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/models/budget.dart';
import 'package:budgetm/models/category.dart';
import 'package:budgetm/screens/dashboard/navbar/budget/add_budget/add_budget_screen.dart';
import 'package:provider/provider.dart';
import 'package:budgetm/viewmodels/navbar_visibility_provider.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  int touchedIndex = -1;
  late FirestoreService _firestoreService;
  late Stream<List<Budget>> _budgetStream;
  List<Category> _categories = [];
  List<Budget> _allBudgets = [];
  double _totalBudgetAmount = 0.0;
  late ScrollController _scrollController;
  double _lastScrollOffset = 0.0;
  Budget? _selectedBudget;

  final List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.cyan,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService.instance;
    _budgetStream = _firestoreService.streamBudgets();
    _loadCategories();

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _lastScrollOffset = 0.0;
  }

  void _onScroll() {
    if (!mounted) return;
    final provider = Provider.of<NavbarVisibilityProvider>(context, listen: false);

    final offset = _scrollController.hasClients ? _scrollController.position.pixels : 0.0;
    // small threshold to avoid rapid toggles on tiny movements
    const threshold = 5.0;
    if (offset > _lastScrollOffset + threshold) {
      // Scrolling down
      provider.setNavBarVisibility(false);
    } else if (offset < _lastScrollOffset - threshold) {
      // Scrolling up
      provider.setNavBarVisibility(true);
    }
    _lastScrollOffset = offset;
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _firestoreService.getAllCategories();
      if (mounted) {
        setState(() {
          _categories = cats;
        });
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      floatingActionButton: FloatingActionButton(
        heroTag: 'addBudgetButton',
        onPressed: () {
          final completedNames = _allBudgets
              .where((b) => b.currentAmount >= b.totalAmount)
              .map((b) => b.name)
              .toList();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddBudgetScreen(),
              settings: RouteSettings(arguments: {'completedBudgetNames': completedNames}),
            ),
          );
        },
        backgroundColor: AppColors.gradientEnd,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildCustomAppBar(context),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreamBuilder<List<Budget>>(
                    stream: _budgetStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPieChart([]),
                            const SizedBox(height: 12),
                            _buildLegend([]),
                            const SizedBox(height: 16),
                            _buildSectionHeader('ACTIVE BUDGETS'),
                            const SizedBox(height: 8),
                            Center(child: Text('Failed to load budgets', style: Theme.of(context).textTheme.bodySmall)),
                          ],
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPieChart([]),
                            const SizedBox(height: 12),
                            _buildLegend([]),
                            const SizedBox(height: 16),
                            _buildSectionHeader('ACTIVE BUDGETS'),
                            const SizedBox(height: 8),
                            Center(child: CircularProgressIndicator()),
                          ],
                        );
                      }
      
                      final budgetsFromSnapshot = snapshot.data ?? [];
      
                      // schedule state update to store all budgets and compute total safely after frame
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          final activeFromSnapshot = budgetsFromSnapshot.where((b) => b.currentAmount < b.totalAmount).toList();
                          final activeTotal = activeFromSnapshot.fold<double>(0.0, (sum, b) => sum + b.totalAmount);
                          setState(() {
                            _allBudgets = budgetsFromSnapshot;
                            _totalBudgetAmount = activeTotal;
                          });
                        }
                      });
      
                      // Use cached _allBudgets for UI if available, otherwise fallback to snapshot data
                      final sourceBudgets = _allBudgets.isNotEmpty ? _allBudgets : budgetsFromSnapshot;
                      final activeBudgets = sourceBudgets.where((b) => b.currentAmount < b.totalAmount).toList();
                      final completedBudgets = sourceBudgets.where((b) => b.currentAmount >= b.totalAmount).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPieChart(activeBudgets),
                          const SizedBox(height: 24),
                          _buildLegend(activeBudgets),
                          const SizedBox(height: 16),
                          _buildSectionHeader('ACTIVE BUDGETS'),
                          // const SizedBox(height: 4),
                          activeBudgets.isEmpty
                              ? Center(child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text('No active budgets', style: Theme.of(context).textTheme.bodySmall),
                              ))
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: activeBudgets.length,
                                  itemBuilder: (context, index) {
                                    final b = activeBudgets[index];
                                    final category = _categories.firstWhere(
                                      (c) => c.id == b.categoryId,
                                      orElse: () => Category(id: '', name: 'Uncategorized'),
                                    );
                                    final catName = category.name ?? 'Uncategorized';
                                    final daysLeft = b.endDate.difference(DateTime.now()).inDays;
                                    final isSelected = _selectedBudget?.id == b.id;

                                    return Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () => _handleBudgetSelection(b),
                                          child: _buildBudgetItem(
                                            icon: HugeIcons.strokeRoundedHome01,
                                            iconColor: Colors.green,
                                            iconBackgroundColor: Colors.green.shade100,
                                            budgetName: b.name,
                                            categoryName: catName,
                                            currentAmount: b.currentAmount,
                                            totalAmount: b.totalAmount,
                                            daysLeft: daysLeft < 0 ? 0 : daysLeft,
                                            isSelected: isSelected,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    );
                                  },
                                ),
                          const SizedBox(height: 16),
                          _buildSectionHeader('COMPLETED BUDGETS'),
                          // const SizedBox(height: 4),
                          completedBudgets.isEmpty
                              ? Center(child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text('No completed budgets', style: Theme.of(context).textTheme.bodySmall),
                              ))
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: completedBudgets.length,
                                  itemBuilder: (context, index) {
                                    final b = completedBudgets[index];
                                    final category = _categories.firstWhere(
                                      (c) => c.id == b.categoryId,
                                      orElse: () => Category(id: '', name: 'Uncategorized'),
                                    );
                                    final catName = category.name ?? 'Uncategorized';
                                    final daysLeft = b.endDate.difference(DateTime.now()).inDays;
                                    return Column(
                                      children: [
                                        _buildBudgetItem(
                                          icon: HugeIcons.strokeRoundedHome01,
                                          iconColor: Colors.blueGrey,
                                          iconBackgroundColor: Colors.blueGrey.shade50,
                                          budgetName: b.name,
                                          categoryName: catName,
                                          currentAmount: b.currentAmount,
                                          totalAmount: b.totalAmount,
                                          daysLeft: daysLeft < 0 ? 0 : daysLeft,
                                          isSelected: false, // Completed budgets are not selectable
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    );
                                  },
                                ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleBudgetSelection(Budget budget) {
    setState(() {
      if (_selectedBudget?.id == budget.id) {
        _selectedBudget = null; // Deselect if the same budget is tapped again
      } else {
        _selectedBudget = budget; // Select the new budget
      }
    });
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
                'Budget',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(List<Budget> activeBudgets) {
    final bool isIndividual = _selectedBudget != null;

    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
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
                    touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 70,
              sections: isIndividual
                  ? _buildIndividualPieChartSections(_selectedBudget!)
                  : _buildAggregatedPieChartSections(activeBudgets),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isIndividual ? _selectedBudget!.name : 'Total Budget',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryTextColorLight,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                isIndividual
                    ? '\$${_selectedBudget!.totalAmount.toStringAsFixed(0)}'
                    : '\$${_totalBudgetAmount.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildAggregatedPieChartSections(List<Budget> activeBudgets) {
    if (activeBudgets.isEmpty) {
      return [
        PieChartSectionData(
          color: Colors.grey.shade300,
          value: 1,
          title: '',
          radius: 35.0,
        ),
      ];
    }

    final double totalSpent = activeBudgets.fold(0.0, (sum, budget) => sum + budget.currentAmount);
    final double totalBudget = activeBudgets.fold(0.0, (sum, budget) => sum + budget.totalAmount);
    final double totalRemaining = totalBudget - totalSpent;

    final isTouchedSpent = touchedIndex == 0;
    final isTouchedRemaining = touchedIndex == 1;

    return [
      PieChartSectionData(
        color: AppColors.gradientEnd,
        value: totalSpent,
        title: '',
        radius: isTouchedSpent ? 45.0 : 35.0,
      ),
      PieChartSectionData(
        color: Colors.grey.shade300,
        value: totalRemaining > 0 ? totalRemaining : 0,
        title: '',
        radius: isTouchedRemaining ? 45.0 : 35.0,
      ),
    ];
  }

  List<PieChartSectionData> _buildIndividualPieChartSections(Budget budget) {
    final double spent = budget.currentAmount;
    final double remaining = budget.totalAmount - spent;

    final isTouchedSpent = touchedIndex == 0;
    final isTouchedRemaining = touchedIndex == 1;

    return [
      PieChartSectionData(
        color: AppColors.gradientEnd,
        value: spent,
        title: '',
        radius: isTouchedSpent ? 45.0 : 35.0,
      ),
      PieChartSectionData(
        color: Colors.grey.shade300,
        value: remaining > 0 ? remaining : 0,
        title: '',
        radius: isTouchedRemaining ? 45.0 : 35.0,
      ),
    ];
  }

  Widget _buildLegend(List<Budget> activeBudgets) {
    final bool isIndividual = _selectedBudget != null;

    if (isIndividual) {
      final budget = _selectedBudget!;
      final spent = budget.currentAmount;
      final remaining = budget.totalAmount - spent;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(AppColors.gradientEnd, 'Spent: \$${spent.toStringAsFixed(0)}'),
          const SizedBox(width: 16),
          _buildLegendItem(Colors.grey.shade300, 'Remaining: \$${remaining.toStringAsFixed(0)}'),
        ],
      );
    }

    if (activeBudgets.isEmpty) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(Colors.grey.shade300, 'No active budgets'),
        ],
      );
    }

    final double totalSpent = activeBudgets.fold(0.0, (sum, budget) => sum + budget.currentAmount);
    final double totalBudget = activeBudgets.fold(0.0, (sum, budget) => sum + budget.totalAmount);
    final double totalRemaining = totalBudget - totalSpent;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(AppColors.gradientEnd, 'Spent: \$${totalSpent.toStringAsFixed(0)}'),
        const SizedBox(width: 16),
        _buildLegendItem(Colors.grey.shade300, 'Remaining: \$${totalRemaining.toStringAsFixed(0)}'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
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

  Widget _buildBudgetItem({
    required List<List<dynamic>> icon,
    required Color iconColor,
    required Color iconBackgroundColor,
    required String budgetName,
    required String categoryName,
    required double currentAmount,
    required double totalAmount,
    required int daysLeft,
    required bool isSelected,
  }) {
    final double progress = totalAmount > 0 ? currentAmount / totalAmount : 0;
    final double remainingPercent = 100 - (progress * 100);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? Colors.green : Colors.grey.shade200,
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: HugeIcon(icon: icon, size: 24, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budgetName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      categoryName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryTextColorLight,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${currentAmount.toStringAsFixed(2)}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                color: AppColors.gradientEnd,
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${totalAmount.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryTextColorLight,
                    ),
                  ),
                  Text(
                    '${remainingPercent.toStringAsFixed(0)}% Remaining',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryTextColorLight,
                    ),
                  ),
                  Text(
                    '$daysLeft days left',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryTextColorLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}