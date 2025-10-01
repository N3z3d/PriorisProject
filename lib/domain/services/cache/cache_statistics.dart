import 'dart:collection';
import 'dart:math';

/// Comprehensive cache statistics tracking and analysis
class CacheStatistics {
  // Basic metrics
  int _hits = 0;
  int _misses = 0;
  int _evictions = 0;
  int _totalOperations = 0;
  int _prefetchAttempts = 0;
  int totalItems = 0;

  // Memory metrics
  int _memoryUsage = 0;
  int _maxMemoryUsage = 0;
  double _compressionRatio = 1.0;

  // Performance metrics
  final Queue<Duration> _operationTimes = Queue<Duration>();
  final Queue<DateTime> _operationTimestamps = Queue<DateTime>();

  // Level-specific metrics
  final Map<String, int> _levelHits = <String, int>{};
  final Map<String, int> _levelMisses = <String, int>{};

  // Pattern analysis
  final Map<String, int> _keyPatternHits = <String, int>{};
  final Map<String, int> _accessPatterns = <String, int>{};

  // Time-based analytics
  DateTime _lastReset = DateTime.now();
  Duration _uptime = Duration.zero;

  // Configuration
  static const int _maxHistorySize = 1000;
  static const Duration _historyWindow = Duration(hours: 24);

  /// Records a cache hit
  void recordHit(dynamic level) {
    _hits++;
    _totalOperations++;

    final levelName = level?.toString() ?? 'unknown';
    _levelHits[levelName] = (_levelHits[levelName] ?? 0) + 1;

    _recordTimestamp();
  }

  /// Records a cache miss
  void recordMiss([dynamic level]) {
    _misses++;
    _totalOperations++;

    if (level != null) {
      final levelName = level.toString();
      _levelMisses[levelName] = (_levelMisses[levelName] ?? 0) + 1;
    }

    _recordTimestamp();
  }

  /// Records an eviction
  void recordEviction() {
    _evictions++;
  }

  /// Records an operation
  void recordOperation() {
    _totalOperations++;
    _recordTimestamp();
  }

  /// Records a prefetch attempt
  void recordPrefetchAttempt() {
    _prefetchAttempts++;
  }

  /// Records operation timing
  void recordOperationTime(Duration duration) {
    _operationTimes.add(duration);

    // Keep only recent operations
    if (_operationTimes.length > _maxHistorySize) {
      _operationTimes.removeFirst();
    }
  }

  /// Records key pattern access
  void recordKeyPatternAccess(String key) {
    final pattern = _extractPattern(key);
    _keyPatternHits[pattern] = (_keyPatternHits[pattern] ?? 0) + 1;
    _accessPatterns[key] = (_accessPatterns[key] ?? 0) + 1;
  }

  /// Updates memory metrics
  void updateMemoryMetrics(int currentUsage, int maxUsage) {
    _memoryUsage = currentUsage;
    _maxMemoryUsage = maxUsage;
  }

  /// Updates compression ratio
  void updateCompressionRatio(double ratio) {
    _compressionRatio = ratio;
  }

  /// Gets overall hit rate
  double get hitRate {
    if (_totalOperations == 0) return 0.0;
    return _hits / _totalOperations;
  }

  /// Gets overall miss rate
  double get missRate {
    if (_totalOperations == 0) return 0.0;
    return _misses / _totalOperations;
  }

  /// Gets memory usage percentage
  double get memoryUsagePercentage {
    if (_maxMemoryUsage == 0) return 0.0;
    return _memoryUsage / _maxMemoryUsage;
  }

  /// Gets memory pressure (0.0 to 1.0)
  double get memoryPressure {
    return memoryUsagePercentage;
  }

  /// Gets compression ratio
  double get compressionRatio => _compressionRatio;

  /// Gets current memory usage in bytes
  int get memoryUsage => _memoryUsage;

  /// Gets total operations count
  int get totalOperations => _totalOperations;

