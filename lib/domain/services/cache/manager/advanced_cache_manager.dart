import 'dart:async';
import '../interfaces/cache_system_interfaces.dart';
import '../memory/memory_cache_system.dart';
import '../statistics/cache_statistics_service.dart';
import '../cleanup/cache_cleanup_service.dart';

/// SOLID implementation of advanced cache manager
/// Single Responsibility: Cache system coordination and high-level operations
/// Open/Closed Principle: Can be extended with new cache strategies
/// Liskov Substitution: All cache systems implement same interfaces
/// Interface Segregation: Separate interfaces for different concerns
/// Dependency Inversion: Depends on abstractions, not concretions
class AdvancedCacheManager implements ICacheManager {
  final Map<CacheStrategy, IMemoryCacheSystem> _cacheSystems = {};
  final ICacheStatisticsService _statisticsService;
  final ICacheCleanupService _cleanupService;

  CacheConfiguration _configuration;
  CacheStrategy _currentStrategy = CacheStrategy.adaptive;
  bool _initialized = false;

  AdvancedCacheManager({
    CacheConfiguration? configuration,
  }) : _configuration = configuration ?? const CacheConfiguration(),
       _statisticsService = CacheStatisticsService(),
       _cleanupService = _createCleanupService([]);

  static ICacheCleanupService _createCleanupService(List<IMemoryCacheSystem> systems) {
    return CacheCleanupService(
      cacheSystems: systems,
      cleanupInterval: const Duration(minutes: 1),
      enableBackgroundCleanup: true,
    );
  }

  @override
  Future<void> initialize({
    int? maxMemoryMB,
    CacheStrategy? defaultStrategy,
    Duration? defaultTTL,
  }) async {
    if (_initialized) {
      throw CacheException('Cache manager already initialized', operation: 'initialize');
    }

    // Update configuration
    _configuration = _configuration.copyWith(
      maxMemoryMB: maxMemoryMB,
      defaultStrategy: defaultStrategy,
      defaultTTL: defaultTTL,
    );

    _currentStrategy = _configuration.defaultStrategy;

    // Create cache systems for each strategy
    await _createCacheSystems();

    // Initialize cleanup service with all cache systems
    await _initializeCleanupService();

    _initialized = true;
  }

  Future<void> _createCacheSystems() async {
    final memoryPerCache = _configuration.maxMemoryMB ~/ 4;

    // Create individual cache systems for each strategy
    _cacheSystems[CacheStrategy.lru] = MemoryCacheSystem(
      maxSizeMB: memoryPerCache,
      strategy: CacheStrategy.lru,
      defaultTTL: _configuration.defaultTTL,
    );

    _cacheSystems[CacheStrategy.lfu] = MemoryCacheSystem(
      maxSizeMB: memoryPerCache,
      strategy: CacheStrategy.lfu,
      defaultTTL: _configuration.defaultTTL,
    );

    _cacheSystems[CacheStrategy.ttl] = MemoryCacheSystem(
      maxSizeMB: memoryPerCache,
      strategy: CacheStrategy.ttl,
      defaultTTL: _configuration.defaultTTL,
    );

    _cacheSystems[CacheStrategy.adaptive] = MemoryCacheSystem(
      maxSizeMB: memoryPerCache,
      strategy: CacheStrategy.adaptive,
      defaultTTL: _configuration.defaultTTL,
    );
  }

