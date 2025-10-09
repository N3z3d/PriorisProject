import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

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
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: _buildDecoration(),
        child: Row(
          children: [
            _buildIcon(),
            const SizedBox(width: 16),
            Expanded(child: _buildTextBlock()),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      color: color.withOpacity(0.05),
      borderRadius: BorderRadiusTokens.card,
      border: Border.all(color: color.withOpacity(0.2)),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 24,
        color: color,
        semanticLabel: _iconSemanticLabel,
      ),
    );
  }

  Widget _buildTextBlock() {
    return Column(
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
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  String get _iconSemanticLabel {
    switch (icon) {
      case Icons.offline_bolt:
        return 'Icone mode hors ligne';
      case Icons.sync:
        return 'Icone synchronisation';
      case Icons.security:
        return 'Icone securite';
      default:
        return 'Icone decoratif';
    }
  }
}
