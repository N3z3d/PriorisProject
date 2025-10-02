import 'dart:math' as math;
import '../../../value_objects/list_item.dart';
import '../interfaces/optimization_strategy.dart';

/// Stratégie d'optimisation temporelle
///
/// Trie les éléments par temps estimé croissant pour maximiser
/// le nombre de complétions rapides.
///
/// SOLID: SRP - Responsabilité unique (tri par temps estimé)
class TimeOptimalOptimizationStrategy implements OptimizationStrategy {
  @override
  String get name => 'TimeOptimal';

  @override
  String get description =>
      'Optimise par temps estimé pour maximiser les complétions rapides';

  @override
  List<ListItem> optimize(List<ListItem> items) {
    final incomplete = items.where((item) => !item.isCompleted).toList();
    final completed = items.where((item) => item.isCompleted).toList();

    // Estimer le temps basé sur l'ELO (plus haut = plus long)
    incomplete.sort((a, b) {
      final timeA = _estimateTime(a);
      final timeB = _estimateTime(b);
      return timeA.compareTo(timeB); // Plus court d'abord
    });

    return [...incomplete, ...completed];
  }

  Duration _estimateTime(ListItem item) {
    // Estimation basique basée sur l'ELO
    final baseMinutes = 10 + ((item.eloScore.value - 1000) / 100 * 5).round();
    return Duration(minutes: math.max(5, baseMinutes));
  }

  @override
  double calculateImprovement(
      List<ListItem> original, List<ListItem> optimized) {
    // Amélioration générique estimée à 15%
    return 0.15;
  }

  @override
  String generateReasoning(List<ListItem> original, List<ListItem> optimized) {
    return 'Optimisation temporelle : éléments courts d\'abord pour maximiser le nombre de complétions.';
  }
}
