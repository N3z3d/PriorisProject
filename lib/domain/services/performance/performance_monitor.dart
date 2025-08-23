import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:flutter/foundation.dart';

/// Moniteur de performance complet pour le système de persistance
/// 
/// FONCTIONNALITÉS:
/// - Métriques temps réel (latence, throughput, taux d'erreur)
/// - Alertes automatiques sur les seuils critiques
/// - Analyse de tendance et prédiction de charge
/// - Profiling mémoire et CPU
/// - Dashboard de métriques exportables
class PerformanceMonitor {
  static PerformanceMonitor? _instance;
  static PerformanceMonitor get instance => _instance ??= PerformanceMonitor._internal();
  
  PerformanceMonitor._internal() {
    _startMetricsCollection();
  }

  // Métriques en temps réel
  final _metrics = <String, _MetricData>{};
  final _performanceHistory = <String, Queue<_DataPoint>>{};
  final _alertHandlers = <String, Function(PerformanceAlert)>{};
  
  // Configuration des seuils d'alerte
  final Map<String, _AlertThreshold> _alertThresholds = {
    'operation_latency_ms': _AlertThreshold(warning: 1000, critical: 3000),
    'error_rate_percent': _AlertThreshold(warning: 5.0, critical: 15.0),
    'cache_hit_rate_percent': _AlertThreshold(warning: 60.0, critical: 40.0, inverse: true),
    'memory_usage_mb': _AlertThreshold(warning: 100.0, critical: 200.0),
    'pending_operations': _AlertThreshold(warning: 100, critical: 500),
  };
  
  // Timer pour collecte périodique
  Timer? _metricsTimer;
  DateTime _monitoringStartTime = DateTime.now();
  
  // Profiler de mémoire intégré
  final _memoryProfiler = _MemoryProfiler();
  
  /// Démarre une opération et retourne un tracker
  PerformanceTracker startOperation(String operationName) {
    return PerformanceTracker._(operationName, this);
  }
  
  /// Enregistre une métrique personnalisée
  void recordMetric(String name, double value, {Map<String, dynamic>? tags}) {
    final now = DateTime.now();
    
    // Mise à jour de la métrique courante
    final currentMetric = _metrics[name] ?? _MetricData(name: name);
    currentMetric.recordValue(value, tags);
    _metrics[name] = currentMetric;
    
    // Historique pour analyse de tendance
    final history = _performanceHistory[name] ?? Queue<_DataPoint>();
    history.add(_DataPoint(timestamp: now, value: value, tags: tags));
    
    // Garder seulement les 1000 dernières mesures
    if (history.length > 1000) {
      history.removeFirst();
    }
    _performanceHistory[name] = history;
    
    // Vérifier les seuils d'alerte
    _checkAlertThresholds(name, value);
    
    if (kDebugMode) {
      print('📊 Métrique $name: $value${tags != null ? ' $tags' : ''}');
    }
  }
  
  /// Enregistre un événement de performance
  void recordEvent(String eventType, Map<String, dynamic> details) {
    recordMetric('event_$eventType', 1.0, tags: details);
  }
  
  /// Obtient les métriques actuelles
  Map<String, dynamic> getCurrentMetrics() {
    final result = <String, dynamic>{};
    
    for (final metric in _metrics.values) {
      result[metric.name] = {
        'current': metric.currentValue,
        'average': metric.average,
        'min': metric.minValue,
        'max': metric.maxValue,
        'count': metric.count,
        'totalTime': metric.totalTime.inMilliseconds,
        'tags': metric.lastTags,
      };
    }
    
    // Ajouter les métriques système
    result.addAll(_getSystemMetrics());
    
    return result;
  }
  
