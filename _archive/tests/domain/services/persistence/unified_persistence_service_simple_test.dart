/// **UNIFIED PERSISTENCE SERVICE SIMPLE TESTS**
/// Tests simplifiés pour vérifier le bon fonctionnement du service unifié

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

/// === Mocks pour les tests ===
class MockCustomListRepository extends Mock implements CustomListRepository {}
class MockListItemRepository extends Mock implements ListItemRepository {}
class MockLogger extends Mock implements ILogger {}

void main() {
  group('UnifiedPersistenceService Simple Tests', () {
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
          enableBackgroundSync: false,
        ),
      );
    });

    test('initialise correctement en mode local', () async {
      // Act
      await service.initialize(isAuthenticated: false);

      // Assert
      expect(service.currentMode, equals(PersistenceMode.localFirst));
      expect(service.isAuthenticated, isFalse);
    });

    test('initialise correctement en mode cloud', () async {
      // Act
      await service.initialize(isAuthenticated: true);

      // Assert
      expect(service.currentMode, equals(PersistenceMode.cloudFirst));
      expect(service.isAuthenticated, isTrue);
    });

    test('récupère des listes en mode local', () async {
      // Arrange
      await service.initialize(isAuthenticated: false);
      final testLists = [
        CustomList(
          id: '1',
          name: 'Test List',
          type: ListType.CUSTOM,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      when(mockLocalRepository.getAllLists()).thenAnswer((_) async => testLists);

      // Act
      final result = await service.getAllLists();

      // Assert
      expect(result, hasLength(1));
      expect(result.first.name, equals('Test List'));
      verify(mockLocalRepository.getAllLists()).called(1);
    });

    test('sauvegarde une liste en mode local', () async {
      // Arrange
      await service.initialize(isAuthenticated: false);
      final testList = CustomList(
        id: 'test-id',
        name: 'Test List',
        type: ListType.CUSTOM,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      when(mockLocalRepository.saveList(testList)).thenAnswer((_) async {});

      // Act
      await service.saveList(testList);

      // Assert
      verify(mockLocalRepository.saveList(testList)).called(1);
    });

    test('récupère les items d\'une liste', () async {
      // Arrange
      await service.initialize(isAuthenticated: false);
      const listId = 'test-list-1';
      final testItems = [
        ListItem(
          id: 'item1',
          title: 'Test Item',
          listId: listId,
          createdAt: DateTime.now(),
        ),
      ];
      when(mockLocalItemRepository.getByListId(listId)).thenAnswer((_) async => testItems);

      // Act
      final result = await service.getItemsByListId(listId);

      // Assert
      expect(result, hasLength(1));
      expect(result.first.title, equals('Test Item'));
      verify(mockLocalItemRepository.getByListId(listId)).called(1);
    });

    test('sauvegarde un item', () async {
      // Arrange
      await service.initialize(isAuthenticated: false);
      final testItem = ListItem(
        id: 'item-id',
        title: 'Test Item',
        listId: 'list-id',
        createdAt: DateTime.now(),
      );
      when(mockLocalItemRepository.add(testItem)).thenAnswer((_) async => testItem);

      // Act
      await service.saveItem(testItem);

      // Assert
      verify(mockLocalItemRepository.add(testItem)).called(1);
    });

    test('obtient des statistiques', () {
      // Act
      final stats = service.getPersistenceStats();

      // Assert
      expect(stats, isA<Map<String, dynamic>>());
      expect(stats, containsPair('service', 'UnifiedPersistenceService'));
      expect(stats, containsPair('version', '1.0.0'));
    });

    test('valide qu\'une liste invalide lance une exception', () async {
      // Arrange
      await service.initialize(isAuthenticated: false);
      final invalidList = CustomList(
        id: '',
        name: '',
        type: ListType.CUSTOM,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act & Assert
      expect(
        () => service.saveList(invalidList),
        throwsA(isA<UnifiedPersistenceException>()),
      );
    });

    test('valide qu\'un item invalide lance une exception', () async {
      // Arrange
      await service.initialize(isAuthenticated: false);
      final invalidItem = ListItem(
        id: '',
        title: '',
        listId: '',
        createdAt: DateTime.now(),
      );

      // Act & Assert
      expect(
        () => service.saveItem(invalidItem),
        throwsA(isA<UnifiedPersistenceException>()),
      );
    });
  });

  group('Configuration Tests', () {
    test('UnifiedPersistenceConfiguration utilise les valeurs par défaut', () {
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