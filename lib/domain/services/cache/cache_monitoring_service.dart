import 'dart:async';
import 'package:prioris/domain/services/cache/cache_service.dart';

/// Service de monitoring et métriques pour le cache
/// Fournit des métriques en temps réel et des alertes
class CacheMonitoringService {
  final CacheService _cacheService;
  Timer? _monitoringTimer;
  final StreamController<CacheMetrics> _metricsController = StreamController<CacheMetrics>.broadcast();
  final StreamController<CacheAlert> _alertsController = StreamController<CacheAlert>.broadcast();
  
  // Seuils d'alerte
  static const double _lowHitRateThreshold = 0.3; // 30%
  static const int _highLatencyThreshold = 100; // 100ms
  static const int _maxErrorRate = 5; // 5 erreurs par minute
  
  // Métriques en temps réel
  final List<CacheMetrics> _metricsHistory = [];
  final List<CacheAlert> _alertsHistory = [];
  int _errorCount = 0;
  DateTime? _lastErrorReset;
  
  CacheMonitoringService(this._cacheService);
  
  /// Stream des métriques en temps réel
  Stream<CacheMetrics> get metricsStream => _metricsController.stream;
  
  /// Stream des alertes
  Stream<CacheAlert> get alertsStream => _alertsController.stream;
  
  /// Historique des métriques
  List<CacheMetrics> get metricsHistory => List.unmodifiable(_metricsHistory);
  
  /// Historique des alertes
  List<CacheAlert> get alertsHistory => List.unmodifiable(_alertsHistory);
  
  /// Démarre le monitoring
  Future<void> startMonitoring({Duration interval = const Duration(seconds: 30)}) async {
    _monitoringTimer?.cancel();
    _monitoringTimer = Timer.periodic(interval, (_) => _collectMetrics());
    
    // Collecte initiale
    await _collectMetrics();
  }
  