  /// Génère un rapport de performance détaillé
  PerformanceReport generateReport({Duration? period}) {
    final reportPeriod = period ?? Duration(hours: 1);
    final cutoffTime = DateTime.now().subtract(reportPeriod);
    
    final reportMetrics = <String, _ReportMetric>{};
    
    for (final entry in _performanceHistory.entries) {
      final metricName = entry.key;
      final history = entry.value;
      
      // Filtrer par période
      final relevantData = history.where((point) => point.timestamp.isAfter(cutoffTime)).toList();
      
      if (relevantData.isNotEmpty) {
        reportMetrics[metricName] = _ReportMetric.fromDataPoints(metricName, relevantData);
      }
    }
    
    return PerformanceReport(
      period: reportPeriod,
      generatedAt: DateTime.now(),
      metrics: reportMetrics,
      systemInfo: _getSystemInfo(),
      alerts: _getRecentAlerts(reportPeriod),
      recommendations: _generateRecommendations(reportMetrics),
    );
  }
  
  /// Analyse de tendance pour prédiction de charge
  Map<String, _TrendAnalysis> analyzeTrends({Duration? period}) {
    final analysisPeriod = period ?? Duration(hours: 24);
    final cutoffTime = DateTime.now().subtract(analysisPeriod);
    
    final trends = <String, _TrendAnalysis>{};
    
    for (final entry in _performanceHistory.entries) {
      final metricName = entry.key;
      final history = entry.value.where((point) => point.timestamp.isAfter(cutoffTime)).toList();
      
      if (history.length >= 10) { // Minimum de données pour analyse
        trends[metricName] = _analyzeTrend(metricName, history);
      }
    }
    
    return trends;
  }
  
  /// Configure un gestionnaire d'alerte
  void setAlertHandler(String alertType, Function(PerformanceAlert) handler) {
    _alertHandlers[alertType] = handler;
  }
  
