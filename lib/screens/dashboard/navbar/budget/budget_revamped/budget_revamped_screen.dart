import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/generated/i18n/app_localizations.dart';
import 'package:budgetm/models/budget.dart';
import 'package:budgetm/viewmodels/revamped_budget_provider.dart';
import 'package:budgetm/viewmodels/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:budgetm/viewmodels/navbar_visibility_provider.dart';

import 'package:table_calendar/table_calendar.dart';
import 'package:budgetm/screens/dashboard/navbar/budget/budget_revamped/budget_detail_revamped_screen.dart';
import 'package:budgetm/screens/dashboard/navbar/budget/budget_revamped/add_budget_revamped_screen.dart';
import 'package:budgetm/utils/currency_formatter.dart';
import 'dart:ui';

class BudgetRevampedScreen extends StatefulWidget {
  const BudgetRevampedScreen({super.key});

  @override
  State<BudgetRevampedScreen> createState() => _BudgetRevampedScreenState();
}

class _BudgetRevampedScreenState extends State<BudgetRevampedScreen>
    with WidgetsBindingObserver {
  late ScrollController _scrollController;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Initialize revamped budget provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RevampedBudgetProvider>(context, listen: false).initialize();
    });
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
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Provider.of<RevampedBudgetProvider>(context, listen: false).initialize();
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
            child: Consumer<RevampedBudgetProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

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

                    _buildCategoryList(context, provider),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.budgetTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  shape: BoxShape.rectangle,
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.gradientStart,
                      AppColors.gradientEnd,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add,
                        size: 16,
                        color: Colors.black,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Add Budget',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    final provider = Provider.of<RevampedBudgetProvider>(
                      context,
                      listen: false,
                    );
                    final result =
                        await PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: AddBudgetRevampedScreen(
                            initialBudgetType: provider.selectedBudgetType,
                          ),
                          withNavBar: false,
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                    if (result == true) {
                      if (context.mounted) {
                        Provider.of<RevampedBudgetProvider>(
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

  Widget _buildBudgetSelectors(BuildContext context, RevampedBudgetProvider provider) {
    VoidCallback onPrevious;
    VoidCallback onNext;
    VoidCallback onQuickJump;

    switch (provider.selectedBudgetType) {
      case BudgetType.weekly:
        onPrevious = provider.goToPreviousWeek;
        onNext = provider.goToNextWeek;
        onQuickJump = () => _showPrettyCalendarPicker(context, provider);
        break;
      case BudgetType.monthly:
        onPrevious = provider.goToPreviousMonth;
        onNext = provider.goToNextMonth;
        onQuickJump = () => _showPrettyCalendarPicker(context, provider);
        break;
      case BudgetType.daily:
        onPrevious = provider.goToPreviousDay;
        onNext = provider.goToNextDay;
        onQuickJump = () => _showPrettyCalendarPicker(context, provider);
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTypeChip(
                context,
                AppLocalizations.of(context)!.budgetDaily,
                BudgetType.daily,
                provider.selectedBudgetType == BudgetType.daily,
                () => provider.changeBudgetType(BudgetType.daily),
              ),
              const SizedBox(width: 12),
              _buildTypeChip(
                context,
                AppLocalizations.of(context)!.budgetWeekly,
                BudgetType.weekly,
                provider.selectedBudgetType == BudgetType.weekly,
                () => provider.changeBudgetType(BudgetType.weekly),
              ),
              const SizedBox(width: 12),
              _buildTypeChip(
                context,
                AppLocalizations.of(context)!.budgetMonthly,
                BudgetType.monthly,
                provider.selectedBudgetType == BudgetType.monthly,
                () => provider.changeBudgetType(BudgetType.monthly),
              ),
            ],
          ),
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

  Future<void> _showPrettyCalendarPicker(
    BuildContext context,
    RevampedBudgetProvider provider,
  ) async {
    DateTime initialDate;
    switch (provider.selectedBudgetType) {
      case BudgetType.weekly:
        initialDate = DateTime.now();
        break;
      case BudgetType.monthly:
        initialDate = provider.selectedMonth;
        break;
      case BudgetType.daily:
        initialDate = provider.selectedDay;
        break;
    }

    DateTime tempSelected = initialDate;
    DateTime focusedDay = initialDate;

    CalendarFormat calendarFormat =
        provider.selectedBudgetType == BudgetType.weekly
        ? CalendarFormat.week
        : CalendarFormat.month;

    final navbarProvider = Provider.of<NavbarVisibilityProvider>(
      context,
      listen: false,
    );
    navbarProvider.setNavBarVisibility(false);

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return Container(
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
            child: StatefulBuilder(
              builder: (ctx, setState) {
                return Column(
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
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        provider.selectedBudgetType == BudgetType.weekly
                            ? AppLocalizations.of(ctx)!.budgetSelectWeek
                            : provider.selectedBudgetType == BudgetType.monthly
                            ? AppLocalizations.of(ctx)!.budgetSelectDate
                            : AppLocalizations.of(ctx)!.budgetSelectDay,
                        style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTextColorLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TableCalendar(
                      firstDay: DateTime(2020, 1, 1),
                      lastDay: DateTime(2100, 12, 31),
                      focusedDay: focusedDay,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      calendarFormat: calendarFormat,
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Month',
                        CalendarFormat.week: 'Week',
                      },
                      headerStyle: HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                        titleTextStyle:
                            Theme.of(ctx).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryTextColorLight,
                            ) ??
                            const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryTextColorLight,
                            ),
                        leftChevronIcon: const Icon(
                          Icons.chevron_left,
                          color: AppColors.gradientEnd,
                        ),
                        rightChevronIcon: const Icon(
                          Icons.chevron_right,
                          color: AppColors.gradientEnd,
                        ),
                      ),
                      calendarStyle: CalendarStyle(
                        selectedDecoration: const BoxDecoration(
                          color: AppColors.gradientEnd,
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: AppColors.gradientStart.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        weekendTextStyle: const TextStyle(
                          color: AppColors.secondaryTextColorLight,
                        ),
                        defaultTextStyle: const TextStyle(
                          color: AppColors.primaryTextColorLight,
                        ),
                        outsideDaysVisible: false,
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekendStyle: TextStyle(
                          color: AppColors.secondaryTextColorLight,
                        ),
                        weekdayStyle: TextStyle(
                          color: AppColors.secondaryTextColorLight,
                        ),
                      ),
                      selectedDayPredicate: (day) => isSameDay(day, tempSelected),
                      onDaySelected: (selected, focused) {
                        setState(() {
                          tempSelected = selected;
                          focusedDay = focused;
                        });
                      },
                      onPageChanged: (focused) {
                        focusedDay = focused;
                      },
                      onFormatChanged: (format) {
                        setState(() {
                          calendarFormat = format;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text(AppLocalizations.of(ctx)!.budgetCancel),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            provider.setSelectedDate(tempSelected);
                            Navigator.of(ctx).pop();
                          },
                          child: Text(AppLocalizations.of(ctx)!.budgetApply),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
          );
        },
      );
    } finally {
      if (context.mounted) {
        navbarProvider.setNavBarVisibility(true);
      }
    }
  }



  Widget _buildCategoryList(BuildContext context, RevampedBudgetProvider provider) {
    final data = provider.revampedCategoryBudgetData
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
              AppLocalizations.of(context)!.budgetBudgets,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: AppColors.gradientEnd,
              onPressed: () async {
                final provider = Provider.of<RevampedBudgetProvider>(
                  context,
                  listen: false,
                );
                final result =
                    await PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: AddBudgetRevampedScreen(
                        initialBudgetType: provider.selectedBudgetType,
                      ),
                      withNavBar: false,
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    );
                if (result == true) {
                  Provider.of<RevampedBudgetProvider>(
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

  String _formatAmountForCard(double amount, {String? currencyCode}) {
    String currencyDisplay;
    if (currencyCode != null) {
      currencyDisplay = currencyCode;
    } else {
      currencyDisplay = Provider.of<CurrencyProvider>(
        context,
        listen: false,
      ).selectedCurrencyCode;
    }
    
    if (amount.abs() >= 1000) {
      final thousands = amount / 1000;
      if (thousands == thousands.floor()) {
        return '$currencyDisplay ${thousands.floor()}k';
      } else {
        return '$currencyDisplay ${thousands.toStringAsFixed(1)}k';
      }
    }
    return formatCurrency(amount, currencyDisplay);
  }

  Widget _buildCategoryCard(
    BuildContext context,
    RevampedCategoryBudgetData data,
    RevampedBudgetProvider provider,
  ) {
    final hasLimit = data.limit > 0;
    final spent = data.spentAmount;
    final limit = data.limit;
    final progress = hasLimit ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = hasLimit && spent > limit;
    final remaining = limit - spent;
    final transactionCount = provider.getTransactionCountForRevampedBudget(data.revampedBudget);

    return GestureDetector(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: BudgetDetailRevampedScreen(
            revampedBudget: data.revampedBudget,
            categoryNames: data.categoryNames,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _getColorFromString(data.categoryColor).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconFromString(data.categoryIcon),
                    color: _getColorFromString(data.categoryColor),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryTextColorLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${AppLocalizations.of(context)!.budgetTransactions} $transactionCount',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  onPressed: () async {
                    final controller = TextEditingController(
                      text: hasLimit ? limit.toStringAsFixed(2) : '',
                    );
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          title: Text(AppLocalizations.of(context)!.budgetSetSpendingLimit),
                          content: TextField(
                            controller: controller,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.budgetEnterLimitAmount,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: Text(AppLocalizations.of(context)!.budgetCancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: Text(AppLocalizations.of(context)!.budgetSave),
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
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!.budgetEnterValidNumber),
                          ),
                        );
                        return;
                      }

                      try {
                        await provider.updateRevampedBudgetLimit(
                          data.revampedBudget.id,
                          parsed,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.budgetLimitSaved),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          String errorMessage = e.toString();
                          if (errorMessage.startsWith('Exception: ')) {
                            errorMessage = errorMessage.substring('Exception: '.length);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(errorMessage)),
                          );
                        }
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        text: _formatAmountForCard(spent, currencyCode: data.revampedBudget.currency),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getColorFromString(data.categoryColor),
                        ),
                        children: [
                          if (hasLimit)
                            TextSpan(
                              text: ' / ${_formatAmountForCard(limit, currencyCode: data.revampedBudget.currency)}',
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
              ],
            ),
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
                        ? AppLocalizations.of(context)!.budgetOverBudget(_formatAmountForCard(spent - limit, currencyCode: data.revampedBudget.currency))
                        : AppLocalizations.of(context)!.budgetRemaining(_formatAmountForCard(remaining, currencyCode: data.revampedBudget.currency)),
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



  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red': return Colors.red;
      case 'orange': return Colors.orange;
      case 'yellow': return Colors.yellow.shade700;
      case 'green': return Colors.green;
      case 'blue': return Colors.blue;
      case 'purple': return Colors.purple;
      case 'pink': return Colors.pink;
      case 'teal': return Colors.teal;
      case 'brown': return Colors.brown;
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

