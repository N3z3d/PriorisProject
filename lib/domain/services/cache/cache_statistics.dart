import 'dart:math';

import 'package:collection/collection.dart';

class CacheStats {
  const CacheStats({
    required this.totalEntries,
    required this.totalSize,
    required this.hitRate,
    required this.missRate,
    required this.diskUsageMB,
    required this.generatedAt,
    this.lastCleanup,
  });

  final int totalEntries;
  final int totalSize;
  final double hitRate;
  final double missRate;
  final double diskUsageMB;
  final DateTime generatedAt;
  final DateTime? lastCleanup;

  Map<String, Object?> toMap() => {
        'totalEntries': totalEntries,
        'totalSize': totalSize,
        'hitRate': hitRate,
        'missRate': missRate,
        'diskUsageMB': diskUsageMB,
        'generatedAt': generatedAt.toIso8601String(),
        'lastCleanup': lastCleanup?.toIso8601String(),
      };
}

class CacheSystemStatistics {
  CacheSystemStatistics({
    this.totalItems = 0,
    this.memoryUsage = 0,
    this.memoryLimit = 1,
    this.capacityEntries = 1,
    this.totalOperations = 0,
    this.totalLatency = Duration.zero,
    this.hitCount = 0,
    this.missCount = 0,
    this.prefetchAttempts = 0,
    this.totalCompressedItems = 0,
    this.totalCompressionSavings = 0,
  });

  int totalItems;
  int memoryUsage;
  int memoryLimit;
  int capacityEntries;
  int totalOperations;
  Duration totalLatency;
  int hitCount;
  int missCount;
  int prefetchAttempts;
  int totalCompressedItems;
  int totalCompressionSavings;

  double get hitRate =>
      totalOperations == 0 ? 0 : hitCount / max(1, hitCount + missCount);

  double get missRate =>
      totalOperations == 0 ? 0 : missCount / max(1, hitCount + missCount);

  double get compressionRatio {
    if (totalCompressedItems == 0 || totalCompressionSavings <= 0) {
      return 1.0;
    }
    final original = totalCompressionSavings + memoryUsage;
    return original == 0 ? 1.0 : memoryUsage / original;
  }

  double get memoryUsagePercentage =>
      memoryLimit <= 0 ? 0 : memoryUsage / memoryLimit;

  double get memoryPressure {
    final byBytes = memoryUsagePercentage;
    final byEntries = capacityEntries <= 0 ? 0 : totalItems / capacityEntries;
    return max(byBytes, byEntries).clamp(0.0, 1.0).toDouble();
  }

  Duration get averageOperationTime =>
      totalOperations == 0 ? Duration.zero : totalLatency ~/ totalOperations;

  CacheSystemStatistics copy() => CacheSystemStatistics(
        totalItems: totalItems,
        memoryUsage: memoryUsage,
        memoryLimit: memoryLimit,
        capacityEntries: capacityEntries,
        totalOperations: totalOperations,
        totalLatency: totalLatency,
        hitCount: hitCount,
        missCount: missCount,
        prefetchAttempts: prefetchAttempts,
        totalCompressedItems: totalCompressedItems,
        totalCompressionSavings: totalCompressionSavings,
      );
}

enum CacheAlertType { diskUsage, hitRate, error }

class CacheAlert {
  CacheAlert({
    required this.type,
    required this.message,
    Map<String, Object?>? details,
    DateTime? timestamp,
  })  : details = details ?? const {},
        timestamp = timestamp ?? DateTime.now();

  final CacheAlertType type;
  final String message;
  final Map<String, Object?> details;
  final DateTime timestamp;
}

class CacheMetrics {
  CacheMetrics({
    required this.timestamp,
    required this.totalEntries,
    required this.hitRate,
    required this.missRate,
    required this.diskUsageMB,
    required this.totalOperations,
    required this.averageLatency,
  });

  final DateTime timestamp;
  final int totalEntries;
  final double hitRate;
  final double missRate;
  final double diskUsageMB;
  final int totalOperations;
  final Duration averageLatency;

  Map<String, Object?> toMap() => {
        'timestamp': timestamp.toIso8601String(),
        'totalEntries': totalEntries,
        'hitRate': hitRate,
        'missRate': missRate,
        'diskUsageMB': diskUsageMB,
        'totalOperations': totalOperations,
        'averageLatency': averageLatency.inMicroseconds,
      };
}

class CachePerformanceReport {
  CachePerformanceReport({
    required this.period,
    required this.totalOperations,
    required this.averageHitRate,
    required this.averageLatency,
    required this.recommendations,
    required this.trend,
  });

  final Duration period;
  final int totalOperations;
  final double averageHitRate;
  final Duration averageLatency;
  final List<String> recommendations;
  final Map<String, Object?> trend;
}

class CacheHealthStatus {
  CacheHealthStatus({
    required this.isHealthy,
    required this.lastCheck,
    required this.metrics,
    required this.issues,
  });

  final bool isHealthy;
  final DateTime lastCheck;
  final CacheMetrics metrics;
  final List<String> issues;
}

double _average(List<double> values) {
  if (values.isEmpty) {
    return 0;
  }
  final total = values.sum;
  return total / values.length;
}

double averageDouble(Iterable<double> values) => _average(values.toList());
