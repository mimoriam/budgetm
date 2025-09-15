import 'package:budgetm/constants/appColors.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  bool _isExpenseSelected = true;

  List<Map<String, dynamic>> _expenseCategories = [
    {'icon': HugeIcons.strokeRoundedShoppingBag01, 'name': 'Super Market'},
    {'icon': HugeIcons.strokeRoundedTShirt, 'name': 'Clothing'},
    {'icon': HugeIcons.strokeRoundedHome01, 'name': 'Home'},
    {'icon': HugeIcons.strokeRoundedTicket01, 'name': 'Entertainment'},
    {'icon': HugeIcons.strokeRoundedBus01, 'name': 'Transport'},
    {'icon': HugeIcons.strokeRoundedGift, 'name': 'Gifts'},
  ];

  List<Map<String, dynamic>> _incomeCategories = [
    {'icon': HugeIcons.strokeRoundedDollar02, 'name': 'Salary'},
    {'icon': HugeIcons.strokeRoundedChartUp, 'name': 'Investments'},
    {'icon': HugeIcons.strokeRoundedBriefcase01, 'name': 'Business'},
    {'icon': HugeIcons.strokeRoundedGift, 'name': 'Gifts'},
  ];

  @override
  Widget build(BuildContext context) {
    final currentList = _isExpenseSelected
        ? _expenseCategories
        : _incomeCategories;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildCustomAppBar(context),
      body: Column(
        children: [
          _buildToggleChips(),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              itemCount: currentList.length,
              itemBuilder: (context, index) {
                final category = currentList[index];
                return _buildCategoryItem(
                  key: ValueKey(category['name']),
                  iconData: category['icon'],
                  name: category['name'],
                );
              },
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = currentList.removeAt(oldIndex);
                  currentList.insert(newIndex, item);
                });
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0), // Uplift FAB
        child: FloatingActionButton(
          onPressed: () {
            // TODO: Add new category logic
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
      preferredSize: const Size.fromHeight(80),
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
                  'Category',
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

  Widget _buildCategoryItem({
    required Key key,
    required List<List<dynamic>> iconData,
    required String name,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.symmetric(vertical: 2.0), // compact margin
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: ListTile(
        dense: true, // make list tile more compact
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.lime.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: HugeIcon(icon: iconData, size: 22, color: Colors.black87),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const HugeIcon(
          icon: HugeIcons.strokeRoundedDragDropVertical,
          color: Colors.grey,
          size: 24,
        ),
      ),
    );
  }
}
