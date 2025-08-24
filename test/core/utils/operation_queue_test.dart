import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/core/utils/operation_queue.dart';

void main() {
  group('OperationQueue Tests', () {
    late OperationQueue queue;
    
    setUp(() {
      queue = OperationQueue.instance;
      queue.cleanup(); // Clean state for each test
    });
    
    test('should execute simple operation successfully', () async {
      // Arrange
      var executed = false;
      
      // Act
      await queue.enqueue(
        name: 'test_operation',
        operation: () async {
          executed = true;
          return 'success';
        },
      );
      
      // Assert
      expect(executed, isTrue);
    });
    
    test('should retry failed operations', () async {
      // Arrange
      var attemptCount = 0;
      
      // Act & Assert
      await expectLater(
        queue.enqueue(
          name: 'failing_operation',
          operation: () async {
            attemptCount++;
            if (attemptCount < 3) {
              throw Exception('Simulated failure');
            }
            return 'success_after_retries';
          },
          maxRetries: 3,
          retryDelay: Duration(milliseconds: 10),
        ),
        completion('success_after_retries'),
      );
      
      expect(attemptCount, equals(3));
    });
    
    test('should respect operation priority', () async {
      // Arrange
      final executionOrder = <String>[];
      
      // Act - Add operations in reverse priority order
      final lowPriorityFuture = queue.enqueue(
        name: 'low_priority',
        operation: () async {
          await Future.delayed(Duration(milliseconds: 10));
          executionOrder.add('low');
          return 'low';
        },
        priority: OperationPriority.low,
      );
      
      final highPriorityFuture = queue.enqueue(
        name: 'high_priority', 
        operation: () async {
          executionOrder.add('high');
          return 'high';
        },
        priority: OperationPriority.high,
      );
      
      final mediumPriorityFuture = queue.enqueue(
        name: 'medium_priority',
        operation: () async {
          executionOrder.add('medium');
          return 'medium';
        },
        priority: OperationPriority.medium,
      );
      
      // Wait for all operations
      await Future.wait([lowPriorityFuture, highPriorityFuture, mediumPriorityFuture]);
      
      // Assert - High priority should execute first, then medium, then low
      expect(executionOrder.first, equals('high'));
    });
    
    test('should fail after max retries', () async {
      // Act & Assert
      await expectLater(
        queue.enqueue(
          name: 'always_failing',
          operation: () async {
            throw Exception('Always fails');
          },
          maxRetries: 2,
          retryDelay: Duration(milliseconds: 10),
        ),
        throwsA(isA<Exception>()),
      );
    });
    
    test('should provide accurate queue statistics', () async {
      // Arrange
      final stats = queue.getStatistics();
      
      // Assert initial state
      expect(stats['queueLength'], equals(0));
      expect(stats['processing'], equals(0));
      expect(stats['completed'], equals(0));
      expect(stats['failed'], equals(0));
      
      // Add some operations
      queue.enqueue(
        name: 'stats_test_1',
        operation: () async => 'result1',
      );
      
      queue.enqueue(
        name: 'stats_test_2', 
        operation: () async => 'result2',
      );
      
      // Check updated stats
      final updatedStats = queue.getStatistics();
      expect(updatedStats['queueLength'], greaterThan(0));
    });
  });
}