import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/services/persistence/services/persistence_error_handler.dart';

void main() {
  group('PersistenceErrorHandler', () {
    late PersistenceErrorHandler errorHandler;

    setUp(() {
      errorHandler = PersistenceErrorHandler();
    });

    group('Error Message Sanitization', () {
      test('should sanitize JWT expired errors', () {
        const error = 'JWT expired: token has expired';
        final result = errorHandler.sanitizeErrorMessage(error);
        expect(result, equals('Session expirée. Veuillez vous reconnecter.'));
      });

      test('should sanitize permission denied errors', () {
        const error = '403 Forbidden: permission denied';
        final result = errorHandler.sanitizeErrorMessage(error);
        expect(result, equals('Permissions insuffisantes pour cette opération.'));
      });

      test('should sanitize network errors', () {
        const error = 'Network error: connection timeout';
        final result = errorHandler.sanitizeErrorMessage(error);
        expect(result, equals('Problème de connexion. Vérifiez votre connexion internet.'));
      });

      test('should sanitize temporary server errors', () {
        const error = '503 Service Unavailable';
        final result = errorHandler.sanitizeErrorMessage(error);
        expect(result, equals('Service temporairement indisponible. Réessayez dans quelques instants.'));
      });

      test('should sanitize database errors', () {
        const error = 'PostgrestException: database connection failed';
        final result = errorHandler.sanitizeErrorMessage(error);
        expect(result, equals('Problème de synchronisation des données. Réessayez plus tard.'));
      });

      test('should provide fallback for unknown errors', () {
        const error = 'Unknown mysterious error';
        final result = errorHandler.sanitizeErrorMessage(error);
        expect(result, equals('Erreur temporaire. Vos données locales sont préservées.'));
      });
    });

    group('Error Classification', () {
      test('should identify recoverable network errors', () {
        const error = 'Network error: connection timeout';
        final isRecoverable = errorHandler.isRecoverableError(error);
        expect(isRecoverable, isTrue);
      });

      test('should identify recoverable temporary errors', () {
        const error = '503 Service Unavailable';
        final isRecoverable = errorHandler.isRecoverableError(error);
        expect(isRecoverable, isTrue);
      });

      test('should identify recoverable rate limit errors', () {
        const error = 'Rate limit exceeded: too many requests';
        final isRecoverable = errorHandler.isRecoverableError(error);
        expect(isRecoverable, isTrue);
      });

      test('should identify non-recoverable permission errors', () {
        const error = '403 Forbidden: permission denied';
        final isRecoverable = errorHandler.isRecoverableError(error);
        expect(isRecoverable, isFalse);
      });

      test('should identify non-recoverable authentication errors', () {
        const error = 'Authentication failed: invalid credentials';
        final isRecoverable = errorHandler.isRecoverableError(error);
        expect(isRecoverable, isFalse);
      });

      test('should default to recoverable for unknown errors', () {
        const error = 'Unknown error type';
        final isRecoverable = errorHandler.isRecoverableError(error);
        expect(isRecoverable, isTrue);
      });
    });

    group('User-Friendly Messages', () {
      test('should provide helpful context for network errors', () {
        const error = 'Network error: DNS resolution failed';
        final message = errorHandler.getUserFriendlyMessage(error);
        expect(message, contains('Vos modifications sont sauvegardées localement'));
        expect(message, contains('synchronisées automatiquement'));
      });

      test('should provide helpful context for permission errors', () {
        const error = '403 Forbidden: access denied';
        final message = errorHandler.getUserFriendlyMessage(error);
        expect(message, contains('Vos données locales restent intactes'));
        expect(message, contains('Contactez le support'));
      });

      test('should provide helpful context for temporary errors', () {
        const error = '502 Bad Gateway';
        final message = errorHandler.getUserFriendlyMessage(error);
        expect(message, contains('généralement temporaire'));
        expect(message, contains('Vos données locales sont sécurisées'));
      });

      test('should provide fallback context for unknown errors', () {
        const error = 'Unknown error';
        final message = errorHandler.getUserFriendlyMessage(error);
        expect(message, contains('Vos données locales sont préservées'));
      });
    });

    group('Cloud Permission Error Handling', () {
      test('should handle permission errors gracefully', () {
        // Should not throw exception
        expect(
          () => errorHandler.handleCloudPermissionError(
            'saveList',
            'test-id',
            '403 Forbidden: permission denied',
          ),
          returnsNormally,
        );
      });

      test('should handle network errors gracefully', () {
        // Should not throw exception
        expect(
          () => errorHandler.handleCloudPermissionError(
            'getAllLists',
            'all',
            'Network error: connection timeout',
          ),
          returnsNormally,
        );
      });

      test('should handle temporary errors gracefully', () {
        // Should not throw exception
        expect(
          () => errorHandler.handleCloudPermissionError(
            'updateItem',
            'item-id',
            '503 Service Unavailable',
          ),
          returnsNormally,
        );
      });

      test('should handle generic cloud errors gracefully', () {
        // Should not throw exception
        expect(
          () => errorHandler.handleCloudPermissionError(
            'deleteList',
            'list-id',
            'Unknown cloud error',
          ),
          returnsNormally,
        );
      });
    });

    group('Error Logging', () {
      test('should log permission errors without throwing', () {
        // Should not throw exception
        expect(
          () => errorHandler.logPermissionError(
            'saveList',
            'test-id',
            '403 Forbidden: permission denied',
          ),
          returnsNormally,
        );
      });

      test('should log network errors without throwing', () {
        // Should not throw exception
        expect(
          () => errorHandler.logPermissionError(
            'getAllLists',
            'all',
            'Network error: connection timeout',
          ),
          returnsNormally,
        );
      });

      test('should log generic errors without throwing', () {
        // Should not throw exception
        expect(
          () => errorHandler.logPermissionError(
            'updateItem',
            'item-id',
            'Generic error message',
          ),
          returnsNormally,
        );
      });
    });

    group('Edge Cases', () {
      test('should handle null/empty error messages', () {
        final result1 = errorHandler.sanitizeErrorMessage('');
        final result2 = errorHandler.sanitizeErrorMessage('   ');

        expect(result1, isNotEmpty);
        expect(result2, isNotEmpty);
      });

      test('should handle very long error messages', () {
        final longError = 'Error: ' + 'x' * 1000;
        final result = errorHandler.sanitizeErrorMessage(longError);

        expect(result, isNotEmpty);
        expect(result.length, lessThan(longError.length));
      });

      test('should handle mixed case error patterns', () {
        final mixedCaseError = 'JWT EXPIRED: TOKEN HAS EXPIRED';
        final result = errorHandler.sanitizeErrorMessage(mixedCaseError);

        expect(result, equals('Session expirée. Veuillez vous reconnecter.'));
      });

      test('should handle complex error with multiple patterns', () {
        final complexError = 'Network error: 403 Forbidden - JWT expired';
        final result = errorHandler.sanitizeErrorMessage(complexError);

        // Should match the first pattern it finds
        expect(result, isNotEmpty);
        expect(result, isNot(equals(complexError)));
      });
    });

    group('Error Pattern Matching', () {
      final permissionPatterns = [
        '403 Forbidden',
        'permission denied',
        'Row Level Security',
        'JWT expired',
        'Unauthorized',
        'Access denied',
        'Authentication failed',
        'Token expired',
        'Invalid credentials',
      ];

      final networkPatterns = [
        'Network error',
        'Connection timeout',
        'No internet connection',
        'Server unreachable',
        'DNS resolution failed',
        'Connection refused',
        'Socket exception',
      ];

      final temporaryPatterns = [
        'Service temporarily unavailable',
        'Rate limit exceeded',
        'Server busy',
        'Temporary failure',
        'Retry later',
        '503 Service Unavailable',
        '502 Bad Gateway',
        '504 Gateway Timeout',
      ];

      for (final pattern in permissionPatterns) {
        test('should recognize permission pattern: $pattern', () {
          final result = errorHandler.sanitizeErrorMessage(pattern);
          expect(result, isNot(equals('Erreur temporaire. Vos données locales sont préservées.')));
        });
      }

      for (final pattern in networkPatterns) {
        test('should recognize network pattern: $pattern', () {
          final result = errorHandler.sanitizeErrorMessage(pattern);
          expect(result, contains('connexion'));
        });
      }

      for (final pattern in temporaryPatterns) {
        test('should recognize temporary pattern: $pattern', () {
          final result = errorHandler.sanitizeErrorMessage(pattern);
          expect(result, contains('temporaire'));
        });
      }
    });
  });
}