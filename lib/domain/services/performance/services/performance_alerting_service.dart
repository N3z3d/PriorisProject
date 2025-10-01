/// SOLID Performance Alerting Service
/// Single Responsibility: Handle performance alerts and thresholds only

import 'dart:collection';
import '../interfaces/performance_interfaces.dart';
import '../models/performance_models.dart';

/// Concrete implementation of performance alerting
/// Follows Single Responsibility Principle - only handles alerting
class PerformanceAlertingService implements IPerformanceAlerting {
  final Map<String, AlertThreshold> _alertThresholds = {};
  final Map<String, Function(PerformanceAlert)> _alertHandlers = {};
  final Queue<PerformanceAlert> _recentAlerts = Queue<PerformanceAlert>();
  final int _maxAlertHistory;

  // Default alert thresholds
  static const Map<String, AlertThreshold> _defaultThresholds = {
    'operation_latency_ms': AlertThreshold(warning: 1000, critical: 3000),
    'error_rate_percent': AlertThreshold(warning: 5.0, critical: 15.0),
    'cache_hit_rate_percent': AlertThreshold(warning: 60.0, critical: 40.0, inverse: true),
    'memory_usage_mb': AlertThreshold(warning: 100.0, critical: 200.0),
    'pending_operations': AlertThreshold(warning: 100, critical: 500),
    'cpu_usage_percent': AlertThreshold(warning: 80.0, critical: 95.0),
    'disk_usage_percent': AlertThreshold(warning: 85.0, critical: 95.0),
  };

  PerformanceAlertingService({
    int maxAlertHistory = 1000,
    Map<String, AlertThreshold>? initialThresholds,
  }) : _maxAlertHistory = maxAlertHistory {
    // Initialize with default thresholds
    _alertThresholds.addAll(_defaultThresholds);

    // Override with custom thresholds if provided
    if (initialThresholds != null) {
      _alertThresholds.addAll(initialThresholds);
    }
  }

  @override
  void setAlertHandler(String alertType, Function(PerformanceAlert) handler) {
    _alertHandlers[alertType] = handler;
  }

  @override
  void setAlertThreshold(String metricName, AlertThreshold threshold) {
    _alertThresholds[metricName] = threshold;
  }

  @override
  void checkAlerts(String metricName, double value) {
    final threshold = _alertThresholds[metricName];
    if (threshold == null) return;

    AlertSeverity? alertSeverity;
    double? triggeredThreshold;

    // Determine alert severity based on thresholds and inverse flag
    if (threshold.inverse) {
      // Lower values are worse (e.g., cache hit rate)
      if (threshold.critical != null && value <= threshold.critical!) {
        alertSeverity = AlertSeverity.critical;
        triggeredThreshold = threshold.critical!;
      } else if (threshold.warning != null && value <= threshold.warning!) {
        alertSeverity = AlertSeverity.warning;
        triggeredThreshold = threshold.warning!;
      }
    } else {
      // Higher values are worse (e.g., latency, error rate)
      if (threshold.critical != null && value >= threshold.critical!) {
        alertSeverity = AlertSeverity.critical;
        triggeredThreshold = threshold.critical!;
      } else if (threshold.warning != null && value >= threshold.warning!) {
        alertSeverity = AlertSeverity.warning;
        triggeredThreshold = threshold.warning!;
      }
    }

    // Create and handle alert if threshold was exceeded
    if (alertSeverity != null && triggeredThreshold != null) {
      final alert = PerformanceAlert(
        type: 'threshold_exceeded',
        metricName: metricName,
        value: value,
        threshold: triggeredThreshold,
        severity: alertSeverity,
        timestamp: DateTime.now(),
        context: {
          'thresholdType': threshold.inverse ? 'inverse' : 'normal',
          'warningThreshold': threshold.warning,
          'criticalThreshold': threshold.critical,
        },
      );

      _handleAlert(alert);
    }
  }

  @override
  List<PerformanceAlert> getRecentAlerts({Duration? period}) {
    if (period == null) {
      return _recentAlerts.toList();
    }

    final cutoff = DateTime.now().subtract(period);
    return _recentAlerts
        .where((alert) => alert.timestamp.isAfter(cutoff))
        .toList();
  }

  @override
  void clearAlertHandlers() {
    _alertHandlers.clear();
  }

