import 'dart:async';
import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/constants/transaction_type_enum.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/models/firestore_transaction.dart';
import 'package:budgetm/models/firestore_account.dart';
import 'package:budgetm/models/category.dart';
import 'package:budgetm/models/budget.dart';
import 'package:provider/provider.dart';
import 'package:budgetm/viewmodels/home_screen_provider.dart';
import 'package:budgetm/viewmodels/vacation_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionType transactionType;

  const AddTransactionScreen({super.key, required this.transactionType});

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
  List<Budget> _activeBudgets = [];
  StreamSubscription<List<Budget>>? _budgetsSubscription;
  String? _selectedAccountId;
  String? _selectedCategoryId;
  String? _selectedBudgetId;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService.instance;
    _loadAccounts();
    _loadCategories();
    // Stream budgets and keep only active ones (currentAmount < totalAmount)
    _budgetsSubscription = _firestoreService.streamBudgets().listen((budgets) {
      final active = budgets.where((b) => b.currentAmount < b.totalAmount).toList();
      if (mounted) {
        setState(() {
          _activeBudgets = active;
          // Do not auto-select a budget; leave selection to the user.
        });
      } else {
        _activeBudgets = active;
      }
    }, onError: (e) {
      debugPrint('Error streaming budgets: $e');
    });
  }

  Future<void> _loadAccounts() async {
    try {
      // Get all accounts
      final accounts = await _firestoreService.getAllAccounts();
      
      // Find the default account or select the first one
      final defaultAccount = accounts.firstWhere(
        (account) => account.isDefault == true,
        orElse: () => accounts.first,
      );
      
      setState(() {
        _accounts = accounts;
        _selectedAccountId = defaultAccount.id;
      });
      _formKey.currentState?.patchValue({'account': defaultAccount.id});
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
          .where((category) => category.type == (widget.transactionType == TransactionType.income ? 'income' : 'expense'))
          .toList();
      
      // Sort by display order
      filteredCategories.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      
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
    } catch (e) {
      // Handle error
      debugPrint('Error loading categories: $e');
    }
  }

  @override
  void dispose() {
    _budgetsSubscription?.cancel();
    super.dispose();
  }

  Future<T?> _showSelectionBottomSheet<T>({
    required String title,
    required List<T> items,
    required T? selectedItem,
    required String Function(T) getDisplayName,
  }) async {
    return await showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = item == selectedItem;
                  return ListTile(
                    title: Text(
                      getDisplayName(item),
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Theme.of(context).primaryColor : null,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).primaryColor,
                          )
                        : null,
                    onTap: () => Navigator.of(context).pop(item),
                  );
                },
              ),
            ),
          ],
        );
      },
    ) ?? items.first;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                                  return GestureDetector(
                                    onTap: () async {
                                      final selectedCategory = _categories.firstWhere(
                                        (cat) => cat.id == _selectedCategoryId,
                                        orElse: () => _categories.first,
                                      );
                                      
                                      final result = await _showSelectionBottomSheet<Category>(
                                        title: 'Select Category',
                                        items: _categories,
                                        selectedItem: selectedCategory,
                                        getDisplayName: (category) => category.name ?? 'Unnamed Category',
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
                                              _selectedCategoryId != null
                                                  ? (_categories.firstWhere(
                                                      (cat) => cat.id == _selectedCategoryId,
                                                      orElse: () => _categories.first,
                                                    ).name ?? 'Unnamed Category')
                                                  : 'Select',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: _selectedCategoryId != null
                                                    ? AppColors.primaryTextColorLight
                                                    : AppColors.lightGreyBackground,
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
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildFormSection(
                              context,
                              'Account',
                              FormBuilderField<String>(
                                name: 'account',
                                initialValue: _selectedAccountId,
                                validator: FormBuilderValidators.required(
                                  errorText: 'Please select an account',
                                ),
                                builder: (FormFieldState<String?> field) {
                                  return GestureDetector(
                                    onTap: () async {
                                      final selectedAccount = _accounts.firstWhere(
                                        (acc) => acc.id == _selectedAccountId,
                                        orElse: () => _accounts.first,
                                      );
                                      
                                      final result = await _showSelectionBottomSheet<FirestoreAccount>(
                                        title: 'Select Account',
                                        items: _accounts,
                                        selectedItem: selectedAccount,
                                        getDisplayName: (account) => account.name,
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
                                              _selectedAccountId != null
                                                  ? (_accounts.firstWhere(
                                                      (acc) => acc.id == _selectedAccountId,
                                                      orElse: () => _accounts.first,
                                                    ).name)
                                                  : 'Select',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: _selectedAccountId != null
                                                    ? AppColors.primaryTextColorLight
                                                    : AppColors.lightGreyBackground,
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
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (widget.transactionType == TransactionType.income && _activeBudgets.isNotEmpty) ...[
                        _buildFormSection(
                          context,
                          'Budget',
                          FormBuilderDropdown(
                            name: 'budget',
                            decoration: _inputDecoration(
                              hintText: 'Select',
                            ),
                            isDense: true,
                            items: _activeBudgets
                                .map(
                                  (budget) => DropdownMenuItem(
                                    value: budget.id,
                                    child: Text(
                                      budget.name ?? 'Unnamed Budget',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                )
                                .toList(),
                            initialValue: _selectedBudgetId,
                            onChanged: (value) {
                              setState(() {
                                _selectedBudgetId = value as String?;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      _buildMoreOptionsToggle(),
                      const SizedBox(height: 10),
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
                FormBuilderDateTimePicker(
                  name: 'date',
                  initialValue: DateTime.now(),
                  inputType: InputType.date,
                  format: DateFormat('dd/MM/yyyy'),
                  style: const TextStyle(fontSize: 13),
                  firstDate: DateTime.now(),
                  decoration: _inputDecoration(
                    suffixIcon: HugeIcons.strokeRoundedCalendar01,
                  ),
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
        const SizedBox(height: 8),
        _buildFormSection(
          context,
          'Repeat',
          FormBuilderDropdown(
            name: 'repeat',
            initialValue: "Don't Repeat",
            decoration: _inputDecoration(),
            items: ["Don't Repeat", 'Daily', 'Weekly', 'Monthly', 'Yearly']
                .map(
                  (repeat) => DropdownMenuItem(
                    value: repeat,
                    child: Text(repeat, style: const TextStyle(fontSize: 13)),
                  ),
                )
                .toList(),
          ),
        ),
        if (widget.transactionType == TransactionType.expense) ...[
          const SizedBox(height: 8),
          _buildFormSection(
            context,
            'Remind',
            FormBuilderDropdown(
              name: 'remind',
              initialValue: "Don't Remind",
              decoration: _inputDecoration(),
              items:
                  [
                        "Don't Remind",
                        '1 day before',
                        '2 days before',
                        '1 week before',
                      ]
                      .map(
                        (remind) => DropdownMenuItem(
                          value: remind,
                          child: Text(
                            remind,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildFormSection(
                  context,
                  'Choose an Icon',
                  FormBuilderDropdown(
                    name: 'icon',
                    decoration: _inputDecoration(hintText: 'Select Icon'),
                    items: ['Shopping', 'Food', 'Transport']
                        .map(
                          (icon) => DropdownMenuItem(
                            value: icon,
                            child: Text(
                              icon,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildFormSection(
                  context,
                  'Color',
                  FormBuilderDropdown(
                    name: 'color',
                    decoration: _inputDecoration(hintText: 'Select Color'),
                    items: ['Red', 'Green', 'Blue']
                        .map(
                          (color) => DropdownMenuItem(
                            value: color,
                            child: Text(
                              color,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
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
    return Container(
      padding: const EdgeInsets.only(bottom: 14),
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
                widget.transactionType == TransactionType.income
                    ? 'Plan an income'
                    : 'Plan an expense',
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
                backgroundColor: AppColors.gradientEnd,
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
                      'Create',
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
    // Cancel the budget stream to prevent race conditions during save
    _budgetsSubscription?.cancel();

    try {
      if (mounted) {
        setState(() {
          _isSaving = true;
        });
      } else {
        _isSaving = true;
      }

      final formData = _formKey.currentState!.value;
      
      // Get the selected account
      final selectedAccount = _accounts.firstWhere(
        (account) => account.id == _selectedAccountId,
      );
      
      // Calculate the transaction date with time
      // Provide default values if date/time fields are not in form data (when "more" options aren't expanded)
      final date = formData['date'] as DateTime? ?? DateTime.now();
      final time = formData['time'] as DateTime?;
      final transactionDate = time != null
          ? DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            )
          : date;
      
      // Parse amount
      final amount = double.parse(formData['amount'] as String);

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
      if (selectedAccount.creditLimit != null && widget.transactionType == TransactionType.expense) {
        final newBalance = selectedAccount.balance - amount;
        if (newBalance.abs() > selectedAccount.creditLimit!) {
          if (mounted) {
            setState(() {
              _isSaving = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('This transaction exceeds the credit limit for this account.'),
              ),
            );
          } else {
            _isSaving = false;
          }
          return;
        }
      }

      final selectedBudgetIdFromForm = formData['budget'] as String?;

      
      // Create transaction
      final transaction = FirestoreTransaction(
        id: '', // Will be generated by Firestore
        description: '', // Default empty description
        amount: amount,
        type: widget.transactionType == TransactionType.income ? 'income' : 'expense',
        date: transactionDate,
        categoryId: _selectedCategoryId,
        budgetId: selectedBudgetIdFromForm,
        accountId: _selectedAccountId,
        time: (formData['time'] as DateTime?)?.toIso8601String(),
        repeat: formData['repeat'] as String?,
        remind: formData['remind'] as String?,
        icon: formData['icon'] as String?,
        color: formData['color'] as String?,
        notes: formData['notes'] as String?,
        paid: widget.transactionType == TransactionType.expense ? formData['paid'] as bool? : null,
      );

      // Insert transaction with vacation flag
      final isVacation = Provider.of<VacationProvider>(context, listen: false).isVacationMode;
      await _firestoreService.createTransaction(transaction, isVacation: isVacation);
      
      // Update account balance
      final newBalance = widget.transactionType == TransactionType.income
          ? selectedAccount.balance + amount
          : selectedAccount.balance - amount;
      
      final updatedAccount = selectedAccount.copyWith(balance: newBalance);
      await _firestoreService.updateAccount(updatedAccount.id, updatedAccount);

      // If a budget is selected for an income transaction, update the budget's current amount
      if (selectedBudgetIdFromForm != null && widget.transactionType == TransactionType.income) {
        try {
          final budget = await _firestoreService.getBudgetById(selectedBudgetIdFromForm);
          if (budget != null) {
            final updatedBudget = budget.copyWith(
              currentAmount: budget.currentAmount + amount,
            );
            await _firestoreService.updateBudget(updatedBudget.id, updatedBudget);
          }
        } catch (e) {
          debugPrint('Error updating budget: $e');
          // Optionally, show a snackbar or handle the error in another way
        }
      }
      
      if (mounted) {
        Provider.of<HomeScreenProvider>(context, listen: false)
            .triggerRefresh(transactionDate: transactionDate);
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