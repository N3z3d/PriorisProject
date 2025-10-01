/// **TASK ORCHESTRATION SERVICE** - CQRS Coordinator
///
/// **LOT 5** : Service orchestrateur qui remplace la God Class TaskApplicationService
/// **Responsabilité unique** : Coordination des Commands/Queries tâches uniquement
/// **Taille** : <200 lignes (contrainte CLAUDE.md respectée)
/// **Architecture** : CQRS + Coordinator Pattern + Dependency Injection

import '../commands/tasks/create_task_command.dart';
import '../commands/tasks/complete_task_command.dart';
import '../commands/tasks/update_task_command.dart';
import '../commands/tasks/duel_tasks_command.dart';
import '../commands/tasks/delete_task_command.dart';
import '../queries/tasks/get_task_query.dart';
import '../queries/tasks/get_tasks_query.dart';
import '../queries/tasks/get_todays_priorities_query.dart';
import '../queries/tasks/get_task_statistics_query.dart';
import 'application_service.dart';
import '../../domain/task/aggregates/task_aggregate.dart';
import '../../domain/task/repositories/task_repository.dart';
import '../../domain/task/services/task_elo_service.dart';

/// **Service d'orchestration des tâches**
///
/// **SRP** : Coordination uniquement - délègue aux Commands/Queries spécialisées
/// **CQRS** : Sépare clairement Commands (modification) et Queries (lecture)
/// **DIP** : Dépend d'abstractions (repositories et services injectés)
class TaskOrchestrationService extends ApplicationService {
  final TaskRepository _taskRepository;
  final TaskEloService _eloService;

  /// **Constructeur avec injection de dépendances** (DIP)
  TaskOrchestrationService(this._taskRepository, this._eloService);

  @override
  String get serviceName => 'TaskOrchestrationService';

  // === COMMANDS (Modifications) ===

  /// Orchestre la création d'une tâche
  Future<OperationResult<TaskAggregate>> createTask(CreateTaskCommand command) async {
    return await safeExecute(() async {
      command.validate();

      final task = TaskAggregate.create(
        title: command.title,
        description: command.description,
        category: command.category,
        dueDate: command.dueDate,
        initialElo: command.initialElo,
      );

      await _taskRepository.save(task);

      return OperationResult.success(
        task,
        message: 'Tâche créée avec succès',
        metadata: {
          'category': command.category,
          'hasDueDate': command.dueDate != null,
          'hasInitialElo': command.initialElo != null,
        },
      );
    }, 'createTask', aggregates: []);
  }

  /// Orchestre la completion d'une tâche
  Future<OperationResult<TaskAggregate>> completeTask(CompleteTaskCommand command) async {
    return await safeExecute(() async {
      command.validate();

      final task = await _taskRepository.findById(command.taskId);
      if (task == null) {
        throw BusinessValidationException(
          'Tâche non trouvée',
          ['La tâche avec l\'ID ${command.taskId} n\'existe pas'],
          operationName: 'completeTask',
        );
      }

      task.markCompleted(command.completedAt ?? DateTime.now());
      await _taskRepository.save(task);

      return OperationResult.success(
        task,
        message: 'Tâche complétée avec succès',
        metadata: {'completedAt': command.completedAt},
      );
    }, 'completeTask', aggregates: []);
  }

  /// Orchestre la mise à jour d'une tâche
  Future<OperationResult<TaskAggregate>> updateTask(UpdateTaskCommand command) async {
    return await safeExecute(() async {
      command.validate();

      final task = await _taskRepository.findById(command.taskId);
      if (task == null) {
        throw BusinessValidationException(
          'Tâche non trouvée',
          ['La tâche avec l\'ID ${command.taskId} n\'existe pas'],
          operationName: 'updateTask',
        );
      }

      if (command.title != null) task.updateTitle(command.title!);
      if (command.description != null) task.updateDescription(command.description);
      if (command.category != null) task.updateCategory(command.category);
      if (command.dueDate != null) task.updateDueDate(command.dueDate);

      await _taskRepository.save(task);

      return OperationResult.success(
        task,
        message: 'Tâche mise à jour avec succès',
      );
    }, 'updateTask', aggregates: []);
  }

