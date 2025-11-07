import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'core/cache_entry.dart';
import 'cache_policies.dart';
import 'cache_statistics.dart';
import 'interfaces/cache_system_interfaces.dart';

typedef PrefetchStrategy = Future<List<String>> Function(String key);

final _zlibCodec = ZLibCodec();

class AdvancedCacheSystem {
  AdvancedCacheSystem({
    CacheConfig? config,
    Object? persistentStorage,
  })  : _config = config ?? const CacheConfig(),
        _storage = persistentStorage == null
            ? null
            : _DynamicStorageAdapter(persistentStorage);

  final CacheConfig _config;
  final _DynamicStorageAdapter? _storage;
  final _entries = <String, _CacheRecord>{};
  final _tagIndex = <String, Set<String>>{};
  final _inFlightComputations = <String, Future>{};
  final _stats = CacheSystemStatistics();
  bool _disposed = false;

  Future<void> set(
    String key,
    dynamic value, {
    Duration? ttl,
    CacheStrategy? strategy,
    List<String>? tags,
    int priority = 0,
    bool compress = false,
  }) async {
    _setInternal(
      key,
      value,
      ttl: ttl,
      tags: tags,
      priority: priority,
      compress: compress,
    );
    await _evictIfNeeded(strategy: strategy, protectedKey: key);
  }

  void setSync(
    String key,
    dynamic value, {
    Duration? ttl,
    CacheStrategy? strategy,
    List<String>? tags,
    int priority = 0,
    bool compress = false,
  }) {
    _setInternal(
      key,
      value,
      ttl: ttl,
      tags: tags,
      priority: priority,
      compress: compress,
    );
    unawaited(_evictIfNeeded(strategy: strategy, protectedKey: key));
  }

  Future<T?> get<T>(String key, {CacheStrategy? strategy}) async {
    _ensureActive();
    final stopwatch = Stopwatch()..start();
    final record = _entries[key];
    _stats.totalOperations += 1;

    if (record == null) {
      _stats.missCount += 1;
      stopwatch.stop();
      _stats.totalLatency += stopwatch.elapsed;
      final restored = await _safeStorageGet<T>(key);
      if (restored != null) {
        await set(key, restored, strategy: strategy);
      }
      return restored;
    }

    if (record.entry.isExpired) {
      await invalidate(key);
      _stats.missCount += 1;
      stopwatch.stop();
      _stats.totalLatency += stopwatch.elapsed;
      return null;
    }

    record.entry.incrementFrequency();
    _stats.hitCount += 1;
    stopwatch.stop();
    _stats.totalLatency += stopwatch.elapsed;
    return record.readValue<T>();
  }

  T? peek<T>(String key) {
    _ensureActive();
    _stats.totalOperations += 1;
    final record = _entries[key];
    if (record == null) {
      _stats.missCount += 1;
      return null;
    }
    if (record.entry.isExpired) {
      _stats.missCount += 1;
      invalidateSync(key);
      return null;
    }

    record.entry.incrementFrequency();
    _stats.hitCount += 1;
    return record.readValue<T>();
  }

  void _setInternal(
    String key,
    dynamic value, {
    Duration? ttl,
    List<String>? tags,
    int priority = 0,
    bool compress = false,
  }) {
    _ensureActive();
    final stopwatch = Stopwatch()..start();
    final effectiveTtl = ttl ?? _config.defaultTtl;
    final size = CacheSizeEstimator.estimateSize(value);
    if (value != null &&
        !CacheSizeEstimator.isReasonableSize(size, maxSizeMB: 20)) {
      throw CacheException(
        'Value too large for cache',
        details: {'key': key, 'sizeBytes': size},
      );
    }

    final record = _CacheRecord.fromValue(
      value: value,
      ttl: effectiveTtl,
      priority: priority,
      compress: (compress || _config.compressionEnabled),
    );

    _entries[key] = record;
    _stats.totalItems = _entries.length;
    _stats.memoryUsage = _entries.values.fold<int>(
      0,
      (total, element) => total + element.entry.sizeBytes,
    );
    _stats.totalCompressedItems += record.compressedValue != null ? 1 : 0;
    _stats.totalCompressionSavings += record.compressionSavings;

    if (tags != null && tags.isNotEmpty) {
      for (final tag in tags) {
        _tagIndex.putIfAbsent(tag, () => <String>{}).add(key);
      }
      record.tags
        ..clear()
        ..addAll(tags);
    }

    stopwatch.stop();
    _stats.totalOperations += 1;
    _stats.totalLatency += stopwatch.elapsed;
    _stats.writeCount += 1;
  }

