/// **SIMPLE PERSISTENCE TEST** - Validation LOT 3.1
///
/// **Test minimaliste** : Vérifier que les nouveaux services compilent
/// **Architecture** : Test de compilation uniquement

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';
import 'package:prioris/domain/services/persistence/interfaces/unified_persistence_interface.dart';
import 'package:prioris/domain/services/persistence/services/local_persistence_service.dart';
import 'package:prioris/domain/services/persistence/services/cloud_persistence_service.dart';
import 'package:prioris/domain/services/persistence/services/sync_persistence_service.dart';
import 'package:prioris/domain/services/persistence/services/persistence_coordinator.dart';

/// === Mocks simples ===
class MockCustomListRepository extends Mock implements CustomListRepository {}
class MockListItemRepository extends Mock implements ListItemRepository {}
class MockLogger extends Mock implements ILogger {}

class SimpleValidator implements IPersistenceValidator {
  @override
  bool validateList(list) => true;

  @override
  bool validateListItem(item) => true;

  @override
  List<CustomList> sanitizeLists(List<CustomList> lists) => lists;

  @override
  List<ListItem> sanitizeItems(List<ListItem> items) => items;
}

class SimpleConfiguration implements IPersistenceConfiguration {
  @override
  PersistenceMode get defaultMode => PersistenceMode.localFirst;

  @override
  MigrationStrategy get defaultMigrationStrategy => MigrationStrategy.intelligentMerge;

  @override
  bool get enableBackgroundSync => true;

  @override
  bool get enableDeduplication => true;

  @override
  Duration get syncTimeout => const Duration(seconds: 30);

  @override
  int get maxRetries => 3;

  @override
  Map<String, dynamic> toMap() => {
    'defaultMode': 'localFirst',
    'enableBackgroundSync': true,
  };
}

void main() {
  group('Simple Persistence Services Compilation Test', () {
    late MockCustomListRepository mockLocalRepository;
    late MockCustomListRepository mockCloudRepository;
    late MockListItemRepository mockLocalItemRepository;
    late MockListItemRepository mockCloudItemRepository;
    late MockLogger mockLogger;
    late SimpleValidator validator;
    late SimpleConfiguration configuration;

    setUp(() {
      mockLocalRepository = MockCustomListRepository();
      mockCloudRepository = MockCustomListRepository();
      mockLocalItemRepository = MockListItemRepository();
      mockCloudItemRepository = MockListItemRepository();
      mockLogger = MockLogger();
      validator = SimpleValidator();
      configuration = SimpleConfiguration();
    });

    test('LocalPersistenceService compile correctly', () {
      // Act
      final service = LocalPersistenceService(
        localRepository: mockLocalRepository,
        localItemRepository: mockLocalItemRepository,
        validator: validator,
        logger: mockLogger,
      );

      // Assert
      expect(service, isNotNull);
      expect(service, isA<LocalPersistenceService>());
    });

    test('CloudPersistenceService compile correctly', () {
      // Arrange
      final localService = LocalPersistenceService(
        localRepository: mockLocalRepository,
        localItemRepository: mockLocalItemRepository,
        validator: validator,
        logger: mockLogger,
      );

      // Act
      final service = CloudPersistenceService(
        cloudRepository: mockCloudRepository,
        cloudItemRepository: mockCloudItemRepository,
        localService: localService,
        validator: validator,
        logger: mockLogger,
        isAuthenticated: true,
      );

      // Assert
      expect(service, isNotNull);
      expect(service, isA<CloudPersistenceService>());
      expect(service.isCloudAvailable, isTrue);
    });

    test('SyncPersistenceService compile correctly', () {
      // Arrange
      final localService = LocalPersistenceService(
        localRepository: mockLocalRepository,
        localItemRepository: mockLocalItemRepository,
        validator: validator,
        logger: mockLogger,
      );

      final cloudService = CloudPersistenceService(
        cloudRepository: mockCloudRepository,
        cloudItemRepository: mockCloudItemRepository,
        localService: localService,
        validator: validator,
        logger: mockLogger,
        isAuthenticated: true,
      );

      // Act
      final service = SyncPersistenceService(
        localService: localService,
        cloudService: cloudService,
        logger: mockLogger,
      );

      // Assert
      expect(service, isNotNull);
      expect(service, isA<SyncPersistenceService>());
      expect(service.isSyncing, isFalse);
    });

    test('PersistenceCoordinator compile and initialize correctly', () async {
      // Arrange
      final localService = LocalPersistenceService(
        localRepository: mockLocalRepository,
        localItemRepository: mockLocalItemRepository,
        validator: validator,
        logger: mockLogger,
      );

      final cloudService = CloudPersistenceService(
        cloudRepository: mockCloudRepository,
        cloudItemRepository: mockCloudItemRepository,
        localService: localService,
        validator: validator,
        logger: mockLogger,
        isAuthenticated: false,
      );

      final syncService = SyncPersistenceService(
        localService: localService,
        cloudService: cloudService,
        logger: mockLogger,
      );

      // Act
      final coordinator = PersistenceCoordinator(
        localService: localService,
        cloudService: cloudService,
        syncService: syncService,
        configuration: configuration,
        logger: mockLogger,
      );

      await coordinator.initialize(isAuthenticated: false);

      // Assert
      expect(coordinator, isNotNull);
      expect(coordinator, isA<PersistenceCoordinator>());
      expect(coordinator.currentMode, equals(PersistenceMode.localFirst));
      expect(coordinator.isAuthenticated, isFalse);
    });

    test('Coordinator can provide statistics', () async {
      // Arrange & setup comme test précédent
      final localService = LocalPersistenceService(
        localRepository: mockLocalRepository,
        localItemRepository: mockLocalItemRepository,
        validator: validator,
        logger: mockLogger,
      );

      final cloudService = CloudPersistenceService(
        cloudRepository: mockCloudRepository,
        cloudItemRepository: mockCloudItemRepository,
        localService: localService,
        validator: validator,
        logger: mockLogger,
        isAuthenticated: false,
      );

      final syncService = SyncPersistenceService(
        localService: localService,
        cloudService: cloudService,
        logger: mockLogger,
      );

      final coordinator = PersistenceCoordinator(
        localService: localService,
        cloudService: cloudService,
        syncService: syncService,
        configuration: configuration,
        logger: mockLogger,
      );

      await coordinator.initialize(isAuthenticated: false);

      // Act
      final stats = coordinator.getPersistenceStats();

      // Assert
      expect(stats, isA<Map<String, dynamic>>());
      expect(stats['service'], equals('PersistenceCoordinator'));
      expect(stats['version'], equals('2.0.0'));
      expect(stats['currentMode'], equals('localFirst'));
      expect(stats['isAuthenticated'], isFalse);
      expect(stats['initialized'], isTrue);
    });
  });
}