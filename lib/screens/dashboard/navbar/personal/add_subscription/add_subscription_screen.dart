import 'package:flutter/material.dart';
import 'package:budgetm/models/personal/subscription.dart';
import 'package:budgetm/viewmodels/currency_provider.dart';
import 'package:budgetm/viewmodels/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:budgetm/constants/appColors.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

class AddSubscriptionScreen extends StatefulWidget {
  const AddSubscriptionScreen({super.key});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isActive = true;
  Recurrence _recurrence = Recurrence.monthly;
  DateTime? _startDate;
  DateTime? _nextBillingDate;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);

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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPriceField(currencyProvider),
                        const SizedBox(height: 10),
                        _buildFormSection(
                          context,
                          'Name',
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(fontSize: 13),
                            decoration: _inputDecoration(
                              hintText: 'Name',
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a name';
                              }
                              if (value.trim().length < 2) {
                                return 'Name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildFormSection(
                          context,
                          'Active',
                          InputDecorator(
                            decoration: _inputDecoration(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Active',
                                  style: TextStyle(fontSize: 13, color: AppColors.primaryTextColorLight),
                                ),
                                Switch(
                                  value: _isActive,
                                  onChanged: (value) {
                                    setState(() {
                                      _isActive = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildFormSection(
                          context,
                          'Recurrence',
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30.0),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                            child: SegmentedButton<Recurrence>(
                              segments: const [
                                ButtonSegment(value: Recurrence.weekly, label: Text('Weekly')),
                                ButtonSegment(value: Recurrence.monthly, label: Text('Monthly')),
                                ButtonSegment(value: Recurrence.quarterly, label: Text('Quarterly')),
                                ButtonSegment(value: Recurrence.yearly, label: Text('Yearly')),
                              ],
                              selected: {_recurrence},
                              onSelectionChanged: (newSelection) {
                                setState(() {
                                  _recurrence = newSelection.first;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildFormSection(
                          context,
                          'Start Date',
                          GestureDetector(
                            onTap: _selectStartDate,
                            child: InputDecorator(
                              decoration: _inputDecoration(
                                hintText: 'Select Date',
                              ).copyWith(
                                suffixIcon: const Padding(
                                  padding: EdgeInsets.only(right: 12.0),
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedCalendar01,
                                    color: Colors.grey,
                                    size: 18,
                                  ),
                                ),
                              ),
                              child: SizedBox(
                                height: 20,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _formatDate(_startDate) ?? 'Select Date',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.primaryTextColorLight,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildFormSection(
                          context,
                          'Next Billing Date',
                          GestureDetector(
                            onTap: _selectNextBillingDate,
                            child: InputDecorator(
                              decoration: _inputDecoration(
                                hintText: 'Select Date',
                              ).copyWith(
                                suffixIcon: const Padding(
                                  padding: EdgeInsets.only(right: 12.0),
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedCalendar01,
                                    color: Colors.grey,
                                    size: 18,
                                  ),
                                ),
                              ),
                              child: SizedBox(
                                height: 20,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _formatDate(_nextBillingDate) ?? 'Select Date',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.primaryTextColorLight,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
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

  Widget _buildPriceField(CurrencyProvider currencyProvider) {
    return Column(
      children: [
        Center(
          child: Text(
            'Price',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryTextColorLight,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _priceController,
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
            prefixText: currencyProvider.currencySymbol,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            final v = value?.trim() ?? '';
            if (v.isEmpty) {
              return 'Please enter a price';
            }
            final parsed = double.tryParse(v);
            if (parsed == null) {
              return 'Please enter a valid number';
            }
            if (parsed <= 0) {
              return 'Price must be greater than zero';
            }
            return null;
          },
        ),
      ],
    );
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_nextBillingDate != null && _nextBillingDate!.isBefore(picked)) {
          _nextBillingDate = null;
        }
      });
    }
  }

  Future<void> _selectNextBillingDate() async {
    final initial = _nextBillingDate ?? _startDate ?? DateTime.now();
    final first = _startDate ?? DateTime(2000);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _nextBillingDate = picked;
      });
    }
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Widget _buildCustomAppBar(BuildContext context) {
    const title = 'Add Subscription';

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
              onPressed: _saveSubscription,
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

  void _saveSubscription() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_startDate == null || _nextBillingDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both start and next billing dates')),
      );
      return;
    }
    if (_nextBillingDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Next billing date cannot be before start date')),
      );
      return;
    }

    try {
      final subscription = Subscription(
        id: 'sub_${DateTime.now().microsecondsSinceEpoch}',
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        isActive: _isActive,
        startDate: _startDate!,
        nextBillingDate: _nextBillingDate!,
        recurrence: _recurrence,
      );

      // TODO: Persist the subscription using a provider/service
      Navigator.of(context).pop(subscription);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}