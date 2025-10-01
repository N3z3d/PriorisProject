import 'dart:collection';
import 'dart:math';

/// Metrics collected by the Circuit Breaker
class CircuitBreakerMetrics {
  final String serviceName;
  final int totalRequests;
  final int successfulRequests;
  final int failedRequests;
  final int timeoutRequests;
  final int circuitOpenRequests;
  final Duration averageResponseTime;
  final Duration p95ResponseTime;
  final Duration p99ResponseTime;
  final double successRate;
  final double failureRate;
  final DateTime lastSuccess;
  final DateTime? lastFailure;
  final Duration uptime;

  const CircuitBreakerMetrics({
    required this.serviceName,
    required this.totalRequests,
    required this.successfulRequests,
    required this.failedRequests,
    required this.timeoutRequests,
    required this.circuitOpenRequests,
    required this.averageResponseTime,
    required this.p95ResponseTime,
    required this.p99ResponseTime,
    required this.successRate,
    required this.failureRate,
    required this.lastSuccess,
    this.lastFailure,
    required this.uptime,
  });

  /// Creates empty metrics for initialization
  factory CircuitBreakerMetrics.empty(String serviceName) {
    final now = DateTime.now();
    return CircuitBreakerMetrics(
      serviceName: serviceName,
      totalRequests: 0,
      successfulRequests: 0,
      failedRequests: 0,
      timeoutRequests: 0,
      circuitOpenRequests: 0,
      averageResponseTime: Duration.zero,
      p95ResponseTime: Duration.zero,
      p99ResponseTime: Duration.zero,
      successRate: 0.0,
      failureRate: 0.0,
      lastSuccess: now,
      lastFailure: null,
      uptime: Duration.zero,
    );
  }

  /// Exports metrics to JSON format for monitoring systems
  Map<String, dynamic> toJson() {
    return {
      'service_name': serviceName,
      'total_requests': totalRequests,
      'successful_requests': successfulRequests,
      'failed_requests': failedRequests,
      'timeout_requests': timeoutRequests,
      'circuit_open_requests': circuitOpenRequests,
      'average_response_time_ms': averageResponseTime.inMilliseconds,
      'p95_response_time_ms': p95ResponseTime.inMilliseconds,
      'p99_response_time_ms': p99ResponseTime.inMilliseconds,
      'success_rate': successRate,
      'failure_rate': failureRate,
      'last_success': lastSuccess.toIso8601String(),
      'last_failure': lastFailure?.toIso8601String(),
      'uptime_seconds': uptime.inSeconds,
    };
  }

  /// Human-readable metrics summary
  String get summary {
    return '''
Circuit Breaker Metrics - $serviceName
Total Requests: $totalRequests
Success Rate: ${(successRate * 100).toStringAsFixed(1)}%
Average Response Time: ${averageResponseTime.inMilliseconds}ms
P95 Response Time: ${p95ResponseTime.inMilliseconds}ms
P99 Response Time: ${p99ResponseTime.inMilliseconds}ms
Uptime: ${uptime.inMinutes} minutes
Last Failure: ${lastFailure ?? 'Never'}
''';
  }
}

/// Health status of the circuit breaker
class CircuitBreakerHealthStatus {
  final bool isHealthy;
  final String state;
  final double healthScore;
  final Duration uptime;
  final DateTime? lastFailure;
  final String? currentIssue;
  final List<String> recommendations;

  const CircuitBreakerHealthStatus({
    required this.isHealthy,
    required this.state,
    required this.healthScore,
    required this.uptime,
    this.lastFailure,
    this.currentIssue,
    this.recommendations = const [],
  });

  /// Creates healthy status
  factory CircuitBreakerHealthStatus.healthy(String state, Duration uptime) {
    return CircuitBreakerHealthStatus(
      isHealthy: true,
      state: state,
      healthScore: 1.0,
      uptime: uptime,
    );
  }

  /// Creates unhealthy status with issue description
  factory CircuitBreakerHealthStatus.unhealthy({
    required String state,
    required Duration uptime,
    required double healthScore,
    DateTime? lastFailure,
    String? issue,
    List<String>? recommendations,
  }) {
    return CircuitBreakerHealthStatus(
      isHealthy: false,
      state: state,
      healthScore: healthScore,
      uptime: uptime,
      lastFailure: lastFailure,
      currentIssue: issue,
      recommendations: recommendations ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_healthy': isHealthy,
      'state': state,
      'health_score': healthScore,
      'uptime_seconds': uptime.inSeconds,
      'last_failure': lastFailure?.toIso8601String(),
      'current_issue': currentIssue,
      'recommendations': recommendations,
    };
  }
}

/// Internal metrics collector for circuit breaker
class MetricsCollector {
  final String serviceName;
  final int maxSampleSize;
  final Queue<_RequestRecord> _requestHistory = Queue<_RequestRecord>();

  int _totalRequests = 0;
  int _successfulRequests = 0;
  int _failedRequests = 0;
  int _timeoutRequests = 0;
  int _circuitOpenRequests = 0;
  DateTime _lastSuccess = DateTime.now();
  DateTime? _lastFailure;
  final DateTime _startTime = DateTime.now();

