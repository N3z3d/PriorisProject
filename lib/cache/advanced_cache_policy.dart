part of 'advanced_cache.dart';

extension AdvancedCachePolicy on AdvancedCacheSystem {
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
