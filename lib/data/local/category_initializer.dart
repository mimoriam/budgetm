import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/models/category.dart';

class CategoryInitializer {
  /// Adds default categories for the given user into the provided WriteBatch.
  /// Does NOT commit the batch. Uses deterministic document IDs to prevent duplicates.
  static Future<void> createDefaultCategoriesForUser(WriteBatch batch, String uid) async {
    final categoriesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('categories');

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
      'Lent',
      'Others',
    ];

    // Income Categories
    final List<String> incomeCategoryNames = [
      'Salary',
      'Income',
      'Rewards',
      'Gifts',
      'Business',
      'Borrowed',
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
      'Lent': 'icon_lent',
      'Others': 'icon_others_expense',
    };

    final Map<String, String> incomeIconMap = {
      'Salary': 'icon_salary',
      'Income': 'icon_income',
      'Rewards': 'icon_rewards',
      'Gifts': 'icon_gifts_income',
      'Business': 'icon_business',
      'Borrowed': 'icon_borrowed',
      'Others': 'icon_others_income',
    };

    // Insert expense categories with deterministic IDs: "expense-{slug}"
    int expenseDisplayOrder = 0;
    for (final String categoryName in expenseCategoryNames) {
      final String iconId = expenseIconMap[categoryName] ?? 'icon_default_expense';
      final String slug = FirestoreService.createSlug(categoryName);
      final String docId = 'expense-$slug';
      final docRef = categoriesRef.doc(docId);

      final category = Category(
        id: docId,
        name: categoryName,
        type: 'expense',
        icon: iconId,
        color: null,
        displayOrder: expenseDisplayOrder,
      );

      batch.set(
        docRef,
        category.toJson(),
        SetOptions(merge: true),
      );

      expenseDisplayOrder++;
    }

    // Insert income categories with deterministic IDs: "income-{slug}"
    int incomeDisplayOrder = 0;
    for (final String categoryName in incomeCategoryNames) {
      final String iconId = incomeIconMap[categoryName] ?? 'icon_default_income';
      final String slug = FirestoreService.createSlug(categoryName);
      final String docId = 'income-$slug';
      final docRef = categoriesRef.doc(docId);

      final category = Category(
        id: docId,
        name: categoryName,
        type: 'income',
        icon: iconId,
        color: null,
        displayOrder: incomeDisplayOrder,
      );

      batch.set(
        docRef,
        category.toJson(),
        SetOptions(merge: true),
      );

      incomeDisplayOrder++;
    }
  }
}
