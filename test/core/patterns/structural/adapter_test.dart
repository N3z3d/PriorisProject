import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/core/patterns/structural/adapter.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/entities/task.dart';

void main() {
  group('Adapter Pattern', () {
    test('should adapt Task to ListItem interface', () {
      // Arrange
      final task = Task(
        title: 'Complete Project',
        description: 'Finish the mobile app project',
        category: 'Work',
        eloScore: 1400.0,
      );

      final adapter = TaskToListItemAdapter(task);

      // Act & Assert
      expect(adapter, isA<ListItemInterface>());
      expect(adapter.getTitle(), equals('Complete Project'));
      expect(adapter.getDescription(), equals('Finish the mobile app project'));
      expect(adapter.getCategory(), equals('Work'));
      expect(adapter.getPriority(), equals(1400.0));
      expect(adapter.isComplete(), isFalse);
      expect(adapter.getId(), isNotEmpty);
    });

    test('should adapt legacy data format', () {
      // Arrange
      final legacyData = LegacyTaskData(
        taskName: 'Legacy Task',
        taskDetails: 'Old format task',
        importance: 5,
        isDone: false,
      );

      final adapter = LegacyTaskAdapter(legacyData);

      // Act & Assert
      expect(adapter.getTitle(), equals('Legacy Task'));
      expect(adapter.getDescription(), equals('Old format task'));
      expect(adapter.getPriority(), equals(1000.0 + (5 * 100))); // Converted importance
      expect(adapter.isComplete(), isFalse);
    });

    test('should adapt external API response', () {
      // Arrange
      final apiResponse = {
        'task_title': 'API Task',
        'task_body': 'Task from external API',
        'priority_level': 3,
        'status': 'pending',
        'created_timestamp': '2024-01-01T10:00:00Z',
      };

      final adapter = ExternalAPIAdapter(apiResponse);

      // Act & Assert
      expect(adapter.getTitle(), equals('API Task'));
      expect(adapter.getDescription(), equals('Task from external API'));
      expect(adapter.getPriority(), equals(1300.0)); // Mapped priority
      expect(adapter.isComplete(), isFalse);
      expect(adapter.getCategory(), equals('External'));
    });

    test('should use adapter manager for multiple adaptations', () {
      // Arrange
      final manager = AdapterManager();

      final task = Task(title: 'Test Task', description: 'Test');
      final legacyData = LegacyTaskData(
        taskName: 'Legacy',
        taskDetails: 'Legacy details',
        importance: 3,
        isDone: true,
      );

      // Act
      final taskAdapter = manager.adaptTask(task);
      final legacyAdapter = manager.adaptLegacyData(legacyData);

      // Assert
      expect(taskAdapter.getTitle(), equals('Test Task'));
      expect(legacyAdapter.getTitle(), equals('Legacy'));
      expect(legacyAdapter.isComplete(), isTrue);
    });

    test('should convert adapted items back to ListItem', () {
      // Arrange
      final task = Task(
        title: 'Convert Test',
        description: 'Test conversion',
        category: 'Test',
      );
      final adapter = TaskToListItemAdapter(task);

      // Act
      final listItem = adapter.toListItem();

      // Assert
      expect(listItem, isA<ListItem>());
      expect(listItem.title, equals('Convert Test'));
      expect(listItem.description, equals('Test conversion'));
      expect(listItem.category, equals('Test'));
    });

    test('should handle null and empty values gracefully', () {
      // Arrange
      final apiResponse = {
        'task_title': null,
        'task_body': '',
        'priority_level': null,
        'status': 'completed',
      };

      final adapter = ExternalAPIAdapter(apiResponse);

      // Act & Assert
      expect(adapter.getTitle(), equals('Untitled Task'));
      expect(adapter.getDescription(), equals('No description'));
      expect(adapter.getPriority(), equals(1200.0)); // Default priority
      expect(adapter.isComplete(), isTrue);
    });

    test('should adapt multiple items in batch', () {
      // Arrange
      final manager = AdapterManager();
      final tasks = [
        Task(title: 'Task 1', description: 'First task'),
        Task(title: 'Task 2', description: 'Second task'),
        Task(title: 'Task 3', description: 'Third task'),
      ];

      // Act
      final adapters = manager.adaptTaskBatch(tasks);

      // Assert
      expect(adapters.length, equals(3));
      expect(adapters[0].getTitle(), equals('Task 1'));
      expect(adapters[1].getTitle(), equals('Task 2'));
      expect(adapters[2].getTitle(), equals('Task 3'));
    });

    test('should register and use custom adapter', () {
      // Arrange
      final manager = AdapterManager();
      final customData = CustomExternalData(
        name: 'Custom Task',
        content: 'Custom content',
        level: 'high',
      );

      // Act
      final adapter = CustomDataAdapter(customData);
      final result = adapter.getTitle();

      // Assert
      expect(result, equals('Custom Task'));
      expect(adapter.getCategory(), equals('Custom'));
      expect(adapter.getPriority(), equals(1500.0)); // High priority
    });
  });
}

// Test data structures

class CustomExternalData {
  final String name;
  final String content;
  final String level;

  CustomExternalData({
    required this.name,
    required this.content,
    required this.level,
  });
}

// Test adapter for custom data
class CustomDataAdapter implements ListItemInterface {
  final CustomExternalData _data;

  CustomDataAdapter(this._data);

  @override
  String getId() => DateTime.now().microsecondsSinceEpoch.toString();

  @override
  String getTitle() => _data.name;

  @override
  String? getDescription() => _data.content;

  @override
  String? getCategory() => 'Custom';

  @override
  double getPriority() {
    switch (_data.level) {
      case 'high':
        return 1500.0;
      case 'medium':
        return 1300.0;
      case 'low':
        return 1100.0;
      default:
        return 1200.0;
    }
  }

  @override
  bool isComplete() => false;

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
      createdAt: getCreatedAt(),
    );
  }
}