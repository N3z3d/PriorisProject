import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/pages/habits/components/habit_card.dart';
import 'package:prioris/presentation/pages/habits/components/habits_list.dart';
import '../../../../helpers/localized_widget.dart';

Widget _buildList({
  required List<Habit> habits,
  Set<String> recordingHabitIds = const {},
}) {
  return localizedApp(
    HabitsList(
      habits: habits,
      recordingHabitIds: recordingHabitIds,
      onDeleteHabit: (_, __) {},
      onRecordHabit: (_) async {},
      onRecordValue: (_, __) async {},
      onCreateHabit: () {},
      onEditHabit: (_) {},
    ),
  );
}

void main() {
  group('HabitsList → HabitCard — propagation isRecording', () {
    testWidgets(
      'T5.1 — habit en cours de recording → sa HabitCard reçoit isRecording=true (bouton disabled)',
      (tester) async {
        final recording = Habit(name: 'Yoga', type: HabitType.binary);
        final other = Habit(name: 'Lecture', type: HabitType.binary);

        await tester.pumpWidget(
          _buildList(
            habits: [recording, other],
            recordingHabitIds: {recording.id},
          ),
        );

        // La carte Yoga doit avoir son bouton disabled
        final yogaCard = find.ancestor(
          of: find.text('Yoga'),
          matching: find.byType(HabitCard),
        );
        expect(yogaCard, findsOneWidget);

        final yogaButton = find.descendant(
          of: yogaCard,
          matching: find.byWidgetPredicate(
            (w) => w is IconButton && (w.tooltip?.contains('Marquer') ?? false),
          ),
        );
        expect(tester.widget<IconButton>(yogaButton).onPressed, isNull,
            reason: 'HabitsList doit propager isRecording=true à la carte Yoga');

        // La carte Lecture doit avoir son bouton actif
        final lectureCard = find.ancestor(
          of: find.text('Lecture'),
          matching: find.byType(HabitCard),
        );
        final lectureButton = find.descendant(
          of: lectureCard,
          matching: find.byWidgetPredicate(
            (w) => w is IconButton && (w.tooltip?.contains('Marquer') ?? false),
          ),
        );
        expect(tester.widget<IconButton>(lectureButton).onPressed, isNotNull,
            reason: 'HabitsList ne doit PAS marquer Lecture comme recording');
      },
    );

    testWidgets(
      'T5.2 — aucun habit en recording → tous les boutons actifs',
      (tester) async {
        final h1 = Habit(name: 'Sport', type: HabitType.binary);
        final h2 = Habit(name: 'Méditation', type: HabitType.binary);

        await tester.pumpWidget(
          _buildList(habits: [h1, h2]),
        );

        final buttons = find.byWidgetPredicate(
          (w) => w is IconButton && (w.tooltip?.contains('Marquer') ?? false),
        );
        for (final btn in tester.widgetList<IconButton>(buttons)) {
          expect(btn.onPressed, isNotNull,
              reason: 'Tous les boutons doivent être actifs sans recordingHabitIds');
        }
      },
    );

    testWidgets(
      'T5.3 — deux habits en recording simultanément → deux boutons disabled',
      (tester) async {
        final h1 = Habit(name: 'Sport', type: HabitType.binary);
        final h2 = Habit(name: 'Méditation', type: HabitType.binary);
        final h3 = Habit(name: 'Lecture', type: HabitType.binary);

        await tester.pumpWidget(
          _buildList(
            habits: [h1, h2, h3],
            recordingHabitIds: {h1.id, h2.id},
          ),
        );

        IconButton _buttonFor(String name) {
          final card = find.ancestor(
            of: find.text(name),
            matching: find.byType(HabitCard),
          );
          final btn = find.descendant(
            of: card,
            matching: find.byWidgetPredicate(
              (w) => w is IconButton && (w.tooltip?.contains('Marquer') ?? false),
            ),
          );
          return tester.widget<IconButton>(btn);
        }

        expect(_buttonFor('Sport').onPressed, isNull);
        expect(_buttonFor('Méditation').onPressed, isNull);
        expect(_buttonFor('Lecture').onPressed, isNotNull);
      },
    );
  });
}
