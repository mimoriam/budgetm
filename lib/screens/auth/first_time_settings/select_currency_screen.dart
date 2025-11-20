import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/generated/i18n/app_localizations.dart';
import 'package:budgetm/screens/dashboard/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:provider/provider.dart';
import 'package:budgetm/viewmodels/currency_provider.dart';
import 'package:budgetm/viewmodels/theme_provider.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SelectCurrencyScreen extends StatefulWidget {
  const SelectCurrencyScreen({super.key});

  @override
  State<SelectCurrencyScreen> createState() => _SelectCurrencyScreenState();
}

class _SelectCurrencyScreenState extends State<SelectCurrencyScreen> {
  Currency? _selectedCurrency;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set default currency
    _selectedCurrency = CurrencyService().findByCode('USD');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.gradientStart, AppColors.gradientEnd2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 32.0,
                          horizontal: 24.0,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.gradientStart2,
                              AppColors.gradientEnd3,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              spreadRadius: 5,
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.selectCurrencyTitle,
                              style: Theme.of(
                                context,
                              ).textTheme.displayLarge?.copyWith(fontSize: 28),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)!.selectCurrencySubtitle,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.secondaryTextColorLight,
                                  ),
                            ),
                            const SizedBox(height: 30),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                AppLocalizations.of(context)!.selectCurrencyLabel,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                showCurrencyPicker(
                                  context: context,
                                  showFlag: true,
                                  showSearchField: true,
                                  showCurrencyName: true,
                                  showCurrencyCode: true,
                                  onSelect: (Currency currency) {
                                    setState(() {
                                      _selectedCurrency = currency;
                                    });
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30.0),
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedCurrency != null
                                          ? '${_selectedCurrency!.name} (${_selectedCurrency!.symbol})'
                                          : AppLocalizations.of(context)!.selectCurrencyLabel,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.gradientEnd,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                ),
                                onPressed: _isLoading ? null : () async {
                                  if (_selectedCurrency != null) {
                                    setState(() {
                                      _isLoading = true;
                                    });

                                    try {
                                      final currencyProvider =
                                          Provider.of<CurrencyProvider>(context, listen: false);
                                      await currencyProvider.setCurrency(_selectedCurrency!, 1.0);

                                      // Determine theme mode string from provider
                                      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                                      String themeModeStr = 'system';
                                      final tm = themeProvider.themeMode;
                                      if (tm == ThemeMode.light) {
                                        themeModeStr = 'light';
                                      } else if (tm == ThemeMode.dark) {
                                        themeModeStr = 'dark';
                                      }

                                      // Begin initialization: upsert default categories and update account profile
                                      final uid = FirebaseAuth.instance.currentUser?.uid;
                                      if (uid == null) {
                                        throw Exception('User not authenticated');
                                      }

                                      await FirestoreService.instance.beginInitialization(
                                        uid,
                                        _selectedCurrency!.code,
                                        themeModeStr,
                                      );

                                      if (context.mounted) {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const MainScreen(showIntroPaywall: true),
                                          ),
                                          (route) => false,
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(AppLocalizations.of(context)!.errorDuringSetup(e.toString())),
                                            backgroundColor: AppColors.errorColor,
                                          ),
                                        );
                                      }
                                    } finally {
                                      if (mounted) {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }
                                    }
                                  }
                                },
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        AppLocalizations.of(context)!.continueButton,
                                        style: Theme.of(context).textTheme.labelLarge
                                            ?.copyWith(color: Colors.white),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
