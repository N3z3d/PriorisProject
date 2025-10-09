import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Header section of the onboarding screen with icon and titles
///
/// Displays a shield icon, main title, and subtitle to reassure users
/// about data protection and automatic management.
class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIcon(),
        const SizedBox(height: 24),
        _buildTitle(),
        const SizedBox(height: 16),
        _buildSubtitle(),
      ],
    );
  }

  Widget _buildIcon() {
    return Semantics(
      image: true,
      label: 'Icône de protection - Bouclier de sécurité',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.shield_outlined,
          size: 48,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Semantics(
      header: true,
      child: Text(
        'Vos listes sont automatiquement protégées',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return const Text(
      'Prioris s\'occupe de tout. Créez vos listes, nous nous chargeons du reste.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        color: AppTheme.textSecondary,
        height: 1.5,
      ),
    );
  }
}
