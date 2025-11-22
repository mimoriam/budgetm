import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/generated/i18n/app_localizations.dart';
import 'package:budgetm/viewmodels/subscription_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';

/// Paywall screen for displaying subscription options and handling purchases.
///
/// Features:
/// - Displays monthly and yearly subscription options
/// - Handles purchase flow with proper error handling
/// - Auto-closes when subscription becomes active
/// - Shows appropriate error messages
/// - Allows restore purchases with feedback
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  ProductDetails? _selectedProduct;
  bool _isPurchasing = false;

  // Product IDs - must match Google Play Console and Cloud Functions
  final String _monthlyProductID = 'android_monthly_subs';
  final String _yearlyProductID = 'android_yearly_subs';

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);
    final products = subscriptionProvider.products;

    // Auto-close when subscription becomes active
    if (subscriptionProvider.isSubscribed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).maybePop();
      });
    }

    // Find products by ID
    ProductDetails? monthlyProduct;
    ProductDetails? yearlyProduct;

    if (products.isNotEmpty) {
      try {
        monthlyProduct = products.firstWhere(
          (prod) => prod.id == _monthlyProductID,
        );
      } catch (e) {
        // Monthly product not found
      }
      try {
        yearlyProduct = products.firstWhere(
          (prod) => prod.id == _yearlyProductID,
        );
      } catch (e) {
        // Yearly product not found
      }
    }

    // Set default selected product (prefer yearly for better value)
    if (_selectedProduct == null && yearlyProduct != null) {
      _selectedProduct = yearlyProduct;
    } else if (_selectedProduct == null && monthlyProduct != null) {
      _selectedProduct = monthlyProduct;
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Stack(
        children: [
          // Scrollable content
          Positioned.fill(
            bottom: 90, // Space for sticky button
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12.0,
              ),
              child: _buildContent(
                context,
                subscriptionProvider,
                monthlyProduct,
                yearlyProduct,
              ),
            ),
          ),
          // Sticky purchase button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildPurchaseButton(context, subscriptionProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    SubscriptionProvider provider,
    ProductDetails? monthlyProduct,
    ProductDetails? yearlyProduct,
  ) {
    // Show loading spinner while products are being fetched
    if (provider.isLoading && provider.products.isEmpty) {
      return const Center(heightFactor: 15, child: CircularProgressIndicator());
    }

    // Show error if no products are found
    if (provider.products.isEmpty) {
      return Center(
        heightFactor: 15,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.paywallCouldNotLoadPlans,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryTextColorLight,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      await context
                          .read<SubscriptionProvider>()
                          .reloadProducts();
                    },
              child: Text(AppLocalizations.of(context)!.homeRetry),
            ),
          ],
        ),
      );
    }

    // Show paywall content
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: kToolbarHeight - 20),

        // Crown Icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orangeAccent.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.workspace_premium, color: Colors.orange, size: 32),
        ),
        const SizedBox(height: 12),

        // Features Section
        _buildFeaturesSection(context),
        const SizedBox(height: 18),

        // Title
        Text(
          AppLocalizations.of(context)!.paywallChooseYourPlan,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryTextColorLight,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        // Subtitle
        Text(
          AppLocalizations.of(context)!.paywallInvestInFinancialFreedom,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.secondaryTextColorLight,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 22),

        // Monthly Plan Card
        if (monthlyProduct != null)
          _buildPlanCard(
            context: context,
            product: monthlyProduct,
            pricePerDay: _pricePerDayText(context, monthlyProduct, 30),
            isPopular: true,
            isSelected: _selectedProduct?.id == monthlyProduct.id,
            onTap: () => setState(() => _selectedProduct = monthlyProduct),
          ),

        const SizedBox(height: 16),

        // Yearly Plan Card
        if (yearlyProduct != null)
          _buildPlanCard(
            context: context,
            product: yearlyProduct,
            pricePerDay: _pricePerDayText(context, yearlyProduct, 365),
            saveAmount: _calculateSavings(monthlyProduct, yearlyProduct),
            isBestValue: true,
            isSelected: _selectedProduct?.id == yearlyProduct.id,
            onTap: () => setState(() => _selectedProduct = yearlyProduct),
          ),

        const SizedBox(height: 18),
        // Savings Box
        _buildSavingsBox(context),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildPurchaseButton(
    BuildContext context,
    SubscriptionProvider provider,
  ) {
    final isDisabled = _isPurchasing || provider.isLoading;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
      color: AppColors.scaffoldBackground,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Show error message if present
          if (provider.error != null && !_isPurchasing)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.error!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => provider.clearError(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDisabled
                    ? Colors.grey.shade400
                    : AppColors.gradientEnd,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 48),
              ),
            onPressed: isDisabled
                ? null
                : () => _handlePurchase(context, provider),
            child: _isPurchasing
                ? const SizedBox(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    AppLocalizations.of(context)!.paywallSubscribeYourPlan,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePurchase(
    BuildContext context,
    SubscriptionProvider provider,
  ) async {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.paywallPleaseSelectPlan),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isPurchasing = true);

    try {
      final success = await provider.purchaseProduct(_selectedProduct!);

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Purchase initiation failed'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (success && mounted) {
        // Show processing message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              // AppLocalizations.of(context)!.paywallProcessingPurchase,
              "Processing Purchase",
            ),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
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
        setState(() => _isPurchasing = false);
      }
    }
  }

  String _pricePerDayText(BuildContext context, ProductDetails p, int days) {
    final perDay = p.rawPrice / days;
    final f = NumberFormat.simpleCurrency(name: p.currencyCode);
    return AppLocalizations.of(context)!.paywallPricePerDay(f.format(perDay));
  }

  String? _calculateSavings(ProductDetails? monthly, ProductDetails? yearly) {
    if (monthly == null || yearly == null) return null;
    final yearlyCost = yearly.rawPrice;
    final monthlyYearlyCost = monthly.rawPrice * 12;
    final savings = monthlyYearlyCost - yearlyCost;
    if (savings <= 0) return null;
    final f = NumberFormat.simpleCurrency(name: yearly.currencyCode);
    return AppLocalizations.of(context)!.paywallSaveAmount(f.format(savings));
  }

  /// Filters the product title to remove app name in parentheses.
  /// Example: "Monthly Subs (Buck: Budget & Expense Tracker)" -> "Monthly Subs"
  String _filterProductTitle(String title) {
    // Remove text in parentheses (e.g., "(Buck: Budget & Expense Tracker)")
    return title.replaceAll(RegExp(r'\s*\([^)]*\)\s*'), '').trim();
  }

  Widget _buildPlanCard({
    required BuildContext context,
    required ProductDetails product,
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
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                        _filterProductTitle(product.title),
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
                            product.price,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryTextColorLight,
                                ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.id == _monthlyProductID
                                ? AppLocalizations.of(context)!.paywallPerMonth
                                : AppLocalizations.of(context)!.paywallPerYear,
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
                // Radio button
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
          // Badge (Most Popular / Best Value)
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

  Widget _buildFeaturesSection(BuildContext context) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.paywallEverythingIncluded,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryTextColorLight,
          ),
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          context,
          AppLocalizations.of(context)!.paywallPersonalizedBudgetInsights,
          Icons.insights,
        ),
        _buildFeatureItem(
          context,
          AppLocalizations.of(context)!.paywallDailyProgressTracking,
          Icons.trending_up,
        ),
        _buildFeatureItem(
          context,
          AppLocalizations.of(context)!.paywallExpenseManagementTools,
          Icons.account_balance_wallet,
        ),
        _buildFeatureItem(
          context,
          AppLocalizations.of(context)!.paywallFinancialHealthTimeline,
          Icons.timeline,
        ),
        // _buildFeatureItem(
        //   context,
        //   AppLocalizations.of(context)!.paywallExpertGuidanceTips,
        //   Icons.lightbulb,
        // ),
        _buildFeatureItem(
          context,
          AppLocalizations.of(context)!.paywallCommunitySupportAccess,
          Icons.people,
        ),
      ],
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

  Widget _buildSavingsBox(BuildContext context) {
    return Container(
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
              border: Border.all(color: Colors.green.shade200, width: 2),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.green,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.paywallSaveYourFinances,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.paywallAverageUserSaves,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.green.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
