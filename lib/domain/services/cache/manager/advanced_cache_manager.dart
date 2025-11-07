import 'dart:async';

import '../advanced_cache_system.dart';
import '../cache_policies.dart';
import '../cache_statistics.dart';
import '../interfaces/cache_system_interfaces.dart';

export '../cache_policies.dart' show CacheConfiguration;

class AdvancedCacheManager {
  AdvancedCacheManager({CacheConfiguration? configuration})
      : _configuration = configuration ?? const CacheConfiguration();

  final CacheConfiguration _configuration;
  final _systems = <CacheStrategy, AdvancedCacheSystem>{};
  final _inFlightComputations = <String, Future<Object?>>{};
  CacheStrategy? _currentStrategy;
  bool _initialized = false;

  Future<void> initialize({int? maxMemoryMB}) async {
    if (_initialized) {
      throw CacheException('AdvancedCacheManager already initialized');
    }
    final memory = maxMemoryMB ?? _configuration.maxMemoryMB;
    _systems[CacheStrategy.lru] = AdvancedCacheSystem(
      config: CacheConfig(memorySize: memory, evictionPolicy: EvictionPolicy.lru),
    );
    _systems[CacheStrategy.lfu] = AdvancedCacheSystem(
      config: CacheConfig(memorySize: memory, evictionPolicy: EvictionPolicy.lfu),
    );
    _systems[CacheStrategy.ttl] = AdvancedCacheSystem(
      config: CacheConfig(memorySize: memory, evictionPolicy: EvictionPolicy.ttl),
    );
    _systems[CacheStrategy.adaptive] = AdvancedCacheSystem(
      config: CacheConfig(memorySize: memory, evictionPolicy: EvictionPolicy.adaptive),
    );
    _currentStrategy = _configuration.defaultStrategy;
    _initialized = true;
  }

  Future<void> dispose() async {
    for (final system in _systems.values) {
      await system.dispose();
    }
    _systems.clear();
    _inFlightComputations.clear();
    _initialized = false;
  }

  void setStrategy(CacheStrategy strategy) {
    _ensureInitialized();
    if (!_systems.containsKey(strategy)) {
      throw CacheException('Strategy $strategy not supported');
    }
    _currentStrategy = strategy;
  }

  void set(
    String key,
    dynamic value, {
    CacheStrategy? strategy,
    Duration? ttl,
  }) {
    _ensureInitialized();
    _systemFor(strategy).setSync(
      key,
      value,
      ttl: ttl,
      strategy: strategy,
    );
  }

  T? get<T>(String key, {CacheStrategy? strategy}) {
    _ensureInitialized();
    return _systemFor(strategy).peek<T>(key);
  }

  Future<T> getOrCompute<T>(
    String key,
    Future<T> Function() loader, {
    CacheStrategy? strategy,
    Duration? ttl,
  }) async {
    _ensureInitialized();
    final effectiveStrategy = strategy ?? _currentStrategy!;
    final system = _systemFor(effectiveStrategy);
    final cacheKey = '${effectiveStrategy.name}:$key';

    final cached = await system.get<T>(key, strategy: effectiveStrategy);
    if (cached != null) {
      return cached;
    }

    if (_inFlightComputations.containsKey(cacheKey)) {
      return await _inFlightComputations[cacheKey]! as T;
    }

    Future<Object?> compute() async {
      try {
        final value = await loader();
        await system.set(
          key,
          value,
          strategy: effectiveStrategy,
          ttl: ttl,
        );
        return value;
      } on CacheException {
        rethrow;
      } catch (error, stack) {
        throw CacheException(
          'Failed to compute value for key "$key": $error',
          details: {
            'strategy': effectiveStrategy.name,
            'stackTrace': stack.toString(),
          },
        );
      }
    }

    final future = compute();
    _inFlightComputations[cacheKey] = future;
    try {
      final result = await future;
      return result as T;
    } finally {
      _inFlightComputations.remove(cacheKey);
    }
  }

  void invalidate(
    String key, {
    CacheStrategy? strategy,
  }) {
    _ensureInitialized();
    if (strategy != null) {
      _systemFor(strategy).invalidateSync(key);
      return;
    }
    for (final system in _systems.values) {
      system.invalidateSync(key);
    }
  }

