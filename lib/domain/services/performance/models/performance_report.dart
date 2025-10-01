import 'package:prioris/domain/services/performance/models/performance_alert.dart';
import 'package:prioris/domain/services/performance/models/report_metric.dart';

/// Model representing a performance report
class PerformanceReport {
  final Duration period;
  final DateTime generatedAt;
  final Map<String, ReportMetric> metrics;
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

  /// Exports the report as JSON
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
