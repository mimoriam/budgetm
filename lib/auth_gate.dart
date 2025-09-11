import 'package:budgetm/screens/auth/first_time_settings/choose_theme_screen.dart';
import 'package:budgetm/screens/auth/first_time_settings/select_currency_screen.dart';
import 'package:budgetm/screens/auth/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool? _themeChosen;

  @override
  void initState() {
    super.initState();
    _checkThemePreference();
  }

  Future<void> _checkThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeChosen = prefs.getBool('theme_chosen') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_themeChosen == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_themeChosen!) {
      // In a real app, you'd check auth status here
      // For now, we'll just go to the login screen
      return const LoginScreen();
    } else {
      return const ChooseThemeScreen();
    }
  }
}
