import 'package:prioris/application/common/buses.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

/// Command to create a new custom list
/// 
/// Follows CQRS pattern - represents a write operation
/// Contains all data needed to create a list with validation
class CreateListCommand extends Command implements ValidatableCommand {
  final String name;
  final String? description;
  final ListType type;
  final int? priority;
  final List<String>? tags;
  final DateTime? startDate;
  final DateTime? endDate;

  const CreateListCommand({
    required this.name,
    this.description,
    required this.type,
    this.priority,
    this.tags,
    this.startDate,
    this.endDate,
  });

  @override
  List<String> validate() {
    final errors = <String>[];

    // Name validation
    if (name.trim().isEmpty) {
      errors.add('List name is required');
    } else if (name.length > 100) {
      errors.add('List name cannot exceed 100 characters');
    } else if (name.trim() != name) {
      errors.add('List name cannot have leading or trailing spaces');
    }

    // Description validation
    if (description != null && description!.length > 500) {
      errors.add('List description cannot exceed 500 characters');
    }

    // Priority validation
    if (priority != null && (priority! < 0 || priority! > 10)) {
      errors.add('Priority must be between 0 and 10');
    }

    // Tags validation
    if (tags != null) {
      if (tags!.length > 10) {
        errors.add('A list cannot have more than 10 tags');
      }

      for (final tag in tags!) {
        if (tag.isEmpty) {
          errors.add('Tag cannot be empty');
        } else if (tag.length > 30) {
          errors.add('Tag "$tag" cannot exceed 30 characters');
        }
      }

      // Check for duplicate tags
      final uniqueTags = tags!.map((tag) => tag.toLowerCase()).toSet();
      if (uniqueTags.length != tags!.length) {
        errors.add('Duplicate tags are not allowed');
      }
    }

    // Date validation
    if (startDate != null && endDate != null && startDate!.isAfter(endDate!)) {
      errors.add('Start date cannot be after end date');
    }

    return errors;
  }

  @override
  String toString() {
    return 'CreateListCommand(name: $name, type: $type, priority: $priority)';
  }
}

/// Command to update an existing list
class UpdateListCommand extends Command implements ValidatableCommand {
  final String listId;
  final String? name;
  final String? description;
  final ListType? type;
  final int? priority;
  final List<String>? tags;
  final DateTime? startDate;
  final DateTime? endDate;
  final int expectedVersion;

  const UpdateListCommand({
    required this.listId,
    this.name,
    this.description,
    this.type,
    this.priority,
    this.tags,
    this.startDate,
    this.endDate,
    required this.expectedVersion,
  });

  @override
  List<String> validate() {
    final errors = <String>[];

    // List ID validation
    if (listId.trim().isEmpty) {
      errors.add('List ID is required');
    }

    // Name validation (if provided)
    if (name != null) {
      if (name!.trim().isEmpty) {
        errors.add('List name cannot be empty');
      } else if (name!.length > 100) {
        errors.add('List name cannot exceed 100 characters');
      } else if (name!.trim() != name!) {
        errors.add('List name cannot have leading or trailing spaces');
      }
    }

    // Description validation (if provided)
    if (description != null && description!.length > 500) {
      errors.add('List description cannot exceed 500 characters');
    }

    // Priority validation (if provided)
    if (priority != null && (priority! < 0 || priority! > 10)) {
      errors.add('Priority must be between 0 and 10');
    }

    // Tags validation (if provided)
    if (tags != null) {
      if (tags!.length > 10) {
        errors.add('A list cannot have more than 10 tags');
      }

      for (final tag in tags!) {
        if (tag.isEmpty) {
          errors.add('Tag cannot be empty');
        } else if (tag.length > 30) {
          errors.add('Tag "$tag" cannot exceed 30 characters');
        }
      }

      // Check for duplicate tags
      final uniqueTags = tags!.map((tag) => tag.toLowerCase()).toSet();
      if (uniqueTags.length != tags!.length) {
        errors.add('Duplicate tags are not allowed');
      }
    }

    // Date validation (if provided)
    if (startDate != null && endDate != null && startDate!.isAfter(endDate!)) {
      errors.add('Start date cannot be after end date');
    }

    // Version validation
    if (expectedVersion < 1) {
      errors.add('Expected version must be positive');
    }

    return errors;
  }

