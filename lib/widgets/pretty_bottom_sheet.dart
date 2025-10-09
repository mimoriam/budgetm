import 'package:flutter/material.dart';
import '../constants/appColors.dart';

class PrettyBottomSheet<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final T selectedItem;
  final String Function(T) getDisplayName;
  final Widget Function(T)? getLeading;

  const PrettyBottomSheet({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItem,
    required this.getDisplayName,
    this.getLeading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            width: 40,
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.lightGreyBackground.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryTextColorLight,
              ),
            ),
          ),
          // const Divider(height: 1),
          // Items list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = item == selectedItem;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2, top: 2),
                  child: Card(
                    elevation: isSelected ? 4 : 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [
                                  AppColors.gradientStart,
                                  AppColors.gradientEnd,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isSelected ? null : Colors.white,
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 0.0,
                        ),
                        leading: getLeading != null ? getLeading!(item) : null,
                        title: Text(
                          getDisplayName(item),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primaryTextColorLight
                                : AppColors.secondaryTextColorLight,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: AppColors.primaryTextColorLight,
                                size: 24,
                              )
                            : null,
                        onTap: () {
                          Navigator.pop(context, item);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}