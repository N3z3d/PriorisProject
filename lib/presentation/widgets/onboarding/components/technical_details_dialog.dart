import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/common/forms/common_button.dart';

/// Dialog displaying technical details about data persistence
///
/// Explains local storage, intelligent sync, and automatic merging
/// to users who want to understand the technical implementation.
class TechnicalDetailsDialog extends StatelessWidget {
  const TechnicalDetailsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusTokens.modal,
      ),
      title: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Text('Comment ça marche'),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TechnicalPoint(
            icon: Icons.phone_android,
            title: 'Stockage local',
            description: 'Vos données sont toujours disponibles sur votre appareil, même sans connexion.',
          ),
          SizedBox(height: 16),
          TechnicalPoint(
            icon: Icons.cloud_sync,
            title: 'Synchronisation intelligente',
            description: 'Quand vous vous connectez, vos données se synchronisent automatiquement entre tous vos appareils.',
          ),
          SizedBox(height: 16),
          TechnicalPoint(
            icon: Icons.merge_type,
            title: 'Fusion automatique',
            description: 'Si des conflits surviennent, nous fusionnons vos données intelligemment sans rien perdre.',
          ),
        ],
      ),
      actions: [
        CommonButton(
          onPressed: () => Navigator.of(context).pop(),
          text: 'Compris',
        ),
      ],
    );
  }

  /// Shows the technical details dialog
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TechnicalDetailsDialog(),
    );
  }
}

/// Widget to display a technical point with icon, title, and description
class TechnicalPoint extends StatelessWidget {
  const TechnicalPoint({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadiusTokens.button,
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppTheme.primaryColor,
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
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