  /// Arrête le monitoring
  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
  }
  
  /// Collecte les métriques actuelles
  Future<CacheMetrics> collectCurrentMetrics() async {
    return await _collectMetrics();
  }
  
  /// Génère un rapport de performance
  Future<CachePerformanceReport> generateReport({
    Duration period = const Duration(hours: 1),
  }) async {
    final now = DateTime.now();
    final cutoff = now.subtract(period);
    
    final relevantMetrics = _getRelevantMetrics(cutoff);
    
    if (relevantMetrics.isEmpty) {
      return CachePerformanceReport.empty();
    }
    
    return _buildPerformanceReport(period, relevantMetrics);
  }

  /// Récupère les métriques pertinentes pour la période
  List<CacheMetrics> _getRelevantMetrics(DateTime cutoff) {
    return _metricsHistory
        .where((m) => m.timestamp.isAfter(cutoff))
        .toList();
  }

  /// Construit le rapport de performance à partir des métriques
  CachePerformanceReport _buildPerformanceReport(
    Duration period, 
    List<CacheMetrics> metrics,
  ) {
    final averages = _calculateAverages(metrics);
    final extremes = _calculateExtremes(metrics);
    final totals = _calculateTotals(metrics);
    final trend = _analyzeTrend(metrics);
    
    return CachePerformanceReport(
      period: period,
      averageHitRate: averages['hitRate']!,
      averageLatency: Duration(milliseconds: averages['latency']!.round()),
      averageDiskUsage: averages['diskUsage']!,
      maxDiskUsage: extremes['maxDiskUsage']!,
      minHitRate: extremes['minHitRate']!,
      totalOperations: totals['operations']!,
      errorCount: _errorCount,
      trend: trend,
      recommendations: _generateRecommendations(
        averages['hitRate']!,
        averages['latency']!,
        averages['diskUsage']!,
        trend,
      ),
    );
  }

  /// Calcule les moyennes des métriques
  Map<String, double> _calculateAverages(List<CacheMetrics> metrics) {
    final avgHitRate = metrics
        .map((m) => m.hitRate)
        .reduce((a, b) => a + b) / metrics.length;
    
    final avgLatency = metrics
        .map((m) => m.averageAccessTime.inMilliseconds)
        .reduce((a, b) => a + b) / metrics.length;
    
    final avgDiskUsage = metrics
        .map((m) => m.diskUsageMB)
        .reduce((a, b) => a + b) / metrics.length;

    return {
      'hitRate': avgHitRate,
      'latency': avgLatency,
      'diskUsage': avgDiskUsage,
    };
  }

  /// Calcule les valeurs extrêmes des métriques
  Map<String, double> _calculateExtremes(List<CacheMetrics> metrics) {
    final maxDiskUsage = metrics
        .map((m) => m.diskUsageMB)
        .reduce((a, b) => a > b ? a : b);
    
    final minHitRate = metrics
        .map((m) => m.hitRate)
        .reduce((a, b) => a < b ? a : b);

    return {
      'maxDiskUsage': maxDiskUsage,
      'minHitRate': minHitRate,
    };
  }

  /// Calcule les totaux des métriques
  Map<String, int> _calculateTotals(List<CacheMetrics> metrics) {
    final totalOperations = metrics
        .map((m) => m.totalOperations)
        .reduce((a, b) => a + b);

    return {
      'operations': totalOperations,
    };
  }
  
  /// Vérifie la santé du cache
  Future<CacheHealthStatus> checkHealth() async {
    final metrics = await _collectMetrics();
    final issues = _identifyHealthIssues(metrics);
    
    return CacheHealthStatus(
      isHealthy: issues.isEmpty,
      issues: issues,
      lastCheck: DateTime.now(),
      metrics: metrics,
    );
  }

  /// Identifie les problèmes de santé du cache
  List<String> _identifyHealthIssues(CacheMetrics metrics) {
    final issues = <String>[];
    
    _checkHitRate(metrics, issues);
    _checkLatency(metrics, issues);
    _checkDiskUsage(metrics, issues);
    _checkErrorRate(issues);
    
    return issues;
  }

  /// Vérifie le taux de succès du cache
  void _checkHitRate(CacheMetrics metrics, List<String> issues) {
    if (metrics.hitRate < _lowHitRateThreshold) {
      issues.add('Hit rate trop faible: ${(metrics.hitRate * 100).toStringAsFixed(1)}%');
    }
  }

  /// Vérifie la latence du cache
  void _checkLatency(CacheMetrics metrics, List<String> issues) {
    if (metrics.averageAccessTime.inMilliseconds > _highLatencyThreshold) {
      issues.add('Latence élevée: ${metrics.averageAccessTime.inMilliseconds}ms');
    }
  }

  /// Vérifie l'usage disque du cache
  void _checkDiskUsage(CacheMetrics metrics, List<String> issues) {
    if (metrics.diskUsageMB > 40) { // 80% de 50MB
      issues.add('Usage disque élevé: ${metrics.diskUsageMB.toStringAsFixed(2)}MB');
    }
  }

  /// Vérifie le taux d'erreur
  void _checkErrorRate(List<String> issues) {
    if (_errorCount > _maxErrorRate) {
      issues.add('Trop d\'erreurs: $_errorCount erreurs');
    }
  }
  
  /// Enregistre une erreur
  void recordError(String operation, String error) {
    _updateErrorCount();
    _createAndSendAlert(operation, error);
  }

  /// Met à jour le compteur d'erreurs
  void _updateErrorCount() {
    _errorCount++;
    
    final now = DateTime.now();
    if (_shouldResetErrorCount(now)) {
      _errorCount = 1;
      _lastErrorReset = now;
    }
  }

  /// Vérifie si le compteur d'erreurs doit être réinitialisé
  bool _shouldResetErrorCount(DateTime now) {
    return _lastErrorReset == null || 
           now.difference(_lastErrorReset!).inMinutes >= 1;
  }

  /// Crée et envoie une alerte d'erreur
  void _createAndSendAlert(String operation, String error) {
    final alert = CacheAlert(
      type: CacheAlertType.error,
      message: 'Erreur lors de $operation: $error',
      timestamp: DateTime.now(),
      severity: CacheAlertSeverity.high,
    );
    
    _alertsHistory.add(alert);
    _alertsController.add(alert);
  }
  
  // Méthodes privées
  
  Future<CacheMetrics> _collectMetrics() async {
    final stats = await _cacheService.getStats();
    
    final metrics = _createMetricsFromStats(stats);
    _processCollectedMetrics(metrics);
    
    return metrics;
  }

  /// Crée des métriques à partir des statistiques
  CacheMetrics _createMetricsFromStats(CacheStats stats) {
    return CacheMetrics(
      timestamp: DateTime.now(),
      totalEntries: stats.totalEntries,
      totalSize: stats.totalSize,
      hitRate: stats.hitRate,
      averageAccessTime: stats.averageAccessTime,
      diskUsageMB: stats.diskUsageMB,
      totalOperations: _calculateTotalOperations(stats),
      errorRate: _errorCount / 60.0, // Erreurs par minute
    );
  }

  /// Traite les métriques collectées
  void _processCollectedMetrics(CacheMetrics metrics) {
    _addToHistory(metrics);
    _metricsController.add(metrics);
    _checkAlerts(metrics);
  }

  /// Ajoute les métriques à l'historique avec limitation
  void _addToHistory(CacheMetrics metrics) {
    _metricsHistory.add(metrics);
    
    // Limiter l'historique à 1000 entrées
    if (_metricsHistory.length > 1000) {
      _metricsHistory.removeRange(0, _metricsHistory.length - 1000);
    }
  }
  
  Future<void> _checkAlerts(CacheMetrics metrics) async {
    final alerts = _generateAlerts(metrics);
    _sendAlerts(alerts);
  }

  /// Génère les alertes basées sur les métriques
  List<CacheAlert> _generateAlerts(CacheMetrics metrics) {
    final alerts = <CacheAlert>[];
    
    _addDiskUsageAlert(metrics, alerts);
    _addHitRateAlert(metrics, alerts);
    _addLatencyAlert(metrics, alerts);
    _addErrorAlert(alerts);
    
    return alerts;
  }

  /// Ajoute une alerte d'usage disque si nécessaire
  void _addDiskUsageAlert(CacheMetrics metrics, List<CacheAlert> alerts) {
    if (metrics.diskUsageMB > 40) {
      alerts.add(CacheAlert(
        type: CacheAlertType.diskUsage,
        message: 'Usage disque élevé: ${metrics.diskUsageMB.toStringAsFixed(2)}MB',
        timestamp: DateTime.now(),
        severity: CacheAlertSeverity.warning,
      ));
    }
  }

  /// Ajoute une alerte de hit rate si nécessaire
  void _addHitRateAlert(CacheMetrics metrics, List<CacheAlert> alerts) {
    if (metrics.hitRate < _lowHitRateThreshold) {
      alerts.add(CacheAlert(
        type: CacheAlertType.hitRate,
        message: 'Hit rate faible: ${(metrics.hitRate * 100).toStringAsFixed(1)}%',
        timestamp: DateTime.now(),
        severity: CacheAlertSeverity.warning,
      ));
    }
  }

  /// Ajoute une alerte de latence si nécessaire
  void _addLatencyAlert(CacheMetrics metrics, List<CacheAlert> alerts) {
    if (metrics.averageAccessTime.inMilliseconds > _highLatencyThreshold) {
      alerts.add(CacheAlert(
        type: CacheAlertType.latency,
        message: 'Latence élevée: ${metrics.averageAccessTime.inMilliseconds}ms',
        timestamp: DateTime.now(),
        severity: CacheAlertSeverity.warning,
      ));
    }
  }

  /// Ajoute une alerte d'erreur si nécessaire
  void _addErrorAlert(List<CacheAlert> alerts) {
    if (_errorCount > _maxErrorRate) {
      alerts.add(CacheAlert(
        type: CacheAlertType.error,
        message: 'Trop d\'erreurs: $_errorCount erreurs',
        timestamp: DateTime.now(),
        severity: CacheAlertSeverity.critical,
      ));
    }
  }

  /// Envoie les alertes générées
  void _sendAlerts(List<CacheAlert> alerts) {
    for (final alert in alerts) {
      _alertsHistory.add(alert);
      _alertsController.add(alert);
    }
  }
  
  int _calculateTotalOperations(CacheStats stats) {
    // Estimation basée sur les métriques disponibles
    return stats.totalEntries * 2; // Approximation
  }
  
  CacheTrend _analyzeTrend(List<CacheMetrics> metrics) {
    if (metrics.length < 2) return CacheTrend.stable;
    
    final sampleSizes = _calculateSampleSizes(metrics);
    final averages = _calculateTrendAverages(metrics, sampleSizes);
    
    return _determineTrend(averages['recent']!, averages['older']!);
  }

  /// Calcule les tailles d'échantillon pour l'analyse de tendance
  Map<String, int> _calculateSampleSizes(List<CacheMetrics> metrics) {
    final sampleSize = metrics.length ~/ 3;
    return {
      'sampleSize': sampleSize,
    };
  }

  /// Calcule les moyennes pour l'analyse de tendance
  Map<String, double> _calculateTrendAverages(
    List<CacheMetrics> metrics, 
    Map<String, int> sampleSizes,
  ) {
    final sampleSize = sampleSizes['sampleSize']!;
    
    final recent = metrics.take(sampleSize).toList();
    final older = metrics.skip(sampleSize).take(sampleSize).toList();
    
    if (recent.isEmpty || older.isEmpty) {
      return {'recent': 0.0, 'older': 0.0};
    }
    
    final recentAvg = recent
        .map((m) => m.hitRate)
        .reduce((a, b) => a + b) / recent.length;
    
    final olderAvg = older
        .map((m) => m.hitRate)
        .reduce((a, b) => a + b) / older.length;
    
    return {
      'recent': recentAvg,
      'older': olderAvg,
    };
  }

  /// Détermine la tendance basée sur les moyennes
  CacheTrend _determineTrend(double recentAvg, double olderAvg) {
    final difference = recentAvg - olderAvg;
    
    if (difference > 0.1) return CacheTrend.improving;
    if (difference < -0.1) return CacheTrend.degrading;
    return CacheTrend.stable;
  }
  
  List<String> _generateRecommendations(
    double hitRate,
    double latency,
    double diskUsage,
    CacheTrend trend,
  ) {
    final recommendations = <String>[];
    
    _addHitRateRecommendations(hitRate, recommendations);
    _addLatencyRecommendations(latency, recommendations);
    _addDiskUsageRecommendations(diskUsage, recommendations);
    _addTrendRecommendations(trend, recommendations);
    
    return recommendations;
  }

  /// Ajoute des recommandations pour le hit rate
  void _addHitRateRecommendations(double hitRate, List<String> recommendations) {
    if (hitRate < 0.5) {
      recommendations.add('Considérer l\'augmentation de la taille du cache');
      recommendations.add('Analyser les patterns d\'accès pour optimiser');
    }
  }

  /// Ajoute des recommandations pour la latence
  void _addLatencyRecommendations(double latency, List<String> recommendations) {
    if (latency > 50) {
      recommendations.add('Optimiser les opérations de cache');
      recommendations.add('Considérer la compression des données');
    }
  }

  /// Ajoute des recommandations pour l'usage disque
  void _addDiskUsageRecommendations(double diskUsage, List<String> recommendations) {
    if (diskUsage > 30) {
      recommendations.add('Nettoyer les entrées expirées');
      recommendations.add('Réduire la TTL des entrées non critiques');
    }
  }

  /// Ajoute des recommandations pour la tendance
  void _addTrendRecommendations(CacheTrend trend, List<String> recommendations) {
    if (trend == CacheTrend.degrading) {
      recommendations.add('Investigation requise sur la dégradation des performances');
    }
  }
  
  /// Dispose des ressources
  void dispose() {
    stopMonitoring();
    _metricsController.close();
    _alertsController.close();
  }
}

