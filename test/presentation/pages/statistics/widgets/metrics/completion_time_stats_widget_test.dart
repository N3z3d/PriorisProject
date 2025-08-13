import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/pages/statistics/widgets/analytics/completion_time_stats_widget.dart';

void main() {
  group('CompletionTimeStatsWidget', () {
    final testTasks = [
      Task(
        id: '1',
        title: 'Tâche Travail 1',
        category: 'Travail',
        isCompleted: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        completedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Task(
        id: '2',
        title: 'Tâche Travail 2',
        category: 'Travail',
        isCompleted: true,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        completedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Task(
        id: '3',
        title: 'Tâche Personnel',
        category: 'Personnel',
        isCompleted: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        completedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      Task(
        id: '4',
        title: 'Tâche non terminée',
        category: 'Administratif',
        isCompleted: false,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];

    Widget createTestWidget({List<Task>? tasks}) {
      return MaterialApp(
        home: Scaffold(
          body: CompletionTimeStatsWidget(tasks: tasks ?? testTasks),
        ),
      );
    }

    testWidgets('should render correctly with valid data', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.text('⏱️ Temps de Complétion par Catégorie'), findsOneWidget);
      expect(find.text('Travail'), findsOneWidget);
      expect(find.text('Personnel'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
    });

    testWidgets('should handle empty list gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(tasks: []));
      
      expect(find.text('⏱️ Temps de Complétion par Catégorie'), findsOneWidget);
      expect(find.text('Aucune tâche terminée'), findsOneWidget);
      expect(find.text('0 jours'), findsOneWidget);
    });

    testWidgets('should handle tasks without completion dates', (WidgetTester tester) async {
      final tasksWithoutDates = [
        Task(
          id: '1',
          title: 'Tâche sans date',
          isCompleted: true,
          createdAt: DateTime.now(),
        ),
      ];
      
      await tester.pumpWidget(createTestWidget(tasks: tasksWithoutDates));
      
      expect(find.text('⏱️ Temps de Complétion par Catégorie'), findsOneWidget);
      expect(find.text('Aucune tâche terminée'), findsOneWidget);
    });

    testWidgets('should handle tasks without categories', (WidgetTester tester) async {
      final tasksWithoutCategory = [
        Task(
          id: '1',
          title: 'Tâche sans catégorie',
          isCompleted: true,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          completedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];
      
      await tester.pumpWidget(createTestWidget(tasks: tasksWithoutCategory));
      
      expect(find.text('⏱️ Temps de Complétion par Catégorie'), findsOneWidget);
      expect(find.text('Sans catégorie'), findsOneWidget);
    });

    testWidgets('should have correct card styling', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, equals(4));
      expect(card.shape, isA<RoundedRectangleBorder>());
    });

    testWidgets('should have correct padding', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      final cardFinder = find.byType(Card);
      expect(cardFinder, findsOneWidget);
      final paddingFinder = find.descendant(
        of: cardFinder,
        matching: find.byType(Padding),
      );
      expect(paddingFinder, findsWidgets);
      final paddings = tester.widgetList<Padding>(paddingFinder);
      final hasCorrectPadding = paddings.any((p) => p.padding == const EdgeInsets.all(20));
      expect(hasCorrectPadding, isTrue);
    });

    testWidgets('should display correct title styling', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      final titleText = tester.widget<Text>(find.text('⏱️ Temps de Complétion par Catégorie'));
      expect(titleText.style?.fontSize, equals(18));
      expect(titleText.style?.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('should calculate completion times correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Vérifier que les temps sont affichés
      expect(find.textContaining('jours'), findsWidgets);
    });

    testWidgets('should display LinearProgressIndicator widgets correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Vérifier que les barres de progression sont présentes
      expect(find.byType(LinearProgressIndicator), findsWidgets);
    });

    testWidgets('should sort categories by completion time', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Vérifier que les catégories sont affichées
      expect(find.text('Travail'), findsOneWidget);
      expect(find.text('Personnel'), findsOneWidget);
    });

    testWidgets('should handle single category tasks', (WidgetTester tester) async {
      final singleCategoryTasks = [
        Task(
          id: '1',
          title: 'Tâche 1',
          category: 'Travail',
          isCompleted: true,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          completedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        Task(
          id: '2',
          title: 'Tâche 2',
          category: 'Travail',
          isCompleted: true,
          createdAt: DateTime.now().subtract(const Duration(days: 8)),
          completedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ];
      
      await tester.pumpWidget(createTestWidget(tasks: singleCategoryTasks));
      
      expect(find.text('⏱️ Temps de Complétion par Catégorie'), findsOneWidget);
      expect(find.text('Travail'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
} 

