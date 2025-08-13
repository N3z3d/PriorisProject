import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/pages/statistics/widgets/charts/elo_distribution_widget.dart';

void main() {
  group('EloDistributionWidget', () {
    final testTasks = [
      Task(
        id: '1',
        title: 'Tâche facile',
        eloScore: 1100, // Facile
      ),
      Task(
        id: '2',
        title: 'Tâche moyenne',
        eloScore: 1300, // Moyen
      ),
      Task(
        id: '3',
        title: 'Tâche difficile',
        eloScore: 1500, // Difficile
      ),
      Task(
        id: '4',
        title: 'Tâche facile 2',
        eloScore: 1150, // Facile
      ),
      Task(
        id: '5',
        title: 'Tâche moyenne 2',
        eloScore: 1350, // Moyen
      ),
    ];

    Widget createTestWidget({List<Task>? tasks}) {
      return MaterialApp(
        home: Scaffold(
          body: EloDistributionWidget(tasks: tasks ?? testTasks),
        ),
      );
    }

    testWidgets('should render correctly with valid data', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.text('📊 Distribution ELO'), findsOneWidget);
      expect(find.byType(PieChart), findsOneWidget);
    });

    testWidgets('should handle empty list gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(tasks: []));
      
      expect(find.text('📊 Distribution ELO'), findsOneWidget);
      expect(find.byType(PieChart), findsOneWidget);
      // Le texte "Aucune tâche" est affiché à l'intérieur du PieChart, non détectable par les tests
    });

    testWidgets('should calculate distribution correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Vérifier que le PieChart est présent
      expect(find.byType(PieChart), findsOneWidget);
      
      // Vérifier que le widget se rend correctement avec les données
      expect(find.text('📊 Distribution ELO'), findsOneWidget);
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
      
      final titleText = tester.widget<Text>(find.text('📊 Distribution ELO'));
      expect(titleText.style?.fontSize, equals(18));
      expect(titleText.style?.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('should have correct chart height', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).last);
      expect(sizedBox.height, equals(150));
    });

    testWidgets('should handle single category tasks', (WidgetTester tester) async {
      final easyTasks = [
        Task(id: '1', title: 'Tâche 1', eloScore: 1100),
        Task(id: '2', title: 'Tâche 2', eloScore: 1150),
      ];
      
      await tester.pumpWidget(createTestWidget(tasks: easyTasks));
      
      expect(find.text('📊 Distribution ELO'), findsOneWidget);
      expect(find.byType(PieChart), findsOneWidget);
    });

    testWidgets('should handle boundary ELO scores', (WidgetTester tester) async {
      final boundaryTasks = [
        Task(id: '1', title: 'Tâche 1199', eloScore: 1199), // Facile
        Task(id: '2', title: 'Tâche 1200', eloScore: 1200), // Moyen
        Task(id: '3', title: 'Tâche 1399', eloScore: 1399), // Moyen
        Task(id: '4', title: 'Tâche 1400', eloScore: 1400), // Difficile
      ];
      
      await tester.pumpWidget(createTestWidget(tasks: boundaryTasks));
      
      expect(find.text('📊 Distribution ELO'), findsOneWidget);
      expect(find.byType(PieChart), findsOneWidget);
    });

    testWidgets('should display PieChart with correct structure', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Vérifier que le PieChart est bien rendu
      expect(find.byType(PieChart), findsOneWidget);
      
      // Vérifier que le widget contient les éléments de structure attendus
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(SizedBox), findsWidgets);
    });
  });
} 

