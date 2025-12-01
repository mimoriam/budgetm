// lib/screens/dashboard/profile/profile_screen.dart

import 'package:budgetm/auth_gate.dart';
import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/generated/i18n/app_localizations.dart';
import 'package:budgetm/screens/dashboard/profile/categories/category_screen.dart';
import 'package:budgetm/screens/dashboard/profile/currency/currency_rates.dart';
import 'package:budgetm/screens/dashboard/profile/feedback/feedback_screen.dart';
import 'package:budgetm/screens/paywall/paywall_screen.dart';
import 'package:budgetm/services/firebase_auth_service.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/viewmodels/vacation_mode_provider.dart';
import 'package:budgetm/viewmodels/subscription_provider.dart';
import 'package:budgetm/viewmodels/user_provider.dart';
import 'package:budgetm/viewmodels/locale_provider.dart';
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

                      return GestureDetector(
                        onTap: isLoading
                            ? null
                            : () {
                                if (isSubscribed) {
                                  _showSubscriptionActionsSheet(context);
                                } else {
                                  PersistentNavBarNavigator.pushNewScreen(
                                    context,
                                    screen: const PaywallScreen(),
                                    withNavBar: false,
                                    pageTransitionAnimation:
                                        PageTransitionAnimation.cupertino,
                                  );
                                }
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                                padding: const EdgeInsets.all(6),
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
                                          ? AppLocalizations.of(
                                              context,
                                            )!.profilePremiumActive
                                          : AppLocalizations.of(
                                              context,
                                            )!.profileFreePlan,
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isSubscribed
                                          ? AppLocalizations.of(
                                              context,
                                            )!.profilePremiumDescription
                                          : AppLocalizations.of(
                                              context,
                                            )!.profileUpgradeDescription,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isLoading)
                                Container(
                                  padding: const EdgeInsets.all(8),
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
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isSubscribed
                                        ? Icons.settings
                                        : Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildSectionHeader(
                    AppLocalizations.of(context)!.profileAccount,
                  ),
                  if (showChangePassword)
                    _buildProfileMenuItem(
                      Icons.lock_outline,
                      'Change Password',
                    ),
                  _buildProfileMenuItem(
                    Icons.category_outlined,
                    AppLocalizations.of(context)!.profileCategories,
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
                    AppLocalizations.of(context)!.profileMenuCurrency,
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
                  _buildProfileMenuItem(
                    Icons.language_outlined,
                    AppLocalizations.of(context)!.profileLanguage,
                    onTap: () {
                      _showLanguageSelectorDialog(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSectionHeader(
                    AppLocalizations.of(context)!.profileLegal,
                  ),
                  _buildProfileMenuItem(
                    Icons.description_outlined,
                    AppLocalizations.of(context)!.profileTermsConditions,
                  ),
                  _buildProfileMenuItem(
                    Icons.privacy_tip_outlined,
                    AppLocalizations.of(context)!.profilePrivacyPolicy,
                  ),
                  const SizedBox(height: 12),
                  _buildSectionHeader(
                    AppLocalizations.of(context)!.profileSupport,
                  ),
                  _buildProfileMenuItem(
                    Icons.help_outline,
                    AppLocalizations.of(context)!.profileHelpSupport,
                  ),
                  _buildProfileMenuItem(
                    Icons.star_outline,
                    AppLocalizations.of(context)!.profileFeedback,
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
                  _buildSectionHeader(
                    AppLocalizations.of(context)!.profileDangerZone,
                  ),
                  _buildProfileMenuItem(
                    Icons.delete_forever,
                    AppLocalizations.of(context)!.profileDeleteAccount,
                    color: Colors.red,
                    onTap: () {
                      _showDeleteAccountConfirmationDialog(context);
                    },
                  ),
                  _buildProfileMenuItem(
                    Icons.logout,
                    AppLocalizations.of(context)!.profileLogout,
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
                              content: Text(
                                AppLocalizations.of(
                                  context,
                                )!.profileErrorSigningOut(e.toString()),
                              ),
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
                  Text(
                    AppLocalizations.of(context)!.profileTitle,
                    textAlign: TextAlign.start,
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
                  return Text(
                    AppLocalizations.of(context)!.profileUserNotFound,
                  );
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
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.profileEditDisplayName,
                                    ),
                                  ),
                                  content: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: TextField(
                                      controller: _controller,
                                      autofocus: true,
                                      textAlign: TextAlign.start,
                                      decoration: InputDecoration(
                                        hintText: AppLocalizations.of(
                                          context,
                                        )!.hintEnterDisplayName,
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
                                      child: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.profileCancel,
                                      ),
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
                                                  try {
                                                    // Update Firestore with 'name' field (consistent with registration)
                                                    await FirestoreService
                                                        .instance
                                                        .updateUserData(
                                                          user.uid,
                                                          {
                                                            'name': newName,
                                                          },
                                                        );
                                                    // Refresh UserProvider to get updated name from Firestore
                                                    if (context.mounted) {
                                                      await Provider.of<UserProvider>(
                                                        context,
                                                        listen: false,
                                                      ).refreshUserData();
                                                    }
                                                  } catch (e) {
                                                    debugPrint(
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
                                          : Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.profileSave,
                                            ),
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
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
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
                  textAlign: TextAlign.center,
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
                    Text(
                      AppLocalizations.of(context)!.profileVacationMode,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
                          // Turning ON vacation mode: check subscription and existing accounts
                          final subscriptionProvider =
                              Provider.of<SubscriptionProvider>(
                                context,
                                listen: false,
                              );

                          // Only prevent vacation mode switching if unsubscribed AND no existing vacation accounts
                          // This allows users who created vacation accounts while subscribed
                          // to continue using them even after subscription expires
                          if (!subscriptionProvider.isSubscribed) {
                            final firestoreService =
                                FirestoreService.instance;
                            final allAccounts = await firestoreService
                                .getAllAccounts();
                            final vacationAccounts = allAccounts
                                .where((a) => a.isVacationAccount == true)
                                .toList();

                            // If no existing vacation accounts, show paywall to prevent creation
                            if (vacationAccounts.isEmpty) {
                              PersistentNavBarNavigator.pushNewScreen(
                                context,
                                screen: const PaywallScreen(),
                                withNavBar: false,
                                pageTransitionAnimation:
                                    PageTransitionAnimation.cupertino,
                              );
                              return;
                            }
                            // If they have existing vacation accounts, allow switching to use them
                          }

                          // Turning ON vacation mode: go through selection flow
                          await Provider.of<VacationProvider>(
                            context,
                            listen: false,
                          ).checkAndShowVacationDialog(context);
                        } else {
                          // Turning OFF vacation mode
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
    return Builder(
      builder: (context) {
        final textDirection = Directionality.of(context);
        return Align(
          alignment: textDirection == TextDirection.rtl
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 4.0,
              right: 4.0,
              top: 8.0,
              bottom: 8.0,
            ),
            child: Text(
              title.toUpperCase(),
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        );
      },
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
        textAlign: TextAlign.start,
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

  ImageProvider _getProfileImage(UserProvider userProvider) {
    final user = userProvider.currentUser;

    if (user != null &&
        userProvider.hasGoogleProvider &&
        userProvider.photoURL != null) {
      return NetworkImage(userProvider.photoURL!);
    }

    return const AssetImage('images/backgrounds/onboarding1.png');
  }

  /// Bottom sheet with Manage / Restore / Refresh actions
  void _showSubscriptionActionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Consumer<SubscriptionProvider>(
            builder: (context, subscriptionProvider, child) {
              final isLoading = subscriptionProvider.isLoading;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle at top
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        "Subscription Options",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Refresh Status
                    // ListTile(
                    //   enabled: !isLoading,
                    //   leading: Icon(
                    //     Icons.refresh,
                    //     color: isLoading ? Colors.grey : null,
                    //   ),
                    //   title: Text(
                    //     AppLocalizations.of(context)!.profileRefreshStatus,
                    //     textAlign: TextAlign.start,
                    //     style: TextStyle(color: isLoading ? Colors.grey : null),
                    //   ),
                    //   trailing: isLoading
                    //       ? const SizedBox(
                    //           width: 20,
                    //           height: 20,
                    //           child: CircularProgressIndicator(strokeWidth: 2),
                    //         )
                    //       : null,
                    //   onTap: isLoading
                    //       ? null
                    //       : () async {
                    //           Navigator.of(ctx).pop();
                    //           try {
                    //             await subscriptionProvider.ensureFreshStatus(
                    //               force: true,
                    //             );
                    //             if (context.mounted) {
                    //               ScaffoldMessenger.of(context).showSnackBar(
                    //                 const SnackBar(
                    //                   content: Text(
                    //                     'Subscription status refreshed',
                    //                   ),
                    //                   backgroundColor: Colors.green,
                    //                   duration: Duration(seconds: 2),
                    //                 ),
                    //               );
                    //             }
                    //           } catch (e) {
                    //             if (context.mounted) {
                    //               ScaffoldMessenger.of(context).showSnackBar(
                    //                 SnackBar(
                    //                   content: Text(
                    //                     subscriptionProvider.error ??
                    //                         'Failed to refresh status',
                    //                   ),
                    //                   backgroundColor: Colors.red,
                    //                 ),
                    //               );
                    //             }
                    //           }
                    //         },
                    // ),
                    // Restore Purchases
                    // TODO: Restore purchases only if it's a new app install and user is subscribed
                    // TODO: and wants the subscription again without paying
                    // ListTile(
                    //   enabled: !isLoading,
                    //   leading: Icon(
                    //     Icons.restore,
                    //     color: isLoading ? Colors.grey : null,
                    //   ),
                    //   title: Text(
                    //     AppLocalizations.of(context)!.profileRestorePurchases,
                    //     textAlign: TextAlign.start,
                    //     style: TextStyle(color: isLoading ? Colors.grey : null),
                    //   ),
                    //   onTap: isLoading
                    //       ? null
                    //       : () async {
                    //           Navigator.of(ctx).pop();
                    //           final success = await subscriptionProvider
                    //               .restorePurchases();
                    //           if (context.mounted) {
                    //             ScaffoldMessenger.of(context).showSnackBar(
                    //               SnackBar(
                    //                 content: Text(
                    //                   success
                    //                       ? 'Checking for purchases...'
                    //                       : subscriptionProvider.error ??
                    //                             'Failed to restore purchases',
                    //                 ),
                    //                 backgroundColor: success
                    //                     ? Colors.blue
                    //                     : Colors.red,
                    //               ),
                    //             );
                    //           }
                    //         },
                    // ),
                    // Manage Subscription
                    ListTile(
                      enabled: !isLoading,
                      leading: Icon(
                        Icons.manage_accounts,
                        color: isLoading ? Colors.grey : null,
                      ),
                      title: Text(
                        AppLocalizations.of(context)!.profileManageSubscription,
                        textAlign: TextAlign.start,
                        style: TextStyle(color: isLoading ? Colors.grey : null),
                      ),
                      onTap: isLoading
                          ? null
                          : () async {
                              Navigator.of(ctx).pop();
                              await subscriptionProvider.openManagementPage();
                            },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Language selector dialog
  void _showLanguageSelectorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<LocaleProvider>(
          builder: (context, localeProvider, child) {
            final supportedLocales = AppLocalizations.supportedLocales;
            
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.languageSelectLanguage),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: supportedLocales.map((locale) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _buildLanguageOption(
                          context,
                          localeProvider,
                          locale,
                          localeProvider.getLocaleDisplayName(locale),
                          localeProvider.getLocaleFlag(locale),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.profileCancel),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    LocaleProvider localeProvider,
    Locale locale,
    String languageName,
    String flag,
  ) {
    final isSelected =
        localeProvider.currentLocale.languageCode == locale.languageCode;

    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(
        languageName,
        textAlign: TextAlign.start,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).primaryColor : null,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
          : null,
      onTap: () async {
        await localeProvider.setLocale(locale);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  /// Shows a confirmation dialog before deleting the account
  void _showDeleteAccountConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.profileDeleteAccountTitle,
              ),
              content: Text(
                AppLocalizations.of(context)!.profileDeleteAccountMessage,
              ),
              actions: [
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  child: Text(
                    AppLocalizations.of(context)!.profileCancel,
                  ),
                ),
                ElevatedButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setState(() {
                            isDeleting = true;
                          });
                          try {
                            await _authService.deleteAccount();
                            if (context.mounted) {
                              // Capture the ScaffoldMessengerState before navigation so we can show a SnackBar
                              final messenger = ScaffoldMessenger.of(context);
                              Navigator.of(context).pop();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AuthGate(),
                                ),
                                (route) => false,
                              );
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(context)!
                                        .profileDeleteAccountSuccess,
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              setState(() {
                                isDeleting = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(context)!
                                        .profileDeleteAccountError(e.toString()),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context)!
                              .profileDeleteAccountConfirm,
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
