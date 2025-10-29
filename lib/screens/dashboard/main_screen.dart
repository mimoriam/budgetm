import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/constants/transaction_type_enum.dart';
import 'package:budgetm/generated/i18n/app_localizations.dart';
import 'package:budgetm/screens/dashboard/navbar/balance/balance_screen.dart';
import 'package:budgetm/screens/dashboard/navbar/budget/budget_screen.dart';
import 'package:budgetm/screens/dashboard/navbar/goals/goals_screen.dart';
import 'package:budgetm/screens/dashboard/navbar/home.dart';
import 'package:budgetm/screens/dashboard/navbar/home/transaction/add_transaction_screen.dart';
import 'package:budgetm/screens/dashboard/navbar/personal/personal_screen.dart';
import 'package:budgetm/viewmodels/vacation_mode_provider.dart';
import 'package:budgetm/viewmodels/home_screen_provider.dart';
import 'package:budgetm/viewmodels/navbar_visibility_provider.dart';
import 'package:budgetm/viewmodels/budget_provider.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconly/iconly.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PersistentTabController _controller;
  bool _isFabMenuOpen = false;

  @override
  void initState() {
    super.initState();
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
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: FloatingActionButton(
                        onPressed: vacationProvider.isVacationMode ? () async {
                          final homeScreenProvider = context.read<HomeScreenProvider>();
                          final result = await PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: AddTransactionScreen(
                              transactionType: TransactionType.expense,
                              selectedDate: homeScreenProvider.selectedDate,
                            ),
                            withNavBar: false,
                            pageTransitionAnimation: PageTransitionAnimation.cupertino,
                          );

                          // If the transaction was successfully added, trigger a refresh of the home screen
                          if (result == true) {
                            if (mounted) {
                              final homeScreenProvider = context.read<HomeScreenProvider>();
                              homeScreenProvider.triggerRefresh();
                              
                              // Also refresh the budget provider
                              final budgetProvider = context.read<BudgetProvider>();
                              budgetProvider.initialize();
                            }
                          }
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
                final result = await PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: AddTransactionScreen(
                    transactionType: TransactionType.expense,
                    selectedDate: homeScreenProvider.selectedDate,
                  ),
                  withNavBar: false,
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );

                // If the transaction was successfully added, trigger a refresh of the home screen
                if (result == true) {
                  if (mounted) {
                    final homeScreenProvider = context.read<HomeScreenProvider>();
                    homeScreenProvider.triggerRefresh();
                    
                    // Also refresh the budget provider
                    final budgetProvider = context.read<BudgetProvider>();
                    budgetProvider.initialize();
                  }
                }
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
              final result = await PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: AddTransactionScreen(
                  transactionType: TransactionType.income,
                  selectedDate: homeScreenProvider.selectedDate,
                ),
                withNavBar: false,
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );

              // If the transaction was successfully added, trigger a refresh of the home screen
              if (result == true) {
                if (mounted) {
                  final homeScreenProvider = context.read<HomeScreenProvider>();
                  homeScreenProvider.triggerRefresh();
                  
                  // Also refresh the budget provider
                  final budgetProvider = context.read<BudgetProvider>();
                  budgetProvider.initialize();
                }
              }
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
              final result = await PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: AddTransactionScreen(
                  transactionType: TransactionType.expense,
                  selectedDate: homeScreenProvider.selectedDate,
                ),
                withNavBar: false,
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );

              // If the transaction was successfully added, trigger a refresh of the home screen
              if (result == true) {
                if (mounted) {
                  final homeScreenProvider = context.read<HomeScreenProvider>();
                  homeScreenProvider.triggerRefresh();
                  
                  // Also refresh the budget provider
                  final budgetProvider = context.read<BudgetProvider>();
                  budgetProvider.initialize();
                }
              }
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
