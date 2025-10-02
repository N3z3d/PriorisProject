import 'dart:math' as math;
import '../../../core/services/domain_service.dart';
import '../../aggregates/custom_list_aggregate.dart';
import '../../value_objects/list_item.dart';
import '../interfaces/optimization_strategy.dart';
import '../strategies/priority_optimization_strategy.dart';
import '../strategies/category_optimization_strategy.dart';
import '../strategies/momentum_optimization_strategy.dart';
import '../strategies/elo_optimization_strategy.dart';
import '../strategies/smart_optimization_strategy.dart';

/// Recommandeur de stratégie d'optimisation
///
/// Analyse les caractéristiques d'une liste pour suggérer la meilleure
/// stratégie d'optimisation adaptée au contexte.
///
/// SOLID:
/// - SRP: Responsabilité unique de recommandation de stratégie
/// - OCP: Extensible via ajout de nouvelles stratégies
/// - DIP: Dépend de l'abstraction OptimizationStrategy
class StrategyRecommender extends LoggableDomainService {
  @override
  String get serviceName => 'StrategyRecommender';

  /// Suggère la meilleure stratégie d'optimisation pour une liste
  OptimizationStrategy suggestStrategy(CustomListAggregate list) {
    return executeOperation(() {
      log('Analyse de la liste ${list.name} pour suggérer une stratégie');

      final items = list.items;
      if (items.isEmpty) {
        return PriorityOptimizationStrategy();
      }

      // Analyser les caractéristiques de la liste
      final hasCategories = items.any((item) => item.category != null);
      final eloVariance = _calculateEloVariance(items);
      final progressRate = list.progress.percentage;
      final itemCount = items.length;

      log('Caractéristiques - Catégories: $hasCategories, Variance ELO: ${eloVariance.toStringAsFixed(1)}, Progression: ${(progressRate * 100).toStringAsFixed(1)}%');

      // Logique de décision pour la stratégie
      if (itemCount <= 5) {
        return PriorityOptimizationStrategy(); // Simple pour petites listes
      }

      if (hasCategories && itemCount >= 10) {
        return CategoryOptimizationStrategy(); // Grouper par catégorie
      }

      if (eloVariance > 100 && progressRate < 0.3) {
        return MomentumOptimizationStrategy(); // Commencer par le plus facile
      }

      if (progressRate > 0.7) {
        return EloOptimizationStrategy(); // Finir par le plus important
      }

      return SmartOptimizationStrategy(); // Algorithme intelligent par défaut
    });
  }

  /// Calcule la variance ELO des éléments
  double _calculateEloVariance(List<ListItem> items) {
    if (items.length < 2) return 0.0;

    final eloValues = items.map((item) => item.eloScore.value).toList();
    final average = eloValues.reduce((a, b) => a + b) / eloValues.length;
    final variance = eloValues
            .map((elo) => math.pow(elo - average, 2))
            .reduce((a, b) => a + b) /
        eloValues.length;

    return variance;
  }
}
