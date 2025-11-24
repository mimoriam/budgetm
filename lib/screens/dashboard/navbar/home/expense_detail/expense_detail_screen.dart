import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/generated/i18n/app_localizations.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/models/category.dart';
import 'package:budgetm/models/firestore_account.dart';
import 'package:budgetm/models/firestore_transaction.dart';
import 'package:budgetm/models/transaction.dart';
import 'package:budgetm/models/personal/borrowed.dart';
import 'package:budgetm/models/personal/lent.dart';
import 'package:budgetm/constants/transaction_type_enum.dart';
import 'package:budgetm/viewmodels/vacation_mode_provider.dart';
import 'package:budgetm/viewmodels/goals_provider.dart';
import 'package:budgetm/utils/account_icon_utils.dart';
import 'package:budgetm/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final Transaction transaction;

  const ExpenseDetailScreen({super.key, required this.transaction});

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  late FirestoreService _firestoreService;
  bool _isDeleting = false;
  bool _isUpdating = false;
  late bool _isPaid;
  bool _hasChanges = false;
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService.instance;
    _isPaid = widget.transaction.paid ?? true;
    print(
      'ExpenseDetailScreen.initState: id=${widget.transaction.id}, incomingPaid=${widget.transaction.paid}, resolvedPaid=$_isPaid',
    );
    _dataFuture = _fetchAllData();
  }

  Future<Map<String, dynamic>> _fetchAllData() async {
    try {
      final futures = <Future>[];

      // Fetch the full FirestoreTransaction to get vacation mode and notes
      final firestoreTxnFuture = _firestoreService.getTransactionById(
        widget.transaction.id,
      );
      futures.add(firestoreTxnFuture);

      // Fetch category data
      final categoryFuture = widget.transaction.categoryId != null
          ? _firestoreService.getCategoryById(widget.transaction.categoryId!)
          : Future.value(null);
      futures.add(categoryFuture);

      // Fetch account data
      final accountFuture = widget.transaction.accountId != null
          ? _firestoreService.getAccountById(widget.transaction.accountId!)
          : Future.value(null);
      futures.add(accountFuture);

      // Fetch goal data only for income transactions
      final goalFuture = widget.transaction.type == TransactionType.income
          ? _fetchLinkedGoalName()
          : Future.value(null);
      futures.add(goalFuture);

      final results = await Future.wait(futures);

      final firestoreTxn = results[0] as FirestoreTransaction?;

      // Fetch vacation account for vacation transactions
      FirestoreAccount? vacationAccount;
      if (firestoreTxn != null && firestoreTxn.isVacation) {
        // For vacation transactions, get the vacation account directly
        if (firestoreTxn.linkedVacationAccountId != null) {
          vacationAccount = await _firestoreService.getAccountById(
            firestoreTxn.linkedVacationAccountId!,
          );
        }
      } else if (firestoreTxn != null &&
          !firestoreTxn.isVacation &&
          firestoreTxn.linkedTransactionId != null) {
        // For normal transactions linked to vacation, fetch the vacation transaction to get the vacation account
        final vacationTxn = await _firestoreService.getTransactionById(
          firestoreTxn.linkedTransactionId!,
        );
        if (vacationTxn != null &&
            vacationTxn.linkedVacationAccountId != null) {
          vacationAccount = await _firestoreService.getAccountById(
            vacationTxn.linkedVacationAccountId!,
          );
        }
      }

      // Borrowed/lent items are now independent - no need to fetch them here
      Borrowed? borrowedItem;
      Lent? lentItem;

      return {
        'firestoreTransaction': firestoreTxn,
        'category': results[1] as Category?,
        'account': results[2] as FirestoreAccount?,
        'goalName': results[3] as String?,
        'vacationAccount': vacationAccount,
        'borrowedItem': borrowedItem,
        'lentItem': lentItem,
      };
    } catch (e) {
      print('Error fetching data: $e');
      return {
        'firestoreTransaction': null,
        'category': null,
        'account': null,
        'goalName': null,
        'vacationAccount': null,
        'borrowedItem': null,
        'lentItem': null,
      };
    }
  }

  Future<void> _deleteTransaction() async {
    try {
      setState(() {
        _isDeleting = true;
      });

      // Check if this transaction is linked to a goal before deletion
      final firestoreTxn = await _firestoreService.getTransactionById(
        widget.transaction.id,
      );
      final bool isGoalTransaction =
          firestoreTxn?.goalId != null && firestoreTxn!.goalId!.isNotEmpty;

      // Delete the transaction from Firestore
      await _firestoreService.deleteTransaction(widget.transaction.id);

      // Notify GoalsProvider if this was a goal transaction
      if (isGoalTransaction) {
        Provider.of<GoalsProvider>(
          context,
          listen: false,
        ).notifyGoalTransactionDeleted();
      }
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }

  Future<void> _togglePaidStatus() async {
    if (_isUpdating) return;

    final bool wasPaid =
        _isPaid; // Store the original state for potential rollback

    setState(() {
      _isUpdating = true;
    });

    try {
      print(
        'ExpenseDetailScreen._togglePaidStatus: id=${widget.transaction.id}, currentPaid=$_isPaid, togglingTo=${!_isPaid}',
      );
      await _firestoreService.toggleTransactionPaidStatus(
        widget.transaction.id,
        !_isPaid,
      );

      setState(() {
        _isPaid = !_isPaid;
        _hasChanges = true;
        _isUpdating = false;
      });
    } catch (e) {
      print('Error toggling paid status: $e');

      // Restore the original state in case of error
      if (wasPaid != _isPaid) {
        setState(() {
          _isPaid = wasPaid;
        });
      }

      setState(() {
        _isUpdating = false;
      });

      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.expenseDetailErrorSaving),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<String?> _fetchLinkedGoalName() async {
    try {
      // Only income transactions can contribute to goals
      if (widget.transaction.type != TransactionType.income) {
        return null;
      }
      // Fetch full Firestore transaction to access goalId
      final firestoreTxn = await _firestoreService.getTransactionById(
        widget.transaction.id,
      );
      final String? goalId = firestoreTxn?.goalId;
      if (goalId == null || goalId.isEmpty) {
        return null;
      }
      final goal = await _firestoreService.getGoalById(goalId);
      return goal?.name;
    } catch (e) {
      print('Error fetching linked goal: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_hasChanges ? true : null);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildCustomAppBar(context),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _dataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(AppLocalizations.of(context)!.homeErrorLoadingData),
                    );
                  }

                  final category = snapshot.data?['category'] as Category?;
                  final account =
                      snapshot.data?['account'] as FirestoreAccount?;
                  final goalName = snapshot.data?['goalName'] as String?;
                  final firestoreTransaction =
                      snapshot.data?['firestoreTransaction']
                          as FirestoreTransaction?;
                  final vacationAccount =
                      snapshot.data?['vacationAccount'] as FirestoreAccount?;
                  final borrowedItem =
                      snapshot.data?['borrowedItem'] as Borrowed?;
                  final lentItem = snapshot.data?['lentItem'] as Lent?;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Text(
                                category?.name ?? widget.transaction.title,
                                style: Theme.of(context).textTheme.displayLarge
                                    ?.copyWith(fontSize: 32),
                              ),
                              const SizedBox(height: 8),
                              // Primary account display - handle vacation transactions
                              Consumer<VacationProvider>(
                                builder: (context, vacationProvider, child) {
                                  // For vacation transactions, show normal account if available
                                  if (firestoreTransaction?.isVacation ==
                                      true) {
                                    if (account != null &&
                                        !(account.isDefault ?? false)) {
                                      // Show normal account for vacation transactions with icon
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: HugeIcon(
                                              icon: getAccountIcon(
                                                account.accountType,
                                              )[0][0],
                                              size: 16,
                                              color: AppColors
                                                  .primaryTextColorLight,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "${account.name} - ${account.accountType}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: AppColors
                                                      .secondaryTextColorLight,
                                                ),
                                          ),
                                        ],
                                      );
                                    }
                                    // If no normal account, show nothing at top (vacation account will be shown below)
                                  }
                                  // For normal transactions, show normal account (but hide default cash account)
                                  else if (account != null &&
                                      !(account.isDefault ?? false)) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: HugeIcon(
                                            icon: getAccountIcon(
                                              account.accountType,
                                            )[0][0],
                                            size: 16,
                                            color:
                                                AppColors.primaryTextColorLight,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "${account.name} - ${account.accountType}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: AppColors
                                                    .secondaryTextColorLight,
                                              ),
                                        ),
                                      ],
                                    );
                                  }
                                  // Fallback - no account to display
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            _buildInfoCard(
                              context,
                              AppLocalizations.of(context)!.expenseDetailTotal,
                              formatCurrency(widget.transaction.amount, widget.transaction.currency),
                            ),
                            const SizedBox(width: 16),
                            _buildInfoCard(
                              context,
                              AppLocalizations.of(context)!.expenseDetailAccumulatedAmount,
                              !_isPaid
                                  ? formatCurrency(0.0, widget.transaction.currency)
                                  : formatCurrency(widget.transaction.amount, widget.transaction.currency),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Show borrowed/lent-specific status or paid/unpaid status for regular transactions
                        if (borrowedItem != null)
                          Column(
                            children: [
                              Center(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.0),
                                    color: borrowedItem.returned
                                        ? const Color(0xFF2ECC71)
                                        : const Color(0xFFE74C3C),
                                  ),
                                  child: Text(
                                    borrowedItem.returned
                                        ? 'RETURNED'
                                        : 'BORROWED',
                                    key: const Key('borrowed-status-chip'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Divider(color: Colors.grey.shade300),
                            ],
                          )
                        else if (lentItem != null)
                          Column(
                            children: [
                              Center(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.0),
                                    color: lentItem.returned
                                        ? const Color(0xFF2ECC71)
                                        : const Color(0xFFE74C3C),
                                  ),
                                  child: Text(
                                    lentItem.returned ? 'RETURNED' : 'LENT',
                                    key: const Key('lent-status-chip'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Divider(color: Colors.grey.shade300),
                            ],
                          )
                        else
                          Column(
                            children: [
                              Center(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.0),
                                    color: _isPaid
                                        ? const Color(0xFF2ECC71)
                                        : const Color(0xFFE74C3C),
                                  ),
                                  child: Text(
                                    _isPaid ? 'PAID' : 'UNPAID',
                                    key: const Key('expense-status-chip'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Divider(color: Colors.grey.shade300),
                            ],
                          ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.date,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.secondaryTextColorLight,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              DateFormat(
                                'MMMM d, yyyy, hh:mm a',
                              ).format(widget.transaction.date).toUpperCase(),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(color: Colors.grey.shade300),
                        const SizedBox(height: 16),

                        // Borrowed/Lent-specific information
                        if (borrowedItem != null) ...[
                          // Due Date
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'DUE DATE',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.secondaryTextColorLight,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                DateFormat(
                                  'MMMM d, yyyy',
                                ).format(borrowedItem.dueDate).toUpperCase(),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(color: Colors.grey.shade300),
                          const SizedBox(height: 16),

                          // Borrowed Notes (if available from borrowed item or transaction)
                          if ((borrowedItem.description != null &&
                                  borrowedItem.description!.isNotEmpty) ||
                              (firestoreTransaction?.notes != null &&
                                  firestoreTransaction!.notes!.isNotEmpty))
                            Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'NOTES',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors
                                                .secondaryTextColorLight,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                        child: Text(
                                          // Show borrowed item description first, then transaction notes if available
                                          (borrowedItem.description != null &&
                                                  borrowedItem
                                                      .description!
                                                      .isNotEmpty)
                                              ? borrowedItem.description!
                                              : firestoreTransaction?.notes ??
                                                    '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(color: Colors.black87),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Divider(color: Colors.grey.shade300),
                              ],
                            ),
                        ] else if (lentItem != null) ...[
                          // Due Date
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'DUE DATE',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.secondaryTextColorLight,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                DateFormat(
                                  'MMMM d, yyyy',
                                ).format(lentItem.dueDate).toUpperCase(),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(color: Colors.grey.shade300),
                          const SizedBox(height: 16),

                          // Lent Notes (if available from lent item or transaction)
                          if ((lentItem.description != null &&
                                  lentItem.description!.isNotEmpty) ||
                              (firestoreTransaction?.notes != null &&
                                  firestoreTransaction!.notes!.isNotEmpty))
                            Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'NOTES',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors
                                                .secondaryTextColorLight,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                        child: Text(
                                          // Show lent item description first, then transaction notes if available
                                          (lentItem.description != null &&
                                                  lentItem
                                                      .description!
                                                      .isNotEmpty)
                                              ? lentItem.description!
                                              : firestoreTransaction?.notes ??
                                                    '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(color: Colors.black87),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Divider(color: Colors.grey.shade300),
                              ],
                            ),
                        ],

                        if (goalName != null && goalName.isNotEmpty)
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'GOAL',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color:
                                              AppColors.secondaryTextColorLight,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    goalName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),
                              Divider(color: Colors.grey.shade300),
                            ],
                          ),

                        // Vacation account information for vacation transactions (with or without normal account) or vacation-linked transactions
                        if (vacationAccount != null &&
                            (firestoreTransaction?.isVacation == true ||
                                (firestoreTransaction?.isVacation == false &&
                                    firestoreTransaction?.linkedTransactionId !=
                                        null)))
                          Column(
                            children: [
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.expenseDetailVacation,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color:
                                              AppColors.secondaryTextColorLight,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Flexible(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: HugeIcon(
                                            icon: HugeIcons
                                                .strokeRoundedAirplaneMode,
                                            size: 16,
                                            color: Colors.blue.shade600,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                vacationAccount.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                textAlign: TextAlign.right,
                                              ),
                                              // Text(
                                              //   vacationAccount.accountType,
                                              //   style: Theme.of(context).textTheme.bodySmall
                                              //       ?.copyWith(color: Colors.grey.shade600),
                                              //   textAlign: TextAlign.right,
                                              // ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Divider(color: Colors.grey.shade300),
                            ],
                          ),

                        // Transaction Notes (only for non-borrowed/lent transactions)
                        if (borrowedItem == null &&
                            lentItem == null &&
                            firestoreTransaction?.notes != null &&
                            firestoreTransaction!.notes!.isNotEmpty)
                          Column(
                            children: [
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'NOTES',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color:
                                              AppColors.secondaryTextColorLight,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      child: Text(
                                        firestoreTransaction.notes!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: Colors.black87),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Divider(color: Colors.grey.shade300),
                            ],
                          ),

                        const SizedBox(height: 40),
                        Row(
                          children: [
                            // Show paid/unpaid toggle for all transactions
                            Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                child: OutlinedButton(
                                  onPressed: _isUpdating
                                      ? null
                                      : _togglePaidStatus,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    side: BorderSide(
                                      color: _isPaid
                                          ? Colors.red
                                          : Colors.green,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: _isUpdating
                                        ? const SizedBox(
                                            key: ValueKey('loading'),
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.grey,
                                                  ),
                                            ),
                                          )
                                        : Text(
                                            key: ValueKey(
                                              _isPaid ? 'paid' : 'unpaid',
                                            ),
                                            _isPaid
                                                ? AppLocalizations.of(context)!.expenseDetailMarkUnpaid
                                                : AppLocalizations.of(context)!.expenseDetailMarkPaid,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge
                                                ?.copyWith(
                                                  color: _isPaid
                                                      ? Colors.red
                                                      : Colors.green,
                                                  fontSize: 14,
                                                ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isDeleting
                                    ? null
                                    : () async {
                                        // Show confirmation dialog before deleting
                                        final bool?
                                        shouldDelete = await showDialog<bool>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text(
                                                'Delete Transaction',
                                              ),
                                              content: const Text(
                                                'Are you sure you want to delete this transaction? This action cannot be undone.',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(
                                                    context,
                                                  ).pop(false),
                                                  child: Text(AppLocalizations.of(context)!.cancel),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(
                                                    context,
                                                  ).pop(true),
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: Colors.red,
                                                  ),
                                                  child: Text(AppLocalizations.of(context)!.delete),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        // Only proceed with deletion if user confirmed
                                        if (shouldDelete == true) {
                                          await _deleteTransaction();
                                          // Navigate back to the previous screen
                                          if (context.mounted) {
                                            Navigator.of(context).pop(true);
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                child: _isDeleting
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        AppLocalizations.of(context)!.delete,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String amount) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryTextColorLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.primaryTextColorLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get currency code (return as-is)
  String _getCurrencyCode(String currencyCode) {
    return currencyCode;
  }

  Widget _buildCustomAppBar(BuildContext context) {
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4),
          child: Row(
            children: [
              GestureDetector(
                onTap: () =>
                    Navigator.of(context).pop(_hasChanges ? true : null),
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
                'Home',
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
}
