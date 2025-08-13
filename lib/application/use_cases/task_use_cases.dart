import '../services/application_service.dart';
import '../../domain/task/aggregates/task_aggregate.dart';
import '../../domain/task/repositories/task_repository.dart';
import '../../domain/task/services/task_elo_service.dart';
import '../../domain/core/value_objects/export.dart';
import '../../domain/core/specifications/export.dart';

/// Commands pour les cas d'usage des tâches
class CreateTaskCommand extends Command {
  final String title;
  final String? description;
  final String? category;
  final DateTime? dueDate;
  final EloScore? initialElo;

  CreateTaskCommand({
    required this.title,
    this.description,
    this.category,
    this.dueDate,
    this.initialElo,
  });

  @override
  void validate() {
    if (title.trim().isEmpty) {
      throw BusinessValidationException(
        'Le titre est requis',
        ['Le titre de la tâche ne peut pas être vide'],
        operationName: 'CreateTask',
      );
    }

    if (title.length > 200) {
      throw BusinessValidationException(
        'Le titre est trop long',
        ['Le titre ne peut pas dépasser 200 caractères'],
        operationName: 'CreateTask',
      );
    }

    if (description != null && description!.length > 1000) {
      throw BusinessValidationException(
        'La description est trop longue',
        ['La description ne peut pas dépasser 1000 caractères'],
        operationName: 'CreateTask',
      );
    }

    if (dueDate != null && dueDate!.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      throw BusinessValidationException(
        'Date d\'échéance invalide',
        ['La date d\'échéance ne peut pas être dans le passé'],
        operationName: 'CreateTask',
      );
    }
  }
}

class CompleteTaskCommand extends Command {
  final String taskId;
  final DateTime? completedAt;

  CompleteTaskCommand({
    required this.taskId,
    this.completedAt,
  });

  @override
  void validate() {
    if (taskId.trim().isEmpty) {
      throw BusinessValidationException(
        'ID de tâche requis',
        ['L\'identifiant de la tâche est requis'],
        operationName: 'CompleteTask',
      );
    }
  }
}

class UpdateTaskCommand extends Command {
  final String taskId;
  final String? title;
  final String? description;
  final String? category;
  final DateTime? dueDate;

  UpdateTaskCommand({
    required this.taskId,
    this.title,
    this.description,
    this.category,
    this.dueDate,
  });

  @override
  void validate() {
    if (taskId.trim().isEmpty) {
      throw BusinessValidationException(
        'ID de tâche requis',
        ['L\'identifiant de la tâche est requis'],
        operationName: 'UpdateTask',
      );
    }

    if (title != null && title!.trim().isEmpty) {
      throw BusinessValidationException(
        'Le titre ne peut pas être vide',
        ['Le titre de la tâche ne peut pas être vide'],
        operationName: 'UpdateTask',
      );
    }
  }
}

class DuelTasksCommand extends Command {
  final String task1Id;
  final String task2Id;

  DuelTasksCommand({
    required this.task1Id,
    required this.task2Id,
  });

  @override
  void validate() {
    if (task1Id.trim().isEmpty || task2Id.trim().isEmpty) {
      throw BusinessValidationException(
        'IDs de tâches requis',
        ['Les identifiants des deux tâches sont requis'],
        operationName: 'DuelTasks',
      );
    }

    if (task1Id == task2Id) {
      throw BusinessValidationException(
        'Tâches identiques',
        ['Une tâche ne peut pas se battre contre elle-même'],
        operationName: 'DuelTasks',
      );
    }
  }
}

class DeleteTaskCommand extends Command {
  final String taskId;

  DeleteTaskCommand({required this.taskId});

  @override
  void validate() {
    if (taskId.trim().isEmpty) {
      throw BusinessValidationException(
        'ID de tâche requis',
        ['L\'identifiant de la tâche est requis'],
        operationName: 'DeleteTask',
      );
    }
  }
}

/// Queries pour les cas d'usage des tâches
class GetTaskQuery extends Query {
  final String taskId;

  GetTaskQuery({required this.taskId});

  @override
  void validate() {
    if (taskId.trim().isEmpty) {
      throw BusinessValidationException(
        'ID de tâche requis',
        ['L\'identifiant de la tâche est requis'],
        operationName: 'GetTask',
      );
    }
  }
}

class GetTasksQuery extends Query {
  final String? category;
  final bool? completed;
  final PriorityLevel? priority;
  final DateRange? dueDateRange;
  final int? limit;
  final String? searchText;

  GetTasksQuery({
    this.category,
    this.completed,
    this.priority,
    this.dueDateRange,
    this.limit,
    this.searchText,
  });

  @override
  void validate() {
    if (limit != null && limit! <= 0) {
      throw BusinessValidationException(
        'Limite invalide',
        ['La limite doit être supérieure à 0'],
        operationName: 'GetTasks',
      );
    }
  }
}

class GetTodaysPrioritiesQuery extends Query {}

