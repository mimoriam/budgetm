import 'package:budgetm/constants/appColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/models/category.dart';
import 'package:budgetm/models/budget.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddBudgetScreen extends StatefulWidget {
  final List<String>? completedBudgetNames;
  const AddBudgetScreen({super.key, this.completedBudgetNames});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoadingCategories = true;
  late FirestoreService _firestoreService;
  List<Category> _categories = [];
  String? _selectedCategoryId;
  bool _isSaving = false;
  List<String> _completedBudgetNames = [];
  bool _didLoadRouteArgs = false;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService.instance;
    _loadCategories();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoadRouteArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is List<String>) {
        _completedBudgetNames = args;
      } else if (widget.completedBudgetNames != null) {
        _completedBudgetNames = widget.completedBudgetNames!;
      } else {
        _completedBudgetNames = [];
      }
      _didLoadRouteArgs = true;
    }
  }

  Future<void> _loadCategories() async {
    try {
      final allCategories = await _firestoreService.getAllCategories();
      final incomeCategories = allCategories
          .where((c) => c.type == 'income')
          .toList();
      incomeCategories.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      setState(() {
        _categories = incomeCategories;
        _isLoadingCategories = false;
        if (_categories.isNotEmpty) {
          final misc = _categories.firstWhere(
            (c) => (c.name ?? '').toLowerCase() == 'misc',
            orElse: () => _categories.first,
          );
          _selectedCategoryId = misc.id;
        }
      });
    } catch (e) {
      debugPrint('Error loading income categories: $e');
      setState(() {
        _isLoadingCategories = false;
      });
    }
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
                                'Name',
                                FormBuilderTextField(
                                  name: 'name',
                                  style: const TextStyle(fontSize: 13),
                                  decoration: _inputDecoration(
                                    hintText: 'Askari Bank',
                                  ),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(
                                      errorText: 'Name is required',
                                    ),
                                    (val) {
                                      if (val == null || val.trim().isEmpty) return null;
                                      final lower = val.trim().toLowerCase();
                                      if (_completedBudgetNames.any((e) => e.trim().toLowerCase() == lower)) {
                                        return 'This name is already used by a completed budget.';
                                      }
                                      return null;
                                    },
                                  ]),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildFormSection(
                                context,
                                'Category',
                                _isLoadingCategories
                                    ? SizedBox(
                                        height: 48,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : FormBuilderDropdown(
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
                                                  category.name ??
                                                      'Unnamed Category',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        initialValue: _selectedCategoryId,
                                        validator:
                                            FormBuilderValidators.required(
                                              errorText:
                                                  'Please select a category',
                                            ),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedCategoryId =
                                                value;
                                          });
                                        },
                                      ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildFormSection(
                          context,
                          'End Date',
                          FormBuilderDateTimePicker(
                            name: 'end_date',
                            initialValue: DateTime.now().add(
                              const Duration(days: 1),
                            ),
                            inputType: InputType.date,
                            format: DateFormat('dd/MM/yyyy'),
                            style: const TextStyle(fontSize: 13),
                            decoration: _inputDecoration(
                              suffixIcon: HugeIcons.strokeRoundedCalendar01,
                            ),
                            validator: FormBuilderValidators.required(
                              errorText: 'End date is required',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildBottomButtons(),
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
            'Amount',
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

  Future<void> _saveBudget() async {
    setState(() {
      _isSaving = true;
    });
    try {
      final formData = _formKey.currentState!.value;
      final name = formData['name'] as String;
      final amountRaw = formData['amount'] as String;
      final totalAmount =
          double.tryParse(amountRaw.replaceAll(',', '')) ??
          double.parse(amountRaw);
      final categoryId =
          formData['category'] as String? ?? _selectedCategoryId ?? '';
      final endDate =
          formData['end_date'] as DateTime? ??
          DateTime.now().add(const Duration(days: 1));
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      final budget = Budget(
        id: '',
        name: name,
        totalAmount: totalAmount,
        currentAmount: 0.0,
        categoryId: categoryId,
        endDate: endDate,
        userId: userId,
      );

      final newId = await _firestoreService.createBudget(budget);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      debugPrint('Error saving budget: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save budget: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildBottomButtons() {
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
                        _saveBudget();
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
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
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
