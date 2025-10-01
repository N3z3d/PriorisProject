/// Observer Pattern Implementation
///
/// Purpose: Define a one-to-many dependency between objects so that when one
/// object changes state, all dependents are notified and updated automatically.
///
/// This implementation provides event-driven notifications for task changes.

/// Observer interface
abstract class TaskObserver {
  void onTaskCreated(String taskId, String title);
  void onTaskUpdated(String taskId, Map<String, dynamic> changes);
  void onTaskCompleted(String taskId, DateTime completedAt);
  void onTaskDeleted(String taskId);
}

/// Subject interface
abstract class TaskSubject {
  void subscribe(TaskObserver observer);
  void unsubscribe(TaskObserver observer);
  void notifyObservers();
}

/// Concrete observable task manager
class ObservableTaskManager implements TaskSubject {
  final List<TaskObserver> _observers = [];
  final Map<String, Map<String, dynamic>> _tasks = {};

  @override
  void subscribe(TaskObserver observer) {
    _observers.add(observer);
  }

  @override
  void unsubscribe(TaskObserver observer) {
    _observers.remove(observer);
  }

  @override
  void notifyObservers() {
    // General notification - specific notifications are handled per action
  }

  /// Create a new task
  void createTask(String id, String title, Map<String, dynamic> properties) {
    _tasks[id] = {
      'title': title,
      'isCompleted': false,
      'createdAt': DateTime.now(),
      ...properties,
    };

    for (final observer in _observers) {
      observer.onTaskCreated(id, title);
    }
  }

  /// Update an existing task
  void updateTask(String id, Map<String, dynamic> changes) {
    if (!_tasks.containsKey(id)) return;

    _tasks[id]!.addAll(changes);
    _tasks[id]!['updatedAt'] = DateTime.now();

    for (final observer in _observers) {
      observer.onTaskUpdated(id, changes);
    }
  }

  /// Complete a task
  void completeTask(String id) {
    if (!_tasks.containsKey(id)) return;

    final completedAt = DateTime.now();
    _tasks[id]!['isCompleted'] = true;
    _tasks[id]!['completedAt'] = completedAt;

    for (final observer in _observers) {
      observer.onTaskCompleted(id, completedAt);
    }
  }

  /// Delete a task
  void deleteTask(String id) {
    if (!_tasks.containsKey(id)) return;

    _tasks.remove(id);

    for (final observer in _observers) {
      observer.onTaskDeleted(id);
    }
  }

  /// Get task data
  Map<String, dynamic>? getTask(String id) => _tasks[id];

  /// Get all tasks
  Map<String, Map<String, dynamic>> getAllTasks() => Map.from(_tasks);

  /// Get observer count
  int getObserverCount() => _observers.length;
}

/// Concrete observer for logging
class TaskLogger implements TaskObserver {
  final List<String> _logs = [];

  @override
  void onTaskCreated(String taskId, String title) {
    final log = '[${DateTime.now()}] Task created: $taskId - $title';
    _logs.add(log);
    print(log);
  }

  @override
  void onTaskUpdated(String taskId, Map<String, dynamic> changes) {
    final log = '[${DateTime.now()}] Task updated: $taskId - Changes: $changes';
    _logs.add(log);
    print(log);
  }

  @override
  void onTaskCompleted(String taskId, DateTime completedAt) {
    final log = '[${DateTime.now()}] Task completed: $taskId at $completedAt';
    _logs.add(log);
    print(log);
  }

  @override
  void onTaskDeleted(String taskId) {
    final log = '[${DateTime.now()}] Task deleted: $taskId';
    _logs.add(log);
    print(log);
  }

  List<String> getLogs() => List.unmodifiable(_logs);
  void clearLogs() => _logs.clear();
}

/// Concrete observer for analytics
class TaskAnalyticsObserver implements TaskObserver {
  int _createdCount = 0;
  int _updatedCount = 0;
  int _completedCount = 0;
  int _deletedCount = 0;

  @override
  void onTaskCreated(String taskId, String title) {
    _createdCount++;
  }

  @override
  void onTaskUpdated(String taskId, Map<String, dynamic> changes) {
    _updatedCount++;
  }

  @override
  void onTaskCompleted(String taskId, DateTime completedAt) {
    _completedCount++;
  }

  @override
  void onTaskDeleted(String taskId) {
    _deletedCount++;
  }

  Map<String, int> getStatistics() {
    return {
      'created': _createdCount,
      'updated': _updatedCount,
      'completed': _completedCount,
      'deleted': _deletedCount,
    };
  }

  void reset() {
    _createdCount = 0;
    _updatedCount = 0;
    _completedCount = 0;
    _deletedCount = 0;
  }
}