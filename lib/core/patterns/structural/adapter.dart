import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/entities/task.dart';

/// Adapter Pattern Implementation
///
/// Purpose: Allow incompatible interfaces to work together by providing
/// a wrapper that translates one interface to another.
///
/// This implementation adapts various data sources (Tasks, legacy data,
/// external APIs) to a common ListItem interface.

/// Common interface for adapted items
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

/// Adapter for Task to ListItem interface
class TaskToListItemAdapter implements ListItemInterface {
  final Task _task;

  TaskToListItemAdapter(this._task);

  @override
  String getId() => _task.id;

  @override
  String getTitle() => _task.title;

  @override
  String? getDescription() => _task.description;

  @override
  String? getCategory() => _task.category;

  @override
  double getPriority() => _task.eloScore;

  @override
  bool isComplete() => _task.isCompleted;

  @override
  DateTime getCreatedAt() => _task.createdAt;

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
      completedAt: isComplete() ? _task.completedAt : null,
      dueDate: _task.dueDate,
      listId: 'adapted',
    );
  }
}

/// Legacy data structure (incompatible with current system)
class LegacyTaskData {
  final String taskName;
  final String taskDetails;
  final int importance; // 1-10 scale
  final bool isDone;
  final String? assignedTo;

  LegacyTaskData({
    required this.taskName,
    required this.taskDetails,
    required this.importance,
    required this.isDone,
    this.assignedTo,
  });
}

/// Adapter for legacy data to ListItem interface
class LegacyTaskAdapter implements ListItemInterface {
  final LegacyTaskData _legacyData;

  LegacyTaskAdapter(this._legacyData);

  @override
  String getId() => 'legacy_${DateTime.now().microsecondsSinceEpoch}';

  @override
  String getTitle() => _legacyData.taskName;

  @override
  String? getDescription() => _legacyData.taskDetails;

  @override
  String? getCategory() => 'Legacy';

  @override
  double getPriority() {
    // Convert 1-10 importance scale to ELO score
    return 1000.0 + (_legacyData.importance * 100);
  }

  @override
  bool isComplete() => _legacyData.isDone;

  @override
  DateTime getCreatedAt() => DateTime.now();

  @override
  ListItem toListItem() {
    final description = _legacyData.assignedTo != null
        ? '${getDescription()} (Assigned to: ${_legacyData.assignedTo})'
        : getDescription();

    return ListItem(
      id: getId(),
      title: getTitle(),
      description: description,
      category: getCategory(),
      eloScore: getPriority(),
      isCompleted: isComplete(),
      createdAt: getCreatedAt(),
      completedAt: isComplete() ? DateTime.now() : null,
      listId: 'legacy',
    );
  }
}

/// Adapter for external API responses
class ExternalAPIAdapter implements ListItemInterface {
  final Map<String, dynamic> _apiResponse;

  ExternalAPIAdapter(this._apiResponse);

  @override
  String getId() => 'api_${DateTime.now().microsecondsSinceEpoch}';

  @override
  String getTitle() {
    return _apiResponse['task_title']?.toString() ?? 'Untitled Task';
  }

  @override
  String? getDescription() {
    final desc = _apiResponse['task_body']?.toString();
    return desc?.isNotEmpty == true ? desc : 'No description';
  }

  @override
  String? getCategory() => 'External';

  @override
  double getPriority() {
    final level = _apiResponse['priority_level'];
    if (level == null) return 1200.0;

    // Map API priority levels to ELO scores
    switch (level) {
      case 1:
        return 1100.0;
      case 2:
        return 1200.0;
      case 3:
        return 1300.0;
      case 4:
        return 1400.0;
      case 5:
        return 1500.0;
      default:
        return 1200.0;
    }
  }

  @override
  bool isComplete() {
    final status = _apiResponse['status']?.toString().toLowerCase();
    return status == 'completed' || status == 'done' || status == 'finished';
  }

  @override
  DateTime getCreatedAt() {
    final timestamp = _apiResponse['created_timestamp']?.toString();
    if (timestamp != null) {
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        // Fall back to current time if parsing fails
      }
    }
    return DateTime.now();
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
      completedAt: isComplete() ? DateTime.now() : null,
      listId: 'external',
    );
  }
}

/// Adapter Manager - manages different types of adapters
class AdapterManager {
  final List<ListItemInterface> _adaptedItems = [];

  /// Adapt a Task to ListItem interface
  ListItemInterface adaptTask(Task task) {
    final adapter = TaskToListItemAdapter(task);
    _adaptedItems.add(adapter);
    return adapter;
  }

  /// Adapt legacy data to ListItem interface
  ListItemInterface adaptLegacyData(LegacyTaskData legacyData) {
    final adapter = LegacyTaskAdapter(legacyData);
    _adaptedItems.add(adapter);
    return adapter;
  }

