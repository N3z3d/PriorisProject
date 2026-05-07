import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/pages/habits/components/habit_progress_display.dart';

import '../../../../helpers/localized_widget.dart';

void main() {
  group('HabitProgressDisplay', () {
    late Habit testHabit;

    setUp(() {
      testHabit = Habit(
        id: '1',
        name: 'Test Habit',
        type: HabitType.binary,
        completions: {},
      );
    });

    testWidgets('affiche correctement "0/7 jours réussis" sans garble',
        (tester) async {
      await tester.pumpWidget(localizedApp(HabitProgressDisplay(habit: testHabit)));
      await tester.pumpAndSettle();
      // Vérifie qu'aucun caractère corrompu n'est présent
      expect(find.textContaining('Ã'), findsNothing,
          reason: 'Garble UTF-8 détecté — vérifier l10n.habitProgressSuccessfulDays');
      // Vérifie que le format attendu est présent
      expect(find.textContaining('/7'), findsOneWidget);
    });

    testWidgets('affiche le pourcentage et la barre de progression', (tester) async {
      await tester.pumpWidget(localizedApp(HabitProgressDisplay(habit: testHabit)));
      await tester.pumpAndSettle();
      expect(find.textContaining('%'), findsOneWidget);
      expect(find.byType(FractionallySizedBox), findsOneWidget);
    });

    testWidgets('hauteur de la carte bornée — container interne < 130px',
        (tester) async {
      await tester.pumpWidget(
        localizedApp(
          SizedBox(width: 400, child: HabitProgressDisplay(habit: testHabit)),
        ),
      );
      await tester.pumpAndSettle();
      final size = tester.getSize(find.byType(HabitProgressDisplay));
      expect(size.height, lessThan(130),
          reason: 'HabitProgressDisplay trop haut : ${size.height}px > 130px');
    });
  });
}
