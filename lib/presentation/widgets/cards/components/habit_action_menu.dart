import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/theme/premium_exports.dart';

/// Menu d'actions contextuel pour PremiumHabitCard
///
/// Responsabilité: Afficher le bottom sheet avec actions (modifier, historique, supprimer)
class HabitActionMenu extends StatelessWidget {
  final Habit habit;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onHistory;

  const HabitActionMenu({
    super.key,
    required this.habit,
    this.onEdit,
    this.onDelete,
    this.onHistory,
  });

  /// Affiche le menu d'actions en bottom sheet
  static void show(
    BuildContext context, {
    required Habit habit,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    VoidCallback? onHistory,
  }) {
    context.showPremiumBottomSheet(
      HabitActionMenu(
        habit: habit,
        onEdit: onEdit,
        onDelete: onDelete,
        onHistory: onHistory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Glassmorphism.glassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Actions pour ${habit.name}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildMenuItem(
            context,
            icon: Icons.edit,
            title: 'Modifier',
            onTap: () {
              Navigator.pop(context);
              onEdit?.call();
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.history,
            title: 'Historique',
            onTap: () {
              Navigator.pop(context);
              onHistory?.call();
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.delete,
            title: 'Supprimer',
            color: Colors.red,
            onTap: () {
              Navigator.pop(context);
              onDelete?.call();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return PremiumUISystem.premiumListItem(
      enableHaptics: true,
      enablePhysics: true,
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: color ?? Theme.of(context).iconTheme.color,
            size: 20,
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
