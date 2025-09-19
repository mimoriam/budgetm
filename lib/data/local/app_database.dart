import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'models/transaction_model.dart';
import 'models/task_model.dart';
import 'models/account_model.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Categories, Transactions, Tasks, Accounts])
class AppDatabase extends _$AppDatabase {
  // Singleton instance
  static AppDatabase? _instance;

  // Private constructor
  AppDatabase._internal([QueryExecutor? executor])
    : super(executor ?? _openConnection());

  // Factory constructor to return the singleton instance
  factory AppDatabase([QueryExecutor? executor]) {
    // Thread-safe singleton initialization
    return _instance ??= AppDatabase._internal(executor);
  }

  // Method to get the singleton instance
  static AppDatabase get instance {
    return AppDatabase();
  }

  @override
  int get schemaVersion => 5; // Incremented from 4 to 5 to add Categories table

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) {
        return m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {},
    );
  }

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'app_database.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }

  // Account management methods
  // NOTE: These methods will be implemented after running drift code generation
  // The following classes need to be generated first:
  // - $AccountsTable (table info class)
  // - Account (data class)
  // - AccountsCompanion (companion class)
  //
  // Uncomment and implement the following methods after code generation:

  /// Insert a new account
  Future<int> insertAccount(AccountsCompanion account) {
    return into(accounts).insert(account);
  }

  /// Insert a new transaction
  Future<int> insertTransaction(TransactionsCompanion transaction) {
    return into(transactions).insert(transaction);
  }

  /// Get an account by ID
  Future<Account?> getAccountById(String id) {
    return (select(
      accounts,
    )..where((acc) => acc.id.equals(id))).getSingleOrNull();
  }

  /// Get an account by name
  Future<Account?> getAccountByName(String name) {
    return (select(
      accounts,
    )..where((acc) => acc.name.equals(name))).getSingleOrNull();
  }

  /// Get a category by ID
  Future<Category?> getCategoryById(int id) {
    return (select(
      categories,
    )..where((cat) => cat.id.equals(id))).getSingleOrNull();
  }

  /// Update the display order of a category
  Future<int> updateCategoryDisplayOrder(int categoryId, int displayOrder) {
    return customUpdate(
      'UPDATE categories SET display_order = ? WHERE id = ?',
      variables: [Variable.withInt(displayOrder), Variable.withInt(categoryId)],
      updates: {categories},
    );
  }

  /// Update display orders for multiple categories
  Future<void> updateMultipleCategoryDisplayOrders(List<MapEntry<int, int>> categoryOrderPairs) async {
    for (var pair in categoryOrderPairs) {
      await updateCategoryDisplayOrder(pair.key, pair.value);
    }
  }

  /// Insert a new category
  Future<int> insertCategory(CategoriesCompanion category) {
    return into(categories).insert(category);
  }

    /// Get the maximum display order for a given category type
    Future<int> getMaxDisplayOrderForType(String type) async {
      final result = await customSelect(
        'SELECT MAX(display_order) as maxOrder FROM categories WHERE type = ?',
        variables: [Variable.withString(type)],
        readsFrom: {categories},
      ).getSingleOrNull();
  
      // If no categories exist for this type, start with 0
      // Otherwise, return the max order + 1
      if (result != null && result.data['maxOrder'] != null) {
        final maxOrder = result.data['maxOrder'] as int?;
        return (maxOrder ?? -1) + 1;
      } else {
        return 0;
      }
    }

  /// Get all categories ordered by display order
  Future<List<Category>> getCategoriesOrdered() {
    return (select(categories)..orderBy([
      (u) => OrderingTerm(expression: u.displayOrder),
      (u) => OrderingTerm(expression: u.id),
    ])).get();
  }

  /// Get all accounts
  Future<List<Account>> getAccounts() {
    return select(accounts).get();
 }

  /// Get the default account
  Future<Account?> getDefaultAccount() {
    return (select(
      accounts,
    )..where((acc) => acc.isDefault.equals(true))).getSingleOrNull();
  }

  /// Create a default account if one doesn't exist
  Future<Account?> createDefaultAccountIfNeeded() async {
    final defaultAccount = await getDefaultAccount();
    if (defaultAccount != null) {
      return defaultAccount;
    }

    // Create a default account
    final defaultAccountCompanion = AccountsCompanion.insert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Default',
      accountType: 'Cash', // Default account type
      currency:
          'USD', // Default currency, should be updated based on user settings
    );

    await insertAccount(defaultAccountCompanion);
    return await getDefaultAccount();
  }

  /// Create a default account with specific name and currency
  Future<Account> createDefaultAccount(String name, String currency) async {
    // First check if a default account already exists
    final existingDefault = await getDefaultAccount();
    if (existingDefault != null) {
      return existingDefault;
    }

    // Create a new default account
    final accountCompanion = AccountsCompanion.insert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      accountType: 'Cash', // Default account type
      currency: currency,
      isDefault: Value(true),
    );

    await insertAccount(accountCompanion);

    // Return the created account
    final createdAccount = await getAccountByName(name);
    if (createdAccount != null) {
      return createdAccount;
    } else {
      throw Exception('Failed to create default account');
    }
  }
}
