import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/presentation/pages/lists/widgets/components/export.dart';
import 'package:prioris/presentation/widgets/common/displays/premium_card.dart';

/// Widget pour afficher une carte de liste personnalisée
///
/// Affiche les informations principales d'une liste avec des actions rapides
/// et une progression visuelle.
class ListCard extends StatelessWidget {
  final CustomList list;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onArchive;

  const ListCard({
    super.key,
    required this.list,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = list.getCompletedItems().length;
    final totalCount = list.items.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return PremiumCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(),
          const SizedBox(height: 12),
          ListCardStats(
            list: list,
            completedCount: completedCount,
            totalCount: totalCount,
            progress: progress,
          ),
          if (totalCount > 0) ...[
            const SizedBox(height: 8),
            ListCardProgress(
              listType: list.type,
              progress: progress,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        Expanded(child: ListCardHeader(list: list)),
        ListCardActionMenu(
          onEdit: onEdit,
          onDelete: onDelete,
          onArchive: onArchive,
        ),
      ],
    );
  }
} 
