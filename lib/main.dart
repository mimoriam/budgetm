import 'package:budgetm/auth_gate.dart';
import 'package:budgetm/utils/appTheme.dart';
import 'package:budgetm/viewmodels/theme_provider.dart';
import 'package:budgetm/viewmodels/vacation_mode_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budgetm/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final bool onboardingDone = prefs.getBool('onboardingDone') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => VacationProvider()),
      ],
      child: MyApp(onboardingDone: onboardingDone),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool onboardingDone;

  const MyApp({super.key, required this.onboardingDone});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
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
