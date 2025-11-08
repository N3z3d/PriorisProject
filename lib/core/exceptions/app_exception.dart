import 'dart:async';

/// Centralized exception handling system
/// Replaces generic Exception() with typed, structured errors

enum ErrorType {
  // Network & API errors
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  serverError,
  
  // Authentication errors
  authenticationFailed,
  tokenExpired,
  accountDisabled,
  
  // Data & persistence errors
  dataCorruption,
  storageFailure,
  syncFailure,
  duplicateId,
  
  // Business logic errors
  validationFailure,
  operationNotAllowed,
  resourceConflict,
  
  // Configuration errors
  configurationError,
  missingEnvironmentVariable,
  
  // Unknown/generic
  unknown,
}

/// Base application exception with structured error information
class AppException implements Exception {
  final ErrorType type;
  final String message;
  final String? userMessage; // User-friendly message for UI
  final String? context; // Where the error occurred
  final dynamic originalError; // Original exception if wrapped
  final StackTrace? stackTrace;
  final Map<String, dynamic>? metadata; // Additional error data
  
  const AppException({
    required this.type,
    required this.message,
    this.userMessage,
    this.context,
    this.originalError,
    this.stackTrace,
    this.metadata,
  });
  
  /// Factory for network-related errors
  factory AppException.network({
    required String message,
    String? userMessage,
    String? context,
    dynamic originalError,
    StackTrace? stackTrace,
  }) => AppException(
    type: ErrorType.network,
    message: message,
    userMessage: userMessage ?? 'Problème de connexion réseau',
    context: context,
    originalError: originalError,
    stackTrace: stackTrace,
  );
  
  /// Factory for authentication errors
  factory AppException.authentication({
    required String message,
    String? userMessage,
    String? context,
    dynamic originalError,
    StackTrace? stackTrace,
  }) => AppException(
    type: ErrorType.authenticationFailed,
    message: message,
    userMessage: userMessage ?? 'Erreur d\'authentification',
    context: context,
    originalError: originalError,
    stackTrace: stackTrace,
  );
  
  /// Factory for permission/authorization errors
  factory AppException.forbidden({
    required String message,
    String? userMessage,
    String? context,
    dynamic originalError,
    StackTrace? stackTrace,
  }) => AppException(
    type: ErrorType.forbidden,
    message: message,
    userMessage: userMessage ?? 'Permissions insuffisantes',
    context: context,
    originalError: originalError,
    stackTrace: stackTrace,
  );
  
  /// Factory for data validation errors
  factory AppException.validation({
    required String message,
    String? userMessage,
    String? context,
    Map<String, dynamic>? validationErrors,
    StackTrace? stackTrace,
  }) => AppException(
    type: ErrorType.validationFailure,
    message: message,
    userMessage: userMessage ?? 'Données invalides',
    context: context,
    stackTrace: stackTrace,
    metadata: validationErrors,
  );
  
  /// Factory for configuration errors
  factory AppException.configuration({
    required String message,
    String? userMessage,
    String? context,
    dynamic originalError,
    StackTrace? stackTrace,
  }) => AppException(
    type: ErrorType.configurationError,
    message: message,
    userMessage: userMessage ?? 'Erreur de configuration',
    context: context,
    originalError: originalError,
    stackTrace: stackTrace,
  );
  
  /// Factory for data persistence errors
  factory AppException.persistence({
    required String message,
    String? userMessage,
    String? context,
    dynamic originalError,
    StackTrace? stackTrace,
  }) => AppException(
    type: ErrorType.storageFailure,
    message: message,
    userMessage: userMessage ?? 'Erreur de sauvegarde',
    context: context,
    originalError: originalError,
    stackTrace: stackTrace,
  );
  
  /// Factory for wrapping unknown exceptions
  factory AppException.unknown({
    required dynamic originalError,
    String? message,
    String? userMessage,
    String? context,
    StackTrace? stackTrace,
  }) => AppException(
    type: ErrorType.unknown,
    message: message ?? 'Erreur inattendue: ${originalError.toString()}',
    userMessage: userMessage ?? 'Une erreur inattendue s\'est produite',
    context: context,
    originalError: originalError,
    stackTrace: stackTrace ?? StackTrace.current,
  );
  
  /// User-friendly error message for display in UI
  String get displayMessage => userMessage ?? message;
  
  /// Full error description for logging
  String get fullDescription {
    final buffer = StringBuffer();
    final typeLabel = type.name;
    buffer.writeln('[$typeLabel] $message');
    if (context != null) buffer.writeln('Context: $context');
    if (originalError != null) buffer.writeln('Original: $originalError');
    if (metadata != null && metadata!.isNotEmpty) {
      buffer.writeln('Metadata: $metadata');
    }
    return buffer.toString();
  }
  
  /// Convert to map for structured logging
  Map<String, dynamic> toJson() => {
    'type': type.name,
    'message': message,
    'userMessage': userMessage,
    'context': context,
    'originalError': originalError?.toString(),
    'metadata': metadata,
    'timestamp': DateTime.now().toIso8601String(),
  };
  
  @override
  String toString() => fullDescription;
}

/// Helper class for converting common exceptions to AppException
class ExceptionHandler {
  /// Convert any exception to structured AppException
  static AppException handle(dynamic error, {
    String? context,
    StackTrace? stackTrace,
  }) {
    if (error is AppException) return error;
    
    // Handle common exception types
    if (error is TimeoutException) {
      return AppException(
        type: ErrorType.timeout,
        message: 'Opération expirée: ${error.message}',
        userMessage: 'L\'opération a pris trop de temps',
        context: context,
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    
    if (error is FormatException) {
      return AppException.validation(
        message: 'Format invalide: ${error.message}',
        userMessage: 'Format de données invalide',
        context: context,
        stackTrace: stackTrace,
      );
    }
    
    // Handle Supabase/HTTP errors by message content
    final errorMessage = error.toString();
    
    if (errorMessage.contains('403') || errorMessage.contains('Forbidden')) {
      return AppException.forbidden(
        message: errorMessage,
        context: context,
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    
    if (errorMessage.contains('401') || errorMessage.contains('Unauthorized')) {
      return AppException.authentication(
        message: errorMessage,
        context: context,
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    
    if (errorMessage.contains('404') || errorMessage.contains('Not Found')) {
      return AppException(
        type: ErrorType.notFound,
        message: errorMessage,
        userMessage: 'Ressource non trouvée',
        context: context,
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    
    if (errorMessage.contains('network') || errorMessage.contains('connection')) {
      return AppException.network(
        message: errorMessage,
        context: context,
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    
    // Default: unknown error
    return AppException.unknown(
      originalError: error,
      context: context,
      stackTrace: stackTrace,
    );
  }
}
