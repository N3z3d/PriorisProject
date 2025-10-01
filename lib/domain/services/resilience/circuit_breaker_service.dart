import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

import 'circuit_breaker_config.dart';
import 'circuit_breaker_state.dart';
import 'circuit_breaker_metrics.dart';
import 'circuit_breaker_exceptions.dart';

/// High-performance Circuit Breaker implementation with advanced resilience patterns
///
/// Provides:
/// - Fail-fast behavior to prevent cascading failures
/// - Automatic recovery with exponential backoff
/// - Comprehensive metrics and monitoring
/// - Configurable retry mechanisms
/// - Fallback execution support
/// - Thread-safe concurrent operations
class CircuitBreakerService {
  final String serviceName;
  CircuitBreakerConfig _config;
  CircuitBreakerState _state = CircuitBreakerState.closed;

  final MetricsCollector _metricsCollector;
  DateTime? _lastFailureTime;
  DateTime? _stateTransitionTime;
  int _consecutiveFailures = 0;
  bool _halfOpenCallInProgress = false;

  // Performance optimization: pre-allocate timers
  Timer? _recoveryTimer;
  final Completer<void>? _recoveryCompleter = null;

  CircuitBreakerService(
    this._config, {
    this.serviceName = 'unnamed-service',
  }) : _metricsCollector = MetricsCollector(serviceName) {

    if (!_config.isValid) {
      throw CircuitBreakerConfigurationException(
        message: 'Invalid circuit breaker configuration',
        parameter: 'config',
      );
    }

    _stateTransitionTime = DateTime.now();

    if (kDebugMode) {
      print('🔧 Circuit Breaker initialized for $serviceName: $_config');
    }
  }

  /// Current state of the circuit breaker
  CircuitBreakerState get state => _state;

  /// Current failure count
  int get failureCount => _consecutiveFailures;

  /// Whether the circuit is operational
  bool get isOperational => _state.isOperational;

  /// Current configuration
  CircuitBreakerConfig get configuration => _config;

  /// Executes an operation through the circuit breaker with full resilience
  Future<T> execute<T>(Future<T> Function() operation) async {
    // Fast path: check if request should be rejected immediately
    if (_state == CircuitBreakerState.open) {
      _metricsCollector.recordCircuitOpen();
      throw CircuitBreakerOpenException(
        message: 'Circuit breaker is open for service $serviceName',
        serviceName: serviceName,
        timestamp: DateTime.now(),
        estimatedRecoveryTime: _getEstimatedRecoveryTime(),
      );
    }

    // Half-open state: only allow one request at a time
    if (_state == CircuitBreakerState.halfOpen && _halfOpenCallInProgress) {
      _metricsCollector.recordCircuitOpen();
      throw CircuitBreakerOpenException(
        message: 'Circuit breaker is testing recovery for service $serviceName',
        serviceName: serviceName,
        timestamp: DateTime.now(),
        estimatedRecoveryTime: Duration(seconds: 5),
      );
    }

    if (_state == CircuitBreakerState.halfOpen) {
      _halfOpenCallInProgress = true;
    }

    return await _executeWithRetry(operation);
  }

  /// Executes operation with fallback when circuit is open
  Future<T> executeWithFallback<T>(
    Future<T> Function() primaryOperation,
    Future<T> Function() fallbackOperation,
  ) async {
    try {
      return await execute(primaryOperation);
    } on CircuitBreakerOpenException {
      // Circuit is open, execute fallback
      if (kDebugMode) {
        print('⚡ Circuit breaker open for $serviceName, executing fallback');
      }

      try {
        return await fallbackOperation();
      } catch (fallbackError) {
        throw FallbackExecutionException(
          message: 'Both primary and fallback operations failed',
          originalException: CircuitBreakerOpenException(
            message: 'Circuit open',
            serviceName: serviceName,
            timestamp: DateTime.now(),
            estimatedRecoveryTime: _getEstimatedRecoveryTime(),
          ),
          fallbackException: Exception(fallbackError.toString()),
        );
      }
    }
  }