  /// Adapt external API response to ListItem interface
  ListItemInterface adaptAPIResponse(Map<String, dynamic> apiResponse) {
    final adapter = ExternalAPIAdapter(apiResponse);
    _adaptedItems.add(adapter);
    return adapter;
  }

  /// Batch adapt multiple tasks
  List<ListItemInterface> adaptTaskBatch(List<Task> tasks) {
    return tasks.map((task) => adaptTask(task)).toList();
  }

  /// Batch adapt multiple legacy items
  List<ListItemInterface> adaptLegacyBatch(List<LegacyTaskData> legacyItems) {
    return legacyItems.map((item) => adaptLegacyData(item)).toList();
  }

  /// Batch adapt multiple API responses
  List<ListItemInterface> adaptAPIBatch(List<Map<String, dynamic>> apiResponses) {
    return apiResponses.map((response) => adaptAPIResponse(response)).toList();
  }

  /// Convert all adapted items to ListItems
  List<ListItem> getAllAsListItems() {
    return _adaptedItems.map((adapter) => adapter.toListItem()).toList();
  }

  /// Get adapted items by category
  List<ListItemInterface> getByCategory(String category) {
    return _adaptedItems
        .where((adapter) => adapter.getCategory() == category)
        .toList();
  }

  /// Get completed adapted items
  List<ListItemInterface> getCompleted() {
    return _adaptedItems.where((adapter) => adapter.isComplete()).toList();
  }

  /// Get pending adapted items
  List<ListItemInterface> getPending() {
    return _adaptedItems.where((adapter) => !adapter.isComplete()).toList();
  }

  /// Clear all adapted items
  void clear() {
    _adaptedItems.clear();
  }

  /// Get statistics
  Map<String, dynamic> getStats() {
    final totalItems = _adaptedItems.length;
    final completed = getCompleted().length;
    final pending = getPending().length;

    final categoryCounts = <String, int>{};
    for (final adapter in _adaptedItems) {
      final category = adapter.getCategory() ?? 'Uncategorized';
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    return {
      'total_adapted_items': totalItems,
      'completed_items': completed,
      'pending_items': pending,
      'completion_rate': totalItems > 0 ? completed / totalItems : 0.0,
      'categories': categoryCounts,
    };
  }
}

/// Specialized adapter for database records
class DatabaseRecordAdapter implements ListItemInterface {
  final Map<String, dynamic> _record;

  DatabaseRecordAdapter(this._record);

  @override
  String getId() => _record['id']?.toString() ?? 'db_${DateTime.now().microsecondsSinceEpoch}';

  @override
  String getTitle() => _record['title']?.toString() ?? 'Database Record';

  @override
  String? getDescription() => _record['description']?.toString();

  @override
  String? getCategory() => _record['category']?.toString() ?? 'Database';

  @override
  double getPriority() => (_record['priority'] as num?)?.toDouble() ?? 1200.0;

  @override
  bool isComplete() => _record['is_completed'] as bool? ?? false;

  @override
  DateTime getCreatedAt() {
    final created = _record['created_at'];
    if (created is String) {
      try {
        return DateTime.parse(created);
      } catch (e) {
        return DateTime.now();
      }
    }
    if (created is DateTime) return created;
    return DateTime.now();
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
      listId: 'database',
    );
  }
}

/// Multi-format adapter that can handle different data sources
class UniversalAdapter implements ListItemInterface {
  final dynamic _data;
  final String _sourceType;

  UniversalAdapter(this._data, this._sourceType);

  @override
  String getId() => 'universal_${DateTime.now().microsecondsSinceEpoch}';

  @override
  String getTitle() {
    switch (_sourceType) {
      case 'map':
        final map = _data as Map<String, dynamic>;
        return map['title'] ?? map['name'] ?? map['task_title'] ?? 'Untitled';
      case 'task':
        final task = _data as Task;
        return task.title;
      default:
        return 'Unknown Format';
    }
  }

  @override
  String? getDescription() {
    switch (_sourceType) {
      case 'map':
        final map = _data as Map<String, dynamic>;
        return map['description'] ?? map['details'] ?? map['task_body'];
      case 'task':
        final task = _data as Task;
        return task.description;
      default:
        return null;
    }
  }

  @override
  String? getCategory() => 'Universal';

  @override
  double getPriority() {
    switch (_sourceType) {
      case 'map':
        final map = _data as Map<String, dynamic>;
        return (map['priority'] as num?)?.toDouble() ?? 1200.0;
      case 'task':
        final task = _data as Task;
        return task.eloScore;
      default:
        return 1200.0;
    }
  }

  @override
  bool isComplete() {
    switch (_sourceType) {
      case 'map':
        final map = _data as Map<String, dynamic>;
        return map['completed'] as bool? ??
               map['is_completed'] as bool? ??
               map['done'] as bool? ?? false;
      case 'task':
        final task = _data as Task;
        return task.isCompleted;
      default:
        return false;
    }
  }

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
      listId: 'universal',
    );
  }
}