  /// Profile l'utilisation mémoire d'une opération
  Future<T> profileMemoryUsage<T>(String operationName, Future<T> Function() operation) async {
    final beforeMemory = _memoryProfiler.getCurrentUsage();
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await operation();
      
      stopwatch.stop();
      final afterMemory = _memoryProfiler.getCurrentUsage();
      final memoryDelta = afterMemory - beforeMemory;
      
      recordMetric('memory_delta_$operationName', memoryDelta.toDouble());
      recordMetric('operation_memory_peak_$operationName', afterMemory.toDouble());
      
      return result;
    } catch (e) {
      stopwatch.stop();
      recordEvent('memory_profile_error', {
        'operation': operationName,
        'error': e.toString(),
        'duration_ms': stopwatch.elapsedMilliseconds,
      });
      rethrow;
    }
  }
  
  /// Benchmark automatisé d'une opération
  Future<BenchmarkResult> benchmarkOperation(
    String operationName,
    Future<void> Function() operation, {
    int iterations = 10,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    print('🏃 Benchmark $operationName - $iterations itérations');
    
    final results = <Duration>[];
    final errors = <String>[];
    final memoryUsages = <int>[];
    
    for (int i = 0; i < iterations; i++) {
      try {
        final stopwatch = Stopwatch()..start();
        final beforeMemory = _memoryProfiler.getCurrentUsage();
        
        await operation().timeout(timeout);
        
        stopwatch.stop();
        final afterMemory = _memoryProfiler.getCurrentUsage();
        
        results.add(stopwatch.elapsed);
        memoryUsages.add(afterMemory - beforeMemory);
        
      } catch (e) {
        errors.add('Iteration $i: $e');
      }
    }
    
    if (results.isEmpty) {
      throw Exception('Toutes les itérations ont échoué');
    }
    
    final benchmarkResult = BenchmarkResult(
      operationName: operationName,
      iterations: iterations,
      successfulRuns: results.length,
      averageLatency: Duration(
        microseconds: (results.map((d) => d.inMicroseconds).reduce((a, b) => a + b) / results.length).round()
      ),
      minLatency: results.reduce((a, b) => a < b ? a : b),
      maxLatency: results.reduce((a, b) => a > b ? a : b),
      p95Latency: _calculatePercentile(results, 0.95),
      p99Latency: _calculatePercentile(results, 0.99),
      averageMemoryUsage: memoryUsages.isNotEmpty ? memoryUsages.reduce((a, b) => a + b) / memoryUsages.length : 0.0,
      errors: errors,
      throughputPerSecond: results.isNotEmpty ? 1000000 / results.map((d) => d.inMicroseconds).reduce((a, b) => a + b) * results.length : 0.0,
    );
    
    // Enregistrer les métriques de benchmark
    recordMetric('benchmark_${operationName}_avg_latency_ms', benchmarkResult.averageLatency.inMilliseconds.toDouble());
    recordMetric('benchmark_${operationName}_throughput_ops_sec', benchmarkResult.throughputPerSecond);
    
    print('📊 Benchmark $operationName terminé: ${benchmarkResult.averageLatency.inMilliseconds}ms avg, ${benchmarkResult.throughputPerSecond.toStringAsFixed(1)} ops/sec');
    
    return benchmarkResult;
  }
  
  /// Obtient les métriques système
  Map<String, dynamic> _getSystemMetrics() {
    return {
      'monitoring_uptime_seconds': DateTime.now().difference(_monitoringStartTime).inSeconds,
      'total_metrics_tracked': _metrics.length,
      'memory_usage_mb': _memoryProfiler.getCurrentUsage() / 1024 / 1024,
      'gc_pressure': _memoryProfiler.getGCPressure(),
    };
  }
  
  /// Collecte périodique des métriques
  void _startMetricsCollection() {
    _metricsTimer = Timer.periodic(Duration(seconds: 30), (_) {
      _collectSystemMetrics();
      _cleanupOldData();
    });
  }
  
  /// Collecte les métriques système périodiques
  void _collectSystemMetrics() {
    recordMetric('system_memory_usage_mb', _memoryProfiler.getCurrentUsage() / 1024 / 1024);
    recordMetric('system_gc_pressure', _memoryProfiler.getGCPressure());
  }
  
  /// Nettoie les anciennes données
  void _cleanupOldData() {
    final cutoffTime = DateTime.now().subtract(Duration(hours: 24));
    
    for (final history in _performanceHistory.values) {
      while (history.isNotEmpty && history.first.timestamp.isBefore(cutoffTime)) {
        history.removeFirst();
      }
    }
  }
  
  /// Vérifie les seuils d'alerte
  void _checkAlertThresholds(String metricName, double value) {
    final threshold = _alertThresholds[metricName];
    if (threshold == null) return;
    
    String? alertLevel;
    if (threshold.inverse) {
      // Pour les métriques où une valeur faible est mauvaise (ex: cache hit rate)
      if (value <= threshold.critical) {
        alertLevel = 'critical';
      } else if (value <= threshold.warning) {
        alertLevel = 'warning';
      }
    } else {
      // Pour les métriques où une valeur haute est mauvaise
      if (value >= threshold.critical) {
        alertLevel = 'critical';
      } else if (value >= threshold.warning) {
        alertLevel = 'warning';
      }
    }
    
    if (alertLevel != null) {
      final alert = PerformanceAlert(
        level: alertLevel,
        metricName: metricName,
        currentValue: value,
        threshold: alertLevel == 'critical' ? threshold.critical : threshold.warning,
        message: _generateAlertMessage(metricName, value, alertLevel),
        timestamp: DateTime.now(),
      );
      
      _handleAlert(alert);
    }
  }
  
  /// Gère les alertes
  void _handleAlert(PerformanceAlert alert) {
    final handler = _alertHandlers[alert.metricName] ?? _alertHandlers['*'];
    if (handler != null) {
      try {
        handler(alert);
      } catch (e) {
        if (kDebugMode) {
          print('❌ Erreur lors de la gestion d\'alerte: $e');
        }
      }
    }
    
    print('🚨 ALERTE ${alert.level.toUpperCase()}: ${alert.message}');
  }
  
  /// Génère un message d'alerte
  String _generateAlertMessage(String metricName, double value, String level) {
    switch (metricName) {
      case 'operation_latency_ms':
        return 'Latence élevée détectée: ${value.toStringAsFixed(1)}ms';
      case 'error_rate_percent':
        return 'Taux d\'erreur élevé: ${value.toStringAsFixed(1)}%';
      case 'cache_hit_rate_percent':
        return 'Taux de cache faible: ${value.toStringAsFixed(1)}%';
      case 'memory_usage_mb':
        return 'Utilisation mémoire élevée: ${value.toStringAsFixed(1)}MB';
      default:
        return 'Seuil $level dépassé pour $metricName: $value';
    }
  }
  
  /// Analyse de tendance pour une métrique
  _TrendAnalysis _analyzeTrend(String metricName, List<_DataPoint> data) {
    if (data.length < 2) {
      return _TrendAnalysis(direction: 'stable', confidence: 0.0, prediction: null);
    }
    
    // Calcul de la régression linéaire simple
    final n = data.length;
    final xValues = List.generate(n, (i) => i.toDouble());
    final yValues = data.map((point) => point.value).toList();
    
    final xSum = xValues.reduce((a, b) => a + b);
    final ySum = yValues.reduce((a, b) => a + b);
    final xySum = List.generate(n, (i) => xValues[i] * yValues[i]).reduce((a, b) => a + b);
    final x2Sum = xValues.map((x) => x * x).reduce((a, b) => a + b);
    
    final slope = (n * xySum - xSum * ySum) / (n * x2Sum - xSum * xSum);
    final intercept = (ySum - slope * xSum) / n;
    
    // Coefficient de corrélation pour la confiance
    final yMean = ySum / n;
    final ssRes = List.generate(n, (i) => pow(yValues[i] - (slope * xValues[i] + intercept), 2)).reduce((a, b) => a + b);
    final ssTot = yValues.map((y) => pow(y - yMean, 2)).reduce((a, b) => a + b);
    final r2 = 1 - (ssRes / ssTot);
    
    // Direction de la tendance
    String direction;
    if (slope.abs() < 0.001) {
      direction = 'stable';
    } else if (slope > 0) {
      direction = 'increasing';
    } else {
      direction = 'decreasing';
    }
    
    // Prédiction pour les prochaines 10 mesures
    final prediction = slope * (n + 10) + intercept;
    
    return _TrendAnalysis(
      direction: direction,
      confidence: r2.clamp(0.0, 1.0),
      prediction: prediction,
      slope: slope,
    );
  }
  
  /// Calcule un percentile
  Duration _calculatePercentile(List<Duration> values, double percentile) {
    final sorted = List<Duration>.from(values)..sort();
    final index = (percentile * (sorted.length - 1)).round();
    return sorted[index];
  }
  
  /// Génère des recommandations basées sur les métriques
  List<String> _generateRecommendations(Map<String, _ReportMetric> metrics) {
    final recommendations = <String>[];
    
    // Analyse de la latence
    final latencyMetric = metrics['operation_latency_ms'];
    if (latencyMetric != null && latencyMetric.average > 1000) {
      recommendations.add('Latence élevée détectée (${latencyMetric.average.toStringAsFixed(1)}ms). Considérer l\'optimisation du cache ou la parallélisation.');
    }
    
    // Analyse du taux d'erreur
    final errorRateMetric = metrics['error_rate_percent'];
    if (errorRateMetric != null && errorRateMetric.average > 5) {
      recommendations.add('Taux d\'erreur élevé (${errorRateMetric.average.toStringAsFixed(1)}%). Implémenter un circuit breaker ou améliorer la gestion d\'erreur.');
    }
    
    // Analyse du cache
    final cacheHitRateMetric = metrics['cache_hit_rate_percent'];
    if (cacheHitRateMetric != null && cacheHitRateMetric.average < 70) {
      recommendations.add('Taux de cache faible (${cacheHitRateMetric.average.toStringAsFixed(1)}%). Augmenter la taille du cache ou optimiser la stratégie de mise en cache.');
    }
    
    // Analyse mémoire
    final memoryMetric = metrics['memory_usage_mb'];
    if (memoryMetric != null && memoryMetric.max > 150) {
      recommendations.add('Pic d\'utilisation mémoire élevé (${memoryMetric.max.toStringAsFixed(1)}MB). Optimiser la gestion mémoire ou implémenter du lazy loading.');
    }
    
    return recommendations;
  }
  
  /// Obtient les alertes récentes
  List<PerformanceAlert> _getRecentAlerts(Duration period) {
    // Implémentation simplifiée - en production, maintenir un historique d'alertes
    return [];
  }
  
  /// Informations système
  Map<String, dynamic> _getSystemInfo() {
    return {
      'platform': kIsWeb ? 'web' : 'native',
      'debug_mode': kDebugMode,
      'monitoring_duration': DateTime.now().difference(_monitoringStartTime).toString(),
    };
  }
  
  /// Arrête le monitoring
  void dispose() {
    _metricsTimer?.cancel();
    _metrics.clear();
    _performanceHistory.clear();
    _alertHandlers.clear();
  }
}

