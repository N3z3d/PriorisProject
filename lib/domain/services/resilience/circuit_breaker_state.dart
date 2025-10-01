/// States for the Circuit Breaker pattern implementation
enum CircuitBreakerState {
  /// Circuit is closed - requests flow normally
  closed,

  /// Circuit is open - requests are blocked to prevent cascade failures
  open,

  /// Circuit is half-open - limited requests allowed to test recovery
  halfOpen,
}

/// Extensions for Circuit Breaker state
extension CircuitBreakerStateExtension on CircuitBreakerState {
  /// Whether requests should be allowed through
  bool get allowsRequests {
    switch (this) {
      case CircuitBreakerState.closed:
        return true;
      case CircuitBreakerState.open:
        return false;
      case CircuitBreakerState.halfOpen:
        return true; // Limited requests allowed
    }
  }

  /// Human-readable description of the state
  String get description {
    switch (this) {
      case CircuitBreakerState.closed:
        return 'Healthy - requests flowing normally';
      case CircuitBreakerState.open:
        return 'Circuit open - blocking requests to prevent cascading failures';
      case CircuitBreakerState.halfOpen:
        return 'Testing recovery - limited requests allowed';
    }
  }

  /// Whether the circuit is operational
  bool get isOperational {
    switch (this) {
      case CircuitBreakerState.closed:
        return true;
      case CircuitBreakerState.open:
        return false;
      case CircuitBreakerState.halfOpen:
        return true; // Partially operational
    }
  }
}