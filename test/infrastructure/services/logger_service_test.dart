import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:logger/logger.dart';

import '../../../lib/infrastructure/services/logger_service.dart';

@GenerateMocks([Logger])
import 'logger_service_test.mocks.dart';

void main() {
  group('LoggerService Tests', () {
    late LoggerService loggerService;
    late MockLogger mockLogger;

    setUp(() {
      mockLogger = MockLogger();
      loggerService = LoggerService.testing(mockLogger);
    });

    test('should log debug messages with context', () {
      // Arrange
      const message = 'Debug test message';
      const context = 'TestContext';
      
      // Act
      loggerService.debug(message, context: context);
      
      // Assert
      verify(mockLogger.d('[TestContext] Debug test message')).called(1);
    });

    test('should log info messages with context', () {
      // Arrange
      const message = 'Info test message';
      const context = 'TestContext';
      
      // Act
      loggerService.info(message, context: context);
      
      // Assert
      verify(mockLogger.i('[TestContext] Info test message')).called(1);
    });

    test('should log warning messages with context', () {
      // Arrange
      const message = 'Warning test message';
      const context = 'TestContext';
      
      // Act
      loggerService.warning(message, context: context);
      
      // Assert
      verify(mockLogger.w('[TestContext] Warning test message')).called(1);
    });

    test('should log error messages with context and error object', () {
      // Arrange
      const message = 'Error test message';
      const context = 'TestContext';
      final error = Exception('Test error');
      
      // Act
      loggerService.error(message, context: context, error: error);
      
      // Assert
      verify(mockLogger.e('[TestContext] Error test message', error: error, stackTrace: null)).called(1);
    });

    test('should handle correlation IDs', () {
      // Arrange
      const message = 'Test with correlation';
      const context = 'TestContext';
      const correlationId = 'test-123';
      
      // Act
      loggerService.debug(message, context: context, correlationId: correlationId);
      
      // Assert
      verify(mockLogger.d('[TestContext][test-123] Test with correlation')).called(1);
    });

    test('should sanitize sensitive data', () {
      // Arrange
      const message = 'API call with key: secret_key_123';
      const context = 'AuthService';
      
      // Act
      loggerService.info(message, context: context);
      
      // Assert
      verify(mockLogger.i('[AuthService] API call with key: ***SANITIZED***')).called(1);
    });
  });
}