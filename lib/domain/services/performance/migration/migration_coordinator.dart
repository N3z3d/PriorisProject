/// **MIGRATION COORDINATOR** - SOLID Replacement
///
/// **LOT 6** : Coordinateur de migration qui remplace OptimizedMigrationService
/// **Architecture** : Coordinator Pattern + SRP + DIP
/// **Taille** : <300 lignes (contrainte CLAUDE.md respectée)

import 'dart:async';
import '../../persistence/data_migration_service.dart';

/// Coordinateur pour les opérations de migration optimisées
///
/// **SRP** : Coordination migration uniquement
/// **DIP** : Dépend d'abstractions spécialisées
/// **Simplification** : Délègue les optimisations aux services spécialisés
class MigrationCoordinator extends DataMigrationService {
  final IWorkerPool _workerPool;
  final ICircuitBreaker _circuitBreaker;
  final IBatchOptimizer _batchOptimizer;

  /// **Constructeur avec injection de dépendances**
  MigrationCoordinator({
    required IWorkerPool workerPool,
    required ICircuitBreaker circuitBreaker,
    required IBatchOptimizer batchOptimizer,
  }) : _workerPool = workerPool,
       _circuitBreaker = circuitBreaker,
       _batchOptimizer = batchOptimizer;

  /// Migre les données avec optimisations coordonnées
  @override
  Future<Map<String, dynamic>> migrateData({
    required Map<String, dynamic> config,
  }) async {
    try {
      // Optimiser la configuration de batch
      final optimizedConfig = await _batchOptimizer.optimize(config);

      // Exécuter avec circuit breaker
      return await _circuitBreaker.execute(() async {
        return await _workerPool.execute(() async {
          return await _performMigration(optimizedConfig);
        });
      });
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Logique de migration simplifiée
  Future<Map<String, dynamic>> _performMigration(
    Map<String, dynamic> config,
  ) async {
    // Migration basique - les optimisations sont gérées par les services injectés
    return await super.migrateData(config: config);
  }
}

/// **Interfaces pour les services spécialisés** (DIP)
abstract class IWorkerPool {
  Future<T> execute<T>(Future<T> Function() task);
}

abstract class ICircuitBreaker {
  Future<T> execute<T>(Future<T> Function() operation);
}

abstract class IBatchOptimizer {
  Future<Map<String, dynamic>> optimize(Map<String, dynamic> config);
}