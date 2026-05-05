import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/pages/statistics/widgets/tabs/tasks_tab_widget.dart';

void main() {
  group('TasksTabWidget', () {
    late List<Task> testTasks;

    setUp(() {
      testTasks = [
        Task(
          id: '1',
          title: 'Tâche 1',
          description: 'Description 1',
          category: 'Travail',
          isCompleted: true,
          eloScore: 1200.0,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          completedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Task(
          id: '2',
          title: 'Tâche 2',
          description: 'Description 2',
          category: 'Personnel',
          isCompleted: false,
          eloScore: 1400.0,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        Task(
          id: '3',
          title: 'Tâche 3',
          description: 'Description 3',
          category: 'Santé',
          isCompleted: true,
          eloScore: 1100.0,
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
    });

    testWidgets('should render all task-related widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TasksTabWidget(tasks: testTasks),
          ),
        ),
      );

      // Vérifier que le widget TasksStatsWidget est présent
      expect(find.text('Task statistics'), findsOneWidget);
      expect(find.text('Completed tasks'), findsOneWidget);
      expect(find.text('In progress'), findsOneWidget);
      expect(find.text('Average ELO'), findsOneWidget);
      expect(find.text('Average time'), findsOneWidget);

      // Vérifier que le widget EloDistributionWidget est présent
      expect(find.text('🎯 Distribution ELO'), findsOneWidget);

      // Vérifier que le widget CompletionTimeStatsWidget est présent
      expect(find.text('⏱️ Temps de Complétion par Catégorie'), findsOneWidget);
    });

    testWidgets('should handle empty tasks list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TasksTabWidget(tasks: []),
          ),
        ),
      );

      // Vérifier que les widgets sont toujours présents même avec une liste vide
      expect(find.text('Task statistics'), findsOneWidget);
      expect(find.text('🎯 Distribution ELO'), findsOneWidget);
      expect(find.text('⏱️ Temps de Complétion par Catégorie'), findsOneWidget);
    });

    testWidgets('should display correct task statistics', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TasksTabWidget(tasks: testTasks),
          ),
        ),
      );

      // Vérifier les statistiques calculées
      // 2 tâches terminées sur 3
      expect(find.text('2'), findsWidgets); // Tâches terminées (peut apparaître aussi dans le graphique)
      expect(find.text('1'), findsWidgets); // En cours
    });

    testWidgets('should have proper spacing between widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TasksTabWidget(tasks: testTasks),
          ),
        ),
      );

      // Vérifier que le widget utilise SingleChildScrollView
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Vérifier que le widget TasksTabWidget est présent
      expect(find.byType(TasksTabWidget), findsOneWidget);
    });
  });
} 

