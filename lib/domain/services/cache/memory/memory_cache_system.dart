import 'dart:collection';
import '../interfaces/cache_system_interfaces.dart';
import '../core/cache_entry.dart';
import '../policies/cache_policy_engine.dart';

/// SOLID implementation of memory cache system
/// Single Responsibility: In-memory cache operations with different strategies
class MemoryCacheSystem implements IMemoryCacheSystem {
  final int maxSizeMB;
  final CachePolicyEngine _policyEngine;
  final Map<String, ICacheEntry> _cache;

  int _currentSizeBytes = 0;

  MemoryCacheSystem({
    required this.maxSizeMB,
    required CacheStrategy strategy,
    required Duration defaultTTL,
  }) : _policyEngine = CachePolicyEngine(strategy: strategy, defaultTTL: defaultTTL),
       _cache = strategy == CacheStrategy.lru
           ? LinkedHashMap<String, ICacheEntry>()
           : <String, ICacheEntry>{};

  @override
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    // Check expiration
    if (entry.isExpired) {
      remove(key);
      return null;
    }

    // Update policy tracking
    _policyEngine.updateEntryOnAccess(key, entry);

    // For LRU, move to end (most recent)
    if (_cache is LinkedHashMap) {
      final lruCache = _cache as LinkedHashMap<String, ICacheEntry>;
      final movedEntry = lruCache.remove(key)!;
      lruCache[key] = movedEntry;
    }

