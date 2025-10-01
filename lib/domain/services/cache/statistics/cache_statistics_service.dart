import 'dart:async';
import '../interfaces/cache_system_interfaces.dart';

/// SOLID implementation of cache statistics service
/// Single Responsibility: Performance monitoring and metrics collection
class CacheStatisticsService implements ICacheStatisticsService {
  int _totalAccesses = 0;
  int _hits = 0;
  int _misses = 0;
  int _writes = 0;
  int _evictions = 0;
  final DateTime _startTime = DateTime.now();

  // Recent performance tracking (last minute)
  final List<DateTime> _recentAccesses = [];
  Timer? _cleanupTimer;

  CacheStatisticsService({bool enableRecentTracking = true}) {
    if (enableRecentTracking) {
      _startRecentAccessCleanup();
    }
  }

  void _startRecentAccessCleanup() {
    _cleanupTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _cleanupRecentAccesses(),
    );
  }

  void _cleanupRecentAccesses() {
    final cutoff = DateTime.now().subtract(const Duration(minutes: 1));
    _recentAccesses.removeWhere((time) => time.isBefore(cutoff));
  }

  @override
  void recordAccess() {
    _totalAccesses++;
    _recentAccesses.add(DateTime.now());
  }

  @override
  void recordHit() {
    _hits++;
  }

  @override
  void recordMiss() {
    _misses++;
  }

  @override
  void recordWrite() {
    _writes++;
  }

  @override
  void recordEviction() {
    _evictions++;
  }

  @override
  double get hitRate => _totalAccesses > 0 ? _hits / _totalAccesses : 0.0;

  @override
  double get missRate => _totalAccesses > 0 ? _misses / _totalAccesses : 0.0;

  @override
  double get requestsPerSecond {
    final uptime = DateTime.now().difference(_startTime);
    return uptime.inSeconds > 0 ? _totalAccesses / uptime.inSeconds : 0.0;
  }

  /// Get recent requests per second (last minute)
  double get recentRequestsPerSecond {
    if (_recentAccesses.isEmpty) return 0.0;

    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
    final recentCount = _recentAccesses
        .where((time) => time.isAfter(oneMinuteAgo))
        .length;

    return recentCount / 60.0; // requests per second
  }

  /// Calculate cache effectiveness score (0-100)
  double get effectivenessScore {
    if (_totalAccesses == 0) return 0.0;

    final hitRateScore = hitRate * 60; // Hit rate worth up to 60 points
    final utilizationScore = requestsPerSecond > 0 ? 20 : 0; // Usage worth 20 points
    final consistencyScore = _evictions < _writes * 0.1 ? 20 : 0; // Low eviction rate worth 20 points

    return (hitRateScore + utilizationScore + consistencyScore).clamp(0.0, 100.0);
  }

  @override
  Map<String, dynamic> getStatistics() {
    final uptime = DateTime.now().difference(_startTime);

    return {
      'totalAccesses': _totalAccesses,
      'hits': _hits,
      'misses': _misses,
      'writes': _writes,
      'evictions': _evictions,
      'hitRate': hitRate,
      'missRate': missRate,
      'uptimeSeconds': uptime.inSeconds,
      'requestsPerSecond': requestsPerSecond,
      'recentRequestsPerSecond': recentRequestsPerSecond,
      'effectivenessScore': effectivenessScore,
      'performance': _getPerformanceMetrics(),
    };
  }

  Map<String, dynamic> _getPerformanceMetrics() {
    return {
      'avgHitsPerWrite': _writes > 0 ? _hits / _writes : 0.0,
      'evictionRate': _writes > 0 ? _evictions / _writes : 0.0,
      'accessFrequency': _getAccessFrequency(),
      'performanceGrade': _getPerformanceGrade(),
    };
  }

  String _getAccessFrequency() {
    final rps = recentRequestsPerSecond;
    if (rps > 10) return 'High';
    if (rps > 1) return 'Medium';
    if (rps > 0.1) return 'Low';
    return 'Minimal';
  }

  String _getPerformanceGrade() {
    final score = effectivenessScore;
    if (score >= 90) return 'A+';
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    if (score >= 50) return 'D';
    return 'F';
  }

  @override
  void reset() {
    _totalAccesses = 0;
    _hits = 0;
    _misses = 0;
    _writes = 0;
    _evictions = 0;
    _recentAccesses.clear();
  }

  /// Get performance report for debugging
  Map<String, dynamic> getPerformanceReport() {
    final uptime = DateTime.now().difference(_startTime);
    final stats = getStatistics();

    return {
      'summary': {
        'uptime': '${uptime.inHours}h ${uptime.inMinutes % 60}m',
        'grade': _getPerformanceGrade(),
        'effectiveness': '${effectivenessScore.toStringAsFixed(1)}%',
        'hitRate': '${(hitRate * 100).toStringAsFixed(1)}%',
      },
      'metrics': stats,
      'recommendations': _getRecommendations(),
    };
  }

  List<String> _getRecommendations() {
    final recommendations = <String>[];

    if (hitRate < 0.5) {
      recommendations.add('Low hit rate detected. Consider increasing cache size or adjusting TTL values.');
    }

    if (_evictions > _writes * 0.2) {
      recommendations.add('High eviction rate. Consider increasing memory limit or optimizing data size.');
    }

    if (recentRequestsPerSecond < 0.1 && _totalAccesses > 100) {
      recommendations.add('Cache is underutilized. Consider shorter TTL values or cache warming strategies.');
    }

    if (_writes == 0 && _totalAccesses > 0) {
      recommendations.add('No writes detected. Ensure cache is being populated correctly.');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Cache performance is optimal!');
    }

    return recommendations;
  }

  /// Create a snapshot of current statistics for comparison
  CacheStatisticsSnapshot createSnapshot() {
    return CacheStatisticsSnapshot(
      timestamp: DateTime.now(),
      totalAccesses: _totalAccesses,
      hits: _hits,
      misses: _misses,
      writes: _writes,
      evictions: _evictions,
      hitRate: hitRate,
      requestsPerSecond: requestsPerSecond,
    );
  }

  void dispose() {
    _cleanupTimer?.cancel();
    _recentAccesses.clear();
  }
}

/// Immutable snapshot of cache statistics
class CacheStatisticsSnapshot {
  final DateTime timestamp;
  final int totalAccesses;
  final int hits;
  final int misses;
  final int writes;
  final int evictions;
  final double hitRate;
  final double requestsPerSecond;

  const CacheStatisticsSnapshot({
    required this.timestamp,
    required this.totalAccesses,
    required this.hits,
    required this.misses,
    required this.writes,
    required this.evictions,
    required this.hitRate,
    required this.requestsPerSecond,
  });

  /// Compare with another snapshot to get delta
  Map<String, dynamic> compareTo(CacheStatisticsSnapshot other) {
    return {
      'timeDelta': timestamp.difference(other.timestamp).inSeconds,
      'accessesDelta': totalAccesses - other.totalAccesses,
      'hitsDelta': hits - other.hits,
      'missesDelta': misses - other.misses,
      'writesDelta': writes - other.writes,
      'evictionsDelta': evictions - other.evictions,
      'hitRateDelta': hitRate - other.hitRate,
      'rpsChange': requestsPerSecond - other.requestsPerSecond,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'totalAccesses': totalAccesses,
      'hits': hits,
      'misses': misses,
      'writes': writes,
      'evictions': evictions,
      'hitRate': hitRate,
      'requestsPerSecond': requestsPerSecond,
    };
  }
}