/// TDD Tests for BulkAddDialog extracted components
///
/// Following Red → Green → Refactor methodology
/// Tests written BEFORE implementing components

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/widgets/dialogs/bulk_add_dialog.dart';
import 'package:prioris/presentation/widgets/dialogs/components/bulk_add_header.dart';
import 'package:prioris/presentation/widgets/dialogs/components/bulk_add_mode_tabs.dart';
import 'package:prioris/presentation/widgets/dialogs/components/bulk_add_text_field.dart';
import 'package:prioris/presentation/widgets/dialogs/components/bulk_add_help_message.dart';
import 'package:prioris/presentation/widgets/dialogs/components/bulk_add_keep_open_option.dart';
import 'package:prioris/presentation/widgets/dialogs/components/bulk_add_action_buttons.dart';
import '../../../helpers/localized_widget.dart';

// Helper for tests that need DefaultTabController AND localization.
Widget localizedTabApp(Widget body) {
  return MaterialApp(
    locale: const Locale('fr'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('fr'), Locale('en')],
    home: DefaultTabController(length: 2, child: Scaffold(body: body)),
  );
}

void main() {
  group('BulkAddHeader Tests - TDD', () {
    testWidgets('should render title correctly', (WidgetTester tester) async {
      const testTitle = 'Test Title';

      await tester.pumpWidget(localizedApp(BulkAddHeader(
        title: testTitle,
        onClose: () {},
      )));

      expect(find.text(testTitle), findsOneWidget);
    });

    testWidgets('should display close button', (WidgetTester tester) async {
      await tester.pumpWidget(localizedApp(BulkAddHeader(
        title: 'Title',
        onClose: () {},
      )));

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should call onClose when close button tapped', (WidgetTester tester) async {
      var closeCalled = false;

      await tester.pumpWidget(localizedApp(BulkAddHeader(
        title: 'Title',
        onClose: () => closeCalled = true,
      )));

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(closeCalled, isTrue);
    });

    testWidgets('should be a Row widget', (WidgetTester tester) async {
      await tester.pumpWidget(localizedApp(BulkAddHeader(
        title: 'Title',
        onClose: () {},
      )));

      expect(find.byType(Row), findsOneWidget);
    });
  });

  group('BulkAddModeTabs Tests - TDD', () {
    testWidgets('should render both tabs', (WidgetTester tester) async {
      await tester.pumpWidget(localizedTabApp(BulkAddModeTabs(
        controller: null,
        onModeChanged: (_) {},
      )));
      await tester.pumpAndSettle();

      // FR locale: bulkAddModeSingle = "Simple", bulkAddModeMultiple = "Multiple"
      expect(find.text('Simple'), findsOneWidget);
      expect(find.text('Multiple'), findsOneWidget);
    });

    testWidgets('should call onModeChanged when tab changes', (WidgetTester tester) async {
      BulkAddMode? selectedMode;

      await tester.pumpWidget(localizedTabApp(BulkAddModeTabs(
        controller: null,
        onModeChanged: (mode) => selectedMode = mode,
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Multiple'));
      await tester.pumpAndSettle();

      expect(selectedMode, equals(BulkAddMode.multiple));
    });

    testWidgets('should use provided TabController', (WidgetTester tester) async {
      final controller = TabController(length: 2, vsync: const TestVSync());

      await tester.pumpWidget(localizedTabApp(BulkAddModeTabs(
        controller: controller,
        onModeChanged: (_) {},
      )));
      await tester.pumpAndSettle();

      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.controller, equals(controller));
    });
  });

  group('BulkAddTextField Tests - TDD', () {
    testWidgets('should render TextField', (WidgetTester tester) async {
      await tester.pumpWidget(localizedApp(BulkAddTextField(
        controller: TextEditingController(),
        focusNode: FocusNode(),
        mode: BulkAddMode.single,
        hintText: 'Test hint',
        onSubmitted: (_) {},
      )));

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should display hint text', (WidgetTester tester) async {
      const hintText = 'Custom hint text';

      await tester.pumpWidget(localizedApp(BulkAddTextField(
        controller: TextEditingController(),
        focusNode: FocusNode(),
        mode: BulkAddMode.single,
        hintText: hintText,
        onSubmitted: (_) {},
      )));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.hintText, equals(hintText));
    });

    testWidgets('should use maxLines=1 for single mode', (WidgetTester tester) async {
      await tester.pumpWidget(localizedApp(BulkAddTextField(
        controller: TextEditingController(),
        focusNode: FocusNode(),
        mode: BulkAddMode.single,
        hintText: '',
        onSubmitted: (_) {},
      )));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, equals(1));
    });

    testWidgets('should use maxLines=5 for multiple mode', (WidgetTester tester) async {
      await tester.pumpWidget(localizedApp(BulkAddTextField(
        controller: TextEditingController(),
        focusNode: FocusNode(),
        mode: BulkAddMode.multiple,
        hintText: '',
        onSubmitted: (_) {},
      )));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, equals(5));
    });

    testWidgets('should call onSubmitted for single mode', (WidgetTester tester) async {
      String? submittedText;

      await tester.pumpWidget(localizedApp(BulkAddTextField(
        controller: TextEditingController(),
        focusNode: FocusNode(),
        mode: BulkAddMode.single,
        hintText: '',
        onSubmitted: (text) => submittedText = text,
      )));

      await tester.enterText(find.byType(TextField), 'Test input');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(submittedText, equals('Test input'));
    });
  });

  group('BulkAddHelpMessage Tests - TDD', () {
    testWidgets('should render help text', (WidgetTester tester) async {
      const helpText = 'Test help message';

      await tester.pumpWidget(localizedApp(const BulkAddHelpMessage(message: helpText)));

      expect(find.text(helpText), findsOneWidget);
    });

    testWidgets('should display info icon', (WidgetTester tester) async {
      await tester.pumpWidget(localizedApp(const BulkAddHelpMessage(message: 'Help')));

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('should be a Row widget', (WidgetTester tester) async {
      await tester.pumpWidget(localizedApp(const BulkAddHelpMessage(message: 'Help')));

      expect(find.byType(Row), findsOneWidget);
    });
  });

  group('BulkAddKeepOpenOption Tests - TDD', () {
    testWidgets('should render checkbox', (WidgetTester tester) async {
      await tester.pumpWidget(localizedApp(BulkAddKeepOpenOption(
        value: false,
        onChanged: (_) {},
      )));

      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('should display label text', (WidgetTester tester) async {
      await tester.pumpWidget(localizedApp(BulkAddKeepOpenOption(
        value: false,
        onChanged: (_) {},
      )));
      await tester.pumpAndSettle();

      // FR locale: keepOpenAfterAdd = "Garder ouvert après ajout"
      expect(find.text('Garder ouvert après ajout'), findsOneWidget);
    });

    testWidgets('should reflect value state', (WidgetTester tester) async {
      await tester.pumpWidget(localizedApp(BulkAddKeepOpenOption(
        value: true,
        onChanged: (_) {},
      )));

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets('should call onChanged when toggled', (WidgetTester tester) async {
      bool? changedValue;

      await tester.pumpWidget(localizedApp(BulkAddKeepOpenOption(
        value: false,
        onChanged: (value) => changedValue = value,
      )));

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      expect(changedValue, isTrue);
    });
  });

  group('BulkAddActionButtons Tests - TDD', () {
    testWidgets('should render cancel and add buttons', (WidgetTester tester) async {
      await tester.pumpWidget(localizedApp(BulkAddActionButtons(
        isValid: true,
        onCancel: () {},
        onSubmit: () {},
      )));
      await tester.pumpAndSettle();

      // FR locale: cancel = "Annuler", add = "Ajouter"
      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('Ajouter'), findsOneWidget);
    });

    testWidgets('should call onCancel when cancel tapped', (WidgetTester tester) async {
      var cancelCalled = false;

      await tester.pumpWidget(localizedApp(BulkAddActionButtons(
        isValid: true,
        onCancel: () => cancelCalled = true,
        onSubmit: () {},
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      expect(cancelCalled, isTrue);
    });

    testWidgets('should call onSubmit when add button tapped and valid', (WidgetTester tester) async {
      var submitCalled = false;

      await tester.pumpWidget(localizedApp(BulkAddActionButtons(
        isValid: true,
        onCancel: () {},
        onSubmit: () => submitCalled = true,
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ajouter'));
      await tester.pumpAndSettle();

      expect(submitCalled, isTrue);
    });

    testWidgets('should disable submit button when not valid', (WidgetTester tester) async {
      await tester.pumpWidget(localizedApp(BulkAddActionButtons(
        isValid: false,
        onCancel: () {},
        onSubmit: () {},
      )));
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Ajouter'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('should be a Row widget', (WidgetTester tester) async {
      await tester.pumpWidget(localizedApp(BulkAddActionButtons(
        isValid: true,
        onCancel: () {},
        onSubmit: () {},
      )));

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
