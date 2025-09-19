import 'package:shared_preferences/shared_preferences.dart';
import 'package:budgetm/data/local/app_database.dart';
import 'package:budgetm/data/local/models/transaction_model.dart';
import 'package:drift/drift.dart';

class CategoryInitializer {
  static const String _CATEGORIES_POPULATED_KEY = 'categories_populated';
  
  /// Prepopulates the Categories table with default categories if not already done
  static Future<void> initializeCategories() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool categoriesPopulated = prefs.getBool(_CATEGORIES_POPULATED_KEY) ?? false;
    
    if (!categoriesPopulated) {
      final AppDatabase database = AppDatabase();
      
      // Default categories to insert - shared names for both income and expense
      final List<String> defaultCategoryNames = [
        'Salary',
        'Investments',
        'Business',
        'Groceries',
        'Clothing',
        'Home',
        'Entertainment',
        'Transport',
        'Gifts',
      ];
      
      // Insert both income and expense categories for each name
      for (final String categoryName in defaultCategoryNames) {
        // Insert income category
        final incomeCategory = CategoriesCompanion.insert(
          name: Value(categoryName),
          type: Value('income'),
        );
        await database.into(database.categories).insert(incomeCategory);
        
        // Insert expense category
        final expenseCategory = CategoriesCompanion.insert(
          name: Value(categoryName),
          type: Value('expense'),
        );
        await database.into(database.categories).insert(expenseCategory);
      }
      
      // Mark categories as populated
      await prefs.setBool(_CATEGORIES_POPULATED_KEY, true);
    }
  }
}
