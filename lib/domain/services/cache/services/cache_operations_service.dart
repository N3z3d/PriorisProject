/// **CACHE OPERATIONS SERVICE** - SRP Specialized Component
///
/// **LOT 10** : Service spécialisé pour opérations CRUD cache uniquement
/// **SRP** : Responsabilité unique = Get/Set/GetOrCompute du cache
/// **Taille** : <100 lignes (extraction depuis God Class 658 lignes)

import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../cache_policies.dart';
import '../cache_statistics.dart';
import '../cache_entry.dart';

/// Service spécialisé pour les opérations de base du cache
///
/// **SRP** : CRUD cache uniquement (get/set/getOrCompute)
/// **DIP** : Injecte ses dépendances (config, storage, statistics)
/// **OCP** : Extensible via nouvelles stratégies de sérialisation
class CacheOperationsService {
  final CacheConfig _config;
  final dynamic _persistentStorage;
  final CacheStatistics _statistics;

  // Internal state pour les opérations
  final Map<String, CacheEntry> _memoryCache;
  final Queue<String> _accessOrder;
  final Map<String, int> _accessCount;
  final Map<String, Completer<dynamic>> _loadingKeys;

  final Stopwatch _operationTimer = Stopwatch();

  const CacheOperationsService({
    required CacheConfig config,
    required CacheStatistics statistics,
    required Map<String, CacheEntry> memoryCache,
    required Queue<String> accessOrder,
    required Map<String, int> accessCount,
    required Map<String, Completer<dynamic>> loadingKeys,
    dynamic persistentStorage,
  }) : _config = config,
       _statistics = statistics,
       _memoryCache = memoryCache,
       _accessOrder = accessOrder,
       _accessCount = accessCount,
       _loadingKeys = loadingKeys,
       _persistentStorage = persistentStorage;

  /// Récupère une valeur du cache avec fallback multi-niveaux
  Future<T?> get<T>(String key) async {
    _operationTimer.reset();
    _operationTimer.start();

    try {
      _statistics.recordOperation();

      // Level 1: Memory cache
      final memoryEntry = _memoryCache[key];
      if (memoryEntry != null && !memoryEntry.isExpired) {
        _updateAccessMetrics(key);
        _statistics.recordHit(CacheLevel.memory);

        if (kDebugMode && _config.debugLogging) {
          print('💾 Cache HIT (Memory): $key');
        }

        return _deserializeValue<T>(memoryEntry.value);
      }

      // Level 2: Persistent cache
      if (_config.persistentCacheEnabled && _persistentStorage != null) {
        final persistentValue = await _persistentStorage.get<String>(key);
        if (persistentValue != null) {
          // Promote to memory cache
          final deserializedValue = _deserializeValue<T>(persistentValue);
          await setInMemory(key, deserializedValue, _config.defaultTtl);

          _statistics.recordHit(CacheLevel.persistent);

          if (kDebugMode && _config.debugLogging) {
            print('💾 Cache HIT (Persistent): $key - promoted to memory');
          }

          return deserializedValue;
        }
      }

      // Cache miss
      _statistics.recordMiss();

      if (kDebugMode && _config.debugLogging) {
        print('❌ Cache MISS: $key');
      }

      return null;

    } finally {
      _operationTimer.stop();
      _statistics.recordOperationTime(_operationTimer.elapsed);
    }
  }

  /// Définit une valeur dans le cache avec distribution intelligente
  Future<void> set<T>(String key, T value, {Duration? ttl}) async {
    _operationTimer.reset();
    _operationTimer.start();

    try {
      _statistics.recordOperation();
      final effectiveTtl = ttl ?? _config.defaultTtl;

      // Always set in memory cache first
      await setInMemory(key, value, effectiveTtl);

      // Set in persistent cache if enabled and value is large enough
      if (_config.persistentCacheEnabled &&
          _persistentStorage != null &&
          _shouldPersist(value)) {

        final serializedValue = _serializeValue(value);
        await _persistentStorage.set(key, serializedValue);

        if (kDebugMode && _config.debugLogging) {
          print('💾 Cache SET (Persistent): $key');
        }
      }

    } finally {
      _operationTimer.stop();
      _statistics.recordOperationTime(_operationTimer.elapsed);
    }
  }

  /// Récupère ou calcule une valeur (cache stampede prevention)
  Future<T> getOrCompute<T>(String key, Future<T> Function() computeFunction) async {
    // Check cache first
    final cachedValue = await get<T>(key);
    if (cachedValue != null) {
      return cachedValue;
    }

    // Check if already computing
    if (_loadingKeys.containsKey(key)) {
      return await _loadingKeys[key]!.future as T;
    }

    // Start computation
    final completer = Completer<T>();
    _loadingKeys[key] = completer as Completer<dynamic>;

    try {
      final computedValue = await computeFunction();
      await set(key, computedValue);
      completer.complete(computedValue);
      return computedValue;
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _loadingKeys.remove(key);
    }
  }

  /// Définit une valeur en mémoire avec expiration
  Future<void> setInMemory<T>(String key, T value, Duration ttl) async {
    final serializedValue = _serializeValue(value);
    final entry = CacheEntry(
      key: key,
      value: serializedValue,
      ttl: ttl,
      createdAt: DateTime.now(),
    );

    _memoryCache[key] = entry;
    _updateAccessMetrics(key);

    if (kDebugMode && _config.debugLogging) {
      print('💾 Cache SET (Memory): $key');
    }
  }

  // ==================== MÉTHODES PRIVÉES ====================

  void _updateAccessMetrics(String key) {
    _accessCount[key] = (_accessCount[key] ?? 0) + 1;
    _accessOrder.remove(key);
    _accessOrder.addLast(key);
  }

  T _deserializeValue<T>(dynamic value) {
    return value as T;
  }

  dynamic _serializeValue<T>(T value) {
    return value;
  }

  bool _shouldPersist<T>(T value) {
    // Simple heuristic: persist if value is "large"
    return true; // TODO: implement size-based logic
  }
}