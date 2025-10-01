/// HEXAGONAL ARCHITECTURE - APPLICATION SERVICE
/// Task Management Application Service
///
/// This service implements the primary ports for Task Management
/// and orchestrates domain operations. It acts as the coordinator
/// between the external world and the domain logic.
///
/// RESPONSIBILITIES:
/// - Implement primary port contracts
/// - Orchestrate domain services and aggregates
/// - Handle transaction boundaries
/// - Publish domain events
/// - Coordinate with other bounded contexts

import '../ports/primary/task_management_ports.dart';
import '../ports/secondary/persistence_ports.dart';
import '../../domain/models/core/entities/task.dart';
import '../../domain/core/value_objects/export.dart';
import '../../domain/task/aggregates/task_aggregate.dart';
import '../../domain/core/events/event_bus.dart';
import '../../domain/task/events/task_events.dart';

/// Task Management Application Service
///
/// Coordinates all task-related use cases following the Application Service pattern.
/// This service ensures proper transaction boundaries and event publication.
class TaskManagementService implements ITaskManagementPort {
  final ITaskPersistencePort _taskRepository;
  final EventBus _eventBus;

  TaskManagementService({
    required ITaskPersistencePort taskRepository,
    required EventBus eventBus,
  }) : _taskRepository = taskRepository,
       _eventBus = eventBus;

  @override
  String get portName => 'TaskManagement';

  @override
  String get version => '1.0.0';

  // ========== TASK CREATION ==========

  @override
  Future<Task> createTask({
    required String title,
    String? description,
    String? category,
    DateTime? dueDate,
    Priority? priority,
  }) async {
    // Validate input
    if (!validateTaskData(title: title, description: description, dueDate: dueDate)) {
      throw ArgumentError('Invalid task data provided');
    }

    // Create task aggregate
    final taskAggregate = TaskAggregate.create(
      title: title,
      description: description,
      category: category,
      dueDate: dueDate,
    );

    // Convert aggregate to Task entity
    final taskEntity = Task(
      id: taskAggregate.id,
      title: taskAggregate.title,
      description: taskAggregate.description,
      category: taskAggregate.category,
      eloScore: taskAggregate.eloScore.value,
      isCompleted: taskAggregate.isCompleted,
      createdAt: taskAggregate.createdAt,
      completedAt: taskAggregate.completedAt,
      dueDate: taskAggregate.dueDate,
    );

    // Persist the task
    final savedTask = await _taskRepository.save(taskEntity);

    // Publish domain events
    await _publishAggregateEvents(taskAggregate);

    return savedTask;
  }

  @override
  Future<Task> createTaskFromListItem(String listItemId) async {
    // This would typically involve calling the List Organization context
    // For now, we'll create a placeholder implementation
    throw UnimplementedError('Cross-context integration not yet implemented');
  }

  @override
  bool validateTaskData({
    required String title,
    String? description,
    DateTime? dueDate,
  }) {
    if (title.trim().isEmpty) return false;
    if (title.length > 200) return false;
    if (description != null && description.length > 1000) return false;
    if (dueDate != null && dueDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return false;
    }
    return true;
  }

  // ========== TASK QUERIES ==========

  @override
  Future<List<Task>> getAllTasks() => _taskRepository.findAll();

  @override
  Future<List<Task>> getTasksByStatus(bool isCompleted) =>
      _taskRepository.findByStatus(isCompleted);

  @override
  Future<List<Task>> getTasksByCategory(String category) =>
      _taskRepository.findByCategory(category);

  @override
  Future<List<Task>> getTasksByDateRange(DateRange dateRange) =>
      _taskRepository.findByDateRange(dateRange.start, dateRange.end);

  @override
  Future<Task?> getTaskById(String taskId) => _taskRepository.findById(taskId);

