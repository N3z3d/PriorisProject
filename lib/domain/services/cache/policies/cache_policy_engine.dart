import 'dart:collection';
import '../interfaces/cache_system_interfaces.dart';
import '../core/cache_entry.dart';

/// SOLID implementation of cache policy engine
/// Single Responsibility: Managing cache eviction policies and TTL rules
class CachePolicyEngine implements ICachePolicyEngine {
  final CacheStrategy strategy;
  final Duration defaultTTL;

  // LFU-specific tracking
  final SplayTreeMap<int, Set<String>> _frequencyMap = SplayTreeMap();
  int _minFrequency = 0;

  // Adaptive scoring cache
  final Map<String, double> _adaptiveScores = {};

  // Policy statistics
  int _evictionCount = 0;
  int _ttlExpirationCount = 0;
  int _policyViolationCount = 0;

  CachePolicyEngine({
    required this.strategy,
    required this.defaultTTL,
  });

  @override
  bool shouldEvict(String key, ICacheEntry entry) {
    // Always evict expired entries
    if (entry.isExpired) {
      _ttlExpirationCount++;
      return true;
    }

    // Strategy-specific eviction logic
    switch (strategy) {
      case CacheStrategy.ttl:
        return entry.isExpired;
      case CacheStrategy.lru:
      case CacheStrategy.lfu:
      case CacheStrategy.adaptive:
        // These strategies handle eviction through candidate selection
        return false;
    }
  }

  @override
  String? getEvictionCandidate(Map<String, ICacheEntry> entries) {
    if (entries.isEmpty) return null;

    switch (strategy) {
      case CacheStrategy.lru:
        return _getLRUCandidate(entries);
      case CacheStrategy.lfu:
        return _getLFUCandidate(entries);
      case CacheStrategy.ttl:
        return _getTTLCandidate(entries);
      case CacheStrategy.adaptive:
        return _getAdaptiveCandidate(entries);
    }
  }

  String? _getLRUCandidate(Map<String, ICacheEntry> entries) {
    String? oldestKey;
    DateTime? oldestTime;

    entries.forEach((key, entry) {
      if (oldestTime == null || entry.lastAccessed.isBefore(oldestTime!)) {
        oldestTime = entry.lastAccessed;
        oldestKey = key;
      }
    });

    return oldestKey;
  }

  String? _getLFUCandidate(Map<String, ICacheEntry> entries) {
    if (_frequencyMap.isEmpty) return null;

    final leastFreqKeys = _frequencyMap[_minFrequency];
    if (leastFreqKeys == null || leastFreqKeys.isEmpty) return null;

    // Among least frequent, choose the oldest accessed
    String? candidate;
    DateTime? oldestTime;

    for (final key in leastFreqKeys) {
      final entry = entries[key];
      if (entry != null) {
        if (oldestTime == null || entry.lastAccessed.isBefore(oldestTime)) {
          oldestTime = entry.lastAccessed;
          candidate = key;
        }
      }
    }

    return candidate;
  }

  String? _getTTLCandidate(Map<String, ICacheEntry> entries) {
    // First, try to find expired entries
    for (final entry in entries.entries) {
      if (entry.value.isExpired) {
        return entry.key;
      }
    }

    // If no expired entries, choose the one expiring soonest
    String? soonestKey;
    DateTime? soonestExpiry;

    entries.forEach((key, entry) {
      if (entry.expiresAt != null) {
        if (soonestExpiry == null || entry.expiresAt!.isBefore(soonestExpiry!)) {
          soonestExpiry = entry.expiresAt;
          soonestKey = key;
        }
      }
    });

    // If no TTL entries, fall back to oldest created
    if (soonestKey == null) {
      DateTime? oldestCreated;
      entries.forEach((key, entry) {
        if (oldestCreated == null || entry.created.isBefore(oldestCreated!)) {
          oldestCreated = entry.created;
          soonestKey = key;
        }
      });
    }

    return soonestKey;
  }

