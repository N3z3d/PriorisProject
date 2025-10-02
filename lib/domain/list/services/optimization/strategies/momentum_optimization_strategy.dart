import 'dart:math' as math;
import '../../../value_objects/list_item.dart';
import '../interfaces/optimization_strategy.dart';

/// Stratégie d'optimisation par momentum
///
/// Trie les éléments par difficulté croissante (ELO) pour créer de l'élan
/// en commençant par les tâches les plus faciles.
///
/// SOLID: SRP - Responsabilité unique (tri par momentum/facilité)
class MomentumOptimizationStrategy implements OptimizationStrategy {
  @override
  String get name => 'Momentum';

  @override
  String get description =>
      'Commence par les tâches faciles pour créer de l\'élan motivationnel';

  @override
  List<ListItem> optimize(List<ListItem> items) {
    final incomplete = items.where((item) => !item.isCompleted).toList();
    final completed = items.where((item) => item.isCompleted).toList();

    // Commencer par les plus faciles pour créer de l'élan
    incomplete.sort((a, b) => a.eloScore.value.compareTo(b.eloScore.value));

    return [...incomplete, ...completed];
  }

  @override
  double calculateImprovement(
      List<ListItem> original, List<ListItem> optimized) {
    // L'amélioration du momentum est basée sur la facilité des premiers éléments
    final firstThird = optimized.take(optimized.length ~/ 3);
    final averageElo = firstThird.isEmpty
        ? 1200.0
        : firstThird.map((item) => item.eloScore.value).reduce((a, b) => a + b) /
            firstThird.length;

    // Plus les premiers éléments sont faciles, plus l'amélioration est grande
    return math.max(0.0, (1400 - averageElo) / 1400 * 0.3); // Max 30%
  }

  @override
  String generateReasoning(List<ListItem> original, List<ListItem> optimized) {
    return 'Éléments faciles en premier pour créer de l\'élan et maintenir la motivation.';
  }
}
