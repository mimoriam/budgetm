import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/viewmodels/budget_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budgetm/viewmodels/navbar_visibility_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen>
    with WidgetsBindingObserver {
  late ScrollController _scrollController;
  double _lastScrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _lastScrollOffset = 0.0;

    // Initialize budget provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BudgetProvider>(context, listen: false).initialize();
    });
  }

  void _onScroll() {
    if (!mounted) return;
    final provider = Provider.of<NavbarVisibilityProvider>(
      context,
      listen: false,
    );

    final offset = _scrollController.hasClients
        ? _scrollController.position.pixels
        : 0.0;
    const threshold = 5.0;
    if (offset > _lastScrollOffset + threshold) {
      provider.setNavBarVisibility(false);
    } else if (offset < _lastScrollOffset - threshold) {
      provider.setNavBarVisibility(true);
    }
    _lastScrollOffset = offset;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Provider.of<BudgetProvider>(context, listen: false).initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Column(
        children: [
          _buildCustomAppBar(context),
          Expanded(
            child: Consumer<BudgetProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMonthYearSelector(context, provider),
                      const SizedBox(height: 20),
                      _buildPieChart(context, provider),
                      const SizedBox(height: 24),
                      _buildCategoryList(context, provider),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
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

  Widget _buildMonthYearSelector(
    BuildContext context,
    BudgetProvider provider,
  ) {
    final monthName = DateFormat.MMMM().format(provider.selectedDate);
    final year = provider.selectedYear;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: provider.previousMonth,
            color: AppColors.gradientEnd,
          ),
          Text(
            '$monthName $year',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: provider.nextMonth,
            color: AppColors.gradientEnd,
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, BudgetProvider provider) {
    if (provider.categoryBudgetData.isEmpty) {
      return _buildEmptyState(context);
    }

    final selectedCategory = provider.selectedCategoryId;
    final showingAll = selectedCategory == null;

    // Filter data based on selection
    final displayData = showingAll
        ? provider.categoryBudgetData
              .where((data) => data.spentAmount > 0)
              .toList()
        : provider.categoryBudgetData
              .where((data) => data.category.id == selectedCategory)
              .toList();

    if (displayData.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                showingAll ? 'Total Spending' : 'Category Breakdown',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (!showingAll)
                TextButton(
                  onPressed: provider.clearCategorySelection,
                  child: const Text('View All'),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: _buildPieChartSections(displayData),
                centerSpaceRadius: 60,
                sectionsSpace: 2,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    if (event is FlTapUpEvent &&
                        pieTouchResponse?.touchedSection != null) {
                      final index =
                          pieTouchResponse!.touchedSection!.touchedSectionIndex;
                      if (index >= 0 &&
                          index < displayData.length &&
                          showingAll) {
                        provider.selectCategory(displayData[index].category.id);
                      }
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildPieChartLegend(displayData),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    List<CategoryBudgetData> data,
  ) {
    final total = data.fold(0.0, (sum, item) => sum + item.spentAmount);

    return data.map((item) {
      final percentage = (item.spentAmount / total * 100);
      final categoryColor = _getColorFromString(item.categoryColor);
      return PieChartSectionData(
        value: item.spentAmount,
        title: '${percentage.toStringAsFixed(1)}%',
        color: categoryColor,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildPieChartLegend(List<CategoryBudgetData> data) {
    return Column(
      children: data.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _getColorFromString(item.categoryColor),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.categoryName,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Text(
                '\$${item.spentAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryList(BuildContext context, BudgetProvider provider) {
    // Only show categories with spending > 0
    final data = provider.categoryBudgetData.where((d) => d.spentAmount > 0).toList();

    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...data.map((item) => _buildCategoryCard(context, item, provider)),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    CategoryBudgetData data,
    BudgetProvider provider,
  ) {
    final isSelected = provider.selectedCategoryId == data.category.id;
    final hasLimit = data.limit > 0;
    final spent = data.spentAmount;
    final limit = data.limit;
    final progress = hasLimit ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = hasLimit && spent > limit;
    final remaining = limit - spent;

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to Budget detail screen
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.gradientEnd : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: icon + category name (category name gets its own line)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getColorFromString(data.categoryColor).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconFromString(data.categoryIcon),
                    color: _getColorFromString(data.categoryColor),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Category name occupies the remaining space on its own line and can wrap
                Expanded(
                  child: Text(
                    data.categoryName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                    maxLines: 3,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),

            // const SizedBox(height: 8),

            // // Row 2: description label (its own line)
            // Text(
            //   'Spent this month',
            //   style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            //   softWrap: true,
            // ),

            // const SizedBox(height: 8),

            // Row 3: amount, optional limit and edit button — amount and limit grouped on left, edit on right
            Row(
              children: [
                // Amount and limit aligned to start, allowed to scale down if very large
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '\$${data.spentAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getColorFromString(data.categoryColor),
                          ),
                        ),
                      ),
                      if (hasLimit)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '/ \$${limit.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ),
                    ],
                  ),
                ),

                // Edit button stays at the end of the row
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.grey.shade600),
                  onPressed: () async {
                    final controller = TextEditingController(
                      text: hasLimit ? limit.toStringAsFixed(2) : '',
                    );
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          title: const Text('Set spending limit'),
                          content: TextField(
                            controller: controller,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              hintText: 'Enter limit amount',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Save'),
                            ),
                          ],
                        );
                      },
                    );
                    if (result == true) {
                      final text = controller.text.trim();
                      final parsed = double.tryParse(text);
                      if (parsed == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enter a valid number')),
                        );
                        return;
                      }
                      await provider.setBudgetLimit(data.category.id, parsed);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Budget limit saved')),
                      );
                    }
                  },
                ),
              ],
            ),

            // Progress section remains on its own block below
            if (hasLimit) ...[
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOverBudget ? Colors.red : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isOverBudget
                        ? '\$${(spent - limit).toStringAsFixed(2)} over budget'
                        : '\$${remaining.toStringAsFixed(2)} remaining',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isOverBudget ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(
            'images/launcher/logo.png',
            width: 80,
            height: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No expenses yet',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding expenses to see your budget breakdown',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
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
        if (colorName.isEmpty) {
          return Colors.grey;
        }
        final hash = colorName.hashCode;
        final r = (hash & 0xFF0000) >> 16;
        final g = (hash & 0x00FF00) >> 8;
        final b = hash & 0x0000FF;
        return Color.fromRGBO(r, g, b, 1);
    }
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName.toLowerCase()) {
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
