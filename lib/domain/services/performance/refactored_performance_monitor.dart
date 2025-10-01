import 'dart:async';
import 'package:prioris/domain/services/performance/core/metrics_collector_service.dart';
import 'package:prioris/domain/services/performance/services/alerting_service.dart';
import 'package:prioris/domain/services/performance/services/trend_analysis_service.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';

/// Moniteur de performance refactorisé respectant les principes SOLID
///
/// SRP: Délègue chaque responsabilité à un service spécialisé
/// OCP: Extensible via l'injection de nouveaux services
/// LSP: Compatible avec l'interface de monitoring
/// ISP: Utilise des interfaces spécialisées pour chaque service
/// DIP: Dépend d'abstractions, pas d'implémentations concrètes
class RefactoredPerformanceMonitor {
  static RefactoredPerformanceMonitor? _instance;
  static RefactoredPerformanceMonitor get instance =>
      _instance ??= RefactoredPerformanceMonitor._internal();

  final MetricsCollectorService _metricsCollector;
  final AlertingService _alertingService;
  final TrendAnalysisService _trendAnalysisService;
  final ILogger _logger;

  Timer? _metricsTimer;
  DateTime _monitoringStartTime = DateTime.now();

  RefactoredPerformanceMonitor._internal()
      : _metricsCollector = MetricsCollectorService(),
        _alertingService = AlertingService(),
        _trendAnalysisService = TrendAnalysisService(),
        _logger = throw UnimplementedError('Use RefactoredPerformanceMonitor.withServices for dependency injection') {
    // Cette implémentation est temporaire - utiliser withServices
    _startMetricsCollection();
    _logger.info(
      'RefactoredPerformanceMonitor initialisé avec services SOLID',
      context: 'RefactoredPerformanceMonitor',
    );
  }

  /// Factory constructor avec injection de dépendances
  RefactoredPerformanceMonitor.withServices({
    required MetricsCollectorService metricsCollector,
    required AlertingService alertingService,
    required TrendAnalysisService trendAnalysisService,
    required ILogger logger,
  })  : _metricsCollector = metricsCollector,
        _alertingService = alertingService,
        _trendAnalysisService = trendAnalysisService,
        _logger = logger {
    _startMetricsCollection();
  }

  /// Démarre le tracking d'une opération
  PerformanceTracker startOperation(String operationName) {
    return PerformanceTracker._(operationName, this);
  }

  /// Enregistre une métrique et évalue les alertes
  void recordMetric(String name, double value, {Map<String, dynamic>? tags}) {
    try {
      // Enregistrer la métrique
      _metricsCollector.recordMetric(name, value, tags: tags);

      // Évaluer les alertes
      _alertingService.evaluateMetric(name, value, context: tags);

      _logger.info(
        'Métrique enregistrée et évaluée: $name = $value',
        context: 'RefactoredPerformanceMonitor',
      );
    } catch (e) {
      _logger.error(
        'Erreur lors de l\'enregistrement de la métrique $name',
        context: 'RefactoredPerformanceMonitor',
        error: e,
      );
    }
  }

  /// Complète le tracking d'une opération
  void completeOperation(PerformanceTracker tracker, {Map<String, dynamic>? tags}) {
    if (tracker.isCompleted) return;

    tracker.complete(tags: tags);

    // Enregistrer les métriques de l'opération
    recordMetric(
      '${tracker.operationName}_duration_ms',
      tracker.elapsedMs.toDouble(),
      tags: tags,
    );

    _logger.info(
      'Opération terminée: ${tracker.operationName} en ${tracker.elapsedMs}ms',
      context: 'RefactoredPerformanceMonitor',
    );
  }

  /// Génère un rapport de performance complet
  PerformanceReport generateReport({Duration? period}) {
    try {
      final reportPeriod = period ?? const Duration(hours: 1);
      final generatedAt = DateTime.now();

      // Obtenir les métriques de la période
      final metricsHistory = _metricsCollector.getAllMetricsHistory(period: reportPeriod);
      final reportMetrics = <String, MetricStatistics>{};

      for (final entry in metricsHistory.entries) {
        if (entry.value.isNotEmpty) {
          final statistics = _metricsCollector.calculateStatistics(entry.key, period: reportPeriod);
          if (statistics != null) {
            reportMetrics[entry.key] = statistics;
          }
        }
      }

      // Obtenir les alertes récentes
      final alerts = _alertingService.getRecentAlerts(period: reportPeriod);

      // Générer les recommandations
      final recommendations = _generateRecommendations(reportMetrics, alerts);

      // Informations système
      final systemInfo = _getSystemInfo();

      _logger.info(
        'Rapport généré: ${reportMetrics.length} métriques, ${alerts.length} alertes',
        context: 'RefactoredPerformanceMonitor',
      );

      return PerformanceReport(
        period: reportPeriod,
        generatedAt: generatedAt,
        metrics: reportMetrics,
        systemInfo: systemInfo,
        alerts: alerts,
        recommendations: recommendations,
      );
    } catch (e) {
      _logger.error(
        'Erreur lors de la génération du rapport',
        context: 'RefactoredPerformanceMonitor',
        error: e,
      );
      rethrow;
    }
  }

