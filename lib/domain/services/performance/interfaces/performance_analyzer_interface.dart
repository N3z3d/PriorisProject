/// SOLID Performance Analyzer Interface
/// Following Interface Segregation Principle - focused on analysis and reporting

import 'dart:async';
import 'package:prioris/domain/services/performance/models/performance_models.dart';
import 'package:prioris/domain/services/performance/interfaces/metrics_collector_interface.dart';

/// Interface for performance analysis and reporting
abstract class IPerformanceAnalyzer {
  /// Generate comprehensive performance report
  PerformanceReport generateReport({Duration? period});

  /// Analyze metric trends for prediction
  TrendAnalysis analyzeMetricTrend(String metricName, List<DataPoint> data);

  /// Analyze multiple metrics trends
  Map<String, TrendAnalysis> analyzeMultipleTrends(Map<String, List<DataPoint>> metricsData);

  /// Generate recommendations based on metrics and alerts
  List<String> generateRecommendations(
    Map<String, MetricStatistics> metrics,
    List<PerformanceAlert> alerts,
  );

  /// Calculate statistical analysis for data points
  MetricStatistics calculateStatistics(String metricName, List<DataPoint> data);

  /// Detect anomalies in metric data
  List<AnomalyDetection> detectAnomalies(
    String metricName,
    List<DataPoint> data, {
    double sensitivityFactor = 2.0,
  });

  /// Predict future metric value based on trend
  double? predictFutureValue(List<DataPoint> data, Duration futureOffset);

  /// Compare benchmark results
  ComparisonResult compareBenchmarks(List<BenchmarkResult> results);

  /// Get health status based on metrics
  PerformanceHealthStatus calculateHealthStatus(
    Map<String, MetricStatistics> metrics,
    List<PerformanceAlert> alerts,
  );
}

/// Anomaly detection result
class AnomalyDetection {
  final DateTime timestamp;
  final double value;
  final double expectedValue;
  final double deviationScore;
  final String severity;
  final String description;

  const AnomalyDetection({
    required this.timestamp,
    required this.value,
    required this.expectedValue,
    required this.deviationScore,
    required this.severity,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'value': value,
      'expectedValue': expectedValue,
      'deviationScore': deviationScore,
      'severity': severity,
      'description': description,
    };
  }
}
