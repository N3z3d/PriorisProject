import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:prioris/presentation/pages/statistics/widgets/charts/streaks_chart_widget.dart';

void main() {
  group('StreaksChartWidget', () {
    const testHabitNames = ['Méditation', 'Sport', 'Lecture', 'Eau'];
    const testStreakData = [12.0, 8.0, 15.0, 6.0];

    Widget createTestWidget({
      List<String>? habitNames,
      List<double>? streakData,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: StreaksChartWidget(
            habitNames: habitNames ?? testHabitNames,
            streakData: streakData ?? testStreakData,
          ),
        ),
      );
    }

    testWidgets('should render correctly with valid data', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Vérifier que le titre est affiché
      expect(find.text('🔥 Évolution des Séries'), findsOneWidget);

      // Vérifier que le graphique est présent
      expect(find.byType(BarChart), findsOneWidget);

      // Vérifier que les noms d'habitudes sont affichés
      for (final habitName in testHabitNames) {
        expect(find.text(habitName), findsOneWidget);
      }
    });

    testWidgets('should handle empty data gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        habitNames: [],
        streakData: [],
      ));

      // Vérifier que le widget se rend sans erreur
      expect(find.text('🔥 Évolution des Séries'), findsOneWidget);
      expect(find.byType(BarChart), findsOneWidget);
    });

    testWidgets('should handle single habit data', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        habitNames: ['Méditation'],
        streakData: [10.0],
      ));

      expect(find.text('Méditation'), findsOneWidget);
      expect(find.byType(BarChart), findsOneWidget);
    });

    testWidgets('should handle different data lengths', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        habitNames: ['Habit1', 'Habit2'],
        streakData: [5.0, 10.0, 15.0], // Plus de données que de noms
      ));

      // Le widget devrait se rendre sans erreur
      expect(find.text('🔥 Évolution des Séries'), findsOneWidget);
      expect(find.byType(BarChart), findsOneWidget);
    });

    testWidgets('should have correct card styling', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final card = tester.widget<Card>(find.byType(Card));
      
      expect(card.elevation, equals(4));
      expect(card.shape, isA<RoundedRectangleBorder>());
    });

    testWidgets('should have correct padding', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Trouver le Card
      final cardFinder = find.byType(Card);
      expect(cardFinder, findsOneWidget);

      // Trouver le Padding dont le parent est le Card
      final paddingFinder = find.descendant(
        of: cardFinder,
        matching: find.byType(Padding),
      );
      expect(paddingFinder, findsWidgets);

      // Vérifier qu'au moins un Padding a le bon EdgeInsets
      final paddings = tester.widgetList<Padding>(paddingFinder);
      final hasCorrectPadding = paddings.any((p) => p.padding == const EdgeInsets.all(20));
      expect(hasCorrectPadding, isTrue);
    });

    testWidgets('should have correct chart height', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).last);
      expect(sizedBox.height, equals(150));
    });

    testWidgets('should display habit names with correct font size', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Vérifier que les noms d'habitudes sont affichés avec la bonne taille de police
      for (final habitName in testHabitNames) {
        final textWidget = tester.widget<Text>(find.text(habitName));
        expect(textWidget.style?.fontSize, equals(10));
      }
    });

    testWidgets('should have correct title styling', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final titleText = tester.widget<Text>(find.text('🔥 Évolution des Séries'));
      expect(titleText.style?.fontSize, equals(18));
      expect(titleText.style?.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('should render BarChart with correct structure', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Vérifier que le BarChart est bien rendu
      expect(find.byType(BarChart), findsOneWidget);
      
      // Vérifier que le widget contient les éléments de structure attendus
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(SizedBox), findsWidgets);
    });
  });
} 
