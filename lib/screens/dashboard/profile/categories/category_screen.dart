import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/screens/dashboard/profile/categories/add_category/add_category_screen.dart';
import 'package:budgetm/viewmodels/budget_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:budgetm/utils/icon_utils.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/models/category.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  bool _isExpenseSelected = true;
  List<Category> _categories = [];
  bool _isLoading = true;
  late FirestoreService _firestoreService;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService.instance;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final categories = await _firestoreService.getAllCategories();
      
      // Filter out duplicate categories based on ID to prevent GlobalKey errors
      final uniqueCategories = <String, Category>{};
      for (final category in categories) {
        uniqueCategories[category.id] = category;
      }
      
      setState(() {
        _categories = uniqueCategories.values.toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading categories: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
                proxyDecorator: (Widget child, int index, Animation<double> animation) {
                  return Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: child,
                    ),
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
          onPressed: () async {
            final initialType = _isExpenseSelected ? 'expense' : 'income';
            final result = await PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: AddCategoryScreen(initialCategoryType: initialType),
              withNavBar: false,
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
            
            // If a category was added successfully, refresh the list
            if (result == true) {
              _loadCategories();
              Provider.of<BudgetProvider>(context, listen: false).refreshCategories();
            }
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
          child: HugeIcon(
            icon: getIcon(category.icon),
            size: 22,
            color: Colors.black87,
          ),
        ),
        title: Text(
          category.name ?? 'Unnamed Category',
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

    // Keep a snapshot of original full _categories to allow reverting on failure
    final originalCategories = List<Category>.from(_categories);

    // Work on a copy of the visible (filtered) list and reorder it
    final updatedVisible = List<Category>.from(currentCategories);
    final movedCategory = updatedVisible.removeAt(oldIndex);
    updatedVisible.insert(newIndex, movedCategory);

    // Optimistically update local state so UI reflects new order immediately
    setState(() {
      for (int i = 0; i < updatedVisible.length; i++) {
        final id = updatedVisible[i].id;
        final idx = _categories.indexWhere((c) => c.id == id);
        if (idx != -1) {
          _categories[idx] = _categories[idx].copyWith(displayOrder: i);
        }
      }

      // Ensure overall list is sorted by displayOrder for correct UI
      _categories.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    });

    // Persist the new order to Firestore in the background. If it fails, revert UI.
    try {
      for (int i = 0; i < updatedVisible.length; i++) {
        final category = updatedVisible[i];
        final updatedCategory = category.copyWith(displayOrder: i);
        await _firestoreService.updateCategory(updatedCategory.id, updatedCategory);
      }
      Provider.of<BudgetProvider>(context, listen: false).refreshCategories();
      // Success - nothing further to do since UI already updated optimistically
    } catch (e) {
      print('Error reordering categories: $e');
      // Revert optimistic update on failure
      if (mounted) {
        setState(() {
          _categories = originalCategories;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to reorder categories. Reverting changes.')),
        );
      }
    }
  }

  Future<void> _deleteCategory(Category category) async {
    try {
      await _firestoreService.deleteCategory(category.id);
      await _loadCategories(); // Reload categories after deletion
    } catch (e) {
      print('Error deleting category: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete category: $e')),
        );
      }
    }
  }
}
