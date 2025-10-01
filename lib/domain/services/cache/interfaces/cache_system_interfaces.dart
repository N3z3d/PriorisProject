import 'dart:async';

/// Core interfaces for the SOLID cache architecture
/// Following Single Responsibility Principle - each interface has one clear purpose

/// Strategy pattern for different cache algorithms
enum CacheStrategy {
  lru,      // Least Recently Used
  lfu,      // Least Frequently Used
  ttl,      // Time To Live
  adaptive, // Adaptive algorithm
}

/// Cache entry metadata and data container
abstract class ICacheEntry {
  dynamic get value;
  int get sizeBytes;
  DateTime get created;
  DateTime get lastAccessed;
  DateTime? get expiresAt;
  int get priority;
  int get frequency;
  bool get isExpired;

  void updateAccess();
  void incrementFrequency();
}

/// Core cache operations interface
abstract class ICacheSystem {
  /// Get value from cache
  T? get<T>(String key);

  /// Set value in cache
  void set<T>(String key, T value, {Duration? ttl, int? priority});

  /// Remove specific key
  void remove(String key);

  /// Remove keys matching pattern
  void removeWhere(bool Function(String) test);

  /// Clear all entries
  void clear();

  /// Get cache statistics
  Map<String, dynamic> getStats();
}

/// Memory cache operations for volatile storage
abstract class IMemoryCacheSystem extends ICacheSystem {
  /// Check if cache has space for new entry
  bool hasSpace(int sizeBytes);

  /// Get current memory usage in bytes
  int get currentSizeBytes;

  /// Get maximum allowed size in MB
  int get maxSizeMB;

  /// Get current utilization percentage
  double get utilization;
}

/// Policy management for cache behavior
abstract class ICachePolicyEngine {
  /// Check if entry should be evicted based on policy
  bool shouldEvict(String key, ICacheEntry entry);

  /// Get next key to evict based on strategy
  String? getEvictionCandidate(Map<String, ICacheEntry> entries);

  /// Update entry metadata after access
  void updateEntryOnAccess(String key, ICacheEntry entry);

  /// Update entry metadata after creation
  void updateEntryOnCreate(String key, ICacheEntry entry);

  /// Get policy-specific statistics
  Map<String, dynamic> getPolicyStats();
}

/// Statistics and performance monitoring
abstract class ICacheStatisticsService {
  /// Record cache access
  void recordAccess();

  /// Record cache hit
  void recordHit();

  /// Record cache miss
  void recordMiss();

  /// Record cache write
  void recordWrite();

  /// Record cache eviction
  void recordEviction();

  /// Get hit rate percentage
  double get hitRate;

  /// Get miss rate percentage
  double get missRate;

  /// Get requests per second
  double get requestsPerSecond;

  /// Get comprehensive statistics
  Map<String, dynamic> getStatistics();

  /// Reset all statistics
  void reset();
}

/// Cache maintenance and cleanup operations
abstract class ICacheCleanupService {
  /// Remove expired entries
  Future<int> removeExpiredEntries();

  /// Optimize cache by reorganizing data
  Future<void> optimizeCache();

  /// Perform background cleanup
  void startBackgroundCleanup();

  /// Stop background cleanup
  void stopBackgroundCleanup();

  /// Get cleanup statistics
  Map<String, dynamic> getCleanupStats();
}

/// Main cache coordinator interface
abstract class ICacheManager {
  /// Initialize cache manager with configuration
  Future<void> initialize({
    int? maxMemoryMB,
    CacheStrategy? defaultStrategy,
    Duration? defaultTTL,
  });

  /// Get value with optional strategy override
  T? get<T>(String key, {CacheStrategy? strategy});

  /// Set value with optional strategy override
  void set<T>(String key, T value, {
    Duration? ttl,
    CacheStrategy? strategy,
    int? priority,
  });

  /// Get or compute value if not cached
  Future<T> getOrCompute<T>(
    String key,
    Future<T> Function() compute, {
    Duration? ttl,
    CacheStrategy? strategy,
  });

  /// Invalidate specific key across all caches
  void invalidate(String key);

  /// Invalidate keys matching pattern
  void invalidatePattern(String pattern);

  /// Change default cache strategy
  void setStrategy(CacheStrategy strategy);

  /// Get comprehensive cache statistics
  Map<String, dynamic> getStatistics();

  /// Get detailed cache report for monitoring
  Map<String, dynamic> getCacheReport();

  /// Create a snapshot of current cache state
  dynamic createSnapshot();

  /// Optimize all cache systems
  Future<void> optimize();

  /// Clear all caches
  void clear();

  /// Dispose resources
  Future<void> dispose();
}

/// Cache snapshot for monitoring and debugging
class CacheSnapshot {
  final DateTime timestamp;
  final Map<String, dynamic> statistics;
  final Map<String, dynamic> systemHealth;
  final List<Map<String, dynamic>> cacheStates;

  const CacheSnapshot({
    required this.timestamp,
    required this.statistics,
    required this.systemHealth,
    required this.cacheStates,
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'statistics': statistics,
      'systemHealth': systemHealth,
      'cacheStates': cacheStates,
    };
  }
}

/// Configuration for cache systems
class CacheConfiguration {
  final int maxMemoryMB;
  final Duration defaultTTL;
  final CacheStrategy defaultStrategy;
  final Duration cleanupInterval;
  final bool enableStatistics;
  final bool enableBackgroundCleanup;

  const CacheConfiguration({
    this.maxMemoryMB = 50,
    this.defaultTTL = const Duration(minutes: 10),
    this.defaultStrategy = CacheStrategy.adaptive,
    this.cleanupInterval = const Duration(minutes: 1),
    this.enableStatistics = true,
    this.enableBackgroundCleanup = true,
  });

  CacheConfiguration copyWith({
    int? maxMemoryMB,
    Duration? defaultTTL,
    CacheStrategy? defaultStrategy,
    Duration? cleanupInterval,
    bool? enableStatistics,
    bool? enableBackgroundCleanup,
  }) {
    return CacheConfiguration(
      maxMemoryMB: maxMemoryMB ?? this.maxMemoryMB,
      defaultTTL: defaultTTL ?? this.defaultTTL,
      defaultStrategy: defaultStrategy ?? this.defaultStrategy,
      cleanupInterval: cleanupInterval ?? this.cleanupInterval,
      enableStatistics: enableStatistics ?? this.enableStatistics,
      enableBackgroundCleanup: enableBackgroundCleanup ?? this.enableBackgroundCleanup,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'maxMemoryMB': maxMemoryMB,
      'defaultTTL': defaultTTL.inMilliseconds,
      'defaultStrategy': defaultStrategy.name,
      'cleanupInterval': cleanupInterval.inMilliseconds,
      'enableStatistics': enableStatistics,
      'enableBackgroundCleanup': enableBackgroundCleanup,
    };
  }
}

/// Exception for cache-related errors
class CacheException implements Exception {
  final String message;
  final String operation;
  final String? key;
  final Object? cause;

  const CacheException(
    this.message, {
    required this.operation,
    this.key,
    this.cause,
  });

  @override
  String toString() {
    final keyInfo = key != null ? ' (key: $key)' : '';
    final causeInfo = cause != null ? ', caused by: $cause' : '';
    return 'CacheException in $operation$keyInfo: $message$causeInfo';
  }
}