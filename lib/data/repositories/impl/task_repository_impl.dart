import 'package:prioris/data/repositories/base/base_repository.dart';
import 'package:prioris/data/repositories/base/repository_interfaces.dart';
import 'package:prioris/domain/models/core/entities/task.dart';

/// Implémentation du repository pour les tâches
/// 
/// Respecte le pattern Repository avec séparation claire
/// entre la logique métier et la persistance.
class TaskRepositoryImpl extends BaseRepository<Task> 
    implements 
        ISearchableRepository<Task>,
        IFilterableRepository<Task>,
        ISortableRepository<Task>,
        IValidatableRepository<Task> {
  
  TaskRepositoryImpl() : super('tasks');

  // ========== ISearchableRepository ==========
  
  @override
  Future<List<Task>> search(String query) async {
    if (query.isEmpty) return getAll();
    
    final lowerQuery = query.toLowerCase();
    return where((task) =>
      task.title.toLowerCase().contains(lowerQuery) ||
      (task.description?.toLowerCase().contains(lowerQuery) ?? false) ||
      task.tags.any((tag) => tag.toLowerCase().contains(lowerQuery))
    );
  }

  // ========== IFilterableRepository ==========
  
  @override
  Future<List<Task>> filter(Map<String, dynamic> filters) async {
    var tasks = await getAll();
    
    // Filtre par statut
    if (filters['isCompleted'] != null) {
      tasks = tasks.where((t) => t.isCompleted == filters['isCompleted']).toList();
    }
    
    // Filtre par priorité
    if (filters['priority'] != null) {
      tasks = tasks.where((t) => t.priority == filters['priority']).toList();
    }
    
    // Filtre par tags
    if (filters['tags'] != null && filters['tags'] is List<String>) {
      final tags = filters['tags'] as List<String>;
      tasks = tasks.where((t) => 
        tags.any((tag) => t.tags.contains(tag))
      ).toList();
    }
    
    // Filtre par date d'échéance
    if (filters['hasDueDate'] == true) {
      tasks = tasks.where((t) => t.dueDate != null).toList();
    }
    
    // Filtre par retard
    if (filters['isOverdue'] == true) {
      final now = DateTime.now();
      tasks = tasks.where((t) => 
        t.dueDate != null && 
        t.dueDate!.isBefore(now) && 
        !t.isCompleted
      ).toList();
    }
    
    // Filtre par score ELO
    if (filters['minEloScore'] != null) {
      tasks = tasks.where((t) => t.eloScore >= filters['minEloScore']).toList();
    }
    if (filters['maxEloScore'] != null) {
      tasks = tasks.where((t) => t.eloScore <= filters['maxEloScore']).toList();
    }
    
    return tasks;
  }

  @override
  Future<List<Task>> filterByType(String type) async {
    // Les tâches n'ont pas de type, on retourne toutes les tâches
    return getAll();
  }

  @override
  Future<List<Task>> filterByStatus(String status) async {
    final isCompleted = status.toLowerCase() == 'completed';
    return where((task) => task.isCompleted == isCompleted);
  }

  @override
  Future<List<Task>> filterByDateRange(DateTime start, DateTime end) async {
    return where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.isAfter(start) && task.dueDate!.isBefore(end);
    });
  }

  // ========== ISortableRepository ==========
  
  @override
  Future<List<Task>> sortBy(String field, {bool ascending = true}) async {
    final tasks = await getAll();
    final comparator = _resolveComparator(field, ascending);
    tasks.sort(comparator);
    return tasks;
  }


  @override
  Future<List<Task>> sortByMultiple(List<SortCriteria> criteria) async {
    if (criteria.isEmpty) return getAll();

    final tasks = await getAll();
    final comparators = criteria
        .map((criterion) => _resolveComparator(criterion.field, criterion.ascending))
        .toList();

    tasks.sort((a, b) {
      for (final comparator in comparators) {
        final result = comparator(a, b);
        if (result != 0) return result;
      }
      return 0;
    });

    return tasks;
  }


  Comparator<Task> _resolveComparator(String field, bool ascending) {
    final normalized = _normalizeSortField(field);
    switch (normalized) {
      case 'title':
        return (a, b) => _applyOrder(a.title.compareTo(b.title), ascending);
      case 'priority':
        return (a, b) => _applyOrder(a.priority.compareTo(b.priority), ascending);
      case 'elo':
        return (a, b) => _applyOrder(a.eloScore.compareTo(b.eloScore), ascending);
      case 'dueDate':
        return (a, b) => _compareDueDate(a, b, ascending);
      case 'createdAt':
        return (a, b) => _applyOrder(a.createdAt.compareTo(b.createdAt), ascending);
      case 'updatedAt':
        return (a, b) => _applyOrder(a.updatedAt.compareTo(b.updatedAt), ascending);
      case 'status':
        return (a, b) => _compareCompletion(a, b, ascending);
      default:
        return (a, b) => b.eloScore.compareTo(a.eloScore);
    }
  }

  String _normalizeSortField(String field) {
    switch (field.toLowerCase()) {
      case 'title':
        return 'title';
      case 'priority':
        return 'priority';
      case 'eloscore':
      case 'elo':
        return 'elo';
      case 'duedate':
      case 'due':
        return 'dueDate';
      case 'created':
      case 'createdat':
        return 'createdAt';
      case 'updated':
      case 'updatedat':
        return 'updatedAt';
      case 'completed':
      case 'status':
        return 'status';
      default:
        return 'default';
    }
  }

  int _compareDueDate(Task a, Task b, bool ascending) {
    if (a.dueDate == null && b.dueDate == null) return 0;
    if (a.dueDate == null) return ascending ? 1 : -1;
    if (b.dueDate == null) return ascending ? -1 : 1;
    return ascending
        ? a.dueDate!.compareTo(b.dueDate!)
        : b.dueDate!.compareTo(a.dueDate!);
  }

  int _compareCompletion(Task a, Task b, bool ascending) {
    if (a.isCompleted == b.isCompleted) return 0;
    if (ascending) {
      return a.isCompleted ? 1 : -1;
    }
    return a.isCompleted ? -1 : 1;
  }

  int _applyOrder(int result, bool ascending) => ascending ? result : -result;

  // ========== IValidatableRepository ==========
  
  @override
  Future<bool> validate(Task entity) async {
    final errors = await getValidationErrors(entity);
    return errors.isEmpty;
  }

  @override
  Future<List<String>> getValidationErrors(Task entity) async {
    final errors = <String>[];

    _validateTitle(entity, errors);
    _validateDescription(entity, errors);
    _validatePriority(entity, errors);
    _validateEloScore(entity, errors);
    _validateDueDate(entity, errors);
    _validateTimestamps(entity, errors);
    _validateTags(entity, errors);

    return errors;
  }
  void _validateTitle(Task entity, List<String> errors) {
    if (entity.title.isEmpty) {
      errors.add("Le titre ne peut pas être vide");
    }
    if (entity.title.length > 200) {
      errors.add("Le titre ne peut pas dépasser 200 caractères");
    }
  }

  void _validateDescription(Task entity, List<String> errors) {
    if (entity.description != null && entity.description!.length > 1000) {
      errors.add("La description ne peut pas dépasser 1000 caractères");
    }
  }

  void _validatePriority(Task entity, List<String> errors) {
    if (entity.priority < 1 || entity.priority > 5) {
      errors.add("La priorité doit être entre 1 et 5");
    }
  }

  void _validateEloScore(Task entity, List<String> errors) {
    if (entity.eloScore < 0) {
      errors.add("Le score ELO ne peut pas être négatif");
    }
  }

  void _validateDueDate(Task entity, List<String> errors) {
    if (entity.dueDate != null && entity.dueDate!.isBefore(entity.createdAt)) {
      errors.add("La date d'échéance ne peut pas être antérieure à la date de création");
    }
  }

  void _validateTimestamps(Task entity, List<String> errors) {
    if (entity.updatedAt.isBefore(entity.createdAt)) {
      errors.add("La date de mise à jour ne peut pas être antérieure à la date de création");
    }
  }

  void _validateTags(Task entity, List<String> errors) {
    if (entity.tags.length > 10) {
      errors.add("Une tâche ne peut pas avoir plus de 10 tags");
    }
    for (final tag in entity.tags) {
      if (tag.isEmpty) {
        errors.add("Les tags ne peuvent pas être vides");
      }
      if (tag.length > 30) {
        errors.add("Les tags ne peuvent pas dépasser 30 caractères");
      }
    }
  }

  @override
  Future<Task> sanitize(Task entity) async {
    return entity.copyWith(
      title: entity.title.trim(),
      description: entity.description?.trim(),
      tags: entity.tags.map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
      priority: entity.priority.clamp(1, 5),
      eloScore: entity.eloScore.clamp(0, double.infinity),
    );
  }

  // ========== Méthodes spécifiques aux tâches ==========
  
  /// Récupère les tâches du jour
  Future<List<Task>> getTodayTasks() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.isAfter(startOfDay) && 
             task.dueDate!.isBefore(endOfDay);
    });
  }

  /// Récupère les tâches en retard
  Future<List<Task>> getOverdueTasks() async {
    final now = DateTime.now();
    return where((task) => 
      task.dueDate != null && 
      task.dueDate!.isBefore(now) && 
      !task.isCompleted
    );
  }

  /// Récupère les tâches prioritaires (score ELO élevé)
  Future<List<Task>> getPriorityTasks({int limit = 5}) async {
    final tasks = await sortBy('eloscore', ascending: false);
    final incompleteTasks = tasks.where((t) => !t.isCompleted).toList();
    return incompleteTasks.take(limit).toList();
  }

  /// Récupère les statistiques des tâches
  Future<Map<String, dynamic>> getStatistics() async {
    final tasks = await getAll();
    final completedTasks = tasks.where((t) => t.isCompleted).toList();
    final overdueTasks = await getOverdueTasks();
    
    return {
      'total': tasks.length,
      'completed': completedTasks.length,
      'pending': tasks.length - completedTasks.length,
      'overdue': overdueTasks.length,
      'completionRate': tasks.isEmpty ? 0.0 : completedTasks.length / tasks.length,
      'averageEloScore': tasks.isEmpty ? 0.0 : 
        tasks.map((t) => t.eloScore).reduce((a, b) => a + b) / tasks.length,
      'byPriority': {
        for (int i = 1; i <= 5; i++)
          i: tasks.where((t) => t.priority == i).length,
      },
    };
  }
}