/// SOLID Performance Monitoring Models
/// Data structures for performance monitoring system

/// Performance alert information
class PerformanceAlert {
  final String type;
  final String metricName;
  final double value;
  final double threshold;
  final AlertSeverity severity;
  final DateTime timestamp;
  final Map<String, dynamic>? context;

  const PerformanceAlert({
    required this.type,
    required this.metricName,
    required this.value,
    required this.threshold,
    required this.severity,
    required this.timestamp,
    this.context,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'metricName': metricName,
      'value': value,
      'threshold': threshold,
      'severity': severity.name,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
    };
  }
}

/// Alert severity levels
enum AlertSeverity {
  info,
  warning,
  critical,
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

/// Performance report containing comprehensive metrics
class PerformanceReport {
  final DateTime generatedAt;
  final Duration period;
  final Map<String, MetricReport> metrics;
  final List<PerformanceAlert> alerts;
  final Map<String, TrendAnalysis> trends;
  final SystemHealthSummary systemHealth;
  final List<String> recommendations;

  const PerformanceReport({
    required this.generatedAt,
    required this.period,
    required this.metrics,
    required this.alerts,
    required this.trends,
    required this.systemHealth,
    required this.recommendations,
  });

  Map<String, dynamic> toMap() {
    return {
      'generatedAt': generatedAt.toIso8601String(),
      'period': period.inMilliseconds,
      'metrics': metrics.map((key, value) => MapEntry(key, value.toMap())),
      'alerts': alerts.map((alert) => alert.toMap()).toList(),
      'trends': trends.map((key, value) => MapEntry(key, value.toMap())),
      'systemHealth': systemHealth.toMap(),
      'recommendations': recommendations,
    };
  }
}

/// Individual metric report
class MetricReport {
  final String name;
  final String unit;
  final double currentValue;
  final double averageValue;
  final double minValue;
  final double maxValue;
  final double percentile95;
  final int sampleCount;
  final List<DataPoint> history;

  const MetricReport({
    required this.name,
    required this.unit,
    required this.currentValue,
    required this.averageValue,
    required this.minValue,
    required this.maxValue,
    required this.percentile95,
    required this.sampleCount,
    required this.history,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'unit': unit,
      'currentValue': currentValue,
      'averageValue': averageValue,
      'minValue': minValue,
      'maxValue': maxValue,
      'percentile95': percentile95,
      'sampleCount': sampleCount,
      'history': history.map((point) => point.toMap()).toList(),
    };
  }
}

/// Data point for time series metrics
class DataPoint {
  final DateTime timestamp;
  final double value;
  final Map<String, dynamic>? tags;

  const DataPoint({
    required this.timestamp,
    required this.value,
    this.tags,
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'value': value,
      'tags': tags,
    };
  }
}

/// Trend analysis result
class TrendAnalysis {
  final String metricName;
  final TrendDirection direction;
  final double slope; // Rate of change per unit time
  final double correlation; // Correlation coefficient (-1 to 1)
  final double predictedValue; // Predicted next value
  final double confidence; // Confidence level (0 to 1)
  final Duration timeWindow;
  final List<String> insights;

  const TrendAnalysis({
    required this.metricName,
    required this.direction,
    required this.slope,
    required this.correlation,
    required this.predictedValue,
    required this.confidence,
    required this.timeWindow,
    required this.insights,
  });

  Map<String, dynamic> toMap() {
    return {
      'metricName': metricName,
      'direction': direction.name,
      'slope': slope,
      'correlation': correlation,
      'predictedValue': predictedValue,
      'confidence': confidence,
      'timeWindow': timeWindow.inMilliseconds,
      'insights': insights,
    };
  }
}

/// Trend direction indicators
enum TrendDirection {
  increasing,
  decreasing,
  stable,
  volatile,
}

/// Memory snapshot for profiling
class MemorySnapshot {
  final DateTime timestamp;
  final int usedBytes;
  final int availableBytes;
  final int peakUsageBytes;
  final Map<String, int> categoryBreakdown;

  const MemorySnapshot({
    required this.timestamp,
    required this.usedBytes,
    required this.availableBytes,
    required this.peakUsageBytes,
    required this.categoryBreakdown,
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'usedBytes': usedBytes,
      'availableBytes': availableBytes,
      'peakUsageBytes': peakUsageBytes,
      'categoryBreakdown': categoryBreakdown,
    };
  }
}

/// System resource snapshot
class SystemSnapshot {
  final DateTime timestamp;
  final double cpuUsage;
  final int memoryUsedMB;
  final int memoryTotalMB;
  final double diskUsage;
  final Map<String, dynamic> additionalMetrics;

