import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/generated/i18n/app_localizations.dart';
import 'package:budgetm/models/budget.dart';
import 'package:budgetm/viewmodels/budget_provider.dart';
import 'package:budgetm/viewmodels/currency_provider.dart';
import 'package:budgetm/viewmodels/subscription_provider.dart';
import 'package:budgetm/screens/paywall/paywall_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:budgetm/widgets/pretty_bottom_sheet.dart';
import 'package:budgetm/utils/icon_utils.dart';
import 'package:budgetm/models/category.dart';
import 'package:currency_picker/currency_picker.dart';

class AddBudgetScreen extends StatefulWidget {
  final bool isVacationMode;
  final BudgetType? initialBudgetType;
  
  const AddBudgetScreen({super.key, this.isVacationMode = false, this.initialBudgetType});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  String? _selectedCategoryId;
  late BudgetType _selectedType;
  bool _isLoading = false;
  bool _isRecurring = false;
  String _selectedCurrencyCode = 'USD';

  @override
  void initState() {
    super.initState();
    // Initialize budget type from parameter or default to monthly
    _selectedType = widget.initialBudgetType ?? BudgetType.monthly;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BudgetProvider>(context, listen: false);
      final currencyProvider = Provider.of<CurrencyProvider>(context, listen: false);
      
      // Initialize currency from CurrencyProvider
      setState(() {
        _selectedCurrencyCode = currencyProvider.selectedCurrencyCode;
      });
      
      if (provider.expenseCategories.isNotEmpty && _selectedCategoryId == null) {
        setState(() {
          _selectedCategoryId = provider.expenseCategories.first.id;
        });
      }
      // Show category selection bottom sheet right after first frame
      _showCategorySelection();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _saveBudget() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.addBudgetCategoryRequired)),
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

      setState(() => _isLoading = true);

      try {
        await Provider.of<BudgetProvider>(context, listen: false)
            .addBudget(_selectedCategoryId!, limit, _selectedType, isVacation: widget.isVacationMode, isRecurring: _isRecurring, currency: _selectedCurrencyCode);
        
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.addBudgetCreated)),
          );
        }
      } catch (e) {
        if (mounted) {
          // Extract clean error message from exception
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
    final provider = Provider.of<BudgetProvider>(context, listen: false);
    if (provider.expenseCategories.isEmpty) return;

    final selectedCategory = provider.expenseCategories.firstWhere(
      (cat) => cat.id == _selectedCategoryId,
      orElse: () => provider.expenseCategories.first,
    );

    final result = await _openBottomSheet<Category>(
      title: AppLocalizations.of(context)!.titleSelectCategory,
      items: provider.expenseCategories,
      selectedItem: selectedCategory,
      getDisplayName: (category) => category.name ?? AppLocalizations.of(context)!.unnamedCategory,
      getLeading: (category) => HugeIcon(
        icon: getIcon(category.icon),
        color: AppColors.secondaryTextColorLight,
        size: 20,
      ),
    );

    if (result == null) {
      setState(() {
        _selectedCategoryId = provider.expenseCategories.first.id;
      });
    } else {
      setState(() {
        _selectedCategoryId = result.id;
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      
                      // Category and Budget Type Section
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildFormSection(
                              context,
                              AppLocalizations.of(context)!.addBudgetSelectCategory,
                              Consumer<BudgetProvider>(
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
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          if (_selectedCategoryId != null && provider.expenseCategories.isNotEmpty) ...[
                                            Padding(
                                              padding: const EdgeInsets.only(right: 8.0),
                                              child: HugeIcon(
                                                icon: getIcon(
                                                  provider.expenseCategories.firstWhere(
                                                    (cat) => cat.id == _selectedCategoryId,
                                                    orElse: () => provider.expenseCategories.first,
                                                  ).icon,
                                                ),
                                                color: AppColors.secondaryTextColorLight,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                          Expanded(
                                            child: Text(
                                              _selectedCategoryId != null
                                                  ? (provider.expenseCategories.firstWhere(
                                                      (cat) => cat.id == _selectedCategoryId,
                                                      orElse: () => provider.expenseCategories.first,
                                                    ).name ?? AppLocalizations.of(context)!.unnamedCategory)
                                                  : AppLocalizations.of(context)!.select,
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
                        ],
                      ),
                      const SizedBox(height: 10),
                      
                      // Currency Section - only show in normal mode
                      if (!widget.isVacationMode) ...[
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
                        const SizedBox(height: 10),
                      ],
                      
                      // Recurring Budget Section
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Consumer<SubscriptionProvider>(
                          builder: (context, subscriptionProvider, child) {
                            final canCreateRecurring = subscriptionProvider.canCreateRecurringBudgets();
                            
                            return CheckboxListTile(
                              title: Text(
                                AppLocalizations.of(context)!.addBudgetRecurring,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: canCreateRecurring 
                                      ? AppColors.primaryTextColorLight 
                                      : AppColors.secondaryTextColorLight,
                                ),
                              ),
                              subtitle: Text(
                                canCreateRecurring
                                    ? (_selectedType == BudgetType.daily
                                        ? AppLocalizations.of(context)!.addBudgetRecurringDailySubtitle
                                        : AppLocalizations.of(context)!.addBudgetRecurringSubtitle)
                                    : AppLocalizations.of(context)!.addBudgetRecurringPremiumSubtitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: canCreateRecurring 
                                      ? AppColors.secondaryTextColorLight 
                                      : Colors.orange.shade600,
                                ),
                              ),
                              value: _isRecurring,
                              onChanged: canCreateRecurring ? (bool? value) {
                                setState(() {
                                  _isRecurring = value ?? false;
                                });
                              } : (bool? value) {
                                // Show paywall if user tries to enable recurring budget without subscription
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const PaywallScreen(),
                                  ),
                                );
                              },
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: AppColors.gradientEnd,
                            );
                          },
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
                AppLocalizations.of(context)!.addBudget,
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
    // Map currency codes to flag emojis
    switch (currencyCode) {
      case 'USD':
        return '🇺🇸';
      case 'EUR':
        return '🇪🇺';
      case 'GBP':
        return '🇬🇧';
      case 'JPY':
        return '🇯🇵';
      case 'CAD':
        return '🇨🇦';
      case 'AUD':
        return '🇦🇺';
      case 'CHF':
        return '🇨🇭';
      case 'CNY':
        return '🇨🇳';
      case 'INR':
        return '🇮🇳';
      case 'BRL':
        return '🇧🇷';
      case 'MXN':
        return '🇲🇽';
      case 'KRW':
        return '🇰🇷';
      case 'SGD':
        return '🇸🇬';
      case 'HKD':
        return '🇭🇰';
      case 'NZD':
        return '🇳🇿';
      case 'SEK':
        return '🇸🇪';
      case 'NOK':
        return '🇳🇴';
      case 'DKK':
        return '🇩🇰';
      case 'PLN':
        return '🇵🇱';
      case 'CZK':
        return '🇨🇿';
      case 'HUF':
        return '🇭🇺';
      case 'RUB':
        return '🇷🇺';
      case 'TRY':
        return '🇹🇷';
      case 'ZAR':
        return '🇿🇦';
      case 'AED':
        return '🇦🇪';
      case 'SAR':
        return '🇸🇦';
      case 'EGP':
        return '🇪🇬';
      case 'ILS':
        return '🇮🇱';
      case 'THB':
        return '🇹🇭';
      case 'MYR':
        return '🇲🇾';
      case 'IDR':
        return '🇮🇩';
      case 'PHP':
        return '🇵🇭';
      case 'VND':
        return '🇻🇳';
      default:
        return '🌍'; // Default globe emoji for unknown currencies
    }
  }
}