import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/viewmodels/subscription_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

enum Plan { monthly, yearly }

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  Plan _selectedPlan = Plan.yearly; // Yearly plan is selected by default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      // Use Stack to layer the sticky button over the scrollable content
      body: Stack(
        children: [
          // Scrollable content area (takes up all space except the button area)
          Positioned.fill(
            bottom: 90, // Reserve space for the sticky button container
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: kToolbarHeight - 20,
                  ), // Reduced space for status bar + potential app bar area
                  // Crown Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.sim_card_download_rounded, // Using Material Icon as HugeIcons might not have a direct match
                      color: Colors.orange,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    'Choose Your Plan',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 24, // Reduced font size
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryTextColorLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  // Subtitle
                  Text(
                    'Invest in your financial freedom today', // Adapted subtitle
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryTextColorLight,
                      fontSize: 14, // Reduced font size
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Plan Selection Cards
                  _buildPlanCard(
                    context: context,
                    plan: Plan.monthly,
                    title: 'Monthly Plan',
                    price: '\$12.99',
                    pricePeriod: 'per month',
                    pricePerDay: '\$0.43/day',
                    isSelected: _selectedPlan == Plan.monthly,
                    isPopular: true,
                    onTap: () => setState(() => _selectedPlan = Plan.monthly),
                  ),
                  const SizedBox(height: 16),
                  _buildPlanCard(
                    context: context,
                    plan: Plan.yearly,
                    title: 'Yearly Plan',
                    price: '\$49.99',
                    pricePeriod: 'per year',
                    pricePerDay: '\$0.14/day',
                    saveAmount: 'Save \$209', // Example save amount
                    isSelected: _selectedPlan == Plan.yearly,
                    isBestValue: true,
                    onTap: () => setState(() => _selectedPlan = Plan.yearly),
                  ),
                  const SizedBox(height: 24),
                  // Features Section
                  Text(
                    'Everything included:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryTextColorLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(context, 'Personalized budget insights', Icons.insights),
                  _buildFeatureItem(context, 'Daily progress tracking', Icons.trending_up),
                  _buildFeatureItem(context, 'Expense management tools', Icons.account_balance_wallet),
                  _buildFeatureItem(context, 'Financial health timeline', Icons.timeline),
                  _buildFeatureItem(context, 'Expert guidance & tips', Icons.lightbulb),
                  _buildFeatureItem(context, 'Community support access', Icons.people),
                  const SizedBox(height: 24),
                  // Savings Box
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: Colors.green.shade100),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.green.shade200,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.green,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Save your finances and future', // Adapted text
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Average user saves ~\u00A32,500 per year by budgeting effectively', // Adapted text
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.green.shade600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ), // Extra space before the sticky button area starts
                ],
              ),
            ),
          ),
          // Sticky Bottom Button Container
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                24,
                16,
                24,
                30,
              ), // Adjust padding as needed
              color: AppColors.scaffoldBackground, // Match scaffold background
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.gradientEnd, // Use app's button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  // For development: Set subscription flag to true
                  final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);
                  final success = await subscriptionProvider.subscribeUser();
                  
                  if (success) {
                    // Show success message
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Subscription activated! You now have access to premium features.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      // Navigate back
                      Navigator.of(context).pop();
                    }
                  } else {
                    // Show error message
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to activate subscription: ${subscriptionProvider.error}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  'Subscribe Your Plan',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white, // Ensure text is visible
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required BuildContext context,
    required Plan plan,
    required String title,
    required String price,
    required String pricePeriod,
    required String pricePerDay,
    String? saveAmount,
    required bool isSelected,
    bool isPopular = false,
    bool isBestValue = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none, // Allow tags to overflow
        children: [
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: isSelected
                    ? AppColors.gradientEnd
                    : Colors.grey.shade300,
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.gradientEnd.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryTextColorLight,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            price,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryTextColorLight,
                                ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            pricePeriod,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.secondaryTextColorLight,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            pricePerDay,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.secondaryTextColorLight,
                                ),
                          ),
                          if (saveAmount != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                saveAmount,
                                style: TextStyle(
                                  color: Colors.green.shade800,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Custom Radio Button
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.gradientEnd
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.gradientEnd,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
          // Tags (Most Popular / Best Value)
          if (isPopular || isBestValue)
            Positioned(
              top: -10,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isBestValue ? Colors.blue : Colors.purple,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (isBestValue ? Colors.blue : Colors.purple)
                          .withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  isBestValue ? 'Best Value' : 'Most Popular',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.gradientEnd.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: AppColors.gradientEnd),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryTextColorLight,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
