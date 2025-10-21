import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:budgetm/models/firestore_transaction.dart';
import 'package:budgetm/models/category.dart';
import 'package:budgetm/models/firestore_account.dart';
import 'package:budgetm/models/firestore_task.dart';
import 'package:budgetm/models/budget.dart';
import 'package:budgetm/models/goal.dart';
import 'package:budgetm/data/local/category_initializer.dart';

class FirestoreService {
  static FirestoreService? _instance;
  static FirestoreService get instance {
    _instance ??= FirestoreService._internal();
    return _instance!;
  }

  // Stream all transactions filtered by currency across all time.
  // Applies vacation/account filters when provided. Results are ordered by date desc.
  Stream<List<FirestoreTransaction>> streamTransactionsByCurrency(
    String currencyCode, {
    String? accountId,
    bool isVacation = false,
  }) {
    try {
      print('DEBUG: streamTransactionsByCurrency - currency=$currencyCode, isVacation=$isVacation, accountId=$accountId');

      Query<FirestoreTransaction> query = _transactionsCollection
          .where('currency', isEqualTo: currencyCode)
          .where('isVacation', isEqualTo: isVacation);

      if (accountId != null) {
        query = query.where('accountId', isEqualTo: accountId);
        print('DEBUG: streamTransactionsByCurrency - Applied accountId filter: $accountId');
      }

      return query
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
            final transactions = snapshot.docs.map((doc) => doc.data()).toList();
            print('DEBUG: streamTransactionsByCurrency - fetched ${transactions.length} tx for currency=$currencyCode');
            if (transactions.isNotEmpty) {
              final txIds = transactions.map((tx) => tx.id).take(6).join(', ');
              print('DEBUG: streamTransactionsByCurrency - sample ids: $txIds');
            }
            return transactions;
          });
    } catch (e) {
      print('Error streaming transactions by currency: $e');
      return Stream.empty();
    }
  }

  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Collection references (user-scoped for security)
  CollectionReference<FirestoreTransaction> get _transactionsCollection {
    if (_userId == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(_userId!)
        .collection('transactions')
        .withConverter<FirestoreTransaction>(
          fromFirestore: (snapshot, _) => FirestoreTransaction.fromFirestore(snapshot.data()!, snapshot.id),
          toFirestore: (transaction, _) => transaction.toJson() as Map<String, Object?>,
        );
  }

  CollectionReference<Category> get _categoriesCollection {
    if (_userId == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(_userId!)
        .collection('categories')
        .withConverter<Category>(
          fromFirestore: (snapshot, _) => Category.fromFirestore(snapshot),
          toFirestore: (category, _) => category.toJson(),
        );
  }

  CollectionReference<Budget> get _budgetsCollection {
    if (_userId == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(_userId!)
        .collection('budgets')
        .withConverter<Budget>(
          fromFirestore: (snapshot, _) => Budget.fromFirestore(snapshot),
          toFirestore: (budget, _) => budget.toJson(),
        );
  }

  CollectionReference<FirestoreGoal> get _goalsCollection {
    if (_userId == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(_userId!)
        .collection('goals')
        .withConverter<FirestoreGoal>(
          fromFirestore: (snapshot, _) => FirestoreGoal.fromFirestore(snapshot),
          toFirestore: (goal, _) => goal.toJson(),
        );
  }

  // Create a new budget
  Future<String> createBudget(Budget budget) async {
    try {
      final docRef = await _budgetsCollection.add(budget);
      return docRef.id;
    } catch (e) {
      print('Error creating budget: $e');
      rethrow;
    }
  }

  // Create or set a budget with a specific ID (used when creating a budget tied to a category)
  Future<void> addBudget(Budget budget) async {
    try {
      print('FirestoreService.addBudget: adding budget id=${budget.id} category=${budget.categoryId} type=${budget.type} year=${budget.year} period=${budget.period} limit=${budget.limit}');
      await _budgetsCollection.doc(budget.id).set(budget);
      print('FirestoreService.addBudget: successfully wrote budget id=${budget.id}');
    } catch (e) {
      print('Error adding budget with id: $e');
      rethrow;
    }
  }

  // Create vacation budgets for all expense categories
  Future<void> createVacationBudgetsForAllExpenseCategories({
    required String currency,
    BudgetType type = BudgetType.monthly
  }) async {
    try {
      // Get all expense categories
      final expenseCategories = await getCategoriesByType('expense');
      print('createVacationBudgetsForAllExpenseCategories: expenseCategories=${expenseCategories.length}');
      
      // Get current date to determine year and period
      final now = DateTime.now();
      final year = now.year;
      int period;
      
      switch (type) {
        case BudgetType.weekly:
          final weekOfMonth = Budget.getWeekOfMonth(now);
          final encoded = (now.month * 10) + weekOfMonth;
          period = encoded;
          break;
        case BudgetType.monthly:
          period = now.month;
          break;
        case BudgetType.yearly:
          period = 1; // For yearly, period is always 1
          break;
      }
      print('createVacationBudgetsForAllExpenseCategories: type=$type year=$year period=$period currency=$currency');
      
      // Get existing vacation budgets for the current period to avoid duplicates
      final existingVacationBudgets = await getBudgetsByType(type, isVacation: true);
      final existingBudgetCategoryIds = existingVacationBudgets
          .where((budget) => budget.year == year && budget.period == period)
          .map((budget) => budget.categoryId)
          .toSet();
      print('createVacationBudgetsForAllExpenseCategories: existingVacationBudgets=${existingVacationBudgets.length} existingCategoryIds=${existingBudgetCategoryIds.length}');
      
      // Get current user ID
      if (_userId == null) {
        throw Exception('User not authenticated');
      }
      
      // Create budgets for expense categories that don't have vacation budgets yet
      for (final category in expenseCategories) {
        if (!existingBudgetCategoryIds.contains(category.id)) {
          // Generate a unique ID for the budget
          final budgetId = Budget.generateId(_userId!, category.id, type, year, period, true, false, currency: currency);
          
          // Get date range for the budget
          final dateRange = Budget.getDateRange(type, year, period);
          
          // Create the new budget with limit = 0.0 and isVacation = true
          final newBudget = Budget(
            id: budgetId,
            categoryId: category.id,
            limit: 0.0,
            type: type,
            year: year,
            period: period,
            startDate: dateRange['startDate']!,
            endDate: dateRange['endDate']!,
            userId: _userId!,
            currency: currency,
            isVacation: true,
          );
          
          // Add the budget to Firestore
          await addBudget(newBudget);
          print('Created vacation budget for category: ${category.name}');
        }
      }
      
      print('Successfully created vacation budgets for all expense categories');
    } catch (e) {
      print('Error creating vacation budgets for all expense categories: $e');
      rethrow;
    }
  }

  // Stream budgets (real-time) - for a specific budget type
  Stream<List<Budget>> streamBudgets({BudgetType? type, bool? isVacation}) {
    try {
      Query<Budget> query = _budgetsCollection;
      
      if (type != null) {
        query = query.where('type', isEqualTo: type.toString().split('.').last);
      }
      
      if (isVacation != null) {
        query = query.where('isVacation', isEqualTo: isVacation);
      }
      
      return query
          .snapshots()
          .map((snapshot) => snapshot.docs.map((d) => d.data()).toList());
    } catch (e) {
      print('Error streaming budgets: $e');
      return Stream.empty();
    }
  }

  // Get all budgets
  Future<List<Budget>> getAllBudgets({bool? isVacation}) async {
    try {
      Query<Budget> query = _budgetsCollection;
      
      if (isVacation != null) {
        query = query.where('isVacation', isEqualTo: isVacation);
      }
      
      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting all budgets: $e');
      return [];
    }
  }

  // Get all vacation budgets for all time
  Future<List<Budget>> getAllVacationBudgets({String? vacationAccountId}) async {
    try {
      Query<Budget> query = _budgetsCollection
          .where('isVacation', isEqualTo: true);
      
      // Add vacationAccountId filter if provided
      if (vacationAccountId != null) {
        query = query.where('vacationAccountId', isEqualTo: vacationAccountId);
      }
      
      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting all vacation budgets: $e');
      return [];
    }
  }

  // Get budgets by type
  Future<List<Budget>> getBudgetsByType(BudgetType type, {bool? isVacation}) async {
    try {
      Query<Budget> query = _budgetsCollection
          .where('type', isEqualTo: type.toString().split('.').last);
      
      if (isVacation != null) {
        query = query.where('isVacation', isEqualTo: isVacation);
      }
      
      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting budgets by type: $e');
      return [];
    }
  }

  Future<Budget?> getBudgetById(String id) async {
    try {
      final doc = await _budgetsCollection.doc(id).get();
      return doc.data();
    } catch (e) {
      print('Error getting budget: $e');
      return null;
    }
  }

  Future<void> updateBudget(String id, Budget budget) async {
    try {
      await _budgetsCollection.doc(id).update(budget.toJson());
    } catch (e) {
      print('Error updating budget: $e');
      rethrow;
    }
  }

  Future<void> deleteBudget(String id, {bool cascadeDelete = false}) async {
    try {
      if (cascadeDelete) {
        // Get the budget to determine its category and date range
        final budgetDoc = await _budgetsCollection.doc(id).get();
        if (!budgetDoc.exists) {
          throw Exception('Budget not found');
        }
        final budget = budgetDoc.data()!;
        
        // Find all transactions associated with this budget's category within the date range
        final transactionsQuery = await _transactionsCollection
            .where('categoryId', isEqualTo: budget.categoryId)
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(budget.startDate))
            .where('date', isLessThanOrEqualTo: Timestamp.fromDate(budget.endDate))
            .get();
        
        // If there are transactions, delete them in a batch
        if (transactionsQuery.docs.isNotEmpty) {
          final batch = _firestore.batch();
          for (final doc in transactionsQuery.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
          print('Deleted ${transactionsQuery.docs.length} transactions associated with budget $id');
        }
      }
      
      // Finally, delete the budget document
      await _budgetsCollection.doc(id).delete();
      print('Budget $id deleted successfully');
    } catch (e) {
      print('Error deleting budget: $e');
      rethrow;
    }
  }

  // ================ GOAL OPERATIONS ================

  // Create a new goal
  Future<void> createGoal(FirestoreGoal goal) async {
    try {
      await _goalsCollection.add(goal);
    } catch (e) {
      print('Error creating goal: $e');
      rethrow;
    }
  }

  // Stream goals (real-time updates)
  Stream<List<FirestoreGoal>> getGoals() {
    try {
      return _goalsCollection
          .orderBy('creationDate', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      print('Error streaming goals: $e');
      return Stream.empty();
    }
  }

  // Update goal
  Future<void> updateGoal(String goalId, FirestoreGoal goal) async {
    try {
      await _goalsCollection.doc(goalId).update(goal.toJson());
    } catch (e) {
      print('Error updating goal: $e');
      rethrow;
    }
  }

  // Delete goal
  Future<void> deleteGoal(String goalId, {bool cascadeDelete = false}) async {
    try {
      if (cascadeDelete) {
        // Find all transactions associated with this goal
        final transactionsQuery = await _transactionsCollection
            .where('goalId', isEqualTo: goalId)
            .get();
        
        // If there are transactions, delete them in a batch
        if (transactionsQuery.docs.isNotEmpty) {
          final batch = _firestore.batch();
          for (final doc in transactionsQuery.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
          print('Deleted ${transactionsQuery.docs.length} transactions associated with goal $goalId');
        }
      } else {
        // Non-cascade: Update transactions to remove the goalId
        final transactionsQuery = await _transactionsCollection
            .where('goalId', isEqualTo: goalId)
            .get();
        
        if (transactionsQuery.docs.isNotEmpty) {
          final batch = _firestore.batch();
          for (final doc in transactionsQuery.docs) {
            batch.update(doc.reference, {'goalId': null});
          }
          await batch.commit();
          print('Disassociated ${transactionsQuery.docs.length} transactions from goal $goalId');
        }
      }
      
      // Finally, delete the goal document
      await _goalsCollection.doc(goalId).delete();
      print('Goal $goalId deleted successfully');
    } catch (e) {
      print('Error deleting goal: $e');
      rethrow;
    }
  }

  // Get goal by ID
  Future<FirestoreGoal?> getGoalById(String goalId) async {
    try {
      final doc = await _goalsCollection.doc(goalId).get();
      return doc.data();
    } catch (e) {
      print('Error getting goal: $e');
      return null;
    }
  }

  // Stream transactions associated with a goal
  Stream<List<FirestoreTransaction>> getTransactionsForGoal(String goalId) {
    try {
      return _transactionsCollection
          .where('goalId', isEqualTo: goalId)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      print('Error streaming transactions for goal: $e');
      return Stream.empty();
    }
  }

  CollectionReference<FirestoreAccount> get _accountsCollection {
    if (_userId == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(_userId!)
        .collection('accounts')
        .withConverter<FirestoreAccount>(
          fromFirestore: (snapshot, _) => FirestoreAccount.fromFirestore(snapshot),
          // Cast to the exact Map type expected by the Firestore API to avoid runtime type errors
          toFirestore: (account, _) => account.toJson() as Map<String, Object?>,
        );
  }

  CollectionReference<FirestoreTask> get _tasksCollection {
    if (_userId == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(_userId!)
        .collection('tasks')
        .withConverter<FirestoreTask>(
          fromFirestore: (snapshot, _) => FirestoreTask.fromFirestore(snapshot),
          toFirestore: (task, _) => task.toJson(),
        );
  }

  // ================ TRANSACTION OPERATIONS ================

  // Create a new transaction (accepts optional vacation flag)
  Future<String> createTransaction(FirestoreTransaction transaction, {bool isVacation = false}) async {
    try {
      final toSave = transaction.copyWith(isVacation: isVacation);
      final docRef = await _transactionsCollection.add(toSave);
      return docRef.id;
    } catch (e) {
      print('Error creating transaction: $e');
      rethrow;
    }
  }

  // Create linked vacation expense transaction with a normal account transaction
  Future<Map<String, String>> createLinkedVacationExpense({
    required FirestoreTransaction vacationTransaction,
    required FirestoreTransaction normalTransaction,
  }) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        // 1. Get new document references for both transactions (no writes yet)
        final vacationRef = _transactionsCollection.doc();
        final normalRef = _transactionsCollection.doc();

        // 2. Create the final transaction objects with linked IDs (pure local computation)
        final finalVacationTransaction = vacationTransaction.copyWith(
          id: vacationRef.id,
          isVacation: true,
          linkedTransactionId: normalRef.id,
        );

        final finalNormalTransaction = normalTransaction.copyWith(
          id: normalRef.id,
          isVacation: false,
          linkedTransactionId: vacationRef.id,
        );

        // DEBUG: prepared linked transactions
        print('DEBUG: createLinkedVacationExpense - prepared finalVacationTxn: id=${finalVacationTransaction.id}, accountId=${finalVacationTransaction.accountId}, date=${finalVacationTransaction.date.toIso8601String()}, amount=${finalVacationTransaction.amount}, linkedId=${finalVacationTransaction.linkedTransactionId}');
        print('DEBUG: createLinkedVacationExpense - prepared finalNormalTxn: id=${finalNormalTransaction.id}, accountId=${finalNormalTransaction.accountId}, date=${finalNormalTransaction.date.toIso8601String()}, amount=${finalNormalTransaction.amount}, linkedId=${finalNormalTransaction.linkedTransactionId}');

        // 3. READS: Fetch the vacation and normal account documents BEFORE any writes
        final vacationAccountRef = _accountsCollection.doc(finalVacationTransaction.accountId);
        final normalAccountRef = _accountsCollection.doc(finalNormalTransaction.accountId);

        final vacationAccountSnapshot = await transaction.get(vacationAccountRef);
        final normalAccountSnapshot = await transaction.get(normalAccountRef);

        if (!vacationAccountSnapshot.exists) {
          throw Exception('Vacation account does not exist');
        }
        if (!normalAccountSnapshot.exists) {
          throw Exception('Normal account does not exist');
        }

        // 4. Compute new balances
        final vacationAccount = vacationAccountSnapshot.data()!;
        final normalAccount = normalAccountSnapshot.data()!;
        final amount = vacationTransaction.amount;

        // For expenses, subtract from both account balances
        final newVacationBalance = vacationAccount.balance - amount;
        final newNormalBalance = normalAccount.balance - amount;

        // 5. WRITES: Create both transaction documents
        transaction.set(vacationRef, finalVacationTransaction);
        transaction.set(normalRef, finalNormalTransaction);

        // 6. WRITES: Update both account balances
        transaction.update(vacationAccountRef, {'balance': newVacationBalance});
        transaction.update(normalAccountRef, {'balance': newNormalBalance});

        // DEBUG: wrote docs and updated balances
        print('DEBUG: createLinkedVacationExpense - wrote txns and updated balances: vacationAcc=${vacationAccountRef.id} newBalance=$newVacationBalance, normalAcc=${normalAccountRef.id} newBalance=$newNormalBalance');

        // 7. Return both IDs
        print('DEBUG: createLinkedVacationExpense - returning ids: vacation=${vacationRef.id}, normal=${normalRef.id}');
        return {
          'vacationTransactionId': vacationRef.id,
          'normalTransactionId': normalRef.id,
        };
      });
    } catch (e) {
      print('Error creating linked vacation expense: $e');
      rethrow;
    }
  }

  // Get transaction by ID
  Future<FirestoreTransaction?> getTransactionById(String id) async {
    try {
      final doc = await _transactionsCollection.doc(id).get();
      return doc.data();
    } catch (e) {
      print('Error getting transaction: $e');
      return null;
    }
  }

  // Get all transactions (optionally filtered by vacation mode)
  Future<List<FirestoreTransaction>> getAllTransactions({bool isVacation = false, String? vacationAccountId}) async {
    try {
      Query<FirestoreTransaction> query = _transactionsCollection.where('isVacation', isEqualTo: isVacation);
      
      // Add vacationAccountId filter if provided
      if (vacationAccountId != null) {
        query = query.where('vacationAccountId', isEqualTo: vacationAccountId);
      }
      
      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }

  // Get transactions for a date range (optionally filtered by vacation mode)
  Future<List<FirestoreTransaction>> getTransactionsForDateRange(
    DateTime startDate,
    DateTime endDate, {
    bool isVacation = false,
  }) async {
    try {
      final query = _transactionsCollection
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .where('isVacation', isEqualTo: isVacation)
          .orderBy('date', descending: true);
      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting transactions for date range: $e');
      return [];
    }
  }

  // Get transactions by type
  Future<List<FirestoreTransaction>> getTransactionsByType(String type) async {
    try {
      final querySnapshot = await _transactionsCollection
          .where('type', isEqualTo: type)
          .orderBy('date', descending: true)
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting transactions by type: $e');
      return [];
    }
  }

  // Update transaction
  Future<void> updateTransaction(String transactionId, Map<String, dynamic> data) async {
    try {
      await _transactionsCollection.doc(transactionId).update(data);
    } catch (e) {
      print('Error updating transaction: $e');
      rethrow;
    }
  }
  // Update transaction with a FirestoreTransaction object
  Future<void> updateTransactionObject(String transactionId, FirestoreTransaction transaction) async {
    try {
      await _transactionsCollection.doc(transactionId).update(transaction.toJson());
    } catch (e) {
      print('Error updating transaction: $e');
      rethrow;
    }
  }

  // Delete transaction
  Future<void> deleteTransaction(String id) async {
    try {
      final transactionDocRef = _transactionsCollection.doc(id);

      await _firestore.runTransaction((transaction) async {
        // 1. Get the transaction document
        final transactionSnapshot = await transaction.get(transactionDocRef);
        if (!transactionSnapshot.exists) {
          throw Exception("Transaction does not exist!");
        }
        final transactionData = transactionSnapshot.data()!;
        final accountId = transactionData.accountId;
        final linkedTransactionId = transactionData.linkedTransactionId;

        // Handle linked transaction cascade deletion
        if (linkedTransactionId != null && linkedTransactionId.isNotEmpty) {
          // Get the linked transaction (READ)
          final linkedTransactionRef = _transactionsCollection.doc(linkedTransactionId);
          final linkedTransactionSnapshot = await transaction.get(linkedTransactionRef);
          
          if (!linkedTransactionSnapshot.exists) {
            throw Exception("Linked transaction does not exist!");
          }
          final linkedTransactionData = linkedTransactionSnapshot.data()!;

          // READS: Pre-fetch both accounts (original and linked) BEFORE any writes
          DocumentReference<FirestoreAccount>? accountDocRef1;
          DocumentSnapshot<FirestoreAccount>? accountSnap1;
          if (accountId != null && accountId.isNotEmpty) {
            accountDocRef1 = _accountsCollection.doc(accountId);
            accountSnap1 = await transaction.get(accountDocRef1);
          }

          final String? linkedAccountId = linkedTransactionData.accountId;
          DocumentReference<FirestoreAccount>? accountDocRef2;
          DocumentSnapshot<FirestoreAccount>? accountSnap2;
          if (linkedAccountId != null && linkedAccountId.isNotEmpty) {
            accountDocRef2 = _accountsCollection.doc(linkedAccountId);
            accountSnap2 = await transaction.get(accountDocRef2);
          }

          // WRITES: Update account balances (reverse both transactions) AFTER all reads
          if (accountDocRef1 != null && accountSnap1 != null && accountSnap1.exists) {
            final double currentBalance1 = accountSnap1.data()!.balance;
            final double transactionAmount1 = transactionData.amount;
            final String transactionType1 = transactionData.type;
            final double newBalance1 = (transactionType1 == 'income')
                ? currentBalance1 - transactionAmount1
                : currentBalance1 + transactionAmount1;
            transaction.update(accountDocRef1, {'balance': newBalance1});
          }

          if (accountDocRef2 != null && accountSnap2 != null && accountSnap2.exists) {
            final double currentBalance2 = accountSnap2.data()!.balance;
            final double transactionAmount2 = linkedTransactionData.amount;
            final String transactionType2 = linkedTransactionData.type;
            final double newBalance2 = (transactionType2 == 'income')
                ? currentBalance2 - transactionAmount2
                : currentBalance2 + transactionAmount2;
            transaction.update(accountDocRef2, {'balance': newBalance2});
          }

          // WRITES: Delete both transaction documents
          transaction.delete(transactionDocRef);
          transaction.delete(linkedTransactionRef);
        } else {
          // Single transaction deletion (existing logic)
          DocumentReference<FirestoreAccount>? accountDocRef;
          DocumentSnapshot<FirestoreAccount>? accountSnapshot;
          if (accountId != null && accountId.isNotEmpty) {
            accountDocRef = _accountsCollection.doc(accountId);
            accountSnapshot = await transaction.get(accountDocRef);
          }

          // If no account is linked or account doesn't exist, delete the transaction
          if (accountId == null || accountId.isEmpty || accountSnapshot == null || !accountSnapshot.exists) {
            transaction.delete(transactionDocRef);
            return;
          }

          // Update account balance
          final currentBalance = accountSnapshot.data()!.balance;
          final transactionAmount = transactionData.amount;
          final transactionType = transactionData.type;

          final newBalance = (transactionType == 'income') ? currentBalance - transactionAmount : currentBalance + transactionAmount;

          transaction.update(accountDocRef!, {'balance': newBalance});

          // Finally delete the transaction
          transaction.delete(transactionDocRef);
        }
      });
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    }
  }

  // Helper method to process account balance reversal for a transaction
  Future<void> _processAccountBalanceReversal(
    Transaction transaction,
    FirestoreTransaction transactionData,
    String? accountId,
  ) async {
    if (accountId == null || accountId.isEmpty) {
      return;
    }

    final accountDocRef = _accountsCollection.doc(accountId);
    final accountSnapshot = await transaction.get(accountDocRef);

    if (!accountSnapshot.exists) {
      return;
    }

    // Update account balance (reverse the original transaction)
    final currentBalance = accountSnapshot.data()!.balance;
    final transactionAmount = transactionData.amount;
    final transactionType = transactionData.type;

    // For deletion, we reverse the original balance change
    // Income: subtract the amount (since original added it)
    // Expense: add the amount (since original subtracted it)
    final newBalance = (transactionType == 'income')
        ? currentBalance - transactionAmount
        : currentBalance + transactionAmount;

    transaction.update(accountDocRef, {'balance': newBalance});
  }

  // Stream transactions (real-time updates)
  Stream<List<FirestoreTransaction>> streamTransactions({String? vacationAccountId}) {
    try {
      Query<FirestoreTransaction> query = _transactionsCollection
          .orderBy('date', descending: true);
      
      // Add vacationAccountId filter if provided
      if (vacationAccountId != null) {
        query = query.where('vacationAccountId', isEqualTo: vacationAccountId);
      }
      
      return query
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      print('Error streaming transactions: $e');
      return Stream.empty();
    }
  }

  // Stream transactions for a date range (optionally filtered by vacation mode and accountId)
  Stream<List<FirestoreTransaction>> streamTransactionsForDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? accountId,
    bool isVacation = false,
  }) {
    try {
      print('DEBUG: streamTransactionsForDateRange - startDate=$startDate, endDate=$endDate, isVacation=$isVacation, accountId=$accountId');
      
      Query<FirestoreTransaction> query = _transactionsCollection
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .where('isVacation', isEqualTo: isVacation);
      
      // Add accountId filter if provided
      if (accountId != null) {
        query = query.where('accountId', isEqualTo: accountId);
        print('DEBUG: Applied accountId filter: $accountId');
      }
      
      return query
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
            final transactions = snapshot.docs.map((doc) => doc.data()).toList();
            print('DEBUG: Fetched ${transactions.length} transactions for isVacation=$isVacation, accountId=$accountId');
            // Log transaction IDs for debugging
            if (transactions.isNotEmpty) {
              final txIds = transactions.map((tx) => '${tx.id}(acc:${tx.accountId})').take(5).join(', ');
              print('DEBUG: Sample transaction IDs: $txIds${transactions.length > 5 ? '...' : ''}');
            }
            return transactions;
          });
    } catch (e) {
      print('Error streaming transactions for date range: $e');
      return Stream.empty();
    }
  }

  // Calculate total amount of transactions for a specific account
  Future<double> getTransactionsAmountForAccount(String accountId) async {
    double totalAmount = 0.0;
    try {
      final querySnapshot = await _transactionsCollection
          .where('accountId', isEqualTo: accountId)
          .get();

      for (final doc in querySnapshot.docs) {
        final transaction = doc.data();
        if (transaction.type == 'income') {
          totalAmount += transaction.amount;
        } else {
          totalAmount -= transaction.amount;
        }
      }
    } catch (e) {
      print('Error getting transactions amount for account: $e');
    }
    return totalAmount;
  }

  // Get all transactions for a specific account
  Future<List<FirestoreTransaction>> getTransactionsForAccount(String accountId) async {
    try {
      final querySnapshot = await _transactionsCollection
          .where('accountId', isEqualTo: accountId)
          .orderBy('date', descending: true)
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting transactions for account: $e');
      return [];
    }
  }

  // Stream transactions for a specific account (real-time updates)
  Stream<List<FirestoreTransaction>> getTransactionsForAccountStream(String accountId) {
    try {
      return _transactionsCollection
          .where('accountId', isEqualTo: accountId)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      print('Error streaming transactions for account: $e');
      return Stream.empty();
    }
  }

  // ================ CATEGORY OPERATIONS ================

  // Create a new category
  Future<String> createCategory(Category category) async {
    try {
      final docRef = await _categoriesCollection.add(category);
      return docRef.id;
    } catch (e) {
      print('Error creating category: $e');
      rethrow;
    }
  }

  // Get category by ID
  Future<Category?> getCategoryById(String id) async {
    try {
      final doc = await _categoriesCollection.doc(id).get();
      return doc.data();
    } catch (e) {
      print('Error getting category: $e');
      return null;
    }
  }

  // Get all categories
  Future<List<Category>> getAllCategories() async {
    try {
      final querySnapshot = await _categoriesCollection
          .orderBy('displayOrder')
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  // Get categories by type
  Future<List<Category>> getCategoriesByType(String type) async {
    try {
      print('getCategoriesByType: type=$type -> attempting where+orderBy(displayOrder)');
      final query = _categoriesCollection
          .where('type', isEqualTo: type)
          .orderBy('displayOrder');
      final querySnapshot = await query.get();
      final results = querySnapshot.docs.map((doc) => doc.data()).toList();
      print('getCategoriesByType: fetched ${results.length} categories with ordered query');
      return results;
    } catch (e) {
      print('getCategoriesByType: ordered query failed: $e; retrying without orderBy');
      try {
        final fallbackSnapshot = await _categoriesCollection
            .where('type', isEqualTo: type)
            .get();
        final fallbackResults = fallbackSnapshot.docs.map((doc) => doc.data()).toList();
        print('getCategoriesByType: fetched ${fallbackResults.length} categories with fallback query');
        return fallbackResults;
      } catch (e2) {
        print('getCategoriesByType: fallback query failed: $e2');
        return [];
      }
    }
  }

  // Update category
  Future<void> updateCategory(String id, Category category) async {
    try {
      await _categoriesCollection.doc(id).update(category.toJson());
    } catch (e) {
      print('Error updating category: $e');
      rethrow;
    }
  }

  // Delete category
  Future<void> deleteCategory(String id) async {
    try {
      await _categoriesCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting category: $e');
      rethrow;
    }
  }

  // Stream categories (real-time updates)
  Stream<List<Category>> streamCategories() {
    try {
      return _categoriesCollection
          .orderBy('displayOrder')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      print('Error streaming categories: $e');
      return Stream.empty();
    }
  }

  // ================ ACCOUNT OPERATIONS ================

  // Create a new account
  Future<String> createAccount(FirestoreAccount account) async {
    try {
      // Server-side validation for all accounts
      
      // 1. Name must be unique across all existing accounts
      if (account.name.isNotEmpty) {
        final nameExists = await doesAccountNameExist(account.name);
        if (nameExists) {
          throw Exception('An account with this name already exists. Please choose a different name.');
        }
      } else {
        throw Exception('Account name is required');
      }
      
      // 2. Server-side validation for vacation accounts
      if (account.isVacationAccount == true) {
        // Enforce that vacation accounts must have accountType = "Credit"
        if (account.accountType != 'Credit') {
          throw Exception('Vacation accounts must have account type set to "Credit"');
        }
        
        // Enforce that vacation accounts must have isVacationAccount = true
        if (account.isVacationAccount != true) {
          throw Exception('Vacation accounts must have isVacationAccount flag set to true');
        }
      }
      
      // Use a raw map write so we can ensure createdAt is set to server timestamp for new accounts
      final accountsRef = _firestore
          .collection('users')
          .doc(_userId!)
          .collection('accounts');
      final data = account.toJson() as Map<String, Object?>;
      
      // Apply vacation mode specific rules
      if (account.isVacationAccount == true) {
        // Force accountType to "Credit" regardless of what client sent
        data['accountType'] = 'Credit';
        // Set creditLimit to null to represent unlimited credit
        data['creditLimit'] = null;
        // Ensure isVacationAccount is true
        data['isVacationAccount'] = true;
      }
      
      if (data['createdAt'] == null) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }
      final docRef = await accountsRef.add(data);
      return docRef.id;
    } catch (e) {
      print('Error creating account: $e');
      rethrow;
    }
  }

  // Get account by ID
  Future<FirestoreAccount?> getAccountById(String id) async {
    try {
      final doc = await _accountsCollection.doc(id).get();
      return doc.data();
    } catch (e) {
      print('Error getting account: $e');
      return null;
    }
  }

  // Get all accounts
  Future<List<FirestoreAccount>> getAllAccounts() async {
    try {
      final querySnapshot = await _accountsCollection.get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting accounts: $e');
      return [];
    }
  }

  // Check if an account with the given name exists (exact match)
  Future<bool> doesAccountNameExist(String name) async {
    try {
      final querySnapshot = await _accountsCollection
          .where('name', isEqualTo: name)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking account name existence: $e');
      return false;
    }
  }

  // Update account
  Future<void> updateAccount(String id, FirestoreAccount account) async {
    try {
      await _accountsCollection.doc(id).update(account.toJson());
    } catch (e) {
      print('Error updating account: $e');
      rethrow;
    }
  }

  // Delete account. If cascadeDelete is true, delete associated transactions.
  // If cascadeDelete is false, migrate transactions to the default account (isDefault == true)
  // by updating their accountId, then delete the account document.
  Future<void> deleteAccount(String id, {bool cascadeDelete = false}) async {
    try {
      // First, query all transactions associated with this account
      final transactionsQuery = await _transactionsCollection
          .where('accountId', isEqualTo: id)
          .get();

      if (cascadeDelete) {
        // If cascadeDelete requested, remove all associated transactions
        if (transactionsQuery.docs.isNotEmpty) {
          final batch = _firestore.batch();

          for (final doc in transactionsQuery.docs) {
            batch.delete(doc.reference);
          }

          // Commit the batch delete for all associated transactions
          await batch.commit();
          print('Deleted ${transactionsQuery.docs.length} transactions associated with account $id');
        }
      } else {
        // Migrate transactions to the default account
        final defaultQuery = await _accountsCollection
            .where('isDefault', isEqualTo: true)
            .limit(1)
            .get();

        if (defaultQuery.docs.isEmpty) {
          throw Exception('Default account not found. Cannot migrate transactions.');
        }

        final defaultAccountId = defaultQuery.docs.first.id;

        if (transactionsQuery.docs.isNotEmpty) {
          final batch = _firestore.batch();

          for (final doc in transactionsQuery.docs) {
            batch.update(doc.reference, {'accountId': defaultAccountId});
          }

          await batch.commit();
          print('Migrated ${transactionsQuery.docs.length} transactions from account $id to default account $defaultAccountId');
        }
      }

      // After handling transactions, delete the account document
      await _accountsCollection.doc(id).delete();
      print('Account $id deleted successfully');
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }

  // Stream accounts (real-time updates)
  Stream<List<FirestoreAccount>> streamAccounts() {
    try {
      return _accountsCollection
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      print('Error streaming accounts: $e');
      return Stream.empty();
    }
  }

  // Toggle transaction paid status and update account balance ATOMICALLY
  Future<void> toggleTransactionPaidStatus(String transactionId, bool isPaid) async {
    final transactionRef = _transactionsCollection.doc(transactionId);

    await _firestore.runTransaction((tx) async {
      final txnSnap = await tx.get(transactionRef);
      if (!txnSnap.exists) {
        throw Exception('Transaction not found');
      }

      final txn = txnSnap.data()!;
      final String? accountId = txn.accountId;
      final double amount = txn.amount;
      final String type = txn.type; // 'income' or 'expense'
      final bool previousPaid = txn.paid ?? false;

      print('toggleTransactionPaidStatus: id=$transactionId prevPaid=$previousPaid -> newPaid=$isPaid type=$type amount=$amount accountId=$accountId');

      // If no change, only ensure the field is persisted and exit early
      if (previousPaid == isPaid) {
        tx.update(transactionRef, {'paid': isPaid});
        print('toggleTransactionPaidStatus: paid state unchanged; persisted field only.');
        return;
      }

      // If no linked account, just persist the paid flag
      if (accountId == null || accountId.isEmpty) {
        tx.update(transactionRef, {'paid': isPaid});
        print('toggleTransactionPaidStatus: no account linked; updated paid only.');
        return;
      }

      final accountRef = _accountsCollection.doc(accountId);
      final accountSnap = await tx.get(accountRef);

      if (!accountSnap.exists) {
        // If account is missing, don't fail toggling the paid flag
        tx.update(transactionRef, {'paid': isPaid});
        print('toggleTransactionPaidStatus: account not found; updated paid only.');
        return;
      }

      final double currentBalance = accountSnap.data()!.balance;

      // Compute balance delta based on type and direction of toggle
      double delta;
      if (type == 'income') {
        // Income: marking paid adds funds; marking unpaid removes them
        delta = isPaid ? amount : -amount;
      } else {
        // Default/expense: marking paid subtracts funds; marking unpaid adds them back
        delta = isPaid ? -amount : amount;
      }

      final double newBalance = currentBalance + delta;

      print('toggleTransactionPaidStatus: currentBalance=$currentBalance delta=$delta newBalance=$newBalance');

      tx.update(accountRef, {'balance': newBalance});
      tx.update(transactionRef, {'paid': isPaid});
    });
  }

  // ================ TASK OPERATIONS ================

  // Create a new task
  Future<String> createTask(FirestoreTask task) async {
    try {
      final docRef = await _tasksCollection.add(task);
      return docRef.id;
    } catch (e) {
      print('Error creating task: $e');
      rethrow;
    }
  }

  // Get task by ID
  Future<FirestoreTask?> getTaskById(String id) async {
    try {
      final doc = await _tasksCollection.doc(id).get();
      return doc.data();
    } catch (e) {
      print('Error getting task: $e');
      return null;
    }
  }

  // Get all tasks
  Future<List<FirestoreTask>> getAllTasks() async {
    try {
      final querySnapshot = await _tasksCollection
          .orderBy('dueDate', descending: false)
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting tasks: $e');
      return [];
    }
  }

  // Get upcoming tasks for a date range
  Future<List<FirestoreTask>> getUpcomingTasksForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _tasksCollection
          .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .where('isCompleted', isEqualTo: false)
          .orderBy('dueDate', descending: false)
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting upcoming tasks: $e');
      return [];
    }
  }

  // Update task
  Future<void> updateTask(String id, FirestoreTask task) async {
    try {
      await _tasksCollection.doc(id).update(task.toJson());
    } catch (e) {
      print('Error updating task: $e');
      rethrow;
    }
  }

  // Delete task
  Future<void> deleteTask(String id) async {
    try {
      await _tasksCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }

  // Stream tasks (real-time updates)
  Stream<List<FirestoreTask>> streamTasks() {
    try {
      return _tasksCollection
          .orderBy('dueDate', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      print('Error streaming tasks: $e');
      return Stream.empty();
    }
  }

  // Stream upcoming tasks for a date range (real-time updates)
  Stream<List<FirestoreTask>> streamUpcomingTasksForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    try {
      return _tasksCollection
          .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .where('isCompleted', isEqualTo: false)
          .orderBy('dueDate', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      print('Error streaming upcoming tasks for date range: $e');
      return Stream.empty();
    }
  }

  // ================ BATCH OPERATIONS ================

  // Run a batch write operation
  Future<void> runBatch(Function(WriteBatch batch) operations) async {
    try {
      final batch = _firestore.batch();
      operations(batch);
      await batch.commit();
    } catch (e) {
      print('Error running batch operation: $e');
      rethrow;
    }
  }

  // ================ ANALYTICS HELPERS ================

  // Get total income and expenses for a date range (optionally filtered by vacation mode)
  Future<Map<String, double>> getIncomeAndExpensesForDateRange(
    DateTime startDate,
    DateTime endDate, {
    bool isVacation = false,
  }) async {
    try {
      final transactions = await getTransactionsForDateRange(
        startDate,
        endDate,
        isVacation: isVacation,
      );
      
      double totalIncome = 0.0;
      double totalExpenses = 0.0;
      
      for (final transaction in transactions) {
        if (transaction.type == 'income') {
          totalIncome += transaction.amount;
        } else if (transaction.type == 'expense') {
          totalExpenses += transaction.amount;
        }
      }
      
      return {
        'income': totalIncome,
        'expenses': totalExpenses,
        'balance': totalIncome - totalExpenses,
      };
    } catch (e) {
      print('Error getting income and expenses: $e');
      return {'income': 0.0, 'expenses': 0.0, 'balance': 0.0};
    }
  }

  // ================ USER MANAGEMENT ================

  // Get user document
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDocument(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      print('Error getting user document: $e');
      rethrow;
    }
  }

  // Update user currency
  Future<void> updateUserCurrency(String uid, String currencyCode) async {
    final docRef = _firestore.collection('users').doc(uid);
    try {
      // Use set with merge to create the document if it doesn't exist,
      // or update it if it does. This is an idempotent operation.
      await docRef.set({'currency': currencyCode}, SetOptions(merge: true));
    } catch (e) {
      // Optional: more specific error handling if needed in the future.
      rethrow;
    }
  }

  // Check if user document exists
  Future<bool> doesUserDocumentExist(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      print('Error checking user document existence: $e');
      return false;
    }
  }

  // Save user data to Firestore (for authentication)
  Future<void> saveUserData(String uid, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(uid).set(userData, SetOptions(merge: true));
      print('User data saved successfully');
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user data
  Future<void> updateUserData(String uid, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(uid).update(userData);
      print('User data updated successfully');
    } catch (e) {
      print('Error updating user data: $e');
      rethrow;
    }
  }

  // ================ INITIALIZATION HELPERS ================

  // Create a default account for new users
  Future<String> createDefaultAccount(String accountName, String currency) async {
    try {
      final defaultAccount = FirestoreAccount(
        id: '', // Firestore will generate
        name: accountName,
        accountType: 'Cash', // Default to Cash account
        balance: 0.0,
        initialBalance: 0.0,
        description: 'Default $currency account',
        color: 'green',
        icon: 'account_balance_wallet',
        currency: currency,
      );
      
      final accountId = await createAccount(defaultAccount);
      print('Default account created successfully with ID: $accountId');
      return accountId;
    } catch (e) {
      print('Error creating default account: $e');
      rethrow;
    }
  }

  // Create a default account only if the user has no existing accounts
  Future<void> createDefaultAccountIfNeeded(String currencyCode, String currencySymbol) async {
    try {
      final defaultId = 'default_cash';
      final docRef = _accountsCollection.doc(defaultId);

      await _firestore.runTransaction((t) async {
        final snap = await t.get(docRef);
        if (!snap.exists) {
          final defaultAccount = FirestoreAccount(
            id: defaultId,
            name: 'None',
            accountType: 'Cash',
            balance: 0.0,
            initialBalance: 0.0,
            description: 'Default $currencyCode account',
            color: 'green',
            icon: 'account_balance_wallet',
            currency: currencyCode,
            isDefault: true,
          );
          // Pass the typed model; the CollectionReference's converter will handle serialization
          t.set(docRef, defaultAccount);
          print('Created default Cash account for new user with currency: $currencyCode');
        } else {
          print('Default account already exists, skipping creation');
        }
      });
    } catch (e) {
      print('Error in createDefaultAccountIfNeeded: $e');
      rethrow;
    }
  }

  // Initialize default categories for new users
  Future<void> initializeDefaultCategories() async {
    try {
      final existingCategories = await getAllCategories();
      if (existingCategories.isNotEmpty) return; // Already initialized
      
      final defaultCategories = [
        // Income categories
        Category(
          id: '',
          name: 'Salary',
          type: 'income',
          icon: 'work',
          color: 'green',
          displayOrder: 0,
        ),
        Category(
          id: '',
          name: 'Freelance',
          type: 'income',
          icon: 'business',
          color: 'green',
          displayOrder: 1,
        ),
        Category(
          id: '',
          name: 'Investment',
          type: 'income',
          icon: 'trending_up',
          color: 'green',
          displayOrder: 2,
        ),
        
        // Expense categories
        Category(
          id: '',
          name: 'Food & Dining',
          type: 'expense',
          icon: 'restaurant',
          color: 'orange',
          displayOrder: 0,
        ),
        Category(
          id: '',
          name: 'Transportation',
          type: 'expense',
          icon: 'directions_car',
          color: 'blue',
          displayOrder: 1,
        ),
        Category(
          id: '',
          name: 'Shopping',
          type: 'expense',
          icon: 'shopping_cart',
          color: 'purple',
          displayOrder: 2,
        ),
        Category(
          id: '',
          name: 'Entertainment',
          type: 'expense',
          icon: 'movie',
          color: 'pink',
          displayOrder: 3,
        ),
        Category(
          id: '',
          name: 'Bills & Utilities',
          type: 'expense',
          icon: 'receipt',
          color: 'red',
          displayOrder: 4,
        ),
      ];
      
      final batch = _firestore.batch();
      for (final category in defaultCategories) {
        final docRef = _categoriesCollection.doc();
        batch.set(docRef, category.copyWith(id: docRef.id));
      }
      await batch.commit();
      
      print('Default categories initialized');
    } catch (e) {
      print('Error initializing default categories: $e');
    }
  }

  // Clear all user data (for testing/debugging)
  Future<void> clearAllUserData() async {
    try {
      if (_userId == null) return;
      
      final batch = _firestore.batch();
      
      // Delete all transactions
      final transactionsSnapshot = await _transactionsCollection.get();
      for (final doc in transactionsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete all categories
      final categoriesSnapshot = await _categoriesCollection.get();
      for (final doc in categoriesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete all accounts
      final accountsSnapshot = await _accountsCollection.get();
      for (final doc in accountsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete all tasks
      final tasksSnapshot = await _tasksCollection.get();
      for (final doc in tasksSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('All user data cleared');
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }

  // ================ ACCOUNT PROFILE INITIALIZATION ================
  // Slug utility for deterministic category document IDs
  static String createSlug(String name) {
    final s = name.trim().toLowerCase();
    var normalized = s.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    normalized = normalized.replaceAll(RegExp(r'-+'), '-');
    normalized = normalized.replaceAll(RegExp(r'^-|-$'), '');
    return normalized.isEmpty ? 'uncategorized' : normalized;
  }

  // Fetch or create the top-level account profile document at accounts/{uid}
  Future<FirestoreAccount> getOrCreateAccount(String uid) async {
    try {
      final docRef = _firestore.collection('accounts').doc(uid);
      final snap = await docRef.get();
      if (snap.exists) {
        final data = snap.data() as Map<String, dynamic>;
        return FirestoreAccount.fromJson(data, uid);
      }
      await docRef.set({
        'isInitialized': false,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Return a minimal FirestoreAccount profile representation for compatibility
      return FirestoreAccount.fromJson({
        'isInitialized': false,
      }, uid);
    } catch (e) {
      print('Error in getOrCreateAccount: $e');
      rethrow;
    }
  }

  // Begin first-time initialization: default categories upsert + account profile update + default shadow account
  Future<void> beginInitialization(String uid, String currency, String themeMode) async {
    try {
      final batch = _firestore.batch();

      // Upsert default categories with deterministic IDs using merge
      await CategoryInitializer.createDefaultCategoriesForUser(batch, uid);

      // Upsert default shadow account under users/{uid}/accounts/default_cash
      final defaultAccountDoc = _firestore
          .collection('users')
          .doc(uid)
          .collection('accounts')
          .doc('default_cash');

      final defaultAccountData = FirestoreAccount(
        id: 'default_cash',
        name: 'None',
        accountType: 'Cash',
        balance: 0.0,
        initialBalance: 0.0,
        description: 'Default $currency account',
        color: 'green',
        icon: 'account_balance_wallet',
        currency: currency,
        isDefault: true,
      ).toJson() as Map<String, Object?>;

      // Use merge to avoid overwriting if it already exists
      batch.set(defaultAccountDoc, defaultAccountData, SetOptions(merge: true));

      // Update account profile document at accounts/{uid}
      final accountProfileDoc = _firestore.collection('accounts').doc(uid);
      batch.set(accountProfileDoc, {
        'currency': currency,
        'themeMode': themeMode,
        'defaultCategoriesCreatedAt': FieldValue.serverTimestamp(),
        'isInitialized': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await batch.commit();
      print('Initialization completed for uid=$uid (categories + default account + profile)');
    } catch (e) {
      print('Error in beginInitialization: $e');
      rethrow;
    }
  }

  // Check if the user has been initialized.
  // If categories exist but account profile says uninitialized, mark initialized.
  Future<bool> isUserInitialized(String uid) async {
    try {
      final profileRef = _firestore.collection('accounts').doc(uid);
      final profileSnap = await profileRef.get();

      bool initialized = false;
      if (profileSnap.exists) {
        final data = profileSnap.data() as Map<String, dynamic>? ?? {};
        initialized = (data['isInitialized'] as bool?) ?? false;
        if (initialized) {
          return true;
        }
      } else {
        // Ensure the profile doc exists for future updates
        await profileRef.set({
          'isInitialized': false,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // If not initialized or missing flag, check categories collection
      final catsSnap = await _firestore
          .collection('users')
          .doc(uid)
          .collection('categories')
          .limit(1)
          .get();

      if (catsSnap.docs.isNotEmpty) {
        await profileRef.set({
          'isInitialized': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return true;
      }

      return false;
    } catch (e) {
      print('Error in isUserInitialized: $e');
      // Fail-safe: treat as not initialized
      return false;
    }
  }
}