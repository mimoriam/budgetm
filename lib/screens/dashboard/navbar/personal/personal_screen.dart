import 'package:flutter/material.dart';
import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/models/personal/borrowed.dart';
import 'package:budgetm/models/personal/lent.dart';
import 'package:budgetm/models/personal/subscription.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'detailed_item/detailed_item_screen.dart';
import 'add_subscription/add_subscription_screen.dart';
import 'add_borrowed/add_borrowed_screen.dart';
import 'add_lent/add_lent_screen.dart';

class PersonalScreen extends StatefulWidget {
  const PersonalScreen({super.key});

  @override
  State<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen> {
  bool _isSubscriptionsSelected = true;
  bool _isBorrowedSelected = false;
  bool _isLentSelected = false;

  final FirestoreService _firestoreService = FirestoreService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildCustomAppBar(context),
          _buildToggleChips(),
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
      padding: const EdgeInsets.only(bottom: 10),
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
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Personal',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  shape: BoxShape.rectangle,
                  gradient: LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, size: 16, color: Colors.black),
                      const SizedBox(width: 6),
                      Text(
                        _isSubscriptionsSelected
                            ? "Add Subscription"
                            : _isBorrowedSelected
                                ? "Add Borrowed"
                                : "Add Lent",
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 12),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    if (_isSubscriptionsSelected) {
                      await PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: const AddSubscriptionScreen(),
                        withNavBar: false,
                        pageTransitionAnimation: PageTransitionAnimation.cupertino,
                      );
                    } else if (_isBorrowedSelected) {
                      await PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: const AddBorrowedScreen(),
                        withNavBar: false,
                        pageTransitionAnimation: PageTransitionAnimation.cupertino,
                      );
                    } else if (_isLentSelected) {
                      await PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: const AddLentScreen(),
                        withNavBar: false,
                        pageTransitionAnimation: PageTransitionAnimation.cupertino,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleChips() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Padding(
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
        ),
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
          _isSubscriptionsSelected
              ? _buildSubscriptionInfoCard()
              : _isBorrowedSelected
                  ? _buildBorrowedInfoCard()
                  : _buildLentInfoCard(),
          const SizedBox(width: 16),
          _isSubscriptionsSelected
              ? _buildSubscriptionActiveCard()
              : _isBorrowedSelected
                  ? _buildBorrowedActiveCard()
                  : _buildLentActiveCard(),
        ],
      ),
    );
  }

  Widget _buildSubscriptionInfoCard() {
    return StreamBuilder<List<Subscription>>(
      stream: _firestoreService.streamSubscriptions(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final total = snapshot.data!.fold(0.0, (sum, item) => sum + item.price);
          return Expanded(
            child: _buildInfoCard(
              context,
              'Total',
              '${snapshot.data!.isNotEmpty ? snapshot.data!.first.currency : 'USD'} ${total.toStringAsFixed(2)}',
            ),
          );
        }
        return Expanded(
          child: _buildInfoCard(context, 'Total', 'USD 0.00'),
        );
      },
    );
  }

  Widget _buildBorrowedInfoCard() {
    return Expanded(
      child: StreamBuilder<List<Borrowed>>(
        stream: _firestoreService.streamBorrowed(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildInfoCard(
              context,
              'Total',
              '${snapshot.data!.length} Item(s)',
            );
          }
          return _buildInfoCard(context, 'Total', '0 Item(s)');
        },
      ),
    );
  }

  Widget _buildLentInfoCard() {
    return Expanded(
      child: StreamBuilder<List<Lent>>(
        stream: _firestoreService.streamLent(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildInfoCard(
              context,
              'Total',
              '${snapshot.data!.length} Item(s)',
            );
          }
          return _buildInfoCard(context, 'Total', '0 Item(s)');
        },
      ),
    );
  }

  Widget _buildSubscriptionActiveCard() {
    return StreamBuilder<List<Subscription>>(
      stream: _firestoreService.streamSubscriptions(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final activeCount = snapshot.data!.where((s) => s.isActive).length;
          return Expanded(
            child: _buildInfoCard(
              context,
              'Active',
              '$activeCount/${snapshot.data!.length}',
            ),
          );
        }
        return Expanded(
          child: _buildInfoCard(context, 'Active', '0/0'),
        );
      },
    );
  }

  Widget _buildBorrowedActiveCard() {
    return Expanded(
      child: StreamBuilder<List<Borrowed>>(
        stream: _firestoreService.streamBorrowed(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final activeCount = snapshot.data!.where((b) => !b.returned).length;
            return _buildInfoCard(
              context,
              'Active',
              '$activeCount/${snapshot.data!.length}',
            );
          }
          return _buildInfoCard(context, 'Active', '0/0');
        },
      ),
    );
  }

  Widget _buildLentActiveCard() {
    return Expanded(
      child: StreamBuilder<List<Lent>>(
        stream: _firestoreService.streamLent(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final activeCount = snapshot.data!.where((l) => !l.returned).length;
            return _buildInfoCard(
              context,
              'Active',
              '$activeCount/${snapshot.data!.length}',
            );
          }
          return _buildInfoCard(context, 'Active', '0/0');
        },
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value) {
    return Container(
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
          StreamBuilder<List<Subscription>>(
            stream: _firestoreService.streamSubscriptions(),
            builder: (context, snapshot) {
              // Only show loading if we have no data at all
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'No subscriptions yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              return Column(
                children: snapshot.data!.map((subscription) => _buildSubscriptionItem(subscription)).toList(),
              );
            },
          ),
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
          StreamBuilder<List<Borrowed>>(
            stream: _firestoreService.streamBorrowed(),
            builder: (context, snapshot) {
              // Only show loading if we have no data at all
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'No borrowed items yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              return Column(
                children: snapshot.data!.map((item) => _buildBorrowedItem(item)).toList(),
              );
            },
          ),
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
          StreamBuilder<List<Lent>>(
            stream: _firestoreService.streamLent(),
            builder: (context, snapshot) {
              // Only show loading if we have no data at all
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'No lent items yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              return Column(
                children: snapshot.data!.map((item) => _buildLentItem(item)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionItem(Subscription subscription) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final progressColor = subscription.isActive ? AppColors.gradientEnd : Colors.grey;

    return GestureDetector(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: DetailedItemScreen(itemType: 'subscription', item: subscription),
          withNavBar: false,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Container(
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
                    icon: HugeIcons.strokeRoundedHome01,
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
                        subscription.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${subscription.currency} ${subscription.price.toStringAsFixed(2)}',
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
      ),
    );
  }

  Widget _buildBorrowedItem(Borrowed item) {
    final currencyFormat = NumberFormat.currency(symbol: item.currency, decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final progressColor = !item.returned ? AppColors.gradientEnd : Colors.grey;

    return GestureDetector(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: DetailedItemScreen(itemType: 'borrowed', item: item),
          withNavBar: false,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Container(
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
                    icon: HugeIcons.strokeRoundedHome01,
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
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  currencyFormat.format(item.price),
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
                  'Due: ${dateFormat.format(item.dueDate)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                if (!item.returned)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gradientEnd.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Borrowed',
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
                      'Returned',
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
      ),
    );
  }

  Widget _buildLentItem(Lent item) {
    final currencyFormat = NumberFormat.currency(symbol: item.currency, decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final progressColor = !item.returned ? AppColors.gradientEnd : Colors.grey;

    return GestureDetector(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: DetailedItemScreen(itemType: 'lent', item: item),
          withNavBar: false,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Container(
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
                    icon: HugeIcons.strokeRoundedHome01,
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
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  currencyFormat.format(item.price),
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
                  'Due: ${dateFormat.format(item.dueDate)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                if (!item.returned)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gradientEnd.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Lent',
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
                      'Returned',
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
      ),
    );
  }

}