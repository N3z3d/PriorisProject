import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

/// Core persistence strategy interface following Strategy Pattern
///
/// Defines contract for different persistence approaches (local, cloud, hybrid)
/// Respects Interface Segregation Principle by providing focused interface
abstract class IPersistenceStrategy {
  /// Strategy identifier for logging and debugging
  String get strategyName;

  /// Check if strategy is currently available/healthy
  Future<bool> isAvailable();

  // === List Operations ===

  /// Retrieve all lists using this strategy
  Future<List<CustomList>> getAllLists();

  /// Save a list using this strategy
  Future<void> saveList(CustomList list);

  /// Update an existing list using this strategy
  Future<void> updateList(CustomList list);

  /// Delete a list using this strategy
  Future<void> deleteList(String listId);

  /// Get a specific list by ID
  Future<CustomList?> getListById(String listId);

  // === List Item Operations ===

  /// Retrieve all items for a specific list
  Future<List<ListItem>> getItemsByListId(String listId);

  /// Save a new item using this strategy
  Future<void> saveItem(ListItem item);

  /// Update an existing item using this strategy
  Future<void> updateItem(ListItem item);

  /// Delete an item using this strategy
  Future<void> deleteItem(String itemId);

  /// Get a specific item by ID
  Future<ListItem?> getItemById(String itemId);

  // === Batch Operations ===

  /// Save multiple lists in a transaction-like manner
  Future<void> saveLists(List<CustomList> lists);

  /// Save multiple items in a transaction-like manner
  Future<void> saveItems(List<ListItem> items);

  // === Health & Maintenance ===

  /// Perform cleanup operations specific to this strategy
  Future<void> cleanup();

  /// Validate data integrity for this strategy
  Future<bool> validateIntegrity();
}

/// Extended interface for strategies that support synchronization
abstract class ISyncablePersistenceStrategy extends IPersistenceStrategy {
  /// Sync data from this strategy to another
  Future<void> syncTo(IPersistenceStrategy targetStrategy);

  /// Sync data from another strategy to this one
  Future<void> syncFrom(IPersistenceStrategy sourceStrategy);

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTime();

  /// Mark sync time
  Future<void> markSyncTime(DateTime syncTime);
}

/// Interface for strategies that support conflict resolution
abstract class IConflictResolvablePersistenceStrategy extends IPersistenceStrategy {
  /// Resolve conflicts between two lists
  CustomList resolveListConflict(CustomList existing, CustomList incoming);

  /// Resolve conflicts between two items
  ListItem resolveItemConflict(ListItem existing, ListItem incoming);

  /// Get conflict resolution strategy name
  String get conflictResolutionStrategy;
}

/// Configuration for persistence strategies
class PersistenceStrategyConfig {
  final bool enableRetry;
  final int maxRetries;
  final Duration retryDelay;
  final bool enableCaching;
  final Duration cacheExpiry;
  final bool enableLogging;

  const PersistenceStrategyConfig({
    this.enableRetry = true,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.enableCaching = false,
    this.cacheExpiry = const Duration(minutes: 5),
    this.enableLogging = true,
  });
}

/// Exception specific to persistence strategy operations
class PersistenceStrategyException implements Exception {
  final String message;
  final String strategyName;
  final Exception? originalException;

  const PersistenceStrategyException({
    required this.message,
    required this.strategyName,
    this.originalException,
  });

  @override
  String toString() => 'PersistenceStrategyException [$strategyName]: $message';
}