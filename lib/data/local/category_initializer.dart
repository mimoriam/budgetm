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
      
      // Map category names to icon identifiers (placeholders)
      final Map<String, String> expenseIconMap = {
        'Supermarket': 'icon_supermarket',
        'Clothing': 'icon_clothing',
        'House': 'icon_house',
        'Transport': 'icon_transport',
        'Entertainment': 'icon_entertainment',
        'Gifts': 'icon_gifts',
        'Travel': 'icon_travel',
        'Education': 'icon_education',
        'Food': 'icon_food',
        'Work': 'icon_work',
        'Electronics': 'icon_electronics',
        'Sport': 'icon_sport',
        'Restaurant': 'icon_restaurant',
        'Health': 'icon_health',
        'Communications': 'icon_communications',
        'Others': 'icon_others_expense',
      };
      
      final Map<String, String> incomeIconMap = {
        'Salary': 'icon_salary',
        'Income': 'icon_income',
        'Rewards': 'icon_rewards',
        'Gifts': 'icon_gifts_income',
        'Business': 'icon_business',
        'Others': 'icon_others_income',
      };
      
      // Insert expense categories with their own display order
      int expenseDisplayOrder = 0;
      for (final String categoryName in expenseCategoryNames) {
        final String iconId = expenseIconMap[categoryName] ?? 'icon_default_expense';
        final expenseCategory = Category(
          id: '', // Firestore will generate
          name: categoryName,
          type: 'expense',
          icon: iconId,
          displayOrder: expenseDisplayOrder,
        );
        await firestoreService.createCategory(expenseCategory);
        expenseDisplayOrder++;
      }
      
      // Insert income categories with their own display order
      int incomeDisplayOrder = 0;
      for (final String categoryName in incomeCategoryNames) {
        final String iconId = incomeIconMap[categoryName] ?? 'icon_default_income';
        final incomeCategory = Category(
          id: '', // Firestore will generate
          name: categoryName,
          type: 'income',
          icon: iconId,
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
