import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/constants/transaction_type_enum.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/models/firestore_transaction.dart';
import 'package:budgetm/models/firestore_account.dart';
import 'package:budgetm/models/category.dart';
import 'package:provider/provider.dart';
import 'package:budgetm/viewmodels/home_screen_provider.dart';
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
  late FirestoreService _firestoreService;
  List<FirestoreAccount> _accounts = [];
  List<Category> _categories = [];
  String? _selectedAccountId;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService.instance;
    _loadAccounts();
    _loadCategories();
  }

  Future<void> _loadAccounts() async {
    try {
      // Get all accounts
      final accounts = await _firestoreService.getAllAccounts();
      
      // If no accounts exist, create a default one
      if (accounts.isEmpty) {
        await _firestoreService.createDefaultAccount("Default Account", "USD");
        final updatedAccounts = await _firestoreService.getAllAccounts();
        if (updatedAccounts.isNotEmpty) {
          setState(() {
            _accounts = updatedAccounts;
            _selectedAccountId = updatedAccounts.first.id;
          });
        }
      } else {
        // Find the default account or select the first one
        final defaultAccount = accounts.firstWhere(
          (account) => account.isDefault == true,
          orElse: () => accounts.first,
        );
        
        setState(() {
          _accounts = accounts;
          _selectedAccountId = defaultAccount.id;
        });
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
        }
      });
    } catch (e) {
      // Handle error
      debugPrint('Error loading categories: $e');
    }
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
                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                              FormBuilderDropdown(
                                name: 'category',
                                decoration: _inputDecoration(
                                  hintText: 'Select',
                                ),
                                isDense: true,
                                items: _categories
                                    .map(
                                      (category) => DropdownMenuItem(
                                        value: category.id,
                                        child: Text(
                                          category.name ?? 'Unnamed Category',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                initialValue: _selectedCategoryId,
                                validator: FormBuilderValidators.required(
                                  errorText: 'Please select a category',
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategoryId = value as String?;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildFormSection(
                              context,
                              'Account',
                              FormBuilderDropdown(
                                name: 'account',
                                decoration: _inputDecoration(
                                  hintText: 'Select',
                                ),
                                isDense: true,
                                valueTransformer: (value) => value?.id,
                                items: _accounts
                                    .map(
                                      (account) => DropdownMenuItem(
                                        value: account,
                                        child: Text(
                                          account.name,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                initialValue: _accounts.isNotEmpty
                                    ? _accounts.firstWhere(
                                        (account) => account.id == _selectedAccountId,
                                        orElse: () => _accounts.first)
                                    : null,
                                validator: FormBuilderValidators.required(
                                  errorText: 'Please select an account',
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedAccountId = value?.id;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
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
        if (widget.transactionType == TransactionType.expense)
          FormBuilderSwitch(
            name: 'paid',
            title: const Text('Paid'),
            initialValue: true,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            controlAffinity: ListTileControlAffinity.trailing,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          ),
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
              onPressed: () {
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
              child: Text(
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
    try {
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
      
      // Create transaction
      final transaction = FirestoreTransaction(
        id: '', // Will be generated by Firestore
        description: '', // Default empty description
        amount: double.parse(formData['amount'] as String),
        type: widget.transactionType == TransactionType.income ? 'income' : 'expense',
        date: transactionDate,
        categoryId: _selectedCategoryId,
        accountId: _selectedAccountId,
        time: (formData['time'] as DateTime?)?.toIso8601String(),
        repeat: formData['repeat'] as String?,
        remind: formData['remind'] as String?,
        icon: formData['icon'] as String?,
        color: formData['color'] as String?,
        notes: formData['notes'] as String?,
        paid: widget.transactionType == TransactionType.expense ? formData['paid'] as bool? : null,
      );
      
      // Insert transaction
      await _firestoreService.createTransaction(transaction);
      
      // Update account balance
      final amount = double.parse(formData['amount'] as String);
      final newBalance = widget.transactionType == TransactionType.income
          ? selectedAccount.balance + amount
          : selectedAccount.balance - amount;
      
      final updatedAccount = selectedAccount.copyWith(balance: newBalance);
      await _firestoreService.updateAccount(updatedAccount.id, updatedAccount);
      
      if (mounted) {
        Provider.of<HomeScreenProvider>(context, listen: false).triggerRefresh();
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
    }
  }
}
