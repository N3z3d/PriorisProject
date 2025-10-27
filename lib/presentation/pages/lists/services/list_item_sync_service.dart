import '../controllers/state/lists_state_manager.dart';
import '../models/lists_state.dart';

/// Exception encapsulating a failure that occurred during a sync-wrapped operation.
class ListSyncOperationFailure implements Exception {
  final Object error;
  final StackTrace stackTrace;
  final ListsState cleanedState;

  const ListSyncOperationFailure({
    required this.error,
    required this.stackTrace,
    required this.cleanedState,
  });

  @override
  String toString() =>
      'ListSyncOperationFailure(error: $error, cleanedState: $cleanedState)';
}

/// Coordinates syncing flags around list item operations to keep the UI spinner consistent.
class ListItemSyncService {
  final ListsStateManager _stateManager;

  const ListItemSyncService(this._stateManager);

  Future<ListsState> runForItem({
    required ListsState state,
    required String itemId,
    required Future<ListsState> Function(ListsState workingState) operation,
  }) async {
    if (itemId.isEmpty) {
      return operation(state);
    }

    final workingState =
        _stateManager.setItemSyncing(state, itemId, isSyncing: true);
    try {
      final nextState = await operation(workingState);
      return _stateManager.setItemSyncing(nextState, itemId, isSyncing: false);
    } catch (error, stackTrace) {
      final cleaned =
          _stateManager.setItemSyncing(workingState, itemId, isSyncing: false);
      throw ListSyncOperationFailure(
        error: error,
        stackTrace: stackTrace,
        cleanedState: cleaned,
      );
    }
  }

  Future<ListsState> runForItems({
    required ListsState state,
    required Set<String> itemIds,
    required Future<ListsState> Function(ListsState workingState) operation,
  }) async {
    if (itemIds.isEmpty) {
      return operation(state);
    }

    final workingState = _stateManager.setMultipleItemsSyncing(
      state,
      itemIds,
      isSyncing: true,
    );

    try {
      final nextState = await operation(workingState);
      return _stateManager.setMultipleItemsSyncing(
        nextState,
        itemIds,
        isSyncing: false,
      );
    } catch (error, stackTrace) {
      final cleaned = _stateManager.setMultipleItemsSyncing(
        workingState,
        itemIds,
        isSyncing: false,
      );
      throw ListSyncOperationFailure(
        error: error,
        stackTrace: stackTrace,
        cleanedState: cleaned,
      );
    }
  }
}
