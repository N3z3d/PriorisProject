/// SOLID-compliant provider for ListsController
/// Wires up all dependencies and exports the controller

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';
import 'package:prioris/presentation/pages/lists/models/lists_state.dart';
import 'package:prioris/presentation/pages/lists/managers/lists_initialization_manager.dart';
import 'package:prioris/presentation/pages/lists/managers/lists_persistence_manager.dart';
import 'package:prioris/presentation/pages/lists/managers/lists_filter_manager.dart';
import 'package:prioris/presentation/pages/lists/services/lists_validation_service.dart';
import 'package:prioris/presentation/pages/lists/interfaces/lists_managers_interfaces.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/data/providers/repository_providers.dart';

/// Provider for ILogger adapter (bridges LoggerService to ILogger interface)
final loggerProvider = Provider<ILogger>((ref) {
  return _LoggerAdapter(LoggerService.instance);
});

/// Provider for ListsValidationService
final listsValidationServiceProvider = Provider<ListsValidationService>((ref) {
  return ListsValidationService();
});

/// Provider for ListsFilterManager
final listsFilterManagerProvider = Provider<ListsFilterManager>((ref) {
  return ListsFilterManager();
});

/// Provider for ListsInitializationManager
final listsInitializationManagerProvider = FutureProvider<ListsInitializationManager>((ref) async {
  final customListRepository = await ref.watch(hiveCustomListRepositoryProvider.future);
  final itemRepository = await ref.watch(hiveListItemRepositoryProvider.future);

  return ListsInitializationManager.legacy(
    customListRepository,
    itemRepository,
  );
});

/// Provider for ListsPersistenceManager
final listsPersistenceManagerProvider = FutureProvider<ListsPersistenceManager>((ref) async {
  final customListRepository = await ref.watch(hiveCustomListRepositoryProvider.future);
  final itemRepository = await ref.watch(hiveListItemRepositoryProvider.future);

  return ListsPersistenceManager.legacy(
    customListRepository,
    itemRepository,
  );
});

/// Main provider for RefactoredListsController
/// This is the primary integration point for the UI
final listsControllerProvider = StateNotifierProvider<RefactoredListsController, ListsState>((ref) {
  // Watch for async providers to be ready
  final initManager = ref.watch(listsInitializationManagerProvider);
  final persistenceManager = ref.watch(listsPersistenceManagerProvider);

  return initManager.when(
    data: (initMgr) {
      return persistenceManager.when(
        data: (persistMgr) {
          return RefactoredListsController(
            initializationManager: initMgr,
            persistenceManager: persistMgr,
            filterManager: ref.read(listsFilterManagerProvider),
            validationService: ref.read(listsValidationServiceProvider),
            logger: ref.read(loggerProvider),
          );
        },
        loading: () => _LoadingListsController(),
        error: (err, stack) {
          LoggerService.instance.error(
            'Failed to initialize persistence manager',
            context: 'listsControllerProvider',
            error: err,
          );
          return _ErrorListsController(err.toString());
        },
      );
    },
    loading: () => _LoadingListsController(),
    error: (err, stack) {
      LoggerService.instance.error(
        'Failed to initialize initialization manager',
        context: 'listsControllerProvider',
        error: err,
      );
      return _ErrorListsController(err.toString());
    },
  );
});

/// Convenience providers for specific state properties
final listsProvider = Provider<List<CustomList>>((ref) {
  return ref.watch(listsControllerProvider).lists;
});

final filteredListsProvider = Provider<List<CustomList>>((ref) {
  return ref.watch(listsControllerProvider).filteredLists;
});

final listsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(listsControllerProvider).isLoading;
});

final listsErrorProvider = Provider<String?>((ref) {
  return ref.watch(listsControllerProvider).error;
});

/// Provider for finding a list by ID
final listByIdProvider = Provider.family<CustomList?, String>((ref, listId) {
  final state = ref.watch(listsControllerProvider);
  return state.findListById(listId);
});

// === Private helper classes ===

/// Temporary controller while loading
class _LoadingListsController extends RefactoredListsController {
  _LoadingListsController()
      : super(
          initializationManager: _DummyInitManager(),
          persistenceManager: _DummyPersistManager(),
          filterManager: ListsFilterManager(),
          validationService: ListsValidationService(),
          logger: _LoggerAdapter(LoggerService.instance),
        );
}

/// Temporary controller for error state
class _ErrorListsController extends RefactoredListsController {
  _ErrorListsController(String error)
      : super(
          initializationManager: _DummyInitManager(),
          persistenceManager: _DummyPersistManager(),
          filterManager: ListsFilterManager(),
          validationService: ListsValidationService(),
          logger: _LoggerAdapter(LoggerService.instance),
        ) {
    state = ListsState.error(error);
  }
}

/// Adapter to bridge LoggerService to ILogger interface
class _LoggerAdapter implements ILogger {
  final LoggerService _logger;

  _LoggerAdapter(this._logger);

  @override
  void debug(String message, {String? context, String? correlationId, dynamic data}) {
    _logger.debug(message, context: context ?? 'App');
  }

  @override
  void info(String message, {String? context, String? correlationId, dynamic data}) {
    _logger.info(message, context: context ?? 'App');
  }

  @override
  void warning(String message, {String? context, String? correlationId, dynamic data}) {
    _logger.warning(message, context: context ?? 'App');
  }

  @override
  void error(String message, {String? context, String? correlationId, dynamic error, StackTrace? stackTrace}) {
    _logger.error(message, context: context ?? 'App', error: error);
  }

  @override
  void fatal(String message, {String? context, String? correlationId, dynamic error, StackTrace? stackTrace}) {
    _logger.error('[FATAL] $message', context: context ?? 'App', error: error);
  }

  @override
  void performance(String operation, Duration duration, {String? context, String? correlationId, Map<String, dynamic>? metrics}) {
    _logger.debug('[$operation] completed in ${duration.inMilliseconds}ms', context: context ?? 'Performance');
  }

  @override
  void userAction(String action, {String? context, String? correlationId, Map<String, dynamic>? properties}) {
    _logger.debug('[UserAction] $action', context: context ?? 'UserAction');
  }
}

/// Dummy implementation for initialization manager (used during loading)
class _DummyInitManager implements IListsInitializationManager {
  @override
  Future<void> initializeAdaptive() async {}

  @override
  Future<void> initializeLegacy() async {}

  @override
  Future<void> initializeAsync() async {}

  @override
  bool get isInitialized => false;

  @override
  String get initializationMode => 'dummy';
}

/// Dummy implementation for persistence manager (used during loading)
class _DummyPersistManager implements IListsPersistenceManager {
  @override
  Future<List<CustomList>> loadAllLists() async => [];

  @override
  Future<void> saveList(CustomList list) async {}

  @override
  Future<void> updateList(CustomList list) async {}

  @override
  Future<void> deleteList(String listId) async {}

  @override
  Future<List<ListItem>> loadListItems(String listId) async => [];

  @override
  Future<void> saveListItem(ListItem item) async {}

  @override
  Future<void> updateListItem(ListItem item) async {}

  @override
  Future<void> deleteListItem(String itemId) async {}

  @override
  Future<void> saveMultipleItems(List<ListItem> items) async {}

  @override
  Future<List<CustomList>> forceReloadFromPersistence() async => [];

  @override
  Future<void> clearAllData() async {}

  @override
  Future<void> verifyListPersistence(String listId) async {}

  @override
  Future<void> verifyItemPersistence(String itemId) async {}

  @override
  Future<void> rollbackItems(List<ListItem> items) async {}
}
