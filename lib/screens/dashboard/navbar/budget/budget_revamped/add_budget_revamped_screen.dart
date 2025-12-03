import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/generated/i18n/app_localizations.dart';
import 'package:budgetm/models/budget.dart';
import 'package:budgetm/viewmodels/revamped_budget_provider.dart';
import 'package:budgetm/viewmodels/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:budgetm/widgets/pretty_bottom_sheet.dart';
import 'package:budgetm/utils/icon_utils.dart';
import 'package:budgetm/models/category.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:table_calendar/table_calendar.dart';

class AddBudgetRevampedScreen extends StatefulWidget {
  final BudgetType? initialBudgetType;
  
  const AddBudgetRevampedScreen({super.key, this.initialBudgetType});

  @override
  State<AddBudgetRevampedScreen> createState() => _AddBudgetRevampedScreenState();
}

class _AddBudgetRevampedScreenState extends State<AddBudgetRevampedScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final Set<String> _selectedCategoryIds = {};
  late BudgetType _selectedType;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String _selectedCurrencyCode = 'USD';

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialBudgetType ?? BudgetType.monthly;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currencyProvider = Provider.of<CurrencyProvider>(context, listen: false);
      setState(() {
        _selectedCurrencyCode = currencyProvider.selectedCurrencyCode;
      });
    });
  }

  Future<void> _saveBudget() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      
      if (_selectedCategoryIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one category')),
        );
        return;
      }

      final limitText = formData['amount'] as String?;
      final limit = double.tryParse(limitText ?? '');
      if (limit == null || limit <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.addBudgetAmountRequired)),
        );
        return;
      }

      final name = formData['name'] as String?;
      
      // Check for duplicate budget before attempting to save
      final provider = Provider.of<RevampedBudgetProvider>(context, listen: false);
      if (provider.hasDuplicateBudget(_selectedCategoryIds.toList(), _selectedType, _selectedCurrencyCode)) {
        // Get category names for user-friendly error message
        final categoryNames = _selectedCategoryIds.map((categoryId) {
          final category = provider.expenseCategories.firstWhere(
            (c) => c.id == categoryId,
            orElse: () => Category(id: '', name: 'Unknown', icon: '', color: '', displayOrder: 999),
          );
          return category.name ?? 'Unknown';
        }).join(', ');
        
        final typeName = _selectedType == BudgetType.daily
            ? AppLocalizations.of(context)!.daily
            : _selectedType == BudgetType.weekly
                ? AppLocalizations.of(context)!.weekly
                : AppLocalizations.of(context)!.monthly;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('A $typeName budget for $categoryNames already exists'),
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        await Provider.of<RevampedBudgetProvider>(context, listen: false)
            .addRevampedBudget(
              _selectedCategoryIds.toList(),
              limit,
              _selectedType,
              _selectedDate,
              _selectedCurrencyCode,
              name: name,
            );
        
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.addBudgetCreated)),
          );
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = e.toString();
          if (errorMessage.startsWith('Exception: ')) {
            errorMessage = errorMessage.substring('Exception: '.length);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<T?> _openBottomSheet<T>({
    required String title,
    required List<T> items,
    required T selectedItem,
    required String Function(T) getDisplayName,
    Widget Function(T)? getLeading,
  }) async {
    final result = await showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return PrettyBottomSheet<T>(
          title: title,
          items: items,
          selectedItem: selectedItem,
          getDisplayName: getDisplayName,
          getLeading: getLeading,
        );
      },
    );

    return result;
  }
  
  Future<void> _showCategorySelection() async {
    final provider = Provider.of<RevampedBudgetProvider>(context, listen: false);
    if (provider.expenseCategories.isEmpty) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
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
                      'Select Categories',
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: provider.expenseCategories.length,
                      itemBuilder: (context, index) {
                        final category = provider.expenseCategories[index];
                        final isSelected = _selectedCategoryIds.contains(category.id);
                        
                        return CheckboxListTile(
                          title: Text(category.name ?? 'Unknown'),
                          subtitle: Text(category.id),
                          secondary: HugeIcon(
                            icon: getIcon(category.icon),
                            color: AppColors.secondaryTextColorLight,
                            size: 24,
                          ),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setModalState(() {
                              if (value == true) {
                                _selectedCategoryIds.add(category.id);
                              } else {
                                _selectedCategoryIds.remove(category.id);
                              }
                            });
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Done'),
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

  Future<void> _showDatePicker() async {
    final result = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        DateTime tempSelected = _selectedDate;
        DateTime focusedDay = _selectedDate;
        CalendarFormat calendarFormat = _selectedType == BudgetType.weekly
            ? CalendarFormat.week
            : CalendarFormat.month;

        return StatefulBuilder(
          builder: (ctx, setModalState) {
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
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Select Date',
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TableCalendar(
                    firstDay: DateTime(2020, 1, 1),
                    lastDay: DateTime(2100, 12, 31),
                    focusedDay: focusedDay,
                    selectedDayPredicate: (day) => isSameDay(day, tempSelected),
                    onDaySelected: (selected, focused) {
                      setModalState(() {
                        tempSelected = selected;
                        focusedDay = focused;
                      });
                    },
                    calendarFormat: calendarFormat,
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Month',
                      CalendarFormat.week: 'Week',
                    },
                    headerStyle: const HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(tempSelected),
                        child: const Text('Select'),
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

    if (result != null) {
      setState(() {
        _selectedDate = result;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFFAFAFA),
        body: Column(
          children: [
            _buildCustomAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18.0,
                  vertical: 16.0,
                ),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Budget Name Section
                      Column(
                        children: [
                          Center(
                            child: Text(
                              'Budget Name',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.secondaryTextColorLight,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          FormBuilderTextField(
                            name: 'name',
                            style: const TextStyle(
                              color: AppColors.primaryTextColorLight,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            decoration: _inputDecoration(hintText: 'e.g., Monthly Groceries').copyWith(
                              hintStyle: const TextStyle(
                                fontSize: 18,
                                color: AppColors.lightGreyBackground,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                            validator: FormBuilderValidators.required(
                              errorText: 'Budget name is required',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Amount Section
                      Column(
                        children: [
                          Center(
                            child: Text(
                              AppLocalizations.of(context)!.addBudgetLimitAmount,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.secondaryTextColorLight,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          FormBuilderTextField(
                            name: 'amount',
                            style: const TextStyle(
                              color: AppColors.primaryTextColorLight,
                              fontSize: 26,
                            ),
                            textAlign: TextAlign.center,
                            decoration: _inputDecoration(hintText: '0.00').copyWith(
                              hintStyle: const TextStyle(
                                fontSize: 26,
                                color: AppColors.lightGreyBackground,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                errorText: AppLocalizations.of(context)!.amountRequired,
                              ),
                              FormBuilderValidators.numeric(
                                errorText: AppLocalizations.of(context)!.pleaseEnterValidNumber,
                              ),
                            ]),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      
                      // Categories Section
                      _buildFormSection(
                        context,
                        'Select Categories',
                        Consumer<RevampedBudgetProvider>(
                          builder: (context, provider, child) {
                            return GestureDetector(
                              onTap: () => _showCategorySelection(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 16.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30.0),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1.0,
                                  ),
                                ),
                                child: _selectedCategoryIds.isEmpty
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Select categories',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: AppColors.lightGreyBackground,
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.grey.shade600,
                                          ),
                                        ],
                                      )
                                    : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: _selectedCategoryIds.map((categoryId) {
                                              final category = provider.expenseCategories.firstWhere(
                                                (c) => c.id == categoryId,
                                                orElse: () => Category(id: '', name: 'Unknown', icon: '', color: '', displayOrder: 999),
                                              );
                                              return Chip(
                                                label: Text(category.name ?? 'Unknown'),
                                                onDeleted: () {
                                                  setState(() {
                                                    _selectedCategoryIds.remove(categoryId);
                                                  });
                                                },
                                                deleteIcon: const Icon(Icons.close, size: 18),
                                              );
                                            }).toList(),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Icon(
                                                Icons.arrow_drop_down,
                                                color: Colors.grey.shade600,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Budget Type and Date Section
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildFormSection(
                              context,
                              AppLocalizations.of(context)!.addBudgetBudgetType,
                              GestureDetector(
                                onTap: () async {
                                  final budgetTypes = [
                                    BudgetType.daily,
                                    BudgetType.weekly,
                                    BudgetType.monthly,
                                  ];
                                  
                                  final selected = await _openBottomSheet<BudgetType>(
                                    title: AppLocalizations.of(context)!.titleSelectBudgetType,
                                    items: budgetTypes,
                                    selectedItem: _selectedType,
                                    getDisplayName: (type) {
                                      switch (type) {
                                        case BudgetType.daily:
                                          return AppLocalizations.of(context)!.daily;
                                        case BudgetType.weekly:
                                          return AppLocalizations.of(context)!.weekly;
                                        case BudgetType.monthly:
                                          return AppLocalizations.of(context)!.monthly;
                                      }
                                    },
                                  );
                                  if (selected != null) {
                                    setState(() {
                                      _selectedType = selected;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 16.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30.0),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _selectedType == BudgetType.daily
                                              ? AppLocalizations.of(context)!.daily
                                              : _selectedType == BudgetType.weekly
                                                  ? AppLocalizations.of(context)!.weekly
                                                  : AppLocalizations.of(context)!.monthly,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.primaryTextColorLight,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.grey.shade600,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildFormSection(
                              context,
                              'Select Date',
                              GestureDetector(
                                onTap: () => _showDatePicker(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 16.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30.0),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.primaryTextColorLight,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.calendar_today,
                                        color: Colors.grey.shade600,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      
                      // Currency Section
                      _buildFormSection(
                        context,
                        AppLocalizations.of(context)!.addBudgetCurrency,
                        GestureDetector(
                          onTap: () {
                            showCurrencyPicker(
                              context: context,
                              showFlag: true,
                              showSearchField: true,
                              onSelect: (Currency currency) {
                                setState(() {
                                  _selectedCurrencyCode = currency.code;
                                });
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 16.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30.0),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _getCurrencyFlag(_selectedCurrencyCode),
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _selectedCurrencyCode,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.primaryTextColorLight,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.grey.shade600,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6),
          child: Row(
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
              Text(
                'Add Budget',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection(BuildContext context, String title, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.secondaryTextColorLight,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        field,
      ],
    );
  }

  InputDecoration _inputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontSize: 13,
        color: AppColors.lightGreyBackground,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 16.0,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: const BorderSide(color: AppColors.errorColor, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: const BorderSide(color: AppColors.errorColor, width: 1.5),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      color: const Color(0xFFFAFAFA),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                side: const BorderSide(color: Colors.black, width: 1.5),
              ),
              child: Text(
                AppLocalizations.of(context)!.addBudgetCancel,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveBudget,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gradientEnd,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      AppLocalizations.of(context)!.addBudgetSaveBudget,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _getCurrencyFlag(String currencyCode) {
    switch (currencyCode) {
      case 'USD': return '🇺🇸';
      case 'EUR': return '🇪🇺';
      case 'GBP': return '🇬🇧';
      case 'JPY': return '🇯🇵';
      case 'CAD': return '🇨🇦';
      case 'AUD': return '🇦🇺';
      case 'CHF': return '🇨🇭';
      case 'CNY': return '🇨🇳';
      case 'INR': return '🇮🇳';
      case 'BRL': return '🇧🇷';
      case 'MXN': return '🇲🇽';
      case 'KRW': return '🇰🇷';
      case 'SGD': return '🇸🇬';
      case 'HKD': return '🇭🇰';
      case 'NZD': return '🇳🇿';
      case 'SEK': return '🇸🇪';
      case 'NOK': return '🇳🇴';
      case 'DKK': return '🇩🇰';
      case 'PLN': return '🇵🇱';
      case 'CZK': return '🇨🇿';
      case 'HUF': return '🇭🇺';
      case 'RUB': return '🇷🇺';
      case 'TRY': return '🇹🇷';
      case 'ZAR': return '🇿🇦';
      case 'AED': return '🇦🇪';
      case 'SAR': return '🇸🇦';
      case 'EGP': return '🇪🇬';
      case 'ILS': return '🇮🇱';
      case 'THB': return '🇹🇭';
      case 'MYR': return '🇲🇾';
      case 'IDR': return '🇮🇩';
      case 'PHP': return '🇵🇭';
      case 'VND': return '🇻🇳';
      default: return '🌍';
    }
  }
}

