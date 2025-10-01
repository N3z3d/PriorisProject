/// **STATISTICS SERVICE** - SRP Specialized Component
///
/// **LOT 10** : Service spécialisé pour statistiques cache uniquement
/// **SRP** : Responsabilité unique = Collecte et calcul de statistiques
/// **Taille** : <60 lignes (extraction depuis God Class 658 lignes)

import 'dart:async';
import '../cache_statistics.dart';

/// Service spécialisé pour les statistiques du cache
///
/// **SRP** : Statistiques et monitoring uniquement
/// **DIP** : Injecte ses dépendances (statistics object, cache structures)
/// **OCP** : Extensible via nouvelles métriques
class StatisticsService {
  final CacheStatistics _statistics;
  final Map<String, dynamic> _memoryCache;
  final Map<String, int> _accessCount;

  const StatisticsService({
    required CacheStatistics statistics,
    required Map<String, dynamic> memoryCache,
    required Map<String, int> accessCount,
  }) : _statistics = statistics,
       _memoryCache = memoryCache,
       _accessCount = accessCount;

  /// Obtient les statistiques complètes du cache
  Future<CacheStatistics> getStatistics() async {
    return _statistics;
  }

  /// Obtient la répartition de l'utilisation mémoire
  Future<Map<String, int>> getMemoryBreakdown() async {
    final breakdown = <String, int>{};

    for (final entry in _memoryCache.entries) {
      final key = entry.key;
      final size = _estimateEntrySize(entry.value);
      breakdown[key] = size;
    }

    return breakdown;
  }

  /// Obtient les clés les plus accédées
  List<String> getMostAccessedKeys({int limit = 10}) {
    final sortedEntries = _accessCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries
        .take(limit)
        .map((e) => e.key)
        .toList();
  }

  /// Obtient un résumé des performances
  Map<String, dynamic> getPerformanceSummary() {
    final total = _statistics.hits + _statistics.misses;
    final hitRate = total > 0 ? _statistics.hits / total : 0.0;

    return {
      'hitRate': hitRate,
      'totalOperations': total,
      'averageOperationTime': _statistics.averageOperationTime,
      'memoryUsage': _memoryCache.length,
      'mostAccessed': getMostAccessedKeys(limit: 5),
    };
  }

  // ==================== MÉTHODES PRIVÉES ====================

  int _estimateEntrySize(dynamic value) {
    // Estimation simple de la taille
    if (value is String) {
      return value.length * 2; // UTF-16
    } else if (value is List) {
      return value.length * 8; // Estimation
    } else if (value is Map) {
      return value.length * 16; // Estimation
    }
    return 8; // Taille par défaut
  }
}