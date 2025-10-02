import '../../../value_objects/list_item.dart';
import '../interfaces/optimization_strategy.dart';

/// Stratégie d'optimisation par catégorie
///
/// Groupe les éléments par catégorie pour minimiser les changements de contexte.
/// Au sein de chaque catégorie, trie par priorité.
///
/// SOLID: SRP - Responsabilité unique (regroupement par catégorie)
class CategoryOptimizationStrategy implements OptimizationStrategy {
  @override
  String get name => 'Category';

  @override
  String get description =>
      'Regroupe par catégorie pour minimiser les changements de contexte';

  @override
  List<ListItem> optimize(List<ListItem> items) {
    final incomplete = items.where((item) => !item.isCompleted).toList();
    final completed = items.where((item) => item.isCompleted).toList();

    // Grouper par catégorie, puis par priorité
    incomplete.sort((a, b) {
      final categoryCompare = (a.category ?? '').compareTo(b.category ?? '');
      if (categoryCompare != 0) return categoryCompare;
      return a.priority.compareTo(b.priority);
    });

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
    return 'Regroupement par catégorie pour minimiser les changements de contexte.';
  }
}
