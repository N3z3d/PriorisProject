/// SOLID-compliant Dependency Injection container for Lists domain
/// Responsibility: Managing dependencies and factory patterns only
/// Follows DIP (Dependency Inversion Principle) throughout

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/core/interfaces/lists_interfaces.dart';
import 'package:prioris/application/services/lists_persistence_service.dart';
import 'package:prioris/application/services/lists_state_manager.dart';
import 'package:prioris/application/services/lists_transaction_manager.dart';
import 'package:prioris/application/services/lists_error_handler.dart';
import 'package:prioris/application/services/lists_loading_manager.dart';
import 'package:prioris/domain/services/persistence/adaptive_persistence_service.dart';
import 'package:prioris/domain/services/core/lists_filter_service.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/data/providers/repository_providers.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';

/// Configuration for dependency injection
enum DependencyMode {
  development,
  testing,
  production,
  adaptive,
}

/// Factory interface for creating services
abstract class IServiceFactory<T> {
  T create();
  void dispose(T instance);
}

/// Container for managing Lists domain dependencies
/// Implements singleton pattern with proper disposal
class ListsDependencyContainer {
  static ListsDependencyContainer? _instance;
  static final Map<Type, dynamic> _services = {};
  static final Map<Type, IServiceFactory> _factories = {};
  static DependencyMode _currentMode = DependencyMode.production;
  static bool _isInitialized = false;

  ListsDependencyContainer._();

  /// Gets singleton instance
  static ListsDependencyContainer get instance {
    _instance ??= ListsDependencyContainer._();
    return _instance!;
  }

  /// Initializes container with specified mode
  static Future<void> initialize({
    required DependencyMode mode,
    Map<Type, IServiceFactory>? customFactories,
  }) async {
    if (_isInitialized) {
      LoggerService.instance.warning(
        'DI Container already initialized, skipping...',
        context: 'ListsDependencyContainer',
      );
      return;
    }

    _currentMode = mode;

    LoggerService.instance.info(
      'Initializing DI Container in $mode mode',
      context: 'ListsDependencyContainer',
    );

    // Register default factories
    await _registerDefaultFactories();

    // Register custom factories if provided
    if (customFactories != null) {
      _factories.addAll(customFactories);
    }

    _isInitialized = true;

    LoggerService.instance.info(
      'DI Container initialized with ${_factories.length} factories',
      context: 'ListsDependencyContainer',
    );
  }

  /// Registers default service factories based on mode
  static Future<void> _registerDefaultFactories() async {
    switch (_currentMode) {
      case DependencyMode.development:
        await _registerDevelopmentFactories();
        break;
      case DependencyMode.testing:
        await _registerTestingFactories();
        break;
      case DependencyMode.production:
        await _registerProductionFactories();
        break;
      case DependencyMode.adaptive:
        await _registerAdaptiveFactories();
        break;
    }
  }

  /// Registers factories for development mode
  static Future<void> _registerDevelopmentFactories() async {
    _factories[IListsErrorHandler] = ListsErrorHandlerFactory();
    _factories[IListsLoadingManager] = ListsLoadingManagerFactory();
    _factories[IListsStateManager] = ListsStateManagerFactory();
    _factories[IListsFilterService] = ListsFilterServiceFactory();
    _factories[IListsPersistenceService] = LocalPersistenceServiceFactory();
    _factories[IListsTransactionManager] = ListsTransactionManagerFactory();
  }

  /// Registers factories for testing mode
  static Future<void> _registerTestingFactories() async {
    _factories[IListsErrorHandler] = MockErrorHandlerFactory();
    _factories[IListsLoadingManager] = MockLoadingManagerFactory();
    _factories[IListsStateManager] = MockStateManagerFactory();
    _factories[IListsFilterService] = MockFilterServiceFactory();
    _factories[IListsPersistenceService] = MockPersistenceServiceFactory();
    _factories[IListsTransactionManager] = MockTransactionManagerFactory();
  }