  _CacheRecord? _invalidateInternal(String key) {
    final record = _entries.remove(key);
    if (record == null) {
      return null;
    }
    for (final tag in record.tags) {
      final keys = _tagIndex[tag];
      keys?.remove(key);
      if (keys != null && keys.isEmpty) {
        _tagIndex.remove(tag);
      }
    }
    _stats.totalItems = _entries.length;
    _stats.evictionCount += 1;
    return record;
  }

  void invalidateSync(String key) {
    final record = _invalidateInternal(key);
    if (record == null || !_config.persistentCacheEnabled) {
      return;
    }
    final future = _storage?.remove(key);
    if (future != null) {
      unawaited(future);
    }
  }

  void _invalidatePatternInternal(String pattern) {
    final regex = RegExp('^' + pattern.replaceAll('*', '.*') + r'$');
    final keys = _entries.keys.where(regex.hasMatch).toList();
    for (final key in keys) {
      _invalidateInternal(key);
    }
  }

  void invalidatePatternSync(String pattern) {
    _invalidatePatternInternal(pattern);
    if (_config.persistentCacheEnabled) {
      unawaited(
        _safeStorageKeys().then(
          (keys) async {
            final regex = RegExp('^' + pattern.replaceAll('*', '.*') + r'$');
            for (final key in keys.where(regex.hasMatch)) {
              await _storage?.remove(key);
            }
          },
        ),
      );
    }
  }

  void _clearInternal() {
    _entries.clear();
    _tagIndex.clear();
    _inFlightComputations.clear();
    _resetStatistics();
  }

  void clearSync() {
    _ensureActive();
    _clearInternal();
    if (_config.persistentCacheEnabled) {
      final future = _storage?.clear();
      if (future != null) {
        unawaited(future);
      }
    }
  }

  Future<void> setWithTags(
    String key,
    dynamic value,
    List<String> tags, {
    Duration? ttl,
  }) =>
      set(key, value, ttl: ttl, tags: tags);

  Future<void> warm(Map<String, dynamic> data) async {
    for (final entry in data.entries) {
      await set(entry.key, entry.value);
    }
  }

  Future<void> prefetch(
    String key,
    PrefetchStrategy strategy,
  ) async {
    final keys = await strategy(key);
    _stats.prefetchAttempts += 1;
    for (final relatedKey in keys) {
      await get<dynamic>(relatedKey);
    }
  }

  Future<void> invalidate(String key) async {
    final record = _invalidateInternal(key);
    if (record == null) {
      return;
    }
    if (_config.persistentCacheEnabled) {
      await _storage?.remove(key);
    }
  }

  Future<void> invalidatePattern(String pattern) async {
    _invalidatePatternInternal(pattern);
    if (_config.persistentCacheEnabled) {
      final regex = RegExp('^' + pattern.replaceAll('*', '.*') + r'$');
      final keys = await _safeStorageKeys();
      for (final key in keys.where(regex.hasMatch)) {
        await _storage?.remove(key);
      }
    }
  }

  Future<void> invalidateByTag(String tag) async {
    final keys = _tagIndex[tag]?.toList() ?? const [];
    for (final key in keys) {
      await invalidate(key);
    }
  }

  Future<void> persistToStorage() async {
    if (_storage == null) {
      return;
    }
    for (final entry in _entries.entries) {
      await _safeStorageSet(entry.key, entry.value.serialize());
    }
  }

  Future<void> restoreFromStorage() async {
    if (_storage == null) {
      return;
    }
    final keys = await _safeStorageKeys();
    for (final key in keys) {
      final data = await _safeStorageGet<dynamic>(key);
      if (data == null) {
        continue;
      }
      if (data is Map<String, Object?>) {
        _entries[key] = _CacheRecord.deserialize(data);
      } else {
        await set(key, data);
      }
    }
  }

