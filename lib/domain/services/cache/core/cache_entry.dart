import '../interfaces/cache_system_interfaces.dart';

/// Concrete implementation of cache entry following SRP
/// Responsible for managing entry metadata and state
class CacheEntry implements ICacheEntry {
  @override
  final dynamic value;

  @override
  final int sizeBytes;

  @override
  final DateTime created;

  @override
  final DateTime? expiresAt;

  @override
  final int priority;

  @override
  DateTime lastAccessed;

  @override
  int frequency;

  CacheEntry({
    required this.value,
    required this.sizeBytes,
    Duration? ttl,
    this.priority = 0,
    this.frequency = 1,
  })  : created = DateTime.now(),
        lastAccessed = DateTime.now(),
        expiresAt = ttl != null ? DateTime.now().add(ttl) : null;

  @override
  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  @override
  void updateAccess() {
    lastAccessed = DateTime.now();
  }

  @override
  void incrementFrequency() {
    frequency++;
    updateAccess();
  }

  /// Calculate age in seconds for adaptive scoring
  int get ageInSeconds => DateTime.now().difference(lastAccessed).inSeconds + 1;

  /// Calculate adaptive score based on multiple factors
  double calculateAdaptiveScore() {
    final sizeWeight = 1.0 / (sizeBytes / 1024 + 1);
    final score = (frequency * 10.0) / ageInSeconds +
                  (priority * 5.0) +
                  sizeWeight * 2.0;
    return score;
  }

  /// Create entry with updated TTL
  CacheEntry copyWithNewTTL(Duration? ttl) {
    return CacheEntry(
      value: value,
      sizeBytes: sizeBytes,
      ttl: ttl,
      priority: priority,
      frequency: frequency,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sizeBytes': sizeBytes,
      'created': created.toIso8601String(),
      'lastAccessed': lastAccessed.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'priority': priority,
      'frequency': frequency,
      'isExpired': isExpired,
      'ageInSeconds': ageInSeconds,
      'adaptiveScore': calculateAdaptiveScore(),
    };
  }
}

/// Utility class for cache entry size estimation
class CacheSizeEstimator {
  /// Estimate memory size of a value in bytes
  static int estimateSize(dynamic value) {
    if (value == null) return 0;

    // Primitive types
    if (value is String) return value.length * 2; // UTF-16
    if (value is int) return 8;
    if (value is double) return 8;
    if (value is bool) return 1;

    // Collections
    if (value is List) {
      int size = 24; // List overhead
      for (final item in value) {
        size += estimateSize(item);
      }
      return size;
    }

    if (value is Map) {
      int size = 24; // Map overhead
      value.forEach((key, val) {
        size += estimateSize(key);
        size += estimateSize(val);
      });
      return size;
    }

    if (value is Set) {
      int size = 24; // Set overhead
      for (final item in value) {
        size += estimateSize(item);
      }
      return size;
    }

    // Default estimation for complex objects
    return 100;
  }

  /// Check if the estimated size is reasonable
  static bool isReasonableSize(int sizeBytes, {int maxSizeMB = 50}) {
    const int maxBytes = 1024 * 1024; // 1MB per entry max
    return sizeBytes > 0 && sizeBytes < maxBytes &&
           sizeBytes < (maxSizeMB * 1024 * 1024 * 0.1); // Max 10% of total cache
  }

  /// Format size for human reading
  static String formatSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}