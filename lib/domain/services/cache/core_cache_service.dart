import 'dart:async';
import 'interfaces/cache_interface.dart';

/// Service de cache de base respectant le principe Single Responsibility
/// 
/// Se concentre uniquement sur les opérations de cache essentielles.
/// Les fonctionnalités avancées sont déléguées à d'autres services.
class CoreCacheService<T> implements CacheInterface<T> {
  final Map<String, T> _cache = {};
  final Map<String, DateTime> _accessTimes = {};
  final int _maxSize;

  CoreCacheService({int maxSize = 1000}) : _maxSize = maxSize;

  @override
  Future<void> set(String key, T value) async {
    if (_cache.length >= _maxSize) {
      await _removeLeastRecentlyUsed();
    }
    
    _cache[key] = value;
    _accessTimes[key] = DateTime.now();
  }

  @override
  Future<T?> get(String key) async {
    final value = _cache[key];
    if (value != null) {
      _accessTimes[key] = DateTime.now();
    }
    return value;
  }

  @override
  Future<void> remove(String key) async {
    _cache.remove(key);
    _accessTimes.remove(key);
  }

  @override
  Future<bool> exists(String key) async {
    return _cache.containsKey(key);
  }

  @override
  Future<void> clear() async {
    _cache.clear();
    _accessTimes.clear();
  }

  /// Supprime l'entrée la moins récemment utilisée
  Future<void> _removeLeastRecentlyUsed() async {
    if (_accessTimes.isEmpty) return;

    final oldestEntry = _accessTimes.entries
        .reduce((a, b) => a.value.isBefore(b.value) ? a : b);
    
    await remove(oldestEntry.key);
  }

  /// Obtient le nombre d'entrées actuelles
  int get length => _cache.length;

  /// Obtient toutes les clés
  Iterable<String> get keys => _cache.keys;
}