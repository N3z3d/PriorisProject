import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/onboarding/components/onboarding_actions.dart';
import 'package:prioris/presentation/widgets/onboarding/components/onboarding_benefits_list.dart';
import 'package:prioris/presentation/widgets/onboarding/components/onboarding_header.dart';
import 'package:prioris/presentation/widgets/onboarding/components/technical_details_dialog.dart';

/// Onboarding ultra-simplifié pour expliquer la persistance des données
///
/// PRINCIPE UX:
/// - Message rassurant principal: "Tout est automatique"
/// - Éliminer la complexité technique
/// - Focus sur les bénéfices utilisateur
/// - Call-to-action clair pour commencer
class SimplifiedDataOnboarding extends ConsumerWidget {
  const SimplifiedDataOnboarding({
    super.key,
    this.onGetStarted,
  });

  final VoidCallback? onGetStarted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      // WCAG 1.3.1 : Structure d'onboarding avec région landmark
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadiusTokens.card,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const OnboardingHeader(),
            const SizedBox(height: 32),
            const OnboardingBenefitsList(),
            const SizedBox(height: 32),
            OnboardingActions(
              onGetStarted: onGetStarted,
              onShowTechnicalDetails: () => _showTechnicalDetails(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showTechnicalDetails(BuildContext context) {
    TechnicalDetailsDialog.show(context);
  }
}

/// Version compacte pour l'affichage inline dans l'app
class CompactDataOnboardingBanner extends ConsumerWidget {
  const CompactDataOnboardingBanner({
    super.key,
    this.onDismiss,
  });

  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadiusTokens.card,
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.shield_outlined,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vos données sont protégées',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Sync automatique et sauvegarde locale',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(
              Icons.close,
              size: 18,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}