  @override
  Future<List<Task>> searchTasks(String query) async {
    // Simple search implementation - can be enhanced
    final allTasks = await _taskRepository.findAll();
    final lowercaseQuery = query.toLowerCase();

    return allTasks.where((task) {
      return task.title.toLowerCase().contains(lowercaseQuery) ||
             (task.description?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  // ========== TASK UPDATES ==========

  @override
  Future<Task> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? category,
    DateTime? dueDate,
    Priority? priority,
  }) async {
    final existingTask = await _taskRepository.findById(taskId);
    if (existingTask == null) {
      throw ArgumentError('Task not found: $taskId');
    }

    final taskAggregate = TaskAggregate.reconstitute(
      id: existingTask.id,
      title: existingTask.title,
      description: existingTask.description,
      eloScore: existingTask.eloScore,
      isCompleted: existingTask.isCompleted,
      createdAt: existingTask.createdAt,
      completedAt: existingTask.completedAt,
      category: existingTask.category,
      dueDate: existingTask.dueDate,
    );

    if (title != null) taskAggregate.updateTitle(title);
    if (description != null) taskAggregate.updateDescription(description);
    if (category != null) taskAggregate.updateCategory(category);
    if (dueDate != null) taskAggregate.updateDueDate(dueDate);

    final updatedTaskEntity = Task(
      id: taskAggregate.id,
      title: taskAggregate.title,
      description: taskAggregate.description,
      category: taskAggregate.category,
      eloScore: taskAggregate.eloScore.value,
      isCompleted: taskAggregate.isCompleted,
      createdAt: taskAggregate.createdAt,
      completedAt: taskAggregate.completedAt,
      dueDate: taskAggregate.dueDate,
    );
    final updatedTask = await _taskRepository.save(updatedTaskEntity);
    await _publishAggregateEvents(taskAggregate);

    return updatedTask;
  }

  @override
  Future<Task> completeTask(String taskId) async {
    final task = await _taskRepository.findById(taskId);
    if (task == null) throw ArgumentError('Task not found: $taskId');

    final taskAggregate = TaskAggregate.reconstitute(
      id: task.id,
      title: task.title,
      description: task.description,
      eloScore: task.eloScore,
      isCompleted: task.isCompleted,
      createdAt: task.createdAt,
      completedAt: task.completedAt,
      category: task.category,
      dueDate: task.dueDate,
    );
    taskAggregate.complete();

    final completedTaskEntity = Task(
      id: taskAggregate.id,
      title: taskAggregate.title,
      description: taskAggregate.description,
      category: taskAggregate.category,
      eloScore: taskAggregate.eloScore.value,
      isCompleted: taskAggregate.isCompleted,
      createdAt: taskAggregate.createdAt,
      completedAt: taskAggregate.completedAt,
      dueDate: taskAggregate.dueDate,
    );
    final completedTask = await _taskRepository.save(completedTaskEntity);
    await _publishAggregateEvents(taskAggregate);

    return completedTask;
  }

  @override
  Future<Task> uncompleteTask(String taskId) async {
    final task = await _taskRepository.findById(taskId);
    if (task == null) throw ArgumentError('Task not found: $taskId');

    final taskAggregate = TaskAggregate.reconstitute(
      id: task.id,
      title: task.title,
      description: task.description,
      eloScore: task.eloScore,
      isCompleted: task.isCompleted,
      createdAt: task.createdAt,
      completedAt: task.completedAt,
      category: task.category,
      dueDate: task.dueDate,
    );
    taskAggregate.reopen();

    final updatedTaskEntity = Task(
      id: taskAggregate.id,
      title: taskAggregate.title,
      description: taskAggregate.description,
      category: taskAggregate.category,
      eloScore: taskAggregate.eloScore.value,
      isCompleted: taskAggregate.isCompleted,
      createdAt: taskAggregate.createdAt,
      completedAt: taskAggregate.completedAt,
      dueDate: taskAggregate.dueDate,
    );
    final updatedTask = await _taskRepository.save(updatedTaskEntity);
    await _publishAggregateEvents(taskAggregate);

    return updatedTask;
  }

  @override
  Future<Task> updateTaskPriority(String taskId, Priority priority) async {
    return updateTask(taskId: taskId, priority: priority);
  }

  // ========== TASK DELETION ==========

  @override
  Future<void> deleteTask(String taskId) async {
    // Get task details before deletion for the event
    final task = await _taskRepository.findById(taskId);
    await _taskRepository.deleteById(taskId);

    // Create proper domain event
    if (task != null) {
      final deleteEvent = TaskDeletedEvent(
        taskId: taskId,
        title: task.title,
        wasCompleted: task.isCompleted,
        finalEloScore: task.eloScore,
        reason: 'Manual deletion',
      );
      await _eventBus.publish(deleteEvent);
    }
  }

  @override
  Future<void> deleteCompletedTasks() async {
    final completedTasks = await _taskRepository.findByStatus(true);
    for (final task in completedTasks) {
      await _taskRepository.deleteById(task.id);
    }

    // Create proper domain event
    final bulkDeleteEvent = TasksBulkDeletedEvent(
      deletedCount: completedTasks.length,
      deleteType: 'completed_only',
    );
    await _eventBus.publish(bulkDeleteEvent);
  }

  @override
  Future<void> deleteAllTasks({required bool confirmed}) async {
    if (!confirmed) throw ArgumentError('Deletion must be explicitly confirmed');

    final allTasks = await _taskRepository.findAll();
    for (final task in allTasks) {
      await _taskRepository.deleteById(task.id);
    }

    // Create proper domain event
    final bulkDeleteEvent = TasksBulkDeletedEvent(
      deletedCount: allTasks.length,
      deleteType: 'all_tasks',
    );
    await _eventBus.publish(bulkDeleteEvent);
  }

  // ========== PRIORITIZATION ==========

  @override
  Future<List<Task>> getTasksForDuel() async {
    final incompleteTasks = await _taskRepository.findByStatus(false);
    if (incompleteTasks.length < 2) return [];

    incompleteTasks.shuffle();
    return incompleteTasks.take(2).toList();
  }

  @override
  Future<void> updateEloScoresFromDuel({
    required String winnerTaskId,
    required String loserTaskId,
  }) async {
    final winner = await _taskRepository.findById(winnerTaskId);
    final loser = await _taskRepository.findById(loserTaskId);

    if (winner == null || loser == null) {
      throw ArgumentError('Tasks not found for ELO update');
    }

    // Create aggregates for ELO calculation
    final winnerAggregate = TaskAggregate.reconstitute(
      id: winner.id,
      title: winner.title,
      description: winner.description,
      eloScore: winner.eloScore,
      isCompleted: winner.isCompleted,
      createdAt: winner.createdAt,
      completedAt: winner.completedAt,
      category: winner.category,
      dueDate: winner.dueDate,
    );
    final loserAggregate = TaskAggregate.reconstitute(
      id: loser.id,
      title: loser.title,
      description: loser.description,
      eloScore: loser.eloScore,
      isCompleted: loser.isCompleted,
      createdAt: loser.createdAt,
      completedAt: loser.completedAt,
      category: loser.category,
      dueDate: loser.dueDate,
    );

    // Perform duel to update ELO scores
    winnerAggregate.duelAgainst(loserAggregate, true);

    // Convert back to entities and save
    final updatedWinner = Task(
      id: winnerAggregate.id,
      title: winnerAggregate.title,
      description: winnerAggregate.description,
      category: winnerAggregate.category,
      eloScore: winnerAggregate.eloScore.value,
      isCompleted: winnerAggregate.isCompleted,
      createdAt: winnerAggregate.createdAt,
      completedAt: winnerAggregate.completedAt,
      dueDate: winnerAggregate.dueDate,
    );
    final updatedLoser = Task(
      id: loserAggregate.id,
      title: loserAggregate.title,
      description: loserAggregate.description,
      category: loserAggregate.category,
      eloScore: loserAggregate.eloScore.value,
      isCompleted: loserAggregate.isCompleted,
      createdAt: loserAggregate.createdAt,
      completedAt: loserAggregate.completedAt,
      dueDate: loserAggregate.dueDate,
    );

    await _taskRepository.save(updatedWinner);
    await _taskRepository.save(updatedLoser);

    // Publish events from aggregates
    await _publishAggregateEvents(winnerAggregate);
    await _publishAggregateEvents(loserAggregate);
  }

  @override
  Future<List<Task>> getTasksByEloScore({bool descending = true}) async {
    final allTasks = await _taskRepository.findAll();
    allTasks.sort((a, b) => descending
        ? b.eloScore.compareTo(a.eloScore)
        : a.eloScore.compareTo(b.eloScore));
    return allTasks;
  }

  @override
  Future<void> resetAllEloScores() async {
    final allTasks = await _taskRepository.findAll();
    final resetTasks = allTasks.map((task) => task.copyWith(eloScore: 1200.0)).toList();
    for (final task in resetTasks) {
      await _taskRepository.save(task);
    }

    // Create proper domain event
    final resetEvent = TasksEloResetEvent(taskCount: allTasks.length);
    await _eventBus.publish(resetEvent);
  }

  // ========== ANALYTICS ==========

  @override
  Future<Map<String, dynamic>> getCompletionStats(DateRange dateRange) async {
    final tasksInRange = await _taskRepository.findByDateRange(dateRange.start, dateRange.end);
    final completedTasks = tasksInRange.where((t) => t.isCompleted).length;

    return {
      'total': tasksInRange.length,
      'completed': completedTasks,
      'completion_rate': tasksInRange.isEmpty ? 0.0 : completedTasks / tasksInRange.length,
      'period': {
        'start': dateRange.start.toIso8601String(),
        'end': dateRange.end.toIso8601String(),
      },
    };
  }

  @override
  Future<Map<String, int>> getCategoryDistribution() async {
    final allTasks = await _taskRepository.findAll();
    final distribution = <String, int>{};

    for (final task in allTasks) {
      final category = task.category ?? 'Uncategorized';
      distribution[category] = (distribution[category] ?? 0) + 1;
    }

    return distribution;
  }

  @override
  Future<List<Map<String, dynamic>>> getProductivityTrends(DateRange dateRange) async {
    // Simplified implementation - would typically use more sophisticated analytics
    final stats = await getCompletionStats(dateRange);
    return [stats];
  }

  @override
  Future<Map<String, dynamic>> getEloDistribution() async {
    final allTasks = await _taskRepository.findAll();
    final eloScores = allTasks.map((t) => t.eloScore).toList();

    if (eloScores.isEmpty) {
      return {'min': 0, 'max': 0, 'average': 0, 'median': 0};
    }

    eloScores.sort();
    return {
      'min': eloScores.first,
      'max': eloScores.last,
      'average': eloScores.reduce((a, b) => a + b) / eloScores.length,
      'median': eloScores[eloScores.length ~/ 2],
      'distribution': _calculateEloDistribution(eloScores),
    };
  }

  // ========== LIFECYCLE ==========

  @override
  Future<bool> isHealthy() async {
    try {
      await _taskRepository.count();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> initialize() async {
    // Initialization logic if needed
  }

  @override
  Future<void> dispose() async {
    // Cleanup logic if needed
  }

  // ========== PRIVATE HELPERS ==========

  Future<void> _publishAggregateEvents(TaskAggregate aggregate) async {
    if (aggregate.hasUncommittedEvents) {
      await _eventBus.publishAll(aggregate.uncommittedEvents);
      aggregate.markEventsAsCommitted();
    }
  }

  Map<String, int> _calculateEloDistribution(List<double> eloScores) {
    const ranges = {
      '800-1000': [800, 1000],
      '1000-1200': [1000, 1200],
      '1200-1400': [1200, 1400],
      '1400-1600': [1400, 1600],
      '1600-1800': [1600, 1800],
      '1800-2000': [1800, 2000],
      '2000+': [2000, double.infinity],
    };

    final distribution = <String, int>{};
    for (final entry in ranges.entries) {
      final count = eloScores.where((score) =>
          score >= entry.value[0] && score < entry.value[1]).length;
      distribution[entry.key] = count;
    }

    return distribution;
  }
}