import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/presentation/pages/habits/services/habit_action_handler.dart';
import 'package:prioris/presentation/pages/habits/widgets/habit_form_widget.dart';

void main() {
  group('HabitActionHandler', () {
    testWidgets('addNewHabit ouvre le formulaire complet', (tester) async {
      late HabitActionHandler handler;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  handler = HabitActionHandler(context: context, ref: ref);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );

      handler.addNewHabit();
      await tester.pumpAndSettle();

      expect(find.text('Nom de l\'habitude'), findsOneWidget);
      expect(find.byType(HabitFormWidget), findsOneWidget);
    });
  });
}
