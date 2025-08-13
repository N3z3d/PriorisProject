import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Widget pour l'état vide d'une liste
/// 
/// Affiche un message approprié quand la liste est vide ou qu'aucun
/// résultat ne correspond à la recherche.
class ListEmptyState extends StatelessWidget {
  final String searchQuery;

  const ListEmptyState({
    super.key,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Fond professionnel au lieu du gradient
              color: AppTheme.surfaceColor,
              border: Border.all(
                color: AppTheme.dividerColor,
                width: 1,
              ),
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppTheme.primaryColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucun élément trouvé',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isNotEmpty 
                ? 'Essayez un autre terme de recherche'
                : 'Ajoutez votre premier élément pour commencer',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 