class GetTaskStatisticsQuery extends Query {
  final DateRange? dateRange;

  GetTaskStatisticsQuery({this.dateRange});
}

/// Service d'application pour les tâches
class TaskApplicationService extends ApplicationService {
  final TaskRepository _taskRepository;
  final TaskEloService _eloService;

  TaskApplicationService(this._taskRepository, this._eloService);

  @override
  String get serviceName => 'TaskApplicationService';

  /// Crée une nouvelle tâche
  Future<OperationResult<TaskAggregate>> createTask(CreateTaskCommand command) async {
    return await safeExecute(() async {
      command.validate();

      // Suggérer un ELO initial si non fourni
      final initialElo = command.initialElo ?? 
        _eloService.suggestInitialElo(
          category: command.category ?? 'general',
          title: command.title,
          dueDate: command.dueDate,
          description: command.description,
        );

      final task = TaskAggregate.create(
        title: command.title,
        description: command.description,
        category: command.category,
        dueDate: command.dueDate,
        eloScore: initialElo,
      );

      await _taskRepository.save(task);

      return OperationResult.success(
        task,
        message: 'Tâche créée avec succès',
        metadata: {
          'initialElo': initialElo.value,
          'category': command.category,
        },
      );
    }, 'createTask', aggregates: []);
  }

  /// Complète une tâche
  Future<OperationResult<TaskAggregate>> completeTask(CompleteTaskCommand command) async {
    return await safeExecute(() async {
      command.validate();

      final task = await _taskRepository.findById(command.taskId);
      if (task == null) {
        throw ResourceNotFoundException('Task', command.taskId);
      }

      if (task.isCompleted) {
        return OperationResult.success(
          task,
          message: 'La tâche était déjà complétée',
          warnings: ['Tâche déjà complétée'],
        );
      }

      task.complete();
      await _taskRepository.save(task);

      return OperationResult.success(
        task,
        message: 'Tâche complétée avec succès',
        metadata: {
          'completedAt': task.completedAt?.toIso8601String(),
          'eloScore': task.eloScore.value,
        },
      );
    }, 'completeTask', aggregates: []);
  }

  /// Met à jour une tâche
  Future<OperationResult<TaskAggregate>> updateTask(UpdateTaskCommand command) async {
    return await safeExecute(() async {
      command.validate();

      final task = await _taskRepository.findById(command.taskId);
      if (task == null) {
        throw ResourceNotFoundException('Task', command.taskId);
      }

      var updatedTask = task;
      final changes = <String>[];

      if (command.title != null && command.title != task.title) {
        updatedTask.updateTitle(command.title!);
        changes.add('titre');
      }

      if (command.description != null && command.description != task.description) {
        updatedTask.updateDescription(command.description);
        changes.add('description');
      }

      if (command.category != null && command.category != task.category) {
        updatedTask.updateCategory(command.category);
        changes.add('catégorie');
      }

      if (command.dueDate != task.dueDate) {
        updatedTask.updateDueDate(command.dueDate);
        changes.add('date d\'échéance');
      }

      if (changes.isNotEmpty) {
        await _taskRepository.save(updatedTask);
      }

      return OperationResult.success(
        updatedTask,
        message: changes.isEmpty 
          ? 'Aucune modification nécessaire'
          : 'Tâche mise à jour: ${changes.join(", ")}',
        metadata: {'changes': changes},
      );
    }, 'updateTask', aggregates: []);
  }

  /// Effectue un duel entre deux tâches
  Future<OperationResult<DuelResult>> duelTasks(DuelTasksCommand command) async {
    return await safeExecute(() async {
      command.validate();

      final task1 = await _taskRepository.findById(command.task1Id);
      if (task1 == null) {
        throw ResourceNotFoundException('Task', command.task1Id);
      }

      final task2 = await _taskRepository.findById(command.task2Id);
      if (task2 == null) {
        throw ResourceNotFoundException('Task', command.task2Id);
      }

      if (task1.isCompleted || task2.isCompleted) {
        throw BusinessValidationException(
          'Duel impossible',
          ['Les tâches complétées ne peuvent pas participer aux duels'],
          operationName: 'DuelTasks',
        );
      }

      final duelResult = _eloService.performDuel(task1, task2);

      await _taskRepository.saveAll([task1, task2]);

      return OperationResult.success(
        duelResult,
        message: 'Duel effectué: ${duelResult.winner.title} remporte la victoire',
        metadata: {
          'winner': duelResult.winner.title,
          'loser': duelResult.loser.title,
          'eloChange': duelResult.winnerEloChange.abs(),
        },
      );
    }, 'duelTasks', aggregates: []);
  }

