import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/screens/dashboard/navbar/home.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

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
    const textStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 12);

    return [
      PersistentBottomNavBarItem(
        icon: const Icon(IconlyBold.home),
        inactiveIcon: const Icon(IconlyLight.home),
        title: ("Home"),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.black,
        textStyle: textStyle,
      ),
      PersistentBottomNavBarItem(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedDollar02,
          color: Colors.white,
        ),
        inactiveIcon: HugeIcon(
          icon: HugeIcons.strokeRoundedDollar02,
          color: Colors.black,
        ),
        title: ("Transactions"),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.black,
        textStyle: textStyle,
      ),
      PersistentBottomNavBarItem(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedChartUp,
          color: Colors.white,
        ),
        inactiveIcon: HugeIcon(
          icon: HugeIcons.strokeRoundedChartUp,
          color: Colors.black,
        ),
        title: ("Budget"),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.black,
        textStyle: textStyle,
      ),
      PersistentBottomNavBarItem(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedWallet02,
          color: Colors.white,
        ),
        inactiveIcon: HugeIcon(
          icon: HugeIcons.strokeRoundedWallet02,
          color: Colors.black,
        ),
        title: ("Wallet"),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.black,
        textStyle: textStyle,
      ),
      PersistentBottomNavBarItem(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedShoppingBag01,
          color: Colors.white,
        ),
        inactiveIcon: HugeIcon(
          icon: HugeIcons.strokeRoundedShoppingBag01,
          color: Colors.black,
        ),
        title: ("Store"),
        activeColorPrimary: Colors.white,
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
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineToSafeArea: true,
      backgroundColor: AppColors.gradientEnd,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardAppears: true,
      navBarHeight: kBottomNavigationBarHeight + 20,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(40.0),
        colorBehindNavBar: AppColors.gradientEnd,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 30.0, right: 10),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: AppColors.gradientEnd,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      navBarStyle: NavBarStyle.style7,
    );
  }
}
