/// **UNIFIED PERSISTENCE FACTORY** - Factory Pattern Implementation
///
/// **SOLID Principles** :
/// - **SRP** : Responsabilité unique - créer des instances de persistance
/// - **OCP** : Extensible pour différentes implémentations
/// - **DIP** : Fournit l'abstraction via l'interface factory
///
/// **Factory Pattern** + **Dependency Injection** = Clean Architecture

import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';
import 'interfaces/unified_persistence_interface.dart';
import 'unified_persistence_service.dart';

/// **FACTORY CONCRÈTE** pour le service de persistance unifié
/// Implémente le Factory Pattern pour créer des instances configurées
class UnifiedPersistenceServiceFactory implements IPersistenceServiceFactory {
  // === Dependencies for factory ===
  final CustomListRepository _localRepository;
  final CustomListRepository _cloudRepository;
  final ListItemRepository _localItemRepository;
  final ListItemRepository _cloudItemRepository;

  /// **Dependency Injection Constructor**
  const UnifiedPersistenceServiceFactory({
    required CustomListRepository localRepository,
    required CustomListRepository cloudRepository,
    required ListItemRepository localItemRepository,
    required ListItemRepository cloudItemRepository,
  }) : _localRepository = localRepository,
       _cloudRepository = cloudRepository,
       _localItemRepository = localItemRepository,
       _cloudItemRepository = cloudItemRepository;

  @override
  IUnifiedPersistenceService createPersistenceService({
    required ILogger logger,
    IPersistenceConfiguration? configuration,
  }) {
    logger.info(
      'Création d\'une instance UnifiedPersistenceService',
      context: 'UnifiedPersistenceServiceFactory',
    );

    return UnifiedPersistenceService(
      localRepository: _localRepository,
      cloudRepository: _cloudRepository,
      localItemRepository: _localItemRepository,
      cloudItemRepository: _cloudItemRepository,
      logger: logger,
      configuration: configuration ?? const UnifiedPersistenceConfiguration(),
    );
  }

  /// **Factory Method** simplifié avec configuration par défaut
  IUnifiedPersistenceService createDefault({
    required ILogger logger,
  }) {
    return createPersistenceService(
      logger: logger,
      configuration: const UnifiedPersistenceConfiguration(),
    );
  }

  /// **Factory Method** pour mode local uniquement (tests/développement)
  IUnifiedPersistenceService createLocalOnly({
    required ILogger logger,
  }) {
    return createPersistenceService(
      logger: logger,
      configuration: const UnifiedPersistenceConfiguration(
        defaultMode: PersistenceMode.localFirst,
        enableBackgroundSync: false,
      ),
    );
  }

  /// **Factory Method** pour mode cloud prioritaire
  IUnifiedPersistenceService createCloudFirst({
    required ILogger logger,
  }) {
    return createPersistenceService(
      logger: logger,
      configuration: const UnifiedPersistenceConfiguration(
        defaultMode: PersistenceMode.cloudFirst,
        enableBackgroundSync: true,
        enableDeduplication: true,
      ),
    );
  }

  /// **Factory Method** pour mode hybride avancé
  IUnifiedPersistenceService createHybrid({
    required ILogger logger,
  }) {
    return createPersistenceService(
      logger: logger,
      configuration: const UnifiedPersistenceConfiguration(
        defaultMode: PersistenceMode.hybrid,
        enableBackgroundSync: true,
        enableDeduplication: true,
        syncTimeout: Duration(seconds: 45),
        maxRetries: 5,
      ),
    );
  }

  /// **Utility Method** - Obtient les statistiques de la factory
  Map<String, dynamic> getFactoryStats() {
    return {
      'factoryType': 'UnifiedPersistenceServiceFactory',
      'version': '1.0.0',
      'supportedModes': [
        PersistenceMode.localFirst.name,
        PersistenceMode.cloudFirst.name,
        PersistenceMode.hybrid.name,
      ],
      'repositoriesConfigured': {
        'localRepository': _localRepository.runtimeType.toString(),
        'cloudRepository': _cloudRepository.runtimeType.toString(),
        'localItemRepository': _localItemRepository.runtimeType.toString(),
        'cloudItemRepository': _cloudItemRepository.runtimeType.toString(),
      },
    };
  }
}

/// **FACTORY PROVIDER** pour l'injection de dépendance avec Riverpod/Provider
/// Simplifie l'utilisation dans l'architecture de l'app
class PersistenceFactoryProvider {
  static UnifiedPersistenceServiceFactory? _instance;

  /// **Singleton Pattern** pour la factory (optionnel)
  static UnifiedPersistenceServiceFactory getInstance({
    required CustomListRepository localRepository,
    required CustomListRepository cloudRepository,
    required ListItemRepository localItemRepository,
    required ListItemRepository cloudItemRepository,
  }) {
    _instance ??= UnifiedPersistenceServiceFactory(
      localRepository: localRepository,
      cloudRepository: cloudRepository,
      localItemRepository: localItemRepository,
      cloudItemRepository: cloudItemRepository,
    );
    return _instance!;
  }

  /// **Reset** pour les tests
  static void resetInstance() {
    _instance = null;
  }
}