/// TDD Tests for BulkAddDialog extracted components
///
/// Following Red → Green → Refactor methodology
/// Tests written BEFORE implementing components

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/dialogs/bulk_add_dialog.dart';
import 'package:prioris/presentation/widgets/dialogs/components/bulk_add_header.dart';
import 'package:prioris/presentation/widgets/dialogs/components/bulk_add_mode_tabs.dart';
import 'package:prioris/presentation/widgets/dialogs/components/bulk_add_text_field.dart';
import 'package:prioris/presentation/widgets/dialogs/components/bulk_add_help_message.dart';
import 'package:prioris/presentation/widgets/dialogs/components/bulk_add_keep_open_option.dart';
import 'package:prioris/presentation/widgets/dialogs/components/bulk_add_action_buttons.dart';

void main() {
  group('BulkAddHeader Tests - TDD', () {
    testWidgets('should render title correctly', (WidgetTester tester) async {
      // GIVEN
      const testTitle = 'Test Title';

      // WHEN
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BulkAddHeader(
              title: testTitle,
              onClose: () {},
            ),
          ),
        ),
      );

      // THEN
      expect(find.text(testTitle), findsOneWidget);
    });

    testWidgets('should display close button', (WidgetTester tester) async {
      // WHEN
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BulkAddHeader(
              title: 'Title',
              onClose: () {},
            ),
          ),
        ),
      );

      // THEN
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should call onClose when close button tapped', (WidgetTester tester) async {
      // GIVEN
      var closeCalled = false;

      // WHEN
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BulkAddHeader(
              title: 'Title',
              onClose: () => closeCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // THEN
      expect(closeCalled, isTrue);
    });

    testWidgets('should be a Row widget', (WidgetTester tester) async {
      // WHEN
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BulkAddHeader(
              title: 'Title',
              onClose: () {},
            ),
          ),
        ),
      );

      // THEN
      expect(find.byType(Row), findsOneWidget);
    });
  });

  group('BulkAddModeTabs Tests - TDD', () {
    testWidgets('should render both tabs', (WidgetTester tester) async {
      // WHEN
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTabController(
            length: 2,
            child: Scaffold(
              body: BulkAddModeTabs(
                controller: null, // Will use DefaultTabController
                onModeChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // THEN
      expect(find.text('Un élément'), findsOneWidget);
      expect(find.text('Plusieurs éléments'), findsOneWidget);
    });

    testWidgets('should call onModeChanged when tab changes', (WidgetTester tester) async {
      // GIVEN
      BulkAddMode? selectedMode;

      // WHEN
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTabController(
            length: 2,
            child: Scaffold(
              body: BulkAddModeTabs(
                controller: null,
                onModeChanged: (mode) => selectedMode = mode,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Plusieurs éléments'));
      await tester.pumpAndSettle();

      // THEN
      expect(selectedMode, equals(BulkAddMode.multiple));
    });

    testWidgets('should use provided TabController', (WidgetTester tester) async {
      // GIVEN
      final controller = TabController(length: 2, vsync: const TestVSync());

      // WHEN
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BulkAddModeTabs(
              controller: controller,
              onModeChanged: (_) {},
            ),
          ),
        ),
      );

      // THEN
      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.controller, equals(controller));
    });
  });

  group('BulkAddTextField Tests - TDD', () {
    testWidgets('should render TextField', (WidgetTester tester) async {
      // WHEN
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BulkAddTextField(
              controller: TextEditingController(),
              focusNode: FocusNode(),
              mode: BulkAddMode.single,
              hintText: 'Test hint',
              onSubmitted: (_) {},
            ),
          ),
        ),
      );

      // THEN
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should display hint text', (WidgetTester tester) async {
      // GIVEN
      const hintText = 'Custom hint text';

      // WHEN
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BulkAddTextField(
              controller: TextEditingController(),
              focusNode: FocusNode(),
              mode: BulkAddMode.single,
              hintText: hintText,
              onSubmitted: (_) {},
            ),
          ),
        ),
      );

      // THEN
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.hintText, equals(hintText));
    });

    testWidgets('should use maxLines=1 for single mode', (WidgetTester tester) async {
      // WHEN
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BulkAddTextField(
              controller: TextEditingController(),
              focusNode: FocusNode(),
              mode: BulkAddMode.single,
              hintText: '',
              onSubmitted: (_) {},
            ),
          ),
        ),
      );

      // THEN
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, equals(1));
    });

    testWidgets('should use maxLines=5 for multiple mode', (WidgetTester tester) async {
      // WHEN
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BulkAddTextField(
              controller: TextEditingController(),
              focusNode: FocusNode(),
              mode: BulkAddMode.multiple,
              hintText: '',
              onSubmitted: (_) {},
            ),
          ),
        ),
      );

      // THEN
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, equals(5));
    });

    testWidgets('should call onSubmitted for single mode', (WidgetTester tester) async {
      // GIVEN
      String? submittedText;

      // WHEN
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BulkAddTextField(
              controller: TextEditingController(),
              focusNode: FocusNode(),
              mode: BulkAddMode.single,
              hintText: '',
              onSubmitted: (text) => submittedText = text,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test input');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // THEN
      expect(submittedText, equals('Test input'));
    });
  });

  group('BulkAddHelpMessage Tests - TDD', () {
    testWidgets('should render help text', (WidgetTester tester) async {
      // GIVEN
      const helpText = 'Test help message';

      // WHEN
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BulkAddHelpMessage(message: helpText),
          ),
        ),
      );

      // THEN
      expect(find.text(helpText), findsOneWidget);
    });

    testWidgets('should display info icon', (WidgetTester tester) async {
      // WHEN
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BulkAddHelpMessage(message: 'Help'),
          ),
        ),
      );

      // THEN
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('should be a Row widget', (WidgetTester tester) async {
      // WHEN
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BulkAddHelpMessage(message: 'Help'),
          ),
        ),
      );

      // THEN
      expect(find.byType(Row), findsOneWidget);
    });
  });

  group('BulkAddKeepOpenOption Tests - TDD', () {
    testWidgets('should render checkbox', (WidgetTester tester) async {
      // WHEN
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BulkAddKeepOpenOption(
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // THEN
      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('should display label text', (WidgetTester tester) async {
      // WHEN
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BulkAddKeepOpenOption(
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // THEN
      expect(find.text('Garder ouvert après ajout'), findsOneWidget);
    });

    testWidgets('should reflect value state', (WidgetTester tester) async {
      // WHEN - Checked
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BulkAddKeepOpenOption(
              value: true,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // THEN
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets('should call onChanged when toggled', (WidgetTester tester) async {
      // GIVEN
      bool? changedValue;

      // WHEN
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BulkAddKeepOpenOption(
              value: false,
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // THEN
      expect(changedValue, isTrue);
    });
  });

  group('BulkAddActionButtons Tests - TDD', () {
    testWidgets('should render cancel and add buttons', (WidgetTester tester) async {
      // WHEN
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BulkAddActionButtons(
              isValid: true,
              onCancel: () {},
              onSubmit: () {},
            ),
          ),
        ),
      );

      // THEN
      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('Ajouter'), findsOneWidget);
    });

    testWidgets('should call onCancel when cancel tapped', (WidgetTester tester) async {
      // GIVEN
      var cancelCalled = false;

      // WHEN
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BulkAddActionButtons(
              isValid: true,
              onCancel: () => cancelCalled = true,
              onSubmit: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      // THEN
      expect(cancelCalled, isTrue);
    });

    testWidgets('should call onSubmit when add button tapped and valid', (WidgetTester tester) async {
      // GIVEN
      var submitCalled = false;

      // WHEN
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BulkAddActionButtons(
              isValid: true,
              onCancel: () {},
              onSubmit: () => submitCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Ajouter'));
      await tester.pumpAndSettle();

      // THEN
      expect(submitCalled, isTrue);
    });

    testWidgets('should disable submit button when not valid', (WidgetTester tester) async {
      // WHEN
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BulkAddActionButtons(
              isValid: false,
              onCancel: () {},
              onSubmit: () {},
            ),
          ),
        ),
      );

      // THEN
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Ajouter'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('should be a Row widget', (WidgetTester tester) async {
      // WHEN
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BulkAddActionButtons(
              isValid: true,
              onCancel: () {},
              onSubmit: () {},
            ),
          ),
        ),
      );

      // THEN
      expect(find.byType(Row), findsOneWidget);
    });
  });
}

// Helper class for TabController tests
class TestVSync extends TickerProvider {
  const TestVSync();

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}