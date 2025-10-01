import 'dart:collection';
import 'package:prioris/domain/services/performance/models/performance_models.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';

/// Service responsable uniquement de la collecte et du stockage des métriques
///
/// Respecte le Single Responsibility Principle en ne gérant que
/// la collecte, l'enregistrement et le stockage des métriques de performance
class MetricsCollectorService {
  final Map<String, MetricData> _metrics = {};
  final Map<String, Queue<DataPoint>> _history = {};
  final int _maxHistoryPoints = 10000; // Limite pour éviter les fuites mémoire

  /// Enregistre une nouvelle métrique
  void recordMetric(String name, double value, {Map<String, dynamic>? tags}) {
    final now = DateTime.now();

    try {
      // Mise à jour de la métrique courante
      final currentMetric = _metrics[name] ?? MetricData(name: name);
      currentMetric.recordValue(value, tags);
      _metrics[name] = currentMetric;

      // Historique pour analyse
      final history = _history[name] ?? Queue<DataPoint>();
      history.add(DataPoint(
        timestamp: now,
        value: value,
        tags: tags,
      ));

      // Maintenir la limite d'historique
      while (history.length > _maxHistoryPoints) {
        history.removeFirst();
      }
      _history[name] = history;

      LoggerService.instance.info(
        'Métrique enregistrée: $name = $value',
        context: 'MetricsCollectorService',
      );
    } catch (e) {
      LoggerService.instance.error(
        'Erreur lors de l\'enregistrement de la métrique $name',
        context: 'MetricsCollectorService',
        error: e,
      );
    }
  }

  /// Obtient la valeur actuelle d'une métrique
  MetricData? getCurrentMetric(String name) {
    return _metrics[name];
  }

  /// Obtient toutes les métriques actuelles
  Map<String, MetricData> getAllCurrentMetrics() {
    return Map.unmodifiable(_metrics);
  }

  /// Obtient l'historique d'une métrique
  List<DataPoint> getMetricHistory(String name, {Duration? period}) {
    final history = _history[name];
    if (history == null) return [];

    if (period == null) {
      return history.toList();
    }

    final cutoffTime = DateTime.now().subtract(period);
    return history.where((point) => point.timestamp.isAfter(cutoffTime)).toList();
  }

  /// Obtient l'historique de toutes les métriques
  Map<String, List<DataPoint>> getAllMetricsHistory({Duration? period}) {
    final result = <String, List<DataPoint>>{};

    for (final entry in _history.entries) {
      result[entry.key] = getMetricHistory(entry.key, period: period);
    }

    return result;
  }

  /// Obtient les dernières valeurs pour plusieurs métriques
  Map<String, double?> getLatestValues(List<String> metricNames) {
    final result = <String, double?>{};

    for (final name in metricNames) {
      final metric = _metrics[name];
      result[name] = metric?.currentValue;
    }

    return result;
  }

  /// Efface l'historique d'une métrique
  void clearMetricHistory(String name) {
    _history.remove(name);
    _metrics.remove(name);

    LoggerService.instance.info(
      'Historique de la métrique $name effacé',
      context: 'MetricsCollectorService',
    );
  }

  /// Efface toutes les métriques
  void clearAllMetrics() {
    final metricsCount = _metrics.length;
    final historyCount = _history.length;

    _metrics.clear();
    _history.clear();

    LoggerService.instance.info(
      'Toutes les métriques effacées: $metricsCount métriques, $historyCount historiques',
      context: 'MetricsCollectorService',
    );
  }

  /// Calcule des statistiques agrégées pour une métrique
  MetricStatistics? calculateStatistics(String name, {Duration? period}) {
    final history = getMetricHistory(name, period: period);
    if (history.isEmpty) return null;

    final values = history.map((point) => point.value).toList();

    return MetricStatistics.fromValues(name, values);
  }

  /// Obtient le nombre de points de données pour une métrique
  int getMetricDataPointCount(String name) {
    return _history[name]?.length ?? 0;
  }

  /// Obtient les métriques avec le plus de données
  List<String> getTopMetricsByDataPoints({int limit = 10}) {
    final metricCounts = <String, int>{};

    for (final entry in _history.entries) {
      metricCounts[entry.key] = entry.value.length;
    }

    final sortedEntries = metricCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries
        .take(limit)
        .map((entry) => entry.key)
        .toList();
  }

  /// Nettoie l'historique ancien
  void cleanupOldHistory({Duration? retentionPeriod}) {
    final retention = retentionPeriod ?? const Duration(days: 7);
    final cutoffTime = DateTime.now().subtract(retention);
    int totalRemoved = 0;

    for (final entry in _history.entries) {
      final history = entry.value;
      final originalSize = history.length;

      history.removeWhere((point) => point.timestamp.isBefore(cutoffTime));

      final removed = originalSize - history.length;
      totalRemoved += removed;
    }

    if (totalRemoved > 0) {
      LoggerService.instance.info(
        'Nettoyage historique: $totalRemoved points supprimés (rétention: ${retention.inDays} jours)',
        context: 'MetricsCollectorService',
      );
    }
  }

  /// Obtient des informations sur l'utilisation mémoire du service
  Map<String, dynamic> getMemoryUsageInfo() {
    int totalDataPoints = 0;
    final metricCounts = <String, int>{};

    for (final entry in _history.entries) {
      final count = entry.value.length;
      totalDataPoints += count;
      metricCounts[entry.key] = count;
    }

    return {
      'total_metrics': _metrics.length,
      'total_data_points': totalDataPoints,
      'average_points_per_metric': _metrics.isNotEmpty
          ? (totalDataPoints / _metrics.length).round()
          : 0,
      'max_history_limit': _maxHistoryPoints,
      'metric_breakdown': metricCounts,
    };
  }

  /// Vérifie si une métrique existe
  bool hasMetric(String name) {
    return _metrics.containsKey(name);
  }

  /// Obtient la liste de toutes les métriques enregistrées
  List<String> getAllMetricNames() {
    return _metrics.keys.toList()..sort();
  }

  /// Crée un snapshot des métriques actuelles
  Map<String, dynamic> createSnapshot() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'metrics': _metrics.map((name, metric) => MapEntry(name, {
        'name': metric.name,
        'current_value': metric.currentValue,
        'count': metric.count,
        'sum': metric.sum,
        'min': metric.min,
        'max': metric.max,
        'average': metric.average,
      })),
      'data_point_counts': _history.map((name, queue) => MapEntry(name, queue.length)),
    };
  }
}