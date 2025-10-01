/// **REFACTORED PERSISTENCE SERVICES TESTS** - Validation LOT 3.1
///
/// **Test simple** : Vérifier que la décomposition SOLID fonctionne
/// **Architecture** : Nouveaux services refactorisés

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';
import 'package:prioris/domain/services/persistence/interfaces/unified_persistence_interface.dart';
import 'package:prioris/domain/services/persistence/services/local_persistence_service.dart';
import 'package:prioris/domain/services/persistence/services/cloud_persistence_service.dart';
import 'package:prioris/domain/services/persistence/services/sync_persistence_service.dart';
import 'package:prioris/domain/services/persistence/services/persistence_coordinator.dart';

/// === Mocks pour les tests ===
class MockCustomListRepository extends Mock implements CustomListRepository {}
class MockListItemRepository extends Mock implements ListItemRepository {}
class MockLogger extends Mock implements ILogger {}
class MockValidator extends Mock implements IPersistenceValidator {}
class MockConfiguration extends Mock implements IPersistenceConfiguration {}

void main() {
  group('Refactored Persistence Services - LOT 3.1', () {
    late MockCustomListRepository mockLocalRepository;
    late MockCustomListRepository mockCloudRepository;
    late MockListItemRepository mockLocalItemRepository;
    late MockListItemRepository mockCloudItemRepository;
    late MockLogger mockLogger;
    late MockValidator mockValidator;
    late MockConfiguration mockConfiguration;

    setUp(() {
      mockLocalRepository = MockCustomListRepository();
      mockCloudRepository = MockCustomListRepository();
      mockLocalItemRepository = MockListItemRepository();
      mockCloudItemRepository = MockListItemRepository();
      mockLogger = MockLogger();
      mockValidator = MockValidator();
      mockConfiguration = MockConfiguration();

      // Configuration par défaut
      when(mockConfiguration.defaultMode).thenReturn(PersistenceMode.localFirst);
      when(mockConfiguration.defaultMigrationStrategy).thenReturn(MigrationStrategy.intelligentMerge);
      when(mockConfiguration.enableBackgroundSync).thenReturn(true);
      when(mockConfiguration.enableDeduplication).thenReturn(true);
      when(mockConfiguration.toMap()).thenReturn({
        'defaultMode': 'localFirst',
        'enableBackgroundSync': true,
      });

      // Validator par défaut
      when(mockValidator.validateList(any)).thenReturn(true);
      when(mockValidator.validateListItem(any)).thenReturn(true);
      when(mockValidator.sanitizeLists(any)).thenAnswer((invocation) => invocation.positionalArguments[0]);
      when(mockValidator.sanitizeItems(any)).thenAnswer((invocation) => invocation.positionalArguments[0]);
    });

    test('LocalPersistenceService peut être instancié', () {
      // Act
      final service = LocalPersistenceService(
        localRepository: mockLocalRepository,
        localItemRepository: mockLocalItemRepository,
        validator: mockValidator,
        logger: mockLogger,
      );

      // Assert
      expect(service, isNotNull);
      expect(service, isA<LocalPersistenceService>());
    });

    test('CloudPersistenceService peut être instancié', () {
      // Arrange
      final localService = LocalPersistenceService(
        localRepository: mockLocalRepository,
        localItemRepository: mockLocalItemRepository,
        validator: mockValidator,
        logger: mockLogger,
      );

      // Act
      final service = CloudPersistenceService(
        cloudRepository: mockCloudRepository,
        cloudItemRepository: mockCloudItemRepository,
        localService: localService,
        validator: mockValidator,
        logger: mockLogger,
        isAuthenticated: true,
      );

      // Assert
      expect(service, isNotNull);
      expect(service, isA<CloudPersistenceService>());
      expect(service.isCloudAvailable, isTrue);
    });

    test('SyncPersistenceService peut être instancié', () {
      // Arrange
      final localService = LocalPersistenceService(
        localRepository: mockLocalRepository,
        localItemRepository: mockLocalItemRepository,
        validator: mockValidator,
        logger: mockLogger,
      );

      final cloudService = CloudPersistenceService(
        cloudRepository: mockCloudRepository,
        cloudItemRepository: mockCloudItemRepository,
        localService: localService,
        validator: mockValidator,
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

    test('PersistenceCoordinator peut être instancié et initialisé', () async {
      // Arrange
      final localService = LocalPersistenceService(
        localRepository: mockLocalRepository,
        localItemRepository: mockLocalItemRepository,
        validator: mockValidator,
        logger: mockLogger,
      );

      final cloudService = CloudPersistenceService(
        cloudRepository: mockCloudRepository,
        cloudItemRepository: mockCloudItemRepository,
        localService: localService,
        validator: mockValidator,
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
        configuration: mockConfiguration,
        logger: mockLogger,
      );

      await coordinator.initialize(isAuthenticated: false);

      // Assert
      expect(coordinator, isNotNull);
      expect(coordinator, isA<PersistenceCoordinator>());
      expect(coordinator.currentMode, equals(PersistenceMode.localFirst));
      expect(coordinator.isAuthenticated, isFalse);
    });

    test('Architecture complète peut traiter une liste', () async {
      // Arrange
      final testList = CustomList(
        id: 'test-1',
        name: 'Test List',
        type: ListType.CUSTOM,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockLocalRepository.getAllLists()).thenAnswer((_) async => [testList]);

      final localService = LocalPersistenceService(
        localRepository: mockLocalRepository,
        localItemRepository: mockLocalItemRepository,
        validator: mockValidator,
        logger: mockLogger,
      );

      final cloudService = CloudPersistenceService(
        cloudRepository: mockCloudRepository,
        cloudItemRepository: mockCloudItemRepository,
        localService: localService,
        validator: mockValidator,
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
        configuration: mockConfiguration,
        logger: mockLogger,
      );

      await coordinator.initialize(isAuthenticated: false);

      // Act
      final result = await coordinator.getAllLists();

      // Assert
      expect(result, hasLength(1));
      expect(result.first.name, equals('Test List'));
      verify(mockLocalRepository.getAllLists()).called(1);
    });

    test('Statistiques du coordinateur sont disponibles', () async {
      // Arrange & setup comme test précédent
      final localService = LocalPersistenceService(
        localRepository: mockLocalRepository,
        localItemRepository: mockLocalItemRepository,
        validator: mockValidator,
        logger: mockLogger,
      );

      final cloudService = CloudPersistenceService(
        cloudRepository: mockCloudRepository,
        cloudItemRepository: mockCloudItemRepository,
        localService: localService,
        validator: mockValidator,
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
        configuration: mockConfiguration,
        logger: mockLogger,
      );

      await coordinator.initialize(isAuthenticated: false);

      // Act
      final stats = coordinator.getPersistenceStats();

      // Assert
      expect(stats, isA<Map<String, dynamic>>());
      expect(stats, containsPair('service', 'PersistenceCoordinator'));
      expect(stats, containsPair('version', '2.0.0'));
      expect(stats, containsPair('currentMode', 'localFirst'));
      expect(stats, containsPair('isAuthenticated', false));
      expect(stats, containsPair('initialized', true));
    });
  });
}