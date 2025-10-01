/// **OPTIMIZED PERSISTENCE COORDINATOR** - SOLID Replacement
///
/// **LOT 6** : Coordinateur de persistance optimisée
/// **Architecture** : Coordinator Pattern + SRP + DIP
/// **Taille** : <200 lignes (contrainte CLAUDE.md respectée)

import 'dart:async';
import '../../persistence/adaptive_persistence_service.dart';

/// Coordinateur pour la persistance optimisée
///
/// **SRP** : Coordination persistance optimisée uniquement
/// **DIP** : Dépend d'abstractions pour cache et optimisations
/// **Simplification** : Logique simplifiée, optimisations déléguées
class OptimizedPersistenceCoordinator extends AdaptivePersistenceService {
  final IPerformanceCache _cache;
  final IOptimizationStrategy _optimizer;

  /// **Constructeur avec injection de dépendances**
  OptimizedPersistenceCoordinator({
    required IPerformanceCache cache,
    required IOptimizationStrategy optimizer,
  }) : _cache = cache,
       _optimizer = optimizer;

  /// Sauvegarde optimisée avec cache
  @override
  Future<void> saveOptimized(String key, dynamic data) async {
    // Optimiser la stratégie de sauvegarde
    final strategy = await _optimizer.getStrategy(key, data);

    // Sauvegarder avec cache
    await _cache.put(key, data);

    // Persister selon la stratégie optimisée
    await strategy.execute();
  }

  /// Lecture optimisée avec cache
  @override
  Future<T?> loadOptimized<T>(String key) async {
    // Vérifier le cache d'abord
    final cached = await _cache.get<T>(key);
    if (cached != null) return cached;

    // Charger depuis la persistance
    final data = await super.loadOptimized<T>(key);

    // Mettre en cache pour accès futurs
    if (data != null) {
      await _cache.put(key, data);
    }

    return data;
  }

  /// Nettoyage des ressources
  @override
  Future<void> dispose() async {
    await _cache.dispose();
    await _optimizer.dispose();
    await super.dispose();
  }
}

/// **Interfaces pour services spécialisés** (DIP)
abstract class IPerformanceCache {
  Future<T?> get<T>(String key);
  Future<void> put<T>(String key, T value);
  Future<void> dispose();
}

abstract class IOptimizationStrategy {
  Future<IExecutionStrategy> getStrategy(String key, dynamic data);
  Future<void> dispose();
}

abstract class IExecutionStrategy {
  Future<void> execute();
}