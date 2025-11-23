import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/pages/duel/widgets/components/priority_duel_layouts.dart';

void main() {
  group('DuelFourCardsLayout', () {
    testWidgets(
      'uses a 2x2 grid without scroll on wide viewports',
      (tester) async {
        final tasks = List.generate(
          4,
          (index) => Task(
            id: 'task-$index',
            title: 'Task $index',
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(1280, 900)),
              child: SizedBox(
                width: 1280,
                height: 900,
                child: DuelFourCardsLayout(
                  tasks: tasks,
                  hideEloScores: false,
                  onSelectWinner: (_, __) async {},
                ),
              ),
            ),
          ),
        );

        expect(find.descendant(of: find.byType(DuelFourCardsLayout), matching: find.byType(SingleChildScrollView)), findsNothing);
        expect(find.byType(GridView), findsOneWidget);
        for (final task in tasks) {
          expect(find.byKey(ValueKey('duel-card-${task.id}')), findsOneWidget);
        }

        final firstCardSize =
            tester.getSize(find.byKey(const ValueKey('duel-card-task-0')));
        final ratio = firstCardSize.width / firstCardSize.height;
        expect(ratio, inInclusiveRange(1.5, 1.9));
      },
    );

    testWidgets(
      'keeps grid even when height is tight (no auto-scroll)',
      (tester) async {
        final tasks = List.generate(
          4,
          (index) => Task(
            id: 'task-$index',
            title: 'Task $index',
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(1200, 520)),
              child: SizedBox(
                width: 1200,
                height: 520,
                child: DuelFourCardsLayout(
                  tasks: tasks,
                  hideEloScores: false,
                  onSelectWinner: (_, __) async {},
                ),
              ),
            ),
          ),
        );

        expect(find.descendant(of: find.byType(DuelFourCardsLayout), matching: find.byType(SingleChildScrollView)), findsNothing);
        expect(find.byType(GridView), findsOneWidget);
        for (final task in tasks) {
          expect(find.byKey(ValueKey('duel-card-${task.id}')), findsOneWidget);
        }
      },
    );
  });
}
