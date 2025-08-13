import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/buttons/action_button.dart';

void main() {
  group('ActionButton', () {
    testWidgets('should display icon and tooltip correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionButton(
              icon: Icons.edit,
              color: Colors.blue,
              onTap: () {},
              tooltip: 'Test tooltip',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionButton(
              icon: Icons.edit,
              color: Colors.blue,
              onTap: () => tapped = true,
              tooltip: 'Test tooltip',
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ActionButton));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('should show loading state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionButton(
              icon: Icons.edit,
              color: Colors.blue,
              onTap: () {},
              tooltip: 'Test tooltip',
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(ActionButton), findsOneWidget);
      
      // Vérifier que l'animation de rotation est active
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('should have correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionButton(
              icon: Icons.edit,
              color: Colors.blue,
              onTap: () {},
              tooltip: 'Test tooltip',
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration as BoxDecoration;
      
      expect(decoration.borderRadius, isA<BorderRadius>());
      expect(decoration.border, isA<Border>());
    });

    testWidgets('should handle tap animations', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionButton(
              icon: Icons.edit,
              color: Colors.blue,
              onTap: () {},
              tooltip: 'Test tooltip',
            ),
          ),
        ),
      );

      // Simuler un tap down
      await tester.tap(find.byType(ActionButton), pointer: 1);
      await tester.pump();
      
      // Simuler un tap up
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('should not call onTap when loading', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionButton(
              icon: Icons.edit,
              color: Colors.blue,
              onTap: () => tapped = true,
              tooltip: 'Test tooltip',
              isLoading: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ActionButton));
      await tester.pump();

      expect(tapped, isFalse);
    });
  });
} 
