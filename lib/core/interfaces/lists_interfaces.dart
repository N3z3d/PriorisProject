/// SOLID Architecture Interfaces for Lists Management
///
/// This file defines the core interfaces that enforce SOLID principles
/// for the lists management system. Each interface has a single responsibility
/// and follows ISP (Interface Segregation Principle) to avoid forcing clients
/// to depend on methods they don't use.

import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/pages/lists/models/lists_state.dart';

/// ISP-compliant persistence interface
/// RESPONSIBILITY: Pure persistence operations without business logic
abstract class IListsPersistenceService {
  /// Retrieves all lists from persistence layer
  Future<List<CustomList>> getAllLists();

  /// Retrieves a specific list by ID
  Future<CustomList?> getListById(String listId);

  /// Saves or updates a list
  Future<void> saveList(CustomList list);

  /// Deletes a list by ID
  Future<void> deleteList(String listId);

  /// Retrieves items for a specific list
  Future<List<ListItem>> getItemsByListId(String listId);

  /// Saves or updates an item
  Future<void> saveItem(ListItem item);

  /// Updates an existing item
  Future<void> updateItem(ListItem item);

  /// Deletes an item by ID
  Future<void> deleteItem(String itemId);

  /// Verifies persistence integrity
  Future<bool> verifyPersistence(String id);

  /// Clears all data
  Future<void> clearAllData();

  /// Forces reload from persistence
  Future<void> forceReload();
}

/// ISP-compliant transaction management interface
/// RESPONSIBILITY: Handling transactions, rollbacks, and data integrity
abstract class IListsTransactionManager {
  /// Executes operation with transaction support
  Future<T> executeTransaction<T>(Future<T> Function() operation);

  /// Executes operation with rollback capability
  Future<T> executeWithRollback<T>(
    Future<T> Function() operation,
    Future<void> Function() rollback,
  );

  /// Verifies operation success
  Future<bool> verifyOperation(String operationId, String entityId);

  /// Handles rollback for failed operations
  Future<void> rollback(List<dynamic> entitiesToRollback);

  /// Executes bulk operations with transaction support
  Future<void> executeBulkTransaction(
    List<Future<void> Function()> operations,
  );
}

/// ISP-compliant error handling interface
/// RESPONSIBILITY: Centralized error handling and recovery
abstract class IListsErrorHandler {
  /// Handles error with context
  void handleError(dynamic error, String context);

  /// Handles error with recovery strategy
  Future<T?> handleErrorWithRecovery<T>(
    dynamic error,
    String context,
    Future<T> Function()? recovery,
  );

  /// Checks if error is recoverable
  bool isRecoverableError(dynamic error);

  /// Gets user-friendly error message
  String getUserFriendlyMessage(dynamic error);

  /// Logs error for monitoring
  void logError(dynamic error, String context, StackTrace? stackTrace);
}

/// ISP-compliant loading state interface
/// RESPONSIBILITY: Managing loading states and execution context
abstract class IListsLoadingManager {
  /// Executes operation with loading state management
  Future<T> executeWithLoading<T>(Future<T> Function() operation);

  /// Sets loading state
  void setLoading(bool isLoading);

  /// Gets current loading state
  bool get isLoading;

  /// Checks if operations can be executed safely
  bool get canExecute;
}

/// Interface for managing lists state following SRP
/// RESPONSIBILITY: Maintain and expose lists state immutably
abstract class IListsStateManager {
  /// Current lists state
  List<CustomList> get lists;
  List<CustomList> get filteredLists;
  String get searchQuery;
  ListType? get selectedType;
  bool get showCompleted;
  bool get showInProgress;
  String? get selectedDateFilter;
  SortOption get sortOption;
  bool get isLoading;
  String? get error;

  /// State update methods
  void updateLists(List<CustomList> lists);
  void updateFilteredLists(List<CustomList> filteredLists);
  void updateSearchQuery(String query);
  void updateTypeFilter(ListType? type);
  void updateShowCompleted(bool show);
  void updateShowInProgress(bool show);
  void updateDateFilter(String? filter);
  void updateSortOption(SortOption option);
  void setLoading(bool isLoading);
  void setError(String? error);

  /// State stream for reactive updates
  Stream<ListsStateSnapshot> get stateStream;
}

/// Interface for CRUD operations following SRP
/// RESPONSIBILITY: Handle all create, read, update, delete operations
abstract class IListsCrudOperations {
  /// List operations
  Future<void> createList(CustomList list);
  Future<void> updateList(CustomList list);
  Future<void> deleteList(String listId);
  Future<List<CustomList>> loadAllLists();

  /// Item operations
  Future<void> addItemToList(String listId, ListItem item);
  Future<void> addMultipleItemsToList(String listId, List<String> itemTitles);
  Future<void> updateListItem(String listId, ListItem item);
  Future<void> removeItemFromList(String listId, String itemId);

  /// Data management
  Future<void> clearAllData();
  Future<void> forceReloadFromPersistence();
}

