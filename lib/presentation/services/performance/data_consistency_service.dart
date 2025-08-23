import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';

/// Service pour garantir la cohérence des données à travers le cycle de vie de l'app
/// 
/// Ce service implémente des stratégies de cache et de vérification pour éliminer
/// les problèmes de "0 listes" au démarrage puis "253 items" après navigation.
class DataConsistencyService {
  static const String _cacheKey = 'last_known_lists_count';
  static const String _lastLoadTimeKey = 'last_successful_load_time';
  
  // Cache en mémoire pour éviter les recharges inutiles
  static List<CustomList>? _cachedLists;
  static DateTime? _lastCacheTime;
  static const Duration _cacheValidity = Duration(minutes: 5);
  
  /// Vérifie si le cache est encore valide
  static bool get isCacheValid {
    if (_cachedLists == null || _lastCacheTime == null) return false;
    return DateTime.now().difference(_lastCacheTime!) < _cacheValidity;
  }
  
  /// Met en cache les listes chargées
  static void cacheLists(List<CustomList> lists) {
    _cachedLists = List.unmodifiable(lists);
    _lastCacheTime = DateTime.now();
    
    print('🔄 Cache mis à jour: ${lists.length} listes');
  }
  
  /// Récupère les listes depuis le cache si valide
  static List<CustomList>? getCachedLists() {
    if (isCacheValid) {
      print('⚡ Utilisation du cache: ${_cachedLists!.length} listes');
      return _cachedLists;
    }
    return null;
  }
  
  /// Invalide le cache
  static void invalidateCache() {
    _cachedLists = null;
    _lastCacheTime = null;
    print('🗑️ Cache invalidé');
  }
  
  /// Détecte les incohérences de données
  static bool detectDataInconsistency({
    required int currentCount,
    required int expectedMinimum,
  }) {
    // Si on a moins de données que prévu, c'est probablement un problème
    if (currentCount == 0 && expectedMinimum > 0) {
      print('⚠️ Incohérence détectée: 0 listes mais $expectedMinimum attendues');
      return true;
    }
    
    return false;
  }
  
  /// Diagnostic pour identifier les problèmes de performance
  static Map<String, dynamic> getDiagnosticInfo() {
    return {
      'cache_valid': isCacheValid,
      'cached_lists_count': _cachedLists?.length ?? 0,
      'last_cache_time': _lastCacheTime?.toIso8601String(),
      'cache_age_minutes': _lastCacheTime != null 
          ? DateTime.now().difference(_lastCacheTime!).inMinutes
          : null,
    };
  }
}

/// Provider pour le service de cohérence des données
final dataConsistencyServiceProvider = Provider<DataConsistencyService>((ref) {
  return DataConsistencyService();
});