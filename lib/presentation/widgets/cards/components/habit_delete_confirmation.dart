import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/premium_exports.dart';

/// Dialog de confirmation de suppression d'habitude
///
/// Responsabilité: Afficher une confirmation avant suppression définitive
class HabitDeleteConfirmation extends StatelessWidget {
  final String habitName;
  final VoidCallback onDelete;

  const HabitDeleteConfirmation({
    super.key,
    required this.habitName,
    required this.onDelete,
  });

  /// Affiche le dialog de confirmation
  static void show(
    BuildContext context, {
    required String habitName,
    required VoidCallback onDelete,
  }) {
    context.showPremiumModal(
      HabitDeleteConfirmation(
        habitName: habitName,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Glassmorphism.glassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Supprimer l\'habitude ?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cette action est irréversible. Toutes les données liées à cette habitude seront perdues.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PremiumUISystem.premiumButton(
            text: 'Annuler',
            onPressed: () => Navigator.pop(context),
            style: PremiumButtonStyle.outline,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PremiumUISystem.premiumButton(
            text: 'Supprimer',
            onPressed: () {
              Navigator.pop(context);
              PremiumHapticService.instance.error();
              context.showPremiumError('Habitude supprimée');
              onDelete();
            },
            style: PremiumButtonStyle.primary,
          ),
        ),
      ],
    );
  }
}