/// Tracker pour une opération spécifique
class PerformanceTracker {
  final String _operationName;
  final PerformanceMonitor _monitor;
  final Stopwatch _stopwatch = Stopwatch();
  final DateTime _startTime = DateTime.now();
  final Map<String, dynamic> _context = {};
  
  PerformanceTracker._(this._operationName, this._monitor) {
    _stopwatch.start();
    _monitor.recordEvent('operation_started', {'operation': _operationName});
  }
  
  /// Ajoute du contexte à l'opération
  void addContext(String key, dynamic value) {
    _context[key] = value;
  }
  
  /// Enregistre un checkpoint intermédiaire
  void checkpoint(String name) {
    _monitor.recordMetric('checkpoint_${_operationName}_$name', _stopwatch.elapsedMilliseconds.toDouble());
  }
  
  /// Termine l'opération avec succès
  void complete() {
    _stopwatch.stop();
    final duration = _stopwatch.elapsedMilliseconds.toDouble();
    
    _monitor.recordMetric('operation_latency_ms', duration, tags: {
      'operation': _operationName,
      'success': true,
      ..._context,
    });
    
    _monitor.recordEvent('operation_completed', {
      'operation': _operationName,
      'duration_ms': duration,
      ..._context,
    });
  }
  
  /// Termine l'opération avec erreur
  void error(String errorMessage) {
    _stopwatch.stop();
    final duration = _stopwatch.elapsedMilliseconds.toDouble();
    
    _monitor.recordMetric('operation_latency_ms', duration, tags: {
      'operation': _operationName,
      'success': false,
      'error': errorMessage,
      ..._context,
    });
    
    _monitor.recordMetric('error_rate_percent', 1.0, tags: {
      'operation': _operationName,
      'error': errorMessage,
    });
    
    _monitor.recordEvent('operation_failed', {
      'operation': _operationName,
      'duration_ms': duration,
      'error': errorMessage,
      ..._context,
    });
  }
}

