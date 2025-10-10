import 'package:flutter/material.dart';
import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/viewmodels/currency_provider.dart';
import 'package:intl/intl.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:budgetm/models/personal/subscription.dart';
import 'package:budgetm/models/personal/borrowed.dart';
import 'package:budgetm/models/personal/lent.dart';
import 'package:provider/provider.dart';

class DetailedItemScreen extends StatelessWidget {
  final String itemType;
  final Object item;

  const DetailedItemScreen({super.key, required this.itemType, required this.item});

  String getAppBarTitle() {
    switch (itemType.toLowerCase()) {
      case 'lent':
        return 'Lent';
      case 'borrowed':
        return 'Borrowed';
      case 'subscription':
        return 'Subscription';
      default:
        return 'Item Details';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = _getName(item);
    final String? description = _getDescription(item);
    final double amount = _getAmount(item);
    final DateTime due = _getDueDate(item);
    final String status = _getStatus(item);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildCustomAppBar(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(
                          name,
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                        ),
                        if (description != null && description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.secondaryTextColorLight,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoCard(
                        context,
                        'Amount',
                        _formatCurrency(amount, Provider.of<CurrencyProvider>(context).currencySymbol),
                      ),
                      const SizedBox(width: 12),
                      _buildInfoCard(
                        context,
                        'Status',
                        status,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'DATE',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.secondaryTextColorLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('MMMM d, yyyy').format(due).toUpperCase(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    itemType.toLowerCase() == 'subscription' ? 'HISTORY' : 'DETAILS',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryTextColorLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: itemType.toLowerCase() == 'subscription'
                        ? _buildSubscriptionHistory(context, item as Subscription)
                        : _buildPersonalDetails(context),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: Text(
                            'Delete',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 14),
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
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6),
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
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
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
              Expanded(
                child: Center(
                  child: Text(
                    getAppBarTitle(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryTextColorLight,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primaryTextColorLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionHistory(BuildContext context, Subscription sub) {
    final entries = sub.history;
    if (entries.isEmpty) {
      return Center(
        child: Text(
          'No history yet',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.secondaryTextColorLight,
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _buildHistoryItem(context, entry);
      },
    );
  }

  Widget _buildHistoryItem(BuildContext context, TransactionHistoryEntry entry) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const HugeIcon(
              icon: HugeIcons.strokeRoundedHome01,
              color: Colors.black87,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.note ?? 'Charge',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMM d, yyyy').format(entry.timestamp),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '+ ${_formatCurrency(entry.amount, Provider.of<CurrencyProvider>(context).currencySymbol)}',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetails(BuildContext context) {
    final DateTime start = _getStartDate(item);
    final String typeLabel = itemType.toLowerCase() == 'lent' ? 'Lent On' : 'Borrowed On';
    final bool returned = _isReturned(item);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                typeLabel.toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryTextColorLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateFormat('MMMM d, yyyy').format(start).toUpperCase(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RETURNED',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryTextColorLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                returned ? 'YES' : 'NO',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: returned ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value, String currencySymbol) {
    return '$currencySymbol${NumberFormat('#,##0.00').format(value)}';
  }

  String _getName(Object item) {
    if (item is Subscription) return item.name;
    if (item is Borrowed) return item.name;
    if (item is Lent) return item.name;
    return 'Item';
  }

  String? _getDescription(Object item) {
    if (item is Borrowed) return item.description;
    if (item is Lent) return item.description;
    return null;
  }

  double _getAmount(Object item) {
    if (item is Subscription) return item.price;
    if (item is Borrowed) return item.price;
    if (item is Lent) return item.price;
    return 0.0;
  }

  DateTime _getDueDate(Object item) {
    if (item is Subscription) return item.dueDate;
    if (item is Borrowed) return item.dueDate;
    if (item is Lent) return item.dueDate;
    return DateTime.now();
  }

  DateTime _getStartDate(Object item) {
    if (item is Subscription) return item.date;
    if (item is Borrowed) return item.date;
    if (item is Lent) return item.date;
    return DateTime.now();
  }

  String _getStatus(Object item) {
    if (item is Subscription) return item.isActive ? 'Active' : 'Inactive';
    if (item is Borrowed) return item.returned ? 'Returned' : 'Not Returned';
    if (item is Lent) return item.returned ? 'Returned' : 'Not Returned';
    return 'Unknown';
  }

  bool _isReturned(Object item) {
    if (item is Borrowed) return item.returned;
    if (item is Lent) return item.returned;
    return false;
  }
}