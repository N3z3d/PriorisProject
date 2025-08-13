import 'dart:async';
import 'interfaces/cache_interface.dart' hide CacheStatsInterface, CacheStats;
import 'core_cache_service.dart';
import 'cache_expiration_service.dart';
import 'cache_stats_service.dart';

/// Service de cache unifié respectant les principes SOLID
/// 
/// Compose les différents services spécialisés selon le principe
/// de composition over inheritance et respecte l'Open/Closed principle.
class UnifiedCacheService<T> implements 
    CacheInterface<T>, 
    AdvancedCacheInterface<T>, 
    CacheStatsInterface,
    CacheInitializationInterface {
  
  late final CoreCacheService<T> _coreCache;
  late final CacheExpirationService _expirationService;
  late final CacheStatsService _statsService;
  
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _coreCache = CoreCacheService<T>(maxSize: 1000);
    _expirationService = CacheExpirationService(_coreCache);
    _statsService = CacheStatsService(_coreCache);
    
    _isInitialized = true;
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('Cache service not initialized. Call initialize() first.');
    }
  }

  // Implémentation de CacheInterface
  @override
  Future<void> set(String key, T value) async {
    _ensureInitialized();
    await _coreCache.set(key, value);
    _statsService.recordSet(key);
  }

  @override
  Future<T?> get(String key) async {
    _ensureInitialized();
    final value = await _coreCache.get(key);
    
    if (value != null) {
      _statsService.recordHit(key);
    } else {
      _statsService.recordMiss(key);
    }
    
    return value;
  }

  @override
  Future<void> remove(String key) async {
    _ensureInitialized();
    await _coreCache.remove(key);
    _statsService.recordRemove(key);
  }

  @override
  Future<bool> exists(String key) async {
    _ensureInitialized();
    return await _coreCache.exists(key);
  }

  @override
  Future<void> clear() async {
    _ensureInitialized();
    await _coreCache.clear();
  }

  // Implémentation de AdvancedCacheInterface
  @override
  Future<void> setWithOptions(
    String key, 
    T value, {
    Duration? ttl,
    bool compress = true,
    CachePriority priority = CachePriority.normal,
  }) async {
    _ensureInitialized();
    
    if (ttl != null) {
      await _expirationService.setWithTTL(key, value, ttl: ttl);
    } else {
      await _coreCache.set(key, value);
    }
    
    _statsService.recordSet(key);
  }

  @override
  Future<void> cleanup() async {
    _ensureInitialized();
    await _expirationService.cleanup();
    _statsService.recordCleanup();
  }

  @override
  Future<void> optimize() async {
    _ensureInitialized();
    // Logique d'optimisation personnalisée
    await cleanup();
  }

  // Implémentation de CacheStatsInterface
  @override
  Future<CacheStats> getStats() async {
    _ensureInitialized();
    return await _statsService.getStats();
  }

  // Implémentation de CacheInitializationInterface
  @override
  Future<void> dispose() async {
    if (_isInitialized) {
      _expirationService.dispose();
      _isInitialized = false;
    }
  }

  /// Méthodes supplémentaires pour une API complète
  
  /// Récupère avec vérification d'expiration
  Future<T?> getWithExpirationCheck(String key) async {
    _ensureInitialized();
    return await _expirationService.getIfNotExpired<T>(key);
  }

  /// Obtient les clés disponibles
  Iterable<String> get keys {
    _ensureInitialized();
    return _coreCache.keys;
  }

  /// Obtient le nombre d'entrées
  int get length {
    _ensureInitialized();
    return _coreCache.length;
  }
}