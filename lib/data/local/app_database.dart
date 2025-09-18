import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'models/transaction_model.dart';
import 'models/task_model.dart';
import 'models/account_model.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Transactions, Tasks, Accounts])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 4; // Incremented from 3 to 4 to fix Accounts table primary key

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
  
  /// Get an account by ID
  Future<Account?> getAccountById(String id) {
    return (select(accounts)..where((acc) => acc.id.equals(id))).getSingleOrNull();
  }
  
  /// Get an account by name
  Future<Account?> getAccountByName(String name) {
    return (select(accounts)..where((acc) => acc.name.equals(name))).getSingleOrNull();
  }
  
  /// Get the default account
  Future<Account?> getDefaultAccount() {
    return (select(accounts)..where((acc) => acc.isDefault.equals(true))).getSingleOrNull();
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
      name: 'Default Account',
      currency: 'USD', // Default currency, should be updated based on user settings
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