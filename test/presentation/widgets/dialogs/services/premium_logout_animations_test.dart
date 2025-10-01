import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/dialogs/services/premium_logout_animations.dart';

class TestTickerProvider extends StatefulWidget {
  final Widget Function(BuildContext context, TickerProvider vsync) builder;

  const TestTickerProvider({super.key, required this.builder});

  @override
  State<TestTickerProvider> createState() => _TestTickerProviderState();
}

class _TestTickerProviderState extends State<TestTickerProvider>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return widget.builder(context, this);
  }
}

void main() {
  group('PremiumLogoutAnimations', () {
    late PremiumLogoutAnimations animations;

    setUp(() {
      animations = PremiumLogoutAnimations();
    });

    tearDown(() {
      if (!animations._isDisposed) {
        animations.dispose();
      }
    });

    group('Initialization', () {
      testWidgets('should initialize animations correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TestTickerProvider(
                builder: (context, vsync) {
                  animations.initializeAnimations(
                    vsync: vsync,
                    animationDuration: const Duration(milliseconds: 600),
                  );
                  return Container();
                },
              ),
            ),
          ),
        );

        // Should not throw and animations should be accessible
        expect(animations.scaleAnimation, isA<Animation<double>>());
        expect(animations.fadeAnimation, isA<Animation<double>>());
        expect(animations.blurAnimation, isA<Animation<double>>());
        expect(animations.glowAnimation, isA<Animation<double>>());
      });

      test('should throw StateError when accessing animations before initialization', () {
        expect(() => animations.scaleAnimation, throwsStateError);
        expect(() => animations.fadeAnimation, throwsStateError);
        expect(() => animations.blurAnimation, throwsStateError);
        expect(() => animations.glowAnimation, throwsStateError);
      });
    });

    group('Animation Values', () {
      testWidgets('should have correct animation ranges', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TestTickerProvider(
                builder: (context, vsync) {
                  animations.initializeAnimations(
                    vsync: vsync,
                    animationDuration: const Duration(milliseconds: 600),
                  );
                  return Container();
                },
              ),
            ),
          ),
        );

        // Test initial values (should be at begin values)
        expect(animations.scaleAnimation.value, equals(0.7));
        expect(animations.fadeAnimation.value, equals(0.0));
        expect(animations.blurAnimation.value, equals(0.0));
        expect(animations.glowAnimation.value, equals(0.0));
      });
    });

    group('Entrance Animation', () {
      testWidgets('should start entrance animation when motion is not reduced', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TestTickerProvider(
                builder: (context, vsync) {
                  animations.initializeAnimations(
                    vsync: vsync,
                    animationDuration: const Duration(milliseconds: 600),
                  );

                  animations.startEntranceAnimation(
                    respectReducedMotion: false,
                    disableAnimations: false,
                  );

                  return Container();
                },
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Animation should have started (values should change)
        expect(animations.scaleAnimation.value, greaterThan(0.7));
        expect(animations.fadeAnimation.value, greaterThan(0.0));
        expect(animations.blurAnimation.value, greaterThan(0.0));
      });

      testWidgets('should skip animations when reduced motion is requested', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TestTickerProvider(
                builder: (context, vsync) {
                  animations.initializeAnimations(
                    vsync: vsync,
                    animationDuration: const Duration(milliseconds: 600),
                  );

                  animations.startEntranceAnimation(
                    respectReducedMotion: true,
                    disableAnimations: true,
                  );

                  return Container();
                },
              ),
            ),
          ),
        );

        await tester.pump();

        // Animation should be at end values immediately
        expect(animations.scaleAnimation.value, equals(1.0));
        expect(animations.fadeAnimation.value, equals(1.0));
        expect(animations.blurAnimation.value, equals(15.0));
      });
    });

    group('Success Particles', () {
      testWidgets('should manage particle state correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TestTickerProvider(
                builder: (context, vsync) {
                  animations.initializeAnimations(
                    vsync: vsync,
                    animationDuration: const Duration(milliseconds: 600),
                  );
                  return Container();
                },
              ),
            ),
          ),
        );

        // Initially particles should not be shown
        expect(animations.showParticles, isFalse);

        // Trigger particles
        animations.triggerSuccessParticles();
        expect(animations.showParticles, isTrue);

        // Wait for auto-hide
        await tester.pump(const Duration(milliseconds: 900));
        expect(animations.showParticles, isFalse);
      });
    });

    group('Exit Animation', () {
      testWidgets('should execute exit animation when motion is not reduced', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TestTickerProvider(
                builder: (context, vsync) {
                  animations.initializeAnimations(
                    vsync: vsync,
                    animationDuration: const Duration(milliseconds: 600),
                  );
                  return Container();
                },
              ),
            ),
          ),
        );

        // First forward the animation
        animations.startEntranceAnimation(
          respectReducedMotion: false,
          disableAnimations: false,
        );

        await tester.pumpAndSettle();

        // Now test exit
        final exitFuture = animations.exitWithAnimation(shouldReduceMotion: false);

        await tester.pump(const Duration(milliseconds: 100));

        // Animation should be reversing
        expect(animations.scaleAnimation.value, lessThan(1.0));

        await exitFuture;
      });

      testWidgets('should skip exit animation when motion is reduced', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TestTickerProvider(
                builder: (context, vsync) {
                  animations.initializeAnimations(
                    vsync: vsync,
                    animationDuration: const Duration(milliseconds: 600),
                  );
                  return Container();
                },
              ),
            ),
          ),
        );

        final exitFuture = animations.exitWithAnimation(shouldReduceMotion: true);

        // Should complete immediately
        await expectLater(exitFuture, completes);
      });
    });

    group('Factory', () {
      test('should create new instance', () {
        final instance = PremiumLogoutAnimationsFactory.create();
        expect(instance, isA<PremiumLogoutAnimations>());
        instance.dispose();
      });

      testWidgets('should create and initialize in one step', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TestTickerProvider(
                builder: (context, vsync) {
                  final instance = PremiumLogoutAnimationsFactory.createAndInitialize(
                    vsync: vsync,
                    animationDuration: const Duration(milliseconds: 300),
                  );

                  // Should be immediately usable
                  expect(instance.scaleAnimation, isA<Animation<double>>());
                  expect(instance.fadeAnimation, isA<Animation<double>>());
                  expect(instance.blurAnimation, isA<Animation<double>>());
                  expect(instance.glowAnimation, isA<Animation<double>>());

                  instance.dispose();
                  return Container();
                },
              ),
            ),
          ),
        );
      });
    });

    group('Disposal', () {
      testWidgets('should handle disposal correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TestTickerProvider(
                builder: (context, vsync) {
                  animations.initializeAnimations(
                    vsync: vsync,
                    animationDuration: const Duration(milliseconds: 600),
                  );
                  return Container();
                },
              ),
            ),
          ),
        );

        // Should not throw
        animations.dispose();

        // Triggering particles after disposal should not cause issues
        animations.triggerSuccessParticles();
        expect(animations.showParticles, isFalse);
      });
    });
  });
}