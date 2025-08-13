/// Interface pour les opérations de cache de base
/// 
/// Respecte le principe Interface Segregation en se concentrant
/// uniquement sur les opérations de cache essentielles.
abstract class CacheInterface<T> {
  /// Sauvegarde une valeur dans le cache
  Future<void> set(String key, T value);
  
  /// Récupère une valeur du cache
  Future<T?> get(String key);
  
  /// Supprime une entrée du cache
  Future<void> remove(String key);
  
  /// Vérifie si une clé existe
  Future<bool> exists(String key);
  
  /// Vide le cache
  Future<void> clear();
}

/// Interface pour les opérations de cache avancées
/// 
/// Séparée des opérations de base selon le principe
/// Interface Segregation.
abstract class AdvancedCacheInterface<T> {
  /// Sauvegarde avec options avancées (TTL, compression, priorité)
  Future<void> setWithOptions(
    String key, 
    T value, {
    Duration? ttl,
    bool compress = true,
    CachePriority priority = CachePriority.normal,
  });
  
  /// Nettoie les entrées expirées
  Future<void> cleanup();
  
  /// Optimise l'espace disque
  Future<void> optimize();
}

/// Interface pour les statistiques du cache
/// 
/// Permet d'obtenir des informations sur les performances
/// sans coupler à l'implémentation du cache.
abstract class CacheStatsInterface {
  /// Récupère les statistiques du cache
  Future<CacheStats> getStats();
}

/// Interface pour l'initialisation du cache
/// 
/// Sépare la logique d'initialisation des opérations de cache.
abstract class CacheInitializationInterface {
  /// Initialise le service de cache
  Future<void> initialize();
  
  /// Libère les ressources
  Future<void> dispose();
}

/// Priorité du cache
enum CachePriority {
  low,
  normal,
  high,
  critical,
}

/// Statistiques du cache
class CacheStats {
  final int totalEntries;
  final int totalSize;
  final double hitRate;
  final Duration averageAccessTime;
  final double diskUsageMB;
  final DateTime lastCleanup;
  
  const CacheStats({
    required this.totalEntries,
    required this.totalSize,
    required this.hitRate,
    required this.averageAccessTime,
    required this.diskUsageMB,
    required this.lastCleanup,
  });
  
  @override
  String toString() {
    return 'CacheStats('
        'entries: $totalEntries, '
        'size: ${(totalSize / 1024).toStringAsFixed(2)}KB, '
        'hitRate: ${(hitRate * 100).toStringAsFixed(1)}%, '
        'avgAccess: ${averageAccessTime.inMilliseconds}ms, '
        'diskUsage: ${diskUsageMB.toStringAsFixed(2)}MB, '
        'lastCleanup: $lastCleanup)';
  }
}