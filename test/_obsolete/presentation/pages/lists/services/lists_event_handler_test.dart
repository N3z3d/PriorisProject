import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/services/core/lists_filter_service.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';
import 'package:prioris/presentation/pages/lists/models/lists_state.dart';
import 'package:prioris/presentation/pages/lists/services/lists_event_handler.dart';

/// Mocks pour les tests
class MockListsFilterService extends Mock implements ListsFilterService {}
class MockLogger extends Mock implements ILogger {}

void main() {
  group('ListsEventHandler Tests', () {
    late ListsEventHandler eventHandler;
    late MockListsFilterService mockFilterService;
    late MockLogger mockLogger;

    setUp(() {
      mockFilterService = MockListsFilterService();
      mockLogger = MockLogger();

      eventHandler = ListsEventHandler(
        filterService: mockFilterService,
        logger: mockLogger,
      );
    });

    group('updateListsAndApplyFilters', () {
      test('met à jour l\'état avec de nouvelles listes et applique les filtres', () {
        // Arrange
        final currentState = const ListsState();
        final testLists = [
          CustomList(
            id: '1',
            name: 'Test List 1',
            type: ListType.PERSONAL,
            createdAt: DateTime.now(),
          ),
          CustomList(
            id: '2',
            name: 'Test List 2',
            type: ListType.WORK,
            createdAt: DateTime.now(),
          ),
        ];
        final filteredLists = [testLists.first]; // Filtre retourne seulement la première

        when(mockFilterService.applyFilters(
          testLists,
          searchQuery: anyNamed('searchQuery'),
          selectedType: anyNamed('selectedType'),
          showCompleted: anyNamed('showCompleted'),
          showInProgress: anyNamed('showInProgress'),
          selectedDateFilter: anyNamed('selectedDateFilter'),
          sortOption: anyNamed('sortOption'),
        )).thenReturn(filteredLists);

        // Act
        final result = eventHandler.updateListsAndApplyFilters(currentState, testLists);

        // Assert
        expect(result.lists, equals(testLists));
        expect(result.filteredLists, equals(filteredLists));
        verify(mockFilterService.applyFilters(
          testLists,
          searchQuery: '',
          selectedType: null,
          showCompleted: true,
          showInProgress: true,
          selectedDateFilter: null,
          sortOption: SortOption.NAME_ASC,
        )).called(1);
        verify(mockLogger.debug(any, context: 'ListsEventHandler')).called(greaterThanOrEqualTo(1));
      });

      test('utilise toutes les listes comme fallback si le filtrage retourne une liste vide', () {
        // Arrange
        final currentState = const ListsState();
        final testLists = [
          CustomList(
            id: '1',
            name: 'Test List',
            type: ListType.PERSONAL,
            createdAt: DateTime.now(),
          ),
        ];
        final emptyFilteredLists = <CustomList>[];

        when(mockFilterService.applyFilters(
          any,
          searchQuery: anyNamed('searchQuery'),
          selectedType: anyNamed('selectedType'),
          showCompleted: anyNamed('showCompleted'),
          showInProgress: anyNamed('showInProgress'),
          selectedDateFilter: anyNamed('selectedDateFilter'),
          sortOption: anyNamed('sortOption'),
        )).thenReturn(emptyFilteredLists);

        // Act
        final result = eventHandler.updateListsAndApplyFilters(currentState, testLists);

        // Assert
        expect(result.lists, equals(testLists));
        expect(result.filteredLists, equals(testLists)); // Fallback appliqué
        verify(mockLogger.warning(any, context: 'ListsEventHandler')).called(1);
      });
    });

    group('Filter Updates', () {
      test('updateSearchQuery met à jour la requête de recherche et applique les filtres', () {
        // Arrange
        final currentState = ListsState(
          lists: [
            CustomList(
              id: '1',
              name: 'Test List',
              type: ListType.PERSONAL,
              createdAt: DateTime.now(),
            ),
          ],
        );
        final filteredLists = currentState.lists;

        when(mockFilterService.applyFilters(
          any,
          searchQuery: anyNamed('searchQuery'),
          selectedType: anyNamed('selectedType'),
          showCompleted: anyNamed('showCompleted'),
          showInProgress: anyNamed('showInProgress'),
          selectedDateFilter: anyNamed('selectedDateFilter'),
          sortOption: anyNamed('sortOption'),
        )).thenReturn(filteredLists);

        // Act
        final result = eventHandler.updateSearchQuery(currentState, 'test query');

        // Assert
        expect(result.searchQuery, equals('test query'));
        expect(result.filteredLists, equals(filteredLists));
        verify(mockFilterService.applyFilters(
          currentState.lists,
          searchQuery: 'test query',
          selectedType: null,
          showCompleted: true,
          showInProgress: true,
          selectedDateFilter: null,
          sortOption: SortOption.NAME_ASC,
        )).called(1);
      });

      test('updateTypeFilter met à jour le filtre de type', () {
        // Arrange
        final currentState = ListsState(
          lists: [
            CustomList(
              id: '1',
              name: 'Test List',
              type: ListType.PERSONAL,
              createdAt: DateTime.now(),
            ),
          ],
        );
        final filteredLists = currentState.lists;

        when(mockFilterService.applyFilters(
          any,
          searchQuery: anyNamed('searchQuery'),
          selectedType: anyNamed('selectedType'),
          showCompleted: anyNamed('showCompleted'),
          showInProgress: anyNamed('showInProgress'),
          selectedDateFilter: anyNamed('selectedDateFilter'),
          sortOption: anyNamed('sortOption'),
        )).thenReturn(filteredLists);

        // Act
        final result = eventHandler.updateTypeFilter(currentState, ListType.WORK);

        // Assert
        expect(result.selectedType, equals(ListType.WORK));
        verify(mockFilterService.applyFilters(
          currentState.lists,
          searchQuery: '',
          selectedType: ListType.WORK,
          showCompleted: true,
          showInProgress: true,
          selectedDateFilter: null,
          sortOption: SortOption.NAME_ASC,
        )).called(1);
      });

      test('updateSortOption met à jour l\'option de tri', () {
        // Arrange
        final currentState = ListsState(
          lists: [
            CustomList(
              id: '1',
              name: 'Test List',
              type: ListType.PERSONAL,
              createdAt: DateTime.now(),
            ),
          ],
        );
        final filteredLists = currentState.lists;

        when(mockFilterService.applyFilters(
          any,
          searchQuery: anyNamed('searchQuery'),
          selectedType: anyNamed('selectedType'),
          showCompleted: anyNamed('showCompleted'),
          showInProgress: anyNamed('showInProgress'),
          selectedDateFilter: anyNamed('selectedDateFilter'),
          sortOption: anyNamed('sortOption'),
        )).thenReturn(filteredLists);

        // Act
        final result = eventHandler.updateSortOption(currentState, SortOption.DATE_CREATED_DESC);

        // Assert
        expect(result.sortOption, equals(SortOption.DATE_CREATED_DESC));
        verify(mockFilterService.applyFilters(
          currentState.lists,
          searchQuery: '',
          selectedType: null,
          showCompleted: true,
          showInProgress: true,
          selectedDateFilter: null,
          sortOption: SortOption.DATE_CREATED_DESC,
        )).called(1);
      });
    });

    group('List State Operations', () {
      test('addListToState ajoute une liste et met à jour les filtres', () {
        // Arrange
        final existingList = CustomList(
          id: '1',
          name: 'Existing List',
          type: ListType.PERSONAL,
          createdAt: DateTime.now(),
        );
        final newList = CustomList(
          id: '2',
          name: 'New List',
          type: ListType.WORK,
          createdAt: DateTime.now(),
        );
        final currentState = ListsState(lists: [existingList]);
        final expectedLists = [existingList, newList];

        when(mockFilterService.applyFilters(
          expectedLists,
          searchQuery: anyNamed('searchQuery'),
          selectedType: anyNamed('selectedType'),
          showCompleted: anyNamed('showCompleted'),
          showInProgress: anyNamed('showInProgress'),
          selectedDateFilter: anyNamed('selectedDateFilter'),
          sortOption: anyNamed('sortOption'),
        )).thenReturn(expectedLists);

        // Act
        final result = eventHandler.addListToState(currentState, newList);

        // Assert
        expect(result.lists, equals(expectedLists));
        expect(result.filteredLists, equals(expectedLists));
      });

      test('removeListFromState supprime une liste et met à jour les filtres', () {
        // Arrange
        final listToKeep = CustomList(
          id: '1',
          name: 'Keep List',
          type: ListType.PERSONAL,
          createdAt: DateTime.now(),
        );
        final listToRemove = CustomList(
          id: '2',
          name: 'Remove List',
          type: ListType.WORK,
          createdAt: DateTime.now(),
        );
        final currentState = ListsState(lists: [listToKeep, listToRemove]);
        final expectedLists = [listToKeep];

        when(mockFilterService.applyFilters(
          expectedLists,
          searchQuery: anyNamed('searchQuery'),
          selectedType: anyNamed('selectedType'),
          showCompleted: anyNamed('showCompleted'),
          showInProgress: anyNamed('showInProgress'),
          selectedDateFilter: anyNamed('selectedDateFilter'),
          sortOption: anyNamed('sortOption'),
        )).thenReturn(expectedLists);

        // Act
        final result = eventHandler.removeListFromState(currentState, '2');

        // Assert
        expect(result.lists, equals(expectedLists));
        expect(result.filteredLists, equals(expectedLists));
      });
    });

    group('Item State Operations', () {
      test('addItemToListState ajoute un item à une liste spécifique', () {
        // Arrange
        final testList = CustomList(
          id: '1',
          name: 'Test List',
          type: ListType.PERSONAL,
          createdAt: DateTime.now(),
          items: [],
        );
        final newItem = ListItem(
          id: 'item1',
          title: 'New Item',
          listId: '1',
          createdAt: DateTime.now(),
        );
        final currentState = ListsState(lists: [testList]);

        when(mockFilterService.applyFilters(
          any,
          searchQuery: anyNamed('searchQuery'),
          selectedType: anyNamed('selectedType'),
          showCompleted: anyNamed('showCompleted'),
          showInProgress: anyNamed('showInProgress'),
          selectedDateFilter: anyNamed('selectedDateFilter'),
          sortOption: anyNamed('sortOption'),
        )).thenReturn([testList.copyWith(items: [newItem])]);

        // Act
        final result = eventHandler.addItemToListState(currentState, '1', newItem);

        // Assert
        expect(result.lists.first.items, hasLength(1));
        expect(result.lists.first.items.first.id, equals('item1'));
      });

      test('removeItemFromListState supprime un item d\'une liste spécifique', () {
        // Arrange
        final existingItem = ListItem(
          id: 'item1',
          title: 'Existing Item',
          listId: '1',
          createdAt: DateTime.now(),
        );
        final testList = CustomList(
          id: '1',
          name: 'Test List',
          type: ListType.PERSONAL,
          createdAt: DateTime.now(),
          items: [existingItem],
        );
        final currentState = ListsState(lists: [testList]);

        when(mockFilterService.applyFilters(
          any,
          searchQuery: anyNamed('searchQuery'),
          selectedType: anyNamed('selectedType'),
          showCompleted: anyNamed('showCompleted'),
          showInProgress: anyNamed('showInProgress'),
          selectedDateFilter: anyNamed('selectedDateFilter'),
          sortOption: anyNamed('sortOption'),
        )).thenReturn([testList.copyWith(items: [])]);

        // Act
        final result = eventHandler.removeItemFromListState(currentState, '1', 'item1');

        // Assert
        expect(result.lists.first.items, isEmpty);
      });
    });

    group('State Management', () {
      test('setLoadingState met l\'état en mode chargement', () {
        // Arrange
        final currentState = const ListsState();

        // Act
        final result = eventHandler.setLoadingState(currentState, true);

        // Assert
        expect(result.isLoading, isTrue);
        expect(result.error, isNull);
      });

      test('setErrorState met l\'état en erreur et arrête le chargement', () {
        // Arrange
        final currentState = const ListsState(isLoading: true);

        // Act
        final result = eventHandler.setErrorState(currentState, 'Test error');

        // Assert
        expect(result.isLoading, isFalse);
        expect(result.error, equals('Erreur: Test error'));
      });

      test('clearError efface l\'erreur de l\'état', () {
        // Arrange
        final currentState = const ListsState(error: 'Some error');

        // Act
        final result = eventHandler.clearError(currentState);

        // Assert
        expect(result.error, isNull);
      });
    });
  });
}