  /// Supprime une tâche
  Future<OperationResult<void>> deleteTask(DeleteTaskCommand command) async {
    return await safeExecute(() async {
      command.validate();

      final task = await _taskRepository.findById(command.taskId);
      if (task == null) {
        throw ResourceNotFoundException('Task', command.taskId);
      }

      await _taskRepository.delete(command.taskId);

      return OperationResult.success(
        null,
        message: 'Tâche supprimée avec succès',
        metadata: {
          'deletedTask': task.title,
          'wasCompleted': task.isCompleted,
        },
      );
    }, 'deleteTask');
  }

  /// Récupère une tâche par son ID
  Future<OperationResult<TaskAggregate>> getTask(GetTaskQuery query) async {
    return await safeExecute(() async {
      query.validate();

      final task = await _taskRepository.findById(query.taskId);
      if (task == null) {
        throw ResourceNotFoundException('Task', query.taskId);
      }

      return OperationResult.success(task);
    }, 'getTask');
  }

  /// Récupère des tâches selon des critères
  Future<OperationResult<List<TaskAggregate>>> getTasks(GetTasksQuery query) async {
    return await safeExecute(() async {
      query.validate();

      // Construire la spécification basée sur les critères
      var specification = Specifications.alwaysTrue<TaskAggregate>();

      if (query.category != null) {
        specification = specification.and(
          TaskSpecifications.hasCategory(query.category!),
        );
      }

      if (query.completed != null) {
        specification = specification.and(
          query.completed! 
            ? TaskSpecifications.completed()
            : TaskSpecifications.incomplete(),
        );
      }

      if (query.priority != null) {
        specification = specification.and(
          TaskSpecifications.hasPriority(query.priority!),
        );
      }

      if (query.dueDateRange != null) {
        specification = specification.and(
          TaskSpecifications.dueBetween(
            query.dueDateRange!.start,
            query.dueDateRange!.end,
          ),
        );
      }

      if (query.searchText != null && query.searchText!.isNotEmpty) {
        specification = specification.and(
          TaskSpecifications.containsText(query.searchText!),
        );
      }

      final tasks = await _taskRepository.findBySpecification(specification);
      
      // Appliquer la limite si spécifiée
      final limitedTasks = query.limit != null 
        ? tasks.take(query.limit!).toList()
        : tasks;

      return OperationResult.success(
        limitedTasks,
        metadata: {
          'totalFound': tasks.length,
          'returned': limitedTasks.length,
          'hasMore': query.limit != null && tasks.length > query.limit!,
        },
      );
    }, 'getTasks');
  }

  /// Récupère les priorités du jour
  Future<OperationResult<List<TaskAggregate>>> getTodaysPriorities(GetTodaysPrioritiesQuery query) async {
    return await safeExecute(() async {
      final priorities = await _taskRepository.findTodaysPriorities();

      return OperationResult.success(
        priorities,
        message: '${priorities.length} priorité(s) pour aujourd\'hui',
        metadata: {
          'overdue': priorities.where((t) => t.isOverdue).length,
          'dueToday': priorities.where((t) => t.dueDate != null && 
            DateRange.today().contains(t.dueDate!)).length,
          'highPriority': priorities.where((t) => t.priority.level == PriorityLevel.high).length,
        },
      );
    }, 'getTodaysPriorities');
  }

  /// Récupère les statistiques des tâches
  Future<OperationResult<TaskStatistics>> getTaskStatistics(GetTaskStatisticsQuery query) async {
    return await safeExecute(() async {
      final statistics = await _taskRepository.getStatistics(dateRange: query.dateRange);

      return OperationResult.success(
        statistics,
        metadata: {
          'period': query.dateRange?.label ?? 'Toutes les données',
          'dataPoints': statistics.totalTasks,
        },
      );
    }, 'getTaskStatistics');
  }

  /// Trouve les meilleurs candidats pour un duel
  Future<OperationResult<List<TaskAggregate>>> findDuelCandidates(String taskId) async {
    return await safeExecute(() async {
      final task = await _taskRepository.findById(taskId);
      if (task == null) {
        throw ResourceNotFoundException('Task', taskId);
      }

      final candidates = await _taskRepository.findDuelCandidates(task);

      return OperationResult.success(
        candidates,
        message: '${candidates.length} candidat(s) trouvé(s) pour un duel',
        metadata: {
          'taskElo': task.eloScore.value,
          'eloRange': '${task.eloScore.value - 200} - ${task.eloScore.value + 200}',
        },
      );
    }, 'findDuelCandidates');
  }

  /// Réouvre une tâche complétée
  Future<OperationResult<TaskAggregate>> reopenTask(String taskId) async {
    return await safeExecute(() async {
      final task = await _taskRepository.findById(taskId);
      if (task == null) {
        throw ResourceNotFoundException('Task', taskId);
      }

      if (!task.isCompleted) {
        return OperationResult.success(
          task,
          message: 'La tâche n\'était pas complétée',
          warnings: ['Tâche déjà ouverte'],
        );
      }

      task.reopen();
      await _taskRepository.save(task);

      return OperationResult.success(
        task,
        message: 'Tâche réouverte avec succès',
      );
    }, 'reopenTask', aggregates: []);
  }
}