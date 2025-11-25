// onboarding_screen.dart
import 'package:budgetm/auth_gate.dart';
import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/generated/i18n/app_localizations.dart';
import 'package:budgetm/services/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<Map<String, String>> _getOnboardingData(BuildContext context) => [
    {
      'imagePath': 'images/backgrounds/onboarding1.png',
      'title': AppLocalizations.of(context)!.onboardingPage1Title,
      'description': AppLocalizations.of(context)!.onboardingPage1Description,
    },
    {
      'imagePath': 'images/backgrounds/onboarding2.png',
      'title': AppLocalizations.of(context)!.onboardingPage2Title,
      'description': AppLocalizations.of(context)!.onboardingPage2Description,
    },
    {
      'imagePath': 'images/backgrounds/onboarding3.png',
      'title': AppLocalizations.of(context)!.onboardingPage3Title,
      'description': AppLocalizations.of(context)!.onboardingPage3Description,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Log analytics event when onboarding screen is opened
    AnalyticsService().logEvent('onboarding_opened');
    _pageController.addListener(() {
      if (_pageController.page != null) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingDone', true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthGate()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingData = _getOnboardingData(context);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: onboardingData.length,
              itemBuilder: (context, index) {
                return OnboardingPageContent(
                  imagePath: onboardingData[index]['imagePath']!,
                  title: onboardingData[index]['title']!,
                  description: onboardingData[index]['description']!,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(40.0, 0, 40.0, 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(
                    onboardingData.length,
                    (index) => _buildIndicator(index),
                  ),
                ),
                _buildProceedButton(),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildProceedButton() {
    return GestureDetector(
      onTap: () {
        final onboardingData = _getOnboardingData(context);
        if (_currentPage == onboardingData.length - 1) {
          _onOnboardingDone();
        } else {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const HugeIcon(
          icon: HugeIcons.strokeRoundedArrowRight01,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

class OnboardingPageContent extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const OnboardingPageContent({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Center(child: Image.asset(imagePath, height: 460)),
          const Spacer(flex: 1),
          Text(
            title,
            style: Theme.of(context).textTheme.displayLarge,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.left,
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
