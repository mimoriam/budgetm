import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/models/firestore_account.dart';
import 'package:budgetm/screens/dashboard/navbar/balance/add_account/add_account_screen.dart';
import 'package:budgetm/viewmodels/vacation_mode_provider.dart';
import 'package:budgetm/widgets/pretty_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VacationDialog extends StatefulWidget {
  const VacationDialog({super.key});

  @override
  State<VacationDialog> createState() => _VacationDialogState();
}

class _VacationDialogState extends State<VacationDialog> {
  final FirestoreService _firestoreService = FirestoreService.instance;
  bool _isLoading = true;
  List<FirestoreAccount> _vacationAccounts = [];


  Future<void> _loadVacationAccounts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final all = await _firestoreService.getAllAccounts();
      // Filter accounts marked as vacation accounts.
      final vac = all.where((a) => a.isVacationAccount == true).toList();
      setState(() {
        _vacationAccounts = vac;
      });
    } catch (e) {
      // Fail silently but keep empty list so user can create one.
      debugPrint('Failed to load vacation accounts: $e');
      setState(() {
        _vacationAccounts = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onSelectAccount(FirestoreAccount account) async {
    final provider = Provider.of<VacationProvider>(context, listen: false);
    await provider.setActiveVacationAccountId(account.id);
    await provider.setVacationMode(true);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _onCreateNewVacationAccount() async {
    // Navigate to AddAccountScreen and allow user to create a vacation account.
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddAccountScreen(isCreatingVacationAccount: true),
      ),
    );
    // After returning, reload accounts so user can select the newly created one.
    await _loadVacationAccounts();
  }

  bool _isSheetOpen = false;

  @override
  void initState() {
    super.initState();
    // Load accounts and open the pretty bottom sheet after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSheetFlow();
    });
  }

  Future<void> _showSheetFlow() async {
    await _loadVacationAccounts();
    if (!mounted) return;
    await _openBottomSheet();
  }

  Future<void> _openBottomSheet() async {
    if (_isSheetOpen) return;
    _isSheetOpen = true;
    try {
      while (mounted) {
        final result = await showModalBottomSheet<FirestoreAccount>(
          context: context,
          isDismissible: false,
          enableDrag: false,
          backgroundColor: Colors.transparent,
          builder: (context) {
            // Mirror the PrettyBottomSheet container style when building custom content.
            if (_isLoading) {
              return Container(
                height: 200,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            // If there are no vacation accounts, show a small sheet with a create button.
            if (_vacationAccounts.isEmpty) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 8),
                      width: 40,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text(
                        'Vacation Mode',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('No vacation accounts found. Create one to continue.'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // Push AddAccountScreen on top of the sheet so user can create one.
                              Navigator.of(context)
                                  .push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const AddAccountScreen(isCreatingVacationAccount: true),
                                ),
                              )
                                  .then((_) async {
                                // After returning, reload accounts and close the sheet so
                                // the outer loop can re-open it with fresh data.
                                await _loadVacationAccounts();
                                if (mounted) {
                                  Navigator.of(context).pop();
                                }
                              });
                            },
                            child: const Text('Create Vacation Account'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            }

            // There are vacation accounts — use PrettyBottomSheet to present them.
            final provider = Provider.of<VacationProvider>(context, listen: false);
            final selected = _vacationAccounts.firstWhere(
              (a) => a.id == provider.activeVacationAccountId,
              orElse: () => _vacationAccounts.first,
            );

            return Stack(
              clipBehavior: Clip.none,
              children: [
                PrettyBottomSheet<FirestoreAccount>(
                  title: 'Vacation Mode',
                  items: _vacationAccounts,
                  selectedItem: selected,
                  getDisplayName: (a) => a.name,
                ),
                Positioned(
                  top: 8,
                  right: 12,
                  child: Material(
                    color: Colors.white,
                    elevation: 4,
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        // Navigate to AddAccountScreen to create a new vacation account.
                        Navigator.of(context)
                            .push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const AddAccountScreen(isCreatingVacationAccount: true),
                          ),
                        )
                            .then((_) async {
                          // Reload accounts and close sheet so selection can be shown again.
                          await _loadVacationAccounts();
                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                        });
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        );

        // If user selected an account (PrettyBottomSheet pops with the selected account),
        // handle it and exit the loop. If result is null, likely user created an account
        // while sheet was open; reload and show the sheet again so they can select.
        if (result != null) {
          await _onSelectAccount(result);
          break;
        } else {
          // If we have accounts now, continue to show selection; otherwise wait briefly.
          if (_vacationAccounts.isNotEmpty) {
            // Loop will show sheet again automatically.
            await Future.delayed(const Duration(milliseconds: 100));
          } else {
            await Future.delayed(const Duration(milliseconds: 200));
          }
        }
      }
    } finally {
      _isSheetOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prevent dismissing with back button while dialog is active.
    return WillPopScope(
      onWillPop: () async => false,
      // The actual UI is presented as a modal bottom sheet. Return an empty
      // placeholder here because the sheet is managed in initState.
      child: const SizedBox.shrink(),
    );
  }
}