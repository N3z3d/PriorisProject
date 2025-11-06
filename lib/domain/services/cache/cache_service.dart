import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:prioris/domain/services/cache/core/cache_entry.dart';
import 'package:prioris/domain/services/cache/cache_statistics.dart';
import 'package:prioris/domain/services/cache/interfaces/cache_system_interfaces.dart';
import 'package:prioris/domain/services/cache/statistics/cache_statistics_service.dart';

export 'cache_statistics.dart' show CacheStats;

final _zlibCodec = ZLibCodec();

class CacheService {
  CacheService({int maxEntries = 1000}) : _maxEntries = maxEntries;

  final int _maxEntries;
  final _entries = <String, _CacheRecord>{};
  final _statistics = CacheStatisticsService();
  bool _initialized = false;

  Future<void> initialize() async {
    _initialized = true;
  }

  Future<void> dispose() async {
    _entries.clear();
    _statistics.dispose();
    _initialized = false;
  }

  Future<void> set(
    String key,
    dynamic value, {
    Duration? ttl,
    bool compress = false,
    int priority = 0,
  }) async {
    _ensureInitialized();

    final size = CacheSizeEstimator.estimateSize(value);
    if (value != null &&
        !CacheSizeEstimator.isReasonableSize(size, maxSizeMB: 20)) {
      throw CacheException(
        'Value too large for cache',
        details: {'key': key, 'sizeBytes': size},
      );
    }

    final record = _createRecord(
      key: key,
      value: value,
      size: size,
      ttl: ttl,
      compress: compress,
      priority: priority,
    );

    _entries[key] = record;
    _statistics.recordWrite();
    await _evictIfNeeded();
  }

  Future<void> setWithTags(
    String key,
    dynamic value,
    List<String> tags, {
    Duration? ttl,
  }) async {
    await set(key, value, ttl: ttl);
    final record = _entries[key];
    if (record != null) {
      record.tags
        ..clear()
        ..addAll(tags.toSet());
    }
  }

  Future<T?> get<T>(String key) async {
    _ensureInitialized();
    _statistics.recordAccess();

    final record = _entries[key];
    if (record == null) {
      _statistics.recordMiss();
      return null;
    }
    if (record.entry.isExpired) {
      _entries.remove(key);
      _statistics.recordMiss();
      return null;
    }

    record.entry.incrementFrequency();
    _statistics.recordHit();
    return record.readValue<T>();
  }

  Future<bool> exists(String key) async =>
      _entries.containsKey(key) && !(_entries[key]!.entry.isExpired);

  Future<void> remove(String key) async {
    _entries.remove(key);
  }

  Future<void> clear() async {
    _entries.clear();
    _statistics.reset();
  }

  Future<void> cleanup() async {
    final now = DateTime.now();
    _entries.removeWhere((_, record) => record.entry.isExpired);
    _lastCleanup = now;
  }

  Future<void> optimize() async {
    await cleanup();
    if (_entries.length > _maxEntries) {
      await _evictIfNeeded(force: true);
    }
  }

  DateTime? _lastCleanup;

  Future<CacheStats> getStats() async {
    final totalSize = _entries.values.fold<int>(
      0,
      (total, record) => total + record.entry.sizeBytes,
    );
    final diskUsageMB = totalSize / (1024 * 1024);
    _lastCleanup ??= DateTime.now();

    return CacheStats(
      totalEntries: _entries.length,
      totalSize: totalSize,
      hitRate: _statistics.hitRate,
      missRate: _statistics.missRate,
      diskUsageMB: diskUsageMB,
      generatedAt: DateTime.now(),
      lastCleanup: _lastCleanup,
    );
  }

  CacheStatisticsSnapshot createStatisticsSnapshot() =>
      _statistics.createSnapshot();

  Map<String, Object?> get detailedStatistics =>
      _statistics.getStatistics();

  Map<String, Object?> get performanceReport =>
      _statistics.getPerformanceReport();

  _CacheRecord _createRecord({
    required String key,
    required dynamic value,
    required int size,
    Duration? ttl,
    required bool compress,
    required int priority,
  }) {
    dynamic storedValue = value;
    Uint8List? compressed;
    if (compress && value is String && value.length > 128) {
      final bytes = utf8.encode(value);
      compressed = Uint8List.fromList(_zlibCodec.encode(bytes));
      storedValue = null;
    }

    final entry = CacheEntry(
      value: storedValue ?? value,
      sizeBytes: size,
      priority: priority,
      ttl: ttl,
    );

    return _CacheRecord(
      entry: entry,
      rawValue: storedValue,
      compressedValue: compressed,
    );
  }

  Future<void> _evictIfNeeded({bool force = false}) async {
    if (!force && _entries.length <= _maxEntries) {
      return;
    }
    final entries = _entries.entries.toList()
      ..sort(
        (a, b) =>
            a.value.entry.lastAccessed.compareTo(b.value.entry.lastAccessed),
      );
    while (_entries.length > _maxEntries && entries.isNotEmpty) {
      final victim = entries.removeAt(0);
      _entries.remove(victim.key);
      _statistics.recordEviction();
    }
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw CacheException('CacheService not initialized');
    }
  }
}

class _CacheRecord {
  _CacheRecord({
    required this.entry,
    required this.rawValue,
    required this.compressedValue,
  });

  final CacheEntry entry;
  final dynamic rawValue;
  final Uint8List? compressedValue;
  final Set<String> tags = <String>{};

  T? readValue<T>() {
    if (compressedValue != null) {
      final decoded = utf8.decode(_zlibCodec.decode(compressedValue!));
      return decoded as T?;
    }
    return rawValue as T?;
  }
}
