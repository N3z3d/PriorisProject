import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/common/layouts/common_empty_state.dart';

void main() {
  group('CommonEmptyState', () {
    testWidgets('should display title correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommonEmptyState(
              title: 'Test Title',
            ),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('should display subtitle when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommonEmptyState(
              title: 'Test Title',
              subtitle: 'Test Subtitle',
            ),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Subtitle'), findsOneWidget);
    });

    testWidgets('should display icon when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommonEmptyState(
              title: 'Test Title',
              icon: Icons.info,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('should display action button when onAction and actionLabel are provided', (WidgetTester tester) async {
      bool actionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonEmptyState(
              title: 'Test Title',
              onAction: () => actionCalled = true,
              actionLabel: 'Test Action',
            ),
          ),
        ),
      );

      expect(find.text('Test Action'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      await tester.tap(find.text('Test Action'));
      await tester.pump();

      expect(actionCalled, isTrue);
    });

    testWidgets('should not display action button when only onAction is provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommonEmptyState(
              title: 'Test Title',
              onAction: null,
              actionLabel: 'Test Action',
            ),
          ),
        ),
      );

      expect(find.text('Test Action'), findsNothing);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('should not display action button when only actionLabel is provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommonEmptyState(
              title: 'Test Title',
              onAction: null,
              actionLabel: 'Test Action',
            ),
          ),
        ),
      );

      expect(find.text('Test Action'), findsNothing);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('should apply custom icon size', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommonEmptyState(
              title: 'Test Title',
              icon: Icons.info,
              iconSize: 100.0,
            ),
          ),
        ),
      );

      final iconFinder = find.byIcon(Icons.info);
      expect(iconFinder, findsOneWidget);

      final icon = tester.widget<Icon>(iconFinder);
      expect(icon.size, 100.0);
    });

    testWidgets('should apply custom title font size', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommonEmptyState(
              title: 'Test Title',
              titleFontSize: 24.0,
            ),
          ),
        ),
      );

      final titleFinder = find.text('Test Title');
      expect(titleFinder, findsOneWidget);

      final titleWidget = tester.widget<Text>(titleFinder);
      expect(titleWidget.style?.fontSize, 24.0);
    });

    testWidgets('should apply custom spacing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommonEmptyState(
              title: 'Test Title',
              icon: Icons.info,
              spacing: 32.0,
            ),
          ),
        ),
      );

      // Vérifier que les SizedBox ont la bonne hauteur
      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsAtLeastNWidgets(2));

      // Le premier SizedBox après l'icône devrait avoir une hauteur de 32.0
      final sizedBoxesList = sizedBoxes.evaluate().toList();
      for (final element in sizedBoxesList) {
        final sizedBox = element.widget as SizedBox;
        if (sizedBox.height == 32.0) {
          expect(sizedBox.height, 32.0);
          return;
        }
      }
      
      // Si on arrive ici, aucun SizedBox avec la bonne hauteur n'a été trouvé
      fail('No SizedBox with height 32.0 found');
    });

    testWidgets('should apply custom padding', (WidgetTester tester) async {
      const customPadding = EdgeInsets.all(64.0);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommonEmptyState(
              title: 'Test Title',
              padding: customPadding,
            ),
          ),
        ),
      );

      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);

      final container = tester.widget<Container>(containerFinder);
      expect(container.padding, customPadding);
    });

    testWidgets('should apply custom alignment', (WidgetTester tester) async {
      const customAlignment = Alignment.topLeft;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommonEmptyState(
              title: 'Test Title',
              alignment: customAlignment,
            ),
          ),
        ),
      );

      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);

      final container = tester.widget<Container>(containerFinder);
      expect(container.alignment, customAlignment);
    });

    testWidgets('should have correct default values', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommonEmptyState(
              title: 'Test Title',
              icon: Icons.info,
            ),
          ),
        ),
      );

      final iconFinder = find.byIcon(Icons.info);
      final icon = tester.widget<Icon>(iconFinder);
      expect(icon.size, 64.0);
      expect(icon.color, Colors.grey[400]);

      final titleFinder = find.text('Test Title');
      final titleWidget = tester.widget<Text>(titleFinder);
      expect(titleWidget.style?.fontSize, 18.0);
      expect(titleWidget.style?.color, Colors.grey[600]);
    });

    testWidgets('should center align text by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommonEmptyState(
              title: 'Test Title',
              subtitle: 'Test Subtitle',
            ),
          ),
        ),
      );

      final titleFinder = find.text('Test Title');
      final titleWidget = tester.widget<Text>(titleFinder);
      expect(titleWidget.textAlign, TextAlign.center);

      final subtitleFinder = find.text('Test Subtitle');
      final subtitleWidget = tester.widget<Text>(subtitleFinder);
      expect(subtitleWidget.textAlign, TextAlign.center);
    });

    testWidgets('should use mainAxisSize.min for Column', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommonEmptyState(
              title: 'Test Title',
            ),
          ),
        ),
      );

      final columnFinder = find.byType(Column);
      expect(columnFinder, findsOneWidget);

      final column = tester.widget<Column>(columnFinder);
      expect(column.mainAxisSize, MainAxisSize.min);
    });
  });
} 
