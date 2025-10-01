/// HEXAGONAL ARCHITECTURE - SECONDARY PORTS
/// Persistence Abstraction Interfaces
///
/// Secondary ports define contracts for external dependencies.
/// These are the "driven" side of the hexagon (databases, APIs, etc.)
///
/// SECONDARY PORTS = Infrastructure abstractions

import '../../../domain/models/core/entities/task.dart';
import '../../../domain/models/core/entities/custom_list.dart';
import '../../../domain/models/core/entities/list_item.dart';
import '../../../domain/models/core/entities/habit.dart';

/// Generic Repository Port
/// Base contract for all persistence operations
abstract class IRepositoryPort<T, ID> {
  Future<T> save(T entity);
  Future<T?> findById(ID id);
  Future<List<T>> findAll();
  Future<void> deleteById(ID id);
  Future<bool> existsById(ID id);
  Future<int> count();
}

/// Task Persistence Port
/// Specific contract for task persistence
abstract class ITaskPersistencePort extends IRepositoryPort<Task, String> {
  Future<List<Task>> findByStatus(bool isCompleted);
  Future<List<Task>> findByCategory(String category);
  Future<List<Task>> findByDateRange(DateTime start, DateTime end);
  Future<void> updateEloScores(List<Task> tasks);
  Future<List<Task>> findByEloRange(double minElo, double maxElo);
}

/// List Persistence Port
/// Contract for list and list item persistence
abstract class IListPersistencePort extends IRepositoryPort<CustomList, String> {
  Future<List<CustomList>> findByType(String type);
  Future<List<ListItem>> findItemsByListId(String listId);
  Future<ListItem> saveListItem(ListItem item);
  Future<void> deleteListItem(String itemId);
  Future<void> moveItemBetweenLists(String itemId, String fromListId, String toListId);
}

/// Habit Persistence Port
/// Contract for habit data persistence
abstract class IHabitPersistencePort extends IRepositoryPort<Habit, String> {
  Future<List<Habit>> findActiveHabits();
  Future<List<Habit>> findHabitsByCategory(String category);
  Future<void> recordHabitCompletion(String habitId, DateTime completionDate);
  Future<Map<String, dynamic>> getHabitStatistics(String habitId);
}

/// Cache Port
/// Contract for caching operations
abstract class ICachePort<K, V> {
  Future<void> put(K key, V value, {Duration? ttl});
  Future<V?> get(K key);
  Future<bool> containsKey(K key);
  Future<void> remove(K key);
  Future<void> clear();
  Future<Map<String, dynamic>> getStatistics();
}

/// Event Store Port
/// Contract for event sourcing/CQRS
abstract class IEventStorePort {
  Future<void> saveEvents(String aggregateId, List<Map<String, dynamic>> events);
  Future<List<Map<String, dynamic>>> getEvents(String aggregateId);
  Future<void> createSnapshot(String aggregateId, Map<String, dynamic> snapshot);
}

/// Notification Port
/// Contract for external notifications
abstract class INotificationPort {
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  });

  Future<void> scheduleNotification({
    required String userId,
    required String title,
    required String message,
    required DateTime scheduledTime,
    Map<String, dynamic>? data,
  });
}

/// Cloud Sync Port
/// Contract for cloud synchronization
abstract class ICloudSyncPort {
  Future<void> syncToCloud(String userId);
  Future<void> syncFromCloud(String userId);
  Future<bool> isCloudAvailable();
  Future<DateTime?> getLastSyncTime(String userId);
}

/// Analytics Port
/// Contract for analytics and telemetry
abstract class IAnalyticsPort {
  Future<void> trackEvent(String eventName, Map<String, dynamic> properties);
  Future<void> trackUserAction(String userId, String action, Map<String, dynamic> context);
  Future<void> trackPerformance(String operation, Duration duration);
}