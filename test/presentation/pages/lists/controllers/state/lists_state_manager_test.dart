import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/services/core/lists_filter_service.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';
import 'package:prioris/presentation/pages/lists/controllers/state/lists_state_manager.dart';

import 'lists_state_manager_test.mocks.dart';

@GenerateMocks([ListsFilterService])
void main() {
  group('ListsStateManager Tests - SOLID SRP Compliance', () {
    late MockListsFilterService mockFilterService;
    late ListsStateManager stateManager;

    setUp(() {
      mockFilterService = MockListsFilterService();
      stateManager = ListsStateManager(filterService: mockFilterService);
    });

    tearDown(() {
      stateManager.dispose();
    });

    group('SRP - Single Responsibility Principle Tests', () {
      test('should manage state only without business logic', () {
        // GIVEN - État initial
        expect(stateManager.currentState.lists, isEmpty);
        expect(stateManager.currentState.isLoading, false);

        // WHEN - Mise à jour d'état simple
        stateManager.setLoadingState(true);

        // THEN - Seul l'état doit changer
        expect(stateManager.currentState.isLoading, true);
        expect(stateManager.currentState.error, isNull);
      });

      test('should delegate filtering to external service (SRP)', () {
        // GIVEN
        final testLists = [
          CustomList(
            id: '1',
            name: 'Test List',
            createdAt: DateTime.now(),
          ),
        ];

        when(mockFilterService.applyFilters(
          any,
          searchQuery: anyNamed('searchQuery'),
          selectedType: anyNamed('selectedType'),
          showCompleted: anyNamed('showCompleted'),
          showInProgress: anyNamed('showInProgress'),
          selectedDateFilter: anyNamed('selectedDateFilter'),
          sortOption: anyNamed('sortOption'),
        )).thenReturn(testLists);

        // WHEN - Mise à jour des listes (qui déclenche le filtrage)
        stateManager.updateLists(testLists);

        // THEN - Le service de filtrage doit être appelé (délégation)
        verify(mockFilterService.applyFilters(
          testLists,
          searchQuery: '',
          selectedType: null,
          showCompleted: true,
          showInProgress: true,
          selectedDateFilter: null,
          sortOption: SortOption.NAME_ASC,
        )).called(1);

        expect(stateManager.currentState.lists, equals(testLists));
      });

      test('should not contain any business logic validation', () {
        // GIVEN - Liste avec données potentiellement invalides
        final invalidList = CustomList(
          id: '',  // ID vide - validation métier
          name: '', // Nom vide - validation métier
          createdAt: DateTime.now().add(Duration(days: 1)), // Date future - validation métier
        );

        // WHEN - Ajout direct sans validation (SRP - pas de validation dans StateManager)
        expect(() => stateManager.addList(invalidList), returnsNormally);

        // THEN - L'état doit être mis à jour sans validation
        expect(stateManager.currentState.lists, contains(invalidList));
        // Note: La validation doit être faite par ValidationService, pas ici
      });
    });

    group('State Management Core Functions', () {
      test('should update search query and apply filters', () {
        // GIVEN
        final testLists = [
          CustomList(id: '1', name: 'Test', createdAt: DateTime.now()),
        ];

        when(mockFilterService.applyFilters(any,
          searchQuery: anyNamed('searchQuery'),
          selectedType: anyNamed('selectedType'),
          showCompleted: anyNamed('showCompleted'),
          showInProgress: anyNamed('showInProgress'),
          selectedDateFilter: anyNamed('selectedDateFilter'),
          sortOption: anyNamed('sortOption'),
        )).thenReturn(testLists);

        stateManager.updateLists(testLists);

        // WHEN
        stateManager.updateSearchQuery('test query');

        // THEN
        expect(stateManager.currentState.searchQuery, equals('test query'));
        verify(mockFilterService.applyFilters(any,
          searchQuery: 'test query',
          selectedType: null,
          showCompleted: true,
          showInProgress: true,
          selectedDateFilter: null,
          sortOption: SortOption.NAME_ASC,
        )).called(1);
      });

      test('should update filter options', () {
        // WHEN
        stateManager.updateTypeFilter(ListType.habit);
        stateManager.updateShowCompleted(false);
        stateManager.updateShowInProgress(false);
        stateManager.updateSortOption(SortOption.CREATION_DATE_DESC);

        // THEN
        final state = stateManager.currentState;
        expect(state.selectedType, equals(ListType.habit));
        expect(state.showCompleted, false);
        expect(state.showInProgress, false);
        expect(state.sortOption, equals(SortOption.CREATION_DATE_DESC));
      });

      test('should manage error states', () {
        // WHEN
        stateManager.setErrorState('Test error');

        // THEN
        expect(stateManager.currentState.error, equals('Test error'));
        expect(stateManager.currentState.isLoading, false);

        // WHEN - Clear error
        stateManager.clearError();

        // THEN
        expect(stateManager.currentState.error, isNull);
      });
    });

    group('List Operations', () {
      test('should add list to state', () {
        // GIVEN
        final list = CustomList(
          id: '1',
          name: 'Test List',
          createdAt: DateTime.now(),
        );

        when(mockFilterService.applyFilters(any,
          searchQuery: anyNamed('searchQuery'),
          selectedType: anyNamed('selectedType'),
          showCompleted: anyNamed('showCompleted'),
          showInProgress: anyNamed('showInProgress'),
          selectedDateFilter: anyNamed('selectedDateFilter'),
          sortOption: anyNamed('sortOption'),
        )).thenReturn([list]);

        // WHEN
        stateManager.addList(list);

        // THEN
        expect(stateManager.currentState.lists, contains(list));
      });

      test('should update existing list in state', () {
        // GIVEN
        final originalList = CustomList(
          id: '1',
          name: 'Original',
          createdAt: DateTime.now(),
        );

        final updatedList = originalList.copyWith(name: 'Updated');

        when(mockFilterService.applyFilters(any,
          searchQuery: anyNamed('searchQuery'),
          selectedType: anyNamed('selectedType'),
          showCompleted: anyNamed('showCompleted'),
          showInProgress: anyNamed('showInProgress'),
          selectedDateFilter: anyNamed('selectedDateFilter'),
          sortOption: anyNamed('sortOption'),
        )).thenReturn([originalList]).thenReturn([updatedList]);

        stateManager.addList(originalList);

        // WHEN
        stateManager.updateList(updatedList);

        // THEN
        expect(stateManager.currentState.lists.first.name, equals('Updated'));
      });

      test('should remove list from state', () {
        // GIVEN
        final list = CustomList(
          id: '1',
          name: 'Test List',
          createdAt: DateTime.now(),
        );

        when(mockFilterService.applyFilters(any,
          searchQuery: anyNamed('searchQuery'),
          selectedType: anyNamed('selectedType'),
          showCompleted: anyNamed('showCompleted'),
          showInProgress: anyNamed('showInProgress'),
          selectedDateFilter: anyNamed('selectedDateFilter'),
          sortOption: anyNamed('sortOption'),
        )).thenReturn([list]).thenReturn([]);

        stateManager.addList(list);

        // WHEN
        stateManager.removeList('1');

        // THEN
        expect(stateManager.currentState.lists, isEmpty);
      });
    });

    group('Item Operations', () {
      test('should add item to list in state', () {
        // GIVEN
        final list = CustomList(
          id: '1',
          name: 'Test List',
          createdAt: DateTime.now(),
          items: [],
        );

        final item = ListItem(
          id: 'item1',
          title: 'Test Item',
          listId: '1',
          createdAt: DateTime.now(),
        );

        when(mockFilterService.applyFilters(any,
          searchQuery: anyNamed('searchQuery'),
          selectedType: anyNamed('selectedType'),
          showCompleted: anyNamed('showCompleted'),
          showInProgress: anyNamed('showInProgress'),
          selectedDateFilter: anyNamed('selectedDateFilter'),
          sortOption: anyNamed('sortOption'),
        )).thenReturn([list]).thenReturn([list.copyWith(items: [item])]);

        stateManager.updateLists([list]);

        // WHEN
        stateManager.addItemToList('1', item);

        // THEN
        final updatedList = stateManager.currentState.lists.first;
        expect(updatedList.items, contains(item));
      });

      test('should add multiple items to list in state', () {
        // GIVEN
        final list = CustomList(
          id: '1',
          name: 'Test List',
          createdAt: DateTime.now(),
          items: [],
        );

        final items = [
          ListItem(id: 'item1', title: 'Item 1', listId: '1', createdAt: DateTime.now()),
          ListItem(id: 'item2', title: 'Item 2', listId: '1', createdAt: DateTime.now()),
        ];

        when(mockFilterService.applyFilters(any,
          searchQuery: anyNamed('searchQuery'),
          selectedType: anyNamed('selectedType'),
          showCompleted: anyNamed('showCompleted'),
          showInProgress: anyNamed('showInProgress'),
          selectedDateFilter: anyNamed('selectedDateFilter'),
          sortOption: anyNamed('sortOption'),
        )).thenReturn([list]).thenReturn([list.copyWith(items: items)]);

        stateManager.updateLists([list]);

        // WHEN
        stateManager.addMultipleItemsToList('1', items);

        // THEN
        final updatedList = stateManager.currentState.lists.first;
        expect(updatedList.items, hasLength(2));
        expect(updatedList.items, containsAll(items));
      });

      test('should update item in list state', () {
        // GIVEN
        final originalItem = ListItem(
          id: 'item1',
          title: 'Original',
          listId: '1',
          createdAt: DateTime.now(),
        );

        final list = CustomList(
          id: '1',
          name: 'Test List',
          createdAt: DateTime.now(),
          items: [originalItem],
        );

        final updatedItem = originalItem.copyWith(title: 'Updated');

        when(mockFilterService.applyFilters(any,
          searchQuery: anyNamed('searchQuery'),
          selectedType: anyNamed('selectedType'),
          showCompleted: anyNamed('showCompleted'),
          showInProgress: anyNamed('showInProgress'),
          selectedDateFilter: anyNamed('selectedDateFilter'),
          sortOption: anyNamed('sortOption'),
        )).thenReturn([list]).thenReturn([list.copyWith(items: [updatedItem])]);

        stateManager.updateLists([list]);

        // WHEN
        stateManager.updateItemInList('1', updatedItem);

        // THEN
        final updatedList = stateManager.currentState.lists.first;
        expect(updatedList.items.first.title, equals('Updated'));
      });

      test('should remove item from list state', () {
        // GIVEN
        final item = ListItem(
          id: 'item1',
          title: 'Test Item',
          listId: '1',
          createdAt: DateTime.now(),
        );

        final list = CustomList(
          id: '1',
          name: 'Test List',
          createdAt: DateTime.now(),
          items: [item],
        );

        when(mockFilterService.applyFilters(any,
          searchQuery: anyNamed('searchQuery'),
          selectedType: anyNamed('selectedType'),
          showCompleted: anyNamed('showCompleted'),
          showInProgress: anyNamed('showInProgress'),
          selectedDateFilter: anyNamed('selectedDateFilter'),
          sortOption: anyNamed('sortOption'),
        )).thenReturn([list]).thenReturn([list.copyWith(items: [])]);

        stateManager.updateLists([list]);

        // WHEN
        stateManager.removeItemFromList('1', 'item1');

        // THEN
        final updatedList = stateManager.currentState.lists.first;
        expect(updatedList.items, isEmpty);
      });
    });

    group('Stream and Lifecycle', () {
      test('should emit state changes on stream', () async {
        // GIVEN
        final states = <ListsState>[];
        stateManager.stateStream.listen(states.add);

        // WHEN
        stateManager.setLoadingState(true);
        stateManager.setLoadingState(false);
        stateManager.setErrorState('Test error');

        // THEN - Attendre que les événements soient traités
        await Future.delayed(Duration(milliseconds: 10));

        expect(states, hasLength(3));
        expect(states[0].isLoading, true);
        expect(states[1].isLoading, false);
        expect(states[2].error, equals('Test error'));
      });

      test('should handle disposal correctly', () {
        // GIVEN - État normal
        expect(() => stateManager.setLoadingState(true), returnsNormally);

        // WHEN - Dispose
        stateManager.dispose();

        // THEN - Les opérations après dispose doivent être ignorées
        expect(() => stateManager.setLoadingState(false), returnsNormally);
        expect(() => stateManager.clearError(), returnsNormally);
      });

      test('should clear filter cache on disposal', () {
        // WHEN
        stateManager.dispose();

        // THEN
        verify(mockFilterService.clearCache()).called(1);
      });
    });
  });
}