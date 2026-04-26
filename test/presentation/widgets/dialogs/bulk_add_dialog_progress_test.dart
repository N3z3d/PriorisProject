import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/dialogs/bulk_add_dialog.dart';
import '../../../helpers/localized_widget.dart';

/// Story 7.3 — Tests widget pour les 5 états de progression du BulkAddDialog
///
/// RED phase: ces tests doivent échouer avant l'implémentation
void main() {
  group('BulkAddDialog - AC1: indicateur de progression', () {
    testWidgets(
      'affiche un LinearProgressIndicator dès que onSubmit démarre',
      (tester) async {
        final completer = Completer<void>();

        await tester.pumpWidget(
          localizedApp(BulkAddDialog(
            onSubmit: (items, onProgress) => completer.future,
          )),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Item 1');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Ajouter'));
        await tester.pump();

        expect(find.byType(LinearProgressIndicator), findsOneWidget,
            reason: 'Un indicateur de progression doit apparaître dès le démarrage');

        completer.complete();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'affiche le compteur n/total quand onProgress est appelé',
      (tester) async {
        late void Function(int, int) capturedProgress;
        final completer = Completer<void>();

        await tester.pumpWidget(
          localizedApp(BulkAddDialog(
            onSubmit: (items, onProgress) {
              capturedProgress = onProgress;
              return completer.future;
            },
          )),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Item 1');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Ajouter'));
        await tester.pump();

        capturedProgress(2, 5);
        await tester.pump();

        expect(find.text('2 / 5'), findsOneWidget,
            reason: 'Le compteur n/total doit être affiché');
        expect(find.byType(LinearProgressIndicator), findsOneWidget,
            reason: 'La barre de progression doit rester visible');

        completer.complete();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'la valeur de LinearProgressIndicator reflète la progression',
      (tester) async {
        late void Function(int, int) capturedProgress;
        final completer = Completer<void>();

        await tester.pumpWidget(
          localizedApp(BulkAddDialog(
            onSubmit: (items, onProgress) {
              capturedProgress = onProgress;
              return completer.future;
            },
          )),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Test');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Ajouter'));
        await tester.pump();

        capturedProgress(3, 10);
        await tester.pump();

        final progressWidget = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(progressWidget.value, closeTo(0.3, 0.01),
            reason: '3/10 = 0.3, la barre doit refléter 30%');

        completer.complete();
        await tester.pumpAndSettle();
      },
    );
  });

  group('BulkAddDialog - AC3: confirmation de complétion', () {
    testWidgets(
      'le dialog retourne le nombre d\'éléments traités quand onSubmit se termine (mode normal)',
      (tester) async {
        int? poppedValue;

        await tester.pumpWidget(
          localizedApp(Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                final result = await showDialog<int>(
                  context: context,
                  builder: (_) => BulkAddDialog(
                    onSubmit: (items, onProgress) async {
                      onProgress(3, 3);
                    },
                  ),
                );
                poppedValue = result;
              },
              child: const Text('Open'),
            ),
          )),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Switch to multiple mode to add 3 items
        await tester.tap(find.text('Multiple'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'A\nB\nC');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Ajouter'));
        await tester.pumpAndSettle();

        expect(poppedValue, isNotNull,
            reason: 'Le dialog doit retourner un résultat à la fermeture');
        expect(poppedValue, greaterThan(0),
            reason: 'Le résultat doit être le nombre d\'éléments traités');
      },
    );

    testWidgets(
      'le dialog ne ferme pas immédiatement — reste ouvert pendant onSubmit',
      (tester) async {
        final completer = Completer<void>();
        bool dialogVisible = true;

        await tester.pumpWidget(
          localizedApp(Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                dialogVisible = true;
                await showDialog<int>(
                  context: context,
                  builder: (_) => BulkAddDialog(
                    onSubmit: (items, onProgress) => completer.future,
                  ),
                );
                dialogVisible = false;
              },
              child: const Text('Open'),
            ),
          )),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Item');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Ajouter'));
        await tester.pump();

        // Dialog must still be visible (onSubmit not done yet)
        expect(dialogVisible, isTrue,
            reason: 'Le dialog doit rester ouvert pendant onSubmit');
        expect(find.byType(BulkAddDialog), findsOneWidget,
            reason: 'Le BulkAddDialog doit toujours être affiché');

        completer.complete();
        await tester.pumpAndSettle();

        expect(dialogVisible, isFalse,
            reason: 'Le dialog doit se fermer après la complétion de onSubmit');
      },
    );
  });

  group('BulkAddDialog - AC2: état partiel en cas d\'erreur', () {
    testWidgets(
      '_isSubmitting repasse à false si onSubmit lève une exception',
      (tester) async {
        await tester.pumpWidget(
          localizedApp(BulkAddDialog(
            onSubmit: (items, onProgress) async {
              throw Exception('Réseau indisponible');
            },
          )),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Item');
        await tester.pumpAndSettle();

        // Submit then expect error recovery
        await tester.tap(find.text('Ajouter'));
        await tester.pumpAndSettle();

        // After error, form should be re-enabled (not stuck in isSubmitting)
        final button = tester.widget<ElevatedButton>(
          find.byKey(const ValueKey('bulk_add_submit_button')),
        );
        expect(button.onPressed, isNotNull,
            reason: 'Le bouton doit être réactivé après une erreur pour permettre une nouvelle tentative');
      },
    );
  });

  group('BulkAddDialog - AC5: état keep-open avec debounce', () {
    testWidgets(
      'en mode keep-open, _isSubmitting reste true pendant 300ms après complétion',
      (tester) async {
        int callCount = 0;

        await tester.pumpWidget(
          localizedApp(BulkAddDialog(
            onSubmit: (items, onProgress) async {
              callCount++;
            },
          )),
        );
        await tester.pumpAndSettle();

        // Enable keep open
        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Item');
        await tester.pumpAndSettle();

        final submitButton = find.byKey(const ValueKey('bulk_add_submit_button'));

        // First submit
        await tester.tap(submitButton);
        // Advance microtasks (onSubmit completes) but NOT the 300ms timer
        await tester.pump(const Duration(milliseconds: 50));

        // Second tap before 300ms debounce window
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        expect(callCount, equals(1),
            reason: 'La protection debounce doit empêcher le double-submit même si onSubmit est instantané');
      },
    );

    testWidgets(
      'en mode keep-open, ré-submit autorisé après 300ms',
      (tester) async {
        int callCount = 0;

        await tester.pumpWidget(
          localizedApp(BulkAddDialog(
            onSubmit: (items, onProgress) async {
              callCount++;
            },
          )),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Item');
        await tester.pumpAndSettle();

        final submitButton = find.byKey(const ValueKey('bulk_add_submit_button'));

        // First submit
        await tester.tap(submitButton);
        await tester.pumpAndSettle(); // Advances timers, 300ms delay clears

        expect(callCount, equals(1));

        // Second submit after debounce window
        await tester.enterText(find.byType(TextField), 'Item 2');
        await tester.pumpAndSettle();
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        expect(callCount, equals(2),
            reason: 'La ré-soumission doit être autorisée après le debounce');
      },
    );
  });
}
