import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/widgets/common/displays/premium_card.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

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
          // En-tête avec type et actions
          Row(
            children: [
              // Icône et type
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      _getIconForType(list.type),
                      color: _getColorForType(list.type),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            list.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (list.description?.isNotEmpty == true)
                            Text(
                              list.description!,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Actions
              if (onEdit != null || onDelete != null || onArchive != null)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit?.call();
                        break;
                      case 'archive':
                        onArchive?.call();
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                    if (onArchive != null)
                      const PopupMenuItem(
                        value: 'archive',
                        child: Row(
                          children: [
                            Icon(Icons.archive, size: 16),
                            SizedBox(width: 8),
                            Text('Archiver'),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Supprimer', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Statistiques
          Row(
            children: [
              // Nombre d'éléments
              Text(
                '$totalCount ${totalCount <= 1 ? 'élément' : 'éléments'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 16),
              
              // Pourcentage de progression
              if (totalCount > 0)
                Text(
                  '${(progress * 100).round()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _getColorForType(list.type),
                  ),
                ),
            ],
          ),
          
          // Barre de progression
          if (totalCount > 0) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getColorForType(list.type),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getIconForType(ListType type) {
    switch (type) {
      case ListType.TRAVEL:
        return Icons.flight;
      case ListType.SHOPPING:
        return Icons.shopping_cart;
      case ListType.MOVIES:
        return Icons.movie;
      case ListType.BOOKS:
        return Icons.book;
      case ListType.RESTAURANTS:
        return Icons.restaurant;
      case ListType.PROJECTS:
        return Icons.work;
      case ListType.CUSTOM:
        return Icons.list;
    }
  }

  Color _getColorForType(ListType type) {
    switch (type) {
      case ListType.TRAVEL:
        return Colors.blue;
      case ListType.SHOPPING:
        return Colors.green;
      case ListType.MOVIES:
        return Colors.purple;
      case ListType.BOOKS:
        return Colors.orange;
      case ListType.RESTAURANTS:
        return Colors.red;
      case ListType.PROJECTS:
        return Colors.indigo;
      case ListType.CUSTOM:
        return AppTheme.primaryColor;
    }
  }
} 