  /// Executes operation with retry logic and timeout
  Future<T> _executeWithRetry<T>(Future<T> Function() operation) async {
    final stopwatch = Stopwatch()..start();
    var attempt = 0;
    final attemptErrors = <Exception>[];

    while (attempt <= _config.maxRetries) {
      attempt++;

      try {
        // Apply timeout to the operation
        final result = await operation().timeout(
          _config.timeoutDuration,
          onTimeout: () {
            throw CircuitBreakerTimeoutException(
              message: 'Operation timed out',
              serviceName: serviceName,
              timeout: _config.timeoutDuration,
              actualDuration: stopwatch.elapsed,
            );
          },
        );

        // Success - record metrics and handle state transitions
        stopwatch.stop();
        _metricsCollector.recordSuccess(stopwatch.elapsed);
        _onOperationSuccess();

        return result;

      } catch (e) {
        attemptErrors.add(e is Exception ? e : Exception(e.toString()));

        // Handle timeout specifically
        if (e is CircuitBreakerTimeoutException) {
          _metricsCollector.recordFailure(stopwatch.elapsed, isTimeout: true);
        } else {
          _metricsCollector.recordFailure(stopwatch.elapsed);
        }

        // If this is the last attempt, handle failure
        if (attempt > _config.maxRetries) {
          _onOperationFailure(e);

          throw MaxRetriesExceededException(
            message: 'Max retries exceeded for $serviceName',
            serviceName: serviceName,
            maxRetries: _config.maxRetries,
            attemptErrors: attemptErrors,
          );
        }

        // Calculate backoff delay for next attempt
        if (attempt <= _config.maxRetries) {
          final backoffDelay = _calculateBackoffDelay(attempt);

          if (kDebugMode) {
            print('🔄 Retry attempt $attempt for $serviceName after $backoffDelay');
          }

          await Future.delayed(backoffDelay);
        }
      }
    }

    // This should never be reached due to the logic above
    throw Exception('Unexpected state in retry logic');
  }

  /// Handles successful operation
  void _onOperationSuccess() {
    final previousState = _state;

    // Reset failure counter
    _consecutiveFailures = 0;

    // State transitions based on current state
    switch (_state) {
      case CircuitBreakerState.halfOpen:
        _transitionToState(CircuitBreakerState.closed);
        _halfOpenCallInProgress = false;
        if (kDebugMode) {
          print('✅ Circuit breaker closed for $serviceName - recovery successful');
        }
        break;
      case CircuitBreakerState.closed:
        // Already closed, just continue
        break;
      case CircuitBreakerState.open:
        // This shouldn't happen as open state blocks requests
        if (kDebugMode) {
          print('⚠️ Unexpected success in open state for $serviceName');
        }
        break;
    }
  }

  /// Handles failed operation
  void _onOperationFailure(dynamic error) {
    _consecutiveFailures++;
    _lastFailureTime = DateTime.now();

    if (kDebugMode) {
      print('❌ Operation failed for $serviceName (failures: $_consecutiveFailures): $error');
    }

    // State transitions based on failure count and current state
    switch (_state) {
      case CircuitBreakerState.closed:
        if (_consecutiveFailures >= _config.failureThreshold) {
          _transitionToState(CircuitBreakerState.open);
          _scheduleRecovery();

          if (kDebugMode) {
            print('🚨 Circuit breaker opened for $serviceName after $_consecutiveFailures failures');
          }
        }
        break;

      case CircuitBreakerState.halfOpen:
        // Single failure in half-open state reopens the circuit
        _transitionToState(CircuitBreakerState.open);
        _halfOpenCallInProgress = false;
        _scheduleRecovery();

        if (kDebugMode) {
          print('🔄 Circuit breaker reopened for $serviceName - recovery failed');
        }
        break;

      case CircuitBreakerState.open:
        // Already open, extend recovery time
        _scheduleRecovery();
        break;
    }
  }

  /// Transitions to a new state
  void _transitionToState(CircuitBreakerState newState) {
    if (_state != newState) {
      _state = newState;
      _stateTransitionTime = DateTime.now();
    }
  }

  /// Schedules automatic recovery attempt
  void _scheduleRecovery() {
    _recoveryTimer?.cancel();

    _recoveryTimer = Timer(_config.recoveryTimeout, () {
      if (_state == CircuitBreakerState.open) {
        _transitionToState(CircuitBreakerState.halfOpen);

        if (kDebugMode) {
          print('🔧 Circuit breaker half-open for $serviceName - testing recovery');
        }
      }
    });
  }

  /// Calculates exponential backoff delay
  Duration _calculateBackoffDelay(int attempt) {
    final baseDelayMs = _config.initialRetryDelay.inMilliseconds;
    final backoffMs = baseDelayMs * pow(_config.backoffMultiplier, attempt - 1);
    final cappedDelayMs = min(backoffMs, _config.maxRetryDelay.inMilliseconds.toDouble());

    // Add jitter to prevent thundering herd
    final jitterMs = cappedDelayMs * 0.1 * (Random().nextDouble() - 0.5);
    final finalDelayMs = (cappedDelayMs + jitterMs).round();

    return Duration(milliseconds: max(0, finalDelayMs));
  }

  /// Estimates when the circuit might recover
  Duration _getEstimatedRecoveryTime() {
    if (_lastFailureTime == null || _state != CircuitBreakerState.open) {
      return Duration.zero;
    }

    final timeSinceFailure = DateTime.now().difference(_lastFailureTime!);
    final remainingRecoveryTime = _config.recoveryTimeout - timeSinceFailure;

    return remainingRecoveryTime > Duration.zero ? remainingRecoveryTime : Duration.zero;
  }

