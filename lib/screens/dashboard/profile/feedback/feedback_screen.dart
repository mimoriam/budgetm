import 'package:budgetm/constants/appColors.dart';
import 'package:budgetm/generated/i18n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  static const String _playStorePackageId = 'xtra.budget.manager';
  static const String _playStoreWebUrl =
      'https://play.google.com/store/apps/details?id=xtra.budget.manager';

  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  int _selectedRating = 4;

  bool get _shouldShowForm => _selectedRating <= 3;
  bool get _isPositiveRating => _selectedRating >= 4;

  void _onRatingSelected(int value) {
    final bool wasShowingForm = _shouldShowForm;
    setState(() {
      _selectedRating = value;
    });

    if (wasShowingForm && value > 3) {
      _formKey.currentState?.reset();
    }
  }

  Future<void> _handleSend() async {
    if (_isPositiveRating) {
      await _openPlayStore();
      return;
    }

    if (_shouldShowForm) {
      await _sendFeedback();
      return;
    }
  }

  Future<void> _openPlayStore() async {
    final Uri marketUri =
        Uri.parse('market://details?id=$_playStorePackageId');
    final Uri webUri = Uri.parse(_playStoreWebUrl);

    try {
      final bool launchedMarket =
          await launchUrl(marketUri, mode: LaunchMode.externalApplication);
      if (!launchedMarket) {
        final bool launchedWeb =
            await launchUrl(webUri, mode: LaunchMode.externalApplication);
        if (!launchedWeb && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open the Play Store.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the Play Store.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendFeedback() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // Simulate network request
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.profileFeedbackThankYou),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Pop after a short delay to let user see the message
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // GestureDetector to dismiss keyboard on tap outside of text fields
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true, // Handles keyboard overlay
        backgroundColor: AppColors.scaffoldBackground,
        body: Column(
          children: [
            _buildCustomAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your thoughts help us improve and bring you a better experience.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.secondaryTextColorLight,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildRatingSection(),
                    if (_shouldShowForm) ...[
                      const SizedBox(height: 24),
                      FormBuilder(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.secondaryTextColorLight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            FormBuilderTextField(
                              name: 'description',
                              maxLines: 8,
                              maxLength: 500, // Added character limit
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)!.hintWriteThoughts,
                                hintStyle: const TextStyle(
                                  color: AppColors.lightGreyBackground,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                counterText: "", // Hide default counter
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                  horizontal: 20.0,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              // Added character counter
                              buildCounter:
                                  (
                                    context, {
                                    required int currentLength,
                                    required bool isFocused,
                                    required int? maxLength,
                                  }) {
                                    return Container(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        '$currentLength/$maxLength',
                                        style: const TextStyle(
                                          color:
                                              AppColors.secondaryTextColorLight,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  },
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Buttons are now inside the scroll view
                    _buildBottomButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
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
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
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
              const SizedBox(width: 12),
              Text(
                "Hi, ${FirebaseAuth.instance.currentUser?.displayName ?? FirebaseAuth.instance.currentUser?.email?.split('@')[0] ?? 'User'}",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How would you rate your experience?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryTextColorLight,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(5, (index) {
            final starValue = index + 1;
            final bool isFilled = starValue <= _selectedRating;
            return IconButton(
              onPressed: () => _onRatingSelected(starValue),
              icon: Icon(
                isFilled ? Icons.star : Icons.star_border,
                color: isFilled ? AppColors.gradientEnd : Colors.grey.shade400,
                size: 32,
              ),
            );
          }),
        ),
        Text(
          _isPositiveRating
              ? 'Awesome! Tap send to rate us on the Play Store.'
              : 'Please tell us what went wrong so we can improve.',
          style: const TextStyle(
            color: AppColors.secondaryTextColorLight,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    final bool disableButton = _shouldShowForm && _isLoading;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: disableButton ? null : _handleSend,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gradientEnd,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            child: _shouldShowForm && _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : Text(
                    _isPositiveRating ? 'Rate on Play Store' : 'Send',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () async {
            final Uri emailUri = Uri(
              scheme: 'mailto',
              path: 'shehroz.khan@email.com',
            );
            try {
              if (!await launchUrl(emailUri, mode: LaunchMode.externalApplication)) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.profileFeedbackEmailError),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            } catch (_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Could not open email client.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: const Text(
            'Send an Email Instead',
            style: TextStyle(
              color: AppColors.gradientEnd,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.gradientEnd,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