  MetricsCollector(this.serviceName, {this.maxSampleSize = 1000});

  /// Records a successful request
  void recordSuccess(Duration responseTime) {
    _totalRequests++;
    _successfulRequests++;
    _lastSuccess = DateTime.now();

    _requestHistory.add(_RequestRecord(
      timestamp: DateTime.now(),
      success: true,
      responseTime: responseTime,
    ));

    _trimHistory();
  }

  /// Records a failed request
  void recordFailure(Duration responseTime, {bool isTimeout = false}) {
    _totalRequests++;
    _failedRequests++;
    if (isTimeout) _timeoutRequests++;
    _lastFailure = DateTime.now();

    _requestHistory.add(_RequestRecord(
      timestamp: DateTime.now(),
      success: false,
      responseTime: responseTime,
    ));

    _trimHistory();
  }

  /// Records a request blocked by open circuit
  void recordCircuitOpen() {
    _totalRequests++;
    _circuitOpenRequests++;
  }

  /// Gets current metrics snapshot
  CircuitBreakerMetrics getMetrics() {
    final successRate = _totalRequests > 0 ? _successfulRequests / _totalRequests : 0.0;
    final failureRate = 1.0 - successRate;

    final responseTimes = _requestHistory
        .map((record) => record.responseTime)
        .toList()
      ..sort();

    return CircuitBreakerMetrics(
      serviceName: serviceName,
      totalRequests: _totalRequests,
      successfulRequests: _successfulRequests,
      failedRequests: _failedRequests,
      timeoutRequests: _timeoutRequests,
      circuitOpenRequests: _circuitOpenRequests,
      averageResponseTime: _calculateAverageResponseTime(),
      p95ResponseTime: _calculatePercentile(responseTimes, 0.95),
      p99ResponseTime: _calculatePercentile(responseTimes, 0.99),
      successRate: successRate,
      failureRate: failureRate,
      lastSuccess: _lastSuccess,
      lastFailure: _lastFailure,
      uptime: DateTime.now().difference(_startTime),
    );
  }

  /// Gets health status based on current metrics
  CircuitBreakerHealthStatus getHealthStatus(String currentState) {
    final metrics = getMetrics();

    // Calculate health score based on multiple factors
    double healthScore = 1.0;
    final recommendations = <String>[];
    String? currentIssue;

    // Factor in success rate
    if (metrics.successRate < 0.5) {
      healthScore *= metrics.successRate;
      currentIssue = 'Low success rate: ${(metrics.successRate * 100).toStringAsFixed(1)}%';
      recommendations.add('Investigate service failures and implement fallback mechanisms');
    }

    // Factor in recent failures
    if (metrics.lastFailure != null) {
      final timeSinceLastFailure = DateTime.now().difference(metrics.lastFailure!);
      if (timeSinceLastFailure < Duration(minutes: 5)) {
        healthScore *= 0.7;
        if (currentIssue == null) {
          currentIssue = 'Recent failure detected';
        }
        recommendations.add('Monitor service stability and consider increasing timeout');
      }
    }

    // Factor in response time
    if (metrics.averageResponseTime > Duration(seconds: 5)) {
      healthScore *= 0.8;
      if (currentIssue == null) {
        currentIssue = 'High response time: ${metrics.averageResponseTime.inMilliseconds}ms';
      }
      recommendations.add('Optimize service performance or increase timeout');
    }

    final isHealthy = healthScore > 0.7 && currentState != 'open';

    return CircuitBreakerHealthStatus(
      isHealthy: isHealthy,
      state: currentState,
      healthScore: healthScore,
      uptime: metrics.uptime,
      lastFailure: metrics.lastFailure,
      currentIssue: currentIssue,
      recommendations: recommendations,
    );
  }

  /// Resets all metrics
  void reset() {
    _totalRequests = 0;
    _successfulRequests = 0;
    _failedRequests = 0;
    _timeoutRequests = 0;
    _circuitOpenRequests = 0;
    _requestHistory.clear();
    _lastFailure = null;
  }

  Duration _calculateAverageResponseTime() {
    if (_requestHistory.isEmpty) return Duration.zero;

    final totalMs = _requestHistory
        .map((record) => record.responseTime.inMilliseconds)
        .reduce((a, b) => a + b);

    return Duration(milliseconds: (totalMs / _requestHistory.length).round());
  }

  Duration _calculatePercentile(List<Duration> sortedTimes, double percentile) {
    if (sortedTimes.isEmpty) return Duration.zero;

    final index = ((sortedTimes.length - 1) * percentile).round();
    return sortedTimes[min(index, sortedTimes.length - 1)];
  }

  void _trimHistory() {
    while (_requestHistory.length > maxSampleSize) {
      _requestHistory.removeFirst();
    }
  }
}

/// Internal record of a request for metrics calculation
class _RequestRecord {
  final DateTime timestamp;
  final bool success;
  final Duration responseTime;

  const _RequestRecord({
    required this.timestamp,
    required this.success,
    required this.responseTime,
  });
}