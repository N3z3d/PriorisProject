/// **COMPUTE COORDINATOR** - SOLID Replacement
///
/// **LOT 6** : Coordinateur de calculs qui remplace le Singleton ComputeService
/// **Architecture** : Coordinator Pattern + Dependency Injection + SRP
/// **Taille** : <200 lignes (contrainte CLAUDE.md respectée)

import 'dart:async';
import 'compute_executor_interface.dart';

/// Coordinateur pour les opérations de calcul intensif
///
/// **SRP** : Coordination uniquement - délègue aux services spécialisés
/// **DIP** : Dépend d'abstractions, pas d'implémentations
/// **OCP** : Extensible via injection de nouveaux services
class ComputeCoordinator {
  final IComputeExecutor _executor;
  final ICacheManager _cacheManager;
  final IQueueManager _queueManager;

  /// **Constructeur avec injection de dépendances** (remplace Singleton)
  ComputeCoordinator({
    required IComputeExecutor executor,
    required ICacheManager cacheManager,
    required IQueueManager queueManager,
  }) : _executor = executor,
       _cacheManager = cacheManager,
       _queueManager = queueManager;

  /// Exécute un calcul avec cache et gestion de file d'attente
  Future<T> executeCompute<T, P>({
    required T Function(P) callback,
    required P parameter,
    String? cacheKey,
    bool useCache = true,
  }) async {
    // Vérifier le cache
    if (useCache && cacheKey != null) {
      final cached = await _cacheManager.get<T>(cacheKey);
      if (cached != null) return cached;
    }

    // Ajouter à la file d'attente et exécuter
    final result = await _queueManager.enqueue(() async {
      return await _executor.execute<T, P>(callback, parameter);
    });

    // Mettre en cache le résultat
    if (useCache && cacheKey != null) {
      await _cacheManager.put(cacheKey, result);
    }

    return result;
  }

  /// Exécute plusieurs calculs en parallèle
  Future<List<T>> executeMany<T, P>({
    required T Function(P) callback,
    required List<P> parameters,
    String? cacheKeyPrefix,
    bool useCache = true,
  }) async {
    final futures = parameters.asMap().entries.map((entry) {
      final index = entry.key;
      final param = entry.value;
      final cacheKey = cacheKeyPrefix != null ? '${cacheKeyPrefix}_$index' : null;

      return executeCompute<T, P>(
        callback: callback,
        parameter: param,
        cacheKey: cacheKey,
        useCache: useCache,
      );
    });

    return await Future.wait(futures);
  }

  /// Obtient les statistiques de performance des calculs
  Future<Map<String, dynamic>> getComputeStats() async {
    final queueStats = await _queueManager.getStats();
    final cacheStats = await _cacheManager.getStats();
    final executorStats = await _executor.getStats();

    return {
      'queue': queueStats,
      'cache': cacheStats,
      'executor': executorStats,
      'coordinator': 'ComputeCoordinator',
    };
  }

  /// Nettoie les ressources
  Future<void> dispose() async {
    await _cacheManager.dispose();
    await _queueManager.dispose();
    await _executor.dispose();
  }
}