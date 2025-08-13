import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/common/layouts/common_section_header.dart';

void main() {
  group('CommonSectionHeader', () {
    testWidgets('should render with title only', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonSectionHeader(
              title: 'Test Title',
            ),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byType(Icon), findsNothing);
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('should render with title and subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonSectionHeader(
              title: 'Test Title',
              subtitle: 'Test Subtitle',
            ),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Subtitle'), findsOneWidget);
    });

    testWidgets('should render with icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonSectionHeader(
              title: 'Test Title',
              icon: Icons.star,
            ),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('should render with action button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonSectionHeader(
              title: 'Test Title',
              onAction: () {},
              actionLabel: 'Action',
            ),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Action'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('should not render action button when only onAction provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonSectionHeader(
              title: 'Test Title',
              onAction: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('should not render action button when only actionLabel provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonSectionHeader(
              title: 'Test Title',
              actionLabel: 'Action',
            ),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('should handle action button tap', (WidgetTester tester) async {
      bool actionCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonSectionHeader(
              title: 'Test Title',
              onAction: () => actionCalled = true,
              actionLabel: 'Action',
            ),
          ),
        ),
      );

      await tester.tap(find.text('Action'));
      expect(actionCalled, isTrue);
    });

    testWidgets('should apply custom title font size', (WidgetTester tester) async {
      const customFontSize = 24.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonSectionHeader(
              title: 'Test Title',
              titleFontSize: customFontSize,
            ),
          ),
        ),
      );

      final titleText = tester.widget<Text>(find.text('Test Title'));
      expect(titleText.style?.fontSize, equals(customFontSize));
    });

    testWidgets('should apply custom title color', (WidgetTester tester) async {
      const customColor = Colors.red;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonSectionHeader(
              title: 'Test Title',
              titleColor: customColor,
            ),
          ),
        ),
      );

      final titleText = tester.widget<Text>(find.text('Test Title'));
      expect(titleText.style?.color, equals(customColor));
    });

    testWidgets('should apply custom spacing', (WidgetTester tester) async {
      const customSpacing = 16.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonSectionHeader(
              title: 'Test Title',
              icon: Icons.star,
              spacing: customSpacing,
            ),
          ),
        ),
      );

      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      expect(sizedBoxes.any((sizedBox) => sizedBox.width == customSpacing), isTrue);
    });

    testWidgets('should render complete header with all elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonSectionHeader(
              title: 'Test Title',
              subtitle: 'Test Subtitle',
              icon: Icons.star,
              onAction: () {},
              actionLabel: 'Action',
            ),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Subtitle'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('Action'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('should use default values when not specified', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonSectionHeader(
              title: 'Test Title',
            ),
          ),
        ),
      );

      final titleText = tester.widget<Text>(find.text('Test Title'));
      expect(titleText.style?.fontSize, equals(18));
      expect(titleText.style?.fontWeight, equals(FontWeight.bold));
    });
  });
} 
