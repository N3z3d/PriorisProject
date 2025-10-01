/// Strategy pattern implementation for persistence modes
/// Follows OCP (Open/Closed Principle) by allowing new persistence strategies
/// without modifying existing code

import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';

/// Strategy interface for persistence operations
/// Follows ISP by defining only essential persistence operations
abstract class IPersistenceStrategy {
  /// Gets strategy name for identification
  String get strategyName;

  /// Checks if strategy is available/ready
  Future<bool> isAvailable();

  /// Initializes the strategy
  Future<void> initialize();

  /// Retrieves all lists
  Future<List<CustomList>> getAllLists();

  /// Retrieves a specific list by ID
  Future<CustomList?> getListById(String listId);

  /// Saves or updates a list
  Future<void> saveList(CustomList list);

  /// Deletes a list
  Future<void> deleteList(String listId);

  /// Retrieves items for a specific list
  Future<List<ListItem>> getItemsByListId(String listId);

  /// Saves an item
  Future<void> saveItem(ListItem item);

  /// Updates an item
  Future<void> updateItem(ListItem item);

  /// Deletes an item
  Future<void> deleteItem(String itemId);

  /// Verifies persistence integrity
  Future<bool> verifyPersistence(String id);

  /// Clears all data
  Future<void> clearAllData();

  /// Disposes strategy resources
  Future<void> dispose();
}

/// Context class that uses persistence strategies
/// Implements strategy pattern to delegate persistence operations
class PersistenceContext {
  IPersistenceStrategy _currentStrategy;
  final Map<String, IPersistenceStrategy> _availableStrategies = {};

  PersistenceContext(IPersistenceStrategy initialStrategy)
      : _currentStrategy = initialStrategy {
    _availableStrategies[initialStrategy.strategyName] = initialStrategy;
  }

  /// Gets current strategy name
  String get currentStrategyName => _currentStrategy.strategyName;

  /// Gets list of available strategy names
  List<String> get availableStrategies => _availableStrategies.keys.toList();

  /// Registers a new persistence strategy
  void registerStrategy(IPersistenceStrategy strategy) {
    _availableStrategies[strategy.strategyName] = strategy;
    LoggerService.instance.debug(
      'Registered persistence strategy: ${strategy.strategyName}',
      context: 'PersistenceContext',
    );
  }

  /// Switches to a different persistence strategy
  Future<void> switchStrategy(String strategyName) async {
    final newStrategy = _availableStrategies[strategyName];
    if (newStrategy == null) {
      throw ArgumentError('Strategy not found: $strategyName');
    }

    if (newStrategy == _currentStrategy) {
      LoggerService.instance.debug(
        'Already using strategy: $strategyName',
        context: 'PersistenceContext',
      );
      return;
    }

    LoggerService.instance.info(
      'Switching persistence strategy: ${_currentStrategy.strategyName} → $strategyName',
      context: 'PersistenceContext',
    );

    // Check if new strategy is available
    final isAvailable = await newStrategy.isAvailable();
    if (!isAvailable) {
      throw StateError('Strategy not available: $strategyName');
    }

    // Initialize new strategy
    await newStrategy.initialize();

    _currentStrategy = newStrategy;

    LoggerService.instance.info(
      'Successfully switched to strategy: $strategyName',
      context: 'PersistenceContext',
    );
  }

  /// Executes operation with fallback to alternative strategies
  Future<T> executeWithFallback<T>(
    Future<T> Function(IPersistenceStrategy) operation,
    {List<String>? fallbackStrategies}
  ) async {
    // Try current strategy first
    try {
      return await operation(_currentStrategy);
    } catch (e) {
      LoggerService.instance.warning(
        'Current strategy failed: ${_currentStrategy.strategyName}',
        context: 'PersistenceContext',
      );

      // Try fallback strategies if provided
      if (fallbackStrategies != null) {
        for (final strategyName in fallbackStrategies) {
          final strategy = _availableStrategies[strategyName];
          if (strategy != null && strategy != _currentStrategy) {
            try {
              LoggerService.instance.info(
                'Trying fallback strategy: $strategyName',
                context: 'PersistenceContext',
              );

              final isAvailable = await strategy.isAvailable();
              if (isAvailable) {
                return await operation(strategy);
              }
            } catch (fallbackError) {
              LoggerService.instance.warning(
                'Fallback strategy failed: $strategyName',
                context: 'PersistenceContext',
              );
              continue;
            }
          }
        }
      }

      // If all strategies failed, rethrow original error
      rethrow;
    }
  }

  // Delegate methods to current strategy

  Future<List<CustomList>> getAllLists() async {
    return await _currentStrategy.getAllLists();
  }

  Future<CustomList?> getListById(String listId) async {
    return await _currentStrategy.getListById(listId);
  }

  Future<void> saveList(CustomList list) async {
    await _currentStrategy.saveList(list);
  }

  Future<void> deleteList(String listId) async {
    await _currentStrategy.deleteList(listId);
  }

  Future<List<ListItem>> getItemsByListId(String listId) async {
    return await _currentStrategy.getItemsByListId(listId);
  }

  Future<void> saveItem(ListItem item) async {
    await _currentStrategy.saveItem(item);
  }

  Future<void> updateItem(ListItem item) async {
    await _currentStrategy.updateItem(item);
  }

  Future<void> deleteItem(String itemId) async {
    await _currentStrategy.deleteItem(itemId);
  }

  Future<bool> verifyPersistence(String id) async {
    return await _currentStrategy.verifyPersistence(id);
  }

  Future<void> clearAllData() async {
    await _currentStrategy.clearAllData();
  }

  /// Disposes all registered strategies
  Future<void> dispose() async {
    for (final strategy in _availableStrategies.values) {
      try {
        await strategy.dispose();
      } catch (e) {
        LoggerService.instance.error(
          'Error disposing strategy: ${strategy.strategyName}',
          context: 'PersistenceContext',
          error: e,
        );
      }
    }
    _availableStrategies.clear();
  }
}