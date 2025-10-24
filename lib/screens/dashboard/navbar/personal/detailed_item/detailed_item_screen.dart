import 'package:flutter/material.dart';
import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:intl/intl.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:budgetm/models/personal/subscription.dart';
import 'package:budgetm/models/personal/borrowed.dart';
import 'package:budgetm/models/personal/lent.dart';

class DetailedItemScreen extends StatefulWidget {
  final String itemType;
  final Object item;

  const DetailedItemScreen({super.key, required this.itemType, required this.item});

  @override
  State<DetailedItemScreen> createState() => _DetailedItemScreenState();
}

class _DetailedItemScreenState extends State<DetailedItemScreen> {
  final FirestoreService _firestoreService = FirestoreService.instance;
  bool _isDeleting = false;
  bool _isUpdating = false;

  String getAppBarTitle() {
    switch (widget.itemType.toLowerCase()) {
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final String name = _getName(widget.item);
    final String? description = _getDescription(widget.item);
    final DateTime due = _getDueDate(widget.item);
    final String status = _getStatus(widget.item);

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
                              '${_getCurrencyCode(_getCurrency(widget.item))} ${_getAmount(widget.item).toStringAsFixed(2)}',
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
                        'DUE DATE',
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
                        // Notes section for borrowed/lent items
                        if (widget.itemType.toLowerCase() != 'subscription' && description != null && description.isNotEmpty) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'NOTES',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.secondaryTextColorLight,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Text(
                                    description,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                        ],
                  // Text(
                  //   widget.itemType.toLowerCase() == 'subscription' ? 'HISTORY' : 'DETAILS',
                  //   style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  //     color: AppColors.secondaryTextColorLight,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  Expanded(
                    child: widget.itemType.toLowerCase() == 'subscription'
                        ? _buildSubscriptionHistory(context, widget.item as Subscription)
                        : _buildPersonalDetails(context),
                  ),
                  const SizedBox(height: 12),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final bool isReturned = _isReturned(widget.item);
    final bool isSubscription = widget.itemType.toLowerCase() == 'subscription';
    
    if (isSubscription) {
      // Only show delete button for subscriptions
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _isDeleting ? null : () => _showDeleteConfirmation(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: _isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Delete',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
        ],
      );
    }
    
    return Row(
      children: [
        if (!isReturned) ...[
          Expanded(
            child: ElevatedButton(
              onPressed: _isUpdating ? null : () => _showMarkAsReturnedConfirmation(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gradientEnd,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: _isUpdating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Mark as Returned',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: ElevatedButton(
            onPressed: _isDeleting ? null : () => _showDeleteConfirmation(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            child: _isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Delete',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _showMarkAsReturnedConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Returned'),
        content: Text('Are you sure you want to mark this ${widget.itemType.toLowerCase()} item as returned?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _markAsReturned();
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete this ${widget.itemType.toLowerCase()} item? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteItem();
    }
  }

  Future<void> _markAsReturned() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      if (widget.itemType.toLowerCase() == 'borrowed') {
        final borrowed = widget.item as Borrowed;
        await _firestoreService.markBorrowedAsReturned(borrowed.id);
      } else if (widget.itemType.toLowerCase() == 'lent') {
        final lent = widget.item as Lent;
        await _firestoreService.markLentAsReturned(lent.id);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item marked as returned successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _deleteItem() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      if (widget.itemType.toLowerCase() == 'borrowed') {
        final borrowed = widget.item as Borrowed;
        await _firestoreService.deleteBorrowed(borrowed.id);
      } else if (widget.itemType.toLowerCase() == 'lent') {
        final lent = widget.item as Lent;
        await _firestoreService.deleteLent(lent.id);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item deleted successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
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
            '+ ${_getCurrencyCode(_getCurrency(widget.item))} ${entry.amount.toStringAsFixed(2)}',
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
    final DateTime start = _getStartDate(widget.item);
    final String typeLabel = widget.itemType.toLowerCase() == 'lent' ? 'Lent On' : 'Borrowed On';
    final bool returned = _isReturned(widget.item);
    return Column(
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
        const SizedBox(height: 16),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: returned ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: returned ? Colors.green.shade200 : Colors.red.shade200,
                ),
              ),
              child: Text(
                returned ? 'YES' : 'NO',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: returned ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getCurrencyCode(String currencyCode) {
    return currencyCode;
  }

  String _getCurrency(Object item) {
    if (item is Borrowed) return item.currency;
    if (item is Lent) return item.currency;
    return 'USD';
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