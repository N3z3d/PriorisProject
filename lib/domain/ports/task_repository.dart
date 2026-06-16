import 'package:prioris/domain/models/core/entities/task.dart';

abstract class ITaskRepository {
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