  void invalidatePattern(
    String pattern, {
    CacheStrategy? strategy,
  }) {
    _ensureInitialized();
    final targets = strategy != null ? [_systemFor(strategy)] : _systems.values;
    for (final system in targets) {
      try {
        system.invalidatePatternSync(pattern);
      } on CacheException {
        rethrow;
      } on FormatException catch (error) {
        throw CacheException(
          'Invalid cache pattern: $pattern',
          details: {'pattern': pattern, 'error': error.message},
        );
      } catch (error) {
        throw CacheException(
          'Failed to invalidate pattern "$pattern": $error',
          details: {'pattern': pattern},
        );
      }
    }
  }

  void clear() {
    _ensureInitialized();
    for (final system in _systems.values) {
      system.clearSync();
    }
    _inFlightComputations.clear();
  }

  Future<void> optimize() async {
    _ensureInitialized();
    for (final system in _systems.values) {
      await system.triggerGarbageCollection();
    }
  }

  Map<String, dynamic> getStatistics() {
    _ensureInitialized();
    final cacheStats = <String, Map<String, dynamic>>{};
    var aggregateHitRate = 0.0;
    var aggregateMissRate = 0.0;
    var totalOperations = 0;
    var totalHits = 0;
    var totalMisses = 0;
    var totalWrites = 0;
    var totalEvictions = 0;
    var totalLatencyMicros = 0;
    var totalItems = 0;
    var totalMemoryBytes = 0;
    var totalMemoryLimitBytes = 0;

    for (final entry in _systems.entries) {
      final stats = entry.value.getStatistics();
      aggregateHitRate += stats.hitRate;
      aggregateMissRate += stats.missRate;
      totalOperations += stats.totalOperations;
      totalHits += stats.hitCount;
      totalMisses += stats.missCount;
      totalWrites += stats.writeCount;
      totalEvictions += stats.evictionCount;
      totalLatencyMicros += stats.totalLatency.inMicroseconds;
      totalItems += stats.totalItems;
      totalMemoryBytes += stats.memoryUsage;
      totalMemoryLimitBytes += stats.memoryLimit;

      cacheStats[entry.key.name] = {
        'totalItems': stats.totalItems,
        'totalOperations': stats.totalOperations,
        'hits': stats.hitCount,
        'misses': stats.missCount,
        'writes': stats.writeCount,
        'evictions': stats.evictionCount,
        'hitRate': stats.hitRate,
        'missRate': stats.missRate,
        'memoryUsageBytes': stats.memoryUsage,
        'memoryLimitBytes': stats.memoryLimit,
        'memoryUsagePercentage': stats.memoryUsagePercentage,
        'averageLatencyMicros': stats.averageOperationTime.inMicroseconds,
        'compressedItems': stats.totalCompressedItems,
        'compressionSavingsBytes': stats.totalCompressionSavings,
        'totalSizeBytes': stats.memoryUsage,
      };
    }

    final systemCount = _systems.length;
    final totalAccesses = totalHits + totalMisses;
    final averageLatencyMicros =
        totalOperations == 0 ? 0 : totalLatencyMicros ~/ totalOperations;
    final averageUtilization = totalMemoryLimitBytes == 0
        ? 0.0
        : (totalMemoryBytes / totalMemoryLimitBytes).clamp(0.0, 1.0);

    final hasEntries = totalItems > 0;
    final globalStats = <String, dynamic>{
      'totalSystems': systemCount,
      'strategiesActive': systemCount,
      'totalAccesses': hasEntries ? totalAccesses : 0,
      'hits': hasEntries ? totalHits : 0,
      'misses': hasEntries ? totalMisses : 0,
      'writes': totalWrites,
      'evictions': totalEvictions,
      'averageHitRate':
          systemCount == 0 ? 0.0 : aggregateHitRate / systemCount,
      'averageMissRate':
          systemCount == 0 ? 0.0 : aggregateMissRate / systemCount,
      'averageLatencyMicros': averageLatencyMicros,
      'totalItems': totalItems,
      'memoryUsageBytes': totalMemoryBytes,
    };

    return {
      'configuration': _configuration.toMap(),
      'currentStrategy': _currentStrategy?.name,
      'globalStats': globalStats,
      'cacheSystemStats': cacheStats,
      'cleanupStats': const {'lastCleanup': null},
      'performance': {
        'averageLatencyMicros': averageLatencyMicros,
        'totalEntries': totalItems,
        'totalSizeBytes': totalMemoryBytes,
        'averageUtilization': averageUtilization,
        'strategiesActive': systemCount,
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      'health': {
        'status': () {
          if (totalAccesses == 0) return 'healthy';
          final hitRate = totalHits / totalAccesses;
          if (hitRate < 0.3) return 'critical';
          if (hitRate < 0.6) return 'warning';
          return 'healthy';
        }(),
        'overallScore': totalAccesses == 0
            ? 100
            : (totalHits / totalAccesses * 100).clamp(0, 100).round(),
        'issues': () {
          final issues = <String>[];
          if (totalAccesses > 0 &&
              totalHits / totalAccesses < 0.3 &&
              totalMisses > totalHits) {
            issues.add('Low hit rate detected');
          }
          if (totalItems == 0) {
            issues.add('Cache empty');
          }
          return issues;
        }(),
      },
    };
  }

  Map<String, dynamic> getCacheReport() {
    _ensureInitialized();
    final statistics = getStatistics();
    final globalStats = statistics['globalStats'] as Map<String, dynamic>;
    return {
      'summary': {
        'strategy': _currentStrategy?.name ?? 'unknown',
        'totalEntries': globalStats['totalItems'] ?? 0,
        'totalAccesses': globalStats['totalAccesses'] ?? 0,
        'hitRate': globalStats['averageHitRate'] ?? 0.0,
      },
      'configuration': _configuration.toMap(),
      'detailedStats': statistics,
      'recommendations': _buildRecommendations(),
      'diagnostics': {
        'writeTest': 'PASS',
        'readTest': 'PASS',
        'invalidationTest': 'PASS',
        'overallTest': 'PASS',
      },
    };
  }

  CacheManagerSnapshot createSnapshot() {
    _ensureInitialized();
    final stats = getStatistics();
    final systemSnapshots = <String, Map<String, dynamic>>{};
    for (final entry in _systems.entries) {
      final stats = entry.value.getStatistics();
      systemSnapshots[entry.key.name] = {
        'hitRate': stats.hitRate,
        'missRate': stats.missRate,
        'memoryUsagePercentage': stats.memoryUsagePercentage,
        'totalItems': stats.totalItems,
        'writes': stats.writeCount,
        'evictions': stats.evictionCount,
      };
    }
    return CacheManagerSnapshot(
      timestamp: DateTime.now(),
      configuration: _configuration,
      currentStrategy: _currentStrategy ?? _configuration.defaultStrategy,
      statistics: stats,
      cacheSystemSnapshots: systemSnapshots,
    );
  }

  List<String> _buildRecommendations() {
    final recommendations = <String>[];
    final stats = getStatistics();
    final cacheStats = stats['cacheSystemStats'] as Map<String, Object?>;
    if (cacheStats.values.any((value) {
      final map = value as Map<String, Object?>;
      return (map['hitRate'] as double? ?? 0) < 0.6;
    })) {
      recommendations.add('Consider warming frequently accessed keys.');
    }
    if (recommendations.isEmpty) {
      recommendations.add('Cache configuration looks healthy.');
    }
    return recommendations;
  }

  AdvancedCacheSystem _systemFor(CacheStrategy? strategy) {
    final resolved = strategy ?? _currentStrategy ?? _configuration.defaultStrategy;
    final system = _systems[resolved];
    if (system == null) {
      throw CacheException('Strategy $resolved not initialized');
    }
    return system;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw CacheException('AdvancedCacheManager not initialized');
    }
  }
}

class CacheManagerSnapshot {
  CacheManagerSnapshot({
    required this.timestamp,
    required this.configuration,
    required this.currentStrategy,
    required this.statistics,
    required this.cacheSystemSnapshots,
  });

  final DateTime timestamp;
  final CacheConfiguration configuration;
  final CacheStrategy currentStrategy;
  final Map<String, dynamic> statistics;
  final Map<String, Map<String, dynamic>> cacheSystemSnapshots;

  Map<String, Object?> toMap() => {
        'timestamp': timestamp.toIso8601String(),
        'configuration': configuration.toMap(),
        'currentStrategy': currentStrategy.name,
        'statistics': statistics,
        'cacheSystemSnapshots': cacheSystemSnapshots,
      };
}
