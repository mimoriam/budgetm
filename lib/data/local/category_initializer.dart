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
      int displayOrder = 0;
      for (final String categoryName in defaultCategoryNames) {
        // Insert income category
        final incomeCategory = Category(
          id: '', // Firestore will generate
          name: categoryName,
          type: 'income',
          displayOrder: displayOrder,
        );
        await firestoreService.createCategory(incomeCategory);
        
        // Insert expense category
        final expenseCategory = Category(
          id: '', // Firestore will generate
          name: categoryName,
          type: 'expense',
          displayOrder: displayOrder,
        );
        await firestoreService.createCategory(expenseCategory);
        
        displayOrder++;
      }
      
      // Mark categories as populated
      await prefs.setBool(_CATEGORIES_POPULATED_KEY, true);
    }
  }
}
