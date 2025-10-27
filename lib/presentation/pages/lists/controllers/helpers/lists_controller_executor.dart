import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';

import '../../models/lists_state.dart';
import '../../services/list_item_sync_service.dart';
import '../state/lists_state_manager.dart';
import '../../interfaces/lists_managers_interfaces.dart';

mixin ListsControllerExecutor on StateNotifier<ListsState> {
  ListsStateManager get stateManager;
  ListItemSyncService get syncService;
  IListsPerformanceMonitor get performanceMonitor;
  ILogger get logger;
  bool get controllerInitialized;
  bool get controllerDisposed;
  String get logContext;

  @protected
  Future<void> runAsync(
    String operation,
    Future<ListsState> Function() action, {
    bool showLoading = true,
  }) async {
    if (!controllerInitialized || controllerDisposed) return;

    if (showLoading) {
      state = stateManager.setLoading(state);
    }

    performanceMonitor.startOperation(operation);
    try {
      final nextState = await action();
      performanceMonitor.endOperation(operation);
      if (!controllerDisposed) {
        state = stateManager.clearError(nextState);
      }
    } on ListSyncOperationFailure catch (failure) {
      performanceMonitor.endOperation(operation);
      _logFailure(operation, failure.error, failure.stackTrace);
      if (!controllerDisposed) {
        state = stateManager.setError(
          failure.cleanedState,
          failure.error.toString(),
        );
      }
      Error.throwWithStackTrace(failure.error, failure.stackTrace);
    } catch (error, stack) {
      performanceMonitor.endOperation(operation);
      _logFailure(operation, error, stack);
      if (!controllerDisposed) {
        state = stateManager.setError(state, error.toString());
      }
      rethrow;
    }
  }

  @protected
  Future<void> runItemOperation({
    required String operation,
    required String itemId,
    required Future<ListsState> Function(ListsState currentState) action,
  }) async {
    if (!controllerInitialized || controllerDisposed) return;

    await runAsync(
      operation,
      () => syncService.runForItem(
        state: state,
        itemId: itemId,
        operation: action,
      ),
      showLoading: false,
    );
  }

  @protected
  Future<void> runItemsOperation({
    required String operation,
    required Set<String> itemIds,
    required Future<ListsState> Function(ListsState currentState) action,
  }) async {
    if (!controllerInitialized || controllerDisposed || itemIds.isEmpty) {
      return;
    }

    await runAsync(
      operation,
      () => syncService.runForItems(
        state: state,
        itemIds: itemIds,
        operation: action,
      ),
      showLoading: false,
    );
  }

  @protected
  void runSync(String operation, VoidCallback mutation) {
    if (!controllerInitialized || controllerDisposed) return;

    try {
      mutation();
      performanceMonitor.logInfo(
        'Operation $operation applied',
        context: logContext,
      );
    } catch (error, stack) {
      _logFailure(operation, error, stack);
      state = stateManager.setError(state, error.toString());
    }
  }

  void _logFailure(String operation, Object error, StackTrace stack) {
    logger.error(
      'Operation $operation failed',
      context: logContext,
      error: error,
      stackTrace: stack,
    );
  }
}
