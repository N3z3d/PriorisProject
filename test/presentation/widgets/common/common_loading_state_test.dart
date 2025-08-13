import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/common/layouts/common_loading_state.dart';

void main() {
  group('CommonLoadingState', () {
    testWidgets('should render with default properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonLoadingState(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('should render with custom message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonLoadingState(
              message: 'Loading...',
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('should apply custom size', (WidgetTester tester) async {
      const customSize = 48.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonLoadingState(
              size: customSize,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, equals(customSize));
      expect(sizedBox.height, equals(customSize));
    });

    testWidgets('should apply custom color', (WidgetTester tester) async {
      const customColor = Colors.red;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonLoadingState(
              color: customColor,
            ),
          ),
        ),
      );

      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      final valueColor = progressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(valueColor.value, equals(customColor));
    });

    testWidgets('should apply custom spacing', (WidgetTester tester) async {
      const customSpacing = 24.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonLoadingState(
              message: 'Loading...',
              spacing: customSpacing,
            ),
          ),
        ),
      );

      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      expect(sizedBoxes.any((sizedBox) => sizedBox.height == customSpacing), isTrue);
    });

    testWidgets('should apply custom alignment', (WidgetTester tester) async {
      const customAlignment = Alignment.topLeft;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonLoadingState(
              alignment: customAlignment,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.alignment, equals(customAlignment));
    });

    testWidgets('should apply custom padding', (WidgetTester tester) async {
      const customPadding = EdgeInsets.all(32.0);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonLoadingState(
              padding: customPadding,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.padding, equals(customPadding));
    });

    testWidgets('should use default values when not specified', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonLoadingState(),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, equals(24.0));
      expect(sizedBox.height, equals(24.0));

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.alignment, equals(Alignment.center));
      expect(container.padding, equals(const EdgeInsets.all(20)));
    });
  });
} 
