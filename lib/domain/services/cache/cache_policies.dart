/// Eviction policies for cache management
enum EvictionPolicy {
  /// Least Recently Used - evicts entries that haven't been accessed recently
  lru,

  /// Least Frequently Used - evicts entries with lowest access count
  lfu,

  /// First In First Out - evicts oldest entries regardless of access
  fifo,

  /// Adaptive Replacement Cache - balances between recency and frequency
  arc,

  /// Time-based - evicts entries based on creation time and TTL
  ttl,

  /// Size-based - evicts largest entries first
  size,

  /// Random - evicts random entries (useful for avoiding worst-case scenarios)
  random,
}

/// Cache replacement strategies implementation
class CacheReplacementStrategy {
  /// Calculates priority score for eviction (lower score = higher eviction priority)
  static double calculateEvictionScore({
    required EvictionPolicy policy,
    required DateTime createdAt,
    required DateTime lastAccessed,
    required int accessCount,
    required int size,
    Duration? ttl,
  }) {
    final now = DateTime.now();
    final age = now.difference(createdAt);
    final timeSinceAccess = now.difference(lastAccessed);

    switch (policy) {
      case EvictionPolicy.lru:
        return timeSinceAccess.inMilliseconds.toDouble();

      case EvictionPolicy.lfu:
        return accessCount.toDouble();

      case EvictionPolicy.fifo:
        return age.inMilliseconds.toDouble();

      case EvictionPolicy.arc:
        // ARC balances recency and frequency
        final frequencyScore = accessCount / age.inMinutes.clamp(1, double.infinity);
        final recencyScore = 1.0 / (timeSinceAccess.inMinutes + 1);
        return frequencyScore * 0.6 + recencyScore * 0.4;

      case EvictionPolicy.ttl:
        if (ttl != null) {
          final remainingTime = createdAt.add(ttl).difference(now);
          return remainingTime.inMilliseconds.toDouble();
        }
        return age.inMilliseconds.toDouble();

      case EvictionPolicy.size:
        return -size.toDouble(); // Negative so larger items have lower scores

      case EvictionPolicy.random:
        return (DateTime.now().millisecondsSinceEpoch % 1000).toDouble();
    }
  }

  /// Predicts cache hit probability for prefetching decisions
  static double predictHitProbability({
    required String key,
    required Map<String, int> accessHistory,
    required Map<String, DateTime> lastAccessTimes,
    Duration lookbackPeriod = const Duration(hours: 24),
  }) {
    final now = DateTime.now();
    final cutoff = now.subtract(lookbackPeriod);

    // Historical access frequency
    final totalAccesses = accessHistory[key] ?? 0;
    final lastAccess = lastAccessTimes[key];

    if (lastAccess == null || lastAccess.isBefore(cutoff)) {
      return 0.1; // Low probability for stale entries
    }

    // Calculate frequency score
    final timeSinceLastAccess = now.difference(lastAccess);
    final accessFrequency = totalAccesses / lookbackPeriod.inHours;

    // Decay probability over time
    final decayFactor = 1.0 / (1.0 + timeSinceLastAccess.inHours / 24.0);

    return (accessFrequency * decayFactor).clamp(0.0, 1.0);
  }

  /// Calculates optimal cache size based on usage patterns
  static int calculateOptimalSize({
    required Map<String, int> accessHistory,
    required Map<String, int> sizeHistory,
    required double hitRateTarget,
    int currentSize = 100,
  }) {
    if (accessHistory.isEmpty) return currentSize;

    // Sort entries by access frequency
    final sortedEntries = accessHistory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    int cumulativeSize = 0;
    int hitCount = 0;
    final totalAccesses = accessHistory.values.reduce((a, b) => a + b);

    for (final entry in sortedEntries) {
      cumulativeSize += sizeHistory[entry.key] ?? 1024; // Default 1KB
      hitCount += entry.value;

      final hitRate = hitCount / totalAccesses;

      if (hitRate >= hitRateTarget) {
        // Add 20% buffer for variations
        return (cumulativeSize * 1.2).round();
      }
    }

    // If target not achievable, return size for 80% coverage
    return (cumulativeSize * 0.8).round();
  }
}

/// Cache warming strategies
abstract class CacheWarmingStrategy {
  Future<Map<String, dynamic>> getWarmingData();
  double getPriority(String key);
}

/// LRU-based warming strategy
class LRUWarmingStrategy implements CacheWarmingStrategy {
  final Map<String, DateTime> _lastAccessTimes;
  final Map<String, dynamic> _cachedData;

