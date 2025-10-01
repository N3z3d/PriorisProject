/// Configuration for Circuit Breaker behavior
class CircuitBreakerConfig {
  /// Number of consecutive failures required to open the circuit
  final int failureThreshold;

  /// Maximum time to wait for an operation to complete
  final Duration timeoutDuration;

  /// Time to wait in open state before attempting recovery
  final Duration recoveryTimeout;

  /// Maximum number of retry attempts
  final int maxRetries;

  /// Multiplier for exponential backoff between retries
  final double backoffMultiplier;

  /// Initial delay for first retry
  final Duration initialRetryDelay;

  /// Maximum delay between retries
  final Duration maxRetryDelay;

  /// Sample window size for metrics calculation
  final int sampleWindowSize;

  /// Minimum requests in window before making state decisions
  final int minimumRequestsInWindow;

  /// Success threshold percentage to close from half-open state
  final double successThresholdPercentage;

  const CircuitBreakerConfig({
    this.failureThreshold = 5,
    this.timeoutDuration = const Duration(seconds: 10),
    this.recoveryTimeout = const Duration(seconds: 60),
    this.maxRetries = 3,
    this.backoffMultiplier = 2.0,
    this.initialRetryDelay = const Duration(milliseconds: 100),
    this.maxRetryDelay = const Duration(seconds: 30),
    this.sampleWindowSize = 100,
    this.minimumRequestsInWindow = 10,
    this.successThresholdPercentage = 0.5,
  });

  /// Creates a configuration optimized for fast services
  factory CircuitBreakerConfig.fastService() {
    return const CircuitBreakerConfig(
      failureThreshold: 3,
      timeoutDuration: Duration(seconds: 2),
      recoveryTimeout: Duration(seconds: 30),
      maxRetries: 2,
      initialRetryDelay: Duration(milliseconds: 50),
    );
  }

  /// Creates a configuration optimized for slow/external services
  factory CircuitBreakerConfig.slowService() {
    return const CircuitBreakerConfig(
      failureThreshold: 10,
      timeoutDuration: Duration(seconds: 30),
      recoveryTimeout: Duration(minutes: 2),
      maxRetries: 5,
      backoffMultiplier: 1.5,
      initialRetryDelay: Duration(seconds: 1),
    );
  }

  /// Creates a configuration for critical services requiring high availability
  factory CircuitBreakerConfig.criticalService() {
    return const CircuitBreakerConfig(
      failureThreshold: 2,
      timeoutDuration: Duration(seconds: 5),
      recoveryTimeout: Duration(seconds: 15),
      maxRetries: 1,
      successThresholdPercentage: 0.8, // Higher success threshold
    );
  }

  /// Copy configuration with overrides
  CircuitBreakerConfig copyWith({
    int? failureThreshold,
    Duration? timeoutDuration,
    Duration? recoveryTimeout,
    int? maxRetries,
    double? backoffMultiplier,
    Duration? initialRetryDelay,
    Duration? maxRetryDelay,
    int? sampleWindowSize,
    int? minimumRequestsInWindow,
    double? successThresholdPercentage,
  }) {
    return CircuitBreakerConfig(
      failureThreshold: failureThreshold ?? this.failureThreshold,
      timeoutDuration: timeoutDuration ?? this.timeoutDuration,
      recoveryTimeout: recoveryTimeout ?? this.recoveryTimeout,
      maxRetries: maxRetries ?? this.maxRetries,
      backoffMultiplier: backoffMultiplier ?? this.backoffMultiplier,
      initialRetryDelay: initialRetryDelay ?? this.initialRetryDelay,
      maxRetryDelay: maxRetryDelay ?? this.maxRetryDelay,
      sampleWindowSize: sampleWindowSize ?? this.sampleWindowSize,
      minimumRequestsInWindow: minimumRequestsInWindow ?? this.minimumRequestsInWindow,
      successThresholdPercentage: successThresholdPercentage ?? this.successThresholdPercentage,
    );
  }

  /// Validates configuration values
  bool get isValid {
    return failureThreshold > 0 &&
        timeoutDuration.inMilliseconds > 0 &&
        recoveryTimeout.inMilliseconds > 0 &&
        maxRetries >= 0 &&
        backoffMultiplier > 0 &&
        initialRetryDelay.inMilliseconds >= 0 &&
        maxRetryDelay > initialRetryDelay &&
        sampleWindowSize > 0 &&
        minimumRequestsInWindow >= 0 &&
        successThresholdPercentage >= 0.0 &&
        successThresholdPercentage <= 1.0;
  }

  @override
  String toString() {
    return 'CircuitBreakerConfig('
        'failureThreshold: $failureThreshold, '
        'timeoutDuration: $timeoutDuration, '
        'recoveryTimeout: $recoveryTimeout, '
        'maxRetries: $maxRetries'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CircuitBreakerConfig &&
        other.failureThreshold == failureThreshold &&
        other.timeoutDuration == timeoutDuration &&
        other.recoveryTimeout == recoveryTimeout &&
        other.maxRetries == maxRetries &&
        other.backoffMultiplier == backoffMultiplier &&
        other.initialRetryDelay == initialRetryDelay &&
        other.maxRetryDelay == maxRetryDelay &&
        other.sampleWindowSize == sampleWindowSize &&
        other.minimumRequestsInWindow == minimumRequestsInWindow &&
        other.successThresholdPercentage == successThresholdPercentage;
  }

  @override
  int get hashCode {
    return Object.hash(
      failureThreshold,
      timeoutDuration,
      recoveryTimeout,
      maxRetries,
      backoffMultiplier,
      initialRetryDelay,
      maxRetryDelay,
      sampleWindowSize,
      minimumRequestsInWindow,
      successThresholdPercentage,
    );
  }
}