/// Métriques du cache
class CacheMetrics {
  final DateTime timestamp;
  final int totalEntries;
  final int totalSize;
  final double hitRate;
  final Duration averageAccessTime;
  final double diskUsageMB;
  final int totalOperations;
  final double errorRate;
  
  const CacheMetrics({
    required this.timestamp,
    required this.totalEntries,
    required this.totalSize,
    required this.hitRate,
    required this.averageAccessTime,
    required this.diskUsageMB,
    required this.totalOperations,
    required this.errorRate,
  });
  
  @override
  String toString() {
    return 'CacheMetrics('
        'timestamp: $timestamp, '
        'entries: $totalEntries, '
        'size: ${(totalSize / 1024).toStringAsFixed(2)}KB, '
        'hitRate: ${(hitRate * 100).toStringAsFixed(1)}%, '
        'latency: ${averageAccessTime.inMilliseconds}ms, '
        'diskUsage: ${diskUsageMB.toStringAsFixed(2)}MB, '
        'operations: $totalOperations, '
        'errorRate: ${errorRate.toStringAsFixed(2)})';
  }
}

/// Alerte du cache
class CacheAlert {
  final CacheAlertType type;
  final String message;
  final DateTime timestamp;
  final CacheAlertSeverity severity;
  
  const CacheAlert({
    required this.type,
    required this.message,
    required this.timestamp,
    required this.severity,
  });
  
