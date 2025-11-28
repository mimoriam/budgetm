// onboarding_screen.dart
import 'dart:async';
import 'dart:io';

import 'package:budgetm/auth_gate.dart';
import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/generated/i18n/app_localizations.dart';
import 'package:budgetm/screens/auth/login/login_screen.dart';
import 'package:budgetm/services/analytics_service.dart';
import 'package:budgetm/services/firebase_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_button/sign_in_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;
  bool _isUserScrolling = false;
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoadingGoogle = false;
  bool _isLoadingApple = false;

  List<String> _getOnboardingImages() => [
    'images/backgrounds/splash_1.png',
    'images/backgrounds/splash_2.png',
    'images/backgrounds/splash_3.png',
    'images/backgrounds/splash_4.png',
    'images/backgrounds/splash_5.png',
    'images/backgrounds/splash_6.png',
  ];

  List<String> _getOnboardingTexts() => [
    'Manage All Finance at One Place',
    'Plan & Track Budgets',
    'Track Vacation Spendings',
    'Multiple Accounts & Currencies',
    'Reminders for Subscriptions',
    'Achieve Your Goals',
  ];

  @override
  void initState() {
    super.initState();
    AnalyticsService().logEvent('onboarding_opened');
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isUserScrolling && mounted) {
        final nextPage = (_currentPage + 1) % _getOnboardingImages().length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _pageController.dispose();
    super.dispose();
  }

  void _showAuthBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AuthBottomSheet(
        onEmailLogin: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
        onGoogleSignIn: _handleGoogleSignIn,
        onAppleSignIn: _handleAppleSignIn,
        isLoadingGoogle: _isLoadingGoogle,
        isLoadingApple: _isLoadingApple,
      ),
    );
  }

  void _handleGoogleSignIn() async {
    if (!mounted) return;
    AnalyticsService().logEvent('google_sign_up_opened');

    setState(() {
      _isLoadingGoogle = true;
    });

    try {
      final user = await _authService.signInWithGoogle();

      if (user != null) {
        final isFirstTime = await _authService.isFirstTimeUser(user.uid);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setBool('onboardingDone', true);
        await prefs.setBool('isFirstTimeUser', isFirstTime);

        if (prefs.getString('firstLoginDate') == null) {
          await prefs.setString(
            'firstLoginDate',
            DateTime.now().toIso8601String(),
          );
        }

        if (mounted) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AuthGate()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingGoogle = false;
        });
      }
    }
  }

  void _handleAppleSignIn() async {
    if (!mounted) return;

    setState(() {
      _isLoadingApple = true;
    });

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Apple Sign-In is not yet implemented'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingApple = false;
        });
      }
    }
  }

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onboardingImages = _getOnboardingImages();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/backgrounds/splash_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
            // 1. The Carousel Section - Now takes ALL available remaining space
            Expanded(
              child: GestureDetector(
                onPanStart: (_) {
                  _isUserScrolling = true;
                  _stopAutoScroll();
                },
                onPanEnd: (_) {
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      _isUserScrolling = false;
                      _startAutoScroll();
                    }
                  });
                },
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: onboardingImages.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        width: double.infinity,
                        // decoration: BoxDecoration(
                        //   color: Colors.red.withOpacity(0.1), // Uncomment to debug layout bounds
                        // ),
                        child: Image.asset(
                          onboardingImages[index],
                          // fitWidth ensures it fills the width, but isn't cropped vertically
                          // switch to BoxFit.contain if you want to ensure the whole image is ALWAYS seen without cropping
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _getOnboardingTexts()[_currentPage],
                key: ValueKey(_currentPage),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // 2. Indicators Section - Now sits directly under the expanded carousel
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  onboardingImages.length,
                  (index) => _buildIndicator(index),
                ),
              ),
            ),

            // 3. Continue Button Section - Anchored at the bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(40.0, 0, 40.0, 1.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showAuthBottomSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.gradientStart,
                          AppColors.gradientEnd,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    child: Center(
                      child: Text(
                        // AppLocalizations.of(context)!.continueButton
                        "Sign in to Continue",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 4. "I am already registered" link
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: TextButton(
                onPressed: _navigateToLogin,
                child: const Text(
                  'I am already registered',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: _currentPage == index ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppColors.gradientEnd
            : AppColors.lightGreyBackground,
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}

// Keeping your exact Logic for the Bottom Sheet
class _AuthBottomSheet extends StatelessWidget {
  final VoidCallback onEmailLogin;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onAppleSignIn;
  final bool isLoadingGoogle;
  final bool isLoadingApple;

  const _AuthBottomSheet({
    required this.onEmailLogin,
    required this.onGoogleSignIn,
    required this.onAppleSignIn,
    required this.isLoadingGoogle,
    required this.isLoadingApple,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightGreyBackground,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.loginTitle,
            style: Theme.of(context).textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.loginSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryTextColorLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: isLoadingGoogle
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : SignInButton(
                    Buttons.google,
                    onPressed: onGoogleSignIn,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
          ),
          if (Platform.isIOS) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: isLoadingApple
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : SignInButton(
                      Buttons.apple,
                      onPressed: onAppleSignIn,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
            ),
          ],
          
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Divider(color: AppColors.lightGreyBackground)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  AppLocalizations.of(context)!.orContinueWith,
                  style: TextStyle(color: AppColors.secondaryTextColorLight),
                ),
              ),
              Expanded(child: Divider(color: AppColors.lightGreyBackground)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              onPressed: onEmailLogin,
              child: Text(
                AppLocalizations.of(context)!.loginTitle,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
