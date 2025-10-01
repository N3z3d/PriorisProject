/// SOLID-compliant error handling service implementation
/// Responsibility: Centralized error handling and recovery only

import 'dart:async';
import 'package:prioris/core/interfaces/lists_interfaces.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';

/// Error severity levels
enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

/// Error categories for better handling
enum ErrorCategory {
  persistence,
  network,
  validation,
  authorization,
  business,
  system,
  unknown,
}

/// Error context for detailed error information
class ErrorContext {
  final String operation;
  final String? entityId;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  ErrorContext({
    required this.operation,
    this.entityId,
    this.metadata,
  }) : timestamp = DateTime.now();
}

/// Concrete implementation of IListsErrorHandler following SRP
/// Provides centralized error handling, recovery, and monitoring
class ListsErrorHandler implements IListsErrorHandler {
  static const int _maxRetryAttempts = 3;
  static const Duration _retryDelay = Duration(seconds: 1);

  final Map<ErrorCategory, List<String>> _errorPatterns = {
    ErrorCategory.persistence: [
      'persistence',
      'database',
      'storage',
      'repository',
      'save',
      'delete',
      'update',
    ],
    ErrorCategory.network: [
      'network',
      'connection',
      'timeout',
      'unreachable',
      'offline',
      'http',
    ],
    ErrorCategory.validation: [
      'validation',
      'invalid',
      'required',
      'format',
      'constraint',
    ],
    ErrorCategory.authorization: [
      'authorization',
      'permission',
      'forbidden',
      'unauthorized',
      'rls',
      'jwt',
    ],
    ErrorCategory.business: [
      'business',
      'rule',
      'logic',
      'duplicate',
      'conflict',
    ],
  };

  ListsErrorHandler() {
    LoggerService.instance.debug(
      'ListsErrorHandler initialized',
      context: 'ListsErrorHandler',
    );
  }

  @override
  void handleError(dynamic error, String context) {
    try {
      final errorCategory = _categorizeError(error);
      final severity = _determineSeverity(error, errorCategory);
      final userMessage = getUserFriendlyMessage(error);

      LoggerService.instance.error(
        'Error handled in $context',
        context: 'ListsErrorHandler',
        error: error,
      );

      // Log structured error information
      _logStructuredError(error, context, errorCategory, severity);

      // Handle based on severity
      _handleBySeverity(error, context, severity);

    } catch (handlingError) {
      // Prevent error handling from causing more errors
      LoggerService.instance.error(
        'Error in error handling for context: $context',
        context: 'ListsErrorHandler',
        error: handlingError,
      );
    }
  }

  @override
  Future<T?> handleErrorWithRecovery<T>(
    dynamic error,
    String context,
    Future<T> Function()? recovery,
  ) async {
    handleError(error, context);

    if (recovery == null || !isRecoverableError(error)) {
      LoggerService.instance.warning(
        'No recovery strategy available for error in $context',
        context: 'ListsErrorHandler',
      );
      return null;
    }

    try {
      LoggerService.instance.info(
        'Attempting recovery for error in $context',
        context: 'ListsErrorHandler',
      );

      final result = await _executeWithRetry(() => recovery());

      LoggerService.instance.info(
        'Recovery successful for error in $context',
        context: 'ListsErrorHandler',
      );

      return result;
    } catch (recoveryError) {
      LoggerService.instance.error(
        'Recovery failed for error in $context',
        context: 'ListsErrorHandler',
        error: recoveryError,
      );
      return null;
    }
  }

  @override
  bool isRecoverableError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Network errors are usually recoverable
    if (_containsPattern(errorString, _errorPatterns[ErrorCategory.network]!)) {
      return true;
    }

    // Some persistence errors are recoverable
    if (_containsPattern(errorString, ['timeout', 'connection', 'temporary'])) {
      return true;
    }

    // Authorization errors might be recoverable with refresh
    if (_containsPattern(errorString, ['jwt expired', 'token expired'])) {
      return true;
    }

    // Validation and business logic errors are usually not recoverable
    if (_containsPattern(errorString, _errorPatterns[ErrorCategory.validation]!) ||
        _containsPattern(errorString, _errorPatterns[ErrorCategory.business]!)) {
      return false;
    }

