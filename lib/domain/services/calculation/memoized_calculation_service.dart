/// Service de mémorisation pour les calculs coûteux
class MemoizedCalculationService {
  static final _instance = MemoizedCalculationService._internal();
  factory MemoizedCalculationService() => _instance;
  MemoizedCalculationService._internal();

  // Cache pour les calculs
  final Map<String, _CacheEntry> _cache = {};
  static const _maxCacheSize = 100;
  static const _defaultTTL = Duration(minutes: 5);

  /// Mémorise un calcul de progression
  T memoizeProgress<T>(String key, T Function() calculation, {Duration? ttl}) {
    final cached = _getFromCache<T>(key);
    if (cached != null) return cached;
    
    final result = calculation();
    _addToCache(key, result, ttl ?? _defaultTTL);
    return result;
  }

  /// Calcul de progression avec mémoisation
  double calculateListProgress(String listId, List items) {
    return memoizeProgress('progress_$listId', () {
      if (items.isEmpty) return 0.0;
      final completed = items.where((item) => item.isCompleted == true).length;
      return completed / items.length;
    });
  }

  /// Calcul de stats avec mémoisation
  Map<String, dynamic> calculateStats(String key, List items) {
    return memoizeProgress('stats_$key', () {
      return {
        'total': items.length,
        'completed': items.where((i) => i.isCompleted == true).length,
        'progress': calculateListProgress(key, items),
        'avgElo': items.isEmpty ? 0.0 : 
          items.fold<double>(0, (sum, i) => sum + (i.eloScore ?? 0)) / items.length,
      };
    });
  }

  T? _getFromCache<T>(String key) {
    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.value as T;
  }

  void _addToCache(String key, dynamic value, Duration ttl) {
    if (_cache.length >= _maxCacheSize) {
      _evictOldest();
    }
    _cache[key] = _CacheEntry(value, DateTime.now().add(ttl));
  }

  void _evictOldest() {
    if (_cache.isEmpty) return;
    final oldest = _cache.entries.reduce((a, b) => 
      a.value.expiry.isBefore(b.value.expiry) ? a : b);
    _cache.remove(oldest.key);
  }

  void invalidate(String key) => _cache.remove(key);
  void invalidateAll() => _cache.clear();
}

class _CacheEntry {
  final dynamic value;
  final DateTime expiry;
  _CacheEntry(this.value, this.expiry);
  bool get isExpired => DateTime.now().isAfter(expiry);
}