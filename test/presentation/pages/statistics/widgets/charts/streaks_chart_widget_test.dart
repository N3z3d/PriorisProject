import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/pages/statistics/widgets/charts/streaks_chart_widget.dart';

void main() {
  group('StreaksChartWidget', () {
    final entries = [
      const StreakChartEntry(name: 'Méditation', streakLength: 12, category: 'Bien-être'),
      const StreakChartEntry(name: 'Sport', streakLength: 8, category: 'Santé'),
      const StreakChartEntry(name: 'Lecture', streakLength: 15, category: 'Apprentissage'),
      const StreakChartEntry(name: 'Hydratation', streakLength: 6, category: 'Santé'),
    ];

    Widget createTestWidget({List<StreakChartEntry>? streaks}) {
      return MaterialApp(
        home: Scaffold(
          body: StreaksChartWidget(
            entries: streaks ?? entries,
            period: const Duration(days: 30),
          ),
        ),
      );
    }

    testWidgets('affiche le titre et le graphique', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('�Y"� �%volution des SǸries'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      for (final entry in entries) {
        expect(find.text(entry.name), findsOneWidget);
      }
    });

    testWidgets('affiche un message lorsque la liste est vide', (tester) async {
      await tester.pumpWidget(createTestWidget(streaks: const []));

      expect(find.text('Aucune série enregistrée'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('utilise un Card avec padding interne', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, equals(4));
      expect(card.shape, isA<RoundedRectangleBorder>());

      final paddingFinder = find.descendant(
        of: find.byType(Card),
        matching: find.byType(Padding),
      );
      final paddings = tester.widgetList<Padding>(paddingFinder);
      final hasExpectedPadding = paddings.any((padding) => padding.padding == const EdgeInsets.all(20));
      expect(hasExpectedPadding, isTrue);
    });

    testWidgets('respecte la hauteur du graphique', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final sizedBoxFinder = find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == 150,
      );
      expect(sizedBoxFinder, findsOneWidget);
    });

    testWidgets('affiche les valeurs de streak dans la légende', (tester) async {
      await tester.pumpWidget(createTestWidget());

      for (final entry in entries) {
        expect(find.text('${entry.streakLength.toStringAsFixed(0)} jours'), findsOneWidget);
      }
    });
  });
}
