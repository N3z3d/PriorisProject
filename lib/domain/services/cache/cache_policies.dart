import 'package:prioris/domain/services/cache/interfaces/cache_system_interfaces.dart';

/// Eviction modes supported by the adaptive cache system.
enum EvictionPolicy { lru, lfu, ttl, adaptive }

/// Low-level configuration shared by cache subsystems.
class CacheConfig {
  const CacheConfig({
    this.memorySize = 256,
    this.maxEntries,
    this.defaultTtl = const Duration(minutes: 15),
    this.persistentCacheEnabled = false,
    this.compressionEnabled = true,
    this.encryptionEnabled = false,
    this.evictionPolicy = EvictionPolicy.adaptive,
  }) : assert(memorySize > 0, 'memorySize must be > 0');

  /// Logical capacity of the cache. In practice we use it as an upper bound for
  /// in-memory entries while also deriving memory usage statistics.
  final int memorySize;

  /// Optional explicit number of entries allowed. When omitted we fallback to
  /// [memorySize].
  final int? maxEntries;

  /// Default time-to-live applied when none is supplied.
  final Duration defaultTtl;

  /// Whether persistent storage should receive write-through operations.
  final bool persistentCacheEnabled;

  /// Enables transparent compression for large payloads.
  final bool compressionEnabled;

  /// Placeholder for future encryption support.
  final bool encryptionEnabled;

  /// Eviction strategy applied when the cache exceeds its capacity.
  final EvictionPolicy evictionPolicy;

  /// Effective maximum number of entries before eviction kicks in.
  int get effectiveMaxEntries =>
      (maxEntries ?? memorySize).clamp(1, 1000000);
}

/// Higher level configuration wrapper used by the manager facade.
class CacheConfiguration extends CacheConfig {
  const CacheConfiguration({
    this.maxMemoryMB = 128,
    this.defaultStrategy = CacheStrategy.adaptive,
    Duration defaultTTL = const Duration(minutes: 30),
    bool compressionEnabled = true,
    EvictionPolicy evictionPolicy = EvictionPolicy.adaptive,
  }) : super(
          memorySize: maxMemoryMB,
          defaultTtl: defaultTTL,
          compressionEnabled: compressionEnabled,
          evictionPolicy: evictionPolicy,
        );

  /// Human readable memory limit (expressed in MB for reports).
  final int maxMemoryMB;

  /// Preferred lookup strategy when none is explicitly provided.
  final CacheStrategy defaultStrategy;

  CacheConfiguration copyWith({
    int? maxMemoryMB,
    CacheStrategy? defaultStrategy,
    Duration? defaultTTL,
    bool? compressionEnabled,
    EvictionPolicy? evictionPolicy,
  }) {
    return CacheConfiguration(
      maxMemoryMB: maxMemoryMB ?? this.maxMemoryMB,
      defaultStrategy: defaultStrategy ?? this.defaultStrategy,
      defaultTTL: defaultTTL ?? defaultTtl,
      compressionEnabled: compressionEnabled ?? this.compressionEnabled,
      evictionPolicy: evictionPolicy ?? this.evictionPolicy,
    );
  }

  Map<String, Object?> toMap() => {
        'maxMemoryMB': maxMemoryMB,
        'defaultStrategy': defaultStrategy.name,
        'defaultTTL': defaultTtl.inMilliseconds,
        'compressionEnabled': compressionEnabled,
        'evictionPolicy': evictionPolicy.name,
      };
}
