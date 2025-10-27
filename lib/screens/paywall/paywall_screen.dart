import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/viewmodels/subscription_provider.dart';
import 'package:flutter/services.dart'; // Import for PlatformException
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart'; // Import RevenueCat

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  // Store the selected RevenueCat Package
  Package? _selectedPackage;
  bool _isPurchasing = false;

  @override
  Widget build(BuildContext context) {
    // Get offerings from the provider
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);
    final offerings = subscriptionProvider.offerings;

    // Get the current offering (e.g., 'default')
    final currentOffering = offerings?.current;

    // Get the monthly and yearly packages from the offering
    final monthlyPackage = currentOffering?.monthly;
    final yearlyPackage = currentOffering?.annual; // RevenueCat uses 'annual'

    // Set default selected package if not already set
    if (_selectedPackage == null && yearlyPackage != null) {
      _selectedPackage = yearlyPackage;
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      // Use Stack to layer the sticky button over the scrollable content
      body: Stack(
        children: [
          // Scrollable content area
          Positioned.fill(
            bottom: 90, // Reserve space for the sticky button container
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12.0,
              ),
              child: (subscriptionProvider.isLoading && offerings == null)
                  // Show loading spinner while offerings are being fetched
                  ? const Center(
                      heightFactor: 15,
                      child: CircularProgressIndicator(),
                    )
                  // Show error if no offerings are found
                  : (currentOffering == null)
                      ? Center(
                          heightFactor: 15,
                          child: Text(
                            'Could not load plans.\nPlease try again later.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.secondaryTextColorLight,
                                ),
                          ),
                        )
                      // Show paywall content
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: kToolbarHeight - 20,
                            ),
                            // Crown Icon
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orangeAccent.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.sim_card_download_rounded,
                                color: Colors.orange,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Title
                            Text(
                              'Choose Your Plan',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryTextColorLight,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            // Subtitle
                            Text(
                              'Invest in your financial freedom today',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.secondaryTextColorLight,
                                    fontSize: 14,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            // --- Refactored Dynamic Plan Cards ---
                            if (monthlyPackage != null)
                              _buildPlanCard(
                                context: context,
                                package: monthlyPackage,
                                // These are examples, you can calculate this
                                pricePerDay: '\$0.43/day',
                                isPopular: true,
                                isSelected: _selectedPackage == monthlyPackage,
                                onTap: () =>
                                    setState(() => _selectedPackage = monthlyPackage),
                              ),

                            const SizedBox(height: 16),

                            if (yearlyPackage != null)
                              _buildPlanCard(
                                context: context,
                                package: yearlyPackage,
                                // These are examples, you can calculate this
                                pricePerDay: '\$0.14/day',
                                saveAmount: 'Save \$209', // Example
                                isBestValue: true,
                                isSelected: _selectedPackage == yearlyPackage,
                                onTap: () =>
                                    setState(() => _selectedPackage = yearlyPackage),
                              ),
                            // ------------------------------------

                            const SizedBox(height: 24),
                            // Features Section
                            Text(
                              'Everything included:',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryTextColorLight,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            _buildFeatureItem(context, 'Personalized budget insights',
                                Icons.insights),
                            _buildFeatureItem(context, 'Daily progress tracking',
                                Icons.trending_up),
                            _buildFeatureItem(context, 'Expense management tools',
                                Icons.account_balance_wallet),
                            _buildFeatureItem(context, 'Financial health timeline',
                                Icons.timeline),
                            _buildFeatureItem(
                                context, 'Expert guidance & tips', Icons.lightbulb),
                            _buildFeatureItem(context, 'Community support access',
                                Icons.people),
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
                                    'Save your finances and future',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade800,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Average user saves ~\u00A32,500 per year by budgeting effectively',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.green.shade600),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
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
                // --- Refactored onPressed with RevenueCat Purchase Logic ---
                onPressed: _isPurchasing
                    ? null // Disable button while purchase is in progress
                    : () async {
                        if (_selectedPackage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a plan.'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        setState(() {
                          _isPurchasing = true;
                        });

                        try {
                          // Make the purchase
                          // *** FIX 1: 'purchasePackage' returns 'PurchaseResult' ***
                          PurchaseResult purchaseResult =
                              await Purchases.purchasePackage(_selectedPackage!);

                          // Check if the "pro" entitlement is now active
                          // *** FIX 1 (continued): Access 'customerInfo' from 'purchaseResult' ***
                          if (purchaseResult.customerInfo.entitlements.active['pro'] != null) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Subscription activated! You now have access to premium features.'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              // Pop the paywall screen on success
                              Navigator.of(context).pop();
                            }
                          }
                        } on PlatformException catch (e) {
                          var errorCode = PurchasesErrorHelper.getErrorCode(e);
                          if (errorCode !=
                              PurchasesErrorCode.purchaseCancelledError) {
                            // Show error if it wasn't a user cancellation
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to purchase: ${e.message}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          // Handle other errors
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('An unexpected error occurred: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isPurchasing = false;
                            });
                          }
                        }
                      },
                // -----------------------------------------------------------
                child: _isPurchasing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Subscribe Your Plan',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white, // Ensure text is visible
                              fontSize: 16,
                            ),
                      ),
              ),
            ),
          ),
          // Restore/Manage links section above the sticky button
          Positioned(
            left: 0,
            right: 0,
            bottom: 90,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () async {
                      final provider = context.read<SubscriptionProvider>();
                      final ok = await provider.restorePurchases();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? 'Purchases restored successfully!'
                                  : 'No active subscription found. You are now on the free plan.',
                            ),
                            backgroundColor: ok ? Colors.green : Colors.orange,
                          ),
                        );
                        if (ok) Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Restore purchases'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final provider = context.read<SubscriptionProvider>();
                      await provider.openManagementPage();
                    },
                    child: const Text('Manage subscription'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Refactored _buildPlanCard to use RevenueCat's 'Package' ---
  Widget _buildPlanCard({
    required BuildContext context,
    required Package package, // Use RevenueCat Package
    required String pricePerDay,
    String? saveAmount,
    required bool isSelected,
    bool isPopular = false,
    bool isBestValue = false,
    required VoidCallback onTap,
  }) {
    // *** FIX 2: Access 'storeProduct' instead of 'product' ***
    final product = package.storeProduct; // Get product details

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
                        product.title, // Dynamic title from RevenueCat
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
                            product.priceString, // Dynamic price from RevenueCat
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryTextColorLight,
                                ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            // Dynamic period
                            package.packageType == PackageType.monthly
                                ? 'per month'
                                : package.packageType == PackageType.annual
                                    ? 'per year'
                                    : '', // Handle other cases if needed
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
                            pricePerDay, // This is still hardcoded, you can calculate it
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

  // --- This function remains unchanged ---
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

