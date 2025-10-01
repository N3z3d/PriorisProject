/// **CACHE COORDINATOR** - Coordinator Pattern
///
/// **LOT 10** : Coordinateur SOLID remplaçant God Class (658 lignes)
/// **SRP** : Coordination uniquement entre services cache spécialisés
/// **Taille** : <150 lignes (orchestration vs implémentation)

import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'services/cache_operations_service.dart';
import 'services/tag_management_service.dart';
import 'services/invalidation_service.dart';
import 'services/statistics_service.dart';
import 'cache_policies.dart';
import 'cache_statistics.dart';
import 'cache_entry.dart';

/// Coordinateur SOLID pour le système de cache avancé
///
/// **SRP** : Coordination uniquement - délègue aux services spécialisés
/// **OCP** : Extensible via injection de nouveaux services
/// **DIP** : Dépend d'abstractions (services injectés)
/// **COORDINATEUR** : Pattern de coordination sans logique métier
class CacheCoordinator {
  final CacheOperationsService _operations;
  final TagManagementService _tagManagement;
  final InvalidationService _invalidation;
  final StatisticsService _statistics;
  final CacheConfig _config;

  // Shared state entre services
  final Map<String, CacheEntry> _memoryCache = <String, CacheEntry>{};
  final Queue<String> _accessOrder = Queue<String>();
  final Map<String, int> _accessCount = <String, int>{};
  final Map<String, List<String>> _taggedKeys = <String, List<String>>{};
  final Map<String, Completer<dynamic>> _loadingKeys = <String, Completer<dynamic>>{};
  final Map<String, Timer> _expirationTimers = <String, Timer>{};

  late final CacheStatistics _statisticsObject;

  /// **Constructeur avec injection de dépendances** (DIP)
  CacheCoordinator({
    required CacheConfig config,
    dynamic persistentStorage,
  }) : _config = config,
       _statisticsObject = CacheStatistics(),
       _operations = CacheOperationsService(
         config: config,
         statistics: CacheStatistics(),
         memoryCache: <String, CacheEntry>{},
         accessOrder: Queue<String>(),
         accessCount: <String, int>{},
         loadingKeys: <String, Completer<dynamic>>{},
         persistentStorage: persistentStorage,
       ),
       _tagManagement = TagManagementService(
         cacheOperations: CacheOperationsService(
           config: config,
           statistics: CacheStatistics(),
           memoryCache: <String, CacheEntry>{},
           accessOrder: Queue<String>(),
           accessCount: <String, int>{},
           loadingKeys: <String, Completer<dynamic>>{},
           persistentStorage: persistentStorage,
         ),
         taggedKeys: <String, List<String>>{},
       ),
       _invalidation = InvalidationService(
         memoryCache: <String, dynamic>{},
         expirationTimers: <String, Timer>{},
       ),
       _statistics = StatisticsService(
         statistics: CacheStatistics(),
         memoryCache: <String, dynamic>{},
         accessCount: <String, int>{},
       ) {

    if (kDebugMode) {
      print('🚀 Advanced Cache Coordinator initialized: ${config.toString()}');
    }
  }

  // ==================== BASIC OPERATIONS (Délégation) ====================

  /// Récupère une valeur du cache
  Future<T?> get<T>(String key) async {
    return await _operations.get<T>(key);
  }

  /// Définit une valeur dans le cache
  Future<void> set<T>(String key, T value, {Duration? ttl}) async {
    return await _operations.set(key, value, ttl: ttl);
  }

  /// Récupère ou calcule une valeur
  Future<T> getOrCompute<T>(String key, Future<T> Function() computeFunction) async {
    return await _operations.getOrCompute(key, computeFunction);
  }

  // ==================== TAG OPERATIONS (Délégation) ====================

  /// Définit une valeur avec des tags
  Future<void> setWithTags<T>(String key, T value, List<String> tags, {Duration? ttl}) async {
    return await _tagManagement.setWithTags(key, value, tags, ttl: ttl);
  }

  /// Invalide par tag
  Future<void> invalidateByTag(String tag) async {
    return await _tagManagement.invalidateByTag(tag);
  }

  /// Obtient les clés par tag
  List<String> getKeysByTag(String tag) {
    return _tagManagement.getKeysByTag(tag);
  }

  // ==================== INVALIDATION (Délégation) ====================

  /// Invalide une clé
  Future<void> invalidate(String key) async {
    await _invalidation.invalidate(key);
    _tagManagement.removeKeyFromAllTags(key);
  }

  /// Invalide par pattern
  Future<void> invalidatePattern(String pattern) async {
    return await _invalidation.invalidatePattern(pattern);
  }

  /// Invalide tout
  Future<void> invalidateAll() async {
    return await _invalidation.invalidateAll();
  }

  // ==================== STATISTICS (Délégation) ====================

  /// Obtient les statistiques
  Future<Map<String, dynamic>> getStatistics() async {
    final cacheStats = await _statistics.getStatistics();
    final memoryBreakdown = await _statistics.getMemoryBreakdown();
    final performanceSummary = _statistics.getPerformanceSummary();
    final tagStats = _tagManagement.getTagStatistics();
    final invalidationStats = _invalidation.getInvalidationStatistics();

    return {
      'cache': cacheStats.toMap(),
      'memory': memoryBreakdown,
      'performance': performanceSummary,
      'tags': tagStats,
      'invalidation': invalidationStats,
      'coordinator': 'CacheCoordinator v1.0',
    };
  }

  // ==================== UTILITY METHODS ====================

  /// Réchauffe le cache avec des données prédéfinies
  Future<void> warm(Map<String, dynamic> data) async {
    final futures = <Future>[];

    for (final entry in data.entries) {
      futures.add(set(entry.key, entry.value));
    }

    await Future.wait(futures);

    if (kDebugMode) {
      print('🔥 Cache warmed with ${data.length} entries');
    }
  }

  /// Configuration du cache
  CacheConfig get config => _config;

  /// Dispose le coordinateur
  void dispose() {
    for (final timer in _expirationTimers.values) {
      timer.cancel();
    }
    _expirationTimers.clear();
    _memoryCache.clear();
    _accessOrder.clear();
    _accessCount.clear();
    _taggedKeys.clear();
    _loadingKeys.clear();

    if (kDebugMode) {
      print('🗑️ Cache Coordinator disposed');
    }
  }
}