/// Classes de données pour le monitoring

class _MetricData {
  final String name;
  double _sum = 0;
  double _minValue = double.infinity;
  double _maxValue = double.negativeInfinity;
  int _count = 0;
  Duration _totalTime = Duration.zero;
  double _currentValue = 0;
  Map<String, dynamic>? lastTags;
  
  _MetricData({required this.name});
  
  void recordValue(double value, Map<String, dynamic>? tags) {
    _sum += value;
    _count++;
    _currentValue = value;
    _minValue = min(_minValue, value);
    _maxValue = max(_maxValue, value);
    lastTags = tags;
  }
  
  double get average => _count > 0 ? _sum / _count : 0.0;
  double get currentValue => _currentValue;
  double get minValue => _minValue == double.infinity ? 0.0 : _minValue;
  double get maxValue => _maxValue == double.negativeInfinity ? 0.0 : _maxValue;
  int get count => _count;
  Duration get totalTime => _totalTime;
}

class _DataPoint {
  final DateTime timestamp;
  final double value;
  final Map<String, dynamic>? tags;
  
  _DataPoint({required this.timestamp, required this.value, this.tags});
}

class _AlertThreshold {
  final double warning;
  final double critical;
  final bool inverse; // true si une valeur faible déclenche l'alerte
  
  _AlertThreshold({required this.warning, required this.critical, this.inverse = false});
}

