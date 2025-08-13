import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Widget pour sélectionner le type de liste
/// 
/// Affiche une grille de types de listes avec icônes et descriptions
/// pour permettre à l'utilisateur de choisir le type approprié.
class ListTypeSelector extends StatelessWidget {
  final ListType? selectedType;
  final ValueChanged<ListType>? onTypeSelected;
  final bool showCustomType;

  const ListTypeSelector({
    super.key,
    this.selectedType,
    this.onTypeSelected,
    this.showCustomType = true,
  });

  @override
  Widget build(BuildContext context) {
    final types = ListType.values.where((type) => 
      showCustomType || type != ListType.CUSTOM
    ).toList();

    return SizedBox(
      height: 400, // Hauteur fixe pour éviter l'overflow
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Type de liste',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: types.length,
              itemBuilder: (context, index) {
                final type = types[index];
                final isSelected = selectedType == type;
                
                return _buildTypeCard(context, type, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Construit une carte de type de liste
  Widget _buildTypeCard(BuildContext context, ListType type, bool isSelected) {
    return GestureDetector(
      onTap: () => onTypeSelected?.call(type),
      child: AnimatedContainer(
        duration: AppTheme.fastAnimation,
        curve: AppTheme.defaultCurve,
        decoration: BoxDecoration(
          color: isSelected 
            ? _getTypeColor(type).withValues(alpha: 0.1)
            : Colors.white,
          border: Border.all(
            color: isSelected 
              ? _getTypeColor(type)
              : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [
            BoxShadow(
              color: _getTypeColor(type).withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getTypeColor(type).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getTypeIcon(type),
                  color: _getTypeColor(type),
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              
              // Nom du type
              Text(
                type.displayName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? _getTypeColor(type) : null,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Description
              if (type.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  type.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Retourne l'icône appropriée pour le type
  IconData _getTypeIcon(ListType type) {
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

  /// Retourne la couleur appropriée pour le type
  Color _getTypeColor(ListType type) {
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
        return Colors.grey;
    }
  }
} 
