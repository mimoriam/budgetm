import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/constants/transaction_type_enum.dart';
import 'package:budgetm/generated/i18n/app_localizations.dart';
import 'package:budgetm/screens/dashboard/navbar/balance/balance_screen.dart';
import 'package:budgetm/screens/dashboard/navbar/budget/budget_screen.dart';
import 'package:budgetm/screens/dashboard/navbar/goals/goals_screen.dart';
import 'package:budgetm/screens/dashboard/navbar/home.dart';
import 'package:budgetm/screens/dashboard/navbar/home/transaction/add_transaction_screen.dart';
import 'package:budgetm/screens/dashboard/navbar/personal/personal_screen.dart';
import 'package:budgetm/screens/paywall/paywall_screen.dart';
import 'package:budgetm/viewmodels/vacation_mode_provider.dart';
import 'package:budgetm/viewmodels/home_screen_provider.dart';
import 'package:budgetm/viewmodels/navbar_visibility_provider.dart';
import 'package:budgetm/viewmodels/budget_provider.dart';
import 'package:budgetm/viewmodels/subscription_provider.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconly/iconly.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  final bool showIntroPaywall;
  
  const MainScreen({super.key, this.showIntroPaywall = false});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

// Static reference to FAB key for showcase coordination
class MainScreenShowcaseKeys {
  static GlobalKey? fabKey;
}

// Static callback handler for showcase completion
class ShowcaseCompletionHandler {
  static VoidCallback? onShowcaseCompleted;
  
  static void notifyCompletion() {
    onShowcaseCompleted?.call();
  }
}

class _MainScreenState extends State<MainScreen> {
  late PersistentTabController _controller;
  bool _isFabMenuOpen = false;
  bool _hasPresentedIntroPaywall = false;
  int _showcasePollAttempts = 0;
  static const int _maxShowcasePollAttempts = 60; // 30 seconds max (60 * 500ms)
  
  // GlobalKey for FAB showcase
  final GlobalKey _fabKey = GlobalKey();
  