  /// Get alert statistics
  Map<String, dynamic> getAlertStatistics({Duration? period}) {
    final alerts = getRecentAlerts(period: period);

    final severityCounts = <AlertSeverity, int>{};
    final metricCounts = <String, int>{};
    final typeCounts = <String, int>{};

    for (final alert in alerts) {
      severityCounts[alert.severity] = (severityCounts[alert.severity] ?? 0) + 1;
      metricCounts[alert.metricName] = (metricCounts[alert.metricName] ?? 0) + 1;
      typeCounts[alert.type] = (typeCounts[alert.type] ?? 0) + 1;
    }

    return {
      'totalAlerts': alerts.length,
      'severityBreakdown': severityCounts.map((k, v) => MapEntry(k.name, v)),
      'metricBreakdown': metricCounts,
      'typeBreakdown': typeCounts,
      'alertRate': _calculateAlertRate(alerts, period ?? const Duration(hours: 1)),
      'mostAlertedMetric': _getMostAlertedMetric(metricCounts),
      'criticalAlertsCount': severityCounts[AlertSeverity.critical] ?? 0,
    };
  }

  /// Get configured alert thresholds
  Map<String, AlertThreshold> getAlertThresholds() {
    return Map.unmodifiable(_alertThresholds);
  }

  /// Update multiple thresholds at once
  void updateThresholds(Map<String, AlertThreshold> newThresholds) {
    _alertThresholds.addAll(newThresholds);
  }

  /// Remove alert threshold for a metric
  void removeThreshold(String metricName) {
    _alertThresholds.remove(metricName);
  }

  /// Check if metric has alerting configured
  bool hasAlerting(String metricName) {
    return _alertThresholds.containsKey(metricName);
  }

  /// Get alert handler names
  List<String> getAlertHandlerTypes() {
    return _alertHandlers.keys.toList();
  }

  /// Test alert system by triggering a test alert
  void triggerTestAlert({AlertSeverity severity = AlertSeverity.info}) {
    final testAlert = PerformanceAlert(
      type: 'test_alert',
      metricName: 'test_metric',
      value: 999.0,
      threshold: 500.0,
      severity: severity,
      timestamp: DateTime.now(),
      context: {'source': 'test', 'generated': true},
    );

    _handleAlert(testAlert);
  }

  /// Handle an alert by calling appropriate handlers and storing
  void _handleAlert(PerformanceAlert alert) {
    // Add to recent alerts history
    _recentAlerts.addLast(alert);

    // Maintain history size limit
    while (_recentAlerts.length > _maxAlertHistory) {
      _recentAlerts.removeFirst();
    }

    // Call specific alert handler if configured
    final handler = _alertHandlers[alert.type];
    if (handler != null) {
      try {
        handler(alert);
      } catch (e) {
        // Handle alert handler errors gracefully
        print('Error in alert handler for ${alert.type}: $e');
      }
    }

    // Call general alert handler if configured
    final generalHandler = _alertHandlers['*'];
    if (generalHandler != null) {
      try {
        generalHandler(alert);
      } catch (e) {
        print('Error in general alert handler: $e');
      }
    }

    // Log critical alerts
    if (alert.severity == AlertSeverity.critical) {
      print('CRITICAL ALERT: ${_formatAlertMessage(alert)}');
    }
  }

  /// Format alert message for logging
  String _formatAlertMessage(PerformanceAlert alert) {
    return '${alert.severity.name.toUpperCase()}: '
        '${alert.metricName} = ${alert.value} '
        '(threshold: ${alert.threshold}) '
        'at ${alert.timestamp}';
  }

  /// Calculate alert rate (alerts per hour)
  double _calculateAlertRate(List<PerformanceAlert> alerts, Duration period) {
    if (alerts.isEmpty || period.inHours == 0) return 0.0;
    return alerts.length / period.inHours;
  }

  /// Get the metric that generated the most alerts
  String? _getMostAlertedMetric(Map<String, int> metricCounts) {
    if (metricCounts.isEmpty) return null;

    String? mostAlerted;
    int maxCount = 0;

    for (final entry in metricCounts.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        mostAlerted = entry.key;
      }
    }

    return mostAlerted;
  }

  /// Clear alert history
  void clearAlertHistory() {
    _recentAlerts.clear();
  }

  /// Export alert configuration
  Map<String, dynamic> exportConfiguration() {
    return {
      'thresholds': _alertThresholds.map((key, value) => MapEntry(key, value.toMap())),
      'handlers': _alertHandlers.keys.toList(),
      'maxHistory': _maxAlertHistory,
    };
  }

  /// Import alert configuration
  void importConfiguration(Map<String, dynamic> config) {
    if (config.containsKey('thresholds')) {
      final thresholds = config['thresholds'] as Map<String, dynamic>;
      for (final entry in thresholds.entries) {
        final thresholdData = entry.value as Map<String, dynamic>;
        _alertThresholds[entry.key] = AlertThreshold(
          warning: thresholdData['warning']?.toDouble(),
          critical: thresholdData['critical']?.toDouble(),
          inverse: thresholdData['inverse'] as bool? ?? false,
        );
      }
    }
  }

  /// Dispose resources
  void dispose() {
    _alertHandlers.clear();
    _recentAlerts.clear();
  }
}