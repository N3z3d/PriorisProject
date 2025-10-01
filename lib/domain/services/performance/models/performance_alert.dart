/// Model representing a performance alert
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