  Future<void> triggerGarbageCollection() async {
    await _evictExpired();
    final target = (_config.effectiveMaxEntries * 0.9).ceil();
    await _trimToCapacity(target);
  }

  Future<Map<String, num>> getMemoryBreakdown() async {
    final total = max(1, _config.memorySize * 1024 * 1024);
    final used = _entries.values.fold<int>(
      0,
      (total, record) => total + record.entry.sizeBytes,
    );
    return {
      'total_memory': total,
      'used_memory': used,
      'available_memory': total - used,
      'cache_overhead': max(0, used * 0.05),
    };
  }

  Future<T> getOrCompute<T>(
    String key,
    Future<T> Function() loader,
  ) async {
    final existing = await get<T>(key);
    if (existing != null) {
      return existing;
    }

    if (_inFlightComputations.containsKey(key)) {
      return _inFlightComputations[key] as Future<T>;
    }

    final future = loader().then((value) async {
      await set(key, value);
      _inFlightComputations.remove(key);
      return value;
    });
    _inFlightComputations[key] = future;
    return future;
  }

  CacheSystemStatistics getStatistics() {
    _stats.memoryLimit = max(1, _config.memorySize * 1024 * 1024);
    _stats.capacityEntries = _config.effectiveMaxEntries;
    _stats.memoryUsage = _entries.values.fold<int>(
      0,
      (total, record) => total + record.entry.sizeBytes,
    );
    return _stats.copy();
  }

  List<String> keys() => List.unmodifiable(_entries.keys);

  Future<void> clear() async {
    _ensureActive();
    _clearInternal();
    if (_config.persistentCacheEnabled) {
      await _storage?.clear();
    }
  }

  Future<void> dispose() async {
    _entries.clear();
    _tagIndex.clear();
    _inFlightComputations.clear();
    _resetStatistics();
    _disposed = true;
  }

  Future<void> _evictIfNeeded({CacheStrategy? strategy, String? protectedKey}) async {
    await _evictExpired();
    if (_entries.length <= _config.effectiveMaxEntries) {
      return;
    }
    switch (_config.evictionPolicy) {
      case EvictionPolicy.lru:
        await _trimUsing(
          (a, b) =>
              a.entry.lastAccessed.compareTo(b.entry.lastAccessed),
          protectedKey: protectedKey,
        );
        break;
      case EvictionPolicy.lfu:
        await _trimUsing(
          (a, b) => a.entry.frequency.compareTo(b.entry.frequency),
          protectedKey: protectedKey,
        );
        break;
      case EvictionPolicy.ttl:
        await _trimUsing((a, b) {
          final aExpires = a.entry.expiresAt ?? DateTime.now();
          final bExpires = b.entry.expiresAt ?? DateTime.now();
          return aExpires.compareTo(bExpires);
        }, protectedKey: protectedKey);
        break;
      case EvictionPolicy.adaptive:
        await _trimUsing(
          (a, b) => a.entry.calculateAdaptiveScore()
              .compareTo(b.entry.calculateAdaptiveScore()),
          protectedKey: protectedKey,
        );
        break;
    }
  }

  Future<void> _evictExpired() async {
    _entries.removeWhere((_, record) => record.entry.isExpired);
    _stats.totalItems = _entries.length;
  }

  Future<void> _trimUsing(
    int Function(_CacheRecord a, _CacheRecord b) comparator, {
    String? protectedKey,
  }) async {
    final target = _config.effectiveMaxEntries;
    final sorted = _entries.entries.toList()
      ..sort((a, b) => comparator(a.value, b.value));
    if (protectedKey != null) {
      sorted.removeWhere((entry) => entry.key == protectedKey);
    }
    while (_entries.length > target && sorted.isNotEmpty) {
      final victim = sorted.removeAt(0);
      await invalidate(victim.key);
    }
    _stats.totalItems = _entries.length;
  }

