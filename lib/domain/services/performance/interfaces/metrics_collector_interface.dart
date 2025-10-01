/// SOLID Metrics Collector Interface
/// Following Interface Segregation Principle - focused on metrics collection only

import 'dart:async';
import 'package:prioris/domain/services/performance/models/performance_models.dart';

/// Interface for metrics collection operations
abstract class IMetricsCollector {
  /// Record a custom metric value
  void recordMetric(String name, double value, {Map<String, dynamic>? tags});

  /// Record a performance event
  void recordEvent(String eventType, Map<String, dynamic> details);

  /// Get current metrics snapshot
  Map<String, dynamic> getCurrentMetrics();

  /// Start tracking an operation
  IOperationTracker startOperation(String operationName);

  /// Get metric history for analysis
  List<DataPoint> getMetricHistory(String metricName, {Duration? period});

  /// Get all metrics history
  Map<String, List<DataPoint>> getAllMetricsHistory({Duration? period});

  /// Calculate statistics for a metric
  MetricStatistics? calculateStatistics(String metricName, {Duration? period});

  /// Get current metrics data
  Map<String, MetricData> getAllCurrentMetrics();

  /// Get memory usage information
  Map<String, dynamic> getMemoryUsageInfo();

  /// Cleanup old metric history
  void cleanupOldHistory({Duration? retentionPeriod});

  /// Dispose resources
  void dispose();
}

/// Interface for operation tracking
abstract class IOperationTracker {
  /// Add context information to the operation
  void addContext(String key, dynamic value);

  /// Record an intermediate checkpoint
  void checkpoint(String checkpointName);

  /// Complete the operation successfully
  void complete({Map<String, dynamic>? result});

  /// Complete the operation with an error
  void completeWithError(Object error, {StackTrace? stackTrace});

  /// Get operation name
  String get operationName;

  /// Get elapsed time in milliseconds
  int get elapsedMs;

  /// Check if operation is completed
  bool get isCompleted;
}

/// Metric data structure
class MetricData {
  final String name;
  final double currentValue;
  final double sum;
  final double minValue;
  final double maxValue;
  final int count;
  final DateTime lastUpdated;
  final Map<String, dynamic>? lastTags;

  const MetricData({
    required this.name,
    required this.currentValue,
    required this.sum,
    required this.minValue,
    required this.maxValue,
    required this.count,
    required this.lastUpdated,
    this.lastTags,
  });

  double get average => count > 0 ? sum / count : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'currentValue': currentValue,
      'average': average,
      'minValue': minValue,
      'maxValue': maxValue,
      'count': count,
      'lastUpdated': lastUpdated.toIso8601String(),
      'lastTags': lastTags,
    };
  }
}

/// Metric statistics for analysis
class MetricStatistics {
  final String metricName;
  final double average;
  final double min;
  final double max;
  final double standardDeviation;
  final double percentile95;
  final int sampleCount;
  final Duration timeWindow;

  const MetricStatistics({
    required this.metricName,
    required this.average,
    required this.min,
    required this.max,
    required this.standardDeviation,
    required this.percentile95,
    required this.sampleCount,
    required this.timeWindow,
  });

  Map<String, dynamic> toMap() {
    return {
      'metricName': metricName,
      'average': average,
      'min': min,
      'max': max,
      'standardDeviation': standardDeviation,
      'percentile95': percentile95,
      'sampleCount': sampleCount,
      'timeWindow': timeWindow.inMilliseconds,
    };
  }
}
