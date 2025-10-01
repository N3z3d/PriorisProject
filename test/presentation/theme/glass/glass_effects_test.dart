import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/theme/glass/glass_effects.dart';

void main() {
  group('GlassEffects Tests - SOLID Compliance', () {
    late GlassEffects glassEffects;

    setUp(() {
      glassEffects = GlassEffects();
    });

    group('SRP Compliance Tests', () {
      testWidgets('glassCard creates proper glass effect', (WidgetTester tester) async {
        final testWidget = MaterialApp(
          home: Scaffold(
            body: glassEffects.glassCard(
              child: const Text('Test'),
            ),
          ),
        );

        await tester.pumpWidget(testWidget);
        expect(find.text('Test'), findsOneWidget);
        expect(find.byType(ClipRRect), findsOneWidget);
        expect(find.byType(BackdropFilter), findsOneWidget);
      });

      testWidgets('blurredBackground creates proper stacked effect', (WidgetTester tester) async {
        final testWidget = MaterialApp(
          home: Scaffold(
            body: glassEffects.blurredBackground(
              background: Container(color: Colors.red),
              child: const Text('Test'),
            ),
          ),
        );

        await tester.pumpWidget(testWidget);
        expect(find.text('Test'), findsOneWidget);
        expect(find.byType(Stack), findsOneWidget);
        expect(find.byType(BackdropFilter), findsOneWidget);
      });

      testWidgets('professionalMorphism creates proper morphism effect', (WidgetTester tester) async {
        final testWidget = MaterialApp(
          home: Scaffold(
            body: glassEffects.professionalMorphism(
              child: const Text('Test'),
            ),
          ),
        );

        await tester.pumpWidget(testWidget);
        expect(find.text('Test'), findsOneWidget);
        expect(find.byType(ClipRRect), findsOneWidget);
        expect(find.byType(BackdropFilter), findsOneWidget);
      });
    });

    group('Interface Compliance Tests (ISP)', () {
      test('GlassEffects implements IGlassEffects interface', () {
        expect(glassEffects, isA<IGlassEffects>());
      });

      test('All interface methods are implemented', () {
        // Test that all required methods exist and can be called
        expect(() => glassEffects.glassCard(child: Container()), returnsNormally);
        expect(() => glassEffects.blurredBackground(
          child: Container(),
          background: Container(),
        ), returnsNormally);
        expect(() => glassEffects.professionalMorphism(child: Container()), returnsNormally);
        expect(() => glassEffects.professionalReflectiveSurface(child: Container()), returnsNormally);
      });
    });

    group('Parameter Validation Tests', () {
      testWidgets('glassCard accepts custom parameters', (WidgetTester tester) async {
        final testWidget = MaterialApp(
          home: Scaffold(
            body: glassEffects.glassCard(
              child: const Text('Test'),
              blur: 15.0,
              opacity: 0.2,
              color: Colors.blue,
              width: 200,
              height: 100,
            ),
          ),
        );

        await tester.pumpWidget(testWidget);
        expect(find.text('Test'), findsOneWidget);

        final container = tester.widget<Container>(find.byType(Container).first);
        expect(container.constraints?.maxWidth, 200);
        expect(container.constraints?.maxHeight, 100);
      });

      testWidgets('Toast position enum works correctly', (WidgetTester tester) async {
        final testWidget = MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                glassEffects.glassToast(
                  child: const Text('Test Top'),
                  position: ToastPosition.top,
                ),
                glassEffects.glassToast(
                  child: const Text('Test Bottom'),
                  position: ToastPosition.bottom,
                ),
              ],
            ),
          ),
        );

        await tester.pumpWidget(testWidget);
        expect(find.text('Test Top'), findsOneWidget);
        expect(find.text('Test Bottom'), findsOneWidget);
      });
    });

    group('Edge Cases Tests', () {
      testWidgets('glassCard with null parameters uses defaults', (WidgetTester tester) async {
        final testWidget = MaterialApp(
          home: Scaffold(
            body: glassEffects.glassCard(
              child: const Text('Test'),
            ),
          ),
        );

        await tester.pumpWidget(testWidget);
        expect(find.text('Test'), findsOneWidget);
      });

      testWidgets('glassModal with dismissible false prevents tap', (WidgetTester tester) async {
        var dismissed = false;
        final testWidget = MaterialApp(
          home: Scaffold(
            body: glassEffects.glassModal(
              child: const Text('Modal Test'),
              barrierDismissible: false,
              onDismiss: () => dismissed = true,
            ),
          ),
        );

        await tester.pumpWidget(testWidget);
        await tester.tap(find.byType(GestureDetector).first);
        expect(dismissed, false);
      });
    });
  });
}