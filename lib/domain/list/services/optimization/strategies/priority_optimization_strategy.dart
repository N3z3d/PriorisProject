import '../../../value_objects/list_item.dart';
import '../interfaces/optimization_strategy.dart';

/// Stratégie d'optimisation par priorité
///
/// Trie les éléments par priorité décroissante pour maximiser l'impact.
/// Les éléments complétés sont placés en fin de liste.
///
/// SOLID: SRP - Responsabilité unique (tri par priorité)
class PriorityOptimizationStrategy implements OptimizationStrategy {
  @override
  String get name => 'Priority';

  @override
  String get description =>
      'Optimise par ordre de priorité décroissante pour maximiser l\'impact';

  @override
  List<ListItem> optimize(List<ListItem> items) {
    final incomplete = items.where((item) => !item.isCompleted).toList();
    final completed = items.where((item) => item.isCompleted).toList();

    incomplete.sort((a, b) => a.priority.compareTo(b.priority));

    return [...incomplete, ...completed];
  }

  @override
  double calculateImprovement(
      List<ListItem> original, List<ListItem> optimized) {
    // Calculer l'amélioration basée sur l'ordre des priorités
    double originalScore = 0;
    double optimizedScore = 0;

    for (int i = 0; i < original.length; i++) {
      final positionWeight =
          1.0 - (i / original.length); // Plus haut = plus important
      originalScore += original[i].priority.score * positionWeight;
      if (i < optimized.length) {
        optimizedScore += optimized[i].priority.score * positionWeight;
      }
    }

    return originalScore > 0
        ? (optimizedScore - originalScore) / originalScore
        : 0.0;
  }

  @override
  String generateReasoning(List<ListItem> original, List<ListItem> optimized) {
    return 'Éléments réorganisés par ordre de priorité décroissante pour maximiser l\'impact.';
  }
}
