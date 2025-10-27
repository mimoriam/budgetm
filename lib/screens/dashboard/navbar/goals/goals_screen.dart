import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/constants/goal_type_enum.dart';
import 'package:budgetm/models/goal.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/utils/icon_utils.dart';
import 'package:budgetm/utils/appTheme.dart';
import 'package:budgetm/viewmodels/navbar_visibility_provider.dart';
import 'package:budgetm/viewmodels/goals_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

import 'goals_detailed/goals_detailed_screen.dart';
import 'create_goal/create_goal_screen.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  bool _isPendingSelected = true;
  late ScrollController _scrollController;
  List<FirestoreGoal> _cachedGoals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final provider = Provider.of<NavbarVisibilityProvider>(
        context,
        listen: false,
      );
      final direction = _scrollController.position.userScrollDirection;

      if (direction == ScrollDirection.reverse) {
        provider.setNavBarVisibility(false);
      } else if (direction == ScrollDirection.forward) {
        provider.setNavBarVisibility(true);
      }
    });
    
    // Load goals once and cache them
    _loadGoals();
    
    // Listen to GoalsProvider for changes (e.g., when transactions are added)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final goalsProvider = Provider.of<GoalsProvider>(context, listen: false);
      goalsProvider.addListener(_onGoalsProviderChanged);
    });
  }

  Future<void> _loadGoals() async {
    print('GoalsScreen: Starting to load goals');
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get goals from FirestoreService directly instead of using stream
      final goals = await FirestoreService.instance.getAllGoals();
      print('GoalsScreen: Loaded ${goals.length} goals');
      
      // Calculate current amounts for each goal based on transactions
      final updatedGoals = <FirestoreGoal>[];
      for (final goal in goals) {
        final calculatedAmount = await FirestoreService.instance.calculateGoalCurrentAmount(goal.id);
        print('GoalsScreen: Goal ${goal.name} - stored: ${goal.currentAmount}, calculated: $calculatedAmount');
        
        // Create a new goal with calculated current amount
        final updatedGoal = FirestoreGoal(
          id: goal.id,
          name: goal.name,
          description: goal.description,
          targetAmount: goal.targetAmount,
          currentAmount: calculatedAmount, // Use calculated amount
          creationDate: goal.creationDate,
          targetDate: goal.targetDate,
          isCompleted: calculatedAmount >= goal.targetAmount, // Update completion status
          userId: goal.userId,
          icon: goal.icon,
          color: goal.color,
          currency: goal.currency,
        );
        updatedGoals.add(updatedGoal);
      }
      
      if (mounted) {
        setState(() {
          _cachedGoals = updatedGoals;
          _isLoading = false;
        });
        print('GoalsScreen: Goals loaded successfully with calculated amounts, UI updated');
      }
    } catch (e) {
      print('GoalsScreen: Error loading goals: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Method to refresh goals (can be called when returning from detail screen)
  Future<void> refreshGoals() async {
    print('GoalsScreen: Refreshing goals');
    await _loadGoals();
  }

  // Callback for GoalsProvider changes
  void _onGoalsProviderChanged() {
    print('GoalsScreen: GoalsProvider changed, refreshing goals');
    if (mounted) {
      refreshGoals();
    }
  }

  @override
  void dispose() {
    // Remove listener before disposing
    try {
      final goalsProvider = Provider.of<GoalsProvider>(context, listen: false);
      goalsProvider.removeListener(_onGoalsProviderChanged);
    } catch (e) {
      // Provider might not be available during disposal
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildCustomAppBar(context),
          _buildToggleChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _cachedGoals.isEmpty
                    ? SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: _buildEmptyState(),
                        ),
                      )
                    : _buildGoalsContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsContent() {
    // No currency filtering - show all goals
    final pendingGoals = _cachedGoals.where((g) => g.isCompleted == false).toList();
    final fulfilledGoals = _cachedGoals.where((g) => g.isCompleted == true).toList();

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildInfoCards(pendingGoals, fulfilledGoals, _cachedGoals),
          _isPendingSelected
              ? _buildPendingGoalsList(pendingGoals)
              : _buildFulfilledGoalsList(fulfilledGoals),
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
                'Goals',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
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
                      const Text(
                        "Add Goal",
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 12),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    await PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: const CreateGoalScreen(goalType: GoalType.pending),
                      withNavBar: false,
                      pageTransitionAnimation: PageTransitionAnimation.cupertino,
                    );
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))]
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

  Widget _buildInfoCards(List<FirestoreGoal> pendingGoals, List<FirestoreGoal> fulfilledGoals, List<FirestoreGoal> allGoals) {
    // Count fulfilled/unfulfilled goals across ALL currencies
    final int fulfilledCount = fulfilledGoals.length;
    final int totalCount = allGoals.length;
    final String fulfilledRatio = '$fulfilledCount / $totalCount';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Fulfilled ratio card centered
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: _buildInfoCard(
                context,
                'Fulfilled Goals',
                fulfilledRatio,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildInfoCard(BuildContext context, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          const SizedBox(height: 4),
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

  Widget _buildPendingGoalsList(List<FirestoreGoal> goals) {
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
          ...goals.map((goal) => _buildGoalItem(goal)),
        ],
      ),
    );
  }

  Widget _buildFulfilledGoalsList(List<FirestoreGoal> goals) {
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
          ...goals.map((goal) => _buildGoalItem(goal)),
        ],
      ),
    );
  }

  Widget _buildGoalItem(FirestoreGoal goal) {
    // Calculate progress using the goal's current amount (which is now calculated from transactions)
    final double progress =
        goal.targetAmount > 0 ? goal.currentAmount / goal.targetAmount : 0;
    
    // Use goal's custom color if available, otherwise fallback to default behavior
    final Color iconBackgroundColor = goal.color != null 
        ? hexToColor(goal.color) 
        : (goal.isCompleted ? Colors.green : AppColors.gradientEnd);
    final Color iconForegroundColor = getContrastingColor(iconBackgroundColor);

    return GestureDetector(
      onTap: () async {
        print('GoalsScreen: Navigating to goal detail for goal: ${goal.name}');
        final result = await PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: GoalDetailScreen(goal: goal),
          withNavBar: false,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
        
        print('GoalsScreen: Returned from goal detail, result: $result');
        // Refresh goals when returning from detail screen if needed
        if (result == true && mounted) {
          print('GoalsScreen: Goal was modified, refreshing goals');
          await refreshGoals();
        }
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
                    color: iconBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: HugeIcon(
                    icon: getIcon(goal.icon),
                    size: 24,
                    color: iconForegroundColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (goal.description != null && goal.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          goal.description!,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (goal.isCompleted)
                  const Icon(Icons.check_circle, color: Colors.green, size: 28)
                else
                  Text(
                    '${goal.currency} ${NumberFormat('#,##0.00').format(goal.currentAmount)}',
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
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.green,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${goal.currency} ${NumberFormat('#,##0.00').format(goal.targetAmount)}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        children: [
          Image.asset(
            'images/launcher/logo.png',
            width: 80,
            height: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No goals created',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by creating a goal to track your progress here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
