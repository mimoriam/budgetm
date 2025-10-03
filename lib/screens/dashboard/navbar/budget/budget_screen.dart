import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/models/budget.dart';
import 'package:budgetm/viewmodels/budget_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:budgetm/viewmodels/navbar_visibility_provider.dart';
import 'package:budgetm/viewmodels/vacation_mode_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:budgetm/screens/dashboard/navbar/budget/budget_detail_screen.dart';
import 'package:budgetm/screens/dashboard/navbar/budget/add_budget_screen.dart';
import 'dart:ui';
import 'package:budgetm/screens/dashboard/main_screen.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen>
    with WidgetsBindingObserver {
  late ScrollController _scrollController;
  double _lastScrollOffset = 0.0;

  VacationProvider? _vacationProvider;
  NavbarVisibilityProvider? _navbarVisibilityProvider;
  bool _hasShownVacationDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _lastScrollOffset = 0.0;

    // Initialize budget provider only if not in vacation mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vacationProvider = Provider.of<VacationProvider>(
        context,
        listen: false,
      );
      if (!vacationProvider.isVacationMode) {
        Provider.of<BudgetProvider>(context, listen: false).initialize();
      }
    });
  }

  void _showVacationModeDialog() {
    // Diagnostic log to trace why/when this dialog is invoked
    print(
      'Budget: showing vacation dialog — routeIsCurrent=${ModalRoute.of(context)?.isCurrent}, isVacation=${_vacationProvider?.isVacationMode}',
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: AlertDialog(
            title: const Text('Vacation Mode Active'),
            content: const Text('This screen is only for normal mode'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _vacationListener() {
    if (!mounted) return;
    final isVacation = _vacationProvider?.isVacationMode ?? false;

    if (isVacation) {
      // Rebuild to show vacation UI and avoid loading data while in vacation mode
      setState(() {});
    } else {
      // When exiting vacation mode, initialize budget data and rebuild to show content
      Provider.of<BudgetProvider>(context, listen: false).initialize();
      setState(() {});
    }
  }

  void _navbarListener() {
    if (!mounted) return;
    final currentIndex = _navbarVisibilityProvider?.currentIndex ?? 0;
    // Show dialog only when Budget tab (index 1) becomes active and vacation mode is on
    if (currentIndex == 1 &&
        _vacationProvider?.isVacationMode == true &&
        !_hasShownVacationDialog) {
      print(
        'Budget: navbar became active and vacation active — tabIndex=$currentIndex',
      );
      _hasShownVacationDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showVacationModeDialog();
      });
    }
  }

  void _onScroll() {
    if (!mounted) return;
    if (!_scrollController.hasClients) return;

    final provider = Provider.of<NavbarVisibilityProvider>(
      context,
      listen: false,
    );
    final direction = _scrollController.position.userScrollDirection;

    if (direction == ScrollDirection.reverse) {
      provider.setNavBarVisibility(false);
    } else if (direction == ScrollDirection.forward) {
      provider.setNavBarVisibility(true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _vacationProvider?.removeListener(_vacationListener);
    _navbarVisibilityProvider?.removeListener(_navbarListener);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newVacation = Provider.of<VacationProvider>(context);
    if (_vacationProvider != newVacation) {
      _vacationProvider?.removeListener(_vacationListener);
      _vacationProvider = newVacation;
      _vacationProvider?.addListener(_vacationListener);
    }

    final newNavbar = Provider.of<NavbarVisibilityProvider>(context);
    if (_navbarVisibilityProvider != newNavbar) {
      _navbarVisibilityProvider?.removeListener(_navbarListener);
      _navbarVisibilityProvider = newNavbar;
      _navbarVisibilityProvider?.addListener(_navbarListener);
    }

    // If vacation mode is already active when dependencies change, show dialog once if Budget tab is active.
    final tabIndex =
        _navbarVisibilityProvider?.currentIndex ??
        Provider.of<NavbarVisibilityProvider>(
          context,
          listen: false,
        ).currentIndex;
    if (_vacationProvider?.isVacationMode == true && !_hasShownVacationDialog) {
      // Diagnostic log to record when the budget screen schedules the vacation dialog
      print(
        'Budget: dependencies detected vacation active — routeIsCurrent=${ModalRoute.of(context)?.isCurrent}, tabIndex=$tabIndex',
      );
      if (tabIndex == 1) {
        _hasShownVacationDialog = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showVacationModeDialog();
        });
      }
    } else if (_vacationProvider?.isVacationMode == false) {
      _hasShownVacationDialog = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final isVacation = Provider.of<VacationProvider>(
        context,
        listen: false,
      ).isVacationMode;
      if (!isVacation) {
        Provider.of<BudgetProvider>(context, listen: false).initialize();
      }
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

                // Use ListView instead of SingleChildScrollView to ensure proper scrolling behavior
                return ListView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 8.0,
                  ),
                  children: [
                    _buildBudgetSelectors(context, provider),
                    const SizedBox(height: 12),
                    _buildPieChart(context, provider),
                    const SizedBox(height: 8),
                    _buildCategoryList(context, provider),
                    // Add bottom spacing so last item is reachable above navbar
                    const SizedBox(height: 16),
                  ],
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
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              // Add button to create a new budget even when no budgets exist
              Container(
                // height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  shape: BoxShape.rectangle,
                  gradient: LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  // color: AppColors.gradientEnd,
                ),
                child: TextButton(
                  child: Text("Add Budget", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 12)),
                  onPressed: () async {
                    final result =
                        await PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: const AddBudgetScreen(),
                          withNavBar: false,
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                    if (result == true) {
                      if (context.mounted) {
                        Provider.of<BudgetProvider>(
                          context,
                          listen: false,
                        ).initialize();
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetSelectors(BuildContext context, BudgetProvider provider) {
    // Determine period navigation callbacks based on selected budget type
    VoidCallback onPrevious;
    VoidCallback onNext;
    VoidCallback onQuickJump;

    switch (provider.selectedBudgetType) {
      case BudgetType.weekly:
        onPrevious = provider.goToPreviousWeek;
        onNext = provider.goToNextWeek;
        onQuickJump = () =>
            _showQuickJumpPicker(context, provider, DatePickerMode.day);
        break;
      case BudgetType.monthly:
        onPrevious = provider.goToPreviousMonth;
        onNext = provider.goToNextMonth;
        onQuickJump = () =>
            _showQuickJumpPicker(context, provider, DatePickerMode.day);
        break;
      case BudgetType.yearly:
        onPrevious = provider.goToPreviousYear;
        onNext = provider.goToNextYear;
        onQuickJump = () =>
            _showQuickJumpPicker(context, provider, DatePickerMode.year);
        break;
    }

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Builder(
            builder: (ctx) {
              // Diagnostic: log selected type and displayed period to help debug UI updates
              WidgetsBinding.instance.addPostFrameCallback((_) {
                print(
                  'BudgetScreen: building selectors type=${provider.selectedBudgetType} period=${provider.currentPeriodDisplay}',
                );
              });
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTypeChip(
                    context,
                    'Weekly',
                    BudgetType.weekly,
                    provider.selectedBudgetType == BudgetType.weekly,
                    () => provider.changeBudgetType(BudgetType.weekly),
                  ),
                  const SizedBox(width: 12),
                  _buildTypeChip(
                    context,
                    'Monthly',
                    BudgetType.monthly,
                    provider.selectedBudgetType == BudgetType.monthly,
                    () => provider.changeBudgetType(BudgetType.monthly),
                  ),
                  const SizedBox(width: 12),
                  _buildTypeChip(
                    context,
                    'Yearly',
                    BudgetType.yearly,
                    provider.selectedBudgetType == BudgetType.yearly,
                    () => provider.changeBudgetType(BudgetType.yearly),
                  ),
                ],
              );
            },
          ),
          // const SizedBox(height: 12),
          PeriodSelector(
            periodText: provider.currentPeriodDisplay,
            onPrevious: onPrevious,
            onNext: onNext,
            onQuickJump: onQuickJump,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(
    BuildContext context,
    String label,
    BudgetType type,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gradientEnd : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Future<void> _showQuickJumpPicker(
    BuildContext context,
    BudgetProvider provider,
    DatePickerMode mode,
  ) async {
    DateTime initialDate;
    String helpText;

    switch (provider.selectedBudgetType) {
      case BudgetType.weekly:
        initialDate = DateTime.now();
        helpText = 'Select Date';
        break;
      case BudgetType.monthly:
        initialDate = provider.selectedMonth;
        helpText = 'Select Month';
        break;
      case BudgetType.yearly:
        initialDate = provider.selectedYear;
        helpText = 'Select Year';
        break;
    }

    print(
      'DEBUG _showQuickJumpPicker: type=${provider.selectedBudgetType}, mode=$mode, initialDate=$initialDate, helpText=$helpText',
    );

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDatePickerMode: mode,
      helpText: helpText,
    );

    print('DEBUG _showQuickJumpPicker: pickedDate=$pickedDate');

    if (pickedDate != null) {
      provider.setSelectedDate(pickedDate);
      print(
        'DEBUG _showQuickJumpPicker: called setSelectedDate with $pickedDate',
      );
    }
  }

  Widget _buildPieChart(BuildContext context, BudgetProvider provider) {
    if (provider.categoryBudgetData.isEmpty) {
      return _buildEmptyState(context);
    }

    final selectedCategory = provider.selectedCategoryId;
    final showingAll = selectedCategory == null;

    // Filter data: show budgets with limit>0 OR spentAmount>0
    // This ensures newly created budgets (with limit but no spending yet) are visible
    final totalCount = provider.categoryBudgetData.length;
    final displayData = showingAll
        ? provider.categoryBudgetData
              .where((data) => data.spentAmount > 0 || data.limit > 0)
              .toList()
        : provider.categoryBudgetData
              .where((data) => data.category.id == selectedCategory)
              .toList();

    // Diagnostic logs
    try {
      print(
        'BudgetScreen: selectedCategory=$selectedCategory showingAll=$showingAll totalCategories=$totalCount displayCount=${displayData.length}',
      );
      final hiddenByFilter = provider.categoryBudgetData
          .where((d) => d.spentAmount == 0 && d.limit == 0)
          .map((d) => {'categoryId': d.category.id, 'name': d.categoryName})
          .toList();
      print(
        'BudgetScreen: budgets hidden (no limit and no spending): $hiddenByFilter',
      );
    } catch (e) {
      print('BudgetScreen: error while logging diagnostic info: $e');
    }

    if (displayData.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
            height: 120,
            child: PieChart(
              PieChartData(
                sections: _buildPieChartSections(displayData),
                centerSpaceRadius: 30,
                sectionsSpace: 2,
                // pieTouchData: PieTouchData(
                //   touchCallback: (FlTouchEvent event, pieTouchResponse) {
                //     if (event is FlTapUpEvent &&
                //         pieTouchResponse?.touchedSection != null) {
                //       final index =
                //           pieTouchResponse!.touchedSection!.touchedSectionIndex;
                //       if (index >= 0 &&
                //           index < displayData.length &&
                //           showingAll) {
                //         provider.selectCategory(displayData[index].category.id);
                //       }
                //     }
                //   },
                // ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildPieChartLegend(displayData),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    List<CategoryBudgetData> data,
  ) {
    final total = data.fold(0.0, (sum, item) => sum + item.spentAmount);
    final useEqualSlices = total <= 0;
    if (useEqualSlices) {
      // Diagnostic: total is zero (no spending yet). Render equal slices and avoid division by zero.
      print(
        'BudgetScreen: totalSpent==0 - rendering equal slices for ${data.length} categories',
      );
    }

    return data.map((item) {
      final value = useEqualSlices ? 1.0 : item.spentAmount;
      final percentage = useEqualSlices
          ? 0.0
          : (item.spentAmount / total * 100);
      final categoryColor = _getColorFromString(item.categoryColor);
      return PieChartSectionData(
        value: value,
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
          padding: const EdgeInsets.symmetric(vertical: 2),
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
    // Show categories with spending > 0 OR limit > 0 (budgets exist)
    // This ensures newly created budgets appear even with no spending yet
    final data = provider.categoryBudgetData
        .where((d) => d.spentAmount > 0 || d.limit > 0)
        .toList();

    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Budgets',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: AppColors.gradientEnd,
              onPressed: () async {
                final result = await PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: const AddBudgetScreen(),
                  withNavBar: false,
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
                if (result == true) {
                  Provider.of<BudgetProvider>(
                    context,
                    listen: false,
                  ).initialize();
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...data.map((item) => _buildCategoryCard(context, item, provider)),
      ],
    );
  }

  String _formatAmountForCard(double amount) {
    if (amount.abs() >= 1000) {
      return '\$${(amount / 1000).floor()}k';
    }
    return '\$${amount.toStringAsFixed(2)}';
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
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: BudgetDetailScreen(
            category: data.category,
            budget: data.budget,
          ),
          withNavBar: false,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _getColorFromString(
                      data.categoryColor,
                    ).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconFromString(data.categoryIcon),
                    color: _getColorFromString(data.categoryColor),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                // Category name occupies the remaining space on its own line and can wrap
                Expanded(
                  child: Text(
                    data.categoryName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 2),

            // Row 3: amount, optional limit and edit button — amount and limit grouped on left, edit on right
            Row(
              children: [
                // Amount and limit aligned to start, allowed to scale down if very large
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        text: _formatAmountForCard(spent),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getColorFromString(data.categoryColor),
                        ),
                        children: [
                          if (hasLimit)
                            TextSpan(
                              text: ' / ${_formatAmountForCard(limit)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
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
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
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

                      // Update budget limit using the budget ID
                      try {
                        if (data.budget.id.isNotEmpty) {
                          await provider.updateBudgetLimit(
                            data.budget.id,
                            parsed,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Budget limit saved'),
                              ),
                            );
                          }
                        } else {
                          // If budget doesn't exist, create a new one
                          await provider.addBudget(
                            data.category.id,
                            parsed,
                            provider.selectedBudgetType,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Budget created')),
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          // Extract clean error message from exception
                          String errorMessage = e.toString();
                          if (errorMessage.startsWith('Exception: ')) {
                            errorMessage = errorMessage.substring(
                              'Exception: '.length,
                            );
                          }
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(errorMessage)));
                        }
                      }
                    }
                  },
                ),
              ],
            ),

            // Progress section remains on its own block below
            if (hasLimit) ...[
              const SizedBox(height: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress > 1.0
                          ? Colors.red
                          : (isOverBudget ? Colors.red : Colors.green),
                    ),
                  ),
                  const SizedBox(height: 4),
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
      padding: const EdgeInsets.all(24),
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
            'No budget created',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by creating a budget to see your spending breakdown here.',
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

// Reusable Period Selector Widget
class PeriodSelector extends StatelessWidget {
  final String periodText;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onQuickJump;

  const PeriodSelector({
    super.key,
    required this.periodText,
    required this.onPrevious,
    required this.onNext,
    required this.onQuickJump,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrevious,
            color: AppColors.gradientEnd,
            tooltip: 'Previous',
          ),
          Expanded(
            child: Text(
              periodText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryTextColorDark,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
            color: AppColors.gradientEnd,
            tooltip: 'Next',
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: onQuickJump,
            color: AppColors.gradientEnd,
            tooltip: 'Jump to date',
          ),
        ],
      ),
    );
  }
}