  @override
  void initState() {
    super.initState();
    // Register FAB key for showcase coordination
    MainScreenShowcaseKeys.fabKey = _fabKey;
    
    // Register showcase completion callback if paywall should be shown
    if (widget.showIntroPaywall) {
      ShowcaseCompletionHandler.onShowcaseCompleted = _maybeShowIntroPaywall;
    }
    
    _controller = PersistentTabController(initialIndex: 0);
    _controller.addListener(() {
      setState(() {});
      // Ensure navbar is always visible when on home screen (index 0) unless in dialog mode
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final navbarProvider = Provider.of<NavbarVisibilityProvider>(context, listen: false);
        if (_controller.index == 0 && !navbarProvider.isDialogMode) {
          navbarProvider.setNavBarVisibility(true);
        }
      });
    });
    
    // Check if we should show paywall immediately (if showcase already completed or not needed)
    if (widget.showIntroPaywall) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAndMaybeShowPaywall();
      });
    }
  }
  
  @override
  void dispose() {
    // Clear the callback when disposing
    if (ShowcaseCompletionHandler.onShowcaseCompleted == _maybeShowIntroPaywall) {
      ShowcaseCompletionHandler.onShowcaseCompleted = null;
    }
    super.dispose();
  }
  
  /// Checks if showcase is needed and shows paywall accordingly.
  /// If showcase already completed or not needed, shows paywall immediately.
  /// Otherwise, sets up polling to check for showcase completion.
  Future<void> _checkAndMaybeShowPaywall() async {
    // Skip if already presented or widget is unmounted
    if (_hasPresentedIntroPaywall || !mounted) {
      return;
    }
    
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);
    
    // Skip if user is already subscribed
    if (subscriptionProvider.isSubscribed) {
      return;
    }
    
    // Check if showcase has already been completed
    final prefs = await SharedPreferences.getInstance();
    final hasSeenShowcase = prefs.getBool('hasSeenHomeShowcase') ?? false;
    
    // If showcase already completed or not needed, show paywall immediately
    if (hasSeenShowcase) {
      _maybeShowIntroPaywall();
    } else {
      // Showcase is being shown, wait for completion
      // Set up polling to check for completion flag
      _waitForShowcaseCompletion();
    }
  }
  
  /// Polls for showcase completion and shows paywall when complete.
  /// Stops polling after max attempts to prevent infinite polling.
  void _waitForShowcaseCompletion() {
    // Stop polling if max attempts reached or widget unmounted
    if (!mounted || _hasPresentedIntroPaywall || _showcasePollAttempts >= _maxShowcasePollAttempts) {
      if (_showcasePollAttempts >= _maxShowcasePollAttempts) {
        // Timeout reached, treat as completed and show paywall
        // This handles edge case where showcase was dismissed early or never completed
        debugPrint('Showcase polling timeout reached, showing paywall');
        _maybeShowIntroPaywall();
      }
      return;
    }
    
    _showcasePollAttempts++;
    
    // Poll every 500ms to check if showcase completed
    Future.delayed(const Duration(milliseconds: 500), () async {
      if (!mounted || _hasPresentedIntroPaywall) return;
      
      final prefs = await SharedPreferences.getInstance();
      final showcaseJustCompleted = prefs.getBool('showcaseJustCompleted') ?? false;
      
      if (showcaseJustCompleted) {
        // Clear the flag
        await prefs.setBool('showcaseJustCompleted', false);
        
        // Notify via callback if registered (this will call _maybeShowIntroPaywall)
        // If callback is not set, call directly
        if (ShowcaseCompletionHandler.onShowcaseCompleted != null) {
          ShowcaseCompletionHandler.notifyCompletion();
        } else {
          _maybeShowIntroPaywall();
        }
      } else {
        // Continue polling
        _waitForShowcaseCompletion();
      }
    });
  }
  
  /// Shows the paywall screen once after first-time setup, if user is not already subscribed.
  /// This is called either immediately (if showcase already completed) or after showcase completion.
  void _maybeShowIntroPaywall() {
    // Skip if already presented or widget is unmounted
    if (_hasPresentedIntroPaywall || !mounted) {
      return;
    }
    
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);
    
    // Skip if user is already subscribed
    if (subscriptionProvider.isSubscribed) {
      return;
    }
    
    // Mark as presented to prevent duplicate shows
    _hasPresentedIntroPaywall = true;
    
    // Hide navbar while showing paywall
    final navbarProvider = Provider.of<NavbarVisibilityProvider>(context, listen: false);
    navbarProvider.setDialogMode(true);
    navbarProvider.setNavBarVisibility(false);
    
    // Show paywall after a brief delay to ensure UI is ready
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: const PaywallScreen(),
        withNavBar: false,
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      ).then((_) {
        // Restore navbar visibility when paywall is dismissed
        if (mounted) {
          navbarProvider.setNavBarVisibility(true);
          navbarProvider.setDialogMode(false);
        }
      });
    });
  }

  List<Widget> _buildScreens() {
    return [
      const HomeScreen(),
      const BudgetScreen(),
      const BalanceScreen(),
      const GoalsScreen(),
      const PersonalScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    const textStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);

    return [
      PersistentBottomNavBarItem(
        icon: const Icon(IconlyBold.home),
        inactiveIcon: const Icon(IconlyLight.home),
        title: AppLocalizations.of(context)!.mainScreenHome,
        activeColorPrimary: Colors.white,
        activeColorSecondary: Colors.black,
        inactiveColorPrimary: Colors.black,
        textStyle: textStyle,
      ),
      PersistentBottomNavBarItem(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedDollar02,
          color: Colors.black,
        ),
        inactiveIcon: HugeIcon(
          icon: HugeIcons.strokeRoundedDollar02,
          color: Colors.black,
        ),
        title: AppLocalizations.of(context)!.mainScreenBudget,
        activeColorPrimary: Colors.white,
        activeColorSecondary: Colors.black,
        inactiveColorPrimary: Colors.black,
        textStyle: textStyle,
      ),
      PersistentBottomNavBarItem(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedChartUp,
          color: Colors.black,
        ),
        inactiveIcon: HugeIcon(
          icon: HugeIcons.strokeRoundedChartUp,
          color: Colors.black54,
        ),
        title: AppLocalizations.of(context)!.mainScreenBalance,
        activeColorPrimary: Colors.white,
        activeColorSecondary: Colors.black,
        inactiveColorPrimary: Colors.black,
        textStyle: textStyle,
      ),
      PersistentBottomNavBarItem(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedWallet02,
          color: Colors.black,
        ),
        inactiveIcon: HugeIcon(
          icon: HugeIcons.strokeRoundedWallet02,
          color: Colors.black,
        ),
        title: AppLocalizations.of(context)!.mainScreenGoals,
        activeColorPrimary: Colors.white,
        activeColorSecondary: Colors.black,
        inactiveColorPrimary: Colors.black,
        textStyle: textStyle,
      ),
      PersistentBottomNavBarItem(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedShoppingBag01,
          color: Colors.black,
        ),
        inactiveIcon: HugeIcon(
          icon: HugeIcons.strokeRoundedShoppingBag01,
          color: Colors.black,
        ),
        title: AppLocalizations.of(context)!.mainScreenPersonal,
        activeColorPrimary: Colors.white,
        activeColorSecondary: Colors.black,
        inactiveColorPrimary: Colors.black,
        textStyle: textStyle,
      ),
    ];
  }

  void _toggleFabMenu() {
    setState(() {
      _isFabMenuOpen = !_isFabMenuOpen;
    });
  }

  void _handleTransactionFlowResult(bool? result, DateTime? fallbackDate) {
    if (!mounted || result != true) {
      return;
    }

    final budgetProvider = context.read<BudgetProvider>();
    budgetProvider.initialize();

    final homeScreenProvider = context.read<HomeScreenProvider>();
    // Always trigger refresh after a transaction is added to ensure cache invalidation
    // and month range recalculation, especially for new months
    homeScreenProvider.triggerRefresh(transactionDate: fallbackDate);
    // homeScreenProvider.triggerTransactionsRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final vacationProvider = context.watch<VacationProvider>();
    final navbarVisibility = context.watch<NavbarVisibilityProvider>();
    // Ensure the NavbarVisibilityProvider always has the current tab index from the controller.
    // Use a post-frame callback to avoid mutating providers synchronously during build.
    if (navbarVisibility.currentIndex != _controller.index) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navbarVisibility.setCurrentIndex(_controller.index);
      });
    }
    
    // Additional safety check: ensure navbar is visible when on home screen
    if (_controller.index == 0 && !navbarVisibility.isNavBarVisible && !navbarVisibility.isDialogMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
navbarVisibility.setNavBarVisibility(true);
      });
    }
    return Scaffold(
      body: Stack(
        children: [
          PersistentTabView(
            context,
            controller: _controller,
            screens: _buildScreens(),
            items: _navBarsItems(),
            confineToSafeArea: true,
            backgroundColor: vacationProvider.isVacationMode ? AppColors.aiGradientStart : AppColors.bottomBarColor,
            handleAndroidBackButtonPress: true,
            resizeToAvoidBottomInset: true,
            stateManagement: true,
            hideNavigationBarWhenKeyboardAppears: true,
            navBarHeight: navbarVisibility.isNavBarVisible
                ? kBottomNavigationBarHeight + 20
                : 0,
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            padding: const EdgeInsets.only(left: 6),
            decoration: NavBarDecoration(
              borderRadius: BorderRadius.circular(40.0),
              colorBehindNavBar: Colors.transparent,
            ),
            navBarStyle: NavBarStyle.style7,
          ),
          if (_isFabMenuOpen)
            GestureDetector(
              onTap: _toggleFabMenu, // Close menu on tap outside
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.black54.withOpacity(0.5)),
            ),
          if (_controller.index == 0) // Only show FAB on home screen (index 0)
            Positioned(
              bottom: 100,
              right: Directionality.of(context) == TextDirection.rtl ? null : 20,
              left: Directionality.of(context) == TextDirection.rtl ? 20 : null,
              child: AnimatedSlide(
                offset: navbarVisibility.isNavBarVisible
                    ? Offset.zero
                    : const Offset(0, 3),
                duration: const Duration(milliseconds: 150),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_isFabMenuOpen)
                      ..._buildFabMenuItemsForCurrentScreen(vacationProvider),
                    const SizedBox(height: 24),
                    Showcase(
                      key: _fabKey,
                      title: 'Add Income/Expense',
                      description: 'Tap here to quickly add income or expense transactions.',
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: FloatingActionButton(
                          onPressed: vacationProvider.isVacationMode ? () async {
                            final homeScreenProvider = context.read<HomeScreenProvider>();
                            final fallbackDate = homeScreenProvider.selectedDate;
                            final result = await PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: AddTransactionScreen(
                                transactionType: TransactionType.expense,
                                selectedDate: homeScreenProvider.selectedDate,
                              ),
                              withNavBar: false,
                              pageTransitionAnimation: PageTransitionAnimation.cupertino,
                            );

                            _handleTransactionFlowResult(result, fallbackDate);
                          } : _toggleFabMenu,
                          elevation: 1,
                          backgroundColor: vacationProvider.isVacationMode ? AppColors.aiGradientStart : AppColors.gradientEnd,
                          shape: const CircleBorder(),
                          child: Icon(
                            vacationProvider.isVacationMode ? Icons.add : (_isFabMenuOpen ? Icons.close : Icons.add),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildFabMenuItemsForCurrentScreen(
    VacationProvider vacationProvider,
  ) {
    // Return empty list if in vacation mode
    if (vacationProvider.isVacationMode) {
      return [];
    }
    
    switch (_controller.index) {
      case 0: // Home
        if (vacationProvider.isAiMode) {
          return [
            _buildFabMenuItem(
              label: AppLocalizations.of(context)!.mainScreenBudget,
              icon: HugeIcons.strokeRoundedDollar02,
              color: Colors.blue,
              onPressed: () {
                _toggleFabMenu();
                _controller.jumpToTab(1);
              },
            ),
            const SizedBox(height: 16),
            _buildFabMenuItem(
              label: AppLocalizations.of(context)!.mainScreenExpense,
              icon: HugeIcons.strokeRoundedChartDown,
              color: Colors.red,
              onPressed: () async {
                _toggleFabMenu();
                final homeScreenProvider = context.read<HomeScreenProvider>();
                final fallbackDate = homeScreenProvider.selectedDate;
                final result = await PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: AddTransactionScreen(
                    transactionType: TransactionType.expense,
                    selectedDate: homeScreenProvider.selectedDate,
                  ),
                  withNavBar: false,
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );

                _handleTransactionFlowResult(result, fallbackDate);
              },
            ),
          ];
        }
        return [
          _buildFabMenuItem(
            label: AppLocalizations.of(context)!.mainScreenIncome,
            icon: HugeIcons.strokeRoundedChartUp,
            color: Colors.green,
            onPressed: () async {
              _toggleFabMenu();
              final homeScreenProvider = context.read<HomeScreenProvider>();
              final fallbackDate = homeScreenProvider.selectedDate;
              final result = await PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: AddTransactionScreen(
                  transactionType: TransactionType.income,
                  selectedDate: homeScreenProvider.selectedDate,
                ),
                withNavBar: false,
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );

              _handleTransactionFlowResult(result, fallbackDate);
            },
          ),
          const SizedBox(height: 16),
          _buildFabMenuItem(
            label: AppLocalizations.of(context)!.mainScreenExpense,
            icon: HugeIcons.strokeRoundedChartDown,
            color: Colors.red,
            onPressed: () async {
              _toggleFabMenu();
              final homeScreenProvider = context.read<HomeScreenProvider>();
              final fallbackDate = homeScreenProvider.selectedDate;
              final result = await PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: AddTransactionScreen(
                  transactionType: TransactionType.expense,
                  selectedDate: homeScreenProvider.selectedDate,
                ),
                withNavBar: false,
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );

              _handleTransactionFlowResult(result, fallbackDate);
            },
          ),
        ];
      case 1: // Budget
        return []; // Budget screen no longer needs FAB actions
      case 2: // Balance
        return []; // Balance screen no longer needs FAB actions
      default:
        return [];
    }
  }

  Widget _buildFabMenuItem({
    required String label,
    required List<List<dynamic>> icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: isRTL ? [
        // RTL: Button first, then label
        FloatingActionButton(
          heroTag: null,
          mini: true,
          elevation: 1,
          onPressed: onPressed,
          backgroundColor: color,
          shape: const CircleBorder(),
          child: HugeIcon(icon: icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ] : [
        // LTR: Label first, then button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 12),
        FloatingActionButton(
          heroTag: null,
          mini: true,
          elevation: 1,
          onPressed: onPressed,
          backgroundColor: color,
          shape: const CircleBorder(),
          child: HugeIcon(icon: icon, color: Colors.white, size: 20),
        ),
      ],
    );
  }
}
