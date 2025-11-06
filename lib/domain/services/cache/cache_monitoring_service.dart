import 'dart:async';

import 'package:prioris/domain/services/cache/cache_service.dart';
import 'package:prioris/domain/services/cache/cache_statistics.dart';

export 'cache_statistics.dart' show CacheAlert, CacheAlertType, CacheMetrics, CachePerformanceReport, CacheHealthStatus;

class CacheMonitoringService {
  CacheMonitoringService(this._cacheService);

  final CacheService _cacheService;
  final _metricsHistory = <CacheMetrics>[];
  final _alertsHistory = <CacheAlert>[];
  final _metricsController = StreamController<CacheMetrics>.broadcast(sync: true);
  final _alertsController = StreamController<CacheAlert>.broadcast(sync: true);
  Timer? _timer;
  bool _disposed = false;

  List<CacheMetrics> get metricsHistory => List.unmodifiable(_metricsHistory);
  List<CacheAlert> get alertsHistory => List.unmodifiable(_alertsHistory);

  Stream<CacheMetrics> get metricsStream => _metricsController.stream;
  Stream<CacheAlert> get alertsStream => _alertsController.stream;

  Future<void> startMonitoring({Duration interval = const Duration(seconds: 1)}) async {
    stopMonitoring();
    _timer = Timer.periodic(interval, (_) => collectCurrentMetrics());
  }

  void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
  }

  Future<CacheMetrics> collectCurrentMetrics() async {
    if (_disposed) {
      return CacheMetrics(
        timestamp: DateTime.now(),
        totalEntries: 0,
        hitRate: 0,
        missRate: 0,
        diskUsageMB: 0,
        totalOperations: 0,
        averageLatency: Duration.zero,
      );
    }

    final stats = await _cacheService.getStats();
    final snapshot = _cacheService.createStatisticsSnapshot();
    final metrics = CacheMetrics(
      timestamp: DateTime.now(),
      totalEntries: stats.totalEntries,
      hitRate: stats.hitRate,
      missRate: stats.missRate,
      diskUsageMB: stats.diskUsageMB,
      totalOperations: snapshot.totalAccesses + snapshot.writes,
      averageLatency: snapshot.requestsPerSecond == 0
          ? const Duration(milliseconds: 0)
          : Duration(
              microseconds: (1000000 / snapshot.requestsPerSecond).round(),
            ),
    );

    _pushMetric(metrics);
    _evaluateAlerts(metrics);
    return metrics;
  }

  Future<CachePerformanceReport> generateReport({
    required Duration period,
  }) async {
    final cutoff = DateTime.now().subtract(period);
    final relevant = _metricsHistory
        .where((metric) => metric.timestamp.isAfter(cutoff))
        .toList();

    if (relevant.isEmpty) {
      return CachePerformanceReport(
        period: period,
        totalOperations: 0,
        averageHitRate: 0,
        averageLatency: Duration.zero,
        recommendations: const [],
        trend: const {},
      );
    }

    final hits = relevant.map((m) => m.hitRate).toList();
    final latencies = relevant
        .map((m) => m.averageLatency.inMilliseconds.toDouble())
        .toList();
    final operations = relevant.fold<int>(
      0,
      (total, metric) => total + metric.totalOperations,
    );

    final recommendations = <String>[];
    final avgHitRate = hits.reduce((a, b) => a + b) / hits.length;
    if (avgHitRate < 0.6) {
      recommendations.add(
          'Average hit rate is below expectations. Investigate warmup strategies.');
    }
    if (operations == 0) {
      recommendations.clear();
    }
    if (recommendations.isEmpty && operations > 0) {
      recommendations.add('Cache performance is within expected range.');
    }

    return CachePerformanceReport(
      period: period,
      totalOperations: operations,
      averageHitRate: avgHitRate,
      averageLatency: Duration(
        milliseconds:
            latencies.isEmpty ? 0 : (latencies.reduce((a, b) => a + b) ~/ latencies.length),
      ),
      recommendations: recommendations,
      trend: {
        'hitRate': avgHitRate,
        'operations': operations,
      },
    );
  }

  Future<CacheHealthStatus> checkHealth() async {
    final metrics = await collectCurrentMetrics();
    final issues = <String>[];
    if (metrics.diskUsageMB > 50) {
      issues.add('Disk usage exceeds 50MB threshold');
    }
    if (metrics.hitRate < 0.2 && metrics.totalOperations > 5) {
      issues.add('Very low hit rate detected');
    }
    if (_alertsHistory.length > 20) {
      issues.add('Frequent cache errors recorded');
    }
    if (_alertsHistory.isNotEmpty) {
      issues.add('Recent cache errors detected');
    }

    return CacheHealthStatus(
      isHealthy: issues.isEmpty,
      lastCheck: DateTime.now(),
      metrics: metrics,
      issues: issues,
    );
  }

  void recordError(String operation, String error) {
    final alert = CacheAlert(
      type: CacheAlertType.error,
      message: 'Error during $operation: $error',
      details: {'operation': operation, 'error': error},
    );
    _pushAlert(alert);
  }

  void dispose() {
    if (_disposed) {
      return;
    }
    stopMonitoring();
    _metricsController.close();
    _alertsController.close();
    _metricsHistory.clear();
    _alertsHistory.clear();
    _disposed = true;
  }

  void _pushMetric(CacheMetrics metrics) {
    _metricsHistory.add(metrics);
    if (_metricsHistory.length > 1000) {
      _metricsHistory.removeRange(0, _metricsHistory.length - 1000);
    }
    if (!_metricsController.isClosed) {
      _metricsController.add(metrics);
    }
  }

  void _pushAlert(CacheAlert alert) {
    _alertsHistory.add(alert);
    if (_alertsHistory.length > 500) {
      _alertsHistory.removeRange(0, _alertsHistory.length - 500);
    }
    if (!_alertsController.isClosed) {
      _alertsController.add(alert);
    }
  }

  void _evaluateAlerts(CacheMetrics metrics) {
    if (metrics.diskUsageMB > 40) {
      _pushAlert(
        CacheAlert(
          type: CacheAlertType.diskUsage,
          message: 'Cache disk usage above 40MB',
          details: {'diskUsageMB': metrics.diskUsageMB},
        ),
      );
    }
    if (metrics.hitRate < 0.3 && metrics.totalOperations > 0) {
      _pushAlert(
        CacheAlert(
          type: CacheAlertType.hitRate,
          message: 'Cache hit rate below 30%',
          details: {'hitRate': metrics.hitRate},
        ),
      );
    }
  }
}
