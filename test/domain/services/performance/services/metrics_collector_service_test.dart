/// Comprehensive test suite for MetricsCollectorService
/// Ensuring ≥85% code coverage with TDD principles

import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/services/performance/services/metrics_collector_service.dart';
import 'package:prioris/domain/services/performance/interfaces/metrics_collector_interface.dart';
import 'package:prioris/domain/services/performance/models/performance_models.dart';

void main() {
  group('MetricsCollectorService Tests', () {
    late MetricsCollectorService service;

    setUp(() {
      service = MetricsCollectorService(maxHistoryPoints: 100);
    });

    tearDown(() {
      service.dispose();
    });

    group('Metric Recording', () {
      test('should record metric with value', () {
        // Act
        service.recordMetric('test_metric', 42.0);

        // Assert
        final metrics = service.getCurrentMetrics();
        expect(metrics['test_metric']['current'], equals(42.0));
        expect(metrics['test_metric']['count'], equals(1));
      });

      test('should record multiple metrics and update statistics', () {
        // Act
        service.recordMetric('test_metric', 10.0);
        service.recordMetric('test_metric', 20.0);
        service.recordMetric('test_metric', 30.0);

        // Assert
        final metrics = service.getCurrentMetrics();
        expect(metrics['test_metric']['current'], equals(30.0));
        expect(metrics['test_metric']['average'], equals(20.0));
        expect(metrics['test_metric']['min'], equals(10.0));
        expect(metrics['test_metric']['max'], equals(30.0));
        expect(metrics['test_metric']['count'], equals(3));
      });

      test('should record metric with tags', () {
        // Act
        service.recordMetric('test_metric', 42.0, tags: {'source': 'test', 'level': 'info'});

        // Assert
        final metrics = service.getCurrentMetrics();
        expect(metrics['test_metric']['tags']['source'], equals('test'));
        expect(metrics['test_metric']['tags']['level'], equals('info'));
      });

      test('should maintain metric history', () {
        // Act
        service.recordMetric('test_metric', 10.0);
        service.recordMetric('test_metric', 20.0);
        service.recordMetric('test_metric', 30.0);

        // Assert
        final history = service.getMetricHistory('test_metric');
        expect(history.length, equals(3));
        expect(history[0].value, equals(10.0));
        expect(history[1].value, equals(20.0));
        expect(history[2].value, equals(30.0));
      });

      test('should limit history points to maxHistoryPoints', () {
        // Act - Record more metrics than the limit
        for (int i = 0; i < 150; i++) {
          service.recordMetric('test_metric', i.toDouble());
        }

        // Assert
        final history = service.getMetricHistory('test_metric');
        expect(history.length, equals(100)); // Should be limited to maxHistoryPoints
        expect(history.first.value, equals(50.0)); // First 50 should be removed
        expect(history.last.value, equals(149.0));
      });
    });

    group('Event Recording', () {
      test('should record event as metric', () {
        // Act
        service.recordEvent('user_action', {'action': 'click', 'button': 'save'});

        // Assert
        final metrics = service.getCurrentMetrics();
        expect(metrics.containsKey('event_user_action'), isTrue);
        expect(metrics['event_user_action']['current'], equals(1.0));
      });

      test('should accumulate event counts', () {
        // Act
        service.recordEvent('user_action', {'action': 'click'});
        service.recordEvent('user_action', {'action': 'scroll'});
        service.recordEvent('user_action', {'action': 'type'});

        // Assert
        final metrics = service.getCurrentMetrics();
        expect(metrics['event_user_action']['count'], equals(3));
      });
    });

    group('Operation Tracking', () {
      test('should start operation tracker', () {
        // Act
        final tracker = service.startOperation('test_operation');

        // Assert
        expect(tracker, isNotNull);
        expect(tracker.operationName, equals('test_operation'));
        expect(tracker.isCompleted, isFalse);
      });

      test('should complete operation successfully', () {
        // Arrange
        final tracker = service.startOperation('test_operation');

        // Act
        tracker.complete(result: {'status': 'success'});

        // Assert
        expect(tracker.isCompleted, isTrue);
        final metrics = service.getCurrentMetrics();
        expect(metrics.containsKey('operation_duration_ms'), isTrue);
      });

      test('should complete operation with error', () {
        // Arrange
        final tracker = service.startOperation('test_operation');

        // Act
        tracker.completeWithError(Exception('Test error'));

        // Assert
        expect(tracker.isCompleted, isTrue);
        final metrics = service.getCurrentMetrics();
        expect(metrics.containsKey('operation_duration_ms'), isTrue);
        expect(metrics.containsKey('operation_error_rate'), isTrue);
      });

      test('should add context to operation', () {
        // Arrange
        final tracker = service.startOperation('test_operation');

        // Act
        tracker.addContext('user_id', '123');
        tracker.addContext('session_id', 'abc');
        tracker.complete();

        // Assert
        expect(tracker.isCompleted, isTrue);
      });

      test('should record checkpoints', () {
        // Arrange
        final tracker = service.startOperation('test_operation');

        // Act
        tracker.checkpoint('validation');
        tracker.checkpoint('processing');
        tracker.complete();

        // Assert
        final metrics = service.getCurrentMetrics();
        expect(metrics.keys.any((key) => key.contains('checkpoint')), isTrue);
      });

      test('should not complete operation twice', () {
        // Arrange
        final tracker = service.startOperation('test_operation');
        tracker.complete();

        // Act
        tracker.complete(); // Second completion attempt

        // Assert
        expect(tracker.isCompleted, isTrue);
        // Should not throw or create duplicate metrics
      });
    });

    group('History and Statistics', () {
      test('should get metric history for period', () {
        // Arrange
        final now = DateTime.now();
        service.recordMetric('test_metric', 10.0);
        await Future.delayed(Duration(milliseconds: 10));
        service.recordMetric('test_metric', 20.0);

        // Act
        final history = service.getMetricHistory('test_metric', period: Duration(hours: 1));

        // Assert
        expect(history.length, equals(2));
      });

      test('should get all metrics history', () {
        // Arrange
        service.recordMetric('metric1', 10.0);
        service.recordMetric('metric2', 20.0);
        service.recordMetric('metric1', 15.0);

        // Act
        final allHistory = service.getAllMetricsHistory();

        // Assert
        expect(allHistory.keys, contains('metric1'));
        expect(allHistory.keys, contains('metric2'));
        expect(allHistory['metric1']?.length, equals(2));
        expect(allHistory['metric2']?.length, equals(1));
      });

      test('should calculate statistics for metric', () {
        // Arrange
        service.recordMetric('test_metric', 10.0);
        service.recordMetric('test_metric', 20.0);
        service.recordMetric('test_metric', 30.0);
        service.recordMetric('test_metric', 40.0);

        // Act
        final stats = service.calculateStatistics('test_metric');

        // Assert
        expect(stats, isNotNull);
        expect(stats!.average, equals(25.0));
        expect(stats.min, equals(10.0));
        expect(stats.max, equals(40.0));
        expect(stats.sampleCount, equals(4));
      });

      test('should return null statistics for non-existent metric', () {
        // Act
        final stats = service.calculateStatistics('non_existent_metric');

        // Assert
        expect(stats, isNull);
      });

      test('should get all current metrics data', () {
        // Arrange
        service.recordMetric('metric1', 10.0);
        service.recordMetric('metric2', 20.0);

        // Act
        final allMetrics = service.getAllCurrentMetrics();

        // Assert
        expect(allMetrics.keys, contains('metric1'));
        expect(allMetrics.keys, contains('metric2'));
        expect(allMetrics['metric1']?.currentValue, equals(10.0));
        expect(allMetrics['metric2']?.currentValue, equals(20.0));
      });
    });

    group('Memory and Performance', () {
      test('should provide memory usage information', () {
        // Arrange
        service.recordMetric('metric1', 10.0);
        service.recordMetric('metric2', 20.0);

        // Act
        final memoryInfo = service.getMemoryUsageInfo();

        // Assert
        expect(memoryInfo['active_metrics'], equals(2));
        expect(memoryInfo['total_history_points'], isA<int>());
        expect(memoryInfo['estimated_memory_kb'], isA<double>());
        expect(memoryInfo['max_history_points'], equals(100));
      });

      test('should cleanup old history based on retention period', () {
        // Arrange - This is a simplified test as we can't easily mock time
        service.recordMetric('test_metric', 10.0);
        service.recordMetric('test_metric', 20.0);

        // Act
        service.cleanupOldHistory(retentionPeriod: Duration(days: 1));

        // Assert - In a real scenario, old data would be removed
        // For now, we just verify the method doesn't throw
        expect(service.getMetricHistory('test_metric').isNotEmpty, isTrue);
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle empty metric name', () {
        // Act & Assert
        expect(() => service.recordMetric('', 10.0), returnsNormally);
      });

      test('should handle negative metric values', () {
        // Act
        service.recordMetric('test_metric', -10.0);

        // Assert
        final metrics = service.getCurrentMetrics();
        expect(metrics['test_metric']['current'], equals(-10.0));
      });

      test('should handle zero metric values', () {
        // Act
        service.recordMetric('test_metric', 0.0);

        // Assert
        final metrics = service.getCurrentMetrics();
        expect(metrics['test_metric']['current'], equals(0.0));
      });

      test('should handle very large metric values', () {
        // Act
        service.recordMetric('test_metric', double.maxFinite);

        // Assert
        final metrics = service.getCurrentMetrics();
        expect(metrics['test_metric']['current'], equals(double.maxFinite));
      });

      test('should handle null tags gracefully', () {
        // Act & Assert
        expect(() => service.recordMetric('test_metric', 10.0, tags: null), returnsNormally);
      });

      test('should handle empty event details', () {
        // Act & Assert
        expect(() => service.recordEvent('test_event', {}), returnsNormally);
      });
    });

    group('Disposal and Cleanup', () {
      test('should dispose cleanly', () {
        // Arrange
        service.recordMetric('test_metric', 10.0);

        // Act & Assert
        expect(() => service.dispose(), returnsNormally);
      });

      test('should clear data on disposal', () {
        // Arrange
        service.recordMetric('test_metric', 10.0);

        // Act
        service.dispose();

        // Assert
        final metrics = service.getCurrentMetrics();
        expect(metrics.isEmpty, isTrue);
      });
    });
  });
}