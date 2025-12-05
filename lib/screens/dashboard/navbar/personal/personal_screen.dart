import 'package:flutter/material.dart';
import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/generated/i18n/app_localizations.dart';
import 'package:budgetm/models/personal/borrowed.dart';
import 'package:budgetm/models/personal/lent.dart';
import 'package:budgetm/models/personal/subscription.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:budgetm/utils/currency_formatter.dart';
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
  String? _filterCurrency; // Null means "All" or default to user's currency if needed

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
                AppLocalizations.of(context)!.personalTitle,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, size: 16, color: Colors.black),
                      const SizedBox(width: 6),
                      Text(
                        _isSubscriptionsSelected
                            ? AppLocalizations.of(
                                context,
                              )!.personalAddSubscription
                            : _isBorrowedSelected
                            ? AppLocalizations.of(context)!.personalAddBorrowed
                            : AppLocalizations.of(context)!.personalAddLent,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    if (_isSubscriptionsSelected) {
                      await PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: const AddSubscriptionScreen(),
                        withNavBar: false,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    } else if (_isBorrowedSelected) {
                      await PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: const AddBorrowedScreen(),
                        withNavBar: false,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    } else if (_isLentSelected) {
                      await PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: const AddLentScreen(),
                        withNavBar: false,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isRTL = Directionality.of(context) == TextDirection.RTL;
              // Build pills in the correct visual order for LTR/RTL
              final pills = isRTL
                  ? [
                      (
                        label: AppLocalizations.of(context)!.personalScreenLent,
                        selected: _isLentSelected,
                        onTap: () {
                          setState(() {
                            _isSubscriptionsSelected = false;
                            _isBorrowedSelected = false;
                            _isLentSelected = true;
                          });
                        },
                      ),
                      (
                        label: AppLocalizations.of(context)!.personalScreenBorrowed,
                        selected: _isBorrowedSelected,
                        onTap: () {
                          setState(() {
                            _isSubscriptionsSelected = false;
                            _isBorrowedSelected = true;
                            _isLentSelected = false;
                          });
                        },
                      ),
                      (
                        label: AppLocalizations.of(context)!.personalScreenSubscriptions,
                        selected: _isSubscriptionsSelected,
                        onTap: () {
                          setState(() {
                            _isSubscriptionsSelected = true;
                            _isBorrowedSelected = false;
                            _isLentSelected = false;
                          });
                        },
                      ),
                    ]
                  : [
                      (
                        label: AppLocalizations.of(context)!.personalScreenSubscriptions,
                        selected: _isSubscriptionsSelected,
                        onTap: () {
                          setState(() {
                            _isSubscriptionsSelected = true;
                            _isBorrowedSelected = false;
                            _isLentSelected = false;
                          });
                        },
                      ),
                      (
                        label: AppLocalizations.of(context)!.personalScreenBorrowed,
                        selected: _isBorrowedSelected,
                        onTap: () {
                          setState(() {
                            _isSubscriptionsSelected = false;
                            _isBorrowedSelected = true;
                            _isLentSelected = false;
                          });
                        },
                      ),
                      (
                        label: AppLocalizations.of(context)!.personalScreenLent,
                        selected: _isLentSelected,
                        onTap: () {
                          setState(() {
                            _isSubscriptionsSelected = false;
                            _isBorrowedSelected = false;
                            _isLentSelected = true;
                          });
                        },
                      ),
                    ];

              // Compute index for selected pill from this dynamic array
              int selectedIndex = pills.indexWhere((pill) => pill.selected);

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
                      left: (width / 3) * selectedIndex,
                      right: width - (width / 3) * (selectedIndex + 1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.gradientEnd,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        height: 45,
                      ),
                    ),
                    Row(
                      children: List.generate(3, (i) {
                        final pill = pills[i];
                        return Expanded(
                          child: _buildChip(pill.label, pill.selected, pill.onTap),
                        );
                      }),
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
          // Filter first
          final filteredData = _filterCurrency == null
              ? snapshot.data!
              : snapshot.data!.where((s) => s.currency == _filterCurrency).toList();

          // If mixed currencies (no filter selected), we can't simply sum them up properly without conversion.
          // For now, if no filter is selected, we might want to show a message or just sum them (which is technically wrong but common in simple apps).
          // OR, we can group by currency.
          // Let's stick to the user request: "Currency selector would then save the currency... subscriptions in personal screen are by a specific currency"
          // This implies we should probably default to showing the user's main currency or force a filter if multiple exist.
          // But for a simple "Total" card, if we have mixed currencies and no filter, showing a sum is misleading.
          
          // Better approach: If filter is active, show sum in that currency.
          // If no filter, show sum in user's default currency (converting if possible, but we don't have rates easily here without async).
          // OR: Just show the sum of the *filtered* list. If "All" is selected, maybe show "Mixed"?
          
          // Let's go with: Sum of filtered items. If "All", we sum everything (naive) but show the currency of the first item or user default.
          // Actually, if "All" is selected and we have multiple currencies, showing a single total is bad.
          // Let's try to be smart: If multiple currencies exist and filter is "All", show "Multi" or similar.
          
          final uniqueCurrencies = filteredData.map((s) => s.currency).toSet();
          
          if (uniqueCurrencies.length > 1) {
             return Expanded(
              child: _buildInfoCard(
                context,
                AppLocalizations.of(context)!.personalScreenTotal,
                'Mixed', // Or "..."
              ),
            );
          }

          final total = filteredData.fold(
            0.0,
            (sum, item) => sum + item.price,
          );
          
          final displayCurrency = uniqueCurrencies.isEmpty 
              ? 'USD' 
              : uniqueCurrencies.first;

          return Expanded(
            child: _buildInfoCard(
              context,
              AppLocalizations.of(context)!.personalScreenTotal,
              formatCurrency(total, displayCurrency),
            ),
          );
        }
        return Expanded(
          child: _buildInfoCard(
            context,
            AppLocalizations.of(context)!.personalScreenTotal,
            'USD 0.00',
          ),
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
              AppLocalizations.of(context)!.personalScreenTotal,
              '${snapshot.data!.length} ${AppLocalizations.of(context)!.personalItems}',
            );
          }
          return _buildInfoCard(
            context,
            AppLocalizations.of(context)!.personalScreenTotal,
            '0 ${AppLocalizations.of(context)!.personalItems}',
          );
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
              AppLocalizations.of(context)!.personalScreenTotal,
              '${snapshot.data!.length} ${AppLocalizations.of(context)!.personalItems}',
            );
          }
          return _buildInfoCard(context, AppLocalizations.of(context)!.personalScreenTotal, '0 ${AppLocalizations.of(context)!.personalItems}');
        },
      ),
    );
  }

  Widget _buildSubscriptionActiveCard() {
    return StreamBuilder<List<Subscription>>(
      stream: _firestoreService.streamSubscriptions(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final filteredData = _filterCurrency == null
              ? snapshot.data!
              : snapshot.data!.where((s) => s.currency == _filterCurrency).toList();
              
          final activeCount = filteredData.where((s) => s.isActive).length;
          return Expanded(
            child: _buildInfoCard(
              context,
              AppLocalizations.of(context)!.personalScreenActive,
              '$activeCount/${filteredData.length}',
            ),
          );
        }
        return Expanded(
          child: _buildInfoCard(
            context,
            AppLocalizations.of(context)!.personalScreenActive,
            '0/0',
          ),
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
              AppLocalizations.of(context)!.personalActive,
              '$activeCount/${snapshot.data!.length}',
            );
          }
          return _buildInfoCard(context, AppLocalizations.of(context)!.personalActive, '0/0');
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
              AppLocalizations.of(context)!.personalActive,
              '$activeCount/${snapshot.data!.length}',
            );
          }
          return _buildInfoCard(context, AppLocalizations.of(context)!.personalActive, '0/0');
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                child: Text(
                  AppLocalizations.of(context)!.personalSubscriptions,
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              // Currency Filter
              StreamBuilder<List<Subscription>>(
                stream: _firestoreService.streamSubscriptions(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  
                  // Extract unique currencies
                  final currencies = snapshot.data!
                      .map((s) => s.currency)
                      .toSet()
                      .toList();
                  
                  if (currencies.length <= 1) return const SizedBox.shrink();

                  return Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButton<String>(
                      value: _filterCurrency,
                      hint: Text(
                        'All',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down, size: 16),
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                      onChanged: (String? newValue) {
                        setState(() {
                          _filterCurrency = newValue;
                        });
                      },
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All'),
                        ),
                        ...currencies.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          StreamBuilder<List<Subscription>>(
            stream: _firestoreService.streamSubscriptions(),
            builder: (context, snapshot) {
              // Only show loading if we have no data at all
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    AppLocalizations.of(context)!.personalScreenNoSubscriptions,
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              // Filter subscriptions
              final filteredSubscriptions = _filterCurrency == null
                  ? snapshot.data!
                  : snapshot.data!.where((s) => s.currency == _filterCurrency).toList();

              if (filteredSubscriptions.isEmpty) {
                 return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'No subscriptions in $_filterCurrency',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return Column(
                children: filteredSubscriptions
                    .map((subscription) => _buildSubscriptionItem(subscription))
                    .toList(),
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
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 12.0,
            ),
            child: Text(
              AppLocalizations.of(context)!.personalScreenBorrowedItems,
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
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    AppLocalizations.of(context)!.personalScreenNoBorrowed,
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              return Column(
                children: snapshot.data!
                    .map((item) => _buildBorrowedItem(item))
                    .toList(),
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
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 12.0,
            ),
            child: Text(
              AppLocalizations.of(context)!.personalScreenLentItems,
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
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    AppLocalizations.of(context)!.personalScreenNoLent,
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              return Column(
                children: snapshot.data!
                    .map((item) => _buildLentItem(item))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionItem(Subscription subscription) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final progressColor = subscription.isActive
        ? AppColors.gradientEnd
        : Colors.grey;

    return GestureDetector(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: DetailedItemScreen(
            itemType: 'subscription',
            item: subscription,
          ),
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
                  formatCurrency(subscription.price, subscription.currency),
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
                  '${AppLocalizations.of(context)!.personalNextBilling}: ${dateFormat.format(subscription.nextBillingDate)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                if (subscription.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gradientEnd.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.personalActive,
                      style: const TextStyle(
                        color: AppColors.gradientEnd,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.personalInactive,
                      style: const TextStyle(
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
                  formatCurrency(item.price, item.currency),
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
                  '${AppLocalizations.of(context)!.personalDue}: ${dateFormat.format(item.dueDate)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                if (!item.returned)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gradientEnd.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.personalBorrowed,
                      style: const TextStyle(
                        color: AppColors.gradientEnd,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.personalReturned,
                      style: const TextStyle(
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
                  formatCurrency(item.price, item.currency),
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
                  '${AppLocalizations.of(context)!.personalDue}: ${dateFormat.format(item.dueDate)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                if (!item.returned)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gradientEnd.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.personalLent,
                      style: const TextStyle(
                        color: AppColors.gradientEnd,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.personalReturned,
                      style: const TextStyle(
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
