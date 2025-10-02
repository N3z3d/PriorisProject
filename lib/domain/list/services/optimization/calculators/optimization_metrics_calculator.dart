import '../../../value_objects/list_item.dart';
import '../../core/services/domain_service.dart';

/// Service calculant les métriques et statistiques d'optimisation
///
/// SOLID COMPLIANCE:
/// - SRP: Responsabilité unique (calcul de métriques)
/// - OCP: Ouvert à l'extension (nouvelles métriques)
/// - DIP: Pas de dépendances concrètes
class OptimizationMetricsCalculator extends LoggableDomainService {
  @override
  String get serviceName => 'OptimizationMetricsCalculator';

  /// Calcule les statistiques pour une liste d'éléments
  Map<String, dynamic> calculateStatistics(
    List<ListItem> original,
    List<ListItem> optimized,
  ) {
    return executeOperation(() {
      log('Calcul des statistiques pour ${original.length} éléments');

      return {
        'totalItems': original.length,
        'incompleteItems': original.where((item) => !item.isCompleted).length,
        'averageElo': original.isEmpty
            ? 0
            : original
                    .map((item) => item.eloScore.value)
                    .reduce((a, b) => a + b) /
                original.length,
        'categoriesCount': original
            .map((item) => item.category)
            .where((cat) => cat != null)
            .toSet()
            .length,
      };
    });
  }
}
