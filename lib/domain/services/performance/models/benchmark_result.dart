/// Model representing benchmark results
class BenchmarkResult {
  final String operationName;
  final int iterations;
  final int successfulRuns;
  final Duration averageLatency;
  final Duration minLatency;
  final Duration maxLatency;
  final Duration p95Latency;
  final Duration p99Latency;
  final double averageMemoryUsage;
  final List<String> errors;
  final double throughputPerSecond;

  BenchmarkResult({
    required this.operationName,
    required this.iterations,
    required this.successfulRuns,
    required this.averageLatency,
    required this.minLatency,
    required this.maxLatency,
    required this.p95Latency,
    required this.p99Latency,
    required this.averageMemoryUsage,
    required this.errors,
    required this.throughputPerSecond,
  });

  /// Success rate
  double get successRate => successfulRuns / iterations;

  /// Formatted benchmark summary
  String get summary => '''
Benchmark: $operationName
Iterations: $iterations ($successfulRuns successful, ${errors.length} errors)
Latency: ${averageLatency.inMilliseconds}ms avg, ${minLatency.inMilliseconds}ms min, ${maxLatency.inMilliseconds}ms max
Percentiles: P95=${p95Latency.inMilliseconds}ms, P99=${p99Latency.inMilliseconds}ms
Throughput: ${throughputPerSecond.toStringAsFixed(1)} ops/sec
Memory: ${averageMemoryUsage.toStringAsFixed(1)}KB avg
Success rate: ${(successRate * 100).toStringAsFixed(1)}%
''';
}
