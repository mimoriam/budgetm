import 'package:budgetm/screens/auth/first_time_settings/choose_theme_screen.dart';
import 'package:budgetm/screens/auth/first_time_settings/select_currency_screen.dart';
import 'package:budgetm/screens/auth/login/login_screen.dart';
import 'package:budgetm/screens/dashboard/main_screen.dart';
import 'package:budgetm/screens/onboarding/onboarding_screen.dart';
import 'package:budgetm/services/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool? _cachedAuthStatus;
  Map<String, bool>? _cachedSetupStatus;

  Future<bool> _isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboardingDone') ?? false;
  }

  Future<Map<String, bool>> _checkSetupStatus() async {
    // Return cached setup status if available
    if (_cachedSetupStatus != null) {
      return _cachedSetupStatus!;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final bool themeChosen = prefs.getBool('theme_chosen') ?? false;
    final bool currencyChosen = (prefs.getString('user_currency') != null);

    _cachedSetupStatus = {
      'themeChosen': themeChosen,
      'currencyChosen': currencyChosen,
    };

    return _cachedSetupStatus!;
  }

  // Check if user is authenticated without triggering loading indicators
  bool _isUserAuthenticated() {
    // Return cached auth status if available
    if (_cachedAuthStatus != null) {
      return _cachedAuthStatus!;
    }
    
    final currentUser = FirebaseAuth.instance.currentUser;
    _cachedAuthStatus = currentUser != null;
    return _cachedAuthStatus!;
  }

  // Reset cache when needed (e.g., after login/logout)
  void _resetCache() {
    _cachedAuthStatus = null;
    _cachedSetupStatus = null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isOnboardingCompleted(),
      builder: (context, onboardingSnapshot) {
        if (onboardingSnapshot.connectionState == ConnectionState.waiting) {
          // Only show minimal loading for initial onboarding check
          return const Scaffold(body: SizedBox.shrink());
        }

        // If onboarding is not completed, show OnboardingScreen
        if (onboardingSnapshot.data != true) {
          return const OnboardingScreen();
        }

        // For already authenticated users, try to navigate directly without loading indicators
        if (_isUserAuthenticated()) {
          return FutureBuilder<Map<String, bool>>(
            future: _checkSetupStatus(),
            builder: (context, setupSnapshot) {
              // Only show loading indicator for initial setup check
              if (setupSnapshot.connectionState == ConnectionState.waiting && _cachedSetupStatus == null) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (setupSnapshot.hasData || _cachedSetupStatus != null) {
                final data = setupSnapshot.data ?? _cachedSetupStatus!;
                final bool themeChosen = data['themeChosen']!;
                final bool currencyChosen = data['currencyChosen']!;

                // If setup is complete, navigate directly to MainScreen
                if (themeChosen && currencyChosen) {
                  return const MainScreen();
                }
                
                // Incomplete setup flows
                if (!themeChosen) {
                  return const ChooseThemeScreen();
                } else if (!currencyChosen) {
                  return const SelectCurrencyScreen();
                } else {
                  // Setup is complete, go to MainScreen
                  return const MainScreen();
                }
              }

              // Default to main screen if there's an error checking setup status
              return const MainScreen();
            },
          );
        }

        // If user is not authenticated, use StreamBuilder for real-time updates
        // Only show loading indicator for initial connection
        return StreamBuilder<User?>(
          stream: _authService.userChanges(),
          builder: (context, authSnapshot) {
            // Show loading indicator only during initial connection
            if (authSnapshot.connectionState == ConnectionState.waiting && authSnapshot.data == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // If user is not logged in, navigate to LoginScreen
            if (!authSnapshot.hasData) {
              return const LoginScreen();
            }

            // If user is logged in, check setup status
            // Cache the authenticated status
            _cachedAuthStatus = true;
            return FutureBuilder<Map<String, bool>>(
              future: _checkSetupStatus(),
              builder: (context, setupSnapshot) {
                // Only show loading indicator for initial setup check
                if (setupSnapshot.connectionState == ConnectionState.waiting && _cachedSetupStatus == null) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (setupSnapshot.hasData || _cachedSetupStatus != null) {
                  final data = setupSnapshot.data ?? _cachedSetupStatus!;
                  final bool themeChosen = data['themeChosen']!;
                  final bool currencyChosen = data['currencyChosen']!;

                  // Incomplete setup flows
                  if (!themeChosen) {
                    return const ChooseThemeScreen();
                  } else if (!currencyChosen) {
                    return const SelectCurrencyScreen();
                  } else {
                    // Setup is complete, go to MainScreen
                    return const MainScreen();
                  }
                }

                // Default to main screen if there's an error checking setup status
                return const MainScreen();
              },
            );
          },
        );
      },
    );
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset cache when dependencies change (e.g., after navigation)
    _resetCache();
  }
}
