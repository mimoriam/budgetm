import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/models/firestore_account.dart';
import 'package:budgetm/viewmodels/vacation_mode_provider.dart';
import 'package:budgetm/widgets/pretty_bottom_sheet.dart';
import 'package:budgetm/screens/dashboard/navbar/balance/add_account/add_account_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

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
                : PrettyBottomSheet<FirestoreAccount>(
                   title: 'Vacation Mode',
                   items: vacationAccounts,
                   selectedItem: vacationAccounts.first,
                   getDisplayName: (a) => a.name,
                   getLeading: (a) => Row(
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
                   actionButton: IconButton(
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
                 ),
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
  }
}