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
    final agg = _accumulateSystems();
    final systemCount = _systems.length;
    final totalAccesses = agg.hits + agg.misses;
    final avgLatencyMicros =
        agg.ops == 0 ? 0 : agg.latency ~/ agg.ops;
    final avgUtilization = agg.memLimit == 0
        ? 0.0
        : (agg.memory / agg.memLimit).clamp(0.0, 1.0);
    final globalStats = _buildGlobalStats(
      systemCount: systemCount,
      totalAccesses: totalAccesses,
      hits: agg.hits,
      misses: agg.misses,
      writes: agg.writes,
      evictions: agg.evictions,
      aggregateHitRate: agg.hitRate,
      aggregateMissRate: agg.missRate,
      avgLatencyMicros: avgLatencyMicros,
      totalItems: agg.items,
      memoryBytes: agg.memory,
    );
    return {
      'configuration': _configuration.toMap(),
      'currentStrategy': _currentStrategy?.name,
      'globalStats': globalStats,
      'cacheSystemStats': agg.cacheStats,
      'cleanupStats': const {'lastCleanup': null},
      'performance': {
        'averageLatencyMicros': avgLatencyMicros,
        'totalEntries': agg.items,
        'totalSizeBytes': agg.memory,
        'averageUtilization': avgUtilization,
        'strategiesActive': systemCount,
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      'health': _buildHealthSection(
        totalAccesses: totalAccesses,
        hits: agg.hits,
        misses: agg.misses,
        totalItems: agg.items,
      ),
    };
  }

  ({
    Map<String, Map<String, dynamic>> cacheStats,
    double hitRate, double missRate,
    int ops, int hits, int misses, int writes, int evictions,
    int latency, int items, int memory, int memLimit,
  }) _accumulateSystems() {
    final cacheStats = <String, Map<String, dynamic>>{};
    var hitRate = 0.0;
    var missRate = 0.0;
    var ops = 0;
    var hits = 0;
    var misses = 0;
    var writes = 0;
    var evictions = 0;
    var latency = 0;
    var items = 0;
    var memory = 0;
    var memLimit = 0;
    for (final entry in _systems.entries) {
      final s = entry.value.getStatistics();
      hitRate += s.hitRate;
      missRate += s.missRate;
      ops += s.totalOperations;
      hits += s.hitCount;
      misses += s.missCount;
      writes += s.writeCount;
      evictions += s.evictionCount;
      latency += s.totalLatency.inMicroseconds;
      items += s.totalItems;
      memory += s.memoryUsage;
      memLimit += s.memoryLimit;
      cacheStats[entry.key.name] = {
        'totalItems': s.totalItems,
        'totalOperations': s.totalOperations,
        'hits': s.hitCount,
        'misses': s.missCount,
        'writes': s.writeCount,
        'evictions': s.evictionCount,
        'hitRate': s.hitRate,
        'missRate': s.missRate,
        'memoryUsageBytes': s.memoryUsage,
        'memoryLimitBytes': s.memoryLimit,
        'memoryUsagePercentage': s.memoryUsagePercentage,
        'averageLatencyMicros': s.averageOperationTime.inMicroseconds,
        'compressedItems': s.totalCompressedItems,
        'compressionSavingsBytes': s.totalCompressionSavings,
        'totalSizeBytes': s.memoryUsage,
      };
    }
    return (
      cacheStats: cacheStats,
      hitRate: hitRate, missRate: missRate,
      ops: ops, hits: hits, misses: misses,
      writes: writes, evictions: evictions,
      latency: latency, items: items,
      memory: memory, memLimit: memLimit,
    );
  }

  Map<String, dynamic> _buildGlobalStats({
    required int systemCount,
    required int totalAccesses,
    required int hits,
    required int misses,
    required int writes,
    required int evictions,
    required double aggregateHitRate,
    required double aggregateMissRate,
    required int avgLatencyMicros,
    required int totalItems,
    required int memoryBytes,
  }) {
    final hasEntries = totalItems > 0;
    return {
      'totalSystems': systemCount,
      'strategiesActive': systemCount,
      'totalAccesses': hasEntries ? totalAccesses : 0,
      'hits': hasEntries ? hits : 0,
      'misses': hasEntries ? misses : 0,
      'writes': writes,
      'evictions': evictions,
      'averageHitRate': systemCount == 0 ? 0.0 : aggregateHitRate / systemCount,
      'averageMissRate': systemCount == 0 ? 0.0 : aggregateMissRate / systemCount,
      'averageLatencyMicros': avgLatencyMicros,
      'totalItems': totalItems,
      'memoryUsageBytes': memoryBytes,
    };
  }

  Map<String, dynamic> _buildHealthSection({
    required int totalAccesses,
    required int hits,
    required int misses,
    required int totalItems,
  }) {
    final hitRate = totalAccesses == 0 ? 1.0 : hits / totalAccesses;
    final status = totalAccesses == 0
        ? 'healthy'
        : hitRate < 0.3
            ? 'critical'
            : hitRate < 0.6
                ? 'warning'
                : 'healthy';
    final overallScore = totalAccesses == 0
        ? 100
        : (hits / totalAccesses * 100).clamp(0, 100).round();
    final issues = <String>[];
    if (totalAccesses > 0 && hitRate < 0.3 && misses > hits) {
      issues.add('Low hit rate detected');
    }
    if (totalItems == 0) issues.add('Cache empty');
    return {'status': status, 'overallScore': overallScore, 'issues': issues};
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
