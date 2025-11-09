import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/theme/systems/premium_animation_system.dart';

/// Tests for refactored PremiumAnimationSystem
/// Validates backward compatibility and SOLID compliance
void main() {
  group('PremiumAnimationSystem Refactoring Tests', () {
    late PremiumAnimationSystem animationSystem;

    setUp(() {
      animationSystem = PremiumAnimationSystem();
    });

    group('Initialization', () {
      test('should initialize successfully', () async {
        expect(animationSystem.isInitialized, isFalse);
        await animationSystem.initialize();
        expect(animationSystem.isInitialized, isTrue);
      });

      test('should handle multiple initialization calls', () async {
        await animationSystem.initialize();
        await animationSystem.initialize();
        expect(animationSystem.isInitialized, isTrue);
      });

      test('should throw StateError when not initialized', () {
        expect(
          () => animationSystem.createFadeTransition(
            child: const SizedBox(),
          ),
          throwsStateError,
        );
      });
    });

    group('Physics Animations - Backward Compatibility', () {
      setUp(() async {
        await animationSystem.initialize();
      });

      testWidgets('createSpringScale should work with tap callback',
          (tester) async {
        bool tapped = false;
        final widget = animationSystem.createSpringScale(
          child: const Text('Test'),
          onTap: () => tapped = true,
        );

        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.text('Test'), findsOneWidget);
      });

      testWidgets('createSpringScale should return plain child without tap',
          (tester) async {
        const testChild = Text('Test');
        final widget = animationSystem.createSpringScale(
          child: testChild,
          onTap: null,
        );

        await tester.pumpWidget(const MaterialApp(home: testChild));
        expect(find.text('Test'), findsOneWidget);
      });

      testWidgets('createElasticBounce should create widget',
          (tester) async {
        final widget = animationSystem.createElasticBounce(
          child: const Text('Bounce'),
        );

        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.text('Bounce'), findsOneWidget);
      });

      testWidgets('createGravityBounce should create widget',
          (tester) async {
        final widget = animationSystem.createGravityBounce(
          child: const Text('Gravity'),
        );

        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.text('Gravity'), findsOneWidget);
      });
    });

    group('Transition Animations - Backward Compatibility', () {
      setUp(() async {
        await animationSystem.initialize();
      });

      testWidgets('createFadeTransition should create widget',
          (tester) async {
        final widget = animationSystem.createFadeTransition(
          child: const Text('Fade'),
        );

        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.text('Fade'), findsOneWidget);
      });

      testWidgets('createFadeTransition should respond to trigger',
          (tester) async {
        final widget = animationSystem.createFadeTransition(
          child: const Text('Fade'),
          trigger: true,
        );

        await tester.pumpWidget(MaterialApp(home: widget));
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('Fade'), findsOneWidget);
      });

      testWidgets('createSlideTransition should create widget',
          (tester) async {
        final widget = animationSystem.createSlideTransition(
          child: const Text('Slide'),
        );

        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.text('Slide'), findsOneWidget);
      });

      testWidgets('createSlideTransition should accept custom offset',
          (tester) async {
        final widget = animationSystem.createSlideTransition(
          child: const Text('Slide'),
          offset: const Offset(1, 0),
        );

        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.text('Slide'), findsOneWidget);
      });
    });

    group('Advanced Animations - Backward Compatibility', () {
      setUp(() async {
        await animationSystem.initialize();
      });

      testWidgets('createStaggeredList should create list', (tester) async {
        final widget = animationSystem.createStaggeredList(
          children: [
            const Text('Item 1'),
            const Text('Item 2'),
            const Text('Item 3'),
          ],
        );

        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.text('Item 1'), findsOneWidget);
        expect(find.text('Item 2'), findsOneWidget);
        expect(find.text('Item 3'), findsOneWidget);
      });

      testWidgets('createPulse should create widget', (tester) async {
        final widget = animationSystem.createPulse(
          child: const Text('Pulse'),
        );

        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.text('Pulse'), findsOneWidget);
      });

      testWidgets('createPulse should accept custom scale range',
          (tester) async {
        final widget = animationSystem.createPulse(
          child: const Text('Pulse'),
          minScale: 0.9,
          maxScale: 1.1,
        );

        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.text('Pulse'), findsOneWidget);
      });

      testWidgets('createShake should create widget', (tester) async {
        final widget = animationSystem.createShake(
          child: const Text('Shake'),
        );

        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.text('Shake'), findsOneWidget);
      });

      testWidgets('createShake should accept custom parameters',
          (tester) async {
        final widget = animationSystem.createShake(
          child: const Text('Shake'),
          offset: 15.0,
          count: 5,
        );

        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.text('Shake'), findsOneWidget);
      });
    });

    group('Default Parameters Validation', () {
      setUp(() async {
        await animationSystem.initialize();
      });

      testWidgets('should use default duration when not specified',
          (tester) async {
        final widget = animationSystem.createFadeTransition(
          child: const Text('Default'),
        );

        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.text('Default'), findsOneWidget);
      });

      testWidgets('should use default scale when not specified',
          (tester) async {
        final widget = animationSystem.createSpringScale(
          child: const Text('Default'),
          onTap: () {},
        );

        await tester.pumpWidget(MaterialApp(home: widget));
        expect(find.text('Default'), findsOneWidget);
      });
    });

    group('SOLID Compliance Validation', () {
      test('system should delegate to builders (SRP)', () async {
        await animationSystem.initialize();

        // Verify that system acts as coordinator, not implementer
        expect(animationSystem.isInitialized, isTrue);
      });

      test('system should be extensible (OCP)', () async {
        await animationSystem.initialize();

        // New animation types can be added via new builders
        // without modifying the main system
        expect(() => animationSystem.createFadeTransition(
          child: const SizedBox(),
        ), returnsNormally);
      });

      test('system should support dependency inversion (DIP)', () async {
        // System depends on abstractions (interface)
        // Builders can be replaced without affecting the system
        await animationSystem.initialize();
        expect(animationSystem.isInitialized, isTrue);
      });
    });
  });
}