  /// Analyse les tendances de toutes les métriques
  Map<String, TrendAnalysis> analyzeTrends({Duration? period}) {
    try {
      final analysisPeriod = period ?? const Duration(hours: 24);
      final metricsHistory = _metricsCollector.getAllMetricsHistory(period: analysisPeriod);

      // Filtrer les métriques avec suffisamment de données
      final validMetrics = <String, List<DataPoint>>{};
      for (final entry in metricsHistory.entries) {
        if (entry.value.length >= 10) {
          validMetrics[entry.key] = entry.value;
        }
      }

      final trends = _trendAnalysisService.analyzeMultipleTrends(validMetrics);

      _logger.info(
        'Analyse de tendances terminée: ${trends.length} métriques analysées',
        context: 'RefactoredPerformanceMonitor',
      );

      return trends;
    } catch (e) {
      _logger.error(
        'Erreur lors de l\'analyse des tendances',
        context: 'RefactoredPerformanceMonitor',
        error: e,
      );
      return {};
    }
  }

  /// Configure un seuil d'alerte
  void setAlertThreshold(String metricName, double warning, double critical, {bool inverse = false}) {
    final threshold = AlertThreshold(
      warning: warning,
      critical: critical,
      inverse: inverse,
    );

    _alertingService.setThreshold(metricName, threshold);

    _logger.info(
      'Seuil configuré pour $metricName: warning=$warning, critical=$critical',
      context: 'RefactoredPerformanceMonitor',
    );
  }

  /// Configure un gestionnaire d'alerte
  void setAlertHandler(String metricName, Function(PerformanceAlert) handler) {
    _alertingService.setAlertHandler(metricName, handler);

    _logger.info(
      'Gestionnaire d\'alerte configuré pour $metricName',
      context: 'RefactoredPerformanceMonitor',
    );
  }

  /// Obtient les métriques actuelles
  Map<String, MetricData> getCurrentMetrics() {
    return _metricsCollector.getAllCurrentMetrics();
  }

  /// Obtient les alertes récentes
  List<PerformanceAlert> getRecentAlerts({Duration? period}) {
    return _alertingService.getRecentAlerts(period: period);
  }

  /// Obtient l'historique d'une métrique
  List<DataPoint> getMetricHistory(String metricName, {Duration? period}) {
    return _metricsCollector.getMetricHistory(metricName, period: period);
  }

  /// Prédit une valeur future pour une métrique
  double? predictFutureValue(String metricName, Duration futureOffset) {
    final history = _metricsCollector.getMetricHistory(metricName);
    if (history.isEmpty) return null;

    return _trendAnalysisService.predictFutureValue(history, futureOffset);
  }

  /// Détecte les anomalies dans une métrique
  List<AnomalyDetection> detectAnomalies(String metricName, {double sensitivity = 2.0}) {
    final history = _metricsCollector.getMetricHistory(metricName);
    if (history.isEmpty) return [];

    return _trendAnalysisService.detectAnomalies(metricName, history, sensitivityFactor: sensitivity);
  }

  /// Obtient des statistiques de performance du système de monitoring
  Map<String, dynamic> getMonitoringStats() {
    return {
      'uptime_hours': DateTime.now().difference(_monitoringStartTime).inHours,
      'metrics_collector': _metricsCollector.getMemoryUsageInfo(),
      'alerts_summary': _alertingService.generateAlertsSummary(),
      'monitoring_start_time': _monitoringStartTime.toIso8601String(),
    };
  }