  /// Registers factories for production mode
  static Future<void> _registerProductionFactories() async {
    _factories[IListsErrorHandler] = ListsErrorHandlerFactory();
    _factories[IListsLoadingManager] = ListsLoadingManagerFactory();
    _factories[IListsStateManager] = ListsStateManagerFactory();
    _factories[IListsFilterService] = ListsFilterServiceFactory();
    _factories[IListsPersistenceService] = AdaptivePersistenceServiceFactory();
    _factories[IListsTransactionManager] = ListsTransactionManagerFactory();
  }

  /// Registers factories for adaptive mode
  static Future<void> _registerAdaptiveFactories() async {
    _factories[IListsErrorHandler] = ListsErrorHandlerFactory();
    _factories[IListsLoadingManager] = ListsLoadingManagerFactory();
    _factories[IListsStateManager] = ListsStateManagerFactory();
    _factories[IListsFilterService] = ListsFilterServiceFactory();
    _factories[IListsPersistenceService] = AdaptivePersistenceServiceFactory();
    _factories[IListsTransactionManager] = ListsTransactionManagerFactory();
  }

  /// Gets service instance (creates if doesn't exist)
  static T get<T>() {
    if (!_isInitialized) {
      throw StateError('DI Container not initialized. Call initialize() first.');
    }

    // Return existing instance if available
    if (_services.containsKey(T)) {
      return _services[T] as T;
    }

    // Create new instance using factory
    final factory = _factories[T];
    if (factory == null) {
      throw StateError('No factory registered for type $T');
    }

    final instance = factory.create() as T;
    _services[T] = instance;

    LoggerService.instance.debug(
      'Created service instance: $T',
      context: 'ListsDependencyContainer',
    );

    return instance;
  }

  /// Registers a custom factory
  static void registerFactory<T>(IServiceFactory<T> factory) {
    _factories[T] = factory;
    LoggerService.instance.debug(
      'Registered custom factory for: $T',
      context: 'ListsDependencyContainer',
    );
  }

  /// Registers a singleton instance
  static void registerSingleton<T>(T instance) {
    _services[T] = instance;
    LoggerService.instance.debug(
      'Registered singleton instance: $T',
      context: 'ListsDependencyContainer',
    );
  }

  /// Checks if service is registered
  static bool isRegistered<T>() {
    return _factories.containsKey(T) || _services.containsKey(T);
  }

  /// Disposes all services and clears container
  static void dispose() {
    LoggerService.instance.info(
      'Disposing DI Container with ${_services.length} services',
      context: 'ListsDependencyContainer',
    );

    // Dispose all services using their factories
    for (final entry in _services.entries) {
      final factory = _factories[entry.key];
      if (factory != null) {
        try {
          factory.dispose(entry.value);
        } catch (e) {
          LoggerService.instance.error(
            'Error disposing service: ${entry.key}',
            context: 'ListsDependencyContainer',
            error: e,
          );
        }
      }
    }

    // Clear all containers
    _services.clear();
    _factories.clear();
    _isInitialized = false;
    _instance = null;

    LoggerService.instance.info(
      'DI Container disposed successfully',
      context: 'ListsDependencyContainer',
    );
  }

  /// Gets container statistics
  static Map<String, dynamic> getStatistics() {
    return {
      'mode': _currentMode.toString(),
      'isInitialized': _isInitialized,
      'registeredFactories': _factories.length,
      'activeServices': _services.length,
      'serviceTypes': _services.keys.map((type) => type.toString()).toList(),
    };
  }
}

/// Concrete service factories following Factory pattern

/// Factory for Lists Error Handler
class ListsErrorHandlerFactory implements IServiceFactory<IListsErrorHandler> {
  @override
  IListsErrorHandler create() => ListsErrorHandler();

