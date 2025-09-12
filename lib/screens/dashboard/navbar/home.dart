import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/models/transaction.dart';
import 'package:budgetm/screens/dashboard/navbar/home/expense_detail/expense_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _scrollController;
  List<DateTime> _months = [];
  int _selectedMonthIndex = 0;

  final List<Transaction> _transactions = [
    Transaction(
      title: 'Shopping',
      description: 'Here is your description goes',
      amount: 20.00,
      type: TransactionType.expense,
      date: DateTime(2025, 8, 10),
      icon: HugeIcon(
        icon: HugeIcons.strokeRoundedShoppingBag01,
        size: 22,
        color: Colors.orange.shade800,
      ),
      iconBackgroundColor: Colors.orange.shade100,
    ),
    Transaction(
      title: 'Movie Ticket',
      description: 'Here is your description goes',
      amount: 200.00,
      type: TransactionType.income,
      date: DateTime(2025, 8, 10),
      icon: HugeIcon(
        icon: HugeIcons.strokeRoundedTicket01,
        size: 22,
        color: Colors.blue.shade800,
      ),
      iconBackgroundColor: Colors.blue.shade100,
    ),
    Transaction(
      title: 'Amazon',
      description: 'Here is your description goes',
      amount: 200.00,
      type: TransactionType.income,
      date: DateTime(2025, 8, 12),
      icon: HugeIcon(
        icon: HugeIcons.strokeRoundedShoppingCart01,
        size: 22,
        color: Colors.indigo.shade800,
      ),
      iconBackgroundColor: Colors.indigo.shade100,
    ),
    Transaction(
      title: 'Udemy',
      description: 'Here is your description goes',
      amount: 20.00,
      type: TransactionType.expense,
      date: DateTime(2025, 8, 12),
      icon: HugeIcon(
        icon: HugeIcons.strokeRoundedAddressBook,
        size: 22,
        color: Colors.purple.shade800,
      ),
      iconBackgroundColor: Colors.purple.shade100,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadMonths();
  }

  Future<void> _loadMonths() async {
    final prefs = await SharedPreferences.getInstance();
    final firstLoginDateString = prefs.getString('firstLoginDate');
    final firstLoginDate = firstLoginDateString != null
        ? DateTime.parse(firstLoginDateString)
        : DateTime.now();

    final now = DateTime.now();
    List<DateTime> generatedMonths = [];
    DateTime currentDate = DateTime(firstLoginDate.year, firstLoginDate.month);

    while (currentDate.isBefore(
      DateTime(now.year, now.month).add(const Duration(days: 365)),
    )) {
      generatedMonths.add(currentDate);
      currentDate = DateTime(currentDate.year, currentDate.month + 1);
    }

    setState(() {
      _months = generatedMonths;
      _selectedMonthIndex = _months.indexWhere(
        (month) => month.year == now.year && month.month == now.month,
      );
      if (_selectedMonthIndex == -1) {
        _selectedMonthIndex = _months.length - 13;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollToSelectedMonth();
      }
    });
  }

  void _scrollToSelectedMonth() {
    if (_selectedMonthIndex != -1) {
      final screenWidth = MediaQuery.of(context).size.width;
      const itemWidth = 85.0; // Adjusted width
      final offset =
          (_selectedMonthIndex * itemWidth) -
          (screenWidth / 2) +
          (itemWidth / 2);
      _scrollController.animateTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.gradientStart, AppColors.gradientEnd2],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.3, 1.0],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Column(
                children: [_buildMonthSelector(), _buildBalanceCards()],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            _buildTransactionSection(),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.gradientStart,
      elevation: 0,
      toolbarHeight: 100,
      pinned: true,
      floating: true,
      snap: true,
      automaticallyImplyLeading: false,
      title: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage('images/avatar.png'),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'August Balance',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '\$ 75,259.00',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAppBarButton(HugeIcons.strokeRoundedAiWebBrowsing),
                  _buildAppBarButton(HugeIcons.strokeRoundedChartAverage),
                  _buildAppBarButton(HugeIcons.strokeRoundedSchoolBell01),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarButton(List<List<dynamic>> icon) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(left: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: () {},
        icon: HugeIcon(icon: icon, color: Colors.black87, size: 22),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _months.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          final month = _months[index];
          final isSelected = index == _selectedMonthIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedMonthIndex = index;
              });
            },
            child: Container(
              width: 85,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.buttonBackground
                    : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  DateFormat('MMM yyyy').format(month),
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoCard(
              'Income',
              '+ \$3,456.98',
              Colors.green,
              HugeIcons.strokeRoundedChartUp,
              AppColors.incomeBackground,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildInfoCard(
              'Expense',
              '- \$567.25',
              Colors.red,
              HugeIcons.strokeRoundedChartDown,
              AppColors.expenseBackground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String amount,
    Color color,
    List<List<dynamic>> icon,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          HugeIcon(icon: icon, color: color, size: 28),
        ],
      ),
    );
  }

  SliverFillRemaining _buildTransactionSection() {
    Map<String, List<Transaction>> groupedTransactions = {};
    for (var tx in _transactions) {
      String dateKey = DateFormat('MMM d, yyyy').format(tx.date);
      if (groupedTransactions[dateKey] == null) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(tx);
    }
    List<String> sortedKeys = groupedTransactions.keys.toList();

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Container(
        padding: const EdgeInsets.only(top: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            ...sortedKeys.map((date) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                    child: Text(
                      date.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  ...groupedTransactions[date]!.map(
                    (tx) => _buildTransactionItem(tx),
                  ),
                ],
              );
            }).toList(),
            const SizedBox(height: 70), // To avoid FAB overlap
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    return InkWell(
      onTap: () {
        if (transaction.type == TransactionType.expense) {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: ExpenseDetailScreen(transaction: transaction),
            withNavBar: false,
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: transaction.iconBackgroundColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: transaction.icon,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaction.description,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              '${transaction.type == TransactionType.income ? '+' : '-'} \$${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: transaction.type == TransactionType.income
                    ? Colors.green
                    : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
