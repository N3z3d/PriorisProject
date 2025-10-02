import 'dart:math' as math;
import '../../../value_objects/list_item.dart';
import '../interfaces/optimization_strategy.dart';

/// Stratégie d'optimisation intelligente
///
/// Combine priorité, ELO et âge pour un score composite intelligent.
/// Pondération: 50% priorité, 30% ELO, 20% âge.
///
/// SOLID: SRP - Responsabilité unique (tri intelligent composite)
class SmartOptimizationStrategy implements OptimizationStrategy {
  @override
  String get name => 'Smart';

  @override
  String get description =>
      'Optimisation intelligente combinant priorité, importance et âge';

  @override
  List<ListItem> optimize(List<ListItem> items) {
    final incomplete = items.where((item) => !item.isCompleted).toList();
    final completed = items.where((item) => item.isCompleted).toList();

    // Algorithme intelligent combinant priorité, ELO et âge
    incomplete.sort((a, b) {
      // Score composite
      final scoreA = _calculateSmartScore(a);
      final scoreB = _calculateSmartScore(b);
      return scoreB.compareTo(scoreA);
    });

    return [...incomplete, ...completed];
  }

  double _calculateSmartScore(ListItem item) {
    // Normaliser les valeurs entre 0 et 1
    final priorityScore = item.priority.score / 2.0; // Priority max ~2.0
    final eloScore = (item.eloScore.value - 800) / 1600; // ELO 800-2400 -> 0-1
    final ageScore = math.min(item.age.inDays / 30, 1.0); // Age max 30 jours

    // Pondération: 50% priorité, 30% ELO, 20% âge
    return (priorityScore * 0.5) + (eloScore * 0.3) + (ageScore * 0.2);
  }

  @override
  double calculateImprovement(
      List<ListItem> original, List<ListItem> optimized) {
    // Amélioration générique estimée à 15%
    return 0.15;
  }

  @override
  String generateReasoning(List<ListItem> original, List<ListItem> optimized) {
    return 'Optimisation intelligente combinant priorité, importance et âge des éléments.';
  }
}
