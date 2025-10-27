// lib/screens/dashboard/profile/profile_screen.dart

import 'package:budgetm/auth_gate.dart';
import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/screens/dashboard/profile/categories/category_screen.dart';
import 'package:budgetm/screens/dashboard/profile/currency/currency_rates.dart';
import 'package:budgetm/screens/dashboard/profile/feedback/feedback_screen.dart';
import 'package:budgetm/screens/paywall/paywall_screen.dart';
import 'package:budgetm/services/firebase_auth_service.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/viewmodels/vacation_mode_provider.dart';
import 'package:budgetm/viewmodels/subscription_provider.dart';
import 'package:budgetm/viewmodels/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();


  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final showChangePassword =
        currentUser?.providerData.any((p) => p.providerId == 'password') ??
        false;
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
                  // Premium Status Card
                  Consumer<SubscriptionProvider>(
                    builder: (context, subscriptionProvider, child) {
                      final isSubscribed = subscriptionProvider.isSubscribed;
                      final isLoading = subscriptionProvider.isLoading;

                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: isSubscribed
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF4CAF50),
                                    Color(0xFF2E7D32),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : const LinearGradient(
                                  colors: [
                                    Color(0xFFFF9800),
                                    Color(0xFFE65100),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (isSubscribed ? Colors.green : Colors.orange)
                                      .withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isSubscribed
                                    ? Icons.workspace_premium
                                    : Icons.lock_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isSubscribed
                                        ? 'Premium Active'
                                        : 'Get Premium',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isSubscribed
                                        ? 'You have access to all premium features'
                                        : 'Unlock unlimited vacation accounts, color picker, and recurring budgets',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (isSubscribed)
                                    Builder(
                                      builder: (context) {
                                        final renewalText = context.read<SubscriptionProvider>().renewalCopy;
                                        if (renewalText == null) return const SizedBox.shrink();
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                            renewalText,
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.9),
                                              fontSize: 12,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                            if (isLoading) // <-- Check loading flag
                              Container(
                                padding: const EdgeInsets.all(8), // Match size
                                child: const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            else
                              GestureDetector(
                                onTap: () {
                                  if (isSubscribed) {
                                    _showSubscriptionActionsSheet(context);
                                  } else {
                                    PersistentNavBarNavigator.pushNewScreen(
                                      context,
                                      screen: const PaywallScreen(),
                                      withNavBar: false,
                                      pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isSubscribed ? Icons.settings : Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildSectionHeader('ACCOUNT'),
                  // _buildProfileMenuItem(Icons.person_outline, 'Edit profile'),
                  if (showChangePassword)
                    _buildProfileMenuItem(
                      Icons.lock_outline,
                      'Change Password',
                    ),
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
                    onTap: () {
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: const CurrencyRatesScreen(),
                        withNavBar: false,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                  ),
                  // _buildProfileMenuItem(
                  //   Icons.cloud_upload_outlined,
                  //   'Import & Export Data',
                  //   onTap: () {
                  //     PersistentNavBarNavigator.pushNewScreen(
                  //       context,
                  //       screen: const ExportDataScreen(),
                  //       withNavBar: false,
                  //       pageTransitionAnimation:
                  //           PageTransitionAnimation.cupertino,
                  //     );
                  //   },
                  // ),
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
                  // _buildProfileMenuItem(
                  //   Icons.delete_outline,
                  //   'Delete Account',
                  //   color: Colors.red,
                  // ),
                  _buildProfileMenuItem(
                    Icons.logout,
                    'Logout',
                    color: Colors.red,
                    onTap: () async {
                      try {
                        await _authService.signOut();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AuthGate(),
                            ),
                            (route) => false,
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error signing out: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
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
                  // IconButton(
                  //   icon: const Icon(Icons.sync_outlined, color: Colors.black),
                  //   onPressed: () {
                  //     // TODO: Implement sync functionality
                  //   },
                  // ),
                  // const SizedBox(width: 16),
                  Text(
                    'Profile',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
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
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return CircleAvatar(
                  radius: 40,
                  backgroundImage: _getProfileImage(userProvider),
                );
              },
            ),
            const SizedBox(height: 12),
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                if (userProvider.currentUser == null) {
                  return const Text('User not found');
                }
                final displayName = userProvider.displayName;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        final TextEditingController _controller =
                            TextEditingController(text: displayName);
                        showDialog(
                          context: context,
                          builder: (context) {
                            bool isSaving = false;
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  title: Center(
                                    child: const Text('Edit display name'),
                                  ),
                                  content: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: TextField(
                                      controller: _controller,
                                      autofocus: true,
                                      decoration: InputDecoration(
                                        hintText: 'Enter display name',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.0,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                              vertical: 12.0,
                                            ),
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: isSaving
                                          ? null
                                          : () async {
                                              final newName = _controller.text
                                                  .trim();
                                              if (newName.isEmpty) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Display name cannot be empty',
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                                return;
                                              }
                                              setState(() {
                                                isSaving = true;
                                              });
                                              try {
                                                final user = FirebaseAuth
                                                    .instance
                                                    .currentUser;
                                                if (user != null) {
                                                  await user.updateDisplayName(
                                                    newName,
                                                  );
                                                  await user.reload();
                                                  // Also update the user's Firestore profile document so the
                                                  // display name is persisted in Firestore and works with
                                                  // offline persistence.
                                                  try {
                                                    await FirestoreService
                                                        .instance
                                                        .updateUserData(
                                                          user.uid,
                                                          {
                                                            'displayName':
                                                                newName,
                                                          },
                                                        );
                                                  } catch (e) {
                                                    // Non-fatal: log and continue; UI already updated from auth.
                                                    print(
                                                      'Failed to update Firestore user document: $e',
                                                    );
                                                  }
                                                }
                                                if (context.mounted) {
                                                  Navigator.of(context).pop();
                                                }
                                              } on FirebaseAuthException catch (
                                                e
                                              ) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        e.message ??
                                                            'Failed to update display name.',
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Error: $e',
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                }
                                              } finally {
                                                if (context.mounted) {
                                                  setState(() {
                                                    isSaving = false;
                                                  });
                                                }
                                              }
                                            },
                                      child: isSaving
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text('Save'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                      child: Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.edit, size: 18, color: Colors.black54),
                  ],
                );
              },
            ),
            const SizedBox(height: 4),
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                if (userProvider.currentUser == null) {
                  return const SizedBox.shrink();
                }
                return Text(
                  userProvider.email,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                );
              },
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
                      onChanged: (value) async {
                        if (value) {
                          // Trigger the check and dialog flow from the provider.
                          await Provider.of<VacationProvider>(
                            context,
                            listen: false,
                          ).checkAndShowVacationDialog(context);
                        } else {
                          // Deactivate vacation mode immediately.
                          await Provider.of<VacationProvider>(
                            context,
                            listen: false,
                          ).setVacationMode(false);
                        }
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

  // Helper method to get the appropriate profile image
  ImageProvider _getProfileImage(UserProvider userProvider) {
    final user = userProvider.currentUser;

    // Check if user is logged in via Google and has a photo URL
    if (user != null &&
        userProvider.hasGoogleProvider &&
        userProvider.photoURL != null) {
      return NetworkImage(userProvider.photoURL!);
    }

    // Fall back to the default asset image
    return const AssetImage('images/backgrounds/onboarding1.png');
  }



  // (Removed legacy restore dialog in favor of bottom sheet actions)

  // Bottom sheet with Manage / Restore / Refresh actions
  void _showSubscriptionActionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Consumer<SubscriptionProvider>(
            builder: (context, subscriptionProvider, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.manage_accounts),
                    title: const Text('Manage subscription'),
                    onTap: subscriptionProvider.isLoading
                        ? null
                        : () async {
                            Navigator.of(ctx).pop();
                            await subscriptionProvider.openManagementPage();
                          },
                  ),
                  ListTile(
                    leading: const Icon(Icons.restore),
                    title: const Text('Restore purchases'),
                    onTap: subscriptionProvider.isLoading
                        ? null
                        : () async {
                            final ok = await subscriptionProvider.restorePurchases();
                            if (mounted) {
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ok
                                        ? 'Purchases restored successfully!'
                                        : 'No active subscription found. You are now on the free plan.',
                                  ),
                                  backgroundColor: ok ? Colors.green : Colors.orange,
                                ),
                              );
                            }
                          },
                  ),
                  ListTile(
                    leading: const Icon(Icons.refresh),
                    title: const Text('Refresh status'),
                    onTap: subscriptionProvider.isLoading
                        ? null
                        : () async {
                            Navigator.of(ctx).pop();
                            await subscriptionProvider.refreshSubscriptionStatus();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Subscription status refreshed'),
                                ),
                              );
                            }
                          },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
