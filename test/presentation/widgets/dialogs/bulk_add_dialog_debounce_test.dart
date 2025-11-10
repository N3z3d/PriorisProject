import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/dialogs/bulk_add_dialog.dart';

/// Tests for debounce protection in BulkAddDialog
/// Prevents duplicate submissions on rapid double-clicks
void main() {
  group('BulkAddDialog - Debounce Protection (Keep Open Mode)', () {
    testWidgets(
      'REPRO: should not submit twice on rapid double-click when keep open enabled',
      (tester) async {
        // ARRANGE
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
        await tester.tap(checkbox);
        await tester.pumpAndSettle();

        // Enter text
        await tester.enterText(find.byType(TextField), 'Test item');
        await tester.pumpAndSettle();

        // ACT - Simulate rapid double-click (< 300ms apart)
        final submitButton = find.byKey(const ValueKey('bulk_add_submit_button'));

        await tester.tap(submitButton);
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        // ASSERT - Should only be called once despite double-click
        expect(
          callCount,
          equals(1),
          reason: 'BUG: Callback called $callCount times on double-click, expected 1',
        );
        expect(allSubmissions, equals([
          ['Test item']
        ]));
      },
    );

    testWidgets(
      'should allow submission after debounce period in keep open mode',
      (tester) async {
        int callCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BulkAddDialog(
                onSubmit: (items) => callCount++,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Enable keep open
        final checkbox = find.byType(Checkbox);
        await tester.tap(checkbox);
        await tester.pumpAndSettle();

        // First submission
        await tester.enterText(find.byType(TextField), 'Item 1');
        await tester.pumpAndSettle();

        final submitButton = find.byKey(const ValueKey('bulk_add_submit_button'));
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        expect(callCount, equals(1));

        // Wait for debounce period (300ms)
        await tester.pump(const Duration(milliseconds: 350));

        // Second submission should work
        await tester.enterText(find.byType(TextField), 'Item 2');
        await tester.pumpAndSettle();

        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        expect(
          callCount,
          equals(2),
          reason: 'Second submission after debounce should succeed',
        );
      },
    );

    testWidgets(
      'should block rapid multiple clicks (3+ clicks) in keep open mode',
      (tester) async {
        int callCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BulkAddDialog(
                onSubmit: (items) => callCount++,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Enable keep open
        final checkbox = find.byType(Checkbox);
        await tester.tap(checkbox);
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Test');
        await tester.pumpAndSettle();

        final submitButton = find.byKey(const ValueKey('bulk_add_submit_button'));

        // Simulate rapid triple-click
        await tester.tap(submitButton);
        await tester.pump(const Duration(milliseconds: 30));
        await tester.tap(submitButton);
        await tester.pump(const Duration(milliseconds: 30));
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        expect(
          callCount,
          equals(1),
          reason: 'Should only call once despite triple-click',
        );
      },
    );
  });

  group('BulkAddDialog - Bulk Mode Debounce', () {
    testWidgets(
      'should prevent duplicate bulk submissions in keep open mode',
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

        // Enable keep open
        final checkbox = find.byType(Checkbox);
        await tester.tap(checkbox);
        await tester.pumpAndSettle();

        // Switch to multiple mode
        await tester.tap(find.text('Multiple'));
        await tester.pumpAndSettle();

        // Enter multiple items
        await tester.enterText(find.byType(TextField), 'Item 1\nItem 2\nItem 3');
        await tester.pumpAndSettle();

        // Rapid double-click
        final submitButton = find.byKey(const ValueKey('bulk_add_submit_button'));
        await tester.tap(submitButton);
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        expect(callCount, equals(1));
        expect(allSubmissions, equals([
          ['Item 1', 'Item 2', 'Item 3']
        ]));
      },
    );
  });
}
