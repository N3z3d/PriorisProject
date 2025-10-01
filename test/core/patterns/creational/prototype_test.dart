import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/core/patterns/creational/prototype.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

void main() {
  group('Prototype Pattern', () {
    test('should clone basic list item', () async {
      // Arrange
      final original = PrototypeListItem(
        id: 'original-123',
        title: 'Original Task',
        description: 'Original description',
        category: 'Work',
        eloScore: 1350.0,
        createdAt: DateTime.now(),
      );

      // Small delay to ensure different timestamps
      await Future.delayed(const Duration(milliseconds: 1));

      // Act
      final cloned = original.clone();

      // Assert
      expect(cloned, isA<PrototypeListItem>());
      expect(cloned.title, equals('Original Task'));
      expect(cloned.description, equals('Original description'));
      expect(cloned.category, equals('Work'));
      expect(cloned.eloScore, equals(1350.0));
      expect(cloned.id, isNot(equals(original.id))); // Different ID
      expect(cloned.createdAt, isNot(equals(original.createdAt))); // Different timestamp
    });

    test('should deep clone with nested properties', () {
      // Arrange
      final metadata = {'priority': 'high', 'tags': ['urgent', 'important']};
      final original = AdvancedPrototypeItem(
        id: 'advanced-123',
        title: 'Advanced Task',
        description: 'Complex task with metadata',
        metadata: metadata,
        createdAt: DateTime.now(),
      );

      // Act
      final cloned = original.clone();

      // Assert
      expect(cloned, isA<AdvancedPrototypeItem>());
      expect(cloned.metadata, equals(metadata));
      expect(cloned.metadata, isNot(same(metadata))); // Deep copy, not same reference

      // Modify original metadata to verify deep copy
      original.metadata['priority'] = 'low';
      expect(cloned.metadata['priority'], equals('high')); // Clone unchanged
    });

    test('should use prototype registry', () {
      // Arrange
      final registry = PrototypeRegistry();

      // Act
      final taskPrototype = registry.getPrototype('task');
      final habitPrototype = registry.getPrototype('habit');
      final notePrototype = registry.getPrototype('note');

      // Assert
      expect(taskPrototype, isA<PrototypeListItem>());
      expect(habitPrototype, isA<PrototypeListItem>());
      expect(notePrototype, isA<PrototypeListItem>());

      expect(taskPrototype.category, equals('Task'));
      expect(habitPrototype.category, equals('Habit'));
      expect(notePrototype.category, equals('Note'));
    });

    test('should register custom prototype', () {
      // Arrange
      final registry = PrototypeRegistry();
      final customPrototype = PrototypeListItem(
        id: 'custom-prototype',
        title: 'Custom Template',
        description: 'Custom prototype description',
        category: 'Custom',
        eloScore: 1500.0,
        createdAt: DateTime.now(),
      );

      // Act
      registry.registerPrototype('custom', customPrototype);
      final cloned = registry.getPrototype('custom');

      // Assert
      expect(cloned.title, equals('Custom Template'));
      expect(cloned.category, equals('Custom'));
      expect(cloned.eloScore, equals(1500.0));
      expect(cloned.id, isNot(equals(customPrototype.id))); // New ID
    });

    test('should throw exception for unknown prototype', () {
      // Arrange
      final registry = PrototypeRegistry();

      // Act & Assert
      expect(
        () => registry.getPrototype('unknown'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should create prototype manager with templates', () {
      // Arrange
      final manager = PrototypeManager();

      // Act
      final urgentTask = manager.createFromTemplate(
        'urgent',
        title: 'Emergency Fix',
        description: 'Critical system issue',
      );

      final routineHabit = manager.createFromTemplate(
        'routine',
        title: 'Daily Standup',
        description: '15-minute team meeting',
      );

      final projectNote = manager.createFromTemplate(
        'project',
        title: 'Project Planning',
        description: 'Initial project requirements',
      );

      // Assert
      expect(urgentTask.title, equals('Emergency Fix'));
      expect(urgentTask.category, equals('Urgent'));
      expect(urgentTask.eloScore, equals(1600.0));

      expect(routineHabit.title, equals('Daily Standup'));
      expect(routineHabit.category, equals('Routine'));
      expect(routineHabit.eloScore, equals(1250.0));

      expect(projectNote.title, equals('Project Planning'));
      expect(projectNote.category, equals('Project'));
      expect(projectNote.eloScore, equals(1300.0));
    });

    test('should create variations with modifications', () {
      // Arrange
      final manager = PrototypeManager();

      // Act
      final baseTask = manager.createFromTemplate(
        'task',
        title: 'Base Task',
        description: 'Standard task',
      );

      final urgentVariation = manager.createVariation(
        baseTask,
        {
          'category': 'Urgent',
          'eloScore': 1700.0,
          'title': 'Urgent Task',
        },
      );

      // Assert
      expect(baseTask.title, equals('Base Task'));
      expect(baseTask.category, equals('Task'));
      expect(baseTask.eloScore, equals(1200.0));

      expect(urgentVariation.title, equals('Urgent Task'));
      expect(urgentVariation.category, equals('Urgent'));
      expect(urgentVariation.eloScore, equals(1700.0));
      expect(urgentVariation.id, isNot(equals(baseTask.id)));
    });

    test('should batch create from prototypes', () {
      // Arrange
      final manager = PrototypeManager();
      final taskInfos = [
        {'title': 'Task 1', 'description': 'First task'},
        {'title': 'Task 2', 'description': 'Second task'},
        {'title': 'Task 3', 'description': 'Third task'},
      ];

      // Act
      final tasks = manager.batchCreate('task', taskInfos);

      // Assert
      expect(tasks.length, equals(3));
      expect(tasks[0].title, equals('Task 1'));
      expect(tasks[1].title, equals('Task 2'));
      expect(tasks[2].title, equals('Task 3'));

      // All should have same category and eloScore from template
      for (final task in tasks) {
        expect(task.category, equals('Task'));
        expect(task.eloScore, equals(1200.0));
      }

      // All should have unique IDs
      final ids = tasks.map((t) => t.id).toSet();
      expect(ids.length, equals(3));
    });
  });
}