    // By default, consider errors as potentially recoverable
    return true;
  }

  @override
  String getUserFriendlyMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Network-related errors
    if (_containsPattern(errorString, ['network', 'connection', 'unreachable'])) {
      return 'Une erreur de connexion est survenue. Vérifiez votre connexion internet.';
    }

    if (_containsPattern(errorString, ['timeout'])) {
      return 'L\'opération a pris trop de temps. Veuillez réessayer.';
    }

    // Authorization errors
    if (_containsPattern(errorString, ['permission', 'forbidden', 'unauthorized'])) {
      return 'Vous n\'avez pas les permissions nécessaires pour cette action.';
    }

    if (_containsPattern(errorString, ['jwt expired', 'token expired'])) {
      return 'Votre session a expiré. Veuillez vous reconnecter.';
    }

    // Validation errors
    if (_containsPattern(errorString, ['validation', 'invalid', 'required'])) {
      return 'Les données saisies ne sont pas valides. Veuillez vérifier et réessayer.';
    }

    // Persistence errors
    if (_containsPattern(errorString, ['duplicate', 'already exists'])) {
      return 'Cet élément existe déjà.';
    }

    if (_containsPattern(errorString, ['not found', 'does not exist'])) {
      return 'L\'élément demandé n\'a pas été trouvé.';
    }

    // Storage errors
    if (_containsPattern(errorString, ['storage', 'disk', 'space'])) {
      return 'Erreur de stockage. Vérifiez l\'espace disponible.';
    }

    // Generic error message
    return 'Une erreur inattendue s\'est produite. Veuillez réessayer.';
  }

  @override
  void logError(dynamic error, String context, StackTrace? stackTrace) {
    try {
      final errorCategory = _categorizeError(error);
      final severity = _determineSeverity(error, errorCategory);

      LoggerService.instance.error(
        'Error logged from $context',
        context: 'ListsErrorHandler',
        error: error,
      );

      // Additional structured logging could be added here
      // for external monitoring services like Crashlytics, Sentry, etc.
      _logToExternalServices(error, context, stackTrace, errorCategory, severity);

    } catch (loggingError) {
      // Prevent logging errors from causing cascading failures
      print('Failed to log error: $loggingError');
    }
  }

  /// Executes operation with retry logic
  Future<T> _executeWithRetry<T>(Future<T> Function() operation) async {
    int attempts = 0;
    dynamic lastError;

    while (attempts < _maxRetryAttempts) {
      try {
        return await operation();
      } catch (error) {
        lastError = error;
        attempts++;

        if (attempts < _maxRetryAttempts && isRecoverableError(error)) {
          LoggerService.instance.debug(
            'Retry attempt $attempts/$_maxRetryAttempts',
            context: 'ListsErrorHandler',
          );

          await Future.delayed(_retryDelay * attempts); // Exponential backoff
        } else {
          break;
        }
      }
    }

    throw lastError;
  }

  /// Categorizes error based on content analysis
  ErrorCategory _categorizeError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    for (final category in _errorPatterns.keys) {
      if (_containsPattern(errorString, _errorPatterns[category]!)) {
        return category;
      }
    }

    return ErrorCategory.unknown;
  }

  /// Determines error severity
  ErrorSeverity _determineSeverity(dynamic error, ErrorCategory category) {
    final errorString = error.toString().toLowerCase();

    // Critical errors
    if (_containsPattern(errorString, ['critical', 'fatal', 'corruption'])) {
      return ErrorSeverity.critical;
    }

    // High severity errors
    if (category == ErrorCategory.authorization ||
        _containsPattern(errorString, ['security', 'breach', 'unauthorized'])) {
      return ErrorSeverity.high;
    }

    // Medium severity errors
    if (category == ErrorCategory.persistence ||
        category == ErrorCategory.business ||
        _containsPattern(errorString, ['data loss', 'conflict'])) {
      return ErrorSeverity.medium;
    }

    // Low severity errors (validation, network timeouts, etc.)
    return ErrorSeverity.low;
  }

  /// Handles error based on severity level
  void _handleBySeverity(dynamic error, String context, ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.critical:
        _handleCriticalError(error, context);
        break;
      case ErrorSeverity.high:
        _handleHighSeverityError(error, context);
        break;
      case ErrorSeverity.medium:
        _handleMediumSeverityError(error, context);
        break;
      case ErrorSeverity.low:
        _handleLowSeverityError(error, context);
        break;
    }
  }

  /// Handles critical errors
  void _handleCriticalError(dynamic error, String context) {
    // In a real app, this might:
    // - Send immediate alerts to development team
    // - Trigger emergency procedures
    // - Create crash reports
    LoggerService.instance.error(
      'CRITICAL ERROR in $context',
      context: 'ListsErrorHandler',
      error: error,
    );
  }

  /// Handles high severity errors
  void _handleHighSeverityError(dynamic error, String context) {
    // In a real app, this might:
    // - Log to security monitoring
    // - Alert administrators
    // - Trigger security protocols
    LoggerService.instance.error(
      'HIGH SEVERITY ERROR in $context',
      context: 'ListsErrorHandler',
      error: error,
    );
  }

  /// Handles medium severity errors
  void _handleMediumSeverityError(dynamic error, String context) {
    // Standard error logging and monitoring
    LoggerService.instance.error(
      'Medium severity error in $context',
      context: 'ListsErrorHandler',
      error: error,
    );
  }

  /// Handles low severity errors
  void _handleLowSeverityError(dynamic error, String context) {
    // Minimal logging for low severity errors
    LoggerService.instance.warning(
      'Low severity error in $context: ${error.toString()}',
      context: 'ListsErrorHandler',
    );
  }

  /// Logs structured error information
  void _logStructuredError(
    dynamic error,
    String context,
    ErrorCategory category,
    ErrorSeverity severity,
  ) {
    final structuredLog = {
      'timestamp': DateTime.now().toIso8601String(),
      'context': context,
      'category': category.toString(),
      'severity': severity.toString(),
      'error': error.toString(),
      'userAgent': 'Flutter App', // In a real app, get actual user agent
    };

    LoggerService.instance.debug(
      'Structured error log: $structuredLog',
      context: 'ListsErrorHandler',
    );
  }

  /// Logs to external monitoring services
  void _logToExternalServices(
    dynamic error,
    String context,
    StackTrace? stackTrace,
    ErrorCategory category,
    ErrorSeverity severity,
  ) {
    // In a real application, this would integrate with:
    // - Firebase Crashlytics
    // - Sentry
    // - Bugsnag
    // - Custom monitoring endpoints

    LoggerService.instance.info(
      'Would log to external services: $category/$severity in $context',
      context: 'ListsErrorHandler',
    );
  }

  /// Checks if error string contains any of the patterns
  bool _containsPattern(String errorString, List<String> patterns) {
    return patterns.any((pattern) => errorString.contains(pattern.toLowerCase()));
  }
}