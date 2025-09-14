import 'package:flutter/material.dart';
import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/models/subscription.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'add_borrowed/add_borrowed.dart';
import 'add_lent/add_lent.dart';

class PersonalScreen extends StatefulWidget {
  const PersonalScreen({super.key});

  @override
  State<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen > {
  bool _isSubscriptionsSelected = true;
  bool _isBorrowedSelected = false;
  bool _isLentSelected = false;

  final List<Subscription> _subscriptions = [
    Subscription(
      title: 'Netflix',
      amount: 15.99,
      nextBillingDate: DateTime(2025, 10, 15),
      icon: HugeIcons.strokeRoundedHome01, // Placeholder icon
    ),
    Subscription(
      title: 'Spotify',
      description: 'Music streaming service',
      amount: 9.99,
      nextBillingDate: DateTime(2025, 10, 5),
      icon: HugeIcons.strokeRoundedHome01, // Placeholder icon
    ),
  ];

  final List<Subscription> _borrowedItems = [
    Subscription(
      title: 'Book',
      description: 'The Great Gatsby',
      amount: 0.0, // Assuming no monetary value for borrowed items
      nextBillingDate: DateTime(2025, 9, 20),
      icon: HugeIcons.strokeRoundedHome01, // Placeholder icon
      isActive: false,
    ),
  ];

  final List<Subscription> _lentItems = [
    Subscription(
      title: 'Camera',
      description: 'DSLR Camera',
      amount: 0.00, // Assuming no monetary value for lent items
      nextBillingDate: DateTime(2025, 9, 25),
      icon: HugeIcons.strokeRoundedHome01, // Placeholder icon
      isActive: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildCustomAppBar(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildInfoCards(),
                  _isSubscriptionsSelected
                      ? _buildSubscriptionsList()
                      : _isBorrowedSelected
                          ? _buildBorrowedItemsList()
                          : _buildLentItemsList(),
                  const SizedBox(height: 80), // Padding for FAB
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 10,
              ),
              child: Center(
                child: Text(
                  'Personal',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            _buildToggleChips(),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return Container(
            height: 55,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: _isSubscriptionsSelected
                      ? 0
                      : _isBorrowedSelected
                          ? width / 3 - 5
                          : width * 2 / 3 - 5,
                  right: _isSubscriptionsSelected
                      ? width * 2 / 3 - 5
                      : _isBorrowedSelected
                          ? width / 3 - 5
                          : 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.gradientEnd,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    height: 45,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildChip(
                        'Subscriptions',
                        _isSubscriptionsSelected,
                        () {
                          setState(() {
                            _isSubscriptionsSelected = true;
                            _isBorrowedSelected = false;
                            _isLentSelected = false;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildChip(
                        'Borrowed',
                        _isBorrowedSelected,
                        () {
                          setState(() {
                            _isSubscriptionsSelected = false;
                            _isBorrowedSelected = true;
                            _isLentSelected = false;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildChip(
                        'Lent',
                        _isLentSelected,
                        () {
                          setState(() {
                            _isSubscriptionsSelected = false;
                            _isBorrowedSelected = false;
                            _isLentSelected = true;
                          });
                        },
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
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : Colors.black54,
            fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
          ),
          child: Text(label),
        ),
      ),
    );
  }

  Widget _buildInfoCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildInfoCard(
            context,
            'Total',
            _isSubscriptionsSelected
                ? '\$25.98'
                : _isBorrowedSelected
                    ? '1 Item'
                    : '1 Item',
          ),
          const SizedBox(width: 16),
          _buildInfoCard(
            context,
            'Active Membership',
            _isSubscriptionsSelected
                ? '2/2'
                : _isBorrowedSelected
                    ? '0/1'
                    : '0/1',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
            ),
          ],
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
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.primaryTextColorLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionsList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Text(
              'ACTIVE SUBSCRIPTIONS',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          ..._subscriptions.map((subscription) => _buildSubscriptionItem(subscription)),
        ],
      ),
    );
  }

  Widget _buildBorrowedItemsList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Text(
              'BORROWED ITEMS',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          ..._borrowedItems.map((subscription) => _buildSubscriptionItem(subscription)),
        ],
      ),
    );
  }

  Widget _buildLentItemsList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Text(
              'LENT ITEMS',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          ..._lentItems.map((subscription) => _buildSubscriptionItem(subscription)),
        ],
      ),
    );
  }

  Widget _buildSubscriptionItem(Subscription subscription) {
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('MMM dd, yyyy');
    final progressColor = subscription.isActive
        ? AppColors.gradientEnd
        : Colors.grey;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: HugeIcon(
                  icon: subscription.icon,
                  size: 24,
                  color: progressColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (subscription.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subscription.description!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                subscription.isActive
                    ? currencyFormat.format(subscription.amount)
                    : 'Returned',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Next billing: ${dateFormat.format(subscription.nextBillingDate)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              if (subscription.isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gradientEnd.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      color: AppColors.gradientEnd,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Inactive',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
