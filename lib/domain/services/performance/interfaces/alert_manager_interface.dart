/// SOLID Alert Manager Interface
/// Following Interface Segregation Principle - focused on alerting only

import 'dart:async';
import 'package:prioris/domain/services/performance/models/performance_models.dart';

/// Alert level enumeration
enum AlertLevel {
  info,
  warning,
  critical,
}

/// Interface for performance alerting system
abstract class IAlertManager {
  /// Configure an alert handler for specific alert types
  void setAlertHandler(String alertType, Function(PerformanceAlert) handler);

  /// Set alert threshold for a metric
  void setAlertThreshold(String metricName, AlertThreshold threshold);

  /// Evaluate a metric value against thresholds
  void evaluateMetric(String metricName, double value, {Map<String, dynamic>? context});

  /// Check if a metric value triggers an alert
  void checkAlerts(String metricName, double value);

  /// Get recent alerts
  List<PerformanceAlert> getRecentAlerts({Duration? period});

  /// Get alerts summary
  Map<String, dynamic> generateAlertsSummary();

  /// Clear all alert handlers
  void clearAlertHandlers();

  /// Dispose resources
  void dispose();
}

/// Performance alert data structure
class PerformanceAlert {
  final AlertLevel level;
  final String metricName;
  final double currentValue;
  final double threshold;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? context;

  const PerformanceAlert({
    required this.level,
    required this.metricName,
    required this.currentValue,
    required this.threshold,
    required this.message,
    required this.timestamp,
    this.context,
  });

  Map<String, dynamic> toMap() {
    return {
      'level': level.name,
      'metricName': metricName,
      'currentValue': currentValue,
      'threshold': threshold,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
    };
  }
}

/// Alert threshold configuration
class AlertThreshold {
  final double? warning;
  final double? critical;
  final bool inverse; // true if lower values are worse

  const AlertThreshold({
    this.warning,
    this.critical,
    this.inverse = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'warning': warning,
      'critical': critical,
      'inverse': inverse,
    };
  }
}
