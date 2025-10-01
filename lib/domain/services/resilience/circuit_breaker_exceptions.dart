/// Exception thrown when circuit breaker is in open state
class CircuitBreakerOpenException implements Exception {
  final String message;
  final String serviceName;
  final DateTime timestamp;
  final Duration estimatedRecoveryTime;

  const CircuitBreakerOpenException({
    required this.message,
    required this.serviceName,
    required this.timestamp,
    required this.estimatedRecoveryTime,
  });

  @override
  String toString() => 'CircuitBreakerOpenException: $message (Service: $serviceName)';
}

/// Exception thrown when operation exceeds timeout
class CircuitBreakerTimeoutException implements Exception {
  final String message;
  final String serviceName;
  final Duration timeout;
  final Duration actualDuration;

  const CircuitBreakerTimeoutException({
    required this.message,
    required this.serviceName,
    required this.timeout,
    required this.actualDuration,
  });

  @override
  String toString() => 'CircuitBreakerTimeoutException: $message '
      '(Timeout: $timeout, Actual: $actualDuration)';
}

/// Exception thrown when maximum retries are exceeded
class MaxRetriesExceededException implements Exception {
  final String message;
  final String serviceName;
  final int maxRetries;
  final List<Exception> attemptErrors;

  const MaxRetriesExceededException({
    required this.message,
    required this.serviceName,
    required this.maxRetries,
    required this.attemptErrors,
  });

  @override
  String toString() => 'MaxRetriesExceededException: $message '
      '(Max retries: $maxRetries, Errors: ${attemptErrors.length})';
}

/// Exception thrown when circuit breaker configuration is invalid
class CircuitBreakerConfigurationException implements Exception {
  final String message;
  final String parameter;

  const CircuitBreakerConfigurationException({
    required this.message,
    required this.parameter,
  });

  @override
  String toString() => 'CircuitBreakerConfigurationException: $message (Parameter: $parameter)';
}

/// Exception wrapper for fallback execution failures
class FallbackExecutionException implements Exception {
  final String message;
  final Exception originalException;
  final Exception fallbackException;

  const FallbackExecutionException({
    required this.message,
    required this.originalException,
    required this.fallbackException,
  });

  @override
  String toString() => 'FallbackExecutionException: $message '
      '(Original: $originalException, Fallback: $fallbackException)';
}