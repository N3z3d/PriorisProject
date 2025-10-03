import 'package:prioris/infrastructure/services/logger_service.dart';

/// Mixin fournissant des capacités de monitoring de performance
///
/// **Single Responsibility Principle (SRP)**: Gère uniquement le monitoring
/// **Open/Closed Principle (OCP)**: Réutilisable par différents managers
/// **Dependency Inversion Principle (DIP)**: Dépend de LoggerService abstraction
mixin PerformanceMonitoringMixin {
  final Map<String, DateTime> _operationStartTimes = {};
  final Map<String, int> _operationCounts = {};

  /// Nom du contexte pour le logging (à override dans la classe qui utilise le mixin)
  String get monitoringContext;

  /// **Template Method Pattern** - Exécute une opération avec monitoring
  Future<T> executeMonitoredOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    _startOperationMonitoring(operationName);

    try {
      final result = await operation();
      _endOperationMonitoring(operationName, success: true);
      return result;
    } catch (e) {
      _endOperationMonitoring(operationName, success: false);
      LoggerService.instance.error(
        'Erreur lors de l\'opération $operationName',
        context: monitoringContext,
        error: e,
      );
      rethrow;
    }
  }

  /// Démarre le monitoring d'une opération
  void _startOperationMonitoring(String operationName) {
    _operationStartTimes[operationName] = DateTime.now();
    _operationCounts[operationName] = (_operationCounts[operationName] ?? 0) + 1;
  }

  /// Termine le monitoring d'une opération
  void _endOperationMonitoring(String operationName, {required bool success}) {
    final startTime = _operationStartTimes.remove(operationName);
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      LoggerService.instance.debug(
        'Opération $operationName ${success ? "réussie" : "échouée"} en ${duration.inMilliseconds}ms',
        context: monitoringContext,
      );
    }
  }

  /// Retourne les statistiques de performance
  Map<String, dynamic> getPerformanceStats() {
    return {
      'operationCounts': Map.from(_operationCounts),
      'averageOperationsPerMinute': _calculateAverageOperationsPerMinute(),
      'totalOperations': _operationCounts.values.fold(0, (sum, count) => sum + count),
    };
  }

  /// Calcule la moyenne d'opérations par minute
  double _calculateAverageOperationsPerMinute() {
    if (_operationCounts.isEmpty) return 0.0;

    final totalOps = _operationCounts.values.fold(0, (sum, count) => sum + count);
    // Estimation basée sur les opérations dans la dernière minute
    return totalOps / 1.0; // Simplification pour l'exemple
  }

  /// Réinitialise les compteurs de monitoring
  void resetPerformanceCounters() {
    _operationStartTimes.clear();
    _operationCounts.clear();
  }
}
