/// Enhanced persistence service using strategy pattern
/// Implements OCP principle by allowing new persistence strategies
/// without modifying existing code

import 'package:prioris/core/interfaces/lists_interfaces.dart';
import 'package:prioris/core/patterns/persistence_strategy.dart';
import 'package:prioris/core/patterns/persistence_strategy_factory.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';

/// Enhanced persistence service that uses strategy pattern
/// This service follows OCP by delegating to pluggable strategies
class EnhancedListsPersistenceService implements IListsPersistenceService {
  final PersistenceContext _context;
  final IStrategySelectionPolicy? _selectionPolicy;

  bool _isDisposed = false;

  EnhancedListsPersistenceService({
    required PersistenceContext context,
    IStrategySelectionPolicy? selectionPolicy,
  }) : _context = context,
       _selectionPolicy = selectionPolicy;

  /// Factory constructor for different environments
  static Future<EnhancedListsPersistenceService> createForEnvironment({
    required String environment,
    Map<String, dynamic>? dependencies,
  }) async {
    PersistenceContext context;
    IStrategySelectionPolicy? policy;

    switch (environment.toLowerCase()) {
      case 'test':
      case 'testing':
        context = await PersistenceStrategyFactory.createTestContext();
        policy = TestingStrategySelectionPolicy();
        break;

      case 'development':
      case 'dev':
        if (dependencies == null) {
          throw ArgumentError('Development environment requires dependencies');
        }
        context = await PersistenceStrategyFactory.createDevelopmentContext(
          listRepository: dependencies['listRepository'],
          itemRepository: dependencies['itemRepository'],
        );
        policy = SmartStrategySelectionPolicy();
        break;

      case 'production':
      case 'prod':
        if (dependencies == null) {
          throw ArgumentError('Production environment requires dependencies');
        }
        context = await PersistenceStrategyFactory.createProductionContext(
          adaptiveService: dependencies['adaptiveService'],
          localListRepository: dependencies['localListRepository'],
          localItemRepository: dependencies['localItemRepository'],
        );
        policy = SmartStrategySelectionPolicy();
        break;

      default:
        throw ArgumentError('Unknown environment: $environment');
    }

    return EnhancedListsPersistenceService(
      context: context,
      selectionPolicy: policy,
    );
  }

  /// Gets current strategy name
  String get currentStrategy => _context.currentStrategyName;

  /// Gets available strategies
  List<String> get availableStrategies => _context.availableStrategies;

  /// Switches to a different strategy
  Future<void> switchStrategy(String strategyName) async {
    if (_isDisposed) {
      throw StateError('Service has been disposed');
    }

    await _context.switchStrategy(strategyName);

    LoggerService.instance.info(
      'Switched to persistence strategy: $strategyName',
      context: 'EnhancedListsPersistenceService',
    );
  }

  /// Optimizes strategy selection based on context
  Future<void> optimizeStrategy({
    bool? isAuthenticated,
    bool? isOnline,
    bool? preferLocal,
  }) async {
    if (_selectionPolicy == null) {
      LoggerService.instance.debug(
        'No selection policy configured, skipping optimization',
        context: 'EnhancedListsPersistenceService',
      );
      return;
    }

    final context = <String, dynamic>{
      if (isAuthenticated != null) 'isAuthenticated': isAuthenticated,
      if (isOnline != null) 'isOnline': isOnline,
      if (preferLocal != null) 'preferLocal': preferLocal,
    };

    final recommendedStrategy = await _selectionPolicy!.selectStrategy(context);
    final strategyName = recommendedStrategy.toString().split('.').last;

    if (availableStrategies.contains(strategyName) &&
        currentStrategy != strategyName) {
      LoggerService.instance.info(
        'Optimizing strategy: $currentStrategy → $strategyName',
        context: 'EnhancedListsPersistenceService',
      );

      try {
        await switchStrategy(strategyName);
      } catch (e) {
        LoggerService.instance.warning(
          'Failed to switch to optimized strategy: $strategyName',
          context: 'EnhancedListsPersistenceService',
          error: e,
        );
      }
    }
  }

  @override
  Future<List<CustomList>> getAllLists() async {
    _ensureNotDisposed();

    return await _executeWithFallback((strategy) async {
      return await strategy.getAllLists();
    });
  }

  @override
  Future<CustomList?> getListById(String listId) async {
    _ensureNotDisposed();

    return await _executeWithFallback((strategy) async {
      return await strategy.getListById(listId);
    });
  }

  @override
  Future<void> saveList(CustomList list) async {
    _ensureNotDisposed();

    await _executeWithFallback((strategy) async {
      await strategy.saveList(list);
    });

    LoggerService.instance.debug(
      'List saved: ${list.name} (strategy: $currentStrategy)',
      context: 'EnhancedListsPersistenceService',
    );
  }

