import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/pages/habits/components/habit_avatar.dart';

import '../../../../helpers/localized_widget.dart';

void main() {
  group('HabitAvatar', () {
    testWidgets('catégorie inconnue → pas d\'icône étoile', (tester) async {
      final habit = Habit(
        id: '1',
        name: 'Test',
        type: HabitType.binary,
        category: 'catégorie_inconnue',
        completions: {},
      );
      await tester.pumpWidget(localizedApp(HabitAvatar(habit: habit)));
      await tester.pumpAndSettle();
      // Aucune icône star — doit utiliser Icons.track_changes_rounded
      final icon = tester.widget<Icon>(
        find.descendant(of: find.byType(HabitAvatar), matching: find.byType(Icon)),
      );
      expect(icon.icon, isNot(equals(Icons.star)),
          reason: 'Icons.star ne doit plus apparaître par défaut');
      expect(icon.icon, equals(Icons.track_changes_rounded));
    });

    testWidgets('catégorie null → pas d\'icône étoile', (tester) async {
      final habit = Habit(
        id: '2',
        name: 'Test',
        type: HabitType.binary,
        completions: {},
      );
      await tester.pumpWidget(localizedApp(HabitAvatar(habit: habit)));
      await tester.pumpAndSettle();
      final icon = tester.widget<Icon>(
        find.descendant(of: find.byType(HabitAvatar), matching: find.byType(Icon)),
      );
      expect(icon.icon, isNot(equals(Icons.star)));
      expect(icon.icon, equals(Icons.track_changes_rounded));
    });
  });
}
