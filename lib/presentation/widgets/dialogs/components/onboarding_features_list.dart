import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Features list component for onboarding dialog
/// Displays introduction text and list of key features
class OnboardingFeaturesList extends StatelessWidget {
  const OnboardingFeaturesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prioris garde automatiquement vos listes en sécurité :',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        _buildFeatureRow(
          icon: Icons.phone_android,
          title: 'Sauvegarde locale',
          description: 'Vos données restent sur cet appareil même hors ligne',
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: 16),
        _buildFeatureRow(
          icon: Icons.cloud_upload_outlined,
          title: 'Synchronisation cloud',
          description: 'Connectez-vous pour synchroniser entre appareils',
          color: AppTheme.accentColor,
        ),
        const SizedBox(height: 16),
        _buildFeatureRow(
          icon: Icons.security,
          title: 'Contrôle total',
          description: 'Gérez vos données dans les paramètres à tout moment',
          color: AppTheme.successColor,
        ),
      ],
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadiusTokens.button,
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
