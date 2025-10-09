/// **UNIFIED PERSISTENCE SERVICE TESTS** - Tests Complets
///
/// Tests pour le service de persistance unifi+® qui remplace 36 services dupliqu+®s
/// V+®rifie le respect des principes SOLID et la fonctionnalit+® compl+¿te

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';
import 'package:prioris/domain/services/persistence/interfaces/unified_persistence_interface.dart';
import 'package:prioris/domain/services/persistence/unified_persistence_service.dart';
import 'package:prioris/domain/services/persistence/unified_persistence_factory.dart';

/// === Mocks pour les tests ===
class MockCustomListRepository extends Mock implements CustomListRepository {}
class MockListItemRepository extends Mock implements ListItemRepository {}
class MockLogger extends Mock implements ILogger {}

/// === Test Data Factories ===
class TestDataFactory {
  static CustomList createTestList({
    String? id,
    String? name,
    ListType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ListItem>? items,
  }) {
    return CustomList(
      id: id ?? 'test-list-1',
      name: name ?? 'Test List',
      type: type ?? ListType.CUSTOM,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      items: items ?? [],
    );
  }

  static ListItem createTestItem({
    String? id,
    String? title,
    String? listId,
    DateTime? createdAt,
    bool? isCompleted,
  }) {
    return ListItem(
      id: id ?? 'test-item-1',
      title: title ?? 'Test Item',
      listId: listId ?? 'test-list-1',
      createdAt: createdAt ?? DateTime.now(),
      isCompleted: isCompleted ?? false,
    );
  }
}

