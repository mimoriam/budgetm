import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:budgetm/models/firestore_transaction.dart';
import 'package:budgetm/models/category.dart';
import 'package:budgetm/models/firestore_account.dart';
import 'package:budgetm/models/firestore_task.dart';

class FirestoreService {
  static FirestoreService? _instance;
  static FirestoreService get instance {
    _instance ??= FirestoreService._internal();
    return _instance!;
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
          fromFirestore: (snapshot, _) => FirestoreTransaction.fromFirestore(snapshot),
          toFirestore: (transaction, _) => transaction.toJson(),
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
  Future<List<FirestoreTransaction>> getAllTransactions({bool isVacation = false}) async {
    try {
      final query = _transactionsCollection.where('isVacation', isEqualTo: isVacation);
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
  Future<void> updateTransaction(String id, FirestoreTransaction transaction) async {
    try {
      await _transactionsCollection.doc(id).update(transaction.toJson());
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
        
        if (accountId == null || accountId.isEmpty) {
          // If no account is linked, just delete the transaction
          transaction.delete(transactionDocRef);
          return;
        }

        // 2. Get the associated account document
        final accountDocRef = _accountsCollection.doc(accountId);
        final accountSnapshot = await transaction.get(accountDocRef);
        if (!accountSnapshot.exists) {
          // If account doesn't exist, just delete the transaction
          transaction.delete(transactionDocRef);
          return;
        }

        // 3. Calculate the new balance
        final currentBalance = accountSnapshot.data()!.balance;
        final transactionAmount = transactionData.amount;
        final transactionType = transactionData.type;

        final newBalance = (transactionType == 'income')
            ? currentBalance - transactionAmount
            : currentBalance + transactionAmount;

        // 4. Update the account balance
        transaction.update(accountDocRef, {'balance': newBalance});

        // 5. Delete the transaction
        transaction.delete(transactionDocRef);
      });
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    }
  }

  // Stream transactions (real-time updates)
  Stream<List<FirestoreTransaction>> streamTransactions() {
    try {
      return _transactionsCollection
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      print('Error streaming transactions: $e');
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
      final querySnapshot = await _categoriesCollection
          .where('type', isEqualTo: type)
          .orderBy('displayOrder')
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting categories by type: $e');
      return [];
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
      final docRef = await _accountsCollection.add(account);
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

  // Update account
  Future<void> updateAccount(String id, FirestoreAccount account) async {
    try {
      await _accountsCollection.doc(id).update(account.toJson());
    } catch (e) {
      print('Error updating account: $e');
      rethrow;
    }
  }

  // Delete account
  Future<void> deleteAccount(String id) async {
    try {
      await _accountsCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }

  // Stream accounts (real-time updates)
  Stream<List<FirestoreAccount>> streamAccounts() {
    try {
      return _accountsCollection
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      print('Error streaming accounts: $e');
      return Stream.empty();
    }
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
        accountType: 'cash', // Default to cash account
        balance: 0.0,
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
            name: 'Wallet',
            accountType: 'cash',
            balance: 0.0,
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
}