  String? _getAdaptiveCandidate(Map<String, ICacheEntry> entries) {
    if (_adaptiveScores.isEmpty) return null;

    String? lowestKey;
    double lowestScore = double.infinity;

    _adaptiveScores.forEach((key, score) {
      if (entries.containsKey(key) && score < lowestScore) {
        lowestScore = score;
        lowestKey = key;
      }
    });

    return lowestKey;
  }

  @override
  void updateEntryOnAccess(String key, ICacheEntry entry) {
    entry.updateAccess();

    switch (strategy) {
      case CacheStrategy.lfu:
        _updateLFUFrequency(key, entry);
        break;
      case CacheStrategy.adaptive:
        _updateAdaptiveScore(key, entry);
        break;
      default:
        // LRU and TTL don't need special update logic
        break;
    }
  }

  @override
  void updateEntryOnCreate(String key, ICacheEntry entry) {
    switch (strategy) {
      case CacheStrategy.lfu:
        _frequencyMap.putIfAbsent(1, () => {}).add(key);
        _minFrequency = 1;
        break;
      case CacheStrategy.adaptive:
        _adaptiveScores[key] = entry.priority.toDouble() + 1.0;
        break;
      default:
        break;
    }
  }

  void _updateLFUFrequency(String key, ICacheEntry entry) {
    final oldFreq = entry.frequency;
    final newFreq = oldFreq + 1;

    // Remove from old frequency bucket
    _frequencyMap[oldFreq]?.remove(key);
    if (_frequencyMap[oldFreq]?.isEmpty ?? false) {
      _frequencyMap.remove(oldFreq);
      if (_minFrequency == oldFreq) {
        _minFrequency = _frequencyMap.isEmpty ? 0 : _frequencyMap.keys.first;
      }
    }

    // Add to new frequency bucket
    _frequencyMap.putIfAbsent(newFreq, () => {}).add(key);
    entry.incrementFrequency();
  }

  void _updateAdaptiveScore(String key, ICacheEntry entry) {
    if (entry is CacheEntry) {
      _adaptiveScores[key] = entry.calculateAdaptiveScore();
    } else {
      // Fallback scoring for non-CacheEntry implementations
      final now = DateTime.now();
      final age = now.difference(entry.lastAccessed).inSeconds + 1;
      final frequency = entry.frequency + 1;
      final priority = entry.priority;
      final sizeWeight = 1.0 / (entry.sizeBytes / 1024 + 1);

      final score = (frequency * 10.0) / age +
                    (priority * 5.0) +
                    sizeWeight * 2.0;

      _adaptiveScores[key] = score;
    }
  }

  /// Remove entry from policy tracking
  void removeEntry(String key, ICacheEntry entry) {
    switch (strategy) {
      case CacheStrategy.lfu:
        _removeLFUEntry(key, entry);
        break;
      case CacheStrategy.adaptive:
        _adaptiveScores.remove(key);
        break;
      default:
        break;
    }
    _evictionCount++;
  }

  void _removeLFUEntry(String key, ICacheEntry entry) {
    _frequencyMap[entry.frequency]?.remove(key);
    if (_frequencyMap[entry.frequency]?.isEmpty ?? false) {
      _frequencyMap.remove(entry.frequency);
    }
  }

  /// Validate policy consistency
  bool validatePolicy(Map<String, ICacheEntry> entries) {
    switch (strategy) {
      case CacheStrategy.lfu:
        return _validateLFUConsistency(entries);
      case CacheStrategy.adaptive:
        return _validateAdaptiveConsistency(entries);
      default:
        return true;
    }
  }

  bool _validateLFUConsistency(Map<String, ICacheEntry> entries) {
    // Verify frequency map consistency
    final entriesInFreqMap = <String>{};
    _frequencyMap.forEach((freq, keys) {
      entriesInFreqMap.addAll(keys);
    });

    final actualEntries = entries.keys.toSet();
    final consistent = entriesInFreqMap.containsAll(actualEntries) &&
                      actualEntries.containsAll(entriesInFreqMap);

    if (!consistent) {
      _policyViolationCount++;
    }

    return consistent;
  }

