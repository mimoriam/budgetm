import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budgetm/services/firestore_service.dart';
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
    print('DEBUG: Vacation toggled -> $_isVacationMode (isAiMode=$_isAiMode), activeAccountId=$_activeVacationAccountId');
    notifyListeners();
  }
 
  Future<void> setActiveVacationAccountId(String? accountId) async {
    final prefs = await SharedPreferences.getInstance();
    final previousAccountId = _activeVacationAccountId;
    _activeVacationAccountId = accountId;
    if (accountId == null) {
      await prefs.remove('activeVacationAccountId');
    } else {
      await prefs.setString('activeVacationAccountId', accountId);
    }
    print('DEBUG: Vacation account changed from $previousAccountId to $accountId (vacationMode=$_isVacationMode)');
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
      // Enable dialog mode to allow navbar hiding on home screen
      navbarProvider.setDialogMode(true);
      navbarProvider.setNavBarVisibility(false);
      
      final allAccounts = await firestoreService.getAllAccounts();
      final vacationAccounts = allAccounts.where((a) => a.isVacationAccount == true).toList();

      if (!context.mounted) return;

      if (vacationAccounts.isEmpty) {
        // Show a bottom sheet with options to create an account or cancel
        final bool? didRequestCreation = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          builder: (BuildContext context) {
            return _NoVacationAccountSheet(
              onCreateAccount: () => Navigator.of(context).pop(true),
              onCancel: () => Navigator.of(context).pop(false),
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
      // Always restore navbar visibility and disable dialog mode, even if an error occurred
      if (context.mounted) {
        navbarProvider.setNavBarVisibility(true);
        navbarProvider.setDialogMode(false);
      }
    }
  }
}

// A reusable bottom sheet widget for when no vacation account exists.
class _NoVacationAccountSheet extends StatelessWidget {
  const _NoVacationAccountSheet({
    required this.onCreateAccount,
    required this.onCancel,
  });

  final VoidCallback onCreateAccount;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top draggable handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Vacation Mode',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Content
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'No vacation accounts created yet. Create one to start tracking your vacation spending.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          // Primary Action
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: onCreateAccount,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Create Vacation Account'),
            ),
          ),
          SizedBox(height: 32,),
          // Secondary Action
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
          //   child: TextButton(
          //     onPressed: onCancel,
          //     style: TextButton.styleFrom(
          //       minimumSize: const Size(double.infinity, 48),
          //     ),
          //     child: const Text('Cancel'),
          //   ),
          // ),
        ],
      ),
    );
  }
}