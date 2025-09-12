import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
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
        size: 24,
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
        size: 24,
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
        size: 24,
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
        size: 24,
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

    // Generate months from first login to 12 months in the future from now
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
        _selectedMonthIndex = _months.length - 13; // Default to current month
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
      const itemWidth = 90.0;
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.gradientEnd,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            _buildTransactionList(),
            const SliverToBoxAdapter(
              child: SizedBox(height: 80), // To avoid FAB overlap
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.gradientStart,
      elevation: 0,
      toolbarHeight: 120,
      pinned: true,
      floating: true,
      snap: true,
      automaticallyImplyLeading: false,
      title: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage('images/avatar.png'),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'August Balance',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '\$ 75,259.00',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAppBarButton(HugeIcons.strokeRoundedFilter),
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
      width: 44,
      height: 44,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: () {},
        icon: HugeIcon(icon: icon, color: Colors.black87, size: 24),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return SizedBox(
      height: 45,
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
              width: 90,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.buttonBackground
                    : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  DateFormat('MMM yyyy').format(month),
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
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
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
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
          const SizedBox(width: 16),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  amount,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          HugeIcon(icon: icon, color: color, size: 30),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildTransactionList() {
    Map<String, List<Transaction>> groupedTransactions = {};
    for (var tx in _transactions) {
      String dateKey = DateFormat('MMM d, yyyy').format(tx.date);
      if (groupedTransactions[dateKey] == null) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(tx);
    }
    List<String> sortedKeys = groupedTransactions.keys.toList();

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.only(top: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: Column(
          children: sortedKeys.map((date) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  child: Text(
                    date.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                ...groupedTransactions[date]!.map(
                  (tx) => _buildTransactionItem(tx),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: transaction.iconBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: transaction.icon,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.description,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
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
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