  @override
  Future<void> deleteList(String listId) async {
    _ensureNotDisposed();

    await _executeWithFallback((strategy) async {
      await strategy.deleteList(listId);
    });

    LoggerService.instance.debug(
      'List deleted: $listId (strategy: $currentStrategy)',
      context: 'EnhancedListsPersistenceService',
    );
  }

  @override
  Future<List<ListItem>> getItemsByListId(String listId) async {
    _ensureNotDisposed();

    return await _executeWithFallback((strategy) async {
      return await strategy.getItemsByListId(listId);
    });
  }

  @override
  Future<void> saveItem(ListItem item) async {
    _ensureNotDisposed();

    await _executeWithFallback((strategy) async {
      await strategy.saveItem(item);
    });

    LoggerService.instance.debug(
      'Item saved: ${item.title} (strategy: $currentStrategy)',
      context: 'EnhancedListsPersistenceService',
    );
  }

  @override
  Future<void> updateItem(ListItem item) async {
    _ensureNotDisposed();

    await _executeWithFallback((strategy) async {
      await strategy.updateItem(item);
    });

    LoggerService.instance.debug(
      'Item updated: ${item.title} (strategy: $currentStrategy)',
      context: 'EnhancedListsPersistenceService',
    );
  }

  @override
  Future<void> deleteItem(String itemId) async {
    _ensureNotDisposed();

    await _executeWithFallback((strategy) async {
      await strategy.deleteItem(itemId);
    });

    LoggerService.instance.debug(
      'Item deleted: $itemId (strategy: $currentStrategy)',
      context: 'EnhancedListsPersistenceService',
    );
  }

  @override
  Future<bool> verifyPersistence(String id) async {
    _ensureNotDisposed();

    return await _executeWithFallback((strategy) async {
      return await strategy.verifyPersistence(id);
    });
  }

  @override
  Future<void> clearAllData() async {
    _ensureNotDisposed();

    await _executeWithFallback((strategy) async {
      await strategy.clearAllData();
    });

    LoggerService.instance.info(
      'All data cleared (strategy: $currentStrategy)',
      context: 'EnhancedListsPersistenceService',
    );
  }

  @override
  Future<void> forceReload() async {
    _ensureNotDisposed();

    LoggerService.instance.debug(
      'Force reload requested (strategy: $currentStrategy)',
      context: 'EnhancedListsPersistenceService',
    );

    // Force reload by getting fresh data
    await getAllLists();
  }

  /// Executes operation with automatic fallback to alternative strategies
  Future<T> _executeWithFallback<T>(
    Future<T> Function(IPersistenceStrategy) operation,
  ) async {
    final fallbackStrategies = availableStrategies
        .where((strategy) => strategy != currentStrategy)
        .toList();

    return await _context.executeWithFallback(
      operation,
      fallbackStrategies: fallbackStrategies,
    );
  }

  /// Gets service statistics
  Map<String, dynamic> getStatistics() {
    return {
      'currentStrategy': currentStrategy,
      'availableStrategies': availableStrategies,
      'strategyCount': availableStrategies.length,
      'isDisposed': _isDisposed,
      'hasSelectionPolicy': _selectionPolicy != null,
    };
  }

  /// Ensures service is not disposed
  void _ensureNotDisposed() {
    if (_isDisposed) {
      throw StateError('Enhanced persistence service has been disposed');
    }
  }

  /// Disposes the service and all strategies
  Future<void> dispose() async {
    if (_isDisposed) return;

    _isDisposed = true;

    LoggerService.instance.debug(
      'Disposing enhanced persistence service',
      context: 'EnhancedListsPersistenceService',
    );

    try {
      await _context.dispose();
    } catch (e) {
      LoggerService.instance.error(
        'Error disposing persistence context',
        context: 'EnhancedListsPersistenceService',
        error: e,
      );
    }

    LoggerService.instance.debug(
      'Enhanced persistence service disposed',
      context: 'EnhancedListsPersistenceService',
    );
  }
}

/// Factory for creating enhanced persistence service with DI integration
class EnhancedPersistenceServiceFactory implements IServiceFactory<IListsPersistenceService> {
  final String _environment;
  final Map<String, dynamic>? _dependencies;

  EnhancedPersistenceServiceFactory({
    required String environment,
    Map<String, dynamic>? dependencies,
  }) : _environment = environment,
       _dependencies = dependencies;

  @override
  IListsPersistenceService create() {
    // This would typically be async, but IServiceFactory interface is sync
    // In a real implementation, you might need to modify the factory interface
    // or handle async creation differently
    throw UnimplementedError(
      'Use EnhancedListsPersistenceService.createForEnvironment() for async creation'
    );
  }

  /// Async factory method
  Future<IListsPersistenceService> createAsync() async {
    return await EnhancedListsPersistenceService.createForEnvironment(
      environment: _environment,
      dependencies: _dependencies,
    );
  }

  @override
  void dispose(IListsPersistenceService instance) {
    if (instance is EnhancedListsPersistenceService) {
      instance.dispose();
    }
  }
}