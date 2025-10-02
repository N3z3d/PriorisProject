import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/pages/lists/utils/list_type_helpers.dart';

/// Widget simplifié pour afficher une carte de liste
///
/// **Responsabilité** : Affichage compact d'une liste avec actions rapides
/// **SRP Compliant** : Se concentre uniquement sur l'affichage visuel
class SimpleListCard extends StatelessWidget {
  const SimpleListCard({
    super.key,
    required this.list,
    required this.onTap,
    required this.onAction,
  });

  final CustomList list;
  final VoidCallback onTap;
  final Function(String action) onAction;

  @override
  Widget build(BuildContext context) {
    final progress = _calculateProgress();
    final completedCount = list.getCompletedItems().length;
    final totalCount = list.items.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusTokens.modal),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadiusTokens.modal,
          border: Border.all(
            color: AppTheme.dividerColor.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        child: GestureDetector(
          onTap: onTap,
          child: ListTile(
            leading: _buildLeadingIcon(progress),
            title: _buildTitle(context),
            subtitle: _buildSubtitle(context, completedCount, totalCount),
            trailing: _buildActions(),
          ),
        ),
      ),
    );
  }

  /// Construit l'icône principale avec indicateur de progression
  Widget _buildLeadingIcon(double progress) {
    return CircleAvatar(
      backgroundColor: progress == 1.0
          ? Colors.green
          : ListTypeHelpers.getColorForType(list.type),
      child: Icon(
        ListTypeHelpers.getIconForType(list.type),
        color: Colors.white,
      ),
    );
  }

  /// Construit le titre de la carte
  Widget _buildTitle(BuildContext context) {
    return Text(
      list.name,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Construit le sous-titre avec description et statistiques
  Widget _buildSubtitle(BuildContext context, int completed, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (list.description?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              list.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            _ListTypeChip(type: list.type),
            const SizedBox(width: 8),
            _ProgressChip(completed: completed, total: total),
          ],
        ),
      ],
    );
  }

  /// Construit le menu d'actions
  Widget _buildActions() {
    return PopupMenuButton<String>(
      onSelected: onAction,
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'edit',
          child: Text('Modifier'),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text('Supprimer'),
        ),
      ],
    );
  }

  /// Calcule la progression de la liste
  double _calculateProgress() {
    if (list.items.isEmpty) return 0.0;
    final completedCount = list.items.where((item) => item.isCompleted).length;
    return completedCount / list.items.length;
  }
}

/// Chip pour afficher le type de liste
class _ListTypeChip extends StatelessWidget {
  const _ListTypeChip({required this.type});

  final ListType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ListTypeHelpers.getColorForType(type).withValues(alpha: 0.1),
        borderRadius: BorderRadiusTokens.card,
      ),
      child: Text(
        type.displayName,
        style: TextStyle(
          fontSize: 12,
          color: ListTypeHelpers.getColorForType(type),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Chip pour afficher la progression
class _ProgressChip extends StatelessWidget {
  const _ProgressChip({
    required this.completed,
    required this.total,
  });

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;
    final color = _getProgressColor(progress);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadiusTokens.card,
      ),
      child: Text(
        '$completed/$total',
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Détermine la couleur selon le niveau de progression
  Color _getProgressColor(double progress) {
    if (progress == 1.0) {
      return Colors.green;
    } else if (progress >= 0.5) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }
}
