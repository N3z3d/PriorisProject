import 'dart:async';
import 'interfaces/cache_interface.dart';

/// Service responsable du calcul des statistiques de cache
/// 
/// Respecte le principe Single Responsibility en se concentrant
/// uniquement sur le monitoring et les statistiques.
class CacheStatsService implements CacheStatsInterface {
  final CacheInterface _cache;
  final Map<String, int> _operationCounts = {
    'hits': 0,
    'misses': 0,
    'sets': 0,
    'removes': 0,
  };
  final Map<String, DateTime> _accessTimes = {};
  DateTime _lastCleanup = DateTime.now();

  CacheStatsService(this._cache);

  /// Enregistre un hit de cache
  void recordHit(String key) {
    _operationCounts['hits'] = (_operationCounts['hits'] ?? 0) + 1;
    _accessTimes[key] = DateTime.now();
  }

  /// Enregistre un miss de cache
  void recordMiss(String key) {
    _operationCounts['misses'] = (_operationCounts['misses'] ?? 0) + 1;
  }

  /// Enregistre une opération set
  void recordSet(String key) {
    _operationCounts['sets'] = (_operationCounts['sets'] ?? 0) + 1;
    _accessTimes[key] = DateTime.now();
  }

  /// Enregistre une opération remove
  void recordRemove(String key) {
    _operationCounts['removes'] = (_operationCounts['removes'] ?? 0) + 1;
    _accessTimes.remove(key);
  }

  /// Met à jour la date du dernier nettoyage
  void recordCleanup() {
    _lastCleanup = DateTime.now();
  }

  @override
  Future<CacheStats> getStats() async {
    return CacheStats(
      totalEntries: await _getTotalEntries(),
      totalSize: await _calculateTotalSize(),
      hitRate: _calculateHitRate(),
      averageAccessTime: _calculateAverageAccessTime(),
      diskUsageMB: 0.0, // Non applicable pour cache mémoire
      lastCleanup: _lastCleanup,
    );
  }

  /// Obtient le nombre total d'entrées
  Future<int> _getTotalEntries() async {
    // Si le cache expose une propriété length
    try {
      return (_cache as dynamic).length ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Calcule la taille totale approximative
  Future<int> _calculateTotalSize() async {
    // Approximation basée sur le nombre d'entrées
    final entries = await _getTotalEntries();
    return entries * 50; // 50 bytes par entrée en moyenne
  }

  /// Calcule le taux de hit
  double _calculateHitRate() {
    final hits = _operationCounts['hits'] ?? 0;
    final misses = _operationCounts['misses'] ?? 0;
    final total = hits + misses;
    
    if (total == 0) return 0.0;
    return hits / total;
  }

  /// Calcule le temps d'accès moyen
  Duration _calculateAverageAccessTime() {
    if (_accessTimes.isEmpty) return Duration.zero;
    
    final now = DateTime.now();
    final totalDuration = _accessTimes.values
        .map((time) => now.difference(time))
        .fold(Duration.zero, (a, b) => a + b);
    
    return Duration(
      milliseconds: totalDuration.inMilliseconds ~/ _accessTimes.length,
    );
  }

  /// Remet à zéro les statistiques
  void resetStats() {
    _operationCounts.clear();
    _operationCounts.addAll({
      'hits': 0,
      'misses': 0,
      'sets': 0,
      'removes': 0,
    });
    _accessTimes.clear();
    _lastCleanup = DateTime.now();
  }

  /// Obtient un résumé des opérations
  Map<String, int> get operationSummary => Map.from(_operationCounts);
}

/// Interface pour les statistiques de cache
abstract class CacheStatsInterface {
  Future<CacheStats> getStats();
}

/// Classe représentant les statistiques de cache
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