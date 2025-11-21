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
import 'package:budgetm/viewmodels/locale_provider.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budgetm/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    // If the error is 'duplicate-app', we can safely ignore it as it means
    // Firebase is already initialized from a previous run/hot-restart.
    if (e.code != 'duplicate-app') {
      rethrow;
    }
  }
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Enable Firestore offline persistence
  // FirebaseFirestore.instance.settings = const Settings(
  //   persistenceEnabled: true,
  // );

  final bool onboardingDone = prefs.getBool('onboardingDone') ?? false;

  // Initialize locale provider
  final localeProvider = LocaleProvider();
  await localeProvider.initialize();

  // Initialize subscription provider
  final subscriptionProvider = SubscriptionProvider();
  await subscriptionProvider.init();

  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => VacationProvider()),
          ChangeNotifierProvider(create: (_) => CurrencyProvider()),
          ChangeNotifierProvider(create: (_) => HomeScreenProvider()),
          ChangeNotifierProvider(create: (_) => NavbarVisibilityProvider()),
          ChangeNotifierProvider.value(value: subscriptionProvider),
          ChangeNotifierProvider.value(value: localeProvider),
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
        child: MyApp(
          onboardingDone: onboardingDone,
          localeProvider: localeProvider,
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool onboardingDone;
  final LocaleProvider localeProvider;

  const MyApp({
    super.key,
    required this.onboardingDone,
    required this.localeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        return MaterialApp(
          builder: DevicePreview.appBuilder,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: DevicePreview.locale(context) ?? localeProvider.currentLocale,
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