/// Interface for validation following SRP
/// RESPONSIBILITY: Validate operations before execution
abstract class IListsValidationService {
  /// List validation
  ValidationResult validateListCreation(CustomList list);
  ValidationResult validateListUpdate(CustomList list);
  ValidationResult validateListDeletion(String listId);

  /// Item validation
  ValidationResult validateItemCreation(ListItem item);
  ValidationResult validateItemUpdate(ListItem item);
  ValidationResult validateBulkItemCreation(List<String> itemTitles);

  /// Data validation
  ValidationResult validateDataClearing();
}

/// Interface for event dispatching following SRP
/// RESPONSIBILITY: Handle domain events and notifications
abstract class IListsEventDispatcher {
  /// Event dispatching
  void dispatchListCreated(CustomList list);
  void dispatchListUpdated(CustomList list);
  void dispatchListDeleted(String listId);
  void dispatchItemAdded(ListItem item);
  void dispatchItemUpdated(ListItem item);
  void dispatchItemRemoved(String itemId);
  void dispatchDataCleared();
  void dispatchError(String error);

  /// Event streams
  Stream<ListsEvent> get eventStream;
}

/// Interface for filtering and sorting following SRP
/// RESPONSIBILITY: Apply filters and sorting logic
abstract class IListsFilterService {
  /// Filter operations
  List<CustomList> applyFilters(
    List<CustomList> lists, {
    String? searchQuery,
    ListType? selectedType,
    bool? showCompleted,
    bool? showInProgress,
    String? selectedDateFilter,
    SortOption? sortOption,
  });

  /// Individual filter methods
  List<CustomList> applySearchFilter(List<CustomList> lists, String query);
  List<CustomList> applyTypeFilter(List<CustomList> lists, ListType type);
  List<CustomList> applyStatusFilter(List<CustomList> lists, bool showCompleted, bool showInProgress);
  List<CustomList> applyDateFilter(List<CustomList> lists, String dateFilter);
  List<CustomList> applySorting(List<CustomList> lists, SortOption sortOption);
}

/// Immutable state snapshot for reactive programming
class ListsStateSnapshot {
  final List<CustomList> lists;
  final List<CustomList> filteredLists;
  final String searchQuery;
  final ListType? selectedType;
  final bool showCompleted;
  final bool showInProgress;
  final String? selectedDateFilter;
  final SortOption sortOption;
  final bool isLoading;
  final String? error;

  const ListsStateSnapshot({
    required this.lists,
    required this.filteredLists,
    required this.searchQuery,
    this.selectedType,
    required this.showCompleted,
    required this.showInProgress,
    this.selectedDateFilter,
    required this.sortOption,
    required this.isLoading,
    this.error,
  });

  /// Create copy with changes
  ListsStateSnapshot copyWith({
    List<CustomList>? lists,
    List<CustomList>? filteredLists,
    String? searchQuery,
    ListType? selectedType,
    bool? showCompleted,
    bool? showInProgress,
    String? selectedDateFilter,
    SortOption? sortOption,
    bool? isLoading,
    String? error,
  }) {
    return ListsStateSnapshot(
      lists: lists ?? this.lists,
      filteredLists: filteredLists ?? this.filteredLists,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedType: selectedType ?? this.selectedType,
      showCompleted: showCompleted ?? this.showCompleted,
      showInProgress: showInProgress ?? this.showInProgress,
      selectedDateFilter: selectedDateFilter ?? this.selectedDateFilter,
      sortOption: sortOption ?? this.sortOption,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Validation result for operations
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.warnings = const [],
  });

  factory ValidationResult.valid() => const ValidationResult(isValid: true);

  factory ValidationResult.invalid(String message) =>
      ValidationResult(isValid: false, errorMessage: message);

  factory ValidationResult.withWarnings(List<String> warnings) =>
      ValidationResult(isValid: true, warnings: warnings);
}

/// Domain events for lists operations
abstract class ListsEvent {
  final DateTime timestamp;
  final String eventId;

  ListsEvent({DateTime? timestamp, String? eventId})
      : timestamp = timestamp ?? DateTime.now(),
        eventId = eventId ?? DateTime.now().microsecondsSinceEpoch.toString();
}

class ListCreatedEvent extends ListsEvent {
  final CustomList list;
  ListCreatedEvent(this.list);
}

class ListUpdatedEvent extends ListsEvent {
  final CustomList list;
  ListUpdatedEvent(this.list);
}

class ListDeletedEvent extends ListsEvent {
  final String listId;
  ListDeletedEvent(this.listId);
}

class ItemAddedEvent extends ListsEvent {
  final ListItem item;
  ItemAddedEvent(this.item);
}

class ItemUpdatedEvent extends ListsEvent {
  final ListItem item;
  ItemUpdatedEvent(this.item);
}

class ItemRemovedEvent extends ListsEvent {
  final String itemId;
  ItemRemovedEvent(this.itemId);
}

class DataClearedEvent extends ListsEvent {}

class ErrorOccurredEvent extends ListsEvent {
  final String error;
  ErrorOccurredEvent(this.error);
}