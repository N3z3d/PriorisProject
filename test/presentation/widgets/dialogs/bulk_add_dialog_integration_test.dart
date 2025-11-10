import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/dialogs/bulk_add_dialog.dart';

/// Tests d'integration pour BulkAddDialog
/// Objectif: Reproduire le bug "rien ne se passe" lors de l'ajout
void main() {
  group('BulkAddDialog - Single Item Addition', () {
    testWidgets(
      'REPRO: should call onSubmit when adding single item',
      (tester) async {
        // ARRANGE - Setup callback spy
        List<String>? submittedItems;
        final callback = (List<String> items) {
          submittedItems = items;
        };

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BulkAddDialog(
                key: const ValueKey('bulk_add_dialog'),
                title: 'Test Dialog',
                onSubmit: callback,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // ACT - User enters text and submits
        final textField = find.byType(TextField);
        expect(textField, findsOneWidget, reason: 'TextField should exist');

        await tester.enterText(textField, 'New test item');
        await tester.pumpAndSettle();

        // Find and tap submit button
        final submitButton = find.text('Ajouter');
        expect(submitButton, findsOneWidget, reason: 'Submit button should exist');

        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        // ASSERT - Callback should have been called with the item
        expect(
          submittedItems,
          isNotNull,
          reason: 'BUG REPRO: onSubmit callback was never called!',
        );
        expect(
          submittedItems,
          equals(['New test item']),
          reason: 'Should contain the entered item',
        );
      },
    );

    testWidgets(
      'REPRO: submit button should be disabled when field is empty',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BulkAddDialog(
                onSubmit: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Check initial state
        final submitButton = find.ancestor(
          of: find.text('Ajouter'),
          matching: find.byType(ElevatedButton),
        );

        expect(submitButton, findsOneWidget);

        final button = tester.widget<ElevatedButton>(submitButton);
        expect(
          button.onPressed,
          isNull,
          reason: 'Submit button should be disabled when text is empty',
        );
      },
    );

    testWidgets(
      'REPRO: should enable submit button when text is entered',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BulkAddDialog(
                onSubmit: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Enter text
        await tester.enterText(find.byType(TextField), 'Test item');
        await tester.pumpAndSettle();

        // Check button state
        final submitButton = find.ancestor(
          of: find.text('Ajouter'),
          matching: find.byType(ElevatedButton),
        );

        final button = tester.widget<ElevatedButton>(submitButton);
        expect(
          button.onPressed,
          isNotNull,
          reason: 'BUG REPRO: Submit button should be enabled with text!',
        );
      },
    );
  });

  group('BulkAddDialog - Bulk Addition', () {
    testWidgets(
      'REPRO: should call onSubmit with multiple items when in bulk mode',
      (tester) async {
        // ARRANGE
        List<String>? submittedItems;
        final callback = (List<String> items) {
          submittedItems = items;
        };

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BulkAddDialog(
                onSubmit: callback,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Switch to multiple mode (tap second tab)
        final multipleModeTab = find.text('Multiple');
        expect(multipleModeTab, findsOneWidget, reason: 'Multiple mode tab should exist');

        await tester.tap(multipleModeTab);
        await tester.pumpAndSettle();

        // ACT - Enter multiple items (one per line)
        final textField = find.byType(TextField);
        await tester.enterText(textField, 'Item 1\nItem 2\nItem 3');
        await tester.pumpAndSettle();

        // Submit
        final submitButton = find.text('Ajouter');
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        // ASSERT
        expect(
          submittedItems,
          isNotNull,
          reason: 'BUG REPRO: Bulk onSubmit callback was never called!',
        );
        expect(
          submittedItems,
          equals(['Item 1', 'Item 2', 'Item 3']),
          reason: 'Should contain all 3 items from separate lines',
        );
      },
    );

    testWidgets(
      'REPRO: should filter out empty lines in bulk mode',
      (tester) async {
        List<String>? submittedItems;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BulkAddDialog(
                onSubmit: (items) => submittedItems = items,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Switch to multiple mode
        await tester.tap(find.text('Multiple'));
        await tester.pumpAndSettle();

        // Enter items with empty lines
        await tester.enterText(
          find.byType(TextField),
          'Item 1\n\nItem 2\n\n\nItem 3\n',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Ajouter'));
        await tester.pumpAndSettle();

        expect(submittedItems, equals(['Item 1', 'Item 2', 'Item 3']));
      },
    );
  });

  group('BulkAddDialog - Keep Open Feature', () {
    testWidgets(
      'REPRO: should clear field and stay open when keep open is enabled',
      (tester) async {
        int callCount = 0;
        List<List<String>> allSubmissions = [];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BulkAddDialog(
                onSubmit: (items) {
                  callCount++;
                  allSubmissions.add(items);
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Enable "Keep open" checkbox
        final checkbox = find.byType(Checkbox);
        expect(checkbox, findsOneWidget);

        await tester.tap(checkbox);
        await tester.pumpAndSettle();

        // Add first item
        await tester.enterText(find.byType(TextField), 'First item');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Ajouter'));
        await tester.pumpAndSettle();

        // Dialog should still be visible
        expect(find.byType(BulkAddDialog), findsOneWidget);

        // Field should be cleared
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, isEmpty);

        // Add second item
        await tester.enterText(find.byType(TextField), 'Second item');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Ajouter'));
        await tester.pumpAndSettle();

        // ASSERT - Should have been called twice
        expect(callCount, equals(2), reason: 'BUG REPRO: Callback should be called twice');
        expect(allSubmissions, equals([
          ['First item'],
          ['Second item']
        ]));
      },
    );
  });

  group('BulkAddDialog - Accessibility', () {
    testWidgets('should have semantic labels for screen readers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BulkAddDialog(
              title: 'Ajouter des elements',
              onSubmit: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for semantic labels - the header wraps its content in Semantics
      final semanticsWidgets = tester.widgetList<Semantics>(find.byType(Semantics));
      final hasExpectedLabel = semanticsWidgets.any(
        (widget) => widget.properties.label == 'Ajouter des elements',
      );

      expect(
        hasExpectedLabel,
        isTrue,
        reason: 'Dialog should have accessible title in Semantics',
      );
    });

    testWidgets('submit button should have ValueKey for testing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BulkAddDialog(
              onSubmit: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for ValueKey on critical widgets
      expect(
        find.byKey(const ValueKey('bulk_add_submit_button')),
        findsOneWidget,
        reason: 'Submit button should have ValueKey for test targeting',
      );
    });
  });
}
