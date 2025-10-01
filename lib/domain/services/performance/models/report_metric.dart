import 'dart:math';

/// Model representing a metric for reports
class ReportMetric {
  final String name;
  final double average;
  final double min;
  final double max;
  final int count;
  final double stdDev;

  ReportMetric({
    required this.name,
    required this.average,
    required this.min,
    required this.max,
    required this.count,
    required this.stdDev,
  });

  /// Creates a ReportMetric from data points
  static ReportMetric fromDataPoints(String name, List<DataPoint> points) {
    final values = points.map((p) => p.value).toList();
    final average = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((v) => pow(v - average, 2)).reduce((a, b) => a + b) / values.length;

    return ReportMetric(
      name: name,
      average: average,
      min: values.reduce((a, b) => a < b ? a : b),
      max: values.reduce((a, b) => a > b ? a : b),
      count: values.length,
      stdDev: sqrt(variance),
    );
  }
}

/// Data point model
class DataPoint {
  final DateTime timestamp;
  final double value;
  final Map<String, dynamic>? tags;

  DataPoint({
    required this.timestamp,
    required this.value,
    this.tags,
  });
}
