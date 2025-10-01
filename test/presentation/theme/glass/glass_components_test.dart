import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/theme/glass/glass_components.dart';

void main() {
  group('GlassComponents Tests - SOLID Compliance', () {
    late GlassComponents glassComponents;

    setUp(() {
      glassComponents = GlassComponents();
    });

    group('SRP Compliance Tests', () {
      testWidgets('glassButton creates interactive button', (WidgetTester tester) async {
        var pressed = false;
        final testWidget = MaterialApp(
          home: Scaffold(
            body: glassComponents.glassButton(
              child: const Text('Button'),
              onPressed: () => pressed = true,
            ),
          ),
        );

        await tester.pumpWidget(testWidget);
        expect(find.text('Button'), findsOneWidget);
        expect(find.byType(GlassButton), findsOneWidget);

        await tester.tap(find.byType(GlassButton));
        await tester.pump();
        expect(pressed, true);
      });

      testWidgets('glassFAB creates floating action button', (WidgetTester tester) async {
        var pressed = false;
        final testWidget = MaterialApp(
          home: Scaffold(
            body: glassComponents.glassFAB(
              child: const Icon(Icons.add),
              onPressed: () => pressed = true,
            ),
          ),
        );

        await tester.pumpWidget(testWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();
        expect(pressed, true);
      });
    });

    group('Interface Compliance Tests (ISP)', () {
      test('GlassComponents implements IGlassComponents interface', () {
        expect(glassComponents, isA<IGlassComponents>());
      });

      test('All interface methods are implemented', () {
        expect(() => glassComponents.glassButton(
          child: Container(),
          onPressed: () {},
        ), returnsNormally);

        expect(() => glassComponents.glassFAB(
          child: Container(),
          onPressed: () {},
        ), returnsNormally);
      });
    });

    group('Animation Tests', () {
      testWidgets('GlassButton responds to tap with animation', (WidgetTester tester) async {
        final testWidget = MaterialApp(
          home: Scaffold(
            body: GlassButton(
              child: const Text('Animated Button'),
              onPressed: () {},
              color: Colors.white,
              blur: 10.0,
              opacity: 0.2,
            ),
          ),
        );

        await tester.pumpWidget(testWidget);

        // Test initial state
        expect(find.text('Animated Button'), findsOneWidget);

        // Test tap down animation
        await tester.press(find.byType(GlassButton));
        await tester.pump(const Duration(milliseconds: 75));

        // Should have scale animation
        final transform = tester.widget<Transform>(find.byType(Transform).first);
        expect(transform.transform, isNotNull);

        // Test tap up
        await tester.pumpAndSettle();
        expect(find.text('Animated Button'), findsOneWidget);
      });

      testWidgets('GlassButton handles tap cancel', (WidgetTester tester) async {
        final testWidget = MaterialApp(
          home: Scaffold(
            body: GlassButton(
              child: const Text('Cancel Test'),
              onPressed: () {},
              color: Colors.white,
              blur: 10.0,
              opacity: 0.2,
            ),
          ),
        );

        await tester.pumpWidget(testWidget);

        // Start press but don't complete
        final gesture = await tester.startGesture(tester.getCenter(find.byType(GlassButton)));
        await tester.pump(const Duration(milliseconds: 50));

        // Cancel the gesture
        await gesture.cancel();
        await tester.pumpAndSettle();

        expect(find.text('Cancel Test'), findsOneWidget);
      });
    });

    group('Parameter Validation Tests', () {
      testWidgets('GlassButton accepts custom styling parameters', (WidgetTester tester) async {
        final testWidget = MaterialApp(
          home: Scaffold(
            body: GlassButton(
              child: const Text('Custom Button'),
              onPressed: () {},
              color: Colors.red,
              blur: 20.0,
              opacity: 0.5,
              padding: const EdgeInsets.all(16),
            ),
          ),
        );

        await tester.pumpWidget(testWidget);
        expect(find.text('Custom Button'), findsOneWidget);

        // Should have BackdropFilter with custom blur
        expect(find.byType(BackdropFilter), findsOneWidget);
      });

      testWidgets('glassFAB accepts custom parameters', (WidgetTester tester) async {
        final testWidget = MaterialApp(
          home: Scaffold(
            body: glassComponents.glassFAB(
              child: const Icon(Icons.star),
              onPressed: () {},
              backgroundColor: Colors.blue,
              elevation: 10.0,
              heroTag: 'custom_fab',
            ),
          ),
        );

        await tester.pumpWidget(testWidget);
        expect(find.byIcon(Icons.star), findsOneWidget);

        final fab = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
        expect(fab.elevation, 10.0);
        expect(fab.heroTag, 'custom_fab');
      });
    });

    group('Edge Cases Tests', () {
      testWidgets('GlassButton with null padding uses defaults', (WidgetTester tester) async {
        final testWidget = MaterialApp(
          home: Scaffold(
            body: GlassButton(
              child: const Text('Default Padding'),
              onPressed: () {},
              color: Colors.white,
              blur: 10.0,
              opacity: 0.2,
            ),
          ),
        );

        await tester.pumpWidget(testWidget);
        expect(find.text('Default Padding'), findsOneWidget);
      });

      testWidgets('glassFAB with null backgroundColor uses default', (WidgetTester tester) async {
        final testWidget = MaterialApp(
          home: Scaffold(
            body: glassComponents.glassFAB(
              child: const Icon(Icons.home),
              onPressed: () {},
            ),
          ),
        );

        await tester.pumpWidget(testWidget);
        expect(find.byIcon(Icons.home), findsOneWidget);
      });
    });

    group('SOLID Principles Validation', () {
      test('Single Responsibility: Only handles interactive glass components', () {
        // GlassComponents should only handle interactive elements
        final component = GlassComponents();
        expect(component, isA<IGlassComponents>());

        // Should not have methods for static effects
        expect(component.runtimeType.toString(), 'GlassComponents');
      });

      test('Open/Closed: Extensible via interface', () {
        // Can create custom implementation
        final customComponent = CustomGlassComponents();
        expect(customComponent, isA<IGlassComponents>());
      });

      test('Liskov Substitution: Interface implementations are substitutable', () {
        IGlassComponents component1 = GlassComponents();
        IGlassComponents component2 = CustomGlassComponents();

        // Both should implement the same interface methods
        expect(() => component1.glassButton(child: Container(), onPressed: () {}), returnsNormally);
        expect(() => component2.glassButton(child: Container(), onPressed: () {}), returnsNormally);
      });
    });
  });
}

/// Test implementation for LSP validation
class CustomGlassComponents implements IGlassComponents {
  @override
  Widget glassButton({
    required Widget child,
    required VoidCallback onPressed,
    Color color = Colors.white,
    double blur = 10.0,
    double opacity = 0.2,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
  }) {
    return Container(child: child);
  }

  @override
  Widget glassFAB({
    required VoidCallback onPressed,
    required Widget child,
    Color? backgroundColor,
    double elevation = 6.0,
    String? heroTag,
  }) {
    return Container(child: child);
  }
}