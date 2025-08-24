import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/core/exceptions/app_exception.dart';

void main() {
  group('AppException Tests', () {
    test('should create network exception with user message', () {
      // Act
      final exception = AppException.network(
        message: 'Connection timeout after 30 seconds',
        context: 'SupabaseRepository',
        userMessage: 'Vérifiez votre connexion internet',
      );
      
      // Assert
      expect(exception.type, equals(ErrorType.network));
      expect(exception.message, equals('Connection timeout after 30 seconds'));
      expect(exception.userMessage, equals('Vérifiez votre connexion internet'));
      expect(exception.context, equals('SupabaseRepository'));
      expect(exception.displayMessage, equals('Vérifiez votre connexion internet'));
    });
    
    test('should create authentication exception', () {
      // Act
      final exception = AppException.authentication(
        message: 'JWT token expired',
        context: 'AuthService',
      );
      
      // Assert
      expect(exception.type, equals(ErrorType.authenticationFailed));
      expect(exception.displayMessage, equals('Erreur d\'authentification'));
    });
    
    test('should create validation exception with metadata', () {
      // Act
      final exception = AppException.validation(
        message: 'Email format is invalid',
        validationErrors: {
          'email': 'Must be a valid email address',
          'password': 'Must be at least 8 characters'
        },
      );
      
      // Assert
      expect(exception.type, equals(ErrorType.validationFailure));
      expect(exception.metadata, isNotNull);
      expect(exception.metadata!['email'], equals('Must be a valid email address'));
    });
    
    test('should generate structured JSON', () {
      // Arrange
      final exception = AppException.forbidden(
        message: 'Access denied to resource',
        context: 'DocumentService',
        userMessage: 'Vous n\'avez pas les permissions nécessaires',
      );
      
      // Act
      final json = exception.toJson();
      
      // Assert
      expect(json['type'], equals('forbidden'));
      expect(json['message'], equals('Access denied to resource'));
      expect(json['userMessage'], equals('Vous n\'avez pas les permissions nécessaires'));
      expect(json['context'], equals('DocumentService'));
      expect(json['timestamp'], isA<String>());
    });
    
    test('should create full description for logging', () {
      // Arrange
      final originalError = FormatException('Invalid JSON');
      final exception = AppException(
        type: ErrorType.dataCorruption,
        message: 'Failed to parse response',
        context: 'ApiClient',
        originalError: originalError,
        metadata: {'statusCode': 500},
      );
      
      // Act
      final description = exception.fullDescription;
      
      // Assert
      expect(description, contains('[dataCorruption]'));
      expect(description, contains('Failed to parse response'));
      expect(description, contains('Context: ApiClient'));
      expect(description, contains('Original: FormatException'));
      expect(description, contains('Metadata: {statusCode: 500}'));
    });
  });
  
  group('ExceptionHandler Tests', () {
    test('should handle TimeoutException', () {
      // Arrange
      final timeout = TimeoutException('Request timed out', Duration(seconds: 30));
      
      // Act
      final appException = ExceptionHandler.handle(timeout, context: 'NetworkService');
      
      // Assert
      expect(appException.type, equals(ErrorType.timeout));
      expect(appException.userMessage, equals('L\'opération a pris trop de temps'));
      expect(appException.context, equals('NetworkService'));
      expect(appException.originalError, equals(timeout));
    });
    
    test('should handle FormatException as validation error', () {
      // Arrange
      final formatError = FormatException('Invalid number format');
      
      // Act
      final appException = ExceptionHandler.handle(formatError);
      
      // Assert
      expect(appException.type, equals(ErrorType.validationFailure));
      expect(appException.userMessage, equals('Format de données invalide'));
    });
    
    test('should detect 403 errors in message', () {
      // Arrange
      final error = Exception('HTTP 403 Forbidden: Access denied');
      
      // Act
      final appException = ExceptionHandler.handle(error);
      
      // Assert
      expect(appException.type, equals(ErrorType.forbidden));
      expect(appException.userMessage, equals('Permissions insuffisantes'));
    });
    
    test('should detect network errors in message', () {
      // Arrange
      final error = Exception('Network connection failed');
      
      // Act
      final appException = ExceptionHandler.handle(error);
      
      // Assert
      expect(appException.type, equals(ErrorType.network));
      expect(appException.userMessage, equals('Problème de connexion réseau'));
    });
    
    test('should handle unknown errors', () {
      // Arrange
      final error = StateError('Something weird happened');
      
      // Act
      final appException = ExceptionHandler.handle(error);
      
      // Assert
      expect(appException.type, equals(ErrorType.unknown));
      expect(appException.userMessage, equals('Une erreur inattendue s\'est produite'));
      expect(appException.originalError, equals(error));
    });
    
    test('should pass through existing AppException', () {
      // Arrange
      final existing = AppException.network(message: 'Already structured');
      
      // Act
      final result = ExceptionHandler.handle(existing);
      
      // Assert
      expect(identical(result, existing), isTrue);
    });
  });
}