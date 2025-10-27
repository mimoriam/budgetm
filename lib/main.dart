import 'dart:io';

import 'package:budgetm/auth_gate.dart';
import 'package:budgetm/generated/i18n/app_localizations.dart';
import 'package:budgetm/utils/appTheme.dart';
import 'package:budgetm/viewmodels/theme_provider.dart';
import 'package:budgetm/viewmodels/vacation_mode_provider.dart';
import 'package:budgetm/viewmodels/currency_provider.dart';
import 'package:budgetm/viewmodels/home_screen_provider.dart';
import 'package:budgetm/viewmodels/navbar_visibility_provider.dart';
import 'package:budgetm/viewmodels/budget_provider.dart';
import 'package:budgetm/viewmodels/goals_provider.dart';
import 'package:budgetm/viewmodels/subscription_provider.dart';
import 'package:budgetm/viewmodels/user_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budgetm/firebase_options.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Enable Firestore offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  await _configureRevenueCat();

  final bool onboardingDone = prefs.getBool('onboardingDone') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => VacationProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        ChangeNotifierProvider(create: (_) => HomeScreenProvider()),
        ChangeNotifierProvider(create: (_) => NavbarVisibilityProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProxyProvider3<
          CurrencyProvider,
          VacationProvider,
          HomeScreenProvider,
          BudgetProvider
        >(
          create: (context) => BudgetProvider(
            currencyProvider: Provider.of<CurrencyProvider>(
              context,
              listen: false,
            ),
            vacationProvider: Provider.of<VacationProvider>(
              context,
              listen: false,
            ),
            homeScreenProvider: Provider.of<HomeScreenProvider>(
              context,
              listen: false,
            ),
          ),
          update:
              (
                context,
                currencyProvider,
                vacationProvider,
                homeScreenProvider,
                budgetProvider,
              ) =>
                  budgetProvider ??
                  BudgetProvider(
                    currencyProvider: currencyProvider,
                    vacationProvider: vacationProvider,
                    homeScreenProvider: homeScreenProvider,
                  ),
        ),
        ChangeNotifierProxyProvider<CurrencyProvider, GoalsProvider>(
          create: (context) => GoalsProvider(
            currencyProvider: Provider.of<CurrencyProvider>(
              context,
              listen: false,
            ),
          ),
          update: (context, currencyProvider, goalsProvider) =>
              goalsProvider ??
              GoalsProvider(currencyProvider: currencyProvider),
        ),
      ],
      child: MyApp(onboardingDone: onboardingDone),
    ),
  );
}

Future<void> _configureRevenueCat() async {
  // Set to debug level for testing
  await Purchases.setLogLevel(LogLevel.debug);

  PurchasesConfiguration configuration;

  // --- !! IMPORTANT !! ---
  // Get these API keys from your RevenueCat dashboard:
  // RevenueCat Dashboard > Project > Apps > (Your App)
  const String appleApiKey = "test_vqgFeMgiflyEiUsqXKaCGhdBcEf";
  const String googleApiKey = "test_vqgFeMgiflyEiUsqXKaCGhdBcEf";

  if (Platform.isIOS) {
    configuration = PurchasesConfiguration(appleApiKey);
  } else if (Platform.isAndroid) {
    configuration = PurchasesConfiguration(googleApiKey);
  } else {
    return; // Unsupported platform
  }

  await Purchases.configure(configuration);
}

class MyApp extends StatelessWidget {
  final bool onboardingDone;

  const MyApp({super.key, required this.onboardingDone});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          // themeMode: themeProvider.themeMode,
          themeMode: ThemeMode.light,
          // home: onboardingDone ? const AuthGate() : const OnboardingScreen(),
          home: AuthGate(),
        );
      },
    );
  }
}
