import 'dart:async';
import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/constants/transaction_type_enum.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/models/firestore_transaction.dart';
import 'package:budgetm/models/firestore_account.dart';
import 'package:budgetm/models/category.dart';
import 'package:budgetm/widgets/pretty_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:budgetm/viewmodels/home_screen_provider.dart';
import 'package:budgetm/viewmodels/vacation_mode_provider.dart';
import 'package:budgetm/viewmodels/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:budgetm/utils/icon_utils.dart';
import 'package:budgetm/utils/account_icon_utils.dart';
import 'package:budgetm/utils/appTheme.dart';
import 'package:intl/intl.dart';
import 'package:budgetm/viewmodels/goals_provider.dart';
import 'package:budgetm/viewmodels/subscription_provider.dart';
import 'package:budgetm/models/goal.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:budgetm/screens/paywall/paywall_screen.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionType transactionType;
  final DateTime? selectedDate;
  final FirestoreTransaction? transaction; // Optional transaction for editing

  const AddTransactionScreen({super.key, required this.transactionType, this.selectedDate, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isMoreOptionsVisible = false;
  bool _isSaving = false;
  late FirestoreService _firestoreService;
  List<FirestoreAccount> _accounts = [];
  List<Category> _categories = [];
  String? _selectedAccountId;
  String? _selectedCategoryId;
  String? _selectedGoalId;
  bool _hasAutoOpenedCategorySheet = false;
  Color _selectedColor = Colors.grey.shade300;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService.instance;
    
    // If editing a transaction, set the selected color and date from the transaction
    if (widget.transaction != null) {
      _selectedColor = hexToColor(widget.transaction!.icon_color);
      _selectedDate = widget.transaction!.date;
    } else if (widget.selectedDate != null) {
      // Check if the selected date is in the same month and year as the current date
      final now = DateTime.now();
      final selectedDate = widget.selectedDate!;
      
      if (selectedDate.year == now.year && selectedDate.month == now.month) {
        // If it's the current month, use today's date instead of the 1st of the month
        _selectedDate = now;
      } else {
        // For past or future months, use the selected date as is
        _selectedDate = selectedDate;
      }
    } else {
      _selectedDate = DateTime.now();
    }
    
    
    _loadAccounts();
    _loadCategories();
  }

  Future<void> _loadAccounts() async {
    try {
      // Get all accounts
      final allAccounts = await _firestoreService.getAllAccounts();
      // Filter out vacation accounts (show only normal accounts)
      final normalModeAccounts = allAccounts
          .where((account) => account.isVacationAccount != true)
          .toList();
      
      // Filter accounts by currency
      final currencyProvider = Provider.of<CurrencyProvider>(context, listen: false);
      final selectedCurrencyCode = currencyProvider.selectedCurrencyCode;
      
      final filteredAccounts = <FirestoreAccount>[];
      for (final account in normalModeAccounts) {
        // Always include default cash account regardless of currency
        if (account.isDefault == true) {
          filteredAccounts.add(account);
        }
        // Include other accounts only if they match the selected currency
        else if (account.currency == selectedCurrencyCode) {
          filteredAccounts.add(account);
        }
      }
      
      setState(() {
        // Always show accounts if any exist (including filtered accounts)
        if (filteredAccounts.isNotEmpty) {
          _accounts = filteredAccounts;
          // Auto-select the first available account
          _selectedAccountId = filteredAccounts.first.id;
        } else {
          // No accounts match the current currency filter
          _accounts = [];
          _selectedAccountId = null;
        }
      });

      if (_selectedAccountId != null) {
        _formKey.currentState?.patchValue({'account': _selectedAccountId});
      }
    } catch (e) {
      // Handle error
      debugPrint('Error loading accounts: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      // Get categories filtered by transaction type and ordered by displayOrder
      final allCategories = await _firestoreService.getAllCategories();
      final filteredCategories = allCategories
          .where(
            (category) =>
                category.type ==
                (widget.transactionType == TransactionType.income
                    ? 'income'
                    : 'expense'),
          )
          .toList();

      // Sort by display order
      filteredCategories.sort(
        (a, b) => a.displayOrder.compareTo(b.displayOrder),
      );

      setState(() {
        _categories = filteredCategories;

        // Set default category
        if (_categories.isNotEmpty) {
          // Try to find "Misc" category first
          final miscCategory = _categories.firstWhere(
            (category) => category.name?.toLowerCase() == 'misc',
            orElse: () => _categories.first,
          );
          _selectedCategoryId = miscCategory.id;
          _formKey.currentState?.patchValue({'category': miscCategory.id});
        }
      });

      // Open category bottom sheet automatically once after categories are loaded.
      if (!_hasAutoOpenedCategorySheet && _categories.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;
          final selectedCategory = _categories.firstWhere(
            (cat) => cat.id == _selectedCategoryId,
            orElse: () => _categories.first,
          );

          final result = await _showPrettySelectionBottomSheet<Category>(
            title: 'Select Category',
            items: _categories,
            selectedItem: selectedCategory,
            getDisplayName: (category) => category.name ?? 'Unnamed Category',
            getLeading: (category) => HugeIcon(
              icon: getIcon(category.icon),
              color: AppColors.primaryTextColorLight,
            ),
          );

          if (result != null) {
            setState(() {
              _selectedCategoryId = result.id;
            });
            _formKey.currentState?.patchValue({'category': result.id});
          }
          _hasAutoOpenedCategorySheet = true;
        });
      }
    } catch (e) {
      // Handle error
      debugPrint('Error loading categories: $e');
    }
  }

  void _showColorPicker() {
    // Check subscription status before showing color picker
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);
    
    if (!subscriptionProvider.canUseColorPicker()) {
      // Show paywall if user is not subscribed
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const PaywallScreen(),
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: _selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  _selectedColor = color;
                });
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Shows a pretty selection bottom sheet for choosing an item of type [T].
  ///
  /// Parameters:
  /// - [title]: The title displayed at the top of the bottom sheet.
  /// - [items]: The list of items to choose from.
  /// - [selectedItem]: The currently selected item to highlight.
  /// - [getDisplayName]: A function that returns the display name for each item.
  /// - [getLeading]: Optional builder to provide a leading widget for each item
  ///   in the list (e.g., an icon). If provided, it is passed through to
  ///   PrettyBottomSheet so each list tile can render a leading widget.
  Future<T?> _showPrettySelectionBottomSheet<T>({
    required String title,
    required List<T> items,
    required T selectedItem,
    required String Function(T) getDisplayName,
    Widget Function(T)? getLeading,
  }) async {
    return await showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
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
  }

  Future<void> _showPrettyCalendarPicker(BuildContext context) async {
    // Initialize with the selected date or current date
    DateTime initialDate = _selectedDate ?? DateTime.now();
    
    // Local, mutable state for the bottom sheet
    DateTime tempSelected = initialDate;
    DateTime focusedDay = initialDate;

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
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.only(top: 6, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    // Title
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Select Date',
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
                      calendarFormat: CalendarFormat.month,
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Month',
                      },
                      headerStyle: HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                        titleTextStyle: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryTextColorLight,
                            ) ??
                            const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryTextColorLight,
                            ),
                        leftChevronIcon:
                            const Icon(Icons.chevron_left, color: AppColors.gradientEnd),
                        rightChevronIcon:
                            const Icon(Icons.chevron_right, color: AppColors.gradientEnd),
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
                        weekendTextStyle:
                            const TextStyle(color: AppColors.secondaryTextColorLight),
                        defaultTextStyle:
                            const TextStyle(color: AppColors.primaryTextColorLight),
                        outsideDaysVisible: false,
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekendStyle: TextStyle(color: AppColors.secondaryTextColorLight),
                        weekdayStyle: TextStyle(color: AppColors.secondaryTextColorLight),
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
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Cancel'),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedDate = tempSelected;
                            });
                            // Update the form field value
                            _formKey.currentState?.patchValue({'date': tempSelected});
                            Navigator.of(ctx).pop();
                          },
                          child: const Text('Apply'),
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
    } catch (e) {
      debugPrint('Error showing calendar picker: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFFAFAFA), // Slight grey background
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
                  // autovalidateMode: AutovalidateMode.always,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Center(
                            child: Text(
                              'Amount',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
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
                            decoration: _inputDecoration(hintText: '0.00')
                                .copyWith(
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
                                errorText: 'Amount is required',
                              ),
                              FormBuilderValidators.numeric(
                                errorText: 'Please enter a valid number',
                              ),
                            ]),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Category and Currency fields side by side
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildFormSection(
                              context,
                              'Category',
                              FormBuilderField<String>(
                                name: 'category',
                                initialValue: _selectedCategoryId,
                                validator: FormBuilderValidators.required(
                                  errorText: 'Please select a category',
                                ),
                                builder: (FormFieldState<String?> field) {
                                  Category? selectedCategory;
                                  if (_categories.isNotEmpty) {
                                    selectedCategory = _categories.firstWhere(
                                      (cat) => cat.id == _selectedCategoryId,
                                      orElse: () => _categories.first,
                                    );
                                  }

                                  return GestureDetector(
                                    onTap: () async {
                                      if (_categories.isEmpty) {
                                        return;
                                      }
                                      final result =
                                          await _showPrettySelectionBottomSheet<
                                            Category
                                          >(
                                            title: 'Select Category',
                                            items: _categories,
                                            selectedItem:
                                                selectedCategory ??
                                                _categories.first,
                                            getDisplayName: (category) =>
                                                category.name ??
                                                'Unnamed Category',
                                            getLeading: (category) => HugeIcon(
                                              icon: getIcon(category.icon),
                                              color: AppColors
                                                  .primaryTextColorLight,
                                            ),
                                          );

                                      if (result != null) {
                                        setState(() {
                                          _selectedCategoryId = result.id;
                                        });
                                        field.didChange(result.id);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10.0,
                                        horizontal: 16.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          30.0,
                                        ),
                                        border: Border.all(
                                          color: field.hasError
                                              ? AppColors.errorColor
                                              : Colors.grey.shade300,
                                          width: field.hasError ? 1.5 : 1.0,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                HugeIcon(
                                                  icon: getIcon(
                                                    selectedCategory?.icon,
                                                  ),
                                                  size: 18,
                                                  color:
                                                      selectedCategory != null
                                                      ? AppColors
                                                            .primaryTextColorLight
                                                      : AppColors
                                                            .lightGreyBackground,
                                                ),
                                                const SizedBox(width: 8),
                                                Flexible(
                                                  child: Text(
                                                    selectedCategory?.name ??
                                                        'Select',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color:
                                                          selectedCategory !=
                                                              null
                                                          ? AppColors
                                                                .primaryTextColorLight
                                                          : AppColors
                                                                .lightGreyBackground,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.grey.shade600,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildFormSection(
                              context,
                              'Currency',
                              FormBuilderField<String>(
                                name: Provider.of<VacationProvider>(context, listen: false).isVacationMode ? 'vacationCurrency' : 'transactionCurrency',
                                initialValue: Provider.of<CurrencyProvider>(context, listen: false).selectedCurrencyCode,
                                validator: FormBuilderValidators.required(
                                  errorText: 'Please select a currency',
                                ),
                                builder: (FormFieldState<String?> field) {
                                  return Consumer<CurrencyProvider>(
                                    builder: (context, currencyProvider, child) {
                                      return GestureDetector(
                                        onTap: () {
                                          showCurrencyPicker(
                                            context: context,
                                            showFlag: true,
                                            showSearchField: true,
                                            onSelect: (Currency currency) async {
                                              // Update the currency provider
                                              final currencyProvider = Provider.of<CurrencyProvider>(context, listen: false);
                                              await currencyProvider.setCurrency(currency, 1.0);
                                              // Reload accounts when currency changes (both normal and vacation mode)
                                              _loadAccounts();
                                              // Reset selected goal when currency changes
                                              setState(() {
                                                _selectedGoalId = null;
                                              });
                                              field.didChange(currency.code);
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
                                              color: field.hasError
                                                  ? AppColors.errorColor
                                                  : Colors.grey.shade300,
                                              width: field.hasError ? 1.5 : 1.0,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                field.value ?? currencyProvider.selectedCurrencyCode,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: AppColors.primaryTextColorLight,
                                                ),
                                              ),
                                              Icon(
                                                Icons.arrow_drop_down,
                                                color: Colors.grey.shade600,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Account field (full width) - shown in both modes
                      if (_accounts.isNotEmpty)
                        _buildFormSection(
                          context,
                          'Account',
                          FormBuilderField<String>(
                            name: 'account',
                            initialValue: _selectedAccountId,
                            validator: FormBuilderValidators.required(
                              errorText: 'Please select an account',
                            ),
                          builder: (FormFieldState<String?> field) {
                            final selectedAccount = _accounts
                                .firstWhere(
                                  (acc) =>
                                      acc.id ==
                                      _selectedAccountId,
                                  orElse: () => _accounts.first,
                                );

                            return GestureDetector(
                              onTap: () async {
                                final result =
                                    await _showPrettySelectionBottomSheet<
                                      FirestoreAccount
                                    >(
                                      title: 'Select Account',
                                      items: _accounts,
                                      selectedItem: selectedAccount,
                                      getDisplayName: (account) =>
                                          account.name,
                                      getLeading: (account) => HugeIcon(
                                        icon: getAccountIcon(account.accountType)[0][0],
                                        color: AppColors.primaryTextColorLight,
                                        size: 20,
                                      ),
                                    );

                                if (result != null) {
                                  setState(() {
                                    _selectedAccountId = result.id;
                                  });
                                  field.didChange(result.id);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 16.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    30.0,
                                  ),
                                  border: Border.all(
                                    color: field.hasError
                                        ? AppColors.errorColor
                                        : Colors.grey.shade300,
                                    width: field.hasError ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          HugeIcon(
                                            icon: getAccountIcon(selectedAccount.accountType)[0][0],
                                            size: 18,
                                            color: _selectedAccountId != null
                                                ? AppColors.primaryTextColorLight
                                                : AppColors.lightGreyBackground,
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              _selectedAccountId != null
                                                  ? selectedAccount.name
                                                  : 'Select',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color:
                                                    _selectedAccountId != null
                                                    ? AppColors.primaryTextColorLight
                                                    : AppColors.lightGreyBackground,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.grey.shade600,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          ),
                        ),
                      // Show helpful message when no accounts are available for selected currency
                      if (_accounts.isEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.orange.shade600,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'No accounts available for the selected currency. Please create an account with this currency or select a different currency.',
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        StreamBuilder<List<FirestoreGoal>>(
                          stream: Provider.of<GoalsProvider>(
                            context,
                            listen: false,
                          ).getGoals(),
                          builder: (context, snapshot) {
                            final allPendingGoals = (snapshot.data ?? [])
                                .where((g) => !g.isCompleted)
                                .toList();
                            
                            // Get the selected transaction currency
                            final formData = _formKey.currentState?.value ?? {};
                            final transactionCurrency = formData['transactionCurrency'] as String? ?? 
                                Provider.of<CurrencyProvider>(context, listen: false).selectedCurrencyCode;
                            
                            // Filter goals to only show those matching the transaction currency
                            final pendingGoals = allPendingGoals
                                .where((g) => g.currency == transactionCurrency)
                                .toList();
                            
                            if (pendingGoals.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            
                            // Determine currently selected goal object if any
                            final FirestoreGoal? selectedGoal =
                                _selectedGoalId != null
                                ? pendingGoals.firstWhere(
                                    (g) => g.id == _selectedGoalId,
                                    orElse: () => pendingGoals.first,
                                  )
                                : null;

                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: _buildFormSection(
                                context,
                                'Goal',
                                FormBuilderField<String>(
                                  name: 'goal',
                                  initialValue: _selectedGoalId,
                                  builder: (FormFieldState<String?> field) {
                                    return GestureDetector(
                                      onTap: () async {
                                        // Build items with a "None" option at the top
                                        final List<FirestoreGoal?> items = [
                                          null,
                                          ...pendingGoals,
                                        ];
                                        final result =
                                            await _showPrettySelectionBottomSheet<
                                              FirestoreGoal?
                                            >(
                                              title: 'Select Goal',
                                              items: items,
                                              selectedItem: selectedGoal,
                                              getDisplayName: (g) =>
                                                  g == null ? 'None' : g.name,
                                            );
                                        // Update selection and form field
                                        setState(() {
                                          _selectedGoalId = result?.id;
                                        });
                                        field.didChange(_selectedGoalId);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10.0,
                                          horizontal: 16.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            30.0,
                                          ),
                                          border: Border.all(
                                            color: field.hasError
                                                ? AppColors.errorColor
                                                : Colors.grey.shade300,
                                            width: field.hasError ? 1.5 : 1.0,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _selectedGoalId != null
                                                    ? (pendingGoals
                                                          .firstWhere(
                                                            (g) =>
                                                                g.id ==
                                                                _selectedGoalId,
                                                            orElse: () =>
                                                                pendingGoals
                                                                    .first,
                                                          )
                                                          .name)
                                                    : 'None',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: _selectedGoalId != null
                                                      ? AppColors
                                                            .primaryTextColorLight
                                                      : AppColors
                                                            .lightGreyBackground,
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
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 10),
                      _buildMoreOptionsToggle(),
                      // const SizedBox(height: 10),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Visibility(
                          visible: _isMoreOptionsVisible,
                          child: _buildMoreOptions(),
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

  Widget _buildMoreOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Notes field moved to the top
        _buildFormSection(
          context,
          'Notes',
          FormBuilderTextField(
            name: 'notes',
            style: const TextStyle(fontSize: 13),
            decoration: _inputDecoration(hintText: 'Notes'),
            maxLines: 2,
          ),
        ),
        const SizedBox(height: 12),
        // Expense-only fields (paid) are intentionally disabled here.
        // Date and Time should be available for both income and expense inside "More"
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _buildFormSection(
                context,
                'Date',
                FormBuilderField<DateTime>(
                  name: 'date',
                  initialValue: _selectedDate,
                  validator: FormBuilderValidators.required(
                    errorText: 'Please select a date',
                  ),
                  builder: (FormFieldState<DateTime?> field) {
                    return GestureDetector(
                      onTap: () => _showPrettyCalendarPicker(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 16.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.0),
                          border: Border.all(
                            color: field.hasError
                                ? AppColors.errorColor
                                : Colors.grey.shade300,
                            width: field.hasError ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                field.value != null
                                    ? DateFormat('dd/MM/yyyy').format(field.value!)
                                    : 'Select Date',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: field.value != null
                                      ? AppColors.primaryTextColorLight
                                      : AppColors.lightGreyBackground,
                                ),
                              ),
                            ),
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedCalendar01,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: _buildFormSection(
                context,
                'Time',
                FormBuilderDateTimePicker(
                  name: 'time',
                  initialValue: DateTime.now(),
                  inputType: InputType.time,
                  format: DateFormat('h:mm a'),
                  style: const TextStyle(fontSize: 13),
                  decoration: _inputDecoration(
                    suffixIcon: HugeIcons.strokeRoundedClock01,
                  ),
                ),
              ),
            ),
          ],
        ),
        // const SizedBox(height: 8),
        // _buildFormSection(
        //   context,
        //   'Repeat',
        //   FormBuilderDropdown(
        //     name: 'repeat',
        //     initialValue: "Don't Repeat",
        //     decoration: _inputDecoration(),
        //     items: ["Don't Repeat", 'Daily', 'Weekly', 'Monthly', 'Yearly']
        //         .map(
        //           (repeat) => DropdownMenuItem(
        //             value: repeat,
        //             child: Text(repeat, style: const TextStyle(fontSize: 13)),
        //           ),
        //         )
        //         .toList(),
        //   ),
        // ),
        if (widget.transactionType == TransactionType.income) ...[
          const SizedBox(height: 8),
          _buildFormSection(
            context,
            'Paid',
            FormBuilderSwitch(
              name: 'paid',
              title: const Text('Paid', style: TextStyle(fontSize: 13)),
              initialValue: true,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
        if (widget.transactionType == TransactionType.expense) ...[
          const SizedBox(height: 8),
          _buildFormSection(
            context,
            'Paid',
            FormBuilderSwitch(
              name: 'paid',
              title: const Text('Paid', style: TextStyle(fontSize: 13)),
              initialValue: true,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          // const SizedBox(height: 8),
          // _buildFormSection(
          //   context,
          //   'Remind',
          //   FormBuilderDropdown(
          //     name: 'remind',
          //     initialValue: "Don't Remind",
          //     decoration: _inputDecoration(),
          //     items:
          //         [
          //               "Don't Remind",
          //               '1 day before',
          //               '2 days before',
          //               '1 week before',
          //             ]
          //             .map(
          //               (remind) => DropdownMenuItem(
          //                 value: remind,
          //                 child: Text(
          //                   remind,
          //                   style: const TextStyle(fontSize: 13),
          //                 ),
          //               ),
          //             )
          //             .toList(),
          //   ),
          // ),
        ],
        const SizedBox(height: 8),
        _buildFormSection(
          context,
          'Color',
          GestureDetector(
            onTap: _showColorPicker,
            child: FormBuilderField(
              name: 'color',
              builder: (FormFieldState<dynamic> field) {
                return InputDecorator(
                  decoration: _inputDecoration(hintText: 'Select Color'),
                  child: SizedBox(
                    height: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Color',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.lightGreyBackground,
                          ),
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _selectedColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoreOptionsToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Expanded(child: Divider(color: Colors.grey)),
        TextButton(
          onPressed: () {
            setState(() {
              _isMoreOptionsVisible = !_isMoreOptionsVisible;
            });
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'More',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14, // Larger text
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                _isMoreOptionsVisible
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ],
          ),
        ),
        const Expanded(child: Divider(color: Colors.grey)),
      ],
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    final isVacationMode = Provider.of<VacationProvider>(context, listen: false).isVacationMode;
    
    return Container(
      padding: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: isVacationMode
            ? null
            : const LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isVacationMode ? AppColors.aiGradientStart : null,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isVacationMode
                          ? [AppColors.aiGradientStart, const Color.fromARGB(255, 154, 185, 235)]
                          : [AppColors.gradientStart, AppColors.gradientEnd],
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
                widget.transaction != null
                    ? (widget.transactionType == TransactionType.income
                        ? 'Edit income'
                        : 'Edit expense')
                    : (widget.transactionType == TransactionType.income
                        ? 'Plan an income'
                        : 'Plan an expense'),
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

  InputDecoration _inputDecoration({
    String? hintText,
    List<List<dynamic>>? suffixIcon,
  }) {
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
      suffixIcon: suffixIcon != null
          ? Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: HugeIcon(
                icon: suffixIcon,
                size: 18,
                color: Colors.grey.shade600,
              ),
            )
          : null,
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    final isVacationMode = Provider.of<VacationProvider>(context, listen: false).isVacationMode;
    
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
                'Cancel',
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
              onPressed: _isSaving
                  ? null
                  : () {
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        _saveTransaction();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isVacationMode ? AppColors.vacationColor : AppColors.gradientEnd,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      widget.transaction != null ? 'Update' : 'Create',
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

  Future<void> _saveTransaction() async {
    try {
      if (mounted) {
        setState(() {
          _isSaving = true;
        });
      } else {
        _isSaving = true;
      }

      final formData = _formKey.currentState!.value;

      // Get the selected currency code from CurrencyProvider
      final currencyProvider = Provider.of<CurrencyProvider>(context, listen: false);
      final selectedCurrencyCode = currencyProvider.selectedCurrencyCode;

      // Check if we're in vacation mode
      final vacationProvider = Provider.of<VacationProvider>(context, listen: false);
      final isVacationMode = vacationProvider.isVacationMode;

      // Calculate the transaction date with time
      // Provide default values if date/time fields are not in form data (when "more" options aren't expanded)
      final date = formData['date'] as DateTime? ?? _selectedDate ?? DateTime.now();
      final time = formData['time'] as DateTime?;
      final transactionDate = time != null
          ? DateTime(date.year, date.month, date.day, time.hour, time.minute)
          : date;

      // Parse amount
      final amount = double.parse(formData['amount'] as String);

      // Selected goal (optional, only for income)
      final String? selectedGoalId = formData['goal'] as String?;

      // Handle vacation mode transactions
      if (isVacationMode) {
        // Validate required fields for vacation transaction
        if (_selectedAccountId == null) {
          throw Exception('No account selected');
        }

        // Get the selected normal account
        final selectedAccount = await _firestoreService.getAccountById(_selectedAccountId!);
        if (selectedAccount == null) {
          throw Exception('Selected account not found');
        }

        // Validate currency matching (default cash account accepts any currency)
        if (selectedAccount.isDefault != true && selectedAccount.currency != selectedCurrencyCode) {
          if (mounted) {
            setState(() {
              _isSaving = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Currency mismatch: The selected account\'s currency (${selectedAccount.currency}) does not match the transaction currency ($selectedCurrencyCode).',
                ),
              ),
            );
          } else {
            _isSaving = false;
          }
          return;
        }

        // Check credit limit on normal account (not vacation account which has unlimited credit)
        if (selectedAccount.creditLimit != null && widget.transactionType == TransactionType.expense) {
          final newBalance = selectedAccount.balance - amount;
          if (newBalance.abs() > selectedAccount.creditLimit!) {
            if (mounted) {
              setState(() {
                _isSaving = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'This transaction exceeds the credit limit for the selected account.',
                  ),
                ),
              );
            } else {
              _isSaving = false;
            }
            return;
          }
        }

        // Get active vacation account ID
        final activeVacationAccountId = vacationProvider.activeVacationAccountId;
        if (activeVacationAccountId == null) {
          throw Exception('No active vacation account found');
        }

        // Create the linked vacation transaction
        final transaction = FirestoreTransaction(
          id: widget.transaction?.id ?? '', // Use existing ID if editing
          description: '', // Default empty description
          amount: amount,
          type: widget.transactionType == TransactionType.income
              ? 'income'
              : 'expense',
          date: transactionDate,
          currency: selectedCurrencyCode,
          categoryId: _selectedCategoryId,
          budgetId: null,
          goalId: selectedGoalId,
          accountId: _selectedAccountId, // Normal account
          time: (formData['time'] as DateTime?)?.toIso8601String(),
          repeat: formData['repeat'] as String?,
          remind: formData['remind'] as String?,
          icon: formData['icon'] as String?,
          color: formData['color'] as String?,
          icon_color: '#${_selectedColor.value.toRadixString(16).padLeft(8, '0').substring(2)}',
          notes: formData['notes'] as String?,
          paid: (formData['paid'] as bool? ?? true),
          isVacation: true, // Mark as vacation transaction for display purposes
          linkedVacationAccountId: activeVacationAccountId, // Link to vacation account
        );

        // Create the linked vacation transaction
        print('DEBUG: AddTransactionScreen - creating linked vacation transaction: type=${widget.transactionType}, categoryId=$_selectedCategoryId, currency=$selectedCurrencyCode, amount=$amount');
        print('DEBUG: AddTransactionScreen - transaction object: isVacation=${transaction.isVacation}, linkedVacationAccountId=${transaction.linkedVacationAccountId}, accountId=${transaction.accountId}');
        if (widget.transaction != null) {
          // Update existing transaction
          print('DEBUG: AddTransactionScreen - updating existing transaction');
          await _firestoreService.updateTransactionObject(
            widget.transaction!.id,
            transaction,
          );
        } else {
          // Create new linked vacation transaction
          print('DEBUG: AddTransactionScreen - creating new linked vacation transaction');
          await _firestoreService.createLinkedVacationTransaction(transaction);
        }

        if (mounted) {
          final homeProvider = Provider.of<HomeScreenProvider>(
            context,
            listen: false,
          );
          // Trigger the new robust refresh mechanism for both modes
          homeProvider.requestRefreshForBothModes(transactionDate: transactionDate);
          Navigator.of(context).pop(true); // Pass true to indicate success
        }
        return;
      }

      // Get the selected account - need to fetch all accounts if _accounts is empty (default account case)
      FirestoreAccount selectedAccount;
      if (_accounts.isNotEmpty) {
        selectedAccount = _accounts.firstWhere(
          (account) => account.id == _selectedAccountId,
        );
      } else {
        // Fetch the account from Firestore if not in the list (default account case)
        if (_selectedAccountId == null) {
          throw Exception(
            'No account available. Please create an account first.',
          );
        }
        final fetchedAccount = await _firestoreService.getAccountById(
          _selectedAccountId!,
        );
        if (fetchedAccount == null) {
          throw Exception('Selected account not found');
        }
        selectedAccount = fetchedAccount;
      }

      // Enforce account transaction limit if present
      if (selectedAccount.transactionLimit != null) {
        final limit = selectedAccount.transactionLimit!;
        if (amount > limit) {
          // Reset saving state and show error, do not proceed
          if (mounted) {
            setState(() {
              _isSaving = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Amount exceeds account transaction limit of ${limit.toStringAsFixed(2)}',
                ),
              ),
            );
          } else {
            _isSaving = false;
          }
          return;
        }
      }

      // Check for credit limit on credit accounts
      // Skip credit limit check for vacation accounts (unlimited credit)
      if (selectedAccount.creditLimit != null &&
          widget.transactionType == TransactionType.expense &&
          selectedAccount.isVacationAccount != true) {
        final newBalance = selectedAccount.balance - amount;
        if (newBalance.abs() > selectedAccount.creditLimit!) {
          if (mounted) {
            setState(() {
              _isSaving = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'This transaction exceeds the credit limit for this account.',
                ),
              ),
            );
          } else {
            _isSaving = false;
          }
          return;
        }
      }

      print(amount);

      // Create transaction
      final transaction = FirestoreTransaction(
       id: widget.transaction?.id ?? '', // Use existing ID if editing
       description: '', // Default empty description
       amount: amount,
       type: widget.transactionType == TransactionType.income
           ? 'income'
           : 'expense',
       date: transactionDate,
       currency: formData['transactionCurrency'] as String? ?? selectedCurrencyCode, // Use selected currency
       categoryId: _selectedCategoryId,
       budgetId: null,
       goalId: selectedGoalId,
       accountId: _selectedAccountId,
       time: (formData['time'] as DateTime?)?.toIso8601String(),
       repeat: formData['repeat'] as String?,
       remind: formData['remind'] as String?,
       icon: formData['icon'] as String?,
       color: formData['color'] as String?,
       icon_color: '#${_selectedColor.value.toRadixString(16).padLeft(8, '0').substring(2)}',
       notes: formData['notes'] as String?,
       paid: (formData['paid'] as bool? ?? true),
     );

      // Insert or update transaction
      if (widget.transaction != null) {
        // Update existing transaction
        await _firestoreService.updateTransactionObject(
          widget.transaction!.id,
          transaction,
        );
      } else {
        // Create new transaction
        await _firestoreService.createTransaction(
          transaction,
          isVacation: false, // Normal mode transactions are not vacation transactions
        );
      }

      // Update account balance
      final newBalance = widget.transactionType == TransactionType.income
          ? selectedAccount.balance + amount
          : selectedAccount.balance - amount;

      print(newBalance);

      final updatedAccount = selectedAccount.copyWith(balance: newBalance);
      await _firestoreService.updateAccount(updatedAccount.id, updatedAccount);

      // If transaction linked to a goal, notify that goal data needs refresh
      if (selectedGoalId != null) {
        print('Transaction added to goal: $selectedGoalId, amount: $amount');
        // Notify GoalsProvider to refresh the goals screen
        Provider.of<GoalsProvider>(context, listen: false).notifyGoalTransactionAdded();
      }

      if (mounted) {
        Provider.of<HomeScreenProvider>(
          context,
          listen: false,
        ).triggerRefresh(transactionDate: transactionDate);
        Navigator.of(context).pop(true); // Pass true to indicate success
      }
    } catch (e) {
      // Handle error
      debugPrint('Error saving transaction: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save transaction: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      } else {
        _isSaving = false;
      }
    }
  }
}