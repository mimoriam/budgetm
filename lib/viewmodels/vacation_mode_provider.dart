import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/models/firestore_account.dart';
import 'package:budgetm/screens/dashboard/navbar/balance/add_account/add_account_screen.dart';
import 'package:budgetm/screens/dashboard/navbar/home/vacation_dialog.dart';
import 'package:budgetm/viewmodels/navbar_visibility_provider.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
 
class VacationProvider with ChangeNotifier {
  bool _isVacationMode = false;
  bool _isAiMode = false;
  String? _activeVacationAccountId;
 
  bool get isVacationMode => _isVacationMode;
  bool get isAiMode => _isAiMode;
  String? get activeVacationAccountId => _activeVacationAccountId;
 
  VacationProvider() {
    _loadVacationMode();
  }
 
  Future<void> _loadVacationMode() async {
    final prefs = await SharedPreferences.getInstance();
    _isVacationMode = prefs.getBool('vacationMode') ?? false;
    _isAiMode = _isVacationMode; // Sync AI mode on initial load
    _activeVacationAccountId = prefs.getString('activeVacationAccountId');
    notifyListeners();
  }
 
  Future<void> setVacationMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _isVacationMode = value;
    _isAiMode = value;
    await prefs.setBool('vacationMode', _isVacationMode);
    notifyListeners();
  }
 
  Future<void> toggleVacationMode() async {
    final prefs = await SharedPreferences.getInstance();
    _isVacationMode = !_isVacationMode;
    _isAiMode = _isVacationMode; // Keep AI mode in sync with vacation mode
    await prefs.setBool('vacationMode', _isVacationMode);
    // Diagnostic log to observe when vacation mode toggles
    print('Vacation toggled -> $_isVacationMode (isAiMode=$_isAiMode)');
    notifyListeners();
  }
 
  Future<void> setActiveVacationAccountId(String? accountId) async {
    final prefs = await SharedPreferences.getInstance();
    _activeVacationAccountId = accountId;
    if (accountId == null) {
      await prefs.remove('activeVacationAccountId');
    } else {
      await prefs.setString('activeVacationAccountId', accountId);
    }
    notifyListeners();
  }
 
  void toggleAiMode() {
    // This function now correctly serves as an alias for the main toggle
    toggleVacationMode();
  }
 
  /// Checks for vacation accounts and shows the appropriate dialog.
  /// This is the single entry point for the vacation mode flow.
  /// Does not enable vacation mode directly.
  Future<void> checkAndShowVacationDialog(BuildContext context) async {
    final firestoreService = FirestoreService.instance;
    final navbarProvider = Provider.of<NavbarVisibilityProvider>(context, listen: false);
    
    try {
      // Hide the navbar before showing any dialog
      navbarProvider.setNavBarVisibility(false);
      
      final allAccounts = await firestoreService.getAllAccounts();
      final vacationAccounts = allAccounts.where((a) => a.isVacationAccount == true).toList();

      if (!context.mounted) return;

      if (vacationAccounts.isEmpty) {
        // Show a dialog with options to create an account or cancel
        final bool? didRequestCreation = await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Vacation Mode'),
              content: const Text('No vacation accounts created yet.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Create Account'),
                ),
              ],
            );
          },
        );

        // If user requested to create an account, navigate to AddAccountScreen
        if (didRequestCreation == true && context.mounted) {
          await PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: const AddAccountScreen(isCreatingVacationAccount: true),
            withNavBar: false, // This hides the bottom navigation bar
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );

          // After returning from AddAccountScreen, re-fetch accounts
          if (context.mounted) {
            final allAccounts = await firestoreService.getAllAccounts();
            final newVacationAccounts = allAccounts.where((a) => a.isVacationAccount == true).toList();

            // If a new vacation account was created, show the non-dismissible VacationDialog
            if (newVacationAccounts.isNotEmpty) {
              await showVacationDialog(context, isMandatory: true);
            }
          }
        }
      } else {
        // Show the account selection dialog
        await showVacationDialog(context, isMandatory: false);
      }
    } catch (e) {
      // Fail silently, could show a generic error dialog if desired
      print('Error checking for vacation accounts: $e');
    } finally {
      // Always restore navbar visibility, even if an error occurred
      if (context.mounted) {
        navbarProvider.setNavBarVisibility(true);
      }
    }
  }
}