  LRUWarmingStrategy(this._lastAccessTimes, this._cachedData);

  @override
  Future<Map<String, dynamic>> getWarmingData() async {
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(hours: 24));

    return Map.fromEntries(
      _lastAccessTimes.entries
          .where((entry) => entry.value.isAfter(cutoff))
          .where((entry) => _cachedData.containsKey(entry.key))
          .map((entry) => MapEntry(entry.key, _cachedData[entry.key]))
    );
  }

  @override
  double getPriority(String key) {
    final lastAccess = _lastAccessTimes[key];
    if (lastAccess == null) return 0.0;

    final timeSinceAccess = DateTime.now().difference(lastAccess);
    return 1.0 / (1.0 + timeSinceAccess.inHours);
  }
}

/// Predictive warming strategy based on usage patterns
class PredictiveWarmingStrategy implements CacheWarmingStrategy {
  final Map<String, List<DateTime>> _accessPatterns;
  final Map<String, dynamic> _cachedData;

  PredictiveWarmingStrategy(this._accessPatterns, this._cachedData);

  @override
  Future<Map<String, dynamic>> getWarmingData() async {
    final predictions = <String, double>{};

    for (final entry in _accessPatterns.entries) {
      predictions[entry.key] = _predictNextAccess(entry.key, entry.value);
    }

    // Return top 50% predicted keys
    final sortedPredictions = predictions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topKeys = sortedPredictions
        .take(sortedPredictions.length ~/ 2)
        .map((e) => e.key)
        .where((key) => _cachedData.containsKey(key));

    return Map.fromEntries(
      topKeys.map((key) => MapEntry(key, _cachedData[key]))
    );
  }

  @override
  double getPriority(String key) {
    final accessTimes = _accessPatterns[key];
    if (accessTimes == null || accessTimes.isEmpty) return 0.0;

    return _predictNextAccess(key, accessTimes);
  }

  double _predictNextAccess(String key, List<DateTime> accessTimes) {
    if (accessTimes.length < 2) return 0.1;

    // Calculate access intervals
    final intervals = <Duration>[];
    for (int i = 1; i < accessTimes.length; i++) {
      intervals.add(accessTimes[i].difference(accessTimes[i - 1]));
    }

    // Calculate average interval
    final avgInterval = Duration(
      milliseconds: intervals
          .map((d) => d.inMilliseconds)
          .reduce((a, b) => a + b) ~/ intervals.length
    );

    // Predict next access time
    final lastAccess = accessTimes.last;
    final predictedNextAccess = lastAccess.add(avgInterval);
    final timeToPredicted = predictedNextAccess.difference(DateTime.now());

    // Return probability based on how soon we expect the next access
    if (timeToPredicted.isNegative) return 0.9; // Overdue
    if (timeToPredicted.inMinutes < 60) return 0.8; // Within hour
    if (timeToPredicted.inHours < 24) return 0.5; // Within day
    return 0.1; // Far future
  }
}

/// Cache partitioning strategies for better performance
class CachePartitioningStrategy {
  /// Partitions cache keys based on access patterns
  static Map<String, List<String>> partitionByAccessPattern({
    required Map<String, int> accessHistory,
    int partitions = 4,
  }) {
    final result = <String, List<String>>{};

    if (accessHistory.isEmpty) return result;

    final sortedEntries = accessHistory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final partitionSize = sortedEntries.length ~/ partitions;

    for (int i = 0; i < partitions; i++) {
      final partitionName = _getPartitionName(i, partitions);
      final start = i * partitionSize;
      final end = (i == partitions - 1)
          ? sortedEntries.length
          : (i + 1) * partitionSize;

      result[partitionName] = sortedEntries
          .skip(start)
          .take(end - start)
          .map((e) => e.key)
          .toList();
    }

    return result;
  }

  /// Partitions cache keys by key prefix
  static Map<String, List<String>> partitionByPrefix(List<String> keys) {
    final result = <String, List<String>>{};

    for (final key in keys) {
      final prefix = key.contains(':') ? key.split(':')[0] : 'default';
      result.putIfAbsent(prefix, () => <String>[]).add(key);
    }

    return result;
  }

  static String _getPartitionName(int index, int total) {
    switch (index) {
      case 0:
        return 'hot'; // Most frequently accessed
      case 1:
        return 'warm'; // Moderately accessed
      default:
        return index == total - 1 ? 'cold' : 'tier_$index'; // Least accessed
    }
  }
}