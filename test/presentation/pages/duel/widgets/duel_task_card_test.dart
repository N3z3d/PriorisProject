import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/pages/duel/widgets/duel_task_card.dart';

void main() {
  Task _buildTask(String title) => Task(
        title: title,
        eloScore: 1200,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

  Future<void> _pumpCard(
    WidgetTester tester, {
    required DuelCardSize size,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 280,
              height: 220,
              child: DuelTaskCard(
                task: _buildTask('Titre centre'),
                onTap: () {},
                hideElo: false,
                cardSize: size,
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('centre le contenu pour les variantes compactes', (tester) async {
    for (final size in [DuelCardSize.compact3, DuelCardSize.compact4]) {
      await _pumpCard(tester, size: size);
      final column = tester.widget<Column>(
        find.byKey(const ValueKey('duel-card-content-column')),
      );
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
      expect(column.crossAxisAlignment, CrossAxisAlignment.center);
      expect(column.mainAxisSize, MainAxisSize.max);
    }
  });
}
