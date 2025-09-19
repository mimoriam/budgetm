import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/screens/dashboard/profile/categories/add_category/add_category_screen.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:budgetm/data/local/app_database.dart';
import 'package:drift/drift.dart' as drift;

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  bool _isExpenseSelected = true;
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final database = AppDatabase.instance;
    final categories = await database.getCategoriesOrdered();
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentCategories = _categories
        .where(
          (category) =>
              category.type == (_isExpenseSelected ? 'expense' : 'income'),
        )
        .toList();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: _buildCustomAppBar(context),
      body: Column(
        children: [
          _buildToggleChips(),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                itemCount: currentCategories.length,
                itemBuilder: (context, index) {
                  final category = currentCategories[index];
                  return _buildCategoryItem(
                    key: ValueKey(category.id),
                    category: category,
                  );
                },
                onReorder: (int oldIndex, int newIndex) {
                  _reorderCategories(oldIndex, newIndex, currentCategories);
                },
              ),
            ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0), // Uplift FAB
        child: FloatingActionButton(
          onPressed: () {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: const AddCategoryScreen(),
              withNavBar: false,
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          },
          backgroundColor: AppColors.gradientEnd,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: Container(
        padding: const EdgeInsets.only(top: 12, bottom: 12),
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
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.gradientStart,
                          AppColors.gradientEnd,
                        ],
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
                  'Categories',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 10.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return Container(
            height: 55, // Increased height
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18), // Less rounded
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: _isExpenseSelected ? 0 : (width / 2) - 4,
                  right: _isExpenseSelected ? (width / 2) - 4 : 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _isExpenseSelected
                          ? const Color(0xFFEF4444)
                          : AppColors.incomeGreen,
                      borderRadius: BorderRadius.circular(14), // Less rounded
                    ),
                    height: 47, // Adjusted inner height
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildChip(
                        'Expense',
                        _isExpenseSelected,
                        () => setState(() => _isExpenseSelected = true),
                      ),
                    ),
                    Expanded(
                      child: _buildChip(
                        'Income',
                        !_isExpenseSelected,
                        () => setState(() => _isExpenseSelected = false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black54,
            fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
          ),
          child: Text(label),
        ),
      ),
    );
  }

  Widget _buildCategoryItem({required Key key, required Category category}) {
    return Container(
      key: key,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.lime.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const HugeIcon(
            icon: HugeIcons.strokeRoundedShoppingBag01,
            size: 22,
            color: Colors.black87,
          ),
        ),
        title: Text(
          category.name ?? '',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: IconButton(
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedDragDropVertical,
            color: Colors.grey,
            size: 24,
          ),
          onPressed: null,
        ),
      ),
    );
  }

  Future<void> _reorderCategories(
    int oldIndex,
    int newIndex,
    List<Category> currentCategories,
  ) async {
    // Adjust newIndex if it's greater than oldIndex
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    // Create a copy of the current categories list
    final updatedCategories = List<Category>.from(currentCategories);

    // Reorder the categories in the list
    final movedCategory = updatedCategories.removeAt(oldIndex);
    updatedCategories.insert(newIndex, movedCategory);

    // Update the display order in the database
    final categoryOrderPairs = <MapEntry<int, int>>[];
    for (int i = 0; i < updatedCategories.length; i++) {
      categoryOrderPairs.add(MapEntry(updatedCategories[i].id, i));
    }

    final database = AppDatabase.instance;
    await database.updateMultipleCategoryDisplayOrders(categoryOrderPairs);

    // Update the state with the new display orders
    setState(() {
      // Create a map of category id to new display order
      final orderMap = <int, int>{};
      for (int i = 0; i < updatedCategories.length; i++) {
        orderMap[updatedCategories[i].id] = i;
      }

      // Update the _categories list with new display orders
      _categories = _categories.map((category) {
        final newDisplayOrder = orderMap[category.id];
        if (newDisplayOrder != null) {
          // Create a new Category object with updated displayOrder
          return category.copyWith(displayOrder: newDisplayOrder);
        }
        return category;
      }).toList();

      // Sort the categories by display order to ensure correct UI order
      _categories.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    });
  }

  Future<void> _deleteCategory(Category category) async {
    final database = AppDatabase.instance;
    await database.customUpdate(
      'DELETE FROM categories WHERE id = ?',
      variables: [drift.Variable.withInt(category.id)],
      updates: {database.categories},
    );
    await _loadCategories(); // Reload categories after deletion
  }
}
