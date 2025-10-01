import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';

/// Mock implementation de ILogger pour les tests
class MockLogger extends Mock implements ILogger {}

void main() {
  group('ILogger Interface Tests', () {
    late MockLogger mockLogger;

    setUp(() {
      mockLogger = MockLogger();
    });

    test('interface définit toutes les méthodes de logging requises', () {
      // Test que l'interface compile et peut être mockée
      expect(mockLogger, isA<ILogger>());
    });

    test('debug method signature is correct', () {
      // Arrange
      const message = 'Debug message';
      const context = 'TestContext';
      const correlationId = 'test-123';
      const data = {'test': 'data'};

      // Act - should not throw
      expect(() => mockLogger.debug(
        message,
        context: context,
        correlationId: correlationId,
        data: data,
      ), returnsNormally);
    });

    test('info method signature is correct', () {
      // Arrange
      const message = 'Info message';
      const context = 'TestContext';
      const correlationId = 'test-123';
      const data = {'test': 'data'};

      // Act - should not throw
      expect(() => mockLogger.info(
        message,
        context: context,
        correlationId: correlationId,
        data: data,
      ), returnsNormally);
    });

    test('warning method signature is correct', () {
      // Arrange
      const message = 'Warning message';
      const context = 'TestContext';
      const correlationId = 'test-123';
      const data = {'test': 'data'};

      // Act - should not throw
      expect(() => mockLogger.warning(
        message,
        context: context,
        correlationId: correlationId,
        data: data,
      ), returnsNormally);
    });

    test('error method signature is correct', () {
      // Arrange
      const message = 'Error message';
      const context = 'TestContext';
      const correlationId = 'test-123';
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;

      // Act - should not throw
      expect(() => mockLogger.error(
        message,
        context: context,
        correlationId: correlationId,
        error: error,
        stackTrace: stackTrace,
      ), returnsNormally);
    });

    test('fatal method signature is correct', () {
      // Arrange
      const message = 'Fatal message';
      const context = 'TestContext';
      const correlationId = 'test-123';
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;

      // Act - should not throw
      expect(() => mockLogger.fatal(
        message,
        context: context,
        correlationId: correlationId,
        error: error,
        stackTrace: stackTrace,
      ), returnsNormally);
    });

    test('performance method signature is correct', () {
      // Arrange
      const operation = 'Test Operation';
      const duration = Duration(milliseconds: 500);
      const context = 'TestContext';
      const correlationId = 'test-123';
      const metrics = {'cpu': 80, 'memory': 512};

      // Act - should not throw
      expect(() => mockLogger.performance(
        operation,
        duration,
        context: context,
        correlationId: correlationId,
        metrics: metrics,
      ), returnsNormally);
    });

    test('userAction method signature is correct', () {
      // Arrange
      const action = 'Test Action';
      const context = 'TestContext';
      const correlationId = 'test-123';
      const properties = {'button': 'save', 'screen': 'settings'};

      // Act - should not throw
      expect(() => mockLogger.userAction(
        action,
        context: context,
        correlationId: correlationId,
        properties: properties,
      ), returnsNormally);
    });
  });
}