import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/pages/habits/components/habit_card.dart';
import 'package:prioris/presentation/widgets/dialogs/habit_record_dialog.dart';
import '../../../../helpers/localized_widget.dart';

Widget _buildCard({
  required Habit habit,
  VoidCallback? onRecord,
  Future<void> Function(Habit, double)? onRecordValue,
  VoidCallback? onEdit,
  VoidCallback? onDelete,
  VoidCallback? onTap,
  bool isRecording = false,
}) {
  return localizedApp(
    HabitCard(
      habit: habit,
      onRecord: onRecord ?? () {},
      onRecordValue: onRecordValue ?? (_, __) async {},
      onEdit: onEdit ?? () {},
      onDelete: onDelete ?? () {},
      onTap: onTap ?? () {},
      isRecording: isRecording,
    ),
  );
}

Habit _completedHabit() {
  final habit = Habit(name: 'Test Habit', type: HabitType.binary);
  habit.markCompleted(true);
  return habit;
}

Habit _quantitativeHabit({double? todayValue}) {
  final habit = Habit(
    name: 'Boire',
    type: HabitType.quantitative,
    targetValue: 8,
    unit: 'verres',
  );
  if (todayValue != null) {
    habit.recordValue(todayValue);
  }
  return habit;
}

Finder _findQuantButton() => find.byWidgetPredicate(
      (w) =>
          w is IconButton &&
          (w.tooltip?.contains('Enregistrer une valeur') ?? false),
    );

Finder _findRecordIcon() => find.byWidgetPredicate(
      (w) =>
          w is Icon &&
          (w.icon == Icons.check_circle || w.icon == Icons.check_circle_outline),
    );

Finder _findRecordButton() => find.byWidgetPredicate(
      (w) => w is IconButton && (w.tooltip?.contains('Marquer') ?? false),
    );

