import '../../../value_objects/list_item.dart';
import '../interfaces/optimization_strategy.dart';

/// Stratégie d'optimisation par score ELO
///
/// Trie les éléments par score ELO décroissant pour traiter d'abord
/// les éléments les plus importants.
///
/// SOLID: SRP - Responsabilité unique (tri par ELO)
class EloOptimizationStrategy implements OptimizationStrategy {
  @override
  String get name => 'ELO';

  @override
  String get description =>
      'Optimise par score ELO décroissant pour traiter les plus importants en premier';

  @override
  List<ListItem> optimize(List<ListItem> items) {
    final incomplete = items.where((item) => !item.isCompleted).toList();
    final completed = items.where((item) => item.isCompleted).toList();

    incomplete.sort((a, b) => b.eloScore.value.compareTo(a.eloScore.value));

    return [...incomplete, ...completed];
  }

  @override
  double calculateImprovement(
      List<ListItem> original, List<ListItem> optimized) {
    // Amélioration générique estimée à 15%
    return 0.15;
  }

  @override
  String generateReasoning(List<ListItem> original, List<ListItem> optimized) {
    return 'Éléments triés par score ELO pour traiter d\'abord les plus importants.';
  }
}
