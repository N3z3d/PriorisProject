import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/pages/lists/controllers/state/lists_state_manager.dart';
import 'package:prioris/presentation/pages/lists/models/lists_state.dart';
import 'package:prioris/presentation/pages/lists/services/list_item_sync_service.dart';

void main() {
  group('ListItemSyncService', () {
    late ListsStateManager manager;
    late ListItemSyncService service;
    late ListsState initialState;

    setUp(() {
      manager = const ListsStateManager();
      service = ListItemSyncService(manager);
      initialState = const ListsState.initial();
    });

    test('wraps an item operation with syncing flags', () async {
      ListsState? stateReceived;

      final result = await service.runForItem(
        state: initialState,
        itemId: 'item-42',
        operation: (workingState) async {
          stateReceived = workingState;
          expect(workingState.syncingItemIds, contains('item-42'));
          return workingState;
        },
      );

      expect(stateReceived, isNotNull);
      expect(stateReceived!.syncingItemIds, contains('item-42'));
      expect(result.syncingItemIds, isNot(contains('item-42')));
    });

    test('clears syncing flag when operation throws', () async {
      try {
        await service.runForItem(
          state: initialState,
          itemId: 'item-error',
          operation: (_) async {
            throw StateError('boom');
          },
        );
        fail('Should have thrown');
      } on ListSyncOperationFailure catch (failure) {
        expect(failure.cleanedState.syncingItemIds, isNot(contains('item-error')));
        expect(failure.error, isA<StateError>());
      }
    });

    test('supports batch syncing operations', () async {
      final ids = {'a', 'b'};
      ListsState? workingState;

      final result = await service.runForItems(
        state: initialState,
        itemIds: ids,
        operation: (state) async {
          workingState = state;
          expect(state.syncingItemIds, containsAll(ids));
          return state;
        },
      );

      expect(workingState, isNotNull);
      expect(result.syncingItemIds, isNot(contains('a')));
      expect(result.syncingItemIds, isNot(contains('b')));
    });
  });
}
