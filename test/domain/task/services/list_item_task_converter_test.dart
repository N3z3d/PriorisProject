import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/task/services/list_item_task_converter.dart';

void main() {
  group('ListItemTaskConverter', () {
    late ListItemTaskConverter converter;
    late DateTime testDate;

    setUp(() {
      converter = ListItemTaskConverter();
      testDate = DateTime(2024, 1, 15, 10, 30);
    });

    group('convertListItemToTask', () {
      test('should convert ListItem to Task with all fields', () {
        // Arrange
        final listItem = ListItem(
          id: 'test-id',
          title: 'Test Task',
          description: 'Test description',
          category: 'Work',
          eloScore: 1350.5,
          isCompleted: false,
          createdAt: testDate,
          completedAt: null,
          dueDate: testDate.add(const Duration(days: 7)),
          notes: 'Some notes',
          listId: 'list-123',
          lastChosenAt: testDate.subtract(const Duration(hours: 1)),
        );

        // Act
        final task = converter.convertListItemToTask(listItem);

        // Assert
        expect(task.id, equals('test-id'));
        expect(task.title, equals('Test Task'));
        expect(task.description, equals('Test description'));
        expect(task.category, equals('Work'));
        expect(task.eloScore, equals(1350.5));
        expect(task.isCompleted, equals(false));
        expect(task.createdAt, equals(testDate));
        expect(task.completedAt, isNull);
        expect(task.dueDate, equals(testDate.add(const Duration(days: 7))));
        expect(task.lastChosenAt, equals(testDate.subtract(const Duration(hours: 1))));
        expect(task.tags, contains('list-123'));
      });

      test('should handle ListItem with minimal data', () {
        // Arrange
        final listItem = ListItem(
          id: 'minimal-id',
          title: 'Minimal Task',
          createdAt: testDate,
        );

        // Act
        final task = converter.convertListItemToTask(listItem);

        // Assert
        expect(task.id, equals('minimal-id'));
        expect(task.title, equals('Minimal Task'));
        expect(task.description, isNull);
        expect(task.category, isNull);
        expect(task.eloScore, equals(1200.0));
        expect(task.isCompleted, equals(false));
        expect(task.createdAt, equals(testDate));
        expect(task.tags, contains('default'));
      });

      test('should convert completed ListItem properly', () {
        // Arrange
        final completedDate = testDate.add(const Duration(hours: 2));
        final listItem = ListItem(
          id: 'completed-id',
          title: 'Completed Task',
          isCompleted: true,
          createdAt: testDate,
          completedAt: completedDate,
        );

        // Act
        final task = converter.convertListItemToTask(listItem);

        // Assert
        expect(task.isCompleted, isTrue);
        expect(task.completedAt, equals(completedDate));
      });
    });

    group('convertTaskToListItem', () {
      test('should convert Task to ListItem with all fields', () {
        // Arrange
        final task = Task(
          id: 'task-id',
          title: 'Test ListItem',
          description: 'Test description',
          category: 'Personal',
          eloScore: 1450.0,
          isCompleted: true,
          createdAt: testDate,
          completedAt: testDate.add(const Duration(hours: 3)),
          dueDate: testDate.add(const Duration(days: 5)),
          tags: ['list-456', 'important'],
          priority: 2,
          lastChosenAt: testDate.subtract(const Duration(minutes: 30)),
        );

        // Act
        final listItem = converter.convertTaskToListItem(task, listId: 'target-list');

        // Assert
        expect(listItem.id, equals('task-id'));
        expect(listItem.title, equals('Test ListItem'));
        expect(listItem.description, equals('Test description'));
        expect(listItem.category, equals('Personal'));
        expect(listItem.eloScore, equals(1450.0));
        expect(listItem.isCompleted, isTrue);
        expect(listItem.createdAt, equals(testDate));
        expect(listItem.completedAt, equals(testDate.add(const Duration(hours: 3))));
        expect(listItem.dueDate, equals(testDate.add(const Duration(days: 5))));
        expect(listItem.listId, equals('target-list'));
        expect(listItem.lastChosenAt, equals(testDate.subtract(const Duration(minutes: 30))));
      });

      test('should extract listId from task tags when not provided', () {
        // Arrange
        final task = Task(
          id: 'auto-id',
          title: 'Auto Task',
          tags: ['list-789', 'urgent'],
          createdAt: testDate,
        );

        // Act
        final listItem = converter.convertTaskToListItem(task);

        // Assert
        expect(listItem.listId, equals('list-789'));
      });

      test('should use first tag as listId when no tags match list pattern', () {
        // Arrange
        final task = Task(
          id: 'no-list-id',
          title: 'No List Task',
          tags: ['urgent', 'important'],
          createdAt: testDate,
        );

        // Act
        final listItem = converter.convertTaskToListItem(task);

        // Assert - Should use first tag as fallback
        expect(listItem.listId, equals('urgent'));
      });

      test('should use default listId when no tags available', () {
        // Arrange
        final task = Task(
          id: 'no-tags',
          title: 'No Tags Task',
          tags: [], // Empty tags
          createdAt: testDate,
        );

        // Act
        final listItem = converter.convertTaskToListItem(task);

        // Assert
        expect(listItem.listId, equals('default'));
      });
    });

    group('convertListItemsToTasks', () {
      test('should convert list of ListItems to Tasks', () {
        // Arrange
        final listItems = [
          ListItem(id: '1', title: 'Item 1', createdAt: testDate),
          ListItem(id: '2', title: 'Item 2', createdAt: testDate, eloScore: 1300.0),
          ListItem(id: '3', title: 'Item 3', createdAt: testDate, isCompleted: true),
        ];

        // Act
        final tasks = converter.convertListItemsToTasks(listItems);

        // Assert
        expect(tasks, hasLength(3));
        expect(tasks[0].title, equals('Item 1'));
        expect(tasks[1].eloScore, equals(1300.0));
        expect(tasks[2].isCompleted, isTrue);
      });

      test('should handle empty list', () {
        // Act
        final tasks = converter.convertListItemsToTasks([]);

        // Assert
        expect(tasks, isEmpty);
      });
    });

    group('convertTasksToListItems', () {
      test('should convert list of Tasks to ListItems with specified listId', () {
        // Arrange
        final tasks = [
          Task(id: '1', title: 'Task 1', createdAt: testDate),
          Task(id: '2', title: 'Task 2', createdAt: testDate, eloScore: 1400.0),
        ];

        // Act
        final listItems = converter.convertTasksToListItems(tasks, listId: 'batch-list');

        // Assert
        expect(listItems, hasLength(2));
        expect(listItems[0].listId, equals('batch-list'));
        expect(listItems[1].listId, equals('batch-list'));
        expect(listItems[1].eloScore, equals(1400.0));
      });
    });
  });
}