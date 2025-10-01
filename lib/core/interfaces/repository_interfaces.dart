/// Repository Interfaces following SOLID principles
///
/// Interface Segregation: Each interface has a single responsibility
/// Dependency Inversion: High-level modules depend on these abstractions

import 'application_interfaces.dart';

// ═══════════════════════════════════════════════════════════════════════════
// BASE REPOSITORY INTERFACES (ISP)
// ═══════════════════════════════════════════════════════════════════════════

/// Basic read operations interface
abstract class ReadOnlyRepository<T, TId> extends ReadableService<T, TId> {}

/// Basic write operations interface
abstract class WriteOnlyRepository<T, TId> extends WritableService<T, TId> {}

/// Full CRUD repository interface (composition of focused interfaces)
abstract class CrudRepository<T, TId>
    implements ReadOnlyRepository<T, TId>, WriteOnlyRepository<T, TId> {}

/// Repository with search capabilities
abstract class SearchableRepository<T, TId>
    implements CrudRepository<T, TId>, SearchableService<T> {}

/// Repository with caching capabilities
abstract class CachedRepository<T, TId>
    implements SearchableRepository<T, TId>, CacheableService<T, TId> {}

// ═══════════════════════════════════════════════════════════════════════════
// SPECIALIZED REPOSITORY INTERFACES (SRP)
// ═══════════════════════════════════════════════════════════════════════════

/// Transaction support interface
abstract class TransactionalRepository {
  Future<T> executeInTransaction<T>(Future<T> Function() operation);
  Future<void> beginTransaction();
  Future<void> commitTransaction();
  Future<void> rollbackTransaction();
}

/// Batch operations interface
abstract class BatchRepository<T, TId> {
  Future<List<TId>> createBatch(List<T> entities);
  Future<void> updateBatch(List<T> entities);
  Future<void> deleteBatch(List<TId> ids);
  Future<List<T>> getBatch(List<TId> ids);
}

/// Pagination support interface
abstract class PaginatedRepository<T> {
  Future<PagedResult<T>> getPage(int pageNumber, int pageSize);
  Future<PagedResult<T>> searchPage(String query, int pageNumber, int pageSize);
}

/// Audit trail interface
abstract class AuditableRepository<T, TId> {
  Future<List<AuditEntry>> getAuditTrail(TId id);
  Future<void> recordAuditEntry(TId id, String action, Map<String, dynamic> changes);
}

/// Soft delete interface
abstract class SoftDeleteRepository<T, TId> {
  Future<void> softDelete(TId id);
  Future<void> restore(TId id);
  Future<List<T>> getDeleted();
  Future<void> permanentDelete(TId id);
}

// ═══════════════════════════════════════════════════════════════════════════
// DOMAIN-SPECIFIC REPOSITORY INTERFACES (SRP)
// ═══════════════════════════════════════════════════════════════════════════

/// List-specific repository operations
abstract class CustomListRepositoryInterface
    implements CachedRepository<CustomList, String>,
               BatchRepository<CustomList, String>,
               PaginatedRepository<CustomList> {
  Future<List<CustomList>> getListsByType(String type);
  Future<List<CustomList>> getListsByStatus(String status);
  Future<List<CustomList>> getRecentLists(int limit);
  Future<int> getListsCount();
}

/// List item-specific repository operations
abstract class ListItemRepositoryInterface
    implements CachedRepository<ListItem, String>,
               BatchRepository<ListItem, String> {
  Future<List<ListItem>> getItemsByListId(String listId);
  Future<List<ListItem>> getItemsByPriority(double minPriority);
  Future<List<ListItem>> getCompletedItems(String listId);
  Future<List<ListItem>> getPendingItems(String listId);
  Future<void> moveItem(String itemId, String targetListId);
  Future<void> reorderItems(String listId, List<String> itemIds);
}

/// Task-specific repository operations
abstract class TaskRepositoryInterface
    implements CachedRepository<Task, String> {
  Future<List<Task>> getTasksByDueDate(DateTime date);
  Future<List<Task>> getOverdueTasks();
  Future<List<Task>> getTasksByTag(String tag);
  Future<void> markAsCompleted(String taskId);
  Future<void> markAsPending(String taskId);
}

/// Habit-specific repository operations
abstract class HabitRepositoryInterface
    implements CachedRepository<Habit, String> {
  Future<List<Habit>> getActiveHabits();
  Future<List<Habit>> getHabitsByCategory(String category);
  Future<void> recordHabitCompletion(String habitId, DateTime date);
  Future<List<HabitCompletion>> getHabitCompletions(String habitId, DateRange range);
  Future<HabitStats> getHabitStats(String habitId);
}

// ═══════════════════════════════════════════════════════════════════════════
// SUPPORT CLASSES
// ═══════════════════════════════════════════════════════════════════════════

/// Paginated result wrapper
class PagedResult<T> {
  final List<T> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final bool hasNext;
  final bool hasPrevious;

  const PagedResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.hasNext,
    required this.hasPrevious,
  });
}

/// Audit entry for tracking changes
class AuditEntry {
  final String id;
  final String entityId;
  final String action;
  final Map<String, dynamic> changes;
  final String userId;
  final DateTime timestamp;

  const AuditEntry({
    required this.id,
    required this.entityId,
    required this.action,
    required this.changes,
    required this.userId,
    required this.timestamp,
  });
}

/// Date range class
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({
    required this.start,
    required this.end,
  });
}

/// Placeholder classes (to be replaced with actual implementations)
class CustomList {}
class ListItem {}
class Task {}
class Habit {}
class HabitCompletion {}
class HabitStats {}