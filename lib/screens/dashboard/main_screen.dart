import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/constants/transaction_type_enum.dart';
import 'package:budgetm/screens/dashboard/navbar/goals/goals_screen.dart';
import 'package:budgetm/screens/dashboard/navbar/home.dart';
import 'package:budgetm/screens/dashboard/navbar/home/transaction/add_transaction_screen.dart';
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
  late List<Widget> _screens;
  bool _isFabMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
    _screens = _buildScreens();
  }

  List<Widget> _buildScreens() {
    return [
      const HomeScreen(),
      Container(), // Placeholder for Transactions
      Container(), // Placeholder for Budget
      const GoalsScreen(),
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
        title: ("Budget"),
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
        title: ("Balance"),
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
        title: ("Goals"),
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
        title: ("Personal"),
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
    return Scaffold(
      body: Stack(
        children: [
          PersistentTabView(
            context,
            controller: _controller,
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
          Positioned(
            bottom: 100,
            right: 20,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_isFabMenuOpen) ...[
                  _buildFabMenuItem(
                    label: "Income",
                    icon: HugeIcons.strokeRoundedChartUp,
                    color: Colors.green,
                    onPressed: () {
                      _toggleFabMenu();
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: const AddTransactionScreen(
                          transactionType: TransactionType.income,
                        ),
                        withNavBar: false,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildFabMenuItem(
                    label: "Expense",
                    icon: HugeIcons.strokeRoundedChartDown,
                    color: Colors.red,
                    onPressed: () {
                      _toggleFabMenu();
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: const AddTransactionScreen(
                          transactionType: TransactionType.expense,
                        ),
                        withNavBar: false,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
                SizedBox(
                  width: 40,
                  height: 40,
                  child: FloatingActionButton(
                    onPressed: _toggleFabMenu,
                    elevation: 1,
                    backgroundColor: AppColors.gradientEnd,
                    shape: const CircleBorder(),
                    child: Icon(
                      _isFabMenuOpen ? Icons.close : Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFabMenuItem({
    required String label,
    required List<List<dynamic>> icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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
