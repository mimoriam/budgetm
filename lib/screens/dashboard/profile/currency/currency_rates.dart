import 'package:budgetm/constants/appColors.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:budgetm/viewmodels/currency_provider.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:currency_picker/src/currency_utils.dart';

class CurrencyRatesScreen extends StatefulWidget {
  const CurrencyRatesScreen({super.key});

  @override
  State<CurrencyRatesScreen> createState() => _CurrencyRatesScreenState();
}

class _CurrencyRatesScreenState extends State<CurrencyRatesScreen> {
 @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final selectedCurrency = currencyProvider.selectedCurrency;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildCustomAppBar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('MAIN CURRENCY', showChangeButton: true),
                  _buildCurrencyCard(
                    _getCurrencyFlag(selectedCurrency),
                    _getCurrencyName(selectedCurrency),
                    selectedCurrency,
                    isMain: true,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('OTHERS', showAddButton: true),
                  // ..._buildOtherCurrencies(currencyProvider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
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
          padding: const EdgeInsets.fromLTRB(14.0, 6.0, 14.0, 0),
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
                'Currency Rates',
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

  Widget _buildSectionHeader(
    String title, {
    bool showChangeButton = false,
    bool showAddButton = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          if (showChangeButton)
            SizedBox(
              height: 28,
              child: ElevatedButton(
                onPressed: () {
                  _showCurrencyPicker(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gradientEnd,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text(
                  'CHANGE',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          if (showAddButton)
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.gradientEnd,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.add, color: Colors.black, size: 18),
                onPressed: () {},
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildOtherCurrencies(CurrencyProvider currencyProvider) {
    List<Widget> widgets = [];
    
    for (int i = 0; i < currencyProvider.otherCurrencies.length; i++) {
      final currencyCode = currencyProvider.otherCurrencies[i];
      final flag = _getCurrencyFlag(currencyCode);
      final name = _getCurrencyName(currencyCode);
      
      widgets.add(
        _buildCurrencyCard(
          flag,
          name,
          currencyCode,
          value: '\$10.00', // This should be replaced with actual conversion logic
        ),
      );
      
      // Add spacing between currency cards except for the last one
      if (i < currencyProvider.otherCurrencies.length - 1) {
        widgets.add(const SizedBox(height: 12));
      }
    }
    
    // If there are no other currencies, show a message
    if (currencyProvider.otherCurrencies.isEmpty) {
      widgets.add(
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 1,
                blurRadius: 10,
              ),
            ],
          ),
          child: const Text(
            'No other currencies added yet',
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ),
      );
    }
    
    return widgets;
  }

  Widget _buildCurrencyCard(
    String flag,
    String name,
    String code, {
    String? value,
    bool isMain = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                code,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          if (value != null) ...[
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ],
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context, listen: false);
    
    showCurrencyPicker(
      context: context,
      onSelect: (Currency currency) {
        currencyProvider.setCurrency(currency.code);
        // The selected currency becomes the main currency, so we don't add it to other currencies
      },
    );
  }

  String _getCurrencyFlag(String currencyCode) {
    try {
      final currency = CurrencyService().findByCode(currencyCode);
      if (currency != null) {
        return CurrencyUtils.currencyToEmoji(currency);
      }
      return '🏳️';
    } catch (e) {
      return '🏳️';
    }
  }

  String _getCurrencyName(String currencyCode) {
    try {
      final currency = CurrencyService().findByCode(currencyCode);
      return currency?.name ?? currencyCode;
    } catch (e) {
      return currencyCode;
    }
  }
}