void main() {
  group('UnifiedPersistenceService Tests', () {
    late IUnifiedPersistenceService service;
    late MockCustomListRepository mockLocalRepository;
    late MockCustomListRepository mockCloudRepository;
    late MockListItemRepository mockLocalItemRepository;
    late MockListItemRepository mockCloudItemRepository;
    late MockLogger mockLogger;

    setUp(() {
      mockLocalRepository = MockCustomListRepository();
      mockCloudRepository = MockCustomListRepository();
      mockLocalItemRepository = MockListItemRepository();
      mockCloudItemRepository = MockListItemRepository();
      mockLogger = MockLogger();

      service = UnifiedPersistenceService(
        localRepository: mockLocalRepository,
        cloudRepository: mockCloudRepository,
        localItemRepository: mockLocalItemRepository,
        cloudItemRepository: mockCloudItemRepository,
        logger: mockLogger,
        configuration: const UnifiedPersistenceConfiguration(
          enableDeduplication: true,
          enableBackgroundSync: false, // D+®sactiv+® pour les tests
        ),
      );
    });

    group('Lifecycle Management', () {
      test('initialise correctement en mode local pour utilisateur invit+®', () async {
        // Act
        await service.initialize(isAuthenticated: false);

        // Assert
        expect(service.currentMode, equals(PersistenceMode.localFirst));
        expect(service.isAuthenticated, isFalse);
        verify(mockLogger.info(argThat(contains('Initialisation')), context: anyNamed('context')));
      });

      test('initialise correctement en mode cloud pour utilisateur connect+®', () async {
        // Act
        await service.initialize(isAuthenticated: true);

        // Assert
        expect(service.currentMode, equals(PersistenceMode.cloudFirst));
        expect(service.isAuthenticated, isTrue);
        verify(mockLogger.info(argThat(contains('Initialisation')), context: anyNamed('context')));
      });

      test('lance une exception si d+®j+á initialis+®', () async {
        // Arrange
        await service.initialize(isAuthenticated: false);

        // Act & Assert
        expect(
          () => service.initialize(isAuthenticated: true),
          throwsA(isA<UnifiedPersistenceException>().having(
            (e) => e.message,
            'message',
            contains('d+®j+á initialis+®'),
          )),
        );
      });

      test('lance une exception si utilis+® sans initialisation', () async {
        // Act & Assert
        expect(
          () => service.getAllLists(),
          throwsA(isA<UnifiedPersistenceException>().having(
            (e) => e.message,
            'message',
            contains('non initialis+®'),
          )),
        );
      });
    });

    group('Authentication State Changes', () {
      setUp(() async {
        await service.initialize(isAuthenticated: false);
      });

      test('g+¿re la transition Invit+® ÔåÆ Connect+®', () async {
        // Arrange
        final localLists = [TestDataFactory.createTestList()];
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => localLists);

        // Act
        await service.updateAuthenticationState(
          isAuthenticated: true,
          migrationStrategy: MigrationStrategy.intelligentMerge,
        );

        // Assert
        expect(service.currentMode, equals(PersistenceMode.cloudFirst));
        expect(service.isAuthenticated, isTrue);
        verify(mockLogger.info(argThat(contains('Changement d\'authentification')), context: anyNamed('context')));
      });

      test('g+¿re la transition Connect+® ÔåÆ Invit+®', () async {
        // Arrange
        await service.updateAuthenticationState(isAuthenticated: true);
        final cloudLists = [TestDataFactory.createTestList()];
        when(mockCloudRepository.getAllLists()).thenAnswer((_) async => cloudLists);

        // Act
        await service.updateAuthenticationState(isAuthenticated: false);

        // Assert
        expect(service.currentMode, equals(PersistenceMode.localFirst));
        expect(service.isAuthenticated, isFalse);
      });
    });

    group('List Operations - Local Mode', () {
      setUp(() async {
        await service.initialize(isAuthenticated: false);
      });

      test('r+®cup+¿re toutes les listes en mode local', () async {
        // Arrange
        final testLists = [
          TestDataFactory.createTestList(id: '1', name: 'List 1'),
          TestDataFactory.createTestList(id: '2', name: 'List 2'),
        ];
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => testLists);

        // Act
        final result = await service.getAllLists();

        // Assert
        expect(result, hasLength(2));
        expect(result.first.name, equals('List 1'));
        verify(mockLocalRepository.getAllLists()).called(1);
      });

      test('sauvegarde une liste en mode local', () async {
        // Arrange
        final testList = TestDataFactory.createTestList();
        when(mockLocalRepository.saveList(testList)).thenAnswer((_) async {});

        // Act
        await service.saveList(testList);

        // Assert
        verify(mockLocalRepository.saveList(testList)).called(1);
        verify(mockLogger.info(argThat(contains('sauvegard+®e')), context: anyNamed('context')));
      });

      test('g+¿re les conflits de d+®duplication lors de la sauvegarde', () async {
        // Arrange
        final testList = TestDataFactory.createTestList();
        final existingList = TestDataFactory.createTestList(
          updatedAt: DateTime.now().add(const Duration(hours: 1)),
        );

        when(mockLocalRepository.saveList(testList))
            .thenThrow(Exception('Une liste avec cet ID existe d+®j+á'));
        when(mockLocalRepository.getListById(testList.id))
            .thenAnswer((_) async => existingList);
        when(mockLocalRepository.updateList(existingList))
            .thenAnswer((_) async {});

        // Act
        await service.saveList(testList);

        // Assert
        verify(mockLocalRepository.saveList(testList)).called(1);
        verify(mockLocalRepository.getListById(testList.id)).called(1);
        verify(mockLocalRepository.updateList(existingList)).called(1);
      });

      test('met +á jour une liste en mode local', () async {
        // Arrange
        final testList = TestDataFactory.createTestList();
        when(mockLocalRepository.updateList(testList)).thenAnswer((_) async {});

        // Act
        await service.updateList(testList);

        // Assert
        verify(mockLocalRepository.updateList(testList)).called(1);
      });

      test('supprime une liste en mode local', () async {
        // Arrange
        const listId = 'test-list-1';
        when(mockLocalRepository.deleteList(listId)).thenAnswer((_) async {});

        // Act
        await service.deleteList(listId);

        // Assert
        verify(mockLocalRepository.deleteList(listId)).called(1);
      });

      test('lance une exception pour liste invalide', () async {
        // Arrange
        final invalidList = TestDataFactory.createTestList(name: ''); // Nom vide

        // Act & Assert
        expect(
          () => service.saveList(invalidList),
          throwsA(isA<UnifiedPersistenceException>().having(
            (e) => e.message,
            'message',
            contains('invalide'),
          )),
        );
      });
    });

    group('Item Operations - Local Mode', () {
      setUp(() async {
        await service.initialize(isAuthenticated: false);
      });

      test('r+®cup+¿re les items d\'une liste', () async {
        // Arrange
        const listId = 'test-list-1';
        final testItems = [
          TestDataFactory.createTestItem(id: '1', title: 'Item 1'),
          TestDataFactory.createTestItem(id: '2', title: 'Item 2'),
        ];
        when(mockLocalItemRepository.getByListId(listId))
            .thenAnswer((_) async => testItems);

        // Act
        final result = await service.getItemsByListId(listId);

        // Assert
        expect(result, hasLength(2));
        expect(result.first.title, equals('Item 1'));
        verify(mockLocalItemRepository.getByListId(listId)).called(1);
      });

      test('sauvegarde un item en mode local', () async {
        // Arrange
        final testItem = TestDataFactory.createTestItem();
        when(mockLocalItemRepository.add(testItem)).thenAnswer((_) async {});

        // Act
        await service.saveItem(testItem);

        // Assert
        verify(mockLocalItemRepository.add(testItem)).called(1);
      });

      test('g+¿re les conflits de d+®duplication pour items', () async {
        // Arrange
        final testItem = TestDataFactory.createTestItem();
        final existingItem = TestDataFactory.createTestItem(
          createdAt: DateTime.now().add(const Duration(hours: 1)),
        );

        when(mockLocalItemRepository.add(testItem))
            .thenThrow(Exception('Un item avec cet id existe d+®j+á'));
        when(mockLocalItemRepository.getById(testItem.id))
            .thenAnswer((_) async => existingItem);
        when(mockLocalItemRepository.update(existingItem))
            .thenAnswer((_) async {});

        // Act
        await service.saveItem(testItem);

        // Assert
        verify(mockLocalItemRepository.add(testItem)).called(1);
        verify(mockLocalItemRepository.getById(testItem.id)).called(1);
        verify(mockLocalItemRepository.update(existingItem)).called(1);
      });

      test('met +á jour un item', () async {
        // Arrange
        final testItem = TestDataFactory.createTestItem();
        when(mockLocalItemRepository.update(testItem)).thenAnswer((_) async {});

        // Act
        await service.updateItem(testItem);

        // Assert
        verify(mockLocalItemRepository.update(testItem)).called(1);
      });

      test('supprime un item', () async {
        // Arrange
        const itemId = 'test-item-1';
        when(mockLocalItemRepository.delete(itemId)).thenAnswer((_) async {});

        // Act
        await service.deleteItem(itemId);

        // Assert
        verify(mockLocalItemRepository.delete(itemId)).called(1);
      });

      test('lance une exception pour item invalide', () async {
        // Arrange
        final invalidItem = TestDataFactory.createTestItem(title: ''); // Titre vide

        // Act & Assert
        expect(
          () => service.saveItem(invalidItem),
          throwsA(isA<UnifiedPersistenceException>().having(
            (e) => e.message,
            'message',
            contains('invalide'),
          )),
        );
      });
    });

    group('Cloud Mode Operations', () {
      setUp(() async {
        await service.initialize(isAuthenticated: true);
      });

      test('r+®cup+¿re les listes en mode cloud avec fallback', () async {
        // Arrange
        final cloudLists = [TestDataFactory.createTestList()];
        when(mockCloudRepository.getAllLists()).thenAnswer((_) async => cloudLists);

        // Act
        final result = await service.getAllLists();

        // Assert
        expect(result, hasLength(1));
        verify(mockCloudRepository.getAllLists()).called(1);
      });

      test('utilise le fallback local si cloud indisponible', () async {
        // Arrange
        final localLists = [TestDataFactory.createTestList()];
        when(mockCloudRepository.getAllLists()).thenThrow(Exception('Cloud indisponible'));
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => localLists);

        // Act
        final result = await service.getAllLists();

        // Assert
        expect(result, hasLength(1));
        verify(mockCloudRepository.getAllLists()).called(1);
        verify(mockLocalRepository.getAllLists()).called(1);
      });

      test('sauvegarde en local puis cloud en mode cloudFirst', () async {
        // Arrange
        final testList = TestDataFactory.createTestList();
        when(mockLocalRepository.saveList(testList)).thenAnswer((_) async {});

        // Act
        await service.saveList(testList);

        // Assert
        verify(mockLocalRepository.saveList(testList)).called(1);
        // Note: Cloud sync est asynchrone et ne sera pas v+®rifi+® dans les tests
      });
    });

    group('Bulk Operations', () {
      setUp(() async {
        await service.initialize(isAuthenticated: false);
      });

      test('sauvegarde plusieurs items avec succ+¿s', () async {
        // Arrange
        final items = [
          TestDataFactory.createTestItem(id: '1', title: 'Item 1'),
          TestDataFactory.createTestItem(id: '2', title: 'Item 2'),
          TestDataFactory.createTestItem(id: '3', title: 'Item 3'),
        ];

        for (final item in items) {
          when(mockLocalItemRepository.add(item)).thenAnswer((_) async {});
        }

        // Act
        await service.saveMultipleItems(items);

        // Assert
        for (final item in items) {
          verify(mockLocalItemRepository.add(item)).called(1);
        }
      });

      test('effectue un rollback en cas d\'+®chec partiel lors de bulk save', () async {
        // Arrange
        final items = [
          TestDataFactory.createTestItem(id: '1', title: 'Item 1'),
          TestDataFactory.createTestItem(id: '2', title: 'Item 2'),
        ];

        when(mockLocalItemRepository.add(items[0])).thenAnswer((_) async {});
        when(mockLocalItemRepository.add(items[1])).thenThrow(Exception('+ëchec sauvegarde'));
        when(mockLocalItemRepository.delete(items[0].id)).thenAnswer((_) async {});

        // Act & Assert
        expect(
          () => service.saveMultipleItems(items),
          throwsA(isA<UnifiedPersistenceException>().having(
            (e) => e.message,
            'message',
            contains('rollback'),
          )),
        );

        verify(mockLocalItemRepository.delete(items[0].id)).called(1);
      });

      test('clearAllData supprime toutes les listes et items', () async {
        // Arrange
        final testLists = [TestDataFactory.createTestList()];
        final testItems = [TestDataFactory.createTestItem()];

        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => testLists);
        when(mockLocalItemRepository.getByListId(testLists.first.id))
            .thenAnswer((_) async => testItems);
        when(mockLocalItemRepository.delete(testItems.first.id)).thenAnswer((_) async {});
        when(mockLocalRepository.deleteList(testLists.first.id)).thenAnswer((_) async {});

        // Act
        await service.clearAllData();

        // Assert
        verify(mockLocalItemRepository.delete(testItems.first.id)).called(1);
        verify(mockLocalRepository.deleteList(testLists.first.id)).called(1);
      });
    });

    group('Validation', () {
      setUp(() async {
        await service.initialize(isAuthenticated: false);
      });

      test('v+®rifie la persistance d\'une liste avec succ+¿s', () async {
        // Arrange
        const listId = 'test-list-1';
        final testList = TestDataFactory.createTestList(id: listId);
        when(mockLocalRepository.getListById(listId)).thenAnswer((_) async => testList);

        // Act
        await service.verifyListPersistence(listId);

        // Assert
        verify(mockLocalRepository.getListById(listId)).called(1);
        verify(mockLogger.debug(argThat(contains('V+®rification r+®ussie')), context: anyNamed('context')));
      });

      test('lance une exception si liste non trouv+®e apr+¿s sauvegarde', () async {
        // Arrange
        const listId = 'test-list-1';
        when(mockLocalRepository.getListById(listId)).thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => service.verifyListPersistence(listId),
          throwsA(isA<UnifiedPersistenceException>().having(
            (e) => e.message,
            'message',
            contains('non trouv+®e apr+¿s sauvegarde'),
          )),
        );
      });

      test('v+®rifie la persistance d\'un item avec succ+¿s', () async {
        // Arrange
        const itemId = 'test-item-1';
        final testItem = TestDataFactory.createTestItem(id: itemId);
        when(mockLocalItemRepository.getById(itemId)).thenAnswer((_) async => testItem);

        // Act
        await service.verifyItemPersistence(itemId);

        // Assert
        verify(mockLocalItemRepository.getById(itemId)).called(1);
      });
    });

    group('Statistics and Monitoring', () {
      setUp(() async {
        await service.initialize(isAuthenticated: false);
      });

      test('retourne des statistiques compl+¿tes', () {
        // Act
        final stats = service.getPersistenceStats();

        // Assert
        expect(stats, containsPair('currentMode', 'localFirst'));
        expect(stats, containsPair('isAuthenticated', false));
        expect(stats, containsPair('initialized', true));
        expect(stats, containsPair('service', 'UnifiedPersistenceService'));
        expect(stats, containsPair('version', '1.0.0'));
        expect(stats, contains('configuration'));
      });

      test('indique l\'+®tat de synchronisation', () {
        // Assert
        expect(service.isSyncing, isFalse);
      });
    });
  });

  group('UnifiedPersistenceServiceFactory Tests', () {
    late UnifiedPersistenceServiceFactory factory;
    late MockCustomListRepository mockLocalRepository;
    late MockCustomListRepository mockCloudRepository;
    late MockListItemRepository mockLocalItemRepository;
    late MockListItemRepository mockCloudItemRepository;
    late MockLogger mockLogger;

    setUp(() {
      mockLocalRepository = MockCustomListRepository();
      mockCloudRepository = MockCustomListRepository();
      mockLocalItemRepository = MockListItemRepository();
      mockCloudItemRepository = MockListItemRepository();
      mockLogger = MockLogger();

      factory = UnifiedPersistenceServiceFactory(
        localRepository: mockLocalRepository,
        cloudRepository: mockCloudRepository,
        localItemRepository: mockLocalItemRepository,
        cloudItemRepository: mockCloudItemRepository,
      );
    });

    test('cr+®e un service avec configuration par d+®faut', () {
      // Act
      final service = factory.createDefault(logger: mockLogger);

      // Assert
      expect(service, isA<IUnifiedPersistenceService>());
      verify(mockLogger.info(argThat(contains('Cr+®ation')), context: anyNamed('context')));
    });

    test('cr+®e un service en mode local uniquement', () {
      // Act
      final service = factory.createLocalOnly(logger: mockLogger);

      // Assert
      expect(service, isA<IUnifiedPersistenceService>());
    });

    test('cr+®e un service en mode cloud prioritaire', () {
      // Act
      final service = factory.createCloudFirst(logger: mockLogger);

      // Assert
      expect(service, isA<IUnifiedPersistenceService>());
    });

    test('cr+®e un service en mode hybride', () {
      // Act
      final service = factory.createHybrid(logger: mockLogger);

      // Assert
      expect(service, isA<IUnifiedPersistenceService>());
    });

    test('retourne des statistiques de factory', () {
      // Act
      final stats = factory.getFactoryStats();

      // Assert
      expect(stats, containsPair('factoryType', 'UnifiedPersistenceServiceFactory'));
      expect(stats, containsPair('version', '1.0.0'));
      expect(stats, contains('supportedModes'));
      expect(stats, contains('repositoriesConfigured'));
    });
  });

  group('Configuration Tests', () {
    test('UnifiedPersistenceConfiguration utilise les valeurs par d+®faut', () {
      // Act
      const config = UnifiedPersistenceConfiguration();

      // Assert
      expect(config.defaultMode, equals(PersistenceMode.localFirst));
      expect(config.defaultMigrationStrategy, equals(MigrationStrategy.intelligentMerge));
      expect(config.enableBackgroundSync, isTrue);
      expect(config.enableDeduplication, isTrue);
      expect(config.syncTimeout, equals(const Duration(seconds: 30)));
      expect(config.maxRetries, equals(3));
    });

    test('UnifiedPersistenceConfiguration peut +¬tre personnalis+®e', () {
      // Act
      const config = UnifiedPersistenceConfiguration(
        defaultMode: PersistenceMode.cloudFirst,
        enableBackgroundSync: false,
        maxRetries: 5,
      );

      // Assert
      expect(config.defaultMode, equals(PersistenceMode.cloudFirst));
      expect(config.enableBackgroundSync, isFalse);
      expect(config.maxRetries, equals(5));
    });

    test('Configuration se convertit en Map correctement', () {
      // Arrange
      const config = UnifiedPersistenceConfiguration();

      // Act
      final map = config.toMap();

      // Assert
      expect(map, containsPair('defaultMode', 'localFirst'));
      expect(map, containsPair('enableBackgroundSync', true));
      expect(map, containsPair('syncTimeoutSeconds', 30));
    });
  });

  group('Exception Tests', () {
    test('UnifiedPersistenceException contient toutes les informations', () {
      // Act
      const exception = UnifiedPersistenceException(
        'Test error',
        operation: 'saveList',
        id: 'test-id',
        mode: PersistenceMode.cloudFirst,
        cause: 'Original error',
      );

      // Assert
      expect(exception.message, equals('Test error'));
      expect(exception.operation, equals('saveList'));
      expect(exception.id, equals('test-id'));
      expect(exception.mode, equals(PersistenceMode.cloudFirst));
      expect(exception.cause, equals('Original error'));
    });

    test('UnifiedPersistenceException toString est informatif', () {
      // Act
      const exception = UnifiedPersistenceException(
        'Test error',
        operation: 'saveList',
        id: 'test-id',
        mode: PersistenceMode.cloudFirst,
      );

      // Assert
      final str = exception.toString();
      expect(str, contains('saveList'));
      expect(str, contains('test-id'));
      expect(str, contains('cloudFirst'));
      expect(str, contains('Test error'));
    });
  });
}
