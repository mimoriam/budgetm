// lib/screens/dashboard/profile/profile_screen.dart

import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/screens/dashboard/profile/categories/category_screen.dart';
import 'package:budgetm/screens/dashboard/profile/export_data/export_data_screen.dart';
import 'package:budgetm/screens/dashboard/profile/feedback/feedback_screen.dart';
import 'package:budgetm/viewmodels/vacation_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildCustomAppBar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 24.0,
              ),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.workspace_premium,
                          color: Colors.white,
                        ),
                        const Text(
                          'Get Premium',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionHeader('ACCOUNT'),
                  _buildProfileMenuItem(Icons.person_outline, 'Edit profile'),
                  _buildProfileMenuItem(Icons.lock_outline, 'Change Password'),
                  _buildProfileMenuItem(
                    Icons.category_outlined,
                    'Categories',
                    onTap: () {
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: const CategoryScreen(),
                        withNavBar: false,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                  ),
                  _buildProfileMenuItem(
                    Icons.attach_money_outlined,
                    'Currency',
                  ),
                  _buildProfileMenuItem(
                    Icons.cloud_upload_outlined,
                    'Import & Export Data',
                    onTap: () {
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: const ExportDataScreen(),
                        withNavBar: false,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSectionHeader('LEGAL'),
                  _buildProfileMenuItem(
                    Icons.description_outlined,
                    'Terms & Conditions',
                  ),
                  _buildProfileMenuItem(
                    Icons.privacy_tip_outlined,
                    'Privacy Policy',
                  ),
                  const SizedBox(height: 12),
                  _buildSectionHeader('SUPPORT'),
                  _buildProfileMenuItem(Icons.help_outline, 'Help & Support'),
                  _buildProfileMenuItem(
                    Icons.star_outline,
                    'Feedback',
                    onTap: () {
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: const FeedbackScreen(),
                        withNavBar: false,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSectionHeader('DANGER ZONE'),
                  _buildProfileMenuItem(
                    Icons.delete_outline,
                    'Delete Account',
                    color: Colors.red,
                  ),
                  _buildProfileMenuItem(
                    Icons.logout,
                    'Logout',
                    // color: Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 6,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.gradientStart,
                            AppColors.gradientEnd,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowLeft01,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Profile',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.sync_outlined, color: Colors.black),
                    onPressed: () {
                      // TODO: Implement sync functionality
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('images/backgrounds/onboarding1.png'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Muhammad Shehroz Khan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'muhammadshehroz5683@gmail.com',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Consumer<VacationProvider>(
              builder: (context, vacationProvider, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Vacation Mode',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: vacationProvider.isVacationMode,
                      onChanged: (value) {
                        vacationProvider.toggleVacationMode();
                      },
                      activeColor: AppColors.gradientEnd,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4.0, top: 8.0, bottom: 8.0),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem(
    IconData icon,
    String title, {
    Color? color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      leading: Icon(icon, color: color ?? Colors.grey.shade700),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
