import 'dart:collection';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../cache_entry.dart';
import '../interfaces/cache_system_interfaces.dart';

/// Service spécialisé pour la couche mémoire du cache - SOLID COMPLIANT
///
/// SOLID COMPLIANCE:
/// - SRP: Responsabilité unique pour le cache mémoire uniquement
/// - OCP: Extensible via configuration et callbacks
/// - LSP: Compatible avec ICacheLayer pour substitution
/// - ISP: Interface focalisée sur les opérations mémoire uniquement
/// - DIP: Dépend des abstractions pour les callbacks et configuration
///
/// Features:
/// - Gestion optimisée de la mémoire avec limites configurables
/// - Expiration automatique des entrées avec timers
/// - Tracking des accès pour les stratégies d'éviction
/// - Concurrency-safe avec contrôle des collisions
/// - Monitoring intégré pour les métriques de performance
///
/// CONSTRAINTS: <200 lignes (extrait de 658 lignes)
class MemoryCacheLayer implements ICacheLayer {

  // Configuration et limites
  final int _maxMemoryUsage;
  final Duration _defaultTtl;
  final bool _debugLogging;

  // Storage interne optimisé
  final Map<String, CacheEntry> _memoryCache = <String, CacheEntry>{};
  final Queue<String> _accessOrder = Queue<String>();
  final Map<String, int> _accessCount = <String, int>{};
  final Map<String, Timer> _expirationTimers = <String, Timer>{};

  // Concurrency control
  final Map<String, Completer<dynamic>> _loadingKeys = <String, Completer<dynamic>>{};

  // Memory tracking
  int _currentMemoryUsage = 0;

  // Callbacks pour intégration avec les autres couches
  final ICacheStatisticsCallback? _statisticsCallback;

  MemoryCacheLayer({
    required int maxMemoryUsage,
    Duration defaultTtl = const Duration(hours: 1),
    bool debugLogging = false,
    ICacheStatisticsCallback? statisticsCallback,
  }) : _maxMemoryUsage = maxMemoryUsage,
       _defaultTtl = defaultTtl,
       _debugLogging = debugLogging,
       _statisticsCallback = statisticsCallback;

  @override
  String get layerName => 'Memory';

  @override
  bool get isAvailable => true;

  @override
  Future<T?> get<T>(String key) async {
    final entry = _memoryCache[key];

    if (entry != null && !entry.isExpired) {
      _updateAccessMetrics(key);
      _statisticsCallback?.recordHit(CacheLevel.memory);

      if (_debugLogging && kDebugMode) {
        debugPrint('💾 Memory Cache HIT: $key');
      }

      return entry.value as T?;
    }

    _statisticsCallback?.recordMiss(CacheLevel.memory);
    return null;
  }

  @override
  Future<void> set<T>(String key, T value, {Duration? ttl}) async {
    // Prévention cache stampede
    if (_loadingKeys.containsKey(key)) {
      await _loadingKeys[key]!.future;
      return;
    }

    final completer = Completer<dynamic>();
    _loadingKeys[key] = completer;

    try {
      final entry = CacheEntry(
        key: key,
        value: value,
        createdAt: DateTime.now(),
        ttl: ttl ?? _defaultTtl,
      );

      await _setEntry(key, entry);
      completer.complete(value);

    } catch (error) {
      completer.completeError(error);
      rethrow;
    } finally {
      _loadingKeys.remove(key);
    }
  }

  @override
  Future<void> remove(String key) async {
    final entry = _memoryCache.remove(key);
    if (entry != null) {
      _currentMemoryUsage -= entry.memorySize;
      _accessOrder.remove(key);
      _accessCount.remove(key);
      _expirationTimers[key]?.cancel();
      _expirationTimers.remove(key);

      if (_debugLogging && kDebugMode) {
        debugPrint('🗑️ Memory Cache REMOVE: $key');
      }
    }
  }

  @override
  Future<void> clear() async {
    _memoryCache.clear();
    _accessOrder.clear();
    _accessCount.clear();
    _currentMemoryUsage = 0;

    // Cancel all expiration timers
    for (final timer in _expirationTimers.values) {
      timer.cancel();
    }
    _expirationTimers.clear();

    if (_debugLogging && kDebugMode) {
      debugPrint('🧹 Memory Cache CLEARED');
    }
  }

  @override
  Future<bool> exists(String key) async {
    final entry = _memoryCache[key];
    return entry != null && !entry.isExpired;
  }

  @override
  Future<List<String>> getKeys() async {
    return _memoryCache.keys
        .where((key) => !_memoryCache[key]!.isExpired)
        .toList();
  }

  /// Métriques spécifiques à la couche mémoire
  CacheLayerMetrics getMetrics() {
    return CacheLayerMetrics(
      layerName: layerName,
      entryCount: _memoryCache.length,
      memoryUsage: _currentMemoryUsage,
      maxMemoryUsage: _maxMemoryUsage,
      averageAccessCount: _accessCount.isNotEmpty
        ? _accessCount.values.reduce((a, b) => a + b) / _accessCount.length
        : 0.0,
    );
  }

  /// Éviction forcée pour libération mémoire (utilisé par CacheEvictionService)
  Future<String?> evictLeastRecentlyUsed() async {
    if (_accessOrder.isNotEmpty) {
      final key = _accessOrder.removeFirst();
      await remove(key);
      return key;
    }
    return null;
  }

  /// Éviction LFU (Least Frequently Used)
  Future<String?> evictLeastFrequentlyUsed() async {
    if (_accessCount.isNotEmpty) {
      final key = _accessCount.entries
          .reduce((a, b) => a.value < b.value ? a : b)
          .key;
      await remove(key);
      return key;
    }
    return null;
  }

  /// Force l'éviction si nécessaire selon la mémoire disponible
  Future<bool> shouldEvict() async {
    return _currentMemoryUsage > _maxMemoryUsage * 0.9;
  }

  // === MÉTHODES PRIVÉES ===

  /// Stockage interne d'une entrée avec gestion mémoire
  Future<void> _setEntry(String key, CacheEntry entry) async {
    // Remove existing entry if any
    await remove(key);

    // Add new entry
    _memoryCache[key] = entry;
    _currentMemoryUsage += entry.memorySize;
    _updateAccessMetrics(key);

    // Setup expiration timer
    if (entry.ttl.inMicroseconds > 0) {
      _expirationTimers[key] = Timer(entry.ttl, () async {
        await remove(key);
      });
    }

    if (_debugLogging && kDebugMode) {
      debugPrint('💾 Memory Cache SET: $key (${entry.memorySize} bytes)');
    }
  }

  /// Mise à jour des métriques d'accès
  void _updateAccessMetrics(String key) {
    // Update access order (move to end for LRU)
    _accessOrder.remove(key);
    _accessOrder.addLast(key);

    // Update access count for LFU
    _accessCount[key] = (_accessCount[key] ?? 0) + 1;
  }
}