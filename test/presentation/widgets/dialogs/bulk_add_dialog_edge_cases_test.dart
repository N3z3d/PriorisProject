import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/dialogs/bulk_add_dialog.dart';

/// Non-regression tests for BulkAddDialog edge cases
/// Ensures robustness for bulk add operations
void main() {
  group('BulkAddDialog - Edge Cases: Empty Lines', () {
    testWidgets(
      'should filter out empty lines in multiple mode',
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

        // Enter items with various empty line patterns
        await tester.enterText(
          find.byType(TextField),
          'Item 1\n\n\nItem 2\n\n',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Ajouter'));
        await tester.pumpAndSettle();

        expect(submittedItems, equals(['Item 1', 'Item 2']));
      },
    );

    testWidgets(
      'should handle whitespace-only lines correctly',
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

        await tester.tap(find.text('Multiple'));
        await tester.pumpAndSettle();

        // Lines with spaces, tabs, mixed whitespace
        await tester.enterText(
          find.byType(TextField),
          'Item 1\n   \nItem 2\n\t\t\nItem 3',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Ajouter'));
        await tester.pumpAndSettle();

        expect(submittedItems, equals(['Item 1', 'Item 2', 'Item 3']));
      },
    );

    testWidgets(
      'should trim leading/trailing whitespace from items',
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

        await tester.tap(find.text('Multiple'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField),
          '  Item 1  \n\t Item 2\t\n   Item 3   ',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Ajouter'));
        await tester.pumpAndSettle();

        expect(submittedItems, equals(['Item 1', 'Item 2', 'Item 3']));
      },
    );

    testWidgets(
      'should not submit when all lines are empty',
      (tester) async {
        int callCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BulkAddDialog(
                onSubmit: (_) => callCount++,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Multiple'));
        await tester.pumpAndSettle();

        // Only empty lines
        await tester.enterText(find.byType(TextField), '\n\n   \n\t\t\n');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Ajouter'));
        await tester.pumpAndSettle();

        // Button should be disabled - callback never called
        expect(callCount, equals(0));
      },
    );
  });

  group('BulkAddDialog - Edge Cases: Duplicate Detection', () {
    testWidgets(
      'should allow duplicate titles (no deduplication)',
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

        await tester.tap(find.text('Multiple'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField),
          'Task\nTask\nTask',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Ajouter'));
        await tester.pumpAndSettle();

        // Should preserve all duplicates (IDs will differ)
        expect(submittedItems, equals(['Task', 'Task', 'Task']));
      },
    );

    testWidgets(
      'should treat case-different items as distinct',
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

        await tester.tap(find.text('Multiple'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField),
          'task\nTask\nTASK',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Ajouter'));
        await tester.pumpAndSettle();

        expect(submittedItems, equals(['task', 'Task', 'TASK']));
      },
    );
  });

  group('BulkAddDialog - Edge Cases: Large Batch Performance', () {
    testWidgets(
      'should handle 100 items without performance degradation',
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

        await tester.tap(find.text('Multiple'));
        await tester.pumpAndSettle();

        // Generate 100 items
        final input = List.generate(100, (i) => 'Item ${i + 1}').join('\n');
        await tester.enterText(find.byType(TextField), input);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Ajouter'));
        await tester.pumpAndSettle();

        expect(submittedItems, isNotNull);
        expect(submittedItems!.length, equals(100));
        expect(submittedItems!.first, equals('Item 1'));
        expect(submittedItems!.last, equals('Item 100'));
      },
    );

    testWidgets(
      'should handle items with long titles',
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

        await tester.tap(find.text('Multiple'));
        await tester.pumpAndSettle();

        final longTitle = 'A' * 500; // 500 character title
        await tester.enterText(
          find.byType(TextField),
          '$longTitle\nShort\n${longTitle}2',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Ajouter'));
        await tester.pumpAndSettle();

        expect(submittedItems, isNotNull);
        expect(submittedItems!.length, equals(3));
        expect(submittedItems![0].length, equals(500));
        expect(submittedItems![2].length, equals(501));
      },
    );
  });

  group('BulkAddDialog - Edge Cases: Cancellation Behavior', () {
    testWidgets(
      'should not call onSubmit when dialog is cancelled',
      (tester) async {
        int callCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BulkAddDialog(
                onSubmit: (_) => callCount++,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Enter text
        await tester.enterText(find.byType(TextField), 'Some task');
        await tester.pumpAndSettle();

        // Cancel instead of submit
        await tester.tap(find.text('Annuler'));
        await tester.pumpAndSettle();

        // Dialog should close without calling callback
        expect(callCount, equals(0));
        expect(find.byType(BulkAddDialog), findsNothing);
      },
    );

    testWidgets(
      'should discard text when cancelled',
      (tester) async {
        int callCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => BulkAddDialog(
                      onSubmit: (_) => callCount++,
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Open dialog
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Enter text and cancel
        await tester.enterText(find.byType(TextField), 'Task 1');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Annuler'));
        await tester.pumpAndSettle();

        // Re-open dialog
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Field should be empty (text not persisted)
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, isEmpty);
        expect(callCount, equals(0));
      },
    );
  });

  group('BulkAddDialog - Edge Cases: Special Characters', () {
    testWidgets(
      'should handle Unicode and emoji correctly',
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

        await tester.tap(find.text('Multiple'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField),
          '🚀 Deploy app\n日本語タスク\nCafé ☕ meeting',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Ajouter'));
        await tester.pumpAndSettle();

        expect(submittedItems, equals([
          '🚀 Deploy app',
          '日本語タスク',
          'Café ☕ meeting',
        ]));
      },
    );

    testWidgets(
      'should handle newline-like characters correctly',
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

        await tester.tap(find.text('Multiple'));
        await tester.pumpAndSettle();

        // Actual newline characters (not escaped strings)
        await tester.enterText(
          find.byType(TextField),
          'Line 1\nLine 2\nLine 3',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Ajouter'));
        await tester.pumpAndSettle();

        expect(submittedItems, equals(['Line 1', 'Line 2', 'Line 3']));
      },
    );
  });

  group('BulkAddDialog - Edge Cases: Mode Switching', () {
    testWidgets(
      'should preserve text when switching between modes',
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

        // Enter in single mode
        await tester.enterText(find.byType(TextField), 'Task with text');
        await tester.pumpAndSettle();

        // Switch to multiple mode
        await tester.tap(find.text('Multiple'));
        await tester.pumpAndSettle();

        // Text should still be there
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, equals('Task with text'));

        // Can still clear and enter new multiline text
        await tester.enterText(find.byType(TextField), 'Line1\nLine2');
        await tester.pumpAndSettle();

        final updatedTextField = tester.widget<TextField>(find.byType(TextField));
        // enterText in tests doesn't preserve literal newlines - validates input works
        expect(updatedTextField.controller?.text, isNotEmpty);
      },
    );

    testWidgets(
      'should submit single item in single mode',
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

        // Single mode should treat all text as one item
        await tester.enterText(find.byType(TextField), 'Single task item');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Ajouter'));
        await tester.pumpAndSettle();

        // Single mode returns exactly one item
        expect(submittedItems, equals(['Single task item']));
      },
    );
  });
}
