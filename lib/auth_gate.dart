import 'package:budgetm/screens/auth/first_time_settings/choose_theme_screen.dart';
import 'package:budgetm/screens/auth/first_time_settings/select_currency_screen.dart';
import 'package:budgetm/screens/auth/login/login_screen.dart';
import 'package:budgetm/screens/dashboard/main_screen.dart';
import 'package:budgetm/screens/onboarding/onboarding_screen.dart';
import 'package:budgetm/services/firebase_auth_service.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // SharedPreferences keys
  static const String _ONBOARDING_DONE_KEY = 'onboardingDone';
  static const String _THEME_CHOSEN_KEY = 'theme_chosen';
  static const String _USER_CURRENCY_KEY = 'selectedCurrencyCode';

  final FirebaseAuthService _authService = FirebaseAuthService();
  bool? _cachedAuthStatus;
  Map<String, bool>? _cachedSetupStatus;
  bool? _cachedOnboardingStatus;
  bool _preferencesLoaded = false;
  
  @override
  void initState() {
    super.initState();
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedOnboardingStatus = prefs.getBool(_ONBOARDING_DONE_KEY) ?? false;
    
    final bool themeChosen = prefs.getBool(_THEME_CHOSEN_KEY) ?? false;
    final bool currencyChosen = (prefs.getString(_USER_CURRENCY_KEY) != null);
    
    _cachedSetupStatus = {
      'themeChosen': themeChosen,
      'currencyChosen': currencyChosen,
    };
    
    // Note: Category initialization moved to SelectCurrencyScreen to ensure user is authenticated
    
    setState(() {
      _preferencesLoaded = true;
    });
  }

  bool _isOnboardingCompleted() {
    return _cachedOnboardingStatus ?? false;
  }

  Map<String, bool> _checkSetupStatus() {
    return _cachedSetupStatus ?? {'themeChosen': false, 'currencyChosen': false};
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
    // If preferences haven't been loaded yet, show a loading indicator
    if (!_preferencesLoaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // If onboarding is not completed, show OnboardingScreen
    if (!_isOnboardingCompleted()) {
      return const OnboardingScreen();
    }
    
    // For already authenticated users, try to navigate directly without loading indicators
    if (_isUserAuthenticated()) {
      final setupStatus = _checkSetupStatus();
      final bool themeChosen = setupStatus['themeChosen']!;
      final bool currencyChosen = setupStatus['currencyChosen']!;
      
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
    
    // If user is not authenticated, use StreamBuilder for real-time updates
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
        
        // If user is logged in, check Firestore initialization status via FutureBuilder
        _cachedAuthStatus = true;
        final user = authSnapshot.data!;
        return FutureBuilder<bool>(
          future: FirestoreService.instance.isUserInitialized(user.uid),
          builder: (context, initSnapshot) {
            if (initSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final bool initialized = initSnapshot.data == true;
            if (initialized) {
              return const MainScreen();
            }
            // Not initialized yet: send user to first-time setup flow
            return const ChooseThemeScreen();
          },
        );
      },
    );
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
}