  /// Gets successful requests count
  int get successfulRequests => _hits;

  /// Gets failed requests count
  int get failedRequests => _misses;

  /// Gets prefetch attempts count
  int get prefetchAttempts => _prefetchAttempts;

  /// Gets eviction count
  int get evictions => _evictions;

  /// Gets average operation time
  Duration get averageOperationTime {
    if (_operationTimes.isEmpty) return Duration.zero;

    final totalMicros = _operationTimes
        .map((d) => d.inMicroseconds)
        .reduce((a, b) => a + b);

    return Duration(microseconds: totalMicros ~/ _operationTimes.length);
  }

  /// Gets percentile operation time
  Duration getPercentileOperationTime(double percentile) {
    if (_operationTimes.isEmpty) return Duration.zero;

    final sortedTimes = _operationTimes.toList()..sort();
    final index = ((sortedTimes.length - 1) * percentile).round();

    return sortedTimes[index.clamp(0, sortedTimes.length - 1)];
  }

  /// Gets operations per second
  double get operationsPerSecond {
    final now = DateTime.now();
    final windowStart = now.subtract(Duration(seconds: 60));

    final recentOps = _operationTimestamps
        .where((timestamp) => timestamp.isAfter(windowStart))
        .length;

    return recentOps / 60.0; // Operations per second over last minute
  }

  /// Gets cache efficiency score (0.0 to 1.0)
  double get efficiencyScore {
    final hitRateScore = hitRate;
    final memoryEfficiency = 1.0 - memoryPressure;
    final performanceScore = averageOperationTime.inMilliseconds < 10 ? 1.0 :
                           10.0 / averageOperationTime.inMilliseconds;

    return (hitRateScore * 0.5 + memoryEfficiency * 0.3 + performanceScore * 0.2)
        .clamp(0.0, 1.0);
  }

  /// Gets level-specific hit rates
  Map<String, double> getLevelHitRates() {
    final result = <String, double>{};

    for (final level in {..._levelHits.keys, ..._levelMisses.keys}) {
      final hits = _levelHits[level] ?? 0;
      final misses = _levelMisses[level] ?? 0;
      final total = hits + misses;

      result[level] = total > 0 ? hits / total : 0.0;
    }

    return result;
  }