  /// Orchestre le duel entre deux tâches
  Future<OperationResult<DuelResult>> duelTasks(DuelTasksCommand command) async {
    return await safeExecute(() async {
      command.validate();

      final task1 = await _taskRepository.findById(command.task1Id);
      final task2 = await _taskRepository.findById(command.task2Id);

      if (task1 == null || task2 == null) {
        throw BusinessValidationException(
          'Tâche(s) non trouvée(s)',
          ['Une ou plusieurs tâches n\'existent pas'],
          operationName: 'duelTasks',
        );
      }

      final result = await _eloService.processDuel(task1, task2);

      await _taskRepository.save(task1);
      await _taskRepository.save(task2);

      return OperationResult.success(
        result,
        message: 'Duel traité avec succès',
        metadata: {
          'winnerId': result.winnerId,
          'eloChanges': result.eloChanges,
        },
      );
    }, 'duelTasks', aggregates: []);
  }

  /// Orchestre la suppression d'une tâche
  Future<OperationResult<void>> deleteTask(DeleteTaskCommand command) async {
    return await safeExecute(() async {
      command.validate();

      final exists = await _taskRepository.exists(command.taskId);
      if (!exists) {
        throw BusinessValidationException(
          'Tâche non trouvée',
          ['La tâche avec l\'ID ${command.taskId} n\'existe pas'],
          operationName: 'deleteTask',
        );
      }

      await _taskRepository.delete(command.taskId);

      return OperationResult.success(
        null,
        message: 'Tâche supprimée avec succès',
      );
    }, 'deleteTask', aggregates: []);
  }

  // === QUERIES (Lectures) ===

  /// Orchestre la lecture d'une tâche
  Future<OperationResult<TaskAggregate>> getTask(GetTaskQuery query) async {
    return await safeExecute(() async {
      query.validate();

      final task = await _taskRepository.findById(query.taskId);
      if (task == null) {
        throw BusinessValidationException(
          'Tâche non trouvée',
          ['La tâche avec l\'ID ${query.taskId} n\'existe pas'],
          operationName: 'getTask',
        );
      }

      return OperationResult.success(task);
    }, 'getTask', aggregates: []);
  }

  /// Orchestre la lecture de plusieurs tâches avec filtres
  Future<OperationResult<List<TaskAggregate>>> getTasks(GetTasksQuery query) async {
    return await safeExecute(() async {
      query.validate();

      final tasks = await _taskRepository.findByFilters(
        category: query.category,
        completed: query.completed,
        priority: query.priority,
        dueDateRange: query.dueDateRange,
        limit: query.limit,
        searchText: query.searchText,
      );

      return OperationResult.success(
        tasks,
        message: '${tasks.length} tâches trouvées',
        metadata: {'count': tasks.length, 'hasFilters': query.category != null},
      );
    }, 'getTasks', aggregates: []);
  }

  /// Orchestre la lecture des priorités du jour
  Future<OperationResult<List<TaskAggregate>>> getTodaysPriorities(GetTodaysPrioritiesQuery query) async {
    return await safeExecute(() async {
      final today = DateTime.now();
      final tasks = await _taskRepository.findTodaysPriorities(today);

      return OperationResult.success(
        tasks,
        message: '${tasks.length} priorités pour aujourd\'hui',
        metadata: {'date': today.toIso8601String(), 'count': tasks.length},
      );
    }, 'getTodaysPriorities', aggregates: []);
  }

  /// Orchestre la lecture des statistiques de tâches
  Future<OperationResult<Map<String, dynamic>>> getTaskStatistics(GetTaskStatisticsQuery query) async {
    return await safeExecute(() async {
      final statistics = await _taskRepository.getStatistics(
        dateRange: query.dateRange,
      );

      return OperationResult.success(
        statistics,
        message: 'Statistiques calculées avec succès',
      );
    }, 'getTaskStatistics', aggregates: []);
  }
}