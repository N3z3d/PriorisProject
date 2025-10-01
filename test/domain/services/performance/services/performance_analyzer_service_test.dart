/// Comprehensive test suite for PerformanceAnalyzerService
/// Ensuring ≥85% code coverage with TDD principles

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:prioris/domain/services/performance/services/performance_analyzer_service.dart';
import 'package:prioris/domain/services/performance/interfaces/metrics_collector_interface.dart';
import 'package:prioris/domain/services/performance/interfaces/alert_manager_interface.dart';
import 'package:prioris/domain/services/performance/models/performance_models.dart';

@GenerateMocks([IMetricsCollector, IAlertManager])
import 'performance_analyzer_service_test.mocks.dart';

void main() {
  group('PerformanceAnalyzerService Tests', () {
    late PerformanceAnalyzerService analyzer;
    late MockIMetricsCollector mockMetricsCollector;
    late MockIAlertManager mockAlertManager;

    setUp(() {
      mockMetricsCollector = MockIMetricsCollector();
      mockAlertManager = MockIAlertManager();
      analyzer = PerformanceAnalyzerService(
        metricsCollector: mockMetricsCollector,
        alertManager: mockAlertManager,
      );
    });

    group('Report Generation', () {
      test('should generate comprehensive performance report', () {
        // Arrange
        final metricsHistory = <String, List<DataPoint>>{
          'cpu_usage': [
            DataPoint(timestamp: DateTime.now().subtract(Duration(minutes: 2)), value: 50.0),
            DataPoint(timestamp: DateTime.now().subtract(Duration(minutes: 1)), value: 60.0),
            DataPoint(timestamp: DateTime.now(), value: 70.0),
          ],
        };
        final alerts = <PerformanceAlert>[];

        when(mockMetricsCollector.getAllMetricsHistory(period: anyNamed('period')))
            .thenReturn(metricsHistory);
        when(mockAlertManager.getRecentAlerts(period: anyNamed('period')))
            .thenReturn(alerts);

        // Act
        final report = analyzer.generateReport(period: Duration(hours: 1));

        // Assert
        expect(report, isNotNull);
        expect(report.metrics.containsKey('cpu_usage'), isTrue);
        expect(report.alerts, equals(alerts));
        expect(report.period, equals(Duration(hours: 1)));
        expect(report.recommendations, isNotEmpty);
      });

      test('should handle empty metrics history', () {
        // Arrange
        when(mockMetricsCollector.getAllMetricsHistory(period: anyNamed('period')))
            .thenReturn(<String, List<DataPoint>>{});
        when(mockAlertManager.getRecentAlerts(period: anyNamed('period')))
            .thenReturn([]);

        // Act
        final report = analyzer.generateReport();

        // Assert
        expect(report.metrics, isEmpty);
        expect(report.alerts, isEmpty);
        expect(report.recommendations.first, contains('No performance issues detected'));
      });
    });

    group('Trend Analysis', () {
      test('should analyze metric trend with sufficient data', () {
        // Arrange
        final dataPoints = [
          DataPoint(timestamp: DateTime.now().subtract(Duration(hours: 3)), value: 10.0),
          DataPoint(timestamp: DateTime.now().subtract(Duration(hours: 2)), value: 20.0),
          DataPoint(timestamp: DateTime.now().subtract(Duration(hours: 1)), value: 30.0),
          DataPoint(timestamp: DateTime.now(), value: 40.0),
        ];

        // Act
        final trend = analyzer.analyzeMetricTrend('cpu_usage', dataPoints);

        // Assert
        expect(trend.metricName, equals('cpu_usage'));
        expect(trend.direction, equals(TrendDirection.increasing));
        expect(trend.slope, greaterThan(0));
        expect(trend.confidence, greaterThan(0));
        expect(trend.insights, isNotEmpty);
      });

      test('should handle insufficient data for trend analysis', () {
        // Arrange
        final dataPoints = [
          DataPoint(timestamp: DateTime.now(), value: 10.0),
        ];

        // Act
        final trend = analyzer.analyzeMetricTrend('cpu_usage', dataPoints);

        // Assert
        expect(trend.direction, equals(TrendDirection.stable));
        expect(trend.slope, equals(0.0));
        expect(trend.confidence, equals(0.0));
        expect(trend.insights.first, contains('Insufficient data'));
      });

      test('should analyze multiple metrics trends', () {
        // Arrange
        final metricsData = <String, List<DataPoint>>{
          'cpu_usage': [
            DataPoint(timestamp: DateTime.now().subtract(Duration(hours: 2)), value: 10.0),
            DataPoint(timestamp: DateTime.now().subtract(Duration(hours: 1)), value: 20.0),
            DataPoint(timestamp: DateTime.now(), value: 30.0),
          ],
          'memory_usage': [
            DataPoint(timestamp: DateTime.now().subtract(Duration(hours: 2)), value: 100.0),
            DataPoint(timestamp: DateTime.now().subtract(Duration(hours: 1)), value: 95.0),
            DataPoint(timestamp: DateTime.now(), value: 90.0),
          ],
        };

        // Act
        final trends = analyzer.analyzeMultipleTrends(metricsData);

        // Assert
        expect(trends.length, equals(2));
        expect(trends.containsKey('cpu_usage'), isTrue);
        expect(trends.containsKey('memory_usage'), isTrue);
        expect(trends['cpu_usage']?.direction, equals(TrendDirection.increasing));
        expect(trends['memory_usage']?.direction, equals(TrendDirection.decreasing));
      });

      test('should detect stable trend for flat data', () {
        // Arrange
        final dataPoints = [
          DataPoint(timestamp: DateTime.now().subtract(Duration(hours: 3)), value: 50.0),
          DataPoint(timestamp: DateTime.now().subtract(Duration(hours: 2)), value: 50.1),
          DataPoint(timestamp: DateTime.now().subtract(Duration(hours: 1)), value: 49.9),
          DataPoint(timestamp: DateTime.now(), value: 50.0),
        ];

        // Act
        final trend = analyzer.analyzeMetricTrend('stable_metric', dataPoints);

        // Assert
        expect(trend.direction, equals(TrendDirection.stable));
        expect(trend.slope.abs(), lessThan(0.01));
      });

      test('should detect volatile trend for erratic data', () {
        // Arrange
        final dataPoints = [
          DataPoint(timestamp: DateTime.now().subtract(Duration(hours: 4)), value: 10.0),
          DataPoint(timestamp: DateTime.now().subtract(Duration(hours: 3)), value: 50.0),
          DataPoint(timestamp: DateTime.now().subtract(Duration(hours: 2)), value: 20.0),
          DataPoint(timestamp: DateTime.now().subtract(Duration(hours: 1)), value: 80.0),
          DataPoint(timestamp: DateTime.now(), value: 30.0),
        ];

        // Act
        final trend = analyzer.analyzeMetricTrend('volatile_metric', dataPoints);

        // Assert
        expect(trend.direction, equals(TrendDirection.volatile));
        expect(trend.correlation.abs(), lessThan(0.3));
      });
    });

    group('Statistics Calculation', () {
      test('should calculate correct statistics for data points', () {
        // Arrange
        final dataPoints = [
          DataPoint(timestamp: DateTime.now(), value: 10.0),
          DataPoint(timestamp: DateTime.now(), value: 20.0),
          DataPoint(timestamp: DateTime.now(), value: 30.0),
          DataPoint(timestamp: DateTime.now(), value: 40.0),
          DataPoint(timestamp: DateTime.now(), value: 50.0),
        ];

        // Act
        final stats = analyzer.calculateStatistics('test_metric', dataPoints);

        // Assert
        expect(stats.metricName, equals('test_metric'));
        expect(stats.average, equals(30.0));
        expect(stats.min, equals(10.0));
        expect(stats.max, equals(50.0));
        expect(stats.sampleCount, equals(5));
        expect(stats.standardDeviation, greaterThan(0));
      });

      test('should handle empty data for statistics', () {
        // Act
        final stats = analyzer.calculateStatistics('empty_metric', []);

        // Assert
        expect(stats.average, equals(0.0));
        expect(stats.min, equals(0.0));
        expect(stats.max, equals(0.0));
        expect(stats.sampleCount, equals(0));
        expect(stats.standardDeviation, equals(0.0));
      });
    });

    group('Anomaly Detection', () {
      test('should detect anomalies in data', () {
        // Arrange - Create data with clear outliers
        final dataPoints = List.generate(20, (i) =>
          DataPoint(timestamp: DateTime.now(), value: 50.0 + (i % 2) * 2)); // Normal: 50-52
        // Add outliers
        dataPoints.add(DataPoint(timestamp: DateTime.now(), value: 100.0)); // Clear outlier
        dataPoints.add(DataPoint(timestamp: DateTime.now(), value: 5.0));   // Clear outlier

        // Act
        final anomalies = analyzer.detectAnomalies('test_metric', dataPoints);

        // Assert
        expect(anomalies.length, greaterThan(0));
        expect(anomalies.any((a) => a.value == 100.0), isTrue);
        expect(anomalies.any((a) => a.value == 5.0), isTrue);
      });

      test('should not detect anomalies in consistent data', () {
        // Arrange - Create consistent data
        final dataPoints = List.generate(20, (i) =>
          DataPoint(timestamp: DateTime.now(), value: 50.0 + (i % 3))); // 50, 51, 52 pattern

        // Act
        final anomalies = analyzer.detectAnomalies('test_metric', dataPoints);

        // Assert
        expect(anomalies, isEmpty);
      });

      test('should handle insufficient data for anomaly detection', () {
        // Arrange
        final dataPoints = [
          DataPoint(timestamp: DateTime.now(), value: 10.0),
          DataPoint(timestamp: DateTime.now(), value: 20.0),
        ];

        // Act
        final anomalies = analyzer.detectAnomalies('test_metric', dataPoints);

        // Assert
        expect(anomalies, isEmpty);
      });

      test('should adjust sensitivity for anomaly detection', () {
        // Arrange
        final dataPoints = List.generate(15, (i) =>
          DataPoint(timestamp: DateTime.now(), value: 50.0));
        dataPoints.add(DataPoint(timestamp: DateTime.now(), value: 60.0)); // Mild outlier

        // Act - Lower sensitivity should detect more anomalies
        final anomaliesHighSensitivity = analyzer.detectAnomalies('test_metric', dataPoints, sensitivityFactor: 1.0);
        final anomaliesLowSensitivity = analyzer.detectAnomalies('test_metric', dataPoints, sensitivityFactor: 3.0);

        // Assert
        expect(anomaliesHighSensitivity.length, greaterThanOrEqualTo(anomaliesLowSensitivity.length));
      });
    });

    group('Future Value Prediction', () {
      test('should predict future value based on trend', () {
        // Arrange - Create linear increasing trend
        final dataPoints = [
          DataPoint(timestamp: DateTime.now().subtract(Duration(hours: 3)), value: 10.0),
          DataPoint(timestamp: DateTime.now().subtract(Duration(hours: 2)), value: 20.0),
          DataPoint(timestamp: DateTime.now().subtract(Duration(hours: 1)), value: 30.0),
        ];

        // Act
        final prediction = analyzer.predictFutureValue(dataPoints, Duration(hours: 1));

        // Assert
        expect(prediction, isNotNull);
        expect(prediction!, greaterThan(30.0)); // Should predict higher value
      });

      test('should return null for insufficient data', () {
        // Arrange
        final dataPoints = [
          DataPoint(timestamp: DateTime.now(), value: 10.0),
        ];

        // Act
        final prediction = analyzer.predictFutureValue(dataPoints, Duration(hours: 1));

        // Assert
        expect(prediction, isNull);
      });
    });

    group('Benchmark Comparison', () {
      test('should compare benchmark results and identify winner', () {
        // Arrange
        final benchmarks = [
          BenchmarkResult(
            operationName: 'operation_a',
            iterations: 100,
            totalDuration: Duration(seconds: 10),
            averageDuration: Duration(milliseconds: 100),
            minDuration: Duration(milliseconds: 90),
            maxDuration: Duration(milliseconds: 110),
            operationsPerSecond: 10.0,
            successRate: 1.0,
            errors: [],
          ),
          BenchmarkResult(
            operationName: 'operation_b',
            iterations: 100,
            totalDuration: Duration(seconds: 5),
            averageDuration: Duration(milliseconds: 50),
            minDuration: Duration(milliseconds: 45),
            maxDuration: Duration(milliseconds: 55),
            operationsPerSecond: 20.0,
            successRate: 1.0,
            errors: [],
          ),
        ];

        // Act
        final comparison = analyzer.compareBenchmarks(benchmarks);

        // Assert
        expect(comparison.winner, equals('operation_b'));
        expect(comparison.results.length, equals(2));
        expect(comparison.comparisons['operation_a'], contains('slower'));
      });

      test('should handle empty benchmark list', () {
        // Act
        final comparison = analyzer.compareBenchmarks([]);

        // Assert
        expect(comparison.winner, contains('No benchmarks'));
        expect(comparison.results, isEmpty);
        expect(comparison.comparisons, isEmpty);
      });
    });

    group('Health Status Calculation', () {
      test('should calculate healthy status for good metrics', () {
        // Arrange
        final metrics = <String, MetricStatistics>{
          'cpu_usage': MetricStatistics(
            metricName: 'cpu_usage',
            average: 30.0,
            min: 25.0,
            max: 35.0,
            standardDeviation: 3.0,
            percentile95: 34.0,
            sampleCount: 100,
            timeWindow: Duration(hours: 1),
          ),
        };
        final alerts = <PerformanceAlert>[];

        // Act
        final health = analyzer.calculateHealthStatus(metrics, alerts);

        // Assert
        expect(health.status, equals(HealthStatus.healthy));
        expect(health.score, greaterThan(80.0));
      });

      test('should calculate warning status for moderate issues', () {
        // Arrange
        final metrics = <String, MetricStatistics>{};
        final alerts = [
          PerformanceAlert(
            level: AlertLevel.warning,
            metricName: 'cpu_usage',
            currentValue: 75.0,
            threshold: 70.0,
            message: 'High CPU usage',
            timestamp: DateTime.now(),
          ),
        ];

        // Act
        final health = analyzer.calculateHealthStatus(metrics, alerts);

        // Assert
        expect(health.status, anyOf(HealthStatus.warning, HealthStatus.healthy));
        expect(health.score, lessThan(100.0));
      });

      test('should calculate critical status for severe issues', () {
        // Arrange
        final metrics = <String, MetricStatistics>{};
        final alerts = List.generate(5, (i) => PerformanceAlert(
          level: AlertLevel.critical,
          metricName: 'metric_$i',
          currentValue: 90.0,
          threshold: 80.0,
          message: 'Critical issue',
          timestamp: DateTime.now(),
        ));

        // Act
        final health = analyzer.calculateHealthStatus(metrics, alerts);

        // Assert
        expect(health.status, equals(HealthStatus.critical));
        expect(health.score, lessThan(60.0));
      });
    });

    group('Recommendations Generation', () {
      test('should generate alert-based recommendations', () {
        // Arrange
        final metrics = <String, MetricStatistics>{};
        final alerts = [
          PerformanceAlert(
            level: AlertLevel.critical,
            metricName: 'cpu_usage',
            currentValue: 95.0,
            threshold: 90.0,
            message: 'Critical CPU usage',
            timestamp: DateTime.now(),
          ),
        ];

        // Act
        final recommendations = analyzer.generateRecommendations(metrics, alerts);

        // Assert
        expect(recommendations, isNotEmpty);
        expect(recommendations.any((r) => r.contains('critical alert')), isTrue);
      });

      test('should generate metrics-based recommendations', () {
        // Arrange
        final metrics = <String, MetricStatistics>{
          'response_latency_ms': MetricStatistics(
            metricName: 'response_latency_ms',
            average: 1500.0,
            min: 1000.0,
            max: 3000.0,
            standardDeviation: 800.0, // High volatility
            percentile95: 2500.0, // High P95
            sampleCount: 100,
            timeWindow: Duration(hours: 1),
          ),
        };
        final alerts = <PerformanceAlert>[];

        // Act
        final recommendations = analyzer.generateRecommendations(metrics, alerts);

        // Assert
        expect(recommendations, isNotEmpty);
        expect(recommendations.any((r) => r.contains('volatility') || r.contains('latency')), isTrue);
      });

      test('should return positive message for good performance', () {
        // Arrange
        final metrics = <String, MetricStatistics>{
          'cpu_usage': MetricStatistics(
            metricName: 'cpu_usage',
            average: 30.0,
            min: 25.0,
            max: 35.0,
            standardDeviation: 2.0,
            percentile95: 34.0,
            sampleCount: 100,
            timeWindow: Duration(hours: 1),
          ),
        };
        final alerts = <PerformanceAlert>[];

        // Act
        final recommendations = analyzer.generateRecommendations(metrics, alerts);

        // Assert
        expect(recommendations.length, equals(1));
        expect(recommendations.first, contains('No performance issues'));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle null or empty metric names gracefully', () {
        // Act & Assert
        expect(() => analyzer.calculateStatistics('', []), returnsNormally);
        expect(() => analyzer.analyzeMetricTrend('', []), returnsNormally);
      });

      test('should handle extreme values in calculations', () {
        // Arrange
        final dataPoints = [
          DataPoint(timestamp: DateTime.now(), value: double.maxFinite),
          DataPoint(timestamp: DateTime.now(), value: double.minPositive),
          DataPoint(timestamp: DateTime.now(), value: 0.0),
        ];

        // Act & Assert
        expect(() => analyzer.calculateStatistics('extreme_metric', dataPoints), returnsNormally);
        expect(() => analyzer.analyzeMetricTrend('extreme_metric', dataPoints), returnsNormally);
      });

      test('should handle identical data points', () {
        // Arrange
        final dataPoints = List.generate(10, (i) =>
          DataPoint(timestamp: DateTime.now(), value: 50.0));

        // Act
        final stats = analyzer.calculateStatistics('identical_metric', dataPoints);
        final trend = analyzer.analyzeMetricTrend('identical_metric', dataPoints);

        // Assert
        expect(stats.standardDeviation, equals(0.0));
        expect(stats.min, equals(stats.max));
        expect(trend.direction, equals(TrendDirection.stable));
      });
    });
  });
}