  @override
  String toString() {
    return 'CacheAlert('
        'type: $type, '
        'severity: $severity, '
        'message: $message, '
        'timestamp: $timestamp)';
  }
}

/// Types d'alertes
enum CacheAlertType {
  diskUsage,
  hitRate,
  latency,
  error,
  performance,
}

/// Sévérité des alertes
enum CacheAlertSeverity {
  low,
  warning,
  high,
  critical,
}

/// Tendances de performance
enum CacheTrend {
  improving,
  stable,
  degrading,
}

/// Statut de santé du cache
class CacheHealthStatus {
  final bool isHealthy;
  final List<String> issues;
  final DateTime lastCheck;
  final CacheMetrics metrics;
  
  const CacheHealthStatus({
    required this.isHealthy,
    required this.issues,
    required this.lastCheck,
    required this.metrics,
  });
  
  @override
  String toString() {
    return 'CacheHealthStatus('
        'healthy: $isHealthy, '
        'issues: ${issues.length}, '
        'lastCheck: $lastCheck)';
  }
}

/// Rapport de performance du cache
class CachePerformanceReport {
  final Duration period;
  final double averageHitRate;
  final Duration averageLatency;
  final double averageDiskUsage;
  final double maxDiskUsage;
  final double minHitRate;
  final int totalOperations;
  final int errorCount;
  final CacheTrend trend;
  final List<String> recommendations;
  
  const CachePerformanceReport({
    required this.period,
    required this.averageHitRate,
    required this.averageLatency,
    required this.averageDiskUsage,
    required this.maxDiskUsage,
    required this.minHitRate,
    required this.totalOperations,
    required this.errorCount,
    required this.trend,
    required this.recommendations,
  });
  
  factory CachePerformanceReport.empty() {
    return const CachePerformanceReport(
      period: Duration.zero,
      averageHitRate: 0.0,
      averageLatency: Duration.zero,
      averageDiskUsage: 0.0,
      maxDiskUsage: 0.0,
      minHitRate: 0.0,
      totalOperations: 0,
      errorCount: 0,
      trend: CacheTrend.stable,
      recommendations: [],
    );
  }
  
  @override
  String toString() {
    return 'CachePerformanceReport('
        'period: $period, '
        'avgHitRate: ${(averageHitRate * 100).toStringAsFixed(1)}%, '
        'avgLatency: ${averageLatency.inMilliseconds}ms, '
        'avgDiskUsage: ${averageDiskUsage.toStringAsFixed(2)}MB, '
        'trend: $trend, '
        'recommendations: ${recommendations.length})';
  }
} 