  Future<void> _trimToCapacity(int target) async {
    if (_entries.length <= target) {
      return;
    }
    final sorted = _entries.entries.toList()
      ..sort(
        (a, b) =>
            a.value.entry.lastAccessed.compareTo(b.value.entry.lastAccessed),
      );
    while (_entries.length > target && sorted.isNotEmpty) {
      final victim = sorted.removeAt(0);
      await invalidate(victim.key);
    }
    _stats.totalItems = _entries.length;
  }

  void _ensureActive() {
    if (_disposed) {
      throw CacheException('AdvancedCacheSystem disposed');
    }
  }

  void _resetStatistics() {
    _stats
      ..totalItems = _entries.length
      ..memoryUsage = _entries.values.fold<int>(
        0,
        (total, record) => total + record.entry.sizeBytes,
      )
      ..totalOperations = 0
      ..totalLatency = Duration.zero
      ..hitCount = 0
      ..missCount = 0
      ..writeCount = 0
      ..evictionCount = 0
      ..prefetchAttempts = 0
      ..totalCompressedItems = 0
      ..totalCompressionSavings = 0;
  }

  Future<T?> _safeStorageGet<T>(String key) async {
    if (_storage == null) {
      return null;
    }
    try {
      return await _storage!.get<T>(key);
    } catch (_) {
      return null;
    }
  }

  Future<void> _safeStorageSet(String key, Object? value) async {
    if (_storage == null) {
      return;
    }
    try {
      await _storage!.set(key, value);
    } catch (_) {
      // Ignore persistence errors during tests
    }
  }

  Future<List<String>> _safeStorageKeys() async {
    if (_storage == null) {
      return const [];
    }
    try {
      return await _storage!.keys();
    } catch (_) {
      return const [];
    }
  }
}

class _CacheRecord {
  _CacheRecord({
    required this.entry,
    required this.rawValue,
    required this.compressedValue,
    required this.compressionSavings,
    this.encodedAsJson = false,
  });

  final CacheEntry entry;
  final dynamic rawValue;
  final Uint8List? compressedValue;
  final int compressionSavings;
  final bool encodedAsJson;
  final Set<String> tags = <String>{};

  static _CacheRecord fromValue({
    required dynamic value,
    required Duration ttl,
    required int priority,
    required bool compress,
  }) {
    Uint8List? compressed;
    int savings = 0;
    dynamic storedValue = value;
    var encodeAsJson = false;

    if (compress) {
      if (value is String && value.length > 128) {
        final bytes = utf8.encode(value);
        compressed = Uint8List.fromList(_zlibCodec.encode(bytes));
        savings = bytes.length - compressed.length;
        storedValue = null;
      } else if (value is List || value is Map) {
        final jsonString = jsonEncode(value);
        final bytes = utf8.encode(jsonString);
        compressed = Uint8List.fromList(_zlibCodec.encode(bytes));
        final originalSize = CacheSizeEstimator.estimateSize(value);
        savings = max(0, originalSize - compressed.length);
        storedValue = null;
        encodeAsJson = true;
        value = jsonDecode(jsonString); // ensure serialization friendly
      }
    }

    final sizeBytes =
        compressed?.length ?? CacheSizeEstimator.estimateSize(value);
    final entry = CacheEntry(
      value: storedValue ?? value,
      sizeBytes: sizeBytes,
      priority: priority,
      ttl: ttl,
    );

    return _CacheRecord(
      entry: entry,
      rawValue: storedValue,
      compressedValue: compressed,
      compressionSavings: max(0, savings),
      encodedAsJson: encodeAsJson,
    );
  }