    return entry.value as T?;
  }

  @override
  void set<T>(String key, T value, {Duration? ttl, int? priority}) {
    final sizeBytes = CacheSizeEstimator.estimateSize(value);

    // Validate size is reasonable
    if (!CacheSizeEstimator.isReasonableSize(sizeBytes, maxSizeMB: maxSizeMB)) {
      throw CacheException(
        'Entry size ${CacheSizeEstimator.formatSize(sizeBytes)} exceeds reasonable limits',
        operation: 'set',
        key: key,
      );
    }

    // Make space if necessary
    while (!hasSpace(sizeBytes) && _cache.isNotEmpty) {
      final candidateKey = _policyEngine.getEvictionCandidate(_cache);
      if (candidateKey != null) {
        remove(candidateKey);
      } else {
        // Fallback eviction if policy fails
        _fallbackEviction();
      }
    }

    // Remove old entry if exists
    final oldEntry = _cache.remove(key);
    if (oldEntry != null) {
      _currentSizeBytes -= oldEntry.sizeBytes;
      _policyEngine.removeEntry(key, oldEntry);
    }

    // Create and add new entry
    final entry = CacheEntry(
      value: value,
      sizeBytes: sizeBytes,
      ttl: ttl ?? _policyEngine.defaultTTL,
      priority: priority ?? 0,
    );

    _cache[key] = entry;
    _currentSizeBytes += sizeBytes;
    _policyEngine.updateEntryOnCreate(key, entry);
  }

  void _fallbackEviction() {
    if (_cache.isEmpty) return;

    // Simple fallback: remove first entry
    final firstKey = _cache.keys.first;
    remove(firstKey);
  }

  @override
  void remove(String key) {
    final entry = _cache.remove(key);
    if (entry != null) {
      _currentSizeBytes -= entry.sizeBytes;
      _policyEngine.removeEntry(key, entry);
    }
  }

  @override
  void removeWhere(bool Function(String) test) {
    final keysToRemove = _cache.keys.where(test).toList();
    for (final key in keysToRemove) {
      remove(key);
    }
  }

  @override
  void clear() {
    _cache.clear();
    _currentSizeBytes = 0;
    _policyEngine.reset();
  }

  @override
  bool hasSpace(int sizeBytes) {
    return (_currentSizeBytes + sizeBytes) <= (maxSizeMB * 1024 * 1024);
  }

  @override
  int get currentSizeBytes => _currentSizeBytes;

  @override
  double get utilization {
    final maxBytes = maxSizeMB * 1024 * 1024;
    return maxBytes > 0 ? _currentSizeBytes / maxBytes : 0.0;
  }

  @override
  Map<String, dynamic> getStats() {
    final expiredCount = _cache.values.where((entry) => entry.isExpired).length;

    return {
      'type': 'Memory',
      'strategy': _policyEngine.strategy.name,
      'entries': _cache.length,
      'expiredEntries': expiredCount,
      'sizeBytes': _currentSizeBytes,
      'sizeMB': _currentSizeBytes / (1024 * 1024),
      'maxSizeMB': maxSizeMB,
      'utilization': utilization,
      'utilizationPercentage': (utilization * 100).toStringAsFixed(1) + '%',
      'averageEntrySize': _cache.isNotEmpty
          ? _currentSizeBytes / _cache.length
          : 0,
      'policyStats': _policyEngine.getPolicyStats(),
      'consistency': _validateConsistency(),
    };
  }

  /// Validate internal consistency
  Map<String, dynamic> _validateConsistency() {
    final issues = <String>[];

    // Check size consistency
    int calculatedSize = 0;
    _cache.values.forEach((entry) {
      calculatedSize += entry.sizeBytes;
    });

    final sizeConsistent = calculatedSize == _currentSizeBytes;
    if (!sizeConsistent) {
      issues.add('Size inconsistency: calculated=$calculatedSize, tracked=$_currentSizeBytes');
    }

    // Check policy consistency
    final policyConsistent = _policyEngine.validatePolicy(_cache);
    if (!policyConsistent) {
      issues.add('Policy tracking inconsistency detected');
    }

    // Check memory bounds
    final withinBounds = _currentSizeBytes <= (maxSizeMB * 1024 * 1024);
    if (!withinBounds) {
      issues.add('Memory usage exceeds configured limit');
    }

    return {
      'isConsistent': issues.isEmpty,
      'issues': issues,
      'sizeConsistent': sizeConsistent,
      'policyConsistent': policyConsistent,
      'withinBounds': withinBounds,
    };
  }

  /// Optimize cache by removing expired entries and reorganizing data
  void optimize() {
    // Remove expired entries
    final expiredKeys = <String>[];
    _cache.forEach((key, entry) {
      if (entry.isExpired) {
        expiredKeys.add(key);
      }
    });

    for (final key in expiredKeys) {
      remove(key);
    }

    // Optimize policy engine
    _policyEngine.optimize();
  }

  /// Get memory usage breakdown
  Map<String, dynamic> getMemoryBreakdown() {
    final breakdown = <String, dynamic>{
      'totalEntries': _cache.length,
      'totalSizeBytes': _currentSizeBytes,
      'averageEntrySize': _cache.isNotEmpty ? _currentSizeBytes / _cache.length : 0,
      'sizeDistribution': _getSizeDistribution(),
      'typeDistribution': _getTypeDistribution(),
    };

    return breakdown;
  }

  Map<String, int> _getSizeDistribution() {
    final distribution = <String, int>{
      'tiny': 0,    // < 1KB
      'small': 0,   // 1KB - 10KB
      'medium': 0,  // 10KB - 100KB
      'large': 0,   // > 100KB
    };

    _cache.values.forEach((entry) {
      final sizeKB = entry.sizeBytes / 1024;
      if (sizeKB < 1) {
        distribution['tiny'] = distribution['tiny']! + 1;
      } else if (sizeKB < 10) {
        distribution['small'] = distribution['small']! + 1;
      } else if (sizeKB < 100) {
        distribution['medium'] = distribution['medium']! + 1;
      } else {
        distribution['large'] = distribution['large']! + 1;
      }
    });

    return distribution;
  }

  Map<String, int> _getTypeDistribution() {
    final distribution = <String, int>{};

    _cache.values.forEach((entry) {
      final type = entry.value.runtimeType.toString();
      distribution[type] = (distribution[type] ?? 0) + 1;
    });

    return distribution;
  }

  /// Get entries sorted by different criteria
  List<MapEntry<String, ICacheEntry>> getSortedEntries(SortCriteria criteria) {
    final entries = _cache.entries.toList();

    switch (criteria) {
      case SortCriteria.bySize:
        entries.sort((a, b) => b.value.sizeBytes.compareTo(a.value.sizeBytes));
        break;
      case SortCriteria.byAge:
        entries.sort((a, b) => a.value.created.compareTo(b.value.created));
        break;
      case SortCriteria.byLastAccessed:
        entries.sort((a, b) => b.value.lastAccessed.compareTo(a.value.lastAccessed));
        break;
      case SortCriteria.byFrequency:
        entries.sort((a, b) => b.value.frequency.compareTo(a.value.frequency));
        break;
    }

    return entries;
  }

  /// Create a snapshot of current cache state
  MemoryCacheSnapshot createSnapshot() {
    return MemoryCacheSnapshot(
      timestamp: DateTime.now(),
      entryCount: _cache.length,
      totalSizeBytes: _currentSizeBytes,
      utilization: utilization,
      strategy: _policyEngine.strategy,
      entries: Map.fromEntries(
        _cache.entries.map((entry) => MapEntry(
          entry.key,
          {
            'size': entry.value.sizeBytes,
            'created': entry.value.created,
            'lastAccessed': entry.value.lastAccessed,
            'frequency': entry.value.frequency,
            'isExpired': entry.value.isExpired,
          },
        )),
      ),
    );
  }
}

enum SortCriteria {
  bySize,
  byAge,
  byLastAccessed,
  byFrequency,
}

/// Immutable snapshot of memory cache state
class MemoryCacheSnapshot {
  final DateTime timestamp;
  final int entryCount;
  final int totalSizeBytes;
  final double utilization;
  final CacheStrategy strategy;
  final Map<String, Map<String, dynamic>> entries;

  const MemoryCacheSnapshot({
    required this.timestamp,
    required this.entryCount,
    required this.totalSizeBytes,
    required this.utilization,
    required this.strategy,
    required this.entries,
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'entryCount': entryCount,
      'totalSizeBytes': totalSizeBytes,
      'totalSizeMB': totalSizeBytes / (1024 * 1024),
      'utilization': utilization,
      'strategy': strategy.name,
      'entries': entries,
    };
  }
}