  @override
  String toString() {
    return 'UpdateListCommand(listId: $listId, expectedVersion: $expectedVersion)';
  }
}

/// Command to delete a list
class DeleteListCommand extends Command implements ValidatableCommand {
  final String listId;
  final int expectedVersion;
  final bool force; // Force delete even if list has tasks

  const DeleteListCommand({
    required this.listId,
    required this.expectedVersion,
    this.force = false,
  });

  @override
  List<String> validate() {
    final errors = <String>[];

    if (listId.trim().isEmpty) {
      errors.add('List ID is required');
    }

    if (expectedVersion < 1) {
      errors.add('Expected version must be positive');
    }

    return errors;
  }

  @override
  String toString() {
    return 'DeleteListCommand(listId: $listId, force: $force)';
  }
}

/// Command to add a task to a list
class AddTaskToListCommand extends Command implements ValidatableCommand {
  final String listId;
  final String taskTitle;
  final String? taskDescription;
  final String? category;
  final DateTime? dueDate;
  final int? priority;

  const AddTaskToListCommand({
    required this.listId,
    required this.taskTitle,
    this.taskDescription,
    this.category,
    this.dueDate,
    this.priority,
  });

  @override
  List<String> validate() {
    final errors = <String>[];

    if (listId.trim().isEmpty) {
      errors.add('List ID is required');
    }

    if (taskTitle.trim().isEmpty) {
      errors.add('Task title is required');
    } else if (taskTitle.length > 200) {
      errors.add('Task title cannot exceed 200 characters');
    }

    if (taskDescription != null && taskDescription!.length > 1000) {
      errors.add('Task description cannot exceed 1000 characters');
    }

    if (category != null && category!.length > 50) {
      errors.add('Category cannot exceed 50 characters');
    }

    if (priority != null && (priority! < 0 || priority! > 10)) {
      errors.add('Priority must be between 0 and 10');
    }

    return errors;
  }

  @override
  String toString() {
    return 'AddTaskToListCommand(listId: $listId, taskTitle: $taskTitle)';
  }
}

/// Command to complete a task in a list
class CompleteTaskCommand extends Command implements ValidatableCommand {
  final String listId;
  final String taskId;
  final DateTime? completedAt;

  const CompleteTaskCommand({
    required this.listId,
    required this.taskId,
    this.completedAt,
  });

  @override
  List<String> validate() {
    final errors = <String>[];

    if (listId.trim().isEmpty) {
      errors.add('List ID is required');
    }

    if (taskId.trim().isEmpty) {
      errors.add('Task ID is required');
    }

    return errors;
  }

  @override
  String toString() {
    return 'CompleteTaskCommand(listId: $listId, taskId: $taskId)';
  }
}

/// Command to uncomplete a task in a list
class UncompleteTaskCommand extends Command implements ValidatableCommand {
  final String listId;
  final String taskId;

  const UncompleteTaskCommand({
    required this.listId,
    required this.taskId,
  });

  @override
  List<String> validate() {
    final errors = <String>[];

    if (listId.trim().isEmpty) {
      errors.add('List ID is required');
    }

    if (taskId.trim().isEmpty) {
      errors.add('Task ID is required');
    }

    return errors;
  }

  @override
  String toString() {
    return 'UncompleteTaskCommand(listId: $listId, taskId: $taskId)';
  }
}

/// Command to reorder tasks in a list
class ReorderTasksCommand extends Command implements ValidatableCommand {
  final String listId;
  final List<String> taskIds; // New order of task IDs
  final int expectedVersion;

  const ReorderTasksCommand({
    required this.listId,
    required this.taskIds,
    required this.expectedVersion,
  });

  @override
  List<String> validate() {
    final errors = <String>[];

    if (listId.trim().isEmpty) {
      errors.add('List ID is required');
    }

    if (taskIds.isEmpty) {
      errors.add('At least one task ID is required');
    }

    // Check for duplicate task IDs
    final uniqueIds = taskIds.toSet();
    if (uniqueIds.length != taskIds.length) {
      errors.add('Duplicate task IDs are not allowed');
    }

    if (expectedVersion < 1) {
      errors.add('Expected version must be positive');
    }

    return errors;
  }

  @override
  String toString() {
    return 'ReorderTasksCommand(listId: $listId, taskCount: ${taskIds.length})';
  }
}