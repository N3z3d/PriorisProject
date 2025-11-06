import 'dart:math';

import 'package:prioris/domain/services/cache/cache_statistics.dart';

class CacheStatisticsService {
  CacheStatisticsService() {
    _startTime = DateTime.now();
  }

  late DateTime _startTime;
  int _totalAccesses = 0;
  int _hits = 0;
  int _misses = 0;
  int _writes = 0;
  int _evictions = 0;
  final List<DateTime> _accessLog = [];
  final List<DateTime> _recentAccessLog = [];

  double get hitRate =>
      _totalAccesses == 0 ? 0.0 : _hits / _totalAccesses.toDouble();

  double get missRate =>
      _totalAccesses == 0 ? 0.0 : _misses / _totalAccesses.toDouble();

  double get requestsPerSecond {
    final elapsed = DateTime.now().difference(_startTime).inMilliseconds;
    if (elapsed <= 0) {
      return 0;
    }
    return _totalAccesses * 1000 / elapsed;
  }

  double get recentRequestsPerSecond {
    final cutoff = DateTime.now().subtract(const Duration(seconds: 1));
    _recentAccessLog.removeWhere((ts) => ts.isBefore(cutoff));
    if (_recentAccessLog.isEmpty) {
      return 0;
    }
    final span = DateTime.now()
        .difference(_recentAccessLog.first)
        .inMilliseconds
        .clamp(1, 1000);
    return _recentAccessLog.length * 1000 / span;
  }

  double get effectivenessScore {
    if (_totalAccesses == 0) {
      return 0;
    }
    final hitScore = hitRate * 60;
    final writeScore = _writes > 0 ? 20 : 5;
    final rpsScore = min(requestsPerSecond, 50) / 50 * 20;
    return (hitScore + writeScore + rpsScore).clamp(0, 100);
  }

  void recordAccess() {
    _totalAccesses++;
    final now = DateTime.now();
    _accessLog.add(now);
    _recentAccessLog.add(now);
  }

  void recordHit() {
    _hits++;
  }

  void recordMiss() {
    _misses++;
  }

  void recordWrite() {
    _writes++;
  }

  void recordEviction() {
    _evictions++;
  }

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

  Map<String, Object?> getStatistics() => {
        'totalAccesses': _totalAccesses,
        'hits': _hits,
        'misses': _misses,
        'writes': _writes,
        'evictions': _evictions,
        'hitRate': hitRate,
        'missRate': missRate,
        'uptimeSeconds':
            DateTime.now().difference(_startTime).inSeconds.clamp(0, 1 << 31),
        'requestsPerSecond': requestsPerSecond,
        'recentRequestsPerSecond': recentRequestsPerSecond,
        'effectivenessScore': effectivenessScore,
        'performance': _buildPerformanceSection(),
      };

  Map<String, Object?> _buildPerformanceSection() {
    final accessFrequency = () {
      if (requestsPerSecond > 10) return 'High';
      if (requestsPerSecond > 2) return 'Medium';
      if (requestsPerSecond > 0.3) return 'Low';
      return 'Minimal';
    }();

    return {
      'accessFrequency': accessFrequency,
      'lastAccess':
          _accessLog.isEmpty ? null : _accessLog.last.toIso8601String(),
      'writeCount': _writes,
      'evictionCount': _evictions,
    };
  }

  Map<String, Object?> getPerformanceReport() {
    final grade = () {
      if (effectivenessScore >= 85) return 'A+';
      if (effectivenessScore >= 70) return 'A';
      if (effectivenessScore >= 55) return 'B';
      if (effectivenessScore >= 40) return 'C';
      return 'D';
    }();

    final recommendations = <String>[];
    if (hitRate < 0.6) {
      recommendations.add(
          'Low hit rate detected. Consider warming popular keys or increasing cache size.');
    }
    if (_writes == 0) {
      recommendations.add('No writes detected recently. Ensure cache is fed.');
    }
    if (requestsPerSecond > 20) {
      recommendations.add('High request rate: verify cache scaling configuration.');
    }
    if (recommendations.isEmpty) {
      recommendations.add('Cache performance is within optimal thresholds.');
    }

    return {
      'summary': {
        'grade': grade,
        'score': effectivenessScore,
      },
      'recommendations': recommendations,
      'metrics': getStatistics(),
    };
  }

  void reset() {
    _totalAccesses = 0;
    _hits = 0;
    _misses = 0;
    _writes = 0;
    _evictions = 0;
    _accessLog.clear();
    _recentAccessLog.clear();
    _startTime = DateTime.now();
  }

  void dispose() {
    _accessLog.clear();
    _recentAccessLog.clear();
  }
}

class CacheStatisticsSnapshot {
  CacheStatisticsSnapshot({
    required this.timestamp,
    required this.totalAccesses,
    required this.hits,
    required this.misses,
    required this.writes,
    required this.evictions,
    required this.hitRate,
    required this.requestsPerSecond,
  });

  final DateTime timestamp;
  final int totalAccesses;
  final int hits;
  final int misses;
  final int writes;
  final int evictions;
  final double hitRate;
  final double requestsPerSecond;

  Map<String, Object?> toMap() => {
        'timestamp': timestamp.toIso8601String(),
        'totalAccesses': totalAccesses,
        'hits': hits,
        'misses': misses,
        'writes': writes,
        'evictions': evictions,
        'hitRate': hitRate,
        'requestsPerSecond': requestsPerSecond,
      };

  Map<String, Object?> compareTo(CacheStatisticsSnapshot other) => {
        'accessesDelta': totalAccesses - other.totalAccesses,
        'hitsDelta': hits - other.hits,
        'missesDelta': misses - other.misses,
        'writesDelta': writes - other.writes,
        'evictionsDelta': evictions - other.evictions,
        'hitRateDelta': hitRate - other.hitRate,
        'rpsChange': requestsPerSecond - other.requestsPerSecond,
        'timeDelta':
            timestamp.difference(other.timestamp).inSeconds.clamp(0, 1 << 31),
      };
}
