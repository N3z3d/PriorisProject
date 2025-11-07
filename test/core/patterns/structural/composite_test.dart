import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/core/patterns/structural/composite.dart';

void main() {
  group('Composite Pattern', () {
    test('should create and manage task leaf', () {
      // Arrange & Act
      final task = TaskLeaf(
        id: 'task1',
        name: 'Complete Documentation',
        description: 'Write comprehensive docs',
        eloScore: 1300.0,
      );

      // Assert
      expect(task.getName(), equals('Complete Documentation'));
      expect(task.getTotalScore(), equals(1300.0));
      expect(task.getItemCount(), equals(1));
      expect(task.isCompleted(), isFalse);
      expect(task.getCompletionPercentage(), equals(0.0));
    });

    test('should create and manage project composite', () {
      // Arrange
      final project = ProjectComposite(
        id: 'proj1',
        name: 'Mobile App Development',
        description: 'Complete mobile app project',
      );

      final task1 = TaskLeaf(id: '1', name: 'Design UI', eloScore: 1200.0);
      final task2 = TaskLeaf(id: '2', name: 'Implement Backend', eloScore: 1400.0);

      // Act
      project.addChild(task1);
      project.addChild(task2);

      // Assert
      expect(project.getName(), equals('Mobile App Development'));
      expect(project.getTotalScore(), equals(2600.0)); // 1200 + 1400
      expect(project.getItemCount(), equals(2));
      expect(project.isCompleted(), isFalse);
      expect(project.getChildren().length, equals(2));
    });

    test('should calculate completion percentage correctly', () {
      // Arrange
      final project = ProjectComposite(id: 'proj1', name: 'Test Project');
      final task1 = TaskLeaf(id: '1', name: 'Task 1', isCompleted: true);
      final task2 = TaskLeaf(id: '2', name: 'Task 2', isCompleted: false);
      final task3 = TaskLeaf(id: '3', name: 'Task 3', isCompleted: true);

      project.addChild(task1);
      project.addChild(task2);
      project.addChild(task3);

      // Act & Assert
      expect(project.getCompletionPercentage(), equals(2.0 / 3.0)); // 2 of 3 completed
    });

    test('should handle nested composite structure', () {
      // Arrange
      final rootProject = ProjectComposite(id: 'root', name: 'Root Project');
      final subProject1 = ProjectComposite(id: 'sub1', name: 'Frontend');
      final subProject2 = ProjectComposite(id: 'sub2', name: 'Backend');

      final uiTask = TaskLeaf(id: '1', name: 'UI Design', eloScore: 1200.0);
      final apiTask = TaskLeaf(id: '2', name: 'API Development', eloScore: 1500.0);
      final dbTask = TaskLeaf(id: '3', name: 'Database Setup', eloScore: 1300.0);

      // Act - Build hierarchy
      subProject1.addChild(uiTask);
      subProject2.addChild(apiTask);
      subProject2.addChild(dbTask);
      rootProject.addChild(subProject1);
      rootProject.addChild(subProject2);

      // Assert
      expect(rootProject.getTotalScore(), equals(4000.0)); // 1200 + 1500 + 1300
      expect(rootProject.getItemCount(), equals(3)); // All leaf tasks
      expect(rootProject.getChildren().length, equals(2)); // Direct children
    });

    test('should find components by ID recursively', () {
      // Arrange
      final root = ProjectComposite(id: 'root', name: 'Root');
      final sub = ProjectComposite(id: 'sub', name: 'Sub Project');
      final task = TaskLeaf(id: 'task1', name: 'Deep Task');

      sub.addChild(task);
      root.addChild(sub);

      // Act
      final foundTask = root.findChildById('task1');
      final foundSub = root.findChildById('sub');

      // Assert
      expect(foundTask, isNotNull);
      expect(foundTask!.getName(), equals('Deep Task'));
      expect(foundSub, isNotNull);
      expect(foundSub!.getName(), equals('Sub Project'));
    });

    test('should use visitor pattern for statistics', () {
      // Arrange
      final project = ProjectComposite(id: 'proj', name: 'Test Project');
      final task1 = TaskLeaf(id: '1', name: 'Task 1', eloScore: 1200.0, isCompleted: true);
      final task2 = TaskLeaf(id: '2', name: 'Task 2', eloScore: 1400.0, isCompleted: false);

      project.addChild(task1);
      project.addChild(task2);

      final visitor = TaskStatisticsVisitor();

      // Act
      project.accept(visitor);
      final stats = visitor.getStatistics();

      // Assert
      expect(stats['total_tasks'], equals(2));
      expect(stats['completed_tasks'], equals(1));
      expect(stats['completion_rate'], equals(0.5));
      expect(stats['total_projects'], equals(1));
      expect(stats['total_score'], equals(2600.0));
    });

    test('should render tree structure with visitor', () {
      // Arrange
      final root = ProjectComposite(id: 'root', name: 'Root');
      final project = ProjectComposite(id: 'proj', name: 'Project');
      final task1 = TaskLeaf(id: '1', name: 'Task 1', isCompleted: true);
      final task2 = TaskLeaf(id: '2', name: 'Task 2', isCompleted: false);

      project.addChild(task1);
      project.addChild(task2);
      root.addChild(project);

      final visitor = TaskTreeRenderVisitor();

      // Act
      root.accept(visitor);
      final treeString = visitor.getTreeString();

      // Assert
      expect(treeString, contains('Root'));
      expect(treeString, contains('Project'));
      expect(treeString, contains('Task 1'));
      expect(treeString, contains('Task 2'));
      expect(treeString, contains('✓')); // Completed task
      expect(treeString, contains('✗')); // Incomplete task
    });

    test('should use hierarchy manager', () {
      // Arrange
      final manager = TaskHierarchyManager(rootName: 'My Projects');

      final project = manager.createProject(name: 'Web App');
      final task1 = manager.createTask(name: 'Setup Project', isCompleted: true);
      final task2 = manager.createTask(name: 'Develop Features');

      // Act
      project.addChild(task1);
      project.addChild(task2);
      manager.addProject(project);

      // Assert
      final stats = manager.getStatistics();
      expect(stats['total_tasks'], equals(2));
      expect(stats['completed_tasks'], equals(1));

      final treeString = manager.renderTree();
      expect(treeString, contains('My Projects'));
      expect(treeString, contains('Web App'));
    });

    test('should complete all tasks in composite', () {
      // Arrange
      final project = ProjectComposite(id: 'proj', name: 'Project');
      final task1 = TaskLeaf(id: '1', name: 'Task 1');
      final task2 = TaskLeaf(id: '2', name: 'Task 2');

      project.addChild(task1);
      project.addChild(task2);

      // Act
      project.setCompleted(true);

      // Assert
      expect(task1.isCompleted(), isTrue);
      expect(task2.isCompleted(), isTrue);
      expect(project.isCompleted(), isTrue);
      expect(project.getCompletionPercentage(), equals(1.0));
    });

    test('should get incomplete tasks from hierarchy', () {
      // Arrange
      final manager = TaskHierarchyManager();
      final project = manager.createProject(name: 'Test Project');

      final completedTask = manager.createTask(name: 'Done Task', isCompleted: true);
      final pendingTask1 = manager.createTask(name: 'Pending 1');
      final pendingTask2 = manager.createTask(name: 'Pending 2');

      project.addChild(completedTask);
      project.addChild(pendingTask1);
      project.addChild(pendingTask2);
      manager.addProject(project);

      // Act
      final incompleteTasks = manager.getIncompleteTasks();

      // Assert
      expect(incompleteTasks.length, equals(2));
      expect(incompleteTasks.map((t) => t.getName()), containsAll(['Pending 1', 'Pending 2']));
    });

    test('should export and handle JSON serialization', () {
      // Arrange
      final manager = TaskHierarchyManager(rootName: 'Export Test');
      final project = manager.createProject(name: 'Test Project');
      final task = manager.createTask(name: 'Test Task', eloScore: 1400.0);

      project.addChild(task);
      manager.addProject(project);

      // Act
      final json = manager.exportToJson();

      // Assert
      expect(json['type'], equals('composite'));
      expect(json['name'], equals('Export Test'));
      expect(json['children'], isA<List>());
      expect(json['totalScore'], equals(1400.0));
      expect(json['itemCount'], equals(1));
    });
  });
}

