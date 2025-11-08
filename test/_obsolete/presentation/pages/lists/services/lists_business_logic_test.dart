import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/services/persistence/adaptive_persistence_service.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';
import 'package:prioris/presentation/pages/lists/services/lists_business_logic.dart';

/// Mocks pour les tests
class MockAdaptivePersistenceService extends Mock implements AdaptivePersistenceService {}
class MockCustomListRepository extends Mock implements CustomListRepository {}
class MockListItemRepository extends Mock implements ListItemRepository {}
class MockLogger extends Mock implements ILogger {}

void main() {
  group('ListsBusinessLogic Tests', () {
    late ListsBusinessLogic businessLogic;
    late MockAdaptivePersistenceService mockAdaptiveService;
    late MockCustomListRepository mockListRepository;
    late MockListItemRepository mockItemRepository;
    late MockLogger mockLogger;

    setUp(() {
      mockAdaptiveService = MockAdaptivePersistenceService();
      mockListRepository = MockCustomListRepository();
      mockItemRepository = MockListItemRepository();
      mockLogger = MockLogger();

      businessLogic = ListsBusinessLogic(
        adaptivePersistenceService: mockAdaptiveService,
        listRepository: mockListRepository,
        itemRepository: mockItemRepository,
        logger: mockLogger,
      );
    });

    group('loadAllLists', () {
      test('charges les listes via AdaptivePersistenceService quand disponible', () async {
        // Arrange
        final testLists = [
          CustomList(
            id: '1',
            name: 'Test List',
            type: ListType.CUSTOM,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        final testItems = [
          ListItem(
            id: 'item1',
            title: 'Test Item',
            listId: '1',
            createdAt: DateTime.now(),
          ),
        ];

        when(mockAdaptiveService.getAllLists()).thenAnswer((_) async => testLists);
        when(mockAdaptiveService.getItemsByListId('1')).thenAnswer((_) async => testItems);
        when(mockAdaptiveService.currentMode).thenReturn(PersistenceMode.localFirst);

        // Act
        final result = await businessLogic.loadAllLists();

        // Assert
        expect(result, hasLength(1));
        expect(result.first.items, hasLength(1));
        verify(mockAdaptiveService.getAllLists()).called(1);
        verify(mockAdaptiveService.getItemsByListId('1')).called(1);
        verify(mockLogger.info(argThat(isA<String>()), context: 'ListsBusinessLogic')).called(1);
      });

      test('utilise le repository legacy quand AdaptivePersistenceService est null', () async {
        // Arrange
        final businessLogicLegacy = ListsBusinessLogic(
          listRepository: mockListRepository,
          itemRepository: mockItemRepository,
          logger: mockLogger,
        );

        final testLists = [
          CustomList(
            id: '1',
            name: 'Test List Legacy',
            type: ListType.PROJECTS,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        final testItems = [
          ListItem(
            id: 'item1',
            title: 'Test Item Legacy',
            listId: '1',
            createdAt: DateTime.now(),
          ),
        ];

        when(mockListRepository.getAllLists()).thenAnswer((_) async => testLists);
        when(mockItemRepository.getByListId('1')).thenAnswer((_) async => testItems);

        // Act
        final result = await businessLogicLegacy.loadAllLists();

        // Assert
        expect(result, hasLength(1));
        expect(result.first.items, hasLength(1));
        verify(mockListRepository.getAllLists()).called(1);
        verify(mockItemRepository.getByListId('1')).called(1);
        verify(mockLogger.info(argThat(isA<String>()), context: 'ListsBusinessLogic')).called(1);
      });

      test('lance une exception quand aucun service de persistance configuré', () async {
        // Arrange
        final businessLogicEmpty = ListsBusinessLogic(logger: mockLogger);

        // Act & Assert
        expect(
          () => businessLogicEmpty.loadAllLists(),
          throwsA(isA<StateError>().having(
            (e) => e.message,
            'message',
            'Aucun service de persistance configuré',
          )),
        );
      });
    });

    group('createList', () {
      test('crée une liste via AdaptivePersistenceService et vérifie la persistance', () async {
        // Arrange
        final testList = CustomList(
          id: 'new-list',
          name: 'New List',
          type: ListType.CUSTOM,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockAdaptiveService.saveList(testList)).thenAnswer((_) async {});
        when(mockListRepository.getListById('new-list')).thenAnswer((_) async => testList);

        // Act
        await businessLogic.createList(testList);

        // Assert
        verify(mockAdaptiveService.saveList(testList)).called(1);
        verify(mockListRepository.getListById('new-list')).called(1);
        verify(mockLogger.info(argThat(isA<String>()), context: 'ListsBusinessLogic')).called(1);
      });

      test('lance une exception si la vérification de persistance échoue', () async {
        // Arrange
        final testList = CustomList(
          id: 'failing-list',
          name: 'Failing List',
          type: ListType.CUSTOM,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockAdaptiveService.saveList(testList)).thenAnswer((_) async {});
        when(mockListRepository.getListById('failing-list')).thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => businessLogic.createList(testList),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Liste non trouvée après sauvegarde'),
          )),
        );
      });
    });

    group('addItemToList', () {
      test('ajoute un item et vérifie la persistance', () async {
        // Arrange
        final testItem = ListItem(
          id: 'new-item',
          title: 'New Item',
          listId: 'list-1',
          createdAt: DateTime.now(),
        );

        when(mockAdaptiveService.saveItem(testItem)).thenAnswer((_) async {});
        when(mockItemRepository.getById('new-item')).thenAnswer((_) async => testItem);

        // Act
        await businessLogic.addItemToList(testItem);

        // Assert
        verify(mockAdaptiveService.saveItem(testItem)).called(1);
        verify(mockItemRepository.getById('new-item')).called(1);
        verify(mockLogger.info(argThat(isA<String>()), context: 'ListsBusinessLogic')).called(1);
      });
    });

    group('addMultipleItemsToList', () {
      test('ajoute plusieurs items avec gestion d\'erreur transactionnelle', () async {
        // Arrange
        final itemTitles = ['Item 1', 'Item 2', 'Item 3'];
        when(mockAdaptiveService.saveItem(argThat(isA<ListItem>()))).thenAnswer((_) async {});
        when(mockItemRepository.getById(argThat(isA<String>()))).thenAnswer((_) async => ListItem(
          id: 'mock-id',
          title: 'Mock Item',
          listId: 'list-1',
          createdAt: DateTime.now(),
        ));

        // Act
        final result = await businessLogic.addMultipleItemsToList('list-1', itemTitles);

        // Assert
        expect(result, hasLength(3));
        verify(mockAdaptiveService.saveItem(argThat(isA<ListItem>()))).called(3);
        verify(mockItemRepository.getById(argThat(isA<String>()))).called(3);
      });

      test('retourne une liste vide pour des titres vides', () async {
        // Act
        final result = await businessLogic.addMultipleItemsToList('list-1', []);

        // Assert
        expect(result, isEmpty);
        verifyNever(mockAdaptiveService.saveItem(argThat(isA<ListItem>())));
      });

      test('effectue un rollback en cas d\'échec partiel', () async {
        // Arrange
        final itemTitles = ['Item 1', 'Item 2'];
        var callCount = 0;
        when(mockAdaptiveService.saveItem(argThat(isA<ListItem>()))).thenAnswer((_) async {
          callCount++;
          if (callCount == 2) {
            throw Exception('Échec sauvegarde');
          }
        });

        when(mockItemRepository.getById(argThat(isA<String>()))).thenAnswer((_) async => ListItem(
          id: 'mock-id',
          title: 'Mock Item',
          listId: 'list-1',
          createdAt: DateTime.now(),
        ));

        when(mockAdaptiveService.deleteItem(argThat(isA<String>()))).thenAnswer((_) async {});

        // Act & Assert
        expect(
          () => businessLogic.addMultipleItemsToList('list-1', itemTitles),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Échec d\'ajout bulk'),
          )),
        );

        // Vérifier que le rollback a été appelé
        verify(mockAdaptiveService.deleteItem(argThat(isA<String>()))).called(1);
      });
    });

    group('clearAllData', () {
      test('efface toutes les données via AdaptivePersistenceService', () async {
        // Arrange
        final testLists = [
          CustomList(
            id: '1',
            name: 'List to delete',
            type: ListType.CUSTOM,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        final testItems = [
          ListItem(
            id: 'item1',
            title: 'Item to delete',
            listId: '1',
            createdAt: DateTime.now(),
          ),
        ];

        when(mockAdaptiveService.getAllLists()).thenAnswer((_) async => testLists);
        when(mockAdaptiveService.getItemsByListId('1')).thenAnswer((_) async => testItems);
        when(mockAdaptiveService.deleteList('1')).thenAnswer((_) async {});
        when(mockAdaptiveService.deleteItem('item1')).thenAnswer((_) async {});

        // Act
        await businessLogic.clearAllData();

        // Assert
        verify(mockAdaptiveService.getAllLists()).called(1);
        verify(mockAdaptiveService.getItemsByListId('1')).called(1);
        verify(mockAdaptiveService.deleteList('1')).called(1);
        verify(mockAdaptiveService.deleteItem('item1')).called(1);
        verify(mockLogger.info('Début de l\'effacement de toutes les données', context: 'ListsBusinessLogic')).called(1);
        verify(mockLogger.info('Toutes les données ont été effacées avec succès', context: 'ListsBusinessLogic')).called(1);
      });
    });
  });
}