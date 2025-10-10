import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/auth_providers.dart';
import 'package:prioris/data/providers/repository_providers.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';
import 'package:prioris/presentation/pages/lists/controllers/operations/lists_crud_operations.dart';
import 'package:prioris/presentation/pages/lists/controllers/operations/lists_validation_service.dart';
import 'package:prioris/presentation/pages/lists/controllers/state/lists_state_manager.dart';
import 'package:prioris/presentation/pages/lists/interfaces/lists_managers_interfaces.dart';
import 'package:prioris/presentation/pages/lists/managers/lists_filter_manager.dart';
import 'package:prioris/presentation/pages/lists/managers/lists_initialization_manager.dart';
import 'package:prioris/presentation/pages/lists/managers/lists_persistence_manager.dart';
import 'package:prioris/presentation/pages/lists/models/lists_state.dart';
import 'package:prioris/presentation/pages/lists/services/lists_performance_monitor.dart';

/// Logger adapter bridging infrastructure LoggerService to the domain ILogger.
final loggerProvider = Provider<ILogger>((ref) {
  return _LoggerAdapter(LoggerService.instance);
});

final listsValidationServiceProvider = Provider<ListsValidationService>((ref) {
  return ListsValidationService();
});

final listsFilterManagerProvider = Provider<ListsFilterManager>((ref) {
  return ListsFilterManager();
});

final listsStateManagerProvider = Provider<ListsStateManager>((ref) {
  return const ListsStateManager();
});

final listsPerformanceMonitorProvider = Provider<IListsPerformanceMonitor>((ref) {
  return ListsPerformanceMonitor();
});

/// Provider qui écoute les changements d'authentification et invalide les repository providers
final authChangeListenerProvider = Provider<void>((ref) {
  ref.listen<bool>(isSignedInProvider, (previous, current) {
    if (previous != null && previous != current) {
      LoggerService.instance.info(
        '🔄 Authentification changée: $previous → $current - Invalidation des repository providers',
        context: 'authChangeListener',
      );

      // Invalider les repository providers pour forcer leur recréation avec le nouveau statut d'auth
      ref.invalidate(adaptiveCustomListRepositoryProvider);
      ref.invalidate(adaptiveListItemRepositoryProvider);
      ref.invalidate(listsInitializationManagerProvider);
      ref.invalidate(listsPersistenceManagerProvider);
      // Ne pas invalider listsControllerProvider ici pour éviter la circularité
    }
  });
});

final listsInitializationManagerProvider = FutureProvider<IListsInitializationManager>((ref) async {
  // Utiliser les repositories adaptatifs qui choisissent automatiquement entre Hive et Supabase
  final customListRepository = await ref.watch(adaptiveCustomListRepositoryProvider.future);
  final itemRepository = await ref.watch(adaptiveListItemRepositoryProvider.future);
  return ListsInitializationManager.legacy(customListRepository as CustomListRepository, itemRepository);
});

final listsPersistenceManagerProvider = FutureProvider<IListsPersistenceManager>((ref) async {
  // Utiliser les repositories adaptatifs qui choisissent automatiquement entre Hive et Supabase
  final customListRepository = await ref.watch(adaptiveCustomListRepositoryProvider.future);
  final itemRepository = await ref.watch(adaptiveListItemRepositoryProvider.future);
  return ListsPersistenceManager.legacy(customListRepository as CustomListRepository, itemRepository);
});

