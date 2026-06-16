import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/pages/habits/components/habit_card.dart';
import '../../../../helpers/localized_widget.dart';

Widget _buildCard({
  required Habit habit,
  VoidCallback? onRecord,
  VoidCallback? onEdit,
  VoidCallback? onDelete,
  VoidCallback? onTap,
  bool isRecording = false,
}) {
  return localizedApp(
    HabitCard(
      habit: habit,
      onRecord: onRecord ?? () {},
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
}