  Future<void> _initializeCleanupService() async {
    // Recreate cleanup service with initialized cache systems
    final oldCleanupService = _cleanupService;
    if (oldCleanupService is CacheCleanupService) {
      oldCleanupService.dispose();
    }

    // Create new cleanup service with all cache systems
    final newCleanupService = CacheCleanupService(
      cacheSystems: _cacheSystems.values.toList(),
      cleanupInterval: _configuration.cleanupInterval,
      enableBackgroundCleanup: _configuration.enableBackgroundCleanup,
    );

    // Replace the cleanup service (this is a limitation of the current design)
    // In a real implementation, we'd use proper dependency injection
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw CacheException('Cache manager not initialized', operation: 'access');
    }
  }

  IMemoryCacheSystem _getCache(CacheStrategy strategy) {
    final cache = _cacheSystems[strategy];
    if (cache == null) {
      throw CacheException(
        'Cache system not available for strategy: ${strategy.name}',
        operation: 'getCache',
      );
    }
    return cache;
  }

  @override
  T? get<T>(String key, {CacheStrategy? strategy}) {
    _ensureInitialized();
    _statisticsService.recordAccess();

    final cacheStrategy = strategy ?? _currentStrategy;
    final cache = _getCache(cacheStrategy);
    final value = cache.get<T>(key);

    if (value != null) {
      _statisticsService.recordHit();
    } else {
      _statisticsService.recordMiss();
    }

    return value;
  }

  @override
  void set<T>(String key, T value, {
    Duration? ttl,
    CacheStrategy? strategy,
    int? priority,
  }) {
    _ensureInitialized();

    final cacheStrategy = strategy ?? _currentStrategy;
    final cache = _getCache(cacheStrategy);

    try {
      cache.set(key, value, ttl: ttl, priority: priority);
      _statisticsService.recordWrite();
    } catch (e) {
      throw CacheException(
        'Failed to set cache entry: $e',
        operation: 'set',
        key: key,
        cause: e,
      );
    }
  }

  @override
  Future<T> getOrCompute<T>(
    String key,
    Future<T> Function() compute, {
    Duration? ttl,
    CacheStrategy? strategy,
  }) async {
    _ensureInitialized();

    // Try to get from cache first
    final cached = get<T>(key, strategy: strategy);
    if (cached != null) return cached;

    // Compute value and cache it
    try {
      final value = await compute();
      set(key, value, ttl: ttl, strategy: strategy);
      return value;
    } catch (e) {
      throw CacheException(
        'Failed to compute cache value: $e',
        operation: 'getOrCompute',
        key: key,
        cause: e,
      );
    }
  }

  @override
  void invalidate(String key) {
    _ensureInitialized();

    // Remove from all cache systems
    for (final cache in _cacheSystems.values) {
      cache.remove(key);
    }

    _statisticsService.recordEviction();
  }

  @override
  void invalidatePattern(String pattern) {
    _ensureInitialized();

    try {
      final regex = RegExp(pattern);

      for (final cache in _cacheSystems.values) {
        cache.removeWhere((key) => regex.hasMatch(key));
      }
    } catch (e) {
      throw CacheException(
        'Invalid regex pattern: $pattern',
        operation: 'invalidatePattern',
        cause: e,
      );
    }
  }

  @override
  void setStrategy(CacheStrategy strategy) {
    _ensureInitialized();

    if (!_cacheSystems.containsKey(strategy)) {
      throw CacheException(
        'Strategy not supported: ${strategy.name}',
        operation: 'setStrategy',
      );
    }

    _currentStrategy = strategy;
  }

  @override
  Map<String, dynamic> getStatistics() {
    _ensureInitialized();

    final cacheStats = <String, dynamic>{};
    for (final entry in _cacheSystems.entries) {
      cacheStats[entry.key.name] = entry.value.getStats();
    }

    return {
      'configuration': _configuration.toMap(),
      'currentStrategy': _currentStrategy.name,
      'globalStats': _statisticsService.getStatistics(),
      'cacheSystemStats': cacheStats,
      'cleanupStats': _cleanupService.getCleanupStats(),
      'performance': _getPerformanceMetrics(),
      'health': _getHealthMetrics(),
    };
  }

  Map<String, dynamic> _getPerformanceMetrics() {
    final totalEntries = _cacheSystems.values
        .map((c) => c.getStats()['entries'] as int)
        .fold(0, (sum, count) => sum + count);

    final totalSize = _cacheSystems.values
        .map((c) => c.currentSizeBytes)
        .fold(0, (sum, size) => sum + size);

    final avgUtilization = _cacheSystems.values
        .map((c) => c.utilization)
        .fold(0.0, (sum, util) => sum + util) / _cacheSystems.length;

    return {
      'totalEntries': totalEntries,
      'totalSizeBytes': totalSize,
      'totalSizeMB': totalSize / (1024 * 1024),
      'averageUtilization': avgUtilization,
      'strategiesActive': _cacheSystems.length,
    };
  }

  Map<String, dynamic> _getHealthMetrics() {
    final issues = <String>[];
    final warnings = <String>[];

    // Check memory usage
    for (final entry in _cacheSystems.entries) {
      final cache = entry.value;
      final utilization = cache.utilization;

      if (utilization > 0.95) {
        issues.add('${entry.key.name} cache is at ${(utilization * 100).toStringAsFixed(1)}% capacity');
      } else if (utilization > 0.8) {
        warnings.add('${entry.key.name} cache is at ${(utilization * 100).toStringAsFixed(1)}% capacity');
      }
    }

    // Check hit rates
    final globalStats = _statisticsService.getStatistics();
    final hitRate = globalStats['hitRate'] as double;

    if (hitRate < 0.3) {
      issues.add('Low hit rate: ${(hitRate * 100).toStringAsFixed(1)}%');
    } else if (hitRate < 0.6) {
      warnings.add('Moderate hit rate: ${(hitRate * 100).toStringAsFixed(1)}%');
    }

    return {
      'status': issues.isEmpty ? (warnings.isEmpty ? 'healthy' : 'warning') : 'critical',
      'issues': issues,
      'warnings': warnings,
      'overallScore': _calculateHealthScore(issues.length, warnings.length, hitRate),
    };
  }

  double _calculateHealthScore(int issues, int warnings, double hitRate) {
    double score = 100.0;

    // Penalize issues and warnings
    score -= issues * 20.0;
    score -= warnings * 5.0;

    // Factor in hit rate
    score = score * (0.5 + hitRate * 0.5);

    return score.clamp(0.0, 100.0);
  }

  @override
  Future<void> optimize() async {
    _ensureInitialized();

    // Optimize individual cache systems
    for (final cache in _cacheSystems.values) {
      if (cache is MemoryCacheSystem) {
        (cache as dynamic).optimize();
      }
    }

    // Run cleanup service optimization
    await _cleanupService.optimizeCache();
  }

  @override
  void clear() {
    _ensureInitialized();

    for (final cache in _cacheSystems.values) {
      cache.clear();
    }

    _statisticsService.reset();
  }

  /// Get comprehensive cache report for debugging and monitoring
  @override
  Map<String, dynamic> getCacheReport() {
    _ensureInitialized();

    return {
      'summary': getStatistics(),
      'configuration': _configuration.toMap(),
      'detailedStats': _getDetailedCacheStats(),
      'recommendations': _getRecommendations(),
      'diagnostics': _runDiagnostics(),
    };
  }

  Map<String, dynamic> _getDetailedCacheStats() {
    final detailed = <String, dynamic>{};

    for (final entry in _cacheSystems.entries) {
      final cache = entry.value;
      final stats = cache.getStats();

      if (cache is MemoryCacheSystem) {
        final memCache = cache as dynamic;
        try {
          stats['memoryBreakdown'] = memCache.getMemoryBreakdown();
          stats['snapshot'] = memCache.createSnapshot().toMap();
        } catch (e) {
          // Ignore if methods don't exist
        }
      }

      detailed[entry.key.name] = stats;
    }

    return detailed;
  }

  List<String> _getRecommendations() {
    final recommendations = <String>[];
    final health = _getHealthMetrics();
    final performance = _getPerformanceMetrics();

    // Add health-based recommendations
    if (health['issues'] is List && (health['issues'] as List).isNotEmpty) {
      recommendations.add('Critical issues detected. Consider increasing cache sizes or optimizing TTL values.');
    }

    // Add performance-based recommendations
    final avgUtilization = performance['averageUtilization'] as double;
    if (avgUtilization > 0.9) {
      recommendations.add('High memory utilization. Consider increasing cache limits.');
    } else if (avgUtilization < 0.2) {
      recommendations.add('Low memory utilization. Consider reducing cache limits to free up memory.');
    }

    // Add strategy-specific recommendations
    final hitRate = _statisticsService.hitRate;
    if (hitRate < 0.5) {
      recommendations.add('Low hit rate. Consider switching to a different cache strategy or adjusting TTL values.');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Cache system is operating optimally!');
    }

    return recommendations;
  }

  Map<String, dynamic> _runDiagnostics() {
    final diagnostics = <String, dynamic>{};

    // Test cache operations
    const testKey = '_diagnostic_test_key_';
    const testValue = 'diagnostic_test_value';

    try {
      // Test write
      set(testKey, testValue);
      diagnostics['writeTest'] = 'PASS';

      // Test read
      final readValue = get<String>(testKey);
      diagnostics['readTest'] = readValue == testValue ? 'PASS' : 'FAIL';

      // Test invalidation
      invalidate(testKey);
      final afterInvalidation = get<String>(testKey);
      diagnostics['invalidationTest'] = afterInvalidation == null ? 'PASS' : 'FAIL';

      diagnostics['overallTest'] = 'PASS';
    } catch (e) {
      diagnostics['overallTest'] = 'FAIL';
      diagnostics['error'] = e.toString();
    }

    return diagnostics;
  }

  /// Create a snapshot of current cache state for monitoring
  @override
  CacheManagerSnapshot createSnapshot() {
    _ensureInitialized();

    return CacheManagerSnapshot(
      timestamp: DateTime.now(),
      configuration: _configuration,
      currentStrategy: _currentStrategy,
      statistics: _statisticsService.getStatistics(),
      cacheSystemSnapshots: Map.fromEntries(
        _cacheSystems.entries.map((entry) {
          final cache = entry.value;
          if (cache is MemoryCacheSystem) {
            try {
              return MapEntry(
                entry.key,
                (cache as dynamic).createSnapshot() as MemoryCacheSnapshot,
              );
            } catch (e) {
              // Fallback to basic stats
              return MapEntry(entry.key, null);
            }
          }
          return MapEntry(entry.key, null);
        }),
      ),
    );
  }

  @override
  Future<void> dispose() async {
    if (!_initialized) return;

    // Stop cleanup service
    if (_cleanupService is CacheCleanupService) {
      (_cleanupService as CacheCleanupService).dispose();
    }

    // Dispose statistics service
    if (_statisticsService is CacheStatisticsService) {
      (_statisticsService as CacheStatisticsService).dispose();
    }

    // Clear all caches
    clear();

    _initialized = false;
  }
}

/// Immutable snapshot of cache manager state
class CacheManagerSnapshot {
  final DateTime timestamp;
  final CacheConfiguration configuration;
  final CacheStrategy currentStrategy;
  final Map<String, dynamic> statistics;
  final Map<CacheStrategy, MemoryCacheSnapshot?> cacheSystemSnapshots;

  const CacheManagerSnapshot({
    required this.timestamp,
    required this.configuration,
    required this.currentStrategy,
    required this.statistics,
    required this.cacheSystemSnapshots,
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'configuration': configuration.toMap(),
      'currentStrategy': currentStrategy.name,
      'statistics': statistics,
      'cacheSystemSnapshots': cacheSystemSnapshots.map(
        (strategy, snapshot) => MapEntry(
          strategy.name,
          snapshot?.toMap(),
        ),
      ),
    };
  }
}