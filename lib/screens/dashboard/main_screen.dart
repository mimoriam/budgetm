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
      const PlaceholderScreen(title: 'Transactions'),
      const PlaceholderScreen(title: 'Budget'),
      const PlaceholderScreen(title: 'Wallet'),
      const PlaceholderScreen(title: 'Store'),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    const textStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 12);

    return [
      PersistentBottomNavBarItem(
        icon: const Icon(IconlyBold.home),
        inactiveIcon: const Icon(IconlyLight.home),
        title: ("Home"),
        activeColorPrimary: AppColors.primaryTextColorLight,
        inactiveColorPrimary: Colors.grey,
        textStyle: textStyle,
      ),
      PersistentBottomNavBarItem(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedEarRings01,
          color: AppColors.primaryTextColorLight,
        ),
        inactiveIcon: HugeIcon(
          icon: HugeIcons.strokeRounded0Circle,
          color: Colors.grey,
        ),
        title: ("Transactions"),
        activeColorPrimary: AppColors.primaryTextColorLight,
        inactiveColorPrimary: Colors.grey,
        textStyle: textStyle,
      ),
      PersistentBottomNavBarItem(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedChart01,
          color: AppColors.primaryTextColorLight,
        ),
        inactiveIcon: HugeIcon(
          icon: HugeIcons.strokeRoundedChart01,
          color: Colors.grey,
        ),
        title: ("Budget"),
        activeColorPrimary: AppColors.primaryTextColorLight,
        inactiveColorPrimary: Colors.grey,
        textStyle: textStyle,
      ),
      PersistentBottomNavBarItem(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedWallet02,
          color: AppColors.primaryTextColorLight,
        ),
        inactiveIcon: HugeIcon(
          icon: HugeIcons.strokeRoundedWallet02,
          color: Colors.grey,
        ),
        title: ("Wallet"),
        activeColorPrimary: AppColors.primaryTextColorLight,
        inactiveColorPrimary: Colors.grey,
        textStyle: textStyle,
      ),
      PersistentBottomNavBarItem(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedShoppingBag01,
          color: AppColors.primaryTextColorLight,
        ),
        inactiveIcon: HugeIcon(
          icon: HugeIcons.strokeRoundedShoppingBag01,
          color: Colors.grey,
        ),
        title: ("Store"),
        activeColorPrimary: AppColors.primaryTextColorLight,
        inactiveColorPrimary: Colors.grey,
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
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardAppears: true,
      popBehaviorOnSelectedNavBarItemPress: PopBehavior.all,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(30.0),
        colorBehindNavBar: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      navBarStyle: NavBarStyle.style6,
      padding: const EdgeInsets.symmetric(vertical: 8),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('This is the $title screen')),
    );
  }
}
