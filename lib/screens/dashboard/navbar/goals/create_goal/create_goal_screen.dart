import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/constants/goal_type_enum.dart';
import 'package:budgetm/generated/i18n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:budgetm/models/goal.dart';
import 'package:budgetm/viewmodels/goals_provider.dart';
import 'package:budgetm/viewmodels/currency_provider.dart';
import 'package:budgetm/viewmodels/subscription_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:budgetm/screens/paywall/paywall_screen.dart';

class CreateGoalScreen extends StatefulWidget {
  final GoalType goalType;

  const CreateGoalScreen({super.key, required this.goalType});

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isMoreOptionsVisible = false;
  Color _selectedColor = Colors.grey.shade300;
  bool _isLoading = false;

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
          title: Text(AppLocalizations.of(context)!.pickColor),
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFFAFAFA),
        body: Column(
          children: [
            _buildCustomAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
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
                        _buildAmountField(),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildFormSection(
                                context,
                                AppLocalizations.of(context)!.createGoalName,
                                FormBuilderTextField(
                                  name: 'name',
                                  style: const TextStyle(fontSize: 13),
                                  decoration: _inputDecoration(
                                    hintText: AppLocalizations.of(context)!.hintName,
                                  ),
                                  validator: FormBuilderValidators.required(
                                    errorText: 'Name is required',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildFormSection(
                                context,
                                AppLocalizations.of(context)!.createGoalCurrency,
                                FormBuilderField<String>(
                                  name: 'currency',
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
                                              onSelect: (Currency currency) {
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
            ),
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return Column(
      children: [
        Center(
          child: Text(
            AppLocalizations.of(context)!.createGoalAmount,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryTextColorLight,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 4),
        FormBuilderTextField(
          name: 'targetAmount',
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
            FormBuilderValidators.required(errorText: 'Amount is required'),
            FormBuilderValidators.numeric(
              errorText: 'Please enter a valid number',
            ),
          ]),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildMoreOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormSection(
          context,
          AppLocalizations.of(context)!.createGoalNotes,
          FormBuilderTextField(
            name: 'description',
            style: const TextStyle(fontSize: 13),
            // initialValue: "Hi there, I'm designing this app.....",
            decoration: _inputDecoration(hintText: AppLocalizations.of(context)!.hintDescription),
            maxLines: 2,
          ),
        ),
        const SizedBox(height: 8),
        _buildFormSection(
          context,
          AppLocalizations.of(context)!.createGoalDate,
          FormBuilderDateTimePicker(
            name: 'targetDate',
            initialValue: DateTime.now(),
            inputType: InputType.date,
            format: DateFormat('dd/MM/yyyy'),
            style: const TextStyle(fontSize: 13),
            decoration: _inputDecoration(
              suffixIcon: HugeIcons.strokeRoundedCalendar01,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildFormSection(
          context,
          AppLocalizations.of(context)!.createGoalColor,
          GestureDetector(
            onTap: _showColorPicker,
            child: FormBuilderField(
              name: 'color',
              builder: (FormFieldState<dynamic> field) {
                return InputDecorator(
                  decoration: _inputDecoration(hintText: AppLocalizations.of(context)!.hintSelectColor),
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
                AppLocalizations.of(context)!.createGoalMore,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
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
    String title;
    if (widget.goalType == GoalType.pending) {
      title = AppLocalizations.of(context)!.createGoalTitle;
    } else {
      title = AppLocalizations.of(context)!.createGoalTitle;
    }

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
                title,
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
              onPressed: _isLoading ? null : () async {
                final isValid = _formKey.currentState?.saveAndValidate() ?? false;
                if (!isValid) return;

                setState(() {
                  _isLoading = true;
                });

                try {
                  final values = _formKey.currentState!.value;

                  // Extract and transform form values
                  final String name = (values['name'] as String? ?? '').trim();

                  // Prevent duplicate goal names (case-insensitive)
                  final bool exists = await context.read<GoalsProvider>().doesGoalExist(name);
                  if (exists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.goalNameAlreadyExistsSnackbar)),
                    );
                    return;
                  }

                  final dynamic amountRaw = values['targetAmount'];
                  double targetAmount;
                  if (amountRaw is num) {
                    targetAmount = amountRaw.toDouble();
                  } else if (amountRaw is String) {
                    targetAmount = double.tryParse(amountRaw.replaceAll(',', '').trim()) ?? 0.0;
                  } else {
                    targetAmount = 0.0;
                  }

                  final DateTime targetDate = (values['targetDate'] as DateTime?) ?? DateTime.now();
                  final String? descriptionRaw = values['description'] as String?;
                  final String? description = (descriptionRaw == null || descriptionRaw.trim().isEmpty)
                      ? null
                      : descriptionRaw.trim();
                  final String icon = (values['icon'] as String? ?? 'icon_default_goal').trim();
                  final String selectedCurrency = values['currency'] as String? ?? Provider.of<CurrencyProvider>(context, listen: false).selectedCurrencyCode;

                  // Convert selected color to ARGB hex string (e.g., ffRRGGBB)
                  final String? colorString = '#${_selectedColor.value.toRadixString(16).padLeft(8, '0')}';

                  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

                  final goal = FirestoreGoal(
                    id: '', // Firestore will generate the ID
                    name: name,
                    description: description,
                    targetAmount: targetAmount,
                    creationDate: DateTime.now(),
                    targetDate: targetDate,
                    userId: userId,
                    icon: icon,
                    color: colorString,
                    isCompleted: widget.goalType == GoalType.fulfilled,
                    currency: selectedCurrency, // Use selected currency from form
                  );

                  await context.read<GoalsProvider>().addGoal(goal);

                  Navigator.of(context).pop();
                } catch (e) {
                  // Handle any errors that might occur during goal creation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.errorCreatingGoal(e.toString()))),
                  );
                } finally {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLoading ? Colors.grey : AppColors.gradientEnd,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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