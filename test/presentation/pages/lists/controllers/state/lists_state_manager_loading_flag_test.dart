import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/pages/lists/controllers/operations/lists_crud_operations.dart';
import 'package:prioris/presentation/pages/lists/controllers/state/lists_state_manager.dart';
import 'package:prioris/presentation/pages/lists/interfaces/lists_managers_interfaces.dart';
import 'package:prioris/presentation/pages/lists/models/lists_state.dart';

import '../../../../../test_utils/list_test_doubles.dart';

void main() {
  test('clearError resets loading flag and removes error', () {
    const manager = ListsStateManager();
    final baseState = const ListsState.initial();

    final loadingState = manager.setLoading(baseState);
    expect(loadingState.isLoading, isTrue);

    final erroredState = loadingState.copyWith(error: 'Test');
    final cleared = manager.clearError(erroredState);

    expect(cleared.error, isNull);
    expect(cleared.isLoading, isFalse);
  });

  test('createList clears loading state and exposes the new list immediately',
      () async {
    final now = DateTime(2024, 10, 20, 12);
    final list = CustomList(
      id: 'list-123',
      name: 'Liste prioritaire',
      type: ListType.CUSTOM,
      createdAt: now,
      updatedAt: now,
      items: const [],
    );

    final manager = ListsStateManager();
    final crud = ListsCrudOperations(
      persistence: const NoopListsPersistenceManager(),
      validator: const PassthroughListsValidationService(),
      filterManager: const EchoListsFilterManager(),
      stateManager: manager,
      logger: const SilentLogger(),
    );

    final initial = const ListsState.initial().copyWith(isLoading: true);

    final result = await crud.createList(initial, list);

    expect(result.isLoading, isFalse);
    expect(result.lists, contains(list));
    expect(result.filteredLists, contains(list));
  });

  test('setItemSyncing toggles the presence of the item id in state', () {
    const manager = ListsStateManager();
    const initial = ListsState.initial();

    final syncingState =
        manager.setItemSyncing(initial, 'item-42', isSyncing: true);
    expect(syncingState.syncingItemIds, contains('item-42'));

    final clearedState =
        manager.setItemSyncing(syncingState, 'item-42', isSyncing: false);
    expect(clearedState.syncingItemIds, isEmpty);
  });
}
