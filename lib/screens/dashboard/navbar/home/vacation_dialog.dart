import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/models/firestore_account.dart';
import 'package:budgetm/viewmodels/vacation_mode_provider.dart';
import 'package:budgetm/viewmodels/currency_provider.dart';
import 'package:budgetm/screens/dashboard/navbar/balance/add_account/add_account_screen.dart';
import 'package:budgetm/constants/appColors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shows the vacation account selection dialog using showGeneralDialog.
/// This function provides a robust implementation that correctly handles non-dismissible behavior.
/// We're using showGeneralDialog instead of showModalBottomSheet because the latter has
/// compatibility issues with the persistent_bottom_nav_bar package, causing the dialog
/// to be dismissible even when isDismissible is set to false.
Future<void> showVacationDialog(BuildContext context, {bool isMandatory = false}) async {
  final firestoreService = FirestoreService.instance;
  
  // Load accounts to get fresh data every time the dialog is shown
  final all = await firestoreService.getAllAccounts();
  final vacationAccounts = all.where((a) => a.isVacationAccount == true).toList();

  if (!context.mounted) return;

  final result = await showGeneralDialog<FirestoreAccount>(
    context: context,
    barrierDismissible: !isMandatory,
    barrierLabel: isMandatory ? 'Vacation Mode Dialog' : '',
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return WillPopScope(
        onWillPop: () async => !isMandatory,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            margin: const EdgeInsets.only(top: 100), // Leave some space at the top
            child: vacationAccounts.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(16),
                    child: const Text('No vacation accounts available.'),
                  )
                : () {
                    // Maintain selection outside the StatefulBuilder so it persists across rebuilds
                    FirestoreAccount? selectedAccount = vacationAccounts.first;
                    
                    return StatefulBuilder(
                      builder: (context, setState) {
                        // UI hinting only; selection is allowed regardless of currency
                        return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Handle bar
                          Container(
                            margin: const EdgeInsets.only(top: 8, bottom: 8),
                            width: 40,
                            height: 2,
                            decoration: BoxDecoration(
                              color: AppColors.lightGreyBackground.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          // Title with action button
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Vacation Mode',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryTextColorLight,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle, size: 30),
                                  onPressed: () async {
                                    Navigator.of(context).pop(); // Close the current dialog
                                    await PersistentNavBarNavigator.pushNewScreen(
                                      context,
                                      screen: const AddAccountScreen(isCreatingVacationAccount: true),
                                      withNavBar: false,
                                      pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                    );
                                    // Re-show the dialog after returning to refresh the list
                                    if (context.mounted) {
                                       await showVacationDialog(context, isMandatory: isMandatory);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          // Removed currency warning; selection is always allowed
                          // Custom account list with validation
                          Container(
                            constraints: const BoxConstraints(maxHeight: 300),
                            child: ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              itemCount: vacationAccounts.length,
                              itemBuilder: (context, index) {
                                final account = vacationAccounts[index];
                                final isSelected = account == selectedAccount;
                                
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Card(
                                    elevation: isSelected ? 4 : 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24.0),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: isSelected
                                            ? LinearGradient(
                                                colors: [
                                                  AppColors.gradientStart,
                                                  AppColors.gradientEnd,
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              )
                                            : null,
                                        color: isSelected ? null : Colors.white,
                                        borderRadius: BorderRadius.circular(24.0),
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 0.0,
                                        ),
                                        leading: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.credit_card,
                                              color: Theme.of(context).iconTheme.color,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                        ),
                                        title: Text(
                                          account.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            color: isSelected
                                                ? AppColors.primaryTextColorLight
                                                : AppColors.secondaryTextColorLight,
                                          ),
                                        ),
                                        trailing: isSelected
                                            ? Icon(
                                                Icons.check_circle,
                                                color: AppColors.primaryTextColorLight,
                                                size: 24,
                                              )
                                            : null,
                                        onTap: () {
                                          setState(() {
                                            selectedAccount = account;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Action button
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(selectedAccount),
                              child: const Text('Enable Vacation Mode'),
                            ),
                          ),
                        ],
                        );
                      },
                    );
                  }(),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      // Create a slide transition from bottom to top
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1.0), // Start from bottom
          end: Offset.zero, // End at the final position
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        )),
        child: child,
      );
    },
  );

  // If user selected an account, handle it.
  if (result != null && context.mounted) {
    final provider = Provider.of<VacationProvider>(context, listen: false);
    await provider.setActiveVacationAccountId(result.id);
    await provider.setVacationMode(true);

    // Store the current currency before switching to vacation mode for reference
    try {
      final currencyProvider = Provider.of<CurrencyProvider>(context, listen: false);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('preVacationCurrencyCode', currencyProvider.selectedCurrencyCode);
    } catch (e) {
      // Non-fatal: currency storage failed
      // ignore
    }
  }
}