  /// Gets most accessed key patterns
  Map<String, int> getTopKeyPatterns({int limit = 10}) {
    final sorted = _keyPatternHits.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sorted.take(limit));
  }

  /// Gets access frequency distribution
  Map<String, int> getAccessFrequencyDistribution() {
    final distribution = <String, int>{};

    for (final count in _accessPatterns.values) {
      String bucket;
      if (count == 1) bucket = '1';
      else if (count <= 5) bucket = '2-5';
      else if (count <= 10) bucket = '6-10';
      else if (count <= 50) bucket = '11-50';
      else if (count <= 100) bucket = '51-100';
      else bucket = '100+';

      distribution[bucket] = (distribution[bucket] ?? 0) + 1;
    }

    return distribution;
  }

  /// Gets cache performance trending data
  Map<String, dynamic> getPerformanceTrend() {
    final now = DateTime.now();
    final oneHourAgo = now.subtract(Duration(hours: 1));

    // Filter recent operations
    final recentTimes = <Duration>[];
    final recentTimestamps = <DateTime>[];

    for (int i = 0; i < _operationTimes.length && i < _operationTimestamps.length; i++) {
      if (_operationTimestamps.elementAt(i).isAfter(oneHourAgo)) {
        recentTimes.add(_operationTimes.elementAt(i));
        recentTimestamps.add(_operationTimestamps.elementAt(i));
      }
    }

    return {
      'recent_operations': recentTimes.length,
      'average_time_ms': recentTimes.isEmpty ? 0 :
          recentTimes.map((d) => d.inMilliseconds).reduce((a, b) => a + b) / recentTimes.length,
      'trend_direction': _calculateTrendDirection(recentTimes),
      'performance_stability': _calculateStability(recentTimes),
    };
  }

  /// Gets detailed analytics report
  Map<String, dynamic> getAnalyticsReport() {
    final uptime = DateTime.now().difference(_lastReset);

    return {
      'summary': {
        'uptime_seconds': uptime.inSeconds,
        'total_operations': _totalOperations,
        'hit_rate': hitRate,
        'miss_rate': missRate,
        'efficiency_score': efficiencyScore,
      },
      'memory': {
        'usage_bytes': _memoryUsage,
        'usage_percentage': memoryUsagePercentage,
        'memory_pressure': memoryPressure,
        'compression_ratio': _compressionRatio,
      },
      'performance': {
        'avg_operation_time_ms': averageOperationTime.inMilliseconds,
        'p95_operation_time_ms': getPercentileOperationTime(0.95).inMilliseconds,
        'p99_operation_time_ms': getPercentileOperationTime(0.99).inMilliseconds,
        'operations_per_second': operationsPerSecond,
      },
      'distribution': {
        'level_hit_rates': getLevelHitRates(),
        'access_patterns': getTopKeyPatterns(),
        'frequency_distribution': getAccessFrequencyDistribution(),
      },
      'advanced': {
        'evictions': _evictions,
        'prefetch_attempts': _prefetchAttempts,
        'total_items': totalItems,
        'performance_trend': getPerformanceTrend(),
      },
    };
  }

  /// Resets all statistics
  void reset() {
    _hits = 0;
    _misses = 0;
    _evictions = 0;
    _totalOperations = 0;
    _prefetchAttempts = 0;
    totalItems = 0;

    _memoryUsage = 0;
    _compressionRatio = 1.0;

    _operationTimes.clear();
    _operationTimestamps.clear();
    _levelHits.clear();
    _levelMisses.clear();
    _keyPatternHits.clear();
    _accessPatterns.clear();

    _lastReset = DateTime.now();
  }

  /// Exports statistics in JSON format
  Map<String, dynamic> toJson() {
    return getAnalyticsReport();
  }

  // Private helper methods

  void _recordTimestamp() {
    _operationTimestamps.add(DateTime.now());

    // Keep only recent timestamps
    if (_operationTimestamps.length > _maxHistorySize) {
      _operationTimestamps.removeFirst();
    }
  }

  String _extractPattern(String key) {
    // Extract common patterns from cache keys
    if (key.contains(':')) {
      return key.split(':')[0] + ':*';
    } else if (key.contains('_')) {
      final parts = key.split('_');
      if (parts.length > 1) {
        return '${parts[0]}_*';
      }
    }
    return 'other';
  }

  String _calculateTrendDirection(List<Duration> recentTimes) {
    if (recentTimes.length < 10) return 'insufficient_data';

    final firstHalf = recentTimes.take(recentTimes.length ~/ 2)
        .map((d) => d.inMilliseconds)
        .reduce((a, b) => a + b) / (recentTimes.length ~/ 2);

    final secondHalf = recentTimes.skip(recentTimes.length ~/ 2)
        .map((d) => d.inMilliseconds)
        .reduce((a, b) => a + b) / (recentTimes.length - recentTimes.length ~/ 2);

    final difference = secondHalf - firstHalf;

    if (difference.abs() < 1.0) return 'stable';
    return difference > 0 ? 'deteriorating' : 'improving';
  }

  double _calculateStability(List<Duration> times) {
    if (times.length < 5) return 0.0;

    final values = times.map((d) => d.inMilliseconds.toDouble()).toList();
    final mean = values.reduce((a, b) => a + b) / values.length;

    final variance = values
        .map((v) => pow(v - mean, 2))
        .reduce((a, b) => a + b) / values.length;

    final standardDeviation = sqrt(variance);
    final coefficientOfVariation = mean > 0 ? standardDeviation / mean : 0;

    // Lower coefficient of variation = higher stability
    return (1.0 - coefficientOfVariation).clamp(0.0, 1.0);
  }
}