  /// Gets current metrics
  CircuitBreakerMetrics getMetrics() => _metricsCollector.getMetrics();

  /// Gets health status
  CircuitBreakerHealthStatus getHealthStatus() =>
      _metricsCollector.getHealthStatus(_state.name);

  /// Forces circuit to open state (for testing/manual control)
  void forceOpen() {
    _transitionToState(CircuitBreakerState.open);
    _consecutiveFailures = _config.failureThreshold;
    _lastFailureTime = DateTime.now();
    _scheduleRecovery();

    if (kDebugMode) {
      print('⚡ Circuit breaker manually opened for $serviceName');
    }
  }

  /// Forces circuit to closed state (for testing/manual control)
  void forceClose() {
    _transitionToState(CircuitBreakerState.closed);
    _consecutiveFailures = 0;
    _halfOpenCallInProgress = false;
    _recoveryTimer?.cancel();

    if (kDebugMode) {
      print('🔧 Circuit breaker manually closed for $serviceName');
    }
  }

  /// Transitions to half-open state for testing
  void transitionToHalfOpen() {
    _transitionToState(CircuitBreakerState.halfOpen);
    _halfOpenCallInProgress = false;
  }

  /// Attempts recovery (moves from open to half-open)
  Future<void> attemptRecovery() async {
    if (_state == CircuitBreakerState.open) {
      _transitionToState(CircuitBreakerState.halfOpen);
      _halfOpenCallInProgress = false;

      if (kDebugMode) {
        print('🔄 Attempting recovery for $serviceName');
      }
    }
  }

  /// Updates configuration at runtime
  void updateConfiguration(CircuitBreakerConfig newConfig) {
    if (!newConfig.isValid) {
      throw CircuitBreakerConfigurationException(
        message: 'Invalid configuration update',
        parameter: 'newConfig',
      );
    }

    _config = newConfig;

    if (kDebugMode) {
      print('🔧 Configuration updated for $serviceName: $newConfig');
    }
  }

  /// Resets circuit breaker to initial state
  void reset() {
    _transitionToState(CircuitBreakerState.closed);
    _consecutiveFailures = 0;
    _lastFailureTime = null;
    _halfOpenCallInProgress = false;
    _recoveryTimer?.cancel();
    _metricsCollector.reset();

    if (kDebugMode) {
      print('🔄 Circuit breaker reset for $serviceName');
    }
  }

  /// Disposes resources
  void dispose() {
    _recoveryTimer?.cancel();

    if (kDebugMode) {
      print('🗑️ Circuit breaker disposed for $serviceName');
    }
  }
}

/// Factory for creating pre-configured circuit breakers
class CircuitBreakerFactory {
  static final Map<String, CircuitBreakerService> _instances = {};

  /// Gets or creates a circuit breaker for a service
  static CircuitBreakerService getOrCreate(
    String serviceName, {
    CircuitBreakerConfig? config,
  }) {
    return _instances.putIfAbsent(
      serviceName,
      () => CircuitBreakerService(
        config ?? CircuitBreakerConfig(),
        serviceName: serviceName,
      ),
    );
  }

  /// Creates a circuit breaker optimized for database operations
  static CircuitBreakerService forDatabase(String serviceName) {
    return CircuitBreakerService(
      CircuitBreakerConfig.slowService().copyWith(
        failureThreshold: 3,
        timeoutDuration: Duration(seconds: 15),
        recoveryTimeout: Duration(minutes: 1),
      ),
      serviceName: serviceName,
    );
  }

  /// Creates a circuit breaker optimized for API calls
  static CircuitBreakerService forApi(String serviceName) {
    return CircuitBreakerService(
      CircuitBreakerConfig.fastService().copyWith(
        failureThreshold: 5,
        maxRetries: 3,
      ),
      serviceName: serviceName,
    );
  }

  /// Creates a circuit breaker optimized for critical operations
  static CircuitBreakerService forCriticalOperation(String serviceName) {
    return CircuitBreakerService(
      CircuitBreakerConfig.criticalService(),
      serviceName: serviceName,
    );
  }

  /// Disposes all circuit breakers
  static void disposeAll() {
    for (final circuitBreaker in _instances.values) {
      circuitBreaker.dispose();
    }
    _instances.clear();
  }

  /// Gets metrics for all circuit breakers
  static Map<String, CircuitBreakerMetrics> getAllMetrics() {
    return Map.fromEntries(
      _instances.entries.map(
        (entry) => MapEntry(entry.key, entry.value.getMetrics()),
      ),
    );
  }

  /// Gets health status for all circuit breakers
  static Map<String, CircuitBreakerHealthStatus> getAllHealthStatus() {
    return Map.fromEntries(
      _instances.entries.map(
        (entry) => MapEntry(entry.key, entry.value.getHealthStatus()),
      ),
    );
  }
}