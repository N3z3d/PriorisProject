import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/core/patterns/creational/abstract_factory.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

void main() {
  group('Abstract Factory Pattern', () {
    test('should create personal productivity items', () {
      // Arrange
      final factory = PersonalProductivityFactory();

      // Act
      final task = factory.createTask('Learn Flutter', 'Study Flutter documentation');
      final habit = factory.createHabit('Daily Exercise', '30 min workout');
      final note = factory.createNote('Meeting Notes', 'Important meeting points');

      // Assert
      expect(task, isA<ListItem>());
      expect(habit, isA<ListItem>());
      expect(note, isA<ListItem>());

      expect(task.title, equals('Learn Flutter'));
      expect(task.category, equals('Personal'));
      expect(task.eloScore, equals(1200.0));

      expect(habit.title, equals('Daily Exercise'));
      expect(habit.category, equals('Health'));
      expect(habit.eloScore, equals(1300.0));

      expect(note.title, equals('Meeting Notes'));
      expect(note.category, equals('Notes'));
      expect(note.eloScore, equals(1100.0));
    });

    test('should create business workflow items', () {
      // Arrange
      final factory = BusinessWorkflowFactory();

      // Act
      final task = factory.createTask('Complete Report', 'Quarterly business report');
      final habit = factory.createHabit('Team Standup', 'Daily team meeting');
      final note = factory.createNote('Client Requirements', 'Project requirements');

      // Assert
      expect(task, isA<ListItem>());
      expect(habit, isA<ListItem>());
      expect(note, isA<ListItem>());

      expect(task.title, equals('Complete Report'));
      expect(task.category, equals('Business'));
      expect(task.eloScore, equals(1400.0));

      expect(habit.title, equals('Team Standup'));
      expect(habit.category, equals('Professional'));
      expect(habit.eloScore, equals(1350.0));

      expect(note.title, equals('Client Requirements'));
      expect(note.category, equals('Business Documentation'));
      expect(note.eloScore, equals(1250.0));
    });

    test('should create items through factory provider', () {
      // Arrange
      final provider = ProductivityFactoryProvider();

      // Act
      final personalFactory = provider.getFactory(WorkflowType.personal);
      final businessFactory = provider.getFactory(WorkflowType.business);

      final personalTask = personalFactory.createTask('Personal Task', 'Description');
      final businessTask = businessFactory.createTask('Business Task', 'Description');

      // Assert
      expect(personalTask.category, equals('Personal'));
      expect(businessTask.category, equals('Business'));
      expect(personalTask.eloScore, equals(1200.0));
      expect(businessTask.eloScore, equals(1400.0));
    });

    test('should throw exception for unknown workflow type', () {
      // Arrange
      final provider = ProductivityFactoryProvider();

      // Act & Assert
      expect(
        () => provider.getFactory(WorkflowType.unknown),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('should register custom factory', () {
      // Arrange
      final provider = ProductivityFactoryProvider();
      final customFactory = CustomWorkflowFactory();

      // Act
      provider.registerFactory(WorkflowType.custom, customFactory);
      final factory = provider.getFactory(WorkflowType.custom);
      final task = factory.createTask('Custom Task', 'Custom description');

      // Assert
      expect(task.category, equals('Custom'));
      expect(task.eloScore, equals(1500.0));
    });

    test('should get available workflow types', () {
      // Arrange
      final provider = ProductivityFactoryProvider();

      // Act
      final types = provider.getAvailableTypes();

      // Assert
      expect(types, contains(WorkflowType.personal));
      expect(types, contains(WorkflowType.business));
      expect(types.length, equals(2));
    });
  });
}

// Test factory for custom workflow
class CustomWorkflowFactory implements ProductivityAbstractFactory {
  @override
  ListItem createTask(String title, String description) {
    return ListItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      category: 'Custom',
      eloScore: 1500.0,
      createdAt: DateTime.now(),
    );
  }

  @override
  ListItem createHabit(String title, String description) {
    return ListItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      category: 'Custom Habit',
      eloScore: 1450.0,
      createdAt: DateTime.now(),
    );
  }

  @override
  ListItem createNote(String title, String content) {
    return ListItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: content,
      category: 'Custom Note',
      eloScore: 1350.0,
      createdAt: DateTime.now(),
    );
  }
}