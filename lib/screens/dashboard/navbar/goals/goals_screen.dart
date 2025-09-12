import 'package:budgetm/constants/appColors.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  bool _isPendingSelected = true;

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
                  _isPendingSelected
                      ? _buildPendingGoalsList()
                      : _buildFulfilledGoalsList(),
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
                  'Goals',
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
                  left: _isPendingSelected ? 0 : width / 2 - 5,
                  right: _isPendingSelected ? width / 2 - 5 : 0,
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
                        'Pending Goals',
                        _isPendingSelected,
                        () => setState(() => _isPendingSelected = true),
                      ),
                    ),
                    Expanded(
                      child: _buildChip(
                        'Fulfilled Goals',
                        !_isPendingSelected,
                        () => setState(() => _isPendingSelected = false),
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
            _isPendingSelected ? '+ \$3,456.98' : '-\$500',
          ),
          const SizedBox(width: 16),
          _buildInfoCard(
            context,
            'Fulfilled Goals',
            _isPendingSelected ? '0/1' : '1/1',
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

  Widget _buildPendingGoalsList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Text(
              'UNFULFILLED GOALS',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          _buildGoalItem(
            icon: HugeIcons.strokeRoundedHome01,
            title: 'Home',
            savedAmount: 20.00,
            currentAmount: 24000,
            totalAmount: 100000,
          ),
          _buildGoalItem(
            icon: HugeIcons.strokeRoundedHome01,
            title: 'Home',
            description: 'Here is your descriptionn goes',
            savedAmount: 20.00,
            currentAmount: 24000,
            totalAmount: 100000,
          ),
        ],
      ),
    );
  }

  Widget _buildFulfilledGoalsList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Text(
              'FULFILLED GOALS',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          _buildGoalItem(
            icon: HugeIcons.strokeRoundedCar01,
            title: 'New Car',
            description: 'Tesla Model Y',
            savedAmount: 50000.00,
            currentAmount: 50000,
            totalAmount: 50000,
            isFulfilled: true,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem({
    required List<List<dynamic>> icon,
    required String title,
    String? description,
    required double savedAmount,
    required double currentAmount,
    required double totalAmount,
    bool isFulfilled = false,
  }) {
    final double progress = totalAmount > 0 ? currentAmount / totalAmount : 0;
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );
    final totalFormat = NumberFormat.compactCurrency(symbol: '\$');
    final progressColor = isFulfilled ? Colors.green : AppColors.gradientEnd;

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
                child: HugeIcon(icon: icon, size: 24, color: progressColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isFulfilled)
                const Icon(Icons.check_circle, color: Colors.green, size: 28)
              else
                Text(
                  currencyFormat.format(savedAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                color: progressColor,
                minHeight: 6,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    totalFormat.format(totalAmount),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isFulfilled ? Colors.green : Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
