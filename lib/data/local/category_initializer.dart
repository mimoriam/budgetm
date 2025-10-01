import 'package:shared_preferences/shared_preferences.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/models/category.dart';

class CategoryInitializer {
  static const String _CATEGORIES_POPULATED_KEY = 'categories_populated';
  
  /// Prepopulates the Categories table with default categories if not already done
  static Future<void> initializeCategories() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool categoriesPopulated = prefs.getBool(_CATEGORIES_POPULATED_KEY) ?? false;
    
    if (!categoriesPopulated) {
      final FirestoreService firestoreService = FirestoreService.instance;
      
      // Expense Categories
      final List<String> expenseCategoryNames = [
        'Supermarket',
        'Clothing',
        'House',
        'Transport',
        'Entertainment',
        'Gifts',
        'Travel',
        'Education',
        'Food',
        'Work',
        'Electronics',
        'Sport',
        'Restaurant',
        'Health',
        'Communications',
        'Others',
      ];
      
      // Income Categories
      final List<String> incomeCategoryNames = [
        'Salary',
        'Income',
        'Rewards',
        'Gifts',
        'Business',
        'Others',
      ];
      
      // Insert expense categories with their own display order
      int expenseDisplayOrder = 0;
      for (final String categoryName in expenseCategoryNames) {
        final expenseCategory = Category(
          id: '', // Firestore will generate
          name: categoryName,
          type: 'expense',
          displayOrder: expenseDisplayOrder,
        );
        await firestoreService.createCategory(expenseCategory);
        expenseDisplayOrder++;
      }
      
      // Insert income categories with their own display order
      int incomeDisplayOrder = 0;
      for (final String categoryName in incomeCategoryNames) {
        final incomeCategory = Category(
          id: '', // Firestore will generate
          name: categoryName,
          type: 'income',
          displayOrder: incomeDisplayOrder,
        );
        await firestoreService.createCategory(incomeCategory);
        incomeDisplayOrder++;
      }
      
      // Mark categories as populated
      await prefs.setBool(_CATEGORIES_POPULATED_KEY, true);
    }
  }
}