  const SystemSnapshot({
    required this.timestamp,
    required this.cpuUsage,
    required this.memoryUsedMB,
    required this.memoryTotalMB,
    required this.diskUsage,
    required this.additionalMetrics,
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'cpuUsage': cpuUsage,
      'memoryUsedMB': memoryUsedMB,
      'memoryTotalMB': memoryTotalMB,
      'diskUsage': diskUsage,
      'additionalMetrics': additionalMetrics,
    };
  }
}

/// Benchmark execution result
class BenchmarkResult {
  final String operationName;
  final int iterations;
  final Duration totalDuration;
  final Duration averageDuration;
  final Duration minDuration;
  final Duration maxDuration;
  final double operationsPerSecond;
  final double successRate;
  final List<String> errors;
  final Map<String, dynamic>? context;

  const BenchmarkResult({
    required this.operationName,
    required this.iterations,
    required this.totalDuration,
    required this.averageDuration,
    required this.minDuration,
    required this.maxDuration,
    required this.operationsPerSecond,
    required this.successRate,
    required this.errors,
    this.context,
  });

  Map<String, dynamic> toMap() {
    return {
      'operationName': operationName,
      'iterations': iterations,
      'totalDurationMs': totalDuration.inMilliseconds,
      'averageDurationMs': averageDuration.inMilliseconds,
      'minDurationMs': minDuration.inMilliseconds,
      'maxDurationMs': maxDuration.inMilliseconds,
      'operationsPerSecond': operationsPerSecond,
      'successRate': successRate,
      'errors': errors,
      'context': context,
    };
  }
}

/// Comparison result between multiple operations
class ComparisonResult {
  final Map<String, BenchmarkResult> results;
  final String winner; // Operation name with best performance
  final Map<String, String> comparisons;

  const ComparisonResult({
    required this.results,
    required this.winner,
    required this.comparisons,
  });

  Map<String, dynamic> toMap() {
    return {
      'results': results.map((key, value) => MapEntry(key, value.toMap())),
      'winner': winner,
      'comparisons': comparisons,
    };
  }
}

/// System health summary
class SystemHealthSummary {
  final HealthStatus overall;
  final Map<String, HealthStatus> components;
  final List<String> issues;
  final List<String> recommendations;
  final DateTime lastCheck;

  const SystemHealthSummary({
    required this.overall,
    required this.components,
    required this.issues,
    required this.recommendations,
    required this.lastCheck,
  });

  Map<String, dynamic> toMap() {
    return {
      'overall': overall.name,
      'components': components.map((key, value) => MapEntry(key, value.name)),
      'issues': issues,
      'recommendations': recommendations,
      'lastCheck': lastCheck.toIso8601String(),
    };
  }
}

/// Health status levels
enum HealthStatus {
  healthy,
  warning,
  critical,
  unknown,
}

/// Overall performance health status
class PerformanceHealthStatus {
  final HealthStatus status;
  final double score; // 0-100 health score
  final Map<String, dynamic> details;
  final DateTime timestamp;

  const PerformanceHealthStatus({
    required this.status,
    required this.score,
    required this.details,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'score': score,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Performance monitoring configuration
class PerformanceConfiguration {
  final Duration metricsCollectionInterval;
  final Duration dataRetentionPeriod;
  final bool enableAlerting;
  final bool enableTrendAnalysis;
  final bool enableMemoryProfiling;
  final bool enableSystemMonitoring;
  final Map<String, AlertThreshold> alertThresholds;
  final int maxHistoryPoints;
  final bool enableBenchmarking;

  const PerformanceConfiguration({
    this.metricsCollectionInterval = const Duration(seconds: 5),
    this.dataRetentionPeriod = const Duration(hours: 24),
    this.enableAlerting = true,
    this.enableTrendAnalysis = true,
    this.enableMemoryProfiling = true,
    this.enableSystemMonitoring = true,
    this.alertThresholds = const {},
    this.maxHistoryPoints = 1000,
    this.enableBenchmarking = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'metricsCollectionInterval': metricsCollectionInterval.inMilliseconds,
      'dataRetentionPeriod': dataRetentionPeriod.inMilliseconds,
      'enableAlerting': enableAlerting,
      'enableTrendAnalysis': enableTrendAnalysis,
      'enableMemoryProfiling': enableMemoryProfiling,
      'enableSystemMonitoring': enableSystemMonitoring,
      'alertThresholds': alertThresholds.map((key, value) => MapEntry(key, value.toMap())),
      'maxHistoryPoints': maxHistoryPoints,
      'enableBenchmarking': enableBenchmarking,
    };
  }
}