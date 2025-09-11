import 'package:budgetm/auth_gate.dart';
import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/viewmodels/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChooseThemeScreen extends StatefulWidget {
  const ChooseThemeScreen({super.key});

  @override
  State<ChooseThemeScreen> createState() => _ChooseThemeScreenState();
}

class _ChooseThemeScreenState extends State<ChooseThemeScreen> {
  ThemeMode _selectedTheme = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.gradientStart, AppColors.gradientEnd2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black87,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: const Text(
                  'Back',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(28.0),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.gradientStart2,
                              AppColors.gradientEnd3,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.0),
                          border: Border.all(
                            color: AppColors.lightGreyBackground.withOpacity(
                              0.5,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 5,
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Choose Theme',
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Select your preferred Theme',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.secondaryTextColorLight,
                                  ),
                            ),
                            const SizedBox(height: 30),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Select Theme',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ThemeBox(
                                  icon: Icons.light_mode,
                                  label: 'Light',
                                  isSelected: _selectedTheme == ThemeMode.light,
                                  onTap: () {
                                    setState(() {
                                      _selectedTheme = ThemeMode.light;
                                    });
                                  },
                                ),
                                const SizedBox(width: 20),
                                ThemeBox(
                                  icon: Icons.dark_mode,
                                  label: 'Dark',
                                  isSelected: _selectedTheme == ThemeMode.dark,
                                  onTap: () {
                                    setState(() {
                                      _selectedTheme = ThemeMode.dark;
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.gradientEnd,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                ),
                                onPressed: () async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setBool('theme_chosen', true);
                                  themeProvider.setThemeMode(_selectedTheme);
                                  if (mounted) {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const AuthGate(),
                                      ),
                                      (route) => false,
                                    );
                                  }
                                },
                                child: Text(
                                  'Continue',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ThemeBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemeBox({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.gradientStart.withOpacity(0.3)
              : AppColors.lightLime,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected
                ? AppColors.gradientEnd
                : Colors.grey.withOpacity(0.2),
            width: 2.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected
                  ? AppColors.primaryTextColorLight
                  : AppColors.secondaryTextColorLight,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.primaryTextColorLight
                    : AppColors.secondaryTextColorLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
