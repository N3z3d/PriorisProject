import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/sample_data/sample_data_stats_display.dart';

void main() {
  group('SampleDataStatsDisplay', () {
    const testStats = {
      'tasks': 10,
      'habits': 5,
      'total': 15,
    };

    testWidgets('should display all statistics correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SampleDataStatsDisplay(stats: testStats),
          ),
        ),
      );

      // Vérifier le titre
      expect(find.text('Cette action importera :'), findsOneWidget);
      
      // Vérifier les statistiques
      expect(find.text('10 tâches d\'exemple'), findsOneWidget);
      expect(find.text('5 habitudes d\'exemple'), findsOneWidget);
      expect(find.text('Total: 15 éléments'), findsOneWidget);
    });

    testWidgets('should display correct icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SampleDataStatsDisplay(stats: testStats),
          ),
        ),
      );

      // Vérifier les icônes
      expect(find.byIcon(Icons.task_alt), findsOneWidget);
      expect(find.byIcon(Icons.track_changes), findsOneWidget);
      expect(find.byIcon(Icons.analytics), findsOneWidget);
    });

    testWidgets('should have correct layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SampleDataStatsDisplay(stats: testStats),
          ),
        ),
      );

      // Vérifier la structure Column
      expect(find.byType(Column), findsOneWidget);
      
      // Vérifier les Rows pour chaque statistique
      expect(find.byType(Row), findsNWidgets(3));
      
      // Vérifier les SizedBox pour l'espacement
      expect(find.byType(SizedBox), findsAtLeastNWidgets(2));
    });

    testWidgets('should handle different stats values', (WidgetTester tester) async {
      const differentStats = {
        'tasks': 0,
        'habits': 100,
        'total': 100,
      };

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SampleDataStatsDisplay(stats: differentStats),
          ),
        ),
      );

      expect(find.text('0 tâches d\'exemple'), findsOneWidget);
      expect(find.text('100 habitudes d\'exemple'), findsOneWidget);
      expect(find.text('Total: 100 éléments'), findsOneWidget);
    });

    testWidgets('should have correct text styling for title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SampleDataStatsDisplay(stats: testStats),
          ),
        ),
      );

      final titleText = tester.widget<Text>(find.text('Cette action importera :'));
      expect(titleText.style?.fontWeight, FontWeight.w600);
    });
  });
} 
