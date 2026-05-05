import 'package:prioris/data/providers/duel_settings_provider.dart';
import 'package:prioris/data/repositories/task_repository.dart';
import 'package:prioris/domain/core/value_objects/duel_settings.dart';
import 'package:prioris/domain/models/core/entities/task.dart';

class TestTaskRepository implements TaskRepository {
  TestTaskRepository(List<Task> tasks) : _tasks = List.of(tasks);

  final List<Task> _tasks;

  @override
  Future<List<Task>> getAllTasks() async => List.of(_tasks);

  @override
  Future<void> saveTask(Task task) async => _tasks.add(task);

  @override
  Future<void> updateTask(Task task) async {
    final i = _tasks.indexWhere((t) => t.id == task.id);
    if (i != -1) _tasks[i] = task;
  }

  @override
  Future<void> deleteTask(String taskId) async =>
      _tasks.removeWhere((t) => t.id == taskId);

  @override
  Future<List<Task>> getActiveTasks() async =>
      _tasks.where((t) => !t.isCompleted).toList();

  @override
  Future<List<Task>> getCompletedTasks() async =>
      _tasks.where((t) => t.isCompleted).toList();

  @override
  Future<List<Task>> getTasksByCategory(String category) async =>
      _tasks.where((t) => t.category == category).toList();

  @override
  Future<void> clearAllTasks() async => _tasks.clear();

  @override
  Future<void> updateEloScores(Task winner, Task loser) async {
    await updateTask(winner);
    await updateTask(loser);
  }

  @override
  Future<List<Task>> getRandomTasksForDuel() async => List.of(_tasks);
}

class InMemoryDuelSettingsStorage implements DuelSettingsStorage {
  const InMemoryDuelSettingsStorage();

  @override
  Future<DuelSettings?> load() async => null;

  @override
  Future<void> save(DuelSettings settings) async {}
}