  bool _validateAdaptiveConsistency(Map<String, ICacheEntry> entries) {
    final scoredKeys = _adaptiveScores.keys.toSet();
    final actualKeys = entries.keys.toSet();
    final consistent = scoredKeys.containsAll(actualKeys) &&
                      actualKeys.containsAll(scoredKeys);

    if (!consistent) {
      _policyViolationCount++;
    }

    return consistent;
  }

  @override
  Map<String, dynamic> getPolicyStats() {
    final baseStats = {
      'strategy': strategy.name,
      'defaultTTL': defaultTTL.inMilliseconds,
      'evictionCount': _evictionCount,
      'ttlExpirationCount': _ttlExpirationCount,
      'policyViolationCount': _policyViolationCount,
    };

    switch (strategy) {
      case CacheStrategy.lfu:
        baseStats.addAll(_getLFUStats().cast<String, Object>());
        break;
      case CacheStrategy.adaptive:
        baseStats.addAll(_getAdaptiveStats().cast<String, Object>());
        break;
      default:
        break;
    }

    return baseStats;
  }

  Map<String, dynamic> _getLFUStats() {
    return {
      'minFrequency': _minFrequency,
      'frequencyDistribution': Map.fromEntries(
        _frequencyMap.entries.map((e) => MapEntry(e.key, e.value.length))
      ),
      'totalTrackedEntries': _frequencyMap.values
          .fold<int>(0, (sum, keys) => sum + keys.length),
    };
  }

  Map<String, dynamic> _getAdaptiveStats() {
    double avgScore = 0;
    double maxScore = 0;
    double minScore = double.infinity;

    if (_adaptiveScores.isNotEmpty) {
      avgScore = _adaptiveScores.values.reduce((a, b) => a + b) / _adaptiveScores.length;
      maxScore = _adaptiveScores.values.reduce((a, b) => a > b ? a : b);
      minScore = _adaptiveScores.values.reduce((a, b) => a < b ? a : b);
    }

    return {
      'averageScore': avgScore,
      'maxScore': maxScore,
      'minScore': minScore == double.infinity ? 0 : minScore,
      'scoredEntries': _adaptiveScores.length,
      'scoreDistribution': _getScoreDistribution(),
    };
  }

  Map<String, int> _getScoreDistribution() {
    final distribution = <String, int>{
      'low': 0,      // 0-10
      'medium': 0,   // 10-50
      'high': 0,     // 50+
    };

    _adaptiveScores.values.forEach((score) {
      if (score < 10) {
        distribution['low'] = distribution['low']! + 1;
      } else if (score < 50) {
        distribution['medium'] = distribution['medium']! + 1;
      } else {
        distribution['high'] = distribution['high']! + 1;
      }
    });

    return distribution;
  }

  /// Reset policy state
  void reset() {
    _frequencyMap.clear();
    _adaptiveScores.clear();
    _minFrequency = 0;
    _evictionCount = 0;
    _ttlExpirationCount = 0;
    _policyViolationCount = 0;
  }

  /// Optimize policy data structures
  void optimize() {
    switch (strategy) {
      case CacheStrategy.lfu:
        _optimizeLFU();
        break;
      case CacheStrategy.adaptive:
        _optimizeAdaptive();
        break;
      default:
        break;
    }
  }

  void _optimizeLFU() {
    // Remove empty frequency buckets
    final emptyFrequencies = <int>[];
    _frequencyMap.forEach((freq, keys) {
      if (keys.isEmpty) {
        emptyFrequencies.add(freq);
      }
    });

    for (final freq in emptyFrequencies) {
      _frequencyMap.remove(freq);
    }

    // Update min frequency if needed
    if (_frequencyMap.isNotEmpty) {
      _minFrequency = _frequencyMap.keys.first;
    } else {
      _minFrequency = 0;
    }
  }

  void _optimizeAdaptive() {
    // Remove stale scores (this would normally be done when entries are removed)
    // This is a safety measure for consistency
    final staleScoredKeys = <String>[];
    _adaptiveScores.forEach((key, score) {
      // Mark extremely low scores for removal (they likely represent removed entries)
      if (score < -1000) {
        staleScoredKeys.add(key);
      }
    });

    for (final key in staleScoredKeys) {
      _adaptiveScores.remove(key);
    }
  }
}