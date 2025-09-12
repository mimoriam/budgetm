import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/screens/dashboard/navbar/home.dart';
import 'package:budgetm/screens/dashboard/navbar/home/plan_income/plan_income_screen.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconly/iconly.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PersistentTabController _controller;
  // FIX: Declare the list of screens as a state variable
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
    // FIX: Initialize the screens list once in initState
    _screens = _buildScreens();
  }

  // FIX: This method now just returns the list of screens
  List<Widget> _buildScreens() {
    return [
      const HomeScreen(),
      Container(), // Placeholder for Transactions
      Container(), // Placeholder for Budget
      Container(), // Placeholder for Wallet
      Container(), // Placeholder for Store
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    const textStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);

    return [
      PersistentBottomNavBarItem(
        icon: const Icon(IconlyBold.home),
        inactiveIcon: const Icon(IconlyLight.home),
        title: ("Home"),
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
        title: ("Transactions"),
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
        title: ("Budget"),
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
        title: ("Wallet"),
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
        title: ("Store"),
        activeColorPrimary: Colors.white,
        activeColorSecondary: Colors.black,
        inactiveColorPrimary: Colors.black,
        textStyle: textStyle,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      // FIX: Use the state variable _screens
      screens: _screens,
      items: _navBarsItems(),
      confineToSafeArea: true,
      backgroundColor: AppColors.bottomBarColor,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardAppears: true,
      navBarHeight: kBottomNavigationBarHeight + 20,
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      padding: const EdgeInsets.only(left: 6),
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(40.0),
        colorBehindNavBar: AppColors.gradientStart,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 26.0, right: 0),
        child: FloatingActionButton(
          onPressed: () {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: const PlanIncomeScreen(),
              withNavBar: false,
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          },
          backgroundColor: AppColors.gradientEnd,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      navBarStyle: NavBarStyle.style7,
    );
  }
}
