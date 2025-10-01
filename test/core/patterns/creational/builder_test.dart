import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/core/patterns/creational/builder.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

void main() {
  group('Builder Pattern', () {
    test('should build simple list item', () {
      // Arrange & Act
      final item = ListItemBuilder()
          .setTitle('Simple Task')
          .setDescription('A simple task description')
          .build();

      // Assert
      expect(item, isA<ListItem>());
      expect(item.title, equals('Simple Task'));
      expect(item.description, equals('A simple task description'));
      expect(item.category, isNull);
      expect(item.eloScore, equals(1200.0)); // Default
    });

    test('should build complex list item with all properties', () {
      // Arrange
      final dueDate = DateTime.now().add(const Duration(days: 7));
      final builder = ListItemBuilder();

      // Act
      final item = builder
          .setTitle('Complex Project')
          .setDescription('Multi-phase project with dependencies')
          .setCategory('Work')
          .setEloScore(1500.0)
          .setDueDate(dueDate)
          .setNotes('Important: coordinate with team')
          .build();

      // Assert
      expect(item.title, equals('Complex Project'));
      expect(item.description, equals('Multi-phase project with dependencies'));
      expect(item.category, equals('Work'));
      expect(item.eloScore, equals(1500.0));
      expect(item.dueDate, equals(dueDate));
      expect(item.notes, equals('Important: coordinate with team'));
      expect(item.isCompleted, isFalse);
    });

    test('should build urgent task using fluent interface', () {
      // Arrange & Act
      final urgentTask = ListItemBuilder()
          .setTitle('Emergency Fix')
          .setDescription('Critical bug fix needed')
          .setCategory('Urgent')
          .setEloScore(1600.0)
          .setDueDate(DateTime.now().add(const Duration(hours: 2)))
          .build();

      // Assert
      expect(urgentTask.title, equals('Emergency Fix'));
      expect(urgentTask.category, equals('Urgent'));
      expect(urgentTask.eloScore, equals(1600.0));
      expect(urgentTask.dueDate?.isBefore(DateTime.now().add(const Duration(hours: 3))), isTrue);
    });

    test('should reset builder after build', () {
      // Arrange
      final builder = ListItemBuilder();

      // Act
      final firstItem = builder
          .setTitle('First Item')
          .setCategory('Category 1')
          .build();

      final secondItem = builder
          .setTitle('Second Item')
          .build();

      // Assert
      expect(firstItem.title, equals('First Item'));
      expect(firstItem.category, equals('Category 1'));

      expect(secondItem.title, equals('Second Item'));
      expect(secondItem.category, isNull); // Should be reset
    });

    test('should use builder director for predefined configurations', () {
      // Arrange
      final director = ListItemBuilderDirector();

      // Act
      final personalTask = director.buildPersonalTask('Call Mom', 'Weekly check-in call');
      final workTask = director.buildWorkTask('Review Code', 'Code review for PR #123');
      final urgentTask = director.buildUrgentTask('Server Down', 'Production server needs restart');

      // Assert
      expect(personalTask.title, equals('Call Mom'));
      expect(personalTask.category, equals('Personal'));
      expect(personalTask.eloScore, equals(1200.0));

      expect(workTask.title, equals('Review Code'));
      expect(workTask.category, equals('Work'));
      expect(workTask.eloScore, equals(1350.0));

      expect(urgentTask.title, equals('Server Down'));
      expect(urgentTask.category, equals('Urgent'));
      expect(urgentTask.eloScore, equals(1600.0));
    });

    test('should validate required fields', () {
      // Arrange
      final builder = ListItemBuilder();

      // Act & Assert
      expect(
        () => builder.setDescription('Missing title').build(),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should create complex workflow with multiple builders', () {
      // Arrange
      final director = ListItemBuilderDirector();

      // Act
      final workflow = director.buildProjectWorkflow(
        'Mobile App Development',
        'Complete mobile app with backend integration',
      );

      // Assert
      expect(workflow.length, equals(4));
      expect(workflow.keys, containsAll(['planning', 'development', 'testing', 'deployment']));

      final planningTask = workflow['planning']!;
      expect(planningTask.title, contains('Planning'));
      expect(planningTask.category, equals('Planning'));

      final deploymentTask = workflow['deployment']!;
      expect(deploymentTask.title, contains('Deployment'));
      expect(deploymentTask.category, equals('DevOps'));
    });

    test('should clone existing item and modify', () async {
      // Arrange
      final originalItem = ListItemBuilder()
          .setTitle('Original Task')
          .setCategory('Original')
          .setEloScore(1300.0)
          .build();

      // Add small delay to ensure different timestamps
      await Future.delayed(const Duration(milliseconds: 1));

      // Act
      final clonedItem = ListItemBuilder.fromExisting(originalItem)
          .setTitle('Cloned Task')
          .setEloScore(1400.0)
          .build();

      // Assert
      expect(clonedItem.title, equals('Cloned Task'));
      expect(clonedItem.category, equals('Original')); // Preserved from original
      expect(clonedItem.eloScore, equals(1400.0)); // Modified
      expect(clonedItem.id, isNot(equals(originalItem.id))); // New ID
    });
  });
}