  @override
  void dispose(IListsErrorHandler instance) {
    // ListsErrorHandler doesn't need special disposal
  }
}

/// Factory for Lists Loading Manager
class ListsLoadingManagerFactory implements IServiceFactory<IListsLoadingManager> {
  @override
  IListsLoadingManager create() => ListsLoadingManager();

  @override
  void dispose(IListsLoadingManager instance) {
    if (instance is ListsLoadingManager) {
      instance.dispose();
    }
  }
}

/// Factory for Lists State Manager
class ListsStateManagerFactory implements IServiceFactory<IListsStateManager> {
  @override
  IListsStateManager create() => ListsStateManager();

  @override
  void dispose(IListsStateManager instance) {
    if (instance is ListsStateManager) {
      instance.dispose();
    }
  }
}

/// Factory for Lists Filter Service
class ListsFilterServiceFactory implements IServiceFactory<IListsFilterService> {
  @override
  IListsFilterService create() => ListsFilterService();

  @override
  void dispose(IListsFilterService instance) {
    // ListsFilterService doesn't need special disposal
  }
}

/// Factory for Local Persistence Service (Development/Testing)
class LocalPersistenceServiceFactory implements IServiceFactory<IListsPersistenceService> {
  @override
  IListsPersistenceService create() {
    // Create in-memory repositories for local development
    final localListRepo = InMemoryCustomListRepository();
    final localItemRepo = InMemoryListItemRepository();

    return ListsPersistenceService.local(localListRepo, localItemRepo);
  }

  @override
  void dispose(IListsPersistenceService instance) {
    // No special disposal needed for local service
  }
}

/// Factory for Adaptive Persistence Service (Production)
class AdaptivePersistenceServiceFactory implements IServiceFactory<IListsPersistenceService> {
  @override
  IListsPersistenceService create() {
    // In a real implementation, you'd get the adaptive service from providers
    // This is a placeholder that would be properly injected
    throw UnimplementedError(
      'AdaptivePersistenceService creation requires Riverpod providers. '
      'Use provider-based injection instead.'
    );
  }

  @override
  void dispose(IListsPersistenceService instance) {
    // Adaptive service disposal handled by Riverpod
  }
}

/// Factory for Lists Transaction Manager
class ListsTransactionManagerFactory implements IServiceFactory<IListsTransactionManager> {
  @override
  IListsTransactionManager create() {
    final persistenceService = ListsDependencyContainer.get<IListsPersistenceService>();
    return ListsTransactionManager(persistenceService: persistenceService);
  }

  @override
  void dispose(IListsTransactionManager instance) {
    // No special disposal needed
  }
}

/// Mock factories for testing

class MockErrorHandlerFactory implements IServiceFactory<IListsErrorHandler> {
  @override
  IListsErrorHandler create() => MockListsErrorHandler();

  @override
  void dispose(IListsErrorHandler instance) {}
}

class MockLoadingManagerFactory implements IServiceFactory<IListsLoadingManager> {
  @override
  IListsLoadingManager create() => MockListsLoadingManager();

  @override
  void dispose(IListsLoadingManager instance) {}
}

class MockStateManagerFactory implements IServiceFactory<IListsStateManager> {
  @override
  IListsStateManager create() => MockListsStateManager();

  @override
  void dispose(IListsStateManager instance) {}
}

class MockFilterServiceFactory implements IServiceFactory<IListsFilterService> {
  @override
  IListsFilterService create() => MockListsFilterService();

  @override
  void dispose(IListsFilterService instance) {}
}

class MockPersistenceServiceFactory implements IServiceFactory<IListsPersistenceService> {
  @override
  IListsPersistenceService create() => MockListsPersistenceService();

  @override
  void dispose(IListsPersistenceService instance) {}
}

class MockTransactionManagerFactory implements IServiceFactory<IListsTransactionManager> {
  @override
  IListsTransactionManager create() => MockListsTransactionManager();