class _MemoryProfiler {
  int getCurrentUsage() {
    // Implémentation basique - en production, utiliser les APIs platform-specific
    return 50 * 1024 * 1024; // 50MB placeholder
  }
  
  double getGCPressure() {
    // Métrique de pression sur le garbage collector
    return 0.5; // Placeholder
  }
}

class _ReportMetric {
  final String name;
  final double average;
  final double min;
  final double max;
  final int count;
  final double stdDev;
  
  _ReportMetric({
    required this.name,
    required this.average,
    required this.min,
    required this.max,
    required this.count,
    required this.stdDev,
  });
  
  static _ReportMetric fromDataPoints(String name, List<_DataPoint> points) {
    final values = points.map((p) => p.value).toList();
    final average = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((v) => pow(v - average, 2)).reduce((a, b) => a + b) / values.length;
    
    return _ReportMetric(
      name: name,
      average: average,
      min: values.reduce((a, b) => a < b ? a : b),
      max: values.reduce((a, b) => a > b ? a : b),
      count: values.length,
      stdDev: sqrt(variance),
    );
  }
}

class _TrendAnalysis {
  final String direction;
  final double confidence;
  final double? prediction;
  final double? slope;
  
  _TrendAnalysis({
    required this.direction,
    required this.confidence,
    this.prediction,
    this.slope,
  });
}

/// Classes publiques pour l'API

class PerformanceAlert {
  final String level;
  final String metricName;
  final double currentValue;
  final double threshold;
  final String message;
  final DateTime timestamp;
  
  PerformanceAlert({
    required this.level,
    required this.metricName,
    required this.currentValue,
    required this.threshold,
    required this.message,
    required this.timestamp,
  });
}

class PerformanceReport {
  final Duration period;
  final DateTime generatedAt;
  final Map<String, _ReportMetric> metrics;
  final Map<String, dynamic> systemInfo;
  final List<PerformanceAlert> alerts;
  final List<String> recommendations;
  
  PerformanceReport({
    required this.period,
    required this.generatedAt,
    required this.metrics,
    required this.systemInfo,
    required this.alerts,
    required this.recommendations,
  });
  
  /// Exporte le rapport en format JSON
  Map<String, dynamic> toJson() {
    return {
      'generated_at': generatedAt.toIso8601String(),
      'period_hours': period.inHours,
      'metrics': metrics.map((key, metric) => MapEntry(key, {
        'average': metric.average,
        'min': metric.min,
        'max': metric.max,
        'count': metric.count,
        'std_dev': metric.stdDev,
      })),
      'system_info': systemInfo,
      'alerts_count': alerts.length,
      'recommendations': recommendations,
    };
  }
}

class BenchmarkResult {
  final String operationName;
  final int iterations;
  final int successfulRuns;
  final Duration averageLatency;
  final Duration minLatency;
  final Duration maxLatency;
  final Duration p95Latency;
  final Duration p99Latency;
  final double averageMemoryUsage;
  final List<String> errors;
  final double throughputPerSecond;
  
  BenchmarkResult({
    required this.operationName,
    required this.iterations,
    required this.successfulRuns,
    required this.averageLatency,
    required this.minLatency,
    required this.maxLatency,
    required this.p95Latency,
    required this.p99Latency,
    required this.averageMemoryUsage,
    required this.errors,
    required this.throughputPerSecond,
  });
  
  /// Taux de succès
  double get successRate => successfulRuns / iterations;
  
  /// Rapport de benchmark formaté
  String get summary => '''
Benchmark: $operationName
Iterations: $iterations (${successfulRuns} réussies, ${errors.length} erreurs)
Latence: ${averageLatency.inMilliseconds}ms avg, ${minLatency.inMilliseconds}ms min, ${maxLatency.inMilliseconds}ms max
Percentiles: P95=${p95Latency.inMilliseconds}ms, P99=${p99Latency.inMilliseconds}ms
Throughput: ${throughputPerSecond.toStringAsFixed(1)} ops/sec
Mémoire: ${averageMemoryUsage.toStringAsFixed(1)}KB avg
Taux de succès: ${(successRate * 100).toStringAsFixed(1)}%
''';
}