final listsControllerProvider = StateNotifierProvider<RefactoredListsController, ListsState>((ref) {
  final initManagerAsync = ref.watch(listsInitializationManagerProvider);
  final persistenceManagerAsync = ref.watch(listsPersistenceManagerProvider);
  final filterManager = ref.watch(listsFilterManagerProvider);
  final validator = ref.watch(listsValidationServiceProvider);
  final logger = ref.watch(loggerProvider);
  final stateManager = ref.watch(listsStateManagerProvider);
  final performanceMonitor = ref.watch(listsPerformanceMonitorProvider);

  return initManagerAsync.when(
    data: (initManager) {
      return persistenceManagerAsync.when(
        data: (persistenceManager) {
          final crud = ListsCrudOperations(
            persistence: persistenceManager,
            validator: validator,
            filterManager: filterManager,
            stateManager: stateManager,
            logger: logger,
          );

          return RefactoredListsController(
            initializationManager: initManager,
            performanceMonitor: performanceMonitor,
            crudOperations: crud,
            stateManager: stateManager,
            logger: logger,
          );
        },
        loading: () => _LoadingListsController(
          stateManager: stateManager,
          logger: logger,
          performanceMonitor: performanceMonitor,
        ),
        error: (error, stack) {
          LoggerService.instance.error(
            'Failed to initialize persistence manager',
            context: 'listsControllerProvider',
            error: error,
          );
          return _ErrorListsController(
            message: error.toString(),
            stateManager: stateManager,
            logger: logger,
            performanceMonitor: performanceMonitor,
          );
        },
      );
    },
    loading: () => _LoadingListsController(
      stateManager: stateManager,
      logger: logger,
      performanceMonitor: performanceMonitor,
    ),
    error: (error, stack) {
      LoggerService.instance.error(
        'Failed to initialize initialization manager',
        context: 'listsControllerProvider',
        error: error,
      );
      return _ErrorListsController(
        message: error.toString(),
        stateManager: stateManager,
        logger: logger,
        performanceMonitor: performanceMonitor,
      );
    },
  );
});

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

final listByIdProvider = Provider.family<CustomList?, String>((ref, listId) {
  final state = ref.watch(listsControllerProvider);
  return state.findListById(listId);
});

class _LoadingListsController extends RefactoredListsController {
  _LoadingListsController({
    required ListsStateManager stateManager,
    required ILogger logger,
    required IListsPerformanceMonitor performanceMonitor,
  }) : super(
          initializationManager: _DummyInitManager(),
          performanceMonitor: performanceMonitor,
          crudOperations: _DummyCrudOperations(logger, stateManager),
          stateManager: stateManager,
          logger: logger,
        );
}

class _ErrorListsController extends RefactoredListsController {
  _ErrorListsController({
    required String message,
    required ListsStateManager stateManager,
    required ILogger logger,
    required IListsPerformanceMonitor performanceMonitor,
  }) : super(
          initializationManager: _DummyInitManager(),
          performanceMonitor: performanceMonitor,
          crudOperations: _DummyCrudOperations(logger, stateManager),
          stateManager: stateManager,
          logger: logger,
        ) {
    state = ListsState.error(message);
  }
}

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

class _DummyPersistenceManager implements IListsPersistenceManager {
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

class _DummyCrudOperations extends ListsCrudOperations {
  _DummyCrudOperations(ILogger logger, ListsStateManager stateManager)
      : super(
          persistence: _DummyPersistenceManager(),
          validator: ListsValidationService(),
          filterManager: ListsFilterManager(),
          stateManager: stateManager,
          logger: logger,
        );
}

class _LoggerAdapter implements ILogger {
  final LoggerService logger;

  _LoggerAdapter(this.logger);

  @override
  void debug(String message, {String? context, String? correlationId, dynamic data}) {
    logger.debug(message, context: context ?? 'App');
  }

  @override
  void info(String message, {String? context, String? correlationId, dynamic data}) {
    logger.info(message, context: context ?? 'App');
  }

  @override
  void warning(String message, {String? context, String? correlationId, dynamic data}) {
    logger.warning(message, context: context ?? 'App');
  }

  @override
  void error(String message, {String? context, String? correlationId, dynamic error, StackTrace? stackTrace}) {
    logger.error(message, context: context ?? 'App', error: error);
  }

  @override
  void fatal(String message, {String? context, String? correlationId, dynamic error, StackTrace? stackTrace}) {
    logger.error('[FATAL] $message', context: context ?? 'App', error: error);
  }

  @override
  void performance(String operation, Duration duration, {String? context, String? correlationId, Map<String, dynamic>? metrics}) {
    logger.debug('[$operation] ${duration.inMilliseconds}ms', context: context ?? 'Performance');
  }

  @override
  void userAction(String action, {String? context, String? correlationId, Map<String, dynamic>? properties}) {
    logger.debug('[UserAction] $action', context: context ?? 'UserAction');
  }
}
