import 'package:budgetm/screens/auth/first_time_settings/choose_theme_screen.dart';
import 'package:budgetm/screens/auth/first_time_settings/select_currency_screen.dart';
import 'package:budgetm/screens/auth/login/login_screen.dart';
import 'package:budgetm/screens/dashboard/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // FIX: Declare a Future variable in the state.
  late Future<Map<String, bool>> _checkStatusFuture;

  Future<Map<String, bool>> _checkLoginAndSetupStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final bool themeChosen = prefs.getBool('theme_chosen') ?? false;
    final bool currencyChosen = (prefs.getString('user_currency') != null);

    return {
      'isLoggedIn': isLoggedIn,
      'themeChosen': themeChosen,
      'currencyChosen': currencyChosen,
    };
  }

  @override
  void initState() {
    super.initState();
    // FIX: Initialize the future in initState. This ensures it only runs once.
    _checkStatusFuture = _checkLoginAndSetupStatus();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, bool>>(
      // FIX: Use the state variable instead of calling the function directly.
      future: _checkStatusFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          final bool isLoggedIn = snapshot.data!['isLoggedIn']!;
          final bool themeChosen = snapshot.data!['themeChosen']!;
          final bool currencyChosen = snapshot.data!['currencyChosen']!;

          if (isLoggedIn) {
            if (!themeChosen) {
              return const ChooseThemeScreen();
            } else if (!currencyChosen) {
              return const SelectCurrencyScreen();
            } else {
              return const MainScreen();
            }
          }
        }
        // Default to login screen if not logged in or if there's an error
        return const LoginScreen();
      },
    );
  }
}
