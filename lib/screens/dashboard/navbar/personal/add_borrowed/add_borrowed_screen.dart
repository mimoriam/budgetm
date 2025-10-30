import 'package:flutter/material.dart';
import 'package:budgetm/models/personal/borrowed.dart';
import 'package:budgetm/viewmodels/currency_provider.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:budgetm/constants/appColors.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:budgetm/generated/i18n/app_localizations.dart';

class AddBorrowedScreen extends StatefulWidget {
  const AddBorrowedScreen({super.key});

  @override
  State<AddBorrowedScreen> createState() => _AddBorrowedScreenState();
}

class _AddBorrowedScreenState extends State<AddBorrowedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime? _date;
  DateTime? _dueDate;
  bool _returned = false;
  bool _isSaving = false;

  bool _isMoreOptionsVisible = false;
  final FirestoreService _firestoreService = FirestoreService.instance;

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
    _dueDate = DateTime.now().add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAmountField(currencyProvider),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildFormSection(
                                context,
                                AppLocalizations.of(context)!.hintName,
                                TextFormField(
                                  controller: _nameController,
                                  style: const TextStyle(fontSize: 13),
                                  decoration: _inputDecoration(
                                    hintText: AppLocalizations.of(context)!.hintName,
                                  ),
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    final v = value?.trim() ?? '';
                                    if (v.isEmpty) {
                                      return 'Please enter a name';
                                    }
                                    return null;
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
                            child: _buildMoreOptions(context),
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

  Widget _buildAmountField(CurrencyProvider currencyProvider) {
    return Column(
      children: [
        Center(
          child: Text(
            AppLocalizations.of(context)!.hintAmount,
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
          ),
          validator: (value) {
            final v = value?.trim() ?? '';
            if (v.isEmpty) {
              return 'Please enter a price';
            }
            final parsed = double.tryParse(v.replaceAll(',', ''));
            if (parsed == null) {
              return 'Please enter a valid number';
            }
            if (parsed <= 0) {
              return 'Price must be greater than zero';
            }
            return null;
          },
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }

  Widget _buildMoreOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormSection(
          context,
          AppLocalizations.of(context)!.hintNotes,
          TextFormField(
            controller: _descriptionController,
            style: const TextStyle(fontSize: 13),
            decoration: _inputDecoration(hintText: AppLocalizations.of(context)!.hintDescription),
            maxLines: 2,
          ),
        ),
        const SizedBox(height: 8),
        _buildFormSection(
          context,
          AppLocalizations.of(context)!.hintSelectDate,
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (picked != null) {
                setState(() {
                  _date = picked;
                  if (_dueDate != null && _dueDate!.isBefore(picked)) {
                    _dueDate = null;
                  }
                });
              }
            },
            child: InputDecorator(
              decoration: _inputDecoration(
                hintText: AppLocalizations.of(context)!.hintSelectDate,
                suffixIcon: HugeIcons.strokeRoundedCalendar01,
              ),
              child: SizedBox(
                height: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _date == null ? 'Select Date' : _formatDate(_date!),
                      style: TextStyle(
                        fontSize: 13,
                        color: _date == null
                            ? AppColors.lightGreyBackground
                            : AppColors.primaryTextColorLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildFormSection(
          context,
          AppLocalizations.of(context)!.hintSelectDueDate,
          GestureDetector(
            onTap: () async {
              final initial = _dueDate ?? _date ?? DateTime.now();
              final first = _date ?? DateTime(2000);
              final picked = await showDatePicker(
                context: context,
                initialDate: initial,
                firstDate: first,
                lastDate: DateTime(2101),
              );
              if (picked != null) {
                setState(() {
                  _dueDate = picked;
                });
              }
            },
            child: InputDecorator(
              decoration: _inputDecoration(
                hintText: AppLocalizations.of(context)!.hintSelectDueDate,
                suffixIcon: HugeIcons.strokeRoundedCalendar01,
              ),
              child: SizedBox(
                height: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _dueDate == null ? 'Select Due Date' : _formatDate(_dueDate!),
                      style: TextStyle(
                        fontSize: 13,
                        color: _dueDate == null
                            ? AppColors.lightGreyBackground
                            : AppColors.primaryTextColorLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildFormSection(
          context,
          AppLocalizations.of(context)!.markAsReturned,
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.0),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
            child: Row(
              children: [
                Text(
                AppLocalizations.of(context)!.markAsReturned,
                  style: TextStyle(fontSize: 13),
                ),
                const Spacer(),
                Switch(
                  value: _returned,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _returned = value;
                    });
                  },
                ),
              ],
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
    final String title = AppLocalizations.of(context)!.addBorrowedTitle;

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
                AppLocalizations.of(context)!.buttonCancel,
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
              onPressed: _isSaving ? null : _saveBorrowedItem,
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
                      AppLocalizations.of(context)!.add,
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

  String _formatDate(DateTime dt) {
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  Future<void> _saveBorrowedItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_date == null || _dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.borrowedSelectBothDates)),
      );
      return;
    }
    if (_dueDate!.isBefore(_date!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.borrowedDueDateBeforeBorrowedDate)),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final borrowed = Borrowed(
        id: 'borrowed_${DateTime.now().microsecondsSinceEpoch}',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim().replaceAll(',', '')),
        date: _date!,
        dueDate: _dueDate!,
        returned: _returned,
        currency: Provider.of<CurrencyProvider>(context, listen: false).selectedCurrencyCode,
      );

      // Save to Firestore without creating a transaction
      await _firestoreService.createBorrowed(borrowed);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.borrowedItemAddedSuccessfully)),
        );
        Navigator.of(context).pop(borrowed);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.borrowedItemError(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}