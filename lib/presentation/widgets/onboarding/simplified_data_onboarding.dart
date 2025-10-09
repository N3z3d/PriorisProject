import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/onboarding/components/onboarding_actions.dart';
import 'package:prioris/presentation/widgets/onboarding/components/onboarding_benefits_list.dart';
import 'package:prioris/presentation/widgets/onboarding/components/onboarding_header.dart';
import 'package:prioris/presentation/widgets/onboarding/components/technical_details_dialog.dart';

class SimplifiedDataOnboarding extends ConsumerWidget {
  const SimplifiedDataOnboarding({
    super.key,
    this.onGetStarted,
  });

  final VoidCallback? onGetStarted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      container: true,
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
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
    );
  }

  void _showTechnicalDetails(BuildContext context) {
    TechnicalDetailsDialog.show(context);
  }
}

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
          _buildIcon(),
          const SizedBox(width: 12),
          const Expanded(child: _BannerTexts()),
          _buildDismissButton(),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Icon(
      Icons.shield_outlined,
      color: AppTheme.primaryColor,
      size: 24,
    );
  }

  Widget _buildDismissButton() {
    return IconButton(
      onPressed: onDismiss,
      icon: const Icon(
        Icons.close,
        size: 18,
        color: AppTheme.textSecondary,
      ),
    );
  }
}

class _BannerTexts extends StatelessWidget {
  const _BannerTexts();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Vos donnees sont protegees',
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
    );
  }
}
