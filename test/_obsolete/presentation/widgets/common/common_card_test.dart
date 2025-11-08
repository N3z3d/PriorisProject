import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/common/layouts/common_card.dart';

void main() {
  group('CommonCard', () {
    testWidgets('should render with default properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: const Scaffold(
            body: CommonCard(
              child: const Text('Test Content'),
            ),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should apply custom padding', (WidgetTester tester) async {
      const customPadding = EdgeInsets.all(32.0);
      
      await tester.pumpWidget(
        const MaterialApp(
          home: const Scaffold(
            body: CommonCard(
              padding: customPadding,
              child: const Text('Test Content'),
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      final container = card.child as Container;
      expect(container.padding, equals(customPadding));
    });

    testWidgets('should apply custom elevation', (WidgetTester tester) async {
      const customElevation = 8.0;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: const Scaffold(
            body: CommonCard(
              elevation: customElevation,
              child: const Text('Test Content'),
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, equals(customElevation));
    });

    testWidgets('should apply custom border radius', (WidgetTester tester) async {
      const customRadius = BorderRadius.all(Radius.circular(8.0));
      
      await tester.pumpWidget(
        const MaterialApp(
          home: const Scaffold(
            body: CommonCard(
              borderRadius: customRadius,
              child: const Text('Test Content'),
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, equals(customRadius));
    });

    testWidgets('should apply custom background color', (WidgetTester tester) async {
      const customColor = Colors.red;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: const Scaffold(
            body: CommonCard(
              backgroundColor: customColor,
              child: const Text('Test Content'),
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.color, equals(customColor));
    });

    testWidgets('should apply custom width', (WidgetTester tester) async {
      const customWidth = 200.0;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: const Scaffold(
            body: CommonCard(
              width: customWidth,
              child: const Text('Test Content'),
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      final container = card.child as Container;
      expect(container.constraints?.maxWidth, equals(customWidth));
    });

    testWidgets('should apply custom height', (WidgetTester tester) async {
      const customHeight = 150.0;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: const Scaffold(
            body: CommonCard(
              height: customHeight,
              child: const Text('Test Content'),
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      final container = card.child as Container;
      expect(container.constraints?.maxHeight, equals(customHeight));
    });

    testWidgets('should handle tap callback', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: const Scaffold(
            body: CommonCard(
              onTap: () => tapped = true,
              child: const Text('Test Content'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CommonCard));
      expect(tapped, isTrue);
    });

    testWidgets('should not wrap in GestureDetector when no onTap provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: const Scaffold(
            body: CommonCard(
              child: const Text('Test Content'),
            ),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsNothing);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should wrap in GestureDetector when onTap provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: const Scaffold(
            body: CommonCard(
              onTap: () {},
              child: const Text('Test Content'),
            ),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should use default padding when not specified', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: const Scaffold(
            body: CommonCard(
              child: const Text('Test Content'),
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      final container = card.child as Container;
      expect(container.padding, equals(const EdgeInsets.all(20)));
    });

    testWidgets('should use default elevation when not specified', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: const Scaffold(
            body: CommonCard(
              child: const Text('Test Content'),
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, equals(4.0));
    });

    testWidgets('should use default border radius when not specified', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: const Scaffold(
            body: CommonCard(
              child: const Text('Test Content'),
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, equals(BorderRadius.circular(16)));
    });

    testWidgets('should use default background color when not specified', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: const Scaffold(
            body: CommonCard(
              child: const Text('Test Content'),
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.color, equals(Colors.white));
    });

    testWidgets('should render complex child widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: const Scaffold(
            body: CommonCard(
              child: Column(
                children: [
                  const Text('Title'),
                  const SizedBox(height: 8),
                  const Text('Subtitle'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Button'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Subtitle'), findsOneWidget);
      expect(find.text('Button'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
} 
