import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/presentation/widgets/common/displays/premium_card.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Widget pour afficher la progression d'une liste
/// 
/// Affiche les statistiques détaillées de progression avec des graphiques
/// et des métriques visuelles.
class ListProgressWidget extends StatelessWidget {
  final CustomList list;

  const ListProgressWidget({
    super.key,
    required this.list,
  });

  @override
  Widget build(BuildContext context) {
    final completedItems = list.getCompletedItems();
    final totalItems = list.items.length;
    final progress = totalItems > 0 ? completedItems.length / totalItems : 0.0;

    // Statistiques par score ELO
    final eloStats = _calculateEloStats();
    
    // Statistiques par catégorie
    final categoryStats = _calculateCategoryStats();

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Text(
            'Progression de la liste',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Progression générale
          _buildGeneralProgress(context, progress, completedItems.length, totalItems),
          const SizedBox(height: 20),
          
          // Statistiques par score ELO
          if (eloStats.isNotEmpty) ...[
            _buildEloStats(context, eloStats),
            const SizedBox(height: 16),
          ],
          
          // Statistiques par catégorie
          if (categoryStats.isNotEmpty) ...[
            _buildCategoryStats(context, categoryStats),
          ],
        ],
      ),
    );
  }

  /// Construit la section de progression générale
  Widget _buildGeneralProgress(
    BuildContext context, 
    double progress, 
    int completed, 
    int total,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progression générale',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          minHeight: 8,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$completed éléments terminés',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.green[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${total - completed} restants',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Construit la section des statistiques par score ELO
  Widget _buildEloStats(BuildContext context, Map<String, int> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Par priorité (ELO)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...stats.entries.map((entry) => _buildEloRow(context, entry.key, entry.value)),
      ],
    );
  }

  /// Construit une ligne de statistique de score ELO
  Widget _buildEloRow(BuildContext context, String eloLevel, int count) {
    final total = list.items.length;
    final percentage = total > 0 ? count / total : 0.0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getEloLevelColor(eloLevel),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              eloLevel,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Text(
            '$count',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(percentage * 100).toInt()}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Construit la section des statistiques par catégorie
  Widget _buildCategoryStats(BuildContext context, Map<String, int> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Par catégorie',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...stats.entries.map((entry) => _buildCategoryRow(context, entry.key, entry.value)),
      ],
    );
  }

  /// Construit une ligne de statistique de catégorie
  Widget _buildCategoryRow(BuildContext context, String category, int count) {
    final total = list.items.length;
    final percentage = total > 0 ? count / total : 0.0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.category,
            size: 12,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              category,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Text(
            '$count',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(percentage * 100).toInt()}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Calcule les statistiques par score ELO
  Map<String, int> _calculateEloStats() {
    final stats = <String, int>{};
    
    for (final item in list.items) {
      final eloLevel = _getEloLevel(item.eloScore);
      stats[eloLevel] = (stats[eloLevel] ?? 0) + 1;
    }
    
    return stats;
  }

  /// Calcule les statistiques par catégorie
  Map<String, int> _calculateCategoryStats() {
    final stats = <String, int>{};
    
    for (final item in list.items) {
      if (item.category != null && item.category!.isNotEmpty) {
        stats[item.category!] = (stats[item.category!] ?? 0) + 1;
      }
    }
    
    return stats;
  }

  /// Retourne le niveau ELO sous forme de string
  String _getEloLevel(double eloScore) {
    if (eloScore >= 1500) {
      return 'URGENT';
    } else if (eloScore >= 1400) {
      return 'ÉLEVÉ';
    } else if (eloScore >= 1300) {
      return 'MOYEN';
    } else {
      return 'BAS';
    }
  }

  /// Retourne la couleur appropriée pour le niveau ELO
  Color _getEloLevelColor(String eloLevel) {
    switch (eloLevel) {
      case 'URGENT':
        return Colors.red;
      case 'ÉLEVÉ':
        return Colors.orange;
      case 'MOYEN':
        return Colors.blue;
      case 'BAS':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
} 
