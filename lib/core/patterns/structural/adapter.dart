import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/entities/task.dart';

abstract class ListItemInterface {
  String getId();
  String getTitle();
  String? getDescription();
  String? getCategory();
  double getPriority();
  bool isComplete();
  DateTime getCreatedAt();
  ListItem toListItem();
}

String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();

class TaskToListItemAdapter implements ListItemInterface {
  TaskToListItemAdapter(this._task);

  final Task _task;

  @override
  String getId() => _task.id ?? _generateId();

  @override
  String getTitle() => _task.title;

  @override
  String? getDescription() => _task.description;

  @override
  String? getCategory() => _task.category;

  @override
  double getPriority() => _task.eloScore ?? 1200.0;

  @override
  bool isComplete() => _task.completedAt != null;

  @override
  DateTime getCreatedAt() => _task.createdAt ?? DateTime.now();

  @override
  ListItem toListItem() {
    return ListItem(
      id: getId(),
      title: getTitle(),
      description: getDescription(),
      category: getCategory(),
      eloScore: getPriority(),
      isCompleted: isComplete(),
      createdAt: getCreatedAt(),
    );
  }
}

class LegacyTaskData {
  LegacyTaskData({
    required this.taskName,
    required this.taskDetails,
    required this.importance,
    required this.isDone,
  });

  final String taskName;
  final String taskDetails;
  final int importance;
  final bool isDone;
}

class LegacyTaskAdapter implements ListItemInterface {
  LegacyTaskAdapter(this._legacyData);

  final LegacyTaskData _legacyData;

  @override
  String getId() => _generateId();

  @override
  String getTitle() => _legacyData.taskName;

  @override
  String? getDescription() => _legacyData.taskDetails;

  @override
  String? getCategory() => 'Legacy';

  @override
  double getPriority() => 1000.0 + (_legacyData.importance * 100);

  @override
  bool isComplete() => _legacyData.isDone;

  @override
  DateTime getCreatedAt() => DateTime.now();

  @override
  ListItem toListItem() {
    return ListItem(
      id: getId(),
      title: getTitle(),
      description: getDescription(),
      category: getCategory(),
      eloScore: getPriority(),
      isCompleted: isComplete(),
      createdAt: getCreatedAt(),
    );
  }
}

class ExternalAPIAdapter implements ListItemInterface {
  ExternalAPIAdapter(Map<String, dynamic> payload)
      : _data = Map<String, dynamic>.from(payload);

  final Map<String, dynamic> _data;

  @override
  String getId() => (_data['id'] as String?) ?? _generateId();

  @override
  String getTitle() => (_data['task_title'] as String?)?.trim().isNotEmpty == true
      ? _data['task_title'] as String
      : 'Untitled Task';

  @override
  String? getDescription() =>
      (_data['task_body'] as String?)?.trim().isNotEmpty == true
          ? _data['task_body'] as String
          : 'No description';

  @override
  String? getCategory() => 'External';

  @override
  double getPriority() {
    final priority = _data['priority_level'];
    if (priority is num) {
      return 1000.0 + priority.toDouble() * 100;
    }
    return 1200.0;
  }

  @override
  bool isComplete() {
    final status = (_data['status'] as String?)?.toLowerCase();
    return status == 'completed' || status == 'done';
  }

  @override
  DateTime getCreatedAt() {
    final timestamp = _data['created_timestamp'] as String?;
    if (timestamp == null) {
      return DateTime.now();
    }
    return DateTime.tryParse(timestamp) ?? DateTime.now();
  }

  @override
  ListItem toListItem() {
    return ListItem(
      id: getId(),
      title: getTitle(),
      description: getDescription(),
      category: getCategory(),
      eloScore: getPriority(),
      isCompleted: isComplete(),
      createdAt: getCreatedAt(),
    );
  }
}

class AdapterManager {
  ListItemInterface adaptTask(Task task) => TaskToListItemAdapter(task);

  ListItemInterface adaptLegacyData(LegacyTaskData data) =>
      LegacyTaskAdapter(data);

  ListItemInterface adaptExternalData(Map<String, dynamic> payload) =>
      ExternalAPIAdapter(payload);

  List<ListItemInterface> adaptTaskBatch(List<Task> tasks) {
    return tasks.map(adaptTask).toList();
  }
}
