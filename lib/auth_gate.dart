import 'package:budgetm/screens/auth/first_time_settings/select_currency_screen.dart';
import 'package:budgetm/screens/auth/login/login_screen.dart';
import 'package:budgetm/screens/dashboard/main_screen.dart';
import 'package:budgetm/screens/onboarding/onboarding_screen.dart';
import 'package:budgetm/services/firebase_auth_service.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/viewmodels/user_provider.dart';
import 'package:budgetm/viewmodels/subscription_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // SharedPreferences keys
  static const String _ONBOARDING_DONE_KEY = 'onboardingDone';

  final FirebaseAuthService _authService = FirebaseAuthService();
  bool? _cachedOnboardingStatus;
  bool _preferencesLoaded = false;
  Future<bool>? _isInitializedFuture;
  bool _hasTriggeredSubRefresh = false;

  @override
  void initState() {
    super.initState();
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedOnboardingStatus = prefs.getBool(_ONBOARDING_DONE_KEY) ?? false;

    setState(() {
      _preferencesLoaded = true;
    });
  }

  bool _isOnboardingCompleted() {
    return _cachedOnboardingStatus ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // If preferences haven't been loaded yet, show a loading indicator
    if (!_preferencesLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // If onboarding is not completed, show OnboardingScreen
    if (!_isOnboardingCompleted()) {
      return const OnboardingScreen();
    }

    // Use StreamBuilder for real-time authentication updates
    return StreamBuilder<User?>(
      stream: _authService.userChanges(),
      builder: (context, authSnapshot) {
        // Update UserProvider with current user after the frame is built
        if (authSnapshot.hasData || authSnapshot.data == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final userProvider = Provider.of<UserProvider>(
              context,
              listen: false,
            );
            userProvider.setUser(authSnapshot.data);
          });
        }

        // Force a fresh subscription status check on login once per session
        if (authSnapshot.hasData && !_hasTriggeredSubRefresh) {
          _hasTriggeredSubRefresh = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            // Use ensureFreshStatus with force=true to guarantee a fresh check
            context
                .read<SubscriptionProvider>()
                .ensureFreshStatus(force: true)
                .catchError((error) {
                  // Silently handle errors - subscription provider will manage error state
                  debugPrint('Error refreshing subscription on login: $error');
                });
          });
        }

        // Reset subscription refresh flag when user logs out
        if (!authSnapshot.hasData && _hasTriggeredSubRefresh) {
          _hasTriggeredSubRefresh = false;
        }

        // Show loading indicator only during initial connection
        if (authSnapshot.connectionState == ConnectionState.waiting &&
            authSnapshot.data == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is not logged in, navigate to LoginScreen
        if (!authSnapshot.hasData) {
          // User logged out, reset the future
          _isInitializedFuture = null;
          return const LoginScreen();
        }

        // If user is logged in, check Firestore initialization status via FutureBuilder
        final user = authSnapshot.data!;

        // If future is not set or belongs to a different user, create a new one
        _isInitializedFuture ??= FirestoreService.instance.isUserInitialized(
          user.uid,
        );

        return FutureBuilder<bool>(
          future: _isInitializedFuture,
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
            return const SelectCurrencyScreen();
          },
        );
      },
    );
  }
}