  @override
  void dispose(IListsTransactionManager instance) {}
}

/// Mock implementations (placeholder - would be in test folder)
class MockListsErrorHandler implements IListsErrorHandler {
  @override
  void handleError(error, String context) {}

  @override
  Future<T?> handleErrorWithRecovery<T>(error, String context, Future<T> Function()? recovery) async => null;

  @override
  bool isRecoverableError(error) => true;

  @override
  String getUserFriendlyMessage(error) => 'Mock error';

  @override
  void logError(error, String context, StackTrace? stackTrace) {}
}

class MockListsLoadingManager implements IListsLoadingManager {
  @override
  Future<T> executeWithLoading<T>(Future<T> Function() operation) => operation();

  @override
  void setLoading(bool isLoading) {}

  @override
  bool get isLoading => false;

  @override
  bool get canExecute => true;
}

class MockListsStateManager implements IListsStateManager {
  @override
  List<CustomList> get lists => [];
  List<CustomList> get filteredLists => [];
  String get searchQuery => '';
  ListType? get selectedType => null;
  bool get showCompleted => true;
  bool get showInProgress => true;
  String? get selectedDateFilter => null;
  SortOption get sortOption => SortOption.NAME_ASC;
  bool get isLoading => false;
  String? get error => null;
  bool get isActive => true;
  Stream<ListsStateSnapshot> get stateStream => Stream.empty();

  void updateLists(List<CustomList> lists) {}
  void updateFilteredLists(List<CustomList> filteredLists) {}
  void updateSearchQuery(String query) {}
  void updateTypeFilter(ListType? type) {}
  void updateShowCompleted(bool show) {}
  void updateShowInProgress(bool show) {}
  void updateDateFilter(String? filter) {}
  void updateSortOption(SortOption option) {}
  void setLoading(bool isLoading) {}
  void setError(String? error) {}
  void dispose() {}
}

class MockListsFilterService implements IListsFilterService {
  @override
  List<CustomList> applyFilters(List<CustomList> lists, {
    String? searchQuery,
    ListType? selectedType,
    bool? showCompleted,
    bool? showInProgress,
    String? selectedDateFilter,
    SortOption? sortOption,
  }) => lists;

  @override
  List<CustomList> applySearchFilter(List<CustomList> lists, String query) => lists;
  List<CustomList> applyTypeFilter(List<CustomList> lists, ListType type) => lists;
  List<CustomList> applyStatusFilter(List<CustomList> lists, bool showCompleted, bool showInProgress) => lists;
  List<CustomList> applyDateFilter(List<CustomList> lists, String dateFilter) => lists;
  List<CustomList> applySorting(List<CustomList> lists, SortOption sortOption) => lists;
}

class MockListsPersistenceService implements IListsPersistenceService {
  @override
  Future<List<CustomList>> getAllLists() async => [];
  Future<CustomList?> getListById(String listId) async => null;
  Future<void> saveList(CustomList list) async {}
  Future<void> deleteList(String listId) async {}
  Future<List<ListItem>> getItemsByListId(String listId) async => [];
  Future<void> saveItem(ListItem item) async {}
  Future<void> updateItem(ListItem item) async {}
  Future<void> deleteItem(String itemId) async {}
  Future<bool> verifyPersistence(String id) async => true;
  Future<void> clearAllData() async {}
  Future<void> forceReload() async {}
}

class MockListsTransactionManager implements IListsTransactionManager {
  @override
  Future<T> executeTransaction<T>(Future<T> Function() operation) => operation();
  Future<T> executeWithRollback<T>(Future<T> Function() operation, Future<void> Function() rollback) => operation();
  Future<bool> verifyOperation(String operationId, String entityId) async => true;
  Future<void> rollback(List entitiesToRollback) async {}
  Future<void> executeBulkTransaction(List<Future<void> Function()> operations) async {
    for (final op in operations) await op();
  }
}