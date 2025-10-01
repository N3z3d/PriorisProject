import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:logger/logger.dart';
import 'package:prioris/infrastructure/services/logger_adapter.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';

/// Mock du LoggerService pour isoler les tests
class MockLoggerService extends Mock implements LoggerService {}

void main() {
  group('LoggerAdapter Tests', () {
    late MockLoggerService mockLoggerService;
    late LoggerAdapter loggerAdapter;

    setUp(() {
      mockLoggerService = MockLoggerService();
      loggerAdapter = LoggerAdapter(mockLoggerService);
    });

    test('implements ILogger interface', () {
      expect(loggerAdapter, isA<ILogger>());
    });

    group('debug method', () {
      test('calls LoggerService.debug with correct parameters', () {
        // Arrange
        const message = 'Debug message';
        const context = 'TestContext';
        const correlationId = 'test-123';
        const data = {'test': 'data'};

        // Act
        loggerAdapter.debug(
          message,
          context: context,
          correlationId: correlationId,
          data: data,
        );

        // Assert
        verify(mockLoggerService.debug(
          message,
          context: context,
          correlationId: correlationId,
          data: data,
        )).called(1);
      });

      test('calls LoggerService.debug with minimal parameters', () {
        // Arrange
        const message = 'Debug message';

        // Act
        loggerAdapter.debug(message);

        // Assert
        verify(mockLoggerService.debug(
          message,
          context: null,
          correlationId: null,
          data: null,
        )).called(1);
      });
    });

    group('info method', () {
      test('calls LoggerService.info with correct parameters', () {
        // Arrange
        const message = 'Info message';
        const context = 'TestContext';
        const correlationId = 'test-123';
        const data = {'test': 'data'};

        // Act
        loggerAdapter.info(
          message,
          context: context,
          correlationId: correlationId,
          data: data,
        );

        // Assert
        verify(mockLoggerService.info(
          message,
          context: context,
          correlationId: correlationId,
          data: data,
        )).called(1);
      });
    });

    group('warning method', () {
      test('calls LoggerService.warning with correct parameters', () {
        // Arrange
        const message = 'Warning message';
        const context = 'TestContext';
        const correlationId = 'test-123';
        const data = {'test': 'data'};

        // Act
        loggerAdapter.warning(
          message,
          context: context,
          correlationId: correlationId,
          data: data,
        );

        // Assert
        verify(mockLoggerService.warning(
          message,
          context: context,
          correlationId: correlationId,
          data: data,
        )).called(1);
      });
    });

    group('error method', () {
      test('calls LoggerService.error with correct parameters', () {
        // Arrange
        const message = 'Error message';
        const context = 'TestContext';
        const correlationId = 'test-123';
        final error = Exception('Test error');
        final stackTrace = StackTrace.current;

        // Act
        loggerAdapter.error(
          message,
          context: context,
          correlationId: correlationId,
          error: error,
          stackTrace: stackTrace,
        );

        // Assert
        verify(mockLoggerService.error(
          message,
          context: context,
          correlationId: correlationId,
          error: error,
          stackTrace: stackTrace,
        )).called(1);
      });
    });

    group('fatal method', () {
      test('calls LoggerService.fatal with correct parameters', () {
        // Arrange
        const message = 'Fatal message';
        const context = 'TestContext';
        const correlationId = 'test-123';
        final error = Exception('Test error');
        final stackTrace = StackTrace.current;

        // Act
        loggerAdapter.fatal(
          message,
          context: context,
          correlationId: correlationId,
          error: error,
          stackTrace: stackTrace,
        );

        // Assert
        verify(mockLoggerService.fatal(
          message,
          context: context,
          correlationId: correlationId,
          error: error,
          stackTrace: stackTrace,
        )).called(1);
      });
    });

    group('performance method', () {
      test('calls LoggerService.performance with correct parameters', () {
        // Arrange
        const operation = 'Test Operation';
        const duration = Duration(milliseconds: 500);
        const context = 'TestContext';
        const correlationId = 'test-123';
        const metrics = {'cpu': 80, 'memory': 512};

        // Act
        loggerAdapter.performance(
          operation,
          duration,
          context: context,
          correlationId: correlationId,
          metrics: metrics,
        );

        // Assert
        verify(mockLoggerService.performance(
          operation,
          duration,
          context: context,
          correlationId: correlationId,
          metrics: metrics,
        )).called(1);
      });
    });

    group('userAction method', () {
      test('calls LoggerService.userAction with correct parameters', () {
        // Arrange
        const action = 'Test Action';
        const context = 'TestContext';
        const correlationId = 'test-123';
        const properties = {'button': 'save', 'screen': 'settings'};

        // Act
        loggerAdapter.userAction(
          action,
          context: context,
          correlationId: correlationId,
          properties: properties,
        );

        // Assert
        verify(mockLoggerService.userAction(
          action,
          context: context,
          correlationId: correlationId,
          properties: properties,
        )).called(1);
      });
    });

    group('defaultInstance factory', () {
      test('creates adapter with singleton LoggerService instance', () {
        // Act
        final adapter = LoggerAdapter.defaultInstance();

        // Assert
        expect(adapter, isA<LoggerAdapter>());
        expect(adapter, isA<ILogger>());
      });
    });
  });
}