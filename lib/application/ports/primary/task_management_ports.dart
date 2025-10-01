/// HEXAGONAL ARCHITECTURE - PRIMARY PORTS
/// Task Management Use Case Interfaces
///
/// Primary ports define the use cases that drive our application.
/// These are the interfaces that the external world uses to interact
/// with our Task Management domain.
///
/// PRIMARY PORTS = "Driving" side of the hexagon (UI, API, CLI, etc.)

import '../../../domain/models/core/entities/task.dart';
import '../../../domain/core/value_objects/export.dart';

/// Task Creation Port
/// Defines the contract for creating new tasks
abstract class ITaskCreationPort {
  /// Creates a new task with the provided information
  Future<Task> createTask({
    required String title,
    String? description,
    String? category,
    DateTime? dueDate,
    Priority? priority,
  });

  /// Creates a task from a list item for prioritization
  Future<Task> createTaskFromListItem(String listItemId);

  /// Validates task creation data
  bool validateTaskData({
    required String title,
    String? description,
    DateTime? dueDate,
  });
}

/// Task Query Port
/// Defines the contract for retrieving tasks
abstract class ITaskQueryPort {
  /// Gets all tasks for the current user
  Future<List<Task>> getAllTasks();

  /// Gets tasks filtered by completion status
  Future<List<Task>> getTasksByStatus(bool isCompleted);

  /// Gets tasks by category
  Future<List<Task>> getTasksByCategory(String category);

  /// Gets tasks due within a date range
  Future<List<Task>> getTasksByDateRange(DateRange dateRange);

  /// Gets a specific task by ID
  Future<Task?> getTaskById(String taskId);

  /// Searches tasks by title or description
  Future<List<Task>> searchTasks(String query);
}

/// Task Update Port
/// Defines the contract for updating existing tasks
abstract class ITaskUpdatePort {
  /// Updates task information
  Future<Task> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? category,
    DateTime? dueDate,
    Priority? priority,
  });

  /// Marks a task as completed
  Future<Task> completeTask(String taskId);

  /// Marks a task as incomplete
  Future<Task> uncompleteTask(String taskId);

  /// Updates task priority
  Future<Task> updateTaskPriority(String taskId, Priority priority);
}

/// Task Deletion Port
/// Defines the contract for removing tasks
abstract class ITaskDeletionPort {
  /// Deletes a specific task
  Future<void> deleteTask(String taskId);

  /// Deletes all completed tasks
  Future<void> deleteCompletedTasks();

  /// Deletes all tasks (with confirmation)
  Future<void> deleteAllTasks({required bool confirmed});
}

/// Task Prioritization Port
/// Defines the contract for task prioritization and ELO scoring
abstract class ITaskPrioritizationPort {
  /// Gets two tasks for prioritization duel
  Future<List<Task>> getTasksForDuel();

  /// Updates ELO scores after a duel result
  Future<void> updateEloScoresFromDuel({
    required String winnerTaskId,
    required String loserTaskId,
  });

  /// Gets tasks sorted by ELO score
  Future<List<Task>> getTasksByEloScore({bool descending = true});

  /// Resets all ELO scores to default
  Future<void> resetAllEloScores();
}

/// Task Analytics Port
/// Defines the contract for task analytics and insights
abstract class ITaskAnalyticsPort {
  /// Gets completion statistics for a date range
  Future<Map<String, dynamic>> getCompletionStats(DateRange dateRange);

  /// Gets category distribution
  Future<Map<String, int>> getCategoryDistribution();

  /// Gets productivity trends
  Future<List<Map<String, dynamic>>> getProductivityTrends(DateRange dateRange);

  /// Gets ELO score distribution
  Future<Map<String, dynamic>> getEloDistribution();
}

/// Combined Task Management Port
/// Aggregates all task-related ports for convenience
abstract class ITaskManagementPort
    implements ITaskCreationPort,
               ITaskQueryPort,
               ITaskUpdatePort,
               ITaskDeletionPort,
               ITaskPrioritizationPort,
               ITaskAnalyticsPort {

  /// Port metadata
  String get portName => 'TaskManagement';
  String get version => '1.0.0';

  /// Health check for the port
  Future<bool> isHealthy();

  /// Initializes the port
  Future<void> initialize();

  /// Disposes resources used by the port
  Future<void> dispose();
}