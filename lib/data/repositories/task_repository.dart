import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/task.dart';

/// Repository abstrait pour la gestion des tâches
abstract class TaskRepository {
  Future<List<Task>> getAllTasks();
  Future<void> saveTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String taskId);
  Future<List<Task>> getActiveTasks();
  Future<List<Task>> getCompletedTasks();
  Future<List<Task>> getTasksByCategory(String category);
  Future<void> clearAllTasks();
  Future<void> updateEloScores(Task winner, Task loser);
  Future<List<Task>> getRandomTasksForDuel();
}

/// Implémentation en mémoire du repository des tâches
class InMemoryTaskRepository implements TaskRepository {
  final List<Task> _tasks = [];
  bool _initialized = false;

  Future<void> _initializeWithSampleData() async {
    if (_initialized) return;
    
    // Pas de données d'exemple - démarrage avec une liste vide
    _initialized = true;
  }

  @override
  Future<List<Task>> getAllTasks() async {
    await _initializeWithSampleData();
    return List.from(_tasks);
  }

  @override
  Future<void> saveTask(Task task) async {
    await _initializeWithSampleData();
    _tasks.add(task);
  }

  @override
  Future<void> updateTask(Task task) async {
    await _initializeWithSampleData();
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _initializeWithSampleData();
    _tasks.removeWhere((t) => t.id == taskId);
  }

  @override
  Future<List<Task>> getActiveTasks() async {
    await _initializeWithSampleData();
    return _tasks.where((t) => !t.isCompleted).toList();
  }

  @override
  Future<List<Task>> getCompletedTasks() async {
    await _initializeWithSampleData();
    return _tasks.where((t) => t.isCompleted).toList();
  }

  @override
  Future<List<Task>> getTasksByCategory(String category) async {
    await _initializeWithSampleData();
    return _tasks.where((t) => t.category == category).toList();
  }

  @override
  Future<void> clearAllTasks() async {
    _tasks.clear();
    _initialized = false;
  }

  @override
  Future<void> updateEloScores(Task winner, Task loser) async {
    // Mettre à jour les scores ELO
    winner.updateEloScore(loser, true);
    loser.updateEloScore(winner, false);
    
    // Sauvegarder les tâches mises à jour
    await updateTask(winner);
    await updateTask(loser);
  }

  @override
  Future<List<Task>> getRandomTasksForDuel() async {
    final activeTasks = await getActiveTasks();
    if (activeTasks.length < 2) {
      return activeTasks;
    }
    
    // Mélanger la liste et prendre les 2 premiers
    activeTasks.shuffle();
    return activeTasks.take(2).toList();
  }
}

/// Provider pour le repository des tâches
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return InMemoryTaskRepository();
});

/// Provider pour toutes les tâches
final allTasksProvider = FutureProvider<List<Task>>((ref) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getAllTasks();
});

/// Provider pour les tâches actives
final activeTasksProvider = FutureProvider<List<Task>>((ref) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getActiveTasks();
});

/// Provider pour les tâches triées par ELO
final tasksSortedByEloProvider = FutureProvider<List<Task>>((ref) async {
  final repository = ref.read(taskRepositoryProvider);
  final tasks = await repository.getAllTasks();
  tasks.sort((a, b) => b.eloScore.compareTo(a.eloScore));
  return tasks;
}); 
