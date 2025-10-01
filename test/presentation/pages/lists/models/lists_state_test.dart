import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/pages/lists/models/lists_state.dart';

void main() {
  group('ListsState', () {
    late CustomList testList;
    late ListItem testItem;

    setUp(() {
      testItem = ListItem(
        id: 'item-1',
        title: 'Test Item',
        createdAt: DateTime.now(),
        listId: 'list-1',
      );

      testList = CustomList(
        id: 'list-1',
        name: 'Test List',
        type: ListType.TODO,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: [testItem],
      );
    });

    group('Factory Constructors', () {
      test('initial creates empty state', () {
        const state = ListsState.initial();

        expect(state.lists, isEmpty);
        expect(state.filteredLists, isEmpty);
        expect(state.searchQuery, isEmpty);
        expect(state.selectedType, isNull);
        expect(state.showCompleted, isTrue);
        expect(state.showInProgress, isTrue);
        expect(state.selectedDateFilter, isNull);
        expect(state.sortOption, SortOption.NAME_ASC);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });

      test('loading creates loading state', () {
        const state = ListsState.loading();

        expect(state.isLoading, isTrue);
        expect(state.error, isNull);
      });

      test('error creates error state', () {
        const state = ListsState.error('Test error');

        expect(state.isLoading, isFalse);
        expect(state.error, 'Test error');
      });
    });

    group('copyWith', () {
      test('creates new instance with updated values', () {
        const initialState = ListsState.initial();
        final newLists = [testList];

        final updatedState = initialState.copyWith(
          lists: newLists,
          searchQuery: 'test',
          isLoading: true,
        );

        expect(updatedState.lists, equals(newLists));
        expect(updatedState.searchQuery, 'test');
        expect(updatedState.isLoading, isTrue);
        // Autres propriétés inchangées
        expect(updatedState.showCompleted, isTrue);
        expect(updatedState.sortOption, SortOption.NAME_ASC);
      });

      test('preserves existing values when null passed', () {
        const initialState = ListsState(
          searchQuery: 'existing query',
          isLoading: true,
        );

        final updatedState = initialState.copyWith(
          lists: [testList],
          // searchQuery et isLoading non fournis -> gardent leurs valeurs
        );

        expect(updatedState.searchQuery, 'existing query');
        expect(updatedState.isLoading, isTrue);
        expect(updatedState.lists, [testList]);
      });
    });

    group('Utility Methods', () {
      test('withLoading updates loading state correctly', () {
        const state = ListsState.error('Some error');

        final loadingState = state.withLoading();
        expect(loadingState.isLoading, isTrue);
        expect(loadingState.error, isNull); // Error cleared when loading

        final notLoadingState = loadingState.withLoading(false);
        expect(notLoadingState.isLoading, isFalse);
      });

      test('withError updates error state correctly', () {
        const state = ListsState.loading();

        final errorState = state.withError('Test error');

        expect(errorState.isLoading, isFalse);
        expect(errorState.error, 'Erreur: Test error');
      });

      test('withoutError clears error', () {
        const state = ListsState.error('Test error');

        final clearedState = state.withoutError();

        expect(clearedState.error, isNull);
      });
    });

    group('Computed Properties', () {
      test('totalListsCount returns correct count', () {
        final state = ListsState(lists: [testList]);

        expect(state.totalListsCount, 1);
      });

      test('filteredListsCount returns correct count', () {
        final state = ListsState(
          lists: [testList],
          filteredLists: [testList],
        );

        expect(state.filteredListsCount, 1);
      });

      test('hasActiveFilters detects active filters', () {
        const emptyState = ListsState.initial();
        expect(emptyState.hasActiveFilters, isFalse);

        final stateWithSearch = emptyState.copyWith(searchQuery: 'test');
        expect(stateWithSearch.hasActiveFilters, isTrue);

        final stateWithType = emptyState.copyWith(selectedType: ListType.TODO);
        expect(stateWithType.hasActiveFilters, isTrue);

        final stateWithSort = emptyState.copyWith(sortOption: SortOption.DATE_CREATED_DESC);
        expect(stateWithSort.hasActiveFilters, isTrue);

        final stateWithStatus = emptyState.copyWith(showCompleted: false);
        expect(stateWithStatus.hasActiveFilters, isTrue);
      });

      test('isEmpty detects empty state', () {
        const emptyState = ListsState.initial();
        expect(emptyState.isEmpty, isTrue);

        final nonEmptyState = emptyState.copyWith(lists: [testList]);
        expect(nonEmptyState.isEmpty, isFalse);
      });

      test('hasDataButNoResults detects filtering issues', () {
        const emptyState = ListsState.initial();
        expect(emptyState.hasDataButNoResults, isFalse);

        final stateWithData = emptyState.copyWith(
          lists: [testList],
          filteredLists: [testList],
        );
        expect(stateWithData.hasDataButNoResults, isFalse);

        final stateWithFilteringIssue = emptyState.copyWith(
          lists: [testList],
          filteredLists: <CustomList>[],
        );
        expect(stateWithFilteringIssue.hasDataButNoResults, isTrue);
      });
    });

    group('Data Operations', () {
      test('findListById returns correct list', () {
        final state = ListsState(lists: [testList]);

        final found = state.findListById('list-1');
        expect(found, equals(testList));

        final notFound = state.findListById('non-existent');
        expect(notFound, isNull);
      });

      test('totalItemsCount calculates correctly', () {
        final list2 = testList.copyWith(
          id: 'list-2',
          items: [
            testItem.copyWith(id: 'item-2'),
            testItem.copyWith(id: 'item-3'),
          ],
        );

        final state = ListsState(lists: [testList, list2]);

        expect(state.totalItemsCount, 3); // 1 + 2 items
      });

      test('completedItemsCount calculates correctly', () {
        final completedItem = testItem.copyWith(
          id: 'item-completed',
          isCompleted: true,
        );

        final listWithCompleted = testList.copyWith(
          items: [testItem, completedItem],
        );

        final state = ListsState(lists: [listWithCompleted]);

        expect(state.completedItemsCount, 1);
      });
    });

    group('Validation', () {
      test('isValid returns true for consistent state', () {
        final state = ListsState(
          lists: [testList],
          filteredLists: [testList],
        );

        expect(state.isValid, isTrue);
      });

      test('isValid returns false for inconsistent state', () {
        final otherList = testList.copyWith(id: 'other-list');

        // More filtered lists than total lists
        final invalidState1 = ListsState(
          lists: [testList],
          filteredLists: [testList, otherList],
        );
        expect(invalidState1.isValid, isFalse);

        // Loading with error
        const invalidState2 = ListsState(
          isLoading: true,
          error: 'Some error',
        );
        expect(invalidState2.isValid, isFalse);

        // Filtered list contains item not in main list
        final invalidState3 = ListsState(
          lists: [testList],
          filteredLists: [otherList],
        );
        expect(invalidState3.isValid, isFalse);
      });
    });

    group('Equality and HashCode', () {
      test('equal states are considered equal', () {
        final state1 = ListsState(lists: [testList]);
        final state2 = ListsState(lists: [testList]);

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('different states are not equal', () {
        final state1 = ListsState(lists: [testList]);
        final state2 = ListsState(
          lists: [testList],
          searchQuery: 'different',
        );

        expect(state1, isNot(equals(state2)));
        expect(state1.hashCode, isNot(equals(state2.hashCode)));
      });

      test('identical instances are equal', () {
        final state = ListsState(lists: [testList]);

        expect(state, equals(state));
        expect(identical(state, state), isTrue);
      });
    });

    group('toString', () {
      test('provides readable string representation', () {
        final state = ListsState(
          lists: [testList],
          filteredLists: [testList],
          searchQuery: 'test',
          isLoading: true,
        );

        final stringRep = state.toString();

        expect(stringRep, contains('ListsState'));
        expect(stringRep, contains('lists: 1'));
        expect(stringRep, contains('filteredLists: 1'));
        expect(stringRep, contains('searchQuery: "test"'));
        expect(stringRep, contains('isLoading: true'));
      });
    });
  });
}