  /// Nettoie les données anciennes
  void cleanup({Duration? retentionPeriod}) {
    final retention = retentionPeriod ?? const Duration(days: 7);

    _metricsCollector.cleanupOldHistory(retentionPeriod: retention);

    _logger.info(
      'Nettoyage terminé (rétention: ${retention.inDays} jours)',
      context: 'RefactoredPerformanceMonitor',
    );
  }

  /// Démarre la collecte périodique de métriques
  void _startMetricsCollection() {
    _metricsTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _collectSystemMetrics();
    });

    _logger.info(
      'Collecte périodique de métriques démarrée',
      context: 'RefactoredPerformanceMonitor',
    );
  }

  /// Collecte les métriques système
  void _collectSystemMetrics() {
    try {
      // Métriques de base du monitoring
      final uptimeHours = DateTime.now().difference(_monitoringStartTime).inHours.toDouble();
      recordMetric('monitoring_uptime_hours', uptimeHours);

      final metricsCount = _metricsCollector.getAllCurrentMetrics().length.toDouble();
      recordMetric('active_metrics_count', metricsCount);

      final alertsCount = _alertingService.getRecentAlerts(period: const Duration(hours: 1)).length.toDouble();
      recordMetric('recent_alerts_count', alertsCount);
    } catch (e) {
      _logger.error(
        'Erreur lors de la collecte des métriques système',
        context: 'RefactoredPerformanceMonitor',
        error: e,
      );
    }
  }

  /// Génère des recommandations basées sur les métriques et alertes
  List<String> _generateRecommendations(
    Map<String, MetricStatistics> metrics,
    List<PerformanceAlert> alerts,
  ) {
    final recommendations = <String>[];

    // Recommandations basées sur les alertes
    final criticalAlerts = alerts.where((a) => a.level == AlertLevel.critical).length;
    if (criticalAlerts > 0) {
      recommendations.add('$criticalAlerts alertes critiques détectées - intervention immédiate requise');
    }

    final warningAlerts = alerts.where((a) => a.level == AlertLevel.warning).length;
    if (warningAlerts > 5) {
      recommendations.add('Trop d\'alertes d\'avertissement ($warningAlerts) - revoir les seuils ou optimiser');
    }

    // Recommandations basées sur les métriques
    for (final entry in metrics.entries) {
      final metricName = entry.key;
      final stats = entry.value;

      if (stats.standardDeviation > stats.average * 0.5) {
        recommendations.add('Métrique $metricName très volatile - analyser les causes');
      }

      if (metricName.contains('latency') && stats.percentile95 > 2000) {
        recommendations.add('Latence P95 élevée pour $metricName (${stats.percentile95.toStringAsFixed(0)}ms)');
      }
    }

    if (recommendations.isEmpty) {
      recommendations.add('Performances normales - aucune action requise');
    }

    return recommendations;
  }

  /// Obtient les informations système
  Map<String, dynamic> _getSystemInfo() {
    return {
      'monitoring_start_time': _monitoringStartTime.toIso8601String(),
      'uptime_hours': DateTime.now().difference(_monitoringStartTime).inHours,
      'dart_version': 'Dart VM',
      'services': {
        'metrics_collector': 'active',
        'alerting_service': 'active',
        'trend_analysis_service': 'active',
      },
    };
  }

  /// Dispose du monitor et nettoie les ressources
  void dispose() {
    _metricsTimer?.cancel();
    _alertingService.dispose();

    _logger.info(
      'RefactoredPerformanceMonitor disposé',
      context: 'RefactoredPerformanceMonitor',
    );
  }
}

// === CLASSES DE SUPPORT (réexportées pour compatibilité) ===

class PerformanceTracker {
  final String operationName;
  final DateTime startTime;
  final Stopwatch _stopwatch;
  final RefactoredPerformanceMonitor _monitor;
  bool _completed = false;

  PerformanceTracker._(this.operationName, this._monitor)
      : startTime = DateTime.now(),
        _stopwatch = Stopwatch()..start();

  void complete({Map<String, dynamic>? tags}) {
    if (_completed) return;
    _completed = true;
    _stopwatch.stop();

    _monitor.completeOperation(this, tags: tags);
  }

  int get elapsedMs => _stopwatch.elapsedMilliseconds;
  Duration get elapsed => _stopwatch.elapsed;
  bool get isCompleted => _completed;
}

// Réexporter les classes nécessaires
export 'package:prioris/domain/services/performance/core/metrics_collector_service.dart';
export 'package:prioris/domain/services/performance/services/alerting_service.dart';
export 'package:prioris/domain/services/performance/services/trend_analysis_service.dart';