  T? readValue<T>() {
    if (compressedValue != null) {
      final decoded = utf8.decode(_zlibCodec.decode(compressedValue!));
      if (encodedAsJson) {
        final dynamic jsonValue = jsonDecode(decoded);
        if (jsonValue is List) {
          if (jsonValue.isEmpty) {
            return <dynamic>[] as T;
          }
          if (jsonValue.every((element) => element is int)) {
            return List<int>.from(jsonValue) as T;
          }
          if (jsonValue.every((element) => element is double)) {
            return List<double>.from(jsonValue) as T;
          }
          if (jsonValue.every((element) => element is String)) {
            return List<String>.from(jsonValue) as T;
          }
          return List<dynamic>.from(jsonValue) as T;
        }
        if (jsonValue is Map) {
          if (jsonValue.keys.every((element) => element is String)) {
            final map = Map<String, dynamic>.from(jsonValue as Map);
            if (map.values.every((element) => element is String)) {
              return Map<String, String>.from(map) as T;
            }
            if (map.values.every((element) => element is int)) {
              return Map<String, int>.from(map.map(
                (key, value) => MapEntry(key, value as int),
              )) as T;
            }
            if (map.values.every((element) => element is double)) {
              return Map<String, double>.from(map.map(
                (key, value) => MapEntry(key, value as double),
              )) as T;
            }
            return map as T;
          }
          return Map<dynamic, dynamic>.from(jsonValue) as T;
        }
        return jsonValue as T?;
      }
      return decoded as T?;
    }
    final value = rawValue;
    if (value == null) {
      return null;
    }
    if (value is T) {
      return value;
    }
    if (value is List) {
      if (value.isEmpty) {
        return <dynamic>[] as T;
      }
      if (value.every((element) => element is int)) {
        return List<int>.from(value) as T;
      }
      if (value.every((element) => element is double)) {
        return List<double>.from(value) as T;
      }
      if (value.every((element) => element is String)) {
        return List<String>.from(value) as T;
      }
      return List<dynamic>.from(value) as T;
    }
    if (value is Map) {
      if (value.keys.every((element) => element is String)) {
        final map = Map<String, dynamic>.from(value as Map);
        if (map.values.every((element) => element is String)) {
          return Map<String, String>.from(map) as T;
        }
        if (map.values.every((element) => element is int)) {
          return Map<String, int>.from(map.map(
            (key, value) => MapEntry(key, value as int),
          )) as T;
        }
        if (map.values.every((element) => element is double)) {
          return Map<String, double>.from(map.map(
            (key, value) => MapEntry(key, value as double),
          )) as T;
        }
        return map as T;
      }
      return Map<dynamic, dynamic>.from(value) as T;
    }
    return value as T?;
  }

  Map<String, Object?> serialize() => {
        'value': rawValue,
        'compressed': compressedValue,
        'priority': entry.priority,
        'frequency': entry.frequency,
        'createdAt': entry.createdAt.toIso8601String(),
        'lastAccessed': entry.lastAccessed.toIso8601String(),
        'expiresAt': entry.expiresAt?.toIso8601String(),
        'compressionSavings': compressionSavings,
        'encodedAsJson': encodedAsJson,
      };

  static _CacheRecord deserialize(Map<String, Object?> data) {
    Uint8List? compressed;
    final serialized = data['compressed'];
    if (serialized is Uint8List) {
      compressed = serialized;
    }
    final record = _CacheRecord(
      entry: CacheEntry(
        value: data['value'],
        sizeBytes: CacheSizeEstimator.estimateSize(data['value']),
        priority: data['priority'] as int? ?? 0,
        frequency: data['frequency'] as int? ?? 1,
        createdAt: DateTime.tryParse(data['createdAt'] as String? ?? ''),
        lastAccessed: DateTime.tryParse(data['lastAccessed'] as String? ?? ''),
        expiresAt: DateTime.tryParse(data['expiresAt'] as String? ?? ''),
      ),
      rawValue: data['value'],
      compressedValue: compressed,
      compressionSavings: data['compressionSavings'] as int? ?? 0,
      encodedAsJson: data['encodedAsJson'] as bool? ?? false,
    );
    return record;
  }
}

class _DynamicStorageAdapter {
  _DynamicStorageAdapter(this._delegate);

  final Object _delegate;

  Future<T?> get<T>(String key) async {
    return await (_delegate as dynamic).get<T>(key);
  }

  Future<void> set<T>(String key, T value) async {
    await (_delegate as dynamic).set<T>(key, value);
  }

  Future<void> remove(String key) async {
    await (_delegate as dynamic).remove(key);
  }

  Future<void> clear() async {
    await (_delegate as dynamic).clear();
  }

  Future<List<String>> keys() async {
    final result = await (_delegate as dynamic).keys();
    if (result is List) {
      return result.cast<String>();
    }
    return const [];
  }
}