void main() {
  group('HabitCard — isRecording (Option C)', () {
    testWidgets('T4.1 — isRecording=true désactive le bouton', (tester) async {
      await tester.pumpWidget(
        _buildCard(
          habit: Habit(name: 'Test', type: HabitType.binary),
          isRecording: true,
        ),
      );
      final btn = tester.widget<IconButton>(_findRecordButton());
      expect(btn.onPressed, isNull);
    });

    testWidgets('T4.2 — isRecording=false laisse le bouton actif', (tester) async {
      bool called = false;
      await tester.pumpWidget(
        _buildCard(
          habit: Habit(name: 'Test', type: HabitType.binary),
          isRecording: false,
          onRecord: () => called = true,
        ),
      );
      final btn = tester.widget<IconButton>(_findRecordButton());
      expect(btn.onPressed, isNotNull);
      await tester.tap(_findRecordButton());
      await tester.pump();
      expect(called, isTrue);
    });

    testWidgets('T4.3 — isRecording omis (défaut) → bouton actif', (tester) async {
      await tester.pumpWidget(
        _buildCard(habit: Habit(name: 'Test', type: HabitType.binary)),
      );
      final btn = tester.widget<IconButton>(_findRecordButton());
      expect(btn.onPressed, isNotNull);
    });
  });

  group('HabitCard — bouton record direct', () {
    testWidgets('T3.1 — bouton record visible sans ouvrir le menu', (tester) async {
      await tester.pumpWidget(
        _buildCard(habit: Habit(name: 'Test', type: HabitType.binary)),
      );

      final checkButton = find.byWidgetPredicate(
        (w) => w is IconButton && (w.tooltip?.contains('Marquer') ?? false),
      );
      expect(checkButton, findsOneWidget);
    });

    testWidgets('T3.2 — affiche check_circle quand habit complété aujourd\'hui',
        (tester) async {
      await tester.pumpWidget(_buildCard(habit: _completedHabit()));

      final icon = tester.widget<Icon>(_findRecordIcon().first);
      expect(icon.icon, Icons.check_circle);
    });

    testWidgets('T3.3 — affiche check_circle_outline quand habit non complété',
        (tester) async {
      await tester.pumpWidget(
        _buildCard(habit: Habit(name: 'Test', type: HabitType.binary)),
      );

      final icon = tester.widget<Icon>(_findRecordIcon().first);
      expect(icon.icon, Icons.check_circle_outline);
    });

    testWidgets('T3.4 — taper le bouton appelle onRecord', (tester) async {
      bool recorded = false;
      await tester.pumpWidget(
        _buildCard(
          habit: Habit(name: 'Test', type: HabitType.binary),
          onRecord: () => recorded = true,
        ),
      );

      final checkButton = find.byWidgetPredicate(
        (w) => w is IconButton && (w.tooltip?.contains('Marquer') ?? false),
      );
      await tester.tap(checkButton);
      await tester.pump();

      expect(recorded, isTrue);
    });

    testWidgets('T3.5 — PopupMenuButton ne contient plus "Marquer comme fait"',
        (tester) async {
      await tester.pumpWidget(
        _buildCard(habit: Habit(name: 'Test', type: HabitType.binary)),
      );

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Marquer comme fait'), findsNothing);
    });

    testWidgets('T3.6 — PopupMenuButton contient toujours "Modifier" et "Supprimer"',
        (tester) async {
      await tester.pumpWidget(
        _buildCard(habit: Habit(name: 'Test', type: HabitType.binary)),
      );

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Modifier'), findsOneWidget);
      expect(find.text('Supprimer'), findsOneWidget);
    });
  });

  group('HabitCard — habitude quantitative (story 10.20)', () {
    testWidgets('Q1 — affiche le bouton "Enregistrer une valeur"',
        (tester) async {
      await tester.pumpWidget(_buildCard(habit: _quantitativeHabit()));
      expect(_findQuantButton(), findsOneWidget);
    });

    testWidgets('Q2 — non-régression : une habitude binaire n\'a pas ce bouton',
        (tester) async {
      await tester.pumpWidget(
        _buildCard(habit: Habit(name: 'Test', type: HabitType.binary)),
      );
      expect(_findQuantButton(), findsNothing);
    });

    testWidgets('Q3 — taper le bouton ouvre HabitRecordDialog (réutilisation)',
        (tester) async {
      await tester.pumpWidget(_buildCard(habit: _quantitativeHabit()));

      await tester.tap(_findQuantButton());
      await tester.pumpAndSettle();

      expect(find.byType(HabitRecordDialog), findsOneWidget);
    });

    testWidgets('Q4 — saisir une valeur et valider appelle onRecordValue(value)',
        (tester) async {
      double? saved;
      await tester.pumpWidget(
        _buildCard(
          habit: _quantitativeHabit(),
          onRecordValue: (_, value) async {
            saved = value;
          },
        ),
      );

      await tester.tap(_findQuantButton());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '5');
      await tester.pump(); // la saisie reactive le bouton Enregistrer
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(saved, 5.0);
    });

    testWidgets('Q5 — cible atteinte aujourd\'hui → icône check_circle',
        (tester) async {
      await tester.pumpWidget(
        _buildCard(habit: _quantitativeHabit(todayValue: 8)),
      );

      final icon = tester.widget<Icon>(
        find.descendant(of: _findQuantButton(), matching: find.byType(Icon)),
      );
      expect(icon.icon, Icons.check_circle);
    });

    testWidgets('Q6 — cible non atteinte → icône add_circle_outline',
        (tester) async {
      await tester.pumpWidget(
        _buildCard(habit: _quantitativeHabit(todayValue: 2)),
      );

      final icon = tester.widget<Icon>(
        find.descendant(of: _findQuantButton(), matching: find.byType(Icon)),
      );
      expect(icon.icon, Icons.add_circle_outline);
    });

    testWidgets('Q7 — isRecording=true désactive le bouton quantitatif',
        (tester) async {
      await tester.pumpWidget(
        _buildCard(habit: _quantitativeHabit(), isRecording: true),
      );
      expect(tester.widget<IconButton>(_findQuantButton()).onPressed, isNull);
    });

    testWidgets('Q8 — tap plein-carte ouvre le dialog quand aucun enregistrement en cours',
        (tester) async {
      await tester.pumpWidget(_buildCard(habit: _quantitativeHabit()));

      await tester.tap(find.text('Boire'));
      await tester.pumpAndSettle();

      expect(find.byType(HabitRecordDialog), findsOneWidget);
    });

    testWidgets('Q9 — tap plein-carte n\'ouvre pas le dialog pendant un enregistrement',
        (tester) async {
      await tester.pumpWidget(
        _buildCard(habit: _quantitativeHabit(), isRecording: true),
      );

      await tester.tap(find.text('Boire'));
      await tester.pumpAndSettle();

      expect(find.byType(HabitRecordDialog), findsNothing,
          reason: 'un second enregistrement serait avale par la garde de re-entrance, sans feedback');
    });
  });
}
