import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/common/forms/common_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Action buttons section for the onboarding screen
///
/// Contains the primary call-to-action button and a link to view
/// technical details. Handles onboarding completion marking.
class OnboardingActions extends StatelessWidget {
  const OnboardingActions({
    super.key,
    this.onGetStarted,
    required this.onShowTechnicalDetails,
  });

  final VoidCallback? onGetStarted;
  final VoidCallback onShowTechnicalDetails;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main call-to-action
        SizedBox(
          width: double.infinity,
          child: Focus(
            // WCAG 2.4.3 : Auto focus on main action
            autofocus: true,
            child: CommonButton(
              onPressed: () {
                _markOnboardingCompleted();
                onGetStarted?.call();
              },
              text: 'Créer ma première liste',
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Discreet link for technical details
        GestureDetector(
          onTap: onShowTechnicalDetails,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Comment ça marche ?',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.primaryColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
  }
}
