import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Individual benefit card component
///
/// Displays a single benefit with icon, title, and description.
/// Follows SRP by handling only one benefit presentation.
class OnboardingBenefitCard extends StatelessWidget {
  const OnboardingBenefitCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      // WCAG 1.3.1 : Each benefit is a focusable element
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadiusTokens.card,
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: color,
                semanticLabel: _getIconSemanticLabel(icon),
              ),
            ),
            const SizedBox(width: 16),
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
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// WCAG 1.1.1 : Provides semantic labels for icons
  String _getIconSemanticLabel(IconData icon) {
    switch (icon) {
      case Icons.offline_bolt:
        return 'Icône mode hors ligne';
      case Icons.sync:
        return 'Icône synchronisation';
      case Icons.security:
        return 'Icône sécurité';
      default:
        return 'Icône';
    }
  }
}
