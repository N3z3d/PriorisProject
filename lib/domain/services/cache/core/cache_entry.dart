import 'dart:convert';
import 'dart:math';

import 'package:prioris/domain/services/cache/interfaces/cache_system_interfaces.dart';

class CacheEntry implements ICacheEntry {
  CacheEntry({
    required this.value,
    required this.sizeBytes,
    int priority = 0,
    int frequency = 1,
    Duration? ttl,
    DateTime? createdAt,
    DateTime? lastAccessed,
    DateTime? expiresAt,
  })  : priority = priority.clamp(0, 100),
        frequency = max(1, frequency),
        _createdAt = createdAt ?? DateTime.now(),
        _lastAccessed = lastAccessed ?? DateTime.now(),
        _expiresAt =
            expiresAt ?? (ttl == null ? null : (createdAt ?? DateTime.now()).add(ttl));

  @override
  final dynamic value;

  @override
  final int sizeBytes;

  @override
  final int priority;

  @override
  int frequency;

  final DateTime _createdAt;
  DateTime _lastAccessed;
  DateTime? _expiresAt;

  @override
  DateTime get createdAt => _createdAt;

  @override
  DateTime get lastAccessed => _lastAccessed;

  @override
  DateTime? get expiresAt => _expiresAt;

  @override
  bool get isExpired =>
      _expiresAt != null && DateTime.now().isAfter(_expiresAt!);

  @override
  void updateAccess() {
    _lastAccessed = DateTime.now();
  }

  @override
  void incrementFrequency() {
    frequency += 1;
    updateAccess();
  }

  @override
  int get ageInSeconds {
    final diffMs = DateTime.now().difference(_createdAt).inMilliseconds;
    final seconds = (diffMs / 1000).ceil();
    return max(1, seconds);
  }

  @override
  double calculateAdaptiveScore() {
    final freshness = 100 / (ageInSeconds + 1);
    final sizePenalty = sizeBytes == 0 ? 0.0 : (sizeBytes / 1024).clamp(0, 100);
    return priority * 2 + frequency * 1.5 + freshness - sizePenalty * 0.1;
  }

  CacheEntry copyWithNewTTL(Duration? ttl) {
    return CacheEntry(
      value: value,
      sizeBytes: sizeBytes,
      priority: priority,
      frequency: frequency,
      createdAt: _createdAt,
      lastAccessed: _lastAccessed,
      expiresAt: ttl == null ? null : DateTime.now().add(ttl),
    );
  }

  Map<String, Object?> toMap() => {
        'value': value,
        'sizeBytes': sizeBytes,
        'priority': priority,
        'frequency': frequency,
        'isExpired': isExpired,
        'created': _createdAt.toIso8601String(),
        'lastAccessed': _lastAccessed.toIso8601String(),
        'expiresAt': _expiresAt?.toIso8601String(),
        'ageInSeconds': ageInSeconds,
        'adaptiveScore': calculateAdaptiveScore(),
      };
}

class CacheSizeEstimator {
  static const _defaultObjectSize = 100;

  static int estimateSize(Object? value) {
    if (value == null) {
      return 0;
    }
    if (value is String) {
      return value.length * 2;
    }
    if (value is int || value is double) {
      return 8;
    }
    if (value is bool) {
      return 1;
    }
    if (value is List) {
      return value.fold<int>(
        24,
        (acc, item) => acc + estimateSize(item),
      );
    }
    if (value is Set) {
      return value.fold<int>(
        24,
        (acc, item) => acc + estimateSize(item),
      );
    }
    if (value is Map) {
      return value.entries.fold<int>(
        24,
        (acc, entry) =>
            acc + estimateSize(entry.key) + estimateSize(entry.value),
      );
    }
    return _defaultObjectSize;
  }

  static bool isReasonableSize(int sizeBytes, {int maxSizeMB = 10}) {
    if (sizeBytes <= 0) {
      return false;
    }
    final maxBytes = maxSizeMB * 1024 * 1024;
    if (sizeBytes > maxBytes) {
      return false;
    }
    final threshold = maxBytes * 0.1;
    return sizeBytes <= threshold;
  }

  static String formatSize(int sizeBytes) {
    if (sizeBytes <= 0) {
      return '0B';
    }
    if (sizeBytes < 1024) {
      return '${sizeBytes}B';
    }
    final kb = sizeBytes / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(1)}KB';
    }
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)}MB';
  }
}
