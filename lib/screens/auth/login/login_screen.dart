import 'package:budgetm/auth_gate.dart';
import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/screens/auth/login/forgot_password/forgot_password_screen.dart';
import 'package:budgetm/screens/auth/signup/signup_screen.dart';
import 'package:budgetm/services/firebase_auth_service.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscureText = true;
  bool _rememberMe = false; // State for the regular checkbox
  bool _isLoadingLogin =
      false; // State for email/password login loading indicator
  bool _isLoadingGoogle = false; // State for Google Sign-In loading indicator
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService.instance;

  void _handleGoogleSignIn() async {
    if (!mounted) return;

    setState(() {
      _isLoadingGoogle = true;
    });

    try {
      final user = await _authService.signInWithGoogle();

      if (user != null) {
        // Check if this is a first-time user
        final isFirstTime = await _authService.isFirstTimeUser(user.uid);

        // Successful login
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        // Store first-time user flag
        await prefs.setBool('isFirstTimeUser', isFirstTime);

        // If this is a first-time user, create a default account
        if (isFirstTime) {
          try {
            await _firestoreService.createDefaultAccount('Cash', 'USD');
          } catch (e) {
            // Handle any errors in creating the default account
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to create default account: $e'),
                  backgroundColor: AppColors.errorColor,
                ),
              );
            }
          }
        }
        // Store the first login timestamp if it doesn't exist
        if (prefs.getString('firstLoginDate') == null) {
          await prefs.setString(
            'firstLoginDate',
            DateTime.now().toIso8601String(),
          );
        }

        if (mounted) {
          // Navigate to AuthGate to determine next screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AuthGate()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      // Handle Google Sign-In errors
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.gradientStart2,
                        AppColors.gradientEnd3,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(30.0),
                    border: Border.all(
                      color: AppColors.lightGreyBackground.withOpacity(0.5),
                    ),
                  ),
                  child: FormBuilder(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Login',
                          style: Theme.of(context).textTheme.displayLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        // 1. Subheading color changed to grey
                        Text(
                          'Enter your email and password to log in',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.secondaryTextColorLight,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        FormBuilderTextField(
                          name: 'email',
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email_outlined),
                            hintText: 'Email',
                            // 2. Hint style updated
                            hintStyle: const TextStyle(
                              color: AppColors.secondaryTextColorLight,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            // 3. Border added for inactive state
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                color: AppColors.lightGreyBackground,
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 1.0,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                color: AppColors.errorColor,
                                width: 1.0,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                color: AppColors.errorColor,
                                width: 1.0,
                              ),
                            ),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.email(),
                          ]),
                        ),
                        const SizedBox(height: 12),
                        FormBuilderTextField(
                          name: 'password',
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline),
                            hintText: 'Password',
                            // 2. Hint style updated
                            hintStyle: const TextStyle(
                              color: AppColors.secondaryTextColorLight,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            // 3. Border added for inactive state
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                color: AppColors.lightGreyBackground,
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 1.0,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                color: AppColors.errorColor,
                                width: 1.0,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                color: AppColors.errorColor,
                                width: 1.0,
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.lightGreyBackground,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.minLength(6),
                          ]),
                        ),
                        const SizedBox(height: 12),
                        // 4. Row styling updated
                        Row(
                          children: [
                            Transform.scale(
                              scale: 0.8,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                              ),
                            ),
                            const Text(
                              'Remember me',
                              style: TextStyle(fontSize: 12),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPasswordScreen(),
                                    ),
                                  );
                                }
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.gradientEnd,
                                  fontSize: 12,
                                ),
                              ),
                            ),
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
                            ),
                            onPressed: _isLoadingLogin
                                ? null
                                : () async {
                                    if (_formKey.currentState
                                            ?.saveAndValidate() ??
                                        false) {
                                      if (!mounted) return;
                                      setState(() {
                                        if (!mounted) return;
                                        _isLoadingLogin = true;
                                      });

                                      // Get email and password from form
                                      final email =
                                          _formKey
                                                  .currentState
                                                  ?.fields['email']
                                                  ?.value
                                              as String;
                                      final password =
                                          _formKey
                                                  .currentState
                                                  ?.fields['password']
                                                  ?.value
                                              as String;

                                      try {
                                        // Sign in with email and password
                                        final user = await _authService
                                            .signInWithEmailAndPassword(
                                              email,
                                              password,
                                            );

                                        if (user != null) {
                                          // Check if this is a first-time user
                                          final isFirstTime = await _authService
                                              .isFirstTimeUser(user.uid);

                                          // Successful login
                                          final prefs =
                                              await SharedPreferences.getInstance();
                                          await prefs.setBool(
                                            'isLoggedIn',
                                            true,
                                          );

                                          // Store first-time user flag
                                          await prefs.setBool(
                                            'isFirstTimeUser',
                                            isFirstTime,
                                          );

                                          // If this is a first-time user, create a default account
                                          if (isFirstTime) {
                                            try {
                                              await _firestoreService
                                                  .createDefaultAccount(
                                                    'Cash',
                                                    'USD',
                                                  );
                                            } catch (e) {
                                              // Handle any errors in creating the default account
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Failed to create default account: $e',
                                                    ),
                                                    backgroundColor:
                                                        AppColors.errorColor,
                                                  ),
                                                );
                                              }
                                            }
                                          }

                                          // Store the first login timestamp if it doesn't exist
                                          if (prefs.getString(
                                                'firstLoginDate',
                                              ) ==
                                              null) {
                                            await prefs.setString(
                                              'firstLoginDate',
                                              DateTime.now().toIso8601String(),
                                            );
                                          }

                                          if (context.mounted) {
                                            // Navigate to AuthGate to determine next screen
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const AuthGate(),
                                              ),
                                              (route) => false,
                                            );
                                          }
                                        }
                                      } catch (e) {
                                        // Handle login errors
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(e.toString()),
                                              backgroundColor:
                                                  AppColors.errorColor,
                                            ),
                                          );
                                        }
                                      } finally {
                                        if (mounted) {
                                          setState(() {
                                            if (!mounted) return;
                                            _isLoadingLogin = false;
                                          });
                                        }
                                      }
                                    }
                                  },
                            child: _isLoadingLogin
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
                                : const Text('Login'),
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: AppColors.lightGreyBackground,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'Or login with',
                                style: TextStyle(
                                  color: AppColors.secondaryTextColorLight,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: AppColors.lightGreyBackground,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: _isLoadingGoogle
                              ? const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : SignInButton(
                                  Buttons.google,
                                  onPressed: () {
                                    _handleGoogleSignIn();
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: SignInButton(
                            Buttons.apple,
                            onPressed: () {},
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 5. "Don't have an account" text styled
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.secondaryTextColorLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignupScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                  decorationColor: AppColors.gradientEnd,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
