import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/generated/i18n/app_localizations.dart';
import 'package:budgetm/viewmodels/subscription_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// REMOVE RevenueCat import
// import 'package:purchases_flutter/purchases_flutter.dart';
// ADD in_app_purchase import
import 'package:in_app_purchase/in_app_purchase.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  // Store the selected in_app_purchase ProductDetails
  // Package? _selectedPackage; // REMOVED
  ProductDetails? _selectedProduct; // ADDED
  bool _isPurchasing = false;

  // TODO: IMPORTANT! Replace these with your actual Product IDs
  // from the App Store and Google Play Console.
  final String _monthlyProductID = 'budgetm_monthly';
  final String _yearlyProductID = 'budgetm_yearly';

  @override
  Widget build(BuildContext context) {
    // Get products from the provider
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);
    // final offerings = subscriptionProvider.offerings; // REMOVED
    final products = subscriptionProvider.products; // ADDED

    // REMOVED RevenueCat-specific package logic
    // final currentOffering = offerings?.current;
    // final monthlyPackage = currentOffering?.monthly;
    // final yearlyPackage = currentOffering?.annual;

    // ADDED logic to find products by their ID
    ProductDetails? monthlyProduct;
    ProductDetails? yearlyProduct;

    if (products.isNotEmpty) {
      try {
        monthlyProduct = products.firstWhere(
          (prod) => prod.id == _monthlyProductID,
        );
      } catch (e) {
        // print('Monthly product not found');
      }
      try {
        yearlyProduct = products.firstWhere(
          (prod) => prod.id == _yearlyProductID,
        );
      } catch (e) {
        // print('Yearly product not found');
      }
    }

    // Set default selected product if not already set
    if (_selectedProduct == null && yearlyProduct != null) {
      _selectedProduct = yearlyProduct;
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
              child:
                  (subscriptionProvider.isLoading &&
                      products.isEmpty) // MODIFIED
                  // Show loading spinner while products are being fetched
                  ? const Center(
                      heightFactor: 15,
                      child: CircularProgressIndicator(),
                    )
                  // Show error if no products are found
                  : (products.isEmpty) // MODIFIED
                  ? Center(
                      heightFactor: 15,
                      child: Text(
                        AppLocalizations.of(context)!.paywallCouldNotLoadPlans,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondaryTextColorLight,
                        ),
                      ),
                    )
                  // Show paywall content
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: kToolbarHeight - 20),
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
                          AppLocalizations.of(context)!.paywallChooseYourPlan,
                          style: Theme.of(context).textTheme.displayLarge
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
                          AppLocalizations.of(
                            context,
                          )!.paywallInvestInFinancialFreedom,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.secondaryTextColorLight,
                                fontSize: 14,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // --- Refactored Dynamic Plan Cards ---
                        if (monthlyProduct != null)
                          _buildPlanCard(
                            context: context,
                            product: monthlyProduct, // MODIFIED
                            // These are examples, you can calculate this
                            pricePerDay: AppLocalizations.of(
                              context,
                            )!.paywallPricePerDay('\$0.43'),
                            isPopular: true,
                            isSelected:
                                _selectedProduct == monthlyProduct, // MODIFIED
                            onTap: () => setState(
                              () => _selectedProduct = monthlyProduct,
                            ), // MODIFIED
                          ),

                        const SizedBox(height: 16),

                        if (yearlyProduct != null)
                          _buildPlanCard(
                            context: context,
                            product: yearlyProduct, // MODIFIED
                            // These are examples, you can calculate this
                            pricePerDay: AppLocalizations.of(
                              context,
                            )!.paywallPricePerDay('\$0.14'),
                            saveAmount: AppLocalizations.of(
                              context,
                            )!.paywallSaveAmount('\$209'), // Example
                            isBestValue: true,
                            isSelected:
                                _selectedProduct == yearlyProduct, // MODIFIED
                            onTap: () => setState(
                              () => _selectedProduct = yearlyProduct,
                            ), // MODIFIED
                          ),

                        // ------------------------------------
                        const SizedBox(height: 24),
                        // Features Section
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.paywallEverythingIncluded,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryTextColorLight,
                              ),
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureItem(
                          context,
                          AppLocalizations.of(
                            context,
                          )!.paywallPersonalizedBudgetInsights,
                          Icons.insights,
                        ),
                        _buildFeatureItem(
                          context,
                          AppLocalizations.of(
                            context,
                          )!.paywallDailyProgressTracking,
                          Icons.trending_up,
                        ),
                        _buildFeatureItem(
                          context,
                          AppLocalizations.of(
                            context,
                          )!.paywallExpenseManagementTools,
                          Icons.account_balance_wallet,
                        ),
                        _buildFeatureItem(
                          context,
                          AppLocalizations.of(
                            context,
                          )!.paywallFinancialHealthTimeline,
                          Icons.timeline,
                        ),
                        _buildFeatureItem(
                          context,
                          AppLocalizations.of(
                            context,
                          )!.paywallExpertGuidanceTips,
                          Icons.lightbulb,
                        ),
                        _buildFeatureItem(
                          context,
                          AppLocalizations.of(
                            context,
                          )!.paywallCommunitySupportAccess,
                          Icons.people,
                        ),
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
                                AppLocalizations.of(
                                  context,
                                )!.paywallSaveYourFinances,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.paywallAverageUserSaves,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.green.shade600),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
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
                // --- Refactored onPressed with in_app_purchase Logic ---
                onPressed: _isPurchasing
                    ? null // Disable button while purchase is in progress
                    : () async {
                        if (_selectedProduct == null) {
                          // MODIFIED
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(
                                  context,
                                )!.paywallPleaseSelectPlan,
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        setState(() {
                          _isPurchasing = true;
                        });

                        try {
                          // Call the provider's purchase method
                          bool success = await subscriptionProvider
                              .purchaseProduct(_selectedProduct!); // MODIFIED

                          // The purchase result (success, error, or cancel)
                          // is now handled by the provider's central stream listener.
                          //
                          // If the purchaseProduct call itself fails (e.g.,
                          // network error before purchase sheet shows),
                          // the 'success' bool will be false.
                          if (!success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  subscriptionProvider.error ??
                                      'Purchase initiation failed',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }

                          // NOTE: You should listen to `subscriptionProvider.isSubscribed`
                          // (e.g., with a Consumer or Selector) to pop the
                          // screen on successful subscription, as the result
                          // now comes from an async stream.

                          // REMOVED all inline purchase handling logic
                        } catch (e) {
                          // Handle other unexpected errors
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.paywallUnexpectedError(e.toString()),
                                ),
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
                        AppLocalizations.of(context)!.paywallSubscribeYourPlan,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white, // Ensure text is visible
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),

          // ---
          // NOTE: The "Restore/Manage" links were commented out
          // in the original file.
          // The new provider methods `restorePurchases()` and `openManagementPage()`
          // will work correctly if you uncomment this UI.
          // ---
          // Positioned(
          //   left: 0,
          //   right: 0,
          //   bottom: 90,
          //   child: Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 24.0),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         TextButton(
          //           onPressed: () async {
          //             final provider = context.read<SubscriptionProvider>();
          //             final ok = await provider.restorePurchases();
          //             if (context.mounted) {
          //               ScaffoldMessenger.of(context).showSnackBar(
          //                 SnackBar(
          //                   content: Text(
          //                     ok
          //                         ? AppLocalizations.of(context)!.paywallPurchasesRestoredSuccessfully
          //                         : provider.error ?? 'Restore failed',
          //                   ),
          //                   backgroundColor: ok ? Colors.green : Colors.orange,
          //                 ),
          //               );
          //               // You should not pop here; wait for the
          //               // stream to update isSubscribed
          //               // if (ok) Navigator.of(context).pop();
          //             }
          //           },
          //           child: Text(AppLocalizations.of(context)!.paywallRestorePurchases),
          //         ),
          //         TextButton(
          //           onPressed: () async {
          //             final provider = context.read<SubscriptionProvider>();
          //             await provider.openManagementPage();
          //           },
          //           child: Text(AppLocalizations.of(context)!.paywallManageSubscription),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  // --- Refactored _buildPlanCard to use 'ProductDetails' ---
  Widget _buildPlanCard({
    required BuildContext context,
    required ProductDetails product, // MODIFIED
    required String pricePerDay,
    String? saveAmount,
    required bool isSelected,
    bool isPopular = false,
    bool isBestValue = false,
    required VoidCallback onTap,
  }) {
    // REMOVED: final product = package.storeProduct;
    // The product is now passed directly.

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
                        product.title, // Dynamic title
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
                            product.price, // Dynamic price (was priceString)
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryTextColorLight,
                                ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            // MODIFIED: We must check the ID to determine the period
                            product.id == _monthlyProductID
                                ? AppLocalizations.of(context)!.paywallPerMonth
                                : product.id == _yearlyProductID
                                ? AppLocalizations.of(context)!.paywallPerYear
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
                            pricePerDay, // This is still hardcoded
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
                  isBestValue
                      ? AppLocalizations.of(context)!.paywallBestValue
                      : AppLocalizations.of(context)!.paywallMostPopular,
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
