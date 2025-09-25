import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/models/firestore_account.dart';
import 'package:budgetm/models/firestore_transaction.dart';
import 'package:budgetm/viewmodels/home_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isCreditSelected = false; // Balance is selected by default
  late FirestoreService _firestoreService;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService.instance;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.scaffoldBackground,
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
                      const SizedBox(height: 24),
                      _buildAmountField(),
                      const SizedBox(height: 16),
                      _buildFormSection(
                        context,
                        'Name',
                        FormBuilderTextField(
                          name: 'name',
                          style: const TextStyle(fontSize: 13),
                          decoration: _inputDecoration(hintText: 'Enter Name'),
                          validator: FormBuilderValidators.required(
                            errorText: 'Name is required',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCreditLimitOrBalanceField(),
                      const SizedBox(height: 16),
                      _buildFormSection(
                        context,
                        'Account Type',
                        FormBuilderDropdown<String>(
                          name: 'account_type',
                          decoration: _inputDecoration(
                            hintText: 'Select Account Type',
                          ),
                          items:
                              [
                                    'Cash',
                                    'Master Card',
                                    'Wallet',
                                    'Cryptocurrency',
                                    'Saving',
                                    'Gold',
                                    'Safe',
                                    'Bank',
                                    'Investment',
                                  ]
                                  .map(
                                    (type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    ),
                                  )
                                  .toList(),
                          validator: FormBuilderValidators.required(
                            errorText: 'Please select an account type',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Transform.scale(
                        scale: 0.9,
                        alignment: Alignment.centerLeft,
                        child: FormBuilderSwitch(
                          name: 'include_in_total',
                          title: const Text('Include in Total Balance'),
                          initialValue: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          controlAffinity: ListTileControlAffinity.trailing,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 6,
              ),
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
                          colors: [
                            AppColors.gradientStart,
                            AppColors.gradientEnd,
                          ],
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
                    'Add New Account',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildToggleChips(),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        height: 55,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(30),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: _isCreditSelected ? constraints.maxWidth / 2 - 5 : 0,
                  right: !_isCreditSelected ? constraints.maxWidth / 2 - 5 : 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.gradientEnd,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    height: 45,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildChip(
                        'Balance',
                        !_isCreditSelected,
                        () => setState(() => _isCreditSelected = false),
                      ),
                    ),
                    Expanded(
                      child: _buildChip(
                        'Credit',
                        _isCreditSelected,
                        () => setState(() => _isCreditSelected = true),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : Colors.black54,
            fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
          ),
          child: Text(label),
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return Column(
      children: [
        Center(
          child: Text(
            'Initial Balance',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryTextColorLight,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        FormBuilderTextField(
          name: 'amount',
          style: const TextStyle(
            color: AppColors.primaryTextColorLight,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          decoration: _inputDecoration(hintText: '0.00').copyWith(
            hintStyle: const TextStyle(
              fontSize: 26,
              color: AppColors.lightGreyBackground,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.numeric(
              errorText: 'Please enter a valid number',
            ),
            (value) {
              if (value == null || value.isEmpty) return null;
              final number = double.tryParse(value);
              if (number != null && number < 0) {
                return 'Initial Balance cannot be negative';
              }
              return null;
            },
          ]),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildCreditLimitOrBalanceField() {
    return _buildFormSection(
      context,
      _isCreditSelected ? 'Credit Limit' : 'Balance Limit',
      FormBuilderTextField(
        name: _isCreditSelected ? 'credit_limit' : 'balance_limit',
        style: const TextStyle(fontSize: 13),
        decoration: _inputDecoration(
          hintText: _isCreditSelected ? 'e.g., 1000' : 'e.g., 1000',
        ),
        keyboardType: const TextInputType.numberWithOptions(signed: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9]*')),
        ],
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
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
      color: AppColors.scaffoldBackground,
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
              onPressed: () async {
                if (_formKey.currentState?.saveAndValidate() ?? false) {
                  try {
                    final values = _formKey.currentState!.value;
                    final name = values['name'] as String;
                    final amount = double.tryParse(values['amount'].toString()) ?? 0.0;
                    final accountType = values['account_type'] as String;

                    // Determine creditLimit or balanceLimit based on _isCreditSelected
                    final creditLimitValue = _isCreditSelected
                        ? double.tryParse(values['credit_limit']?.toString() ?? '')
                        : null;
                    final balanceLimitValue = !_isCreditSelected
                        ? double.tryParse(values['balance_limit']?.toString() ?? '')
                        : null;

                    double balance = amount;
                    if (_isCreditSelected && creditLimitValue != null) {
                      balance -= creditLimitValue.abs();
                    }

                    final newAccount = FirestoreAccount(
                      id: '', // Will be generated by Firestore
                      name: name,
                      accountType: accountType,
                      balance: balance,
                      currency: 'USD', // Placeholder
                      creditLimit: creditLimitValue,
                      balanceLimit: balanceLimitValue,
                      isDefault: false,
                    );

                    final accountId = await _firestoreService.createAccount(newAccount);

                    // Check if 'include_in_total' is enabled and create initial balance transaction
                    final includeInTotal = values['include_in_total'] as bool? ?? true;
                    if (includeInTotal && amount > 0) {
                      // Determine transaction type based on account type and amount
                      String transactionType = 'income';
                      String description = 'Initial Balance for $name';
                      
                      if (_isCreditSelected) {
                        // For credit accounts, a positive limit is effectively an expense (liability)
                        transactionType = 'expense';
                        description = 'Credit Limit for $name';
                      }
                      
                      final initialTransaction = FirestoreTransaction(
                        id: '', // Will be generated by Firestore
                        description: description,
                        amount: amount.abs(), // Use absolute value of amount
                        type: transactionType,
                        date: DateTime.now(),
                        accountId: accountId,
                      );
                      
                      await _firestoreService.createTransaction(initialTransaction);
                    }
                    
                    if (includeInTotal) {
                      Provider.of<HomeScreenProvider>(context, listen: false).triggerAccountRefresh();
                    } else {
                      Provider.of<HomeScreenProvider>(context, listen: false).triggerRefresh();
                    }

                    debugPrint(_formKey.currentState?.value.toString());
                    Navigator.of(context).pop();
                  } catch (e) {
                    print('Error creating account: $e');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to create account: $e')),
                      );
                    }
                  }
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
                'Add',
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
}
