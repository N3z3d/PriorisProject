import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/dialogs/duplicate_warning_dialog.dart';
import '../../../helpers/localized_widget.dart';

void main() {
  group('DuplicateWarningDialog', () {
    testWidgets('mode single — boutons Annuler et Ajouter quand même',
        (tester) async {
      await tester.pumpWidget(localizedApp(Builder(
        builder: (ctx) => ElevatedButton(
          onPressed: () => showDialog<DuplicateChoice>(
            context: ctx,
            builder: (_) => DuplicateWarningDialog(
              duplicateTitles: const ['Café'],
              totalCount: 1,
            ),
          ),
          child: const Text('open'),
        ),
      )));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('Ajouter quand même'), findsOneWidget);
      expect(find.textContaining('Ignorer'), findsNothing);
    });

    testWidgets('mode bulk — 2 doublons sur 5 — les 3 boutons sont présents',
        (tester) async {
      await tester.pumpWidget(localizedApp(Builder(
        builder: (ctx) => ElevatedButton(
          onPressed: () => showDialog<DuplicateChoice>(
            context: ctx,
            builder: (_) => DuplicateWarningDialog(
              duplicateTitles: const ['A', 'B'],
              totalCount: 5,
            ),
          ),
          child: const Text('open'),
        ),
      )));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Annuler'), findsOneWidget);
      expect(find.textContaining('Ignorer'), findsOneWidget);
      expect(find.textContaining('Tout ajouter'), findsOneWidget);
    });

    testWidgets(
        'mode bulk "tout doublon" — bouton Ignorer absent (uniqueCount == 0)',
        (tester) async {
      await tester.pumpWidget(localizedApp(Builder(
        builder: (ctx) => ElevatedButton(
          onPressed: () => showDialog<DuplicateChoice>(
            context: ctx,
            builder: (_) => DuplicateWarningDialog(
              duplicateTitles: const ['A', 'B', 'C', 'D', 'E'],
              totalCount: 5,
            ),
          ),
          child: const Text('open'),
        ),
      )));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Annuler'), findsOneWidget);
      expect(find.textContaining('Ignorer'), findsNothing);
      expect(find.textContaining('Tout ajouter'), findsOneWidget);
    });

    testWidgets('tap Annuler → pop avec DuplicateChoice.cancel', (tester) async {
      DuplicateChoice? result;

      await tester.pumpWidget(localizedApp(Builder(
        builder: (ctx) => ElevatedButton(
          onPressed: () async {
            result = await showDialog<DuplicateChoice>(
              context: ctx,
              builder: (_) => DuplicateWarningDialog(
                duplicateTitles: const ['X'],
                totalCount: 1,
              ),
            );
          },
          child: const Text('open'),
        ),
      )));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      expect(result, DuplicateChoice.cancel);
    });

    testWidgets('tap Ignorer → pop avec DuplicateChoice.skipDuplicates',
        (tester) async {
      DuplicateChoice? result;

      await tester.pumpWidget(localizedApp(Builder(
        builder: (ctx) => ElevatedButton(
          onPressed: () async {
            result = await showDialog<DuplicateChoice>(
              context: ctx,
              builder: (_) => DuplicateWarningDialog(
                duplicateTitles: const ['A'],
                totalCount: 3,
              ),
            );
          },
          child: const Text('open'),
        ),
      )));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Ignorer'));
      await tester.pumpAndSettle();

      expect(result, DuplicateChoice.skipDuplicates);
    });

    testWidgets('tap Ajouter quand même → pop avec DuplicateChoice.addAll',
        (tester) async {
      DuplicateChoice? result;

      await tester.pumpWidget(localizedApp(Builder(
        builder: (ctx) => ElevatedButton(
          onPressed: () async {
            result = await showDialog<DuplicateChoice>(
              context: ctx,
              builder: (_) => DuplicateWarningDialog(
                duplicateTitles: const ['X'],
                totalCount: 1,
              ),
            );
          },
          child: const Text('open'),
        ),
      )));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ajouter quand même'));
      await tester.pumpAndSettle();

      expect(result, DuplicateChoice.addAll);
    });
  });
}
