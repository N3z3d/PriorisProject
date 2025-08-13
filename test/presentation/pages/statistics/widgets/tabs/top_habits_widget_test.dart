import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/pages/statistics/widgets/smart/top_habits_widget.dart';

void main() {
  group('TopHabitsWidget', () {
    final testHabits = [
      const TopHabit(name: '🧘 Méditation matinale', percentage: '95%', rank: 1),
      const TopHabit(name: '💧 Boire 2L d\'eau', percentage: '88%', rank: 2),
      const TopHabit(name: '🏃 Exercice physique', percentage: '82%', rank: 3),
      const TopHabit(name: '📚 Lecture quotidienne', percentage: '75%', rank: 4),
      const TopHabit(name: '💪 Pompes', percentage: '68%', rank: 5),
    ];

    Widget createTestWidget({List<TopHabit>? habits}) {
      return MaterialApp(
        home: Scaffold(
          body: TopHabitsWidget(topHabits: habits ?? testHabits),
        ),
      );
    }

    testWidgets('should render correctly with valid data', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.text('🏆 Top 5 Habitudes'), findsOneWidget);
      for (final habit in testHabits) {
        expect(find.text(habit.name), findsOneWidget);
        expect(find.text(habit.percentage), findsOneWidget);
        expect(find.text('${habit.rank}'), findsOneWidget);
      }
    });

    testWidgets('should handle empty list gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(habits: []));
      expect(find.text('🏆 Top 5 Habitudes'), findsOneWidget);
      // Aucun nom d'habitude ne doit être affiché
      expect(find.byType(Row), findsNothing);
      expect(find.byType(Text), findsOneWidget); // Seulement le titre
    });

    testWidgets('should display correct number of items', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      // Il y a 5 items + le titre
      expect(find.byType(Row), findsNWidgets(5));
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
      final titleText = tester.widget<Text>(find.text('🏆 Top 5 Habitudes'));
      expect(titleText.style?.fontSize, equals(18));
      expect(titleText.style?.fontWeight, equals(FontWeight.bold));
    });
  });
} 
