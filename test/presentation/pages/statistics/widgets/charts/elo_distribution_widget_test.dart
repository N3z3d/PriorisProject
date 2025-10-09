import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/pages/statistics/widgets/charts/elo_distribution_widget.dart';

void main() {
  group('EloDistributionWidget', () {
    final testTasks = [
      Task(id: '1', title: 'Facile', eloScore: 1100),
      Task(id: '2', title: 'Moyenne', eloScore: 1300),
      Task(id: '3', title: 'Difficile', eloScore: 1500),
      Task(id: '4', title: 'Très difficile', eloScore: 1650),
      Task(id: '5', title: 'Expert', eloScore: 1820),
    ];

    Widget createTestWidget({List<Task>? tasks}) {
      return MaterialApp(
        home: Scaffold(
          body: EloDistributionWidget(tasks: tasks ?? testTasks),
        ),
      );
    }

    testWidgets('affiche le titre et le graphique', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('�Y"S Distribution ELO'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(
        find.text('Répartition de la difficulté de vos tâches en fonction de leur score ELO.'),
        findsOneWidget,
      );
    });

    testWidgets('affiche un message lorsque la liste est vide', (tester) async {
      await tester.pumpWidget(createTestWidget(tasks: []));

      expect(find.text('�Y"S Distribution ELO'), findsOneWidget);
      expect(find.text('Aucune tâche'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('affiche la légende avec les bonnes tranches', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('1000 - 1199'), findsOneWidget);
      expect(find.text('1200 - 1399'), findsOneWidget);
      expect(find.text('1400 - 1599'), findsOneWidget);
      expect(find.text('1600 - 1799'), findsOneWidget);
      expect(find.text('1800+'), findsOneWidget);
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

    testWidgets('met à jour le compteur lorsque les tâches changent', (tester) async {
      await tester.pumpWidget(createTestWidget(tasks: testTasks.take(2).toList()));

      expect(find.text('2'), findsOneWidget);
    });
  });
}
