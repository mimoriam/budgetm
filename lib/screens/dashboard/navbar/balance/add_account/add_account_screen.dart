import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/models/firestore_account.dart';
import 'package:budgetm/models/firestore_transaction.dart';
import 'package:budgetm/viewmodels/home_screen_provider.dart';
import 'package:budgetm/widgets/pretty_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:budgetm/utils/account_icon_utils.dart';

class AddAccountScreen extends StatefulWidget {
  final bool isCreatingVacationAccount;
  const AddAccountScreen({super.key, this.isCreatingVacationAccount = false});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isCreditSelected = false; // Balance is selected by default
  bool _isSaving = false;
  String? _selectedAccountType;
  late FirestoreService _firestoreService;
  late FocusNode _amountFocusNode;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService.instance;
    _amountFocusNode = FocusNode();
    // If creating a vacation account, default to Credit and don't prompt selection.
    if (widget.isCreatingVacationAccount) {
      _isCreditSelected = true;
      _selectedAccountType = 'Credit';
    } else {
      // Show account type selection bottom sheet immediately after first frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAccountTypeSelection();
      });
    }
  }

  @override
  void dispose() {
    _amountFocusNode.dispose();
    super.dispose();
  }

  Future<dynamic?> _showPrettySelectionBottomSheet({
    required String title,
    required List<dynamic> items,
    required dynamic selectedItem,
    required String Function(dynamic) getDisplayName,
    Widget Function(dynamic)? getLeading,
  }) async {
    final result = await showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return PrettyBottomSheet<dynamic>(
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

  Future<void> _showAccountTypeSelection() async {
    final types = [
      'Cash',
      'Master Card',
      'Wallet',
      'Cryptocurrency',
      'Saving',
      'Gold',
      'Safe',
      'Bank',
      'Investment',
    ];

    final selected = _selectedAccountType ?? types.first;

    final result = await _showPrettySelectionBottomSheet(
      title: 'Select Account Type',
      items: types,
      selectedItem: selected,
      getDisplayName: (t) => t.toString(),
      getLeading: (t) {
        final icons = getAccountIcon(t.toString());
        final iconData = (icons.isNotEmpty && icons.first.isNotEmpty)
            ? icons.first.first
            : HugeIcons.strokeRoundedCash01;
        return SizedBox(
          width: 28,
          height: 28,
          child: Center(
            child: HugeIcon(
              icon: iconData,
              color: AppColors.primaryTextColorLight,
              size: 20,
            ),
          ),
        );
      },
    );

    if (result == null) {
      // If user dismissed without selecting, default to 'Cash'
      setState(() {
        _selectedAccountType = types.first;
        _formKey.currentState?.patchValue({'account_type': types.first});
      });
    } else {
      setState(() {
        _selectedAccountType = result as String;
        _formKey.currentState?.patchValue({
          'account_type': _selectedAccountType,
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _amountFocusNode.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
                  // autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        Column(
                          children: [
                            widget.isCreatingVacationAccount
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10.0,
                                      horizontal: 16.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30.0),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Builder(
                                              builder: (context) {
                                                final icons = getAccountIcon(
                                                  _selectedAccountType,
                                                );
                                                final iconData =
                                                    (icons.isNotEmpty &&
                                                        icons.first.isNotEmpty)
                                                    ? icons.first.first
                                                    : HugeIcons
                                                          .strokeRoundedCash01;
                                                return HugeIcon(
                                                  icon: iconData,
                                                  color:
                                                      _selectedAccountType !=
                                                          null
                                                      ? AppColors
                                                            .primaryTextColorLight
                                                      : AppColors
                                                            .lightGreyBackground,
                                                  size: 16,
                                                );
                                              },
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _selectedAccountType ?? 'Credit',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color:
                                                    _selectedAccountType != null
                                                    ? AppColors
                                                          .primaryTextColorLight
                                                    : AppColors
                                                          .lightGreyBackground,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: _showAccountTypeSelection,
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
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Builder(
                                                builder: (context) {
                                                  final icons = getAccountIcon(
                                                    _selectedAccountType,
                                                  );
                                                  final iconData =
                                                      (icons.isNotEmpty &&
                                                          icons
                                                              .first
                                                              .isNotEmpty)
                                                      ? icons.first.first
                                                      : HugeIcons
                                                            .strokeRoundedCash01;
                                                  return HugeIcon(
                                                    icon: iconData,
                                                    color:
                                                        _selectedAccountType !=
                                                            null
                                                        ? AppColors
                                                              .primaryTextColorLight
                                                        : AppColors
                                                              .lightGreyBackground,
                                                    size: 16,
                                                  );
                                                },
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                _selectedAccountType ??
                                                    'Select Account Type',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color:
                                                      _selectedAccountType !=
                                                          null
                                                      ? AppColors
                                                            .primaryTextColorLight
                                                      : AppColors
                                                            .lightGreyBackground,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Icon(
                                            Icons.arrow_drop_down,
                                            color: AppColors
                                                .secondaryTextColorLight,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            // Hidden field to store and validate the account_type
                            Opacity(
                              opacity: 0,
                              child: AbsorbPointer(
                                child: FormBuilderTextField(
                                  name: 'account_type',
                                  initialValue: widget.isCreatingVacationAccount
                                      ? 'Credit'
                                      : _selectedAccountType,
                                  validator: FormBuilderValidators.required(
                                    errorText: 'Account type is required',
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // const SizedBox(height: 10),
                      // Transform.scale(
                      //   scale: 0.9,
                      //   alignment: Alignment.centerLeft,
                      //   child: FormBuilderSwitch(
                      //     name: 'include_in_total',
                      //     title: const Text('Include in Total Balance'),
                      //     initialValue: true,
                      //     decoration: const InputDecoration(
                      //       border: InputBorder.none,
                      //       contentPadding: EdgeInsets.zero,
                      //     ),
                      //     controlAffinity: ListTileControlAffinity.trailing,
                      //     contentPadding: const EdgeInsets.symmetric(
                      //       horizontal: 4,
                      //     ),
                      //   ),
                      // ),
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
        gradient: widget.isCreatingVacationAccount
            ? null
            : const LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: widget.isCreatingVacationAccount
            ? AppColors.aiGradientStart
            : null,
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
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            widget.isCreatingVacationAccount
                                ? AppColors.aiGradientStart
                                : AppColors.gradientStart,
                            widget.isCreatingVacationAccount
                                ? const Color.fromARGB(255, 154, 185, 235)
                                : AppColors.gradientEnd,
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
            if (!widget.isCreatingVacationAccount) const SizedBox(height: 10),
            // Hide account type selection toggle for vacation accounts
            if (!widget.isCreatingVacationAccount) _buildToggleChips(),
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
            widget.isCreatingVacationAccount
                ? 'Total Budget'
                : 'Initial Balance',
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
          focusNode: _amountFocusNode,
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
              // Allow negative initial balance for credit accounts
              if (number != null && number < 0 && !_isCreditSelected) {
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
    // Hide credit limit field for vacation accounts
    if (widget.isCreatingVacationAccount) {
      return const SizedBox.shrink();
    }

    return _buildFormSection(
      context,
      _isCreditSelected ? 'Credit Limit' : 'Transaction Limit',
      FormBuilderTextField(
        name: _isCreditSelected ? 'credit_limit' : 'transaction_limit',
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
              onPressed: _isSaving
                  ? null
                  : () async {
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        try {
                          setState(() {
                            _isSaving = true;
                          });
                          final values = _formKey.currentState!.value;
                          final name = values['name'] as String;
                          final amount =
                              double.tryParse(values['amount'].toString()) ??
                              0.0;
                          final accountType = values['account_type'] as String;

                          // Determine creditLimit or balanceLimit based on _isCreditSelected
                          // For vacation accounts, creditLimit should always be null (unlimited)
                          final creditLimitValue =
                              widget.isCreatingVacationAccount
                              ? null
                              : _isCreditSelected
                              ? double.tryParse(
                                  values['credit_limit']?.toString() ?? '',
                                )
                              : null;
                          final balanceLimitValue = !_isCreditSelected
                              ? double.tryParse(
                                  values['transaction_limit']?.toString() ?? '',
                                )
                              : null;
                          // Parse transaction_limit explicitly so it can be saved separately
                          final transactionLimitValue = double.tryParse(
                            values['transaction_limit']?.toString() ?? '',
                          );

                          // Preserve user-entered amount for transaction creation logic,
                          // but store/display a negative balance for credit accounts.
                          final inputAmount = amount;
                          double storedAmount = amount;
                          if (_isCreditSelected) {
                            storedAmount = -amount.abs();
                          }

                          double balance = storedAmount;
                          if (_isCreditSelected && creditLimitValue != null) {
                            balance -= creditLimitValue.abs();
                          }

                          final newAccount = FirestoreAccount(
                            id: '', // Will be generated by Firestore
                            name: name,
                            accountType: widget.isCreatingVacationAccount
                                ? 'Credit'
                                : accountType,
                            balance: balance,
                            initialBalance:
                                inputAmount, // Store the user's input as initial balance
                            currency: 'USD', // Placeholder
                            creditLimit: creditLimitValue,
                            balanceLimit: balanceLimitValue,
                            transactionLimit: transactionLimitValue,
                            isDefault: false,
                            isVacationAccount: widget.isCreatingVacationAccount,
                          );

                          final accountId = await _firestoreService
                              .createAccount(newAccount);

                          // Check if 'include_in_total' is enabled and create initial balance transaction
                          // final includeInTotal =
                          //     values['include_in_total'] as bool? ?? true;
                          // TODO: Uncomment the Include in Total balance option
                          final includeInTotal =
                              values['include_in_total'] as bool? ?? false;
                          if (includeInTotal && inputAmount > 0) {
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
                              amount: inputAmount
                                  .abs(), // Use absolute value of user-entered amount
                              type: transactionType,
                              date: DateTime.now(),
                              accountId: accountId,
                            );

                            await _firestoreService.createTransaction(
                              initialTransaction,
                            );
                          }

                          if (includeInTotal) {
                            if (context.mounted) {
                              Provider.of<HomeScreenProvider>(
                                context,
                                listen: false,
                              ).triggerAccountRefresh();
                            }
                          } else {
                            if (context.mounted) {
                              Provider.of<HomeScreenProvider>(
                                context,
                                listen: false,
                              ).triggerRefresh();
                            }
                          }

                          debugPrint(_formKey.currentState?.value.toString());
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to create account: $e'),
                              ),
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
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isCreatingVacationAccount
                    ? AppColors.vacationColor
                    : AppColors.gradientEnd,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2.0,
                      ),
                    )
                  : Text(
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
