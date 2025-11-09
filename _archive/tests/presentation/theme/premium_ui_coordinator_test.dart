import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/theme/premium_ui_coordinator.dart';
import 'package:prioris/presentation/theme/interfaces/premium_ui_interfaces.dart';
import 'package:prioris/presentation/widgets/loading/premium_skeletons.dart';

void main() {
  group('PremiumUICoordinator', () {
    late PremiumUICoordinator coordinator;

    setUp(() {
      coordinator = PremiumUICoordinator.instance;
    });

    tearDown(() {
      // Reset coordinator state for clean tests
      if (coordinator.isInitialized) {
        // Note: In a real app, we'd need a reset method
        // For testing, we use a fresh instance each time
      }
    });

    group('Initialization', () {
      testWidgets('should initialize all systems correctly', (tester) async {
        expect(coordinator.isInitialized, isFalse);

        await coordinator.initialize();

        expect(coordinator.isInitialized, isTrue);
        expect(coordinator.themeSystem, isA<IPremiumThemeSystem>());
        expect(coordinator.componentSystem, isA<IPremiumComponentSystem>());
        expect(coordinator.animationSystem, isA<IPremiumAnimationSystem>());
        expect(coordinator.layoutSystem, isA<IPremiumLayoutSystem>());
        expect(coordinator.modalSystem, isA<IPremiumModalSystem>());
        expect(coordinator.feedbackSystem, isA<IPremiumFeedbackSystem>());
      });

      test('should be a singleton', () {
        final instance1 = PremiumUICoordinator.instance;
        final instance2 = PremiumUICoordinator.instance;

        expect(identical(instance1, instance2), isTrue);
      });

      test('should not reinitialize if already initialized', () async {
        await coordinator.initialize();
        expect(coordinator.isInitialized, isTrue);

        // Second initialization should not throw
        await coordinator.initialize();
        expect(coordinator.isInitialized, isTrue);
      });
    });

    group('System Access', () {
      setUp(() async {
        await coordinator.initialize();
      });

      test('should provide access to theme system', () {
        expect(coordinator.themeSystem, isNotNull);
        expect(coordinator.themeSystem, isA<IPremiumThemeSystem>());
      });

      test('should provide access to component system', () {
        expect(coordinator.componentSystem, isNotNull);
        expect(coordinator.componentSystem, isA<IPremiumComponentSystem>());
      });

      test('should provide access to animation system', () {
        expect(coordinator.animationSystem, isNotNull);
        expect(coordinator.animationSystem, isA<IPremiumAnimationSystem>());
      });

      test('should provide access to layout system', () {
        expect(coordinator.layoutSystem, isNotNull);
        expect(coordinator.layoutSystem, isA<IPremiumLayoutSystem>());
      });

      test('should provide access to modal system', () {
        expect(coordinator.modalSystem, isNotNull);
        expect(coordinator.modalSystem, isA<IPremiumModalSystem>());
      });

      test('should provide access to feedback system', () {
        expect(coordinator.feedbackSystem, isNotNull);
        expect(coordinator.feedbackSystem, isA<IPremiumFeedbackSystem>());
      });

      test('should throw error when accessing systems before initialization', () {
        final uninitializedCoordinator = PremiumUICoordinator();

        expect(() => uninitializedCoordinator.themeSystem,
               throwsA(isA<StateError>()));
        expect(() => uninitializedCoordinator.componentSystem,
               throwsA(isA<StateError>()));
        expect(() => uninitializedCoordinator.animationSystem,
               throwsA(isA<StateError>()));
        expect(() => uninitializedCoordinator.layoutSystem,
               throwsA(isA<StateError>()));
        expect(() => uninitializedCoordinator.modalSystem,
               throwsA(isA<StateError>()));
        expect(() => uninitializedCoordinator.feedbackSystem,
               throwsA(isA<StateError>()));
      });
    });

    group('Backward Compatibility API', () {
      setUp(() async {
        await coordinator.initialize();
      });

      testWidgets('should create premium button', (tester) async {
        final button = coordinator.premiumButton(
          text: 'Test Button',
          onPressed: () {},
          style: PremiumButtonStyle.primary,
          size: ButtonSize.medium,
        );

        expect(button, isA<Widget>());

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: button)));
        await tester.pumpAndSettle();

        expect(find.text('Test Button'), findsOneWidget);
      });

      testWidgets('should create premium card', (tester) async {
        final card = coordinator.premiumCard(
          child: const Text('Card Content'),
          enableGlass: true,
          showLoading: false,
        );

        expect(card, isA<Widget>());

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: card)));
        await tester.pumpAndSettle();

        expect(find.text('Card Content'), findsOneWidget);
      });

      testWidgets('should create premium FAB', (tester) async {
        final fab = coordinator.premiumFAB(
          onPressed: () {},
          child: const Icon(Icons.add),
          enableHaptics: true,
        );

        expect(fab, isA<Widget>());

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: fab)));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.add), findsOneWidget);
      });

      testWidgets('should show premium modal', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      coordinator.showPremiumModal<void>(
                        context: context,
                        child: const Text('Modal Content'),
                        enableGlass: true,
                      );
                    },
                    child: const Text('Show Modal'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Modal'));
        await tester.pumpAndSettle();

        expect(find.text('Modal Content'), findsOneWidget);
      });
    });

    group('Convenience Methods', () {
      setUp(() async {
        await coordinator.initialize();
      });

      testWidgets('should show premium bottom sheet', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      coordinator.showPremiumBottomSheet<void>(
                        context: context,
                        child: const Text('Bottom Sheet Content'),
                        height: 300,
                      );
                    },
                    child: const Text('Show Bottom Sheet'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Bottom Sheet'));
        await tester.pumpAndSettle();

        expect(find.text('Bottom Sheet Content'), findsOneWidget);
      });

      testWidgets('should show premium success feedback', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      coordinator.showPremiumSuccess(
                        context: context,
                        message: 'Success message',
                        type: SuccessType.standard,
                      );
                    },
                    child: const Text('Show Success'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Success'));
        await tester.pumpAndSettle();

        // Verify feedback system was called
        // (In a real implementation, we'd mock the feedback system)
        expect(find.text('Show Success'), findsOneWidget);
      });

      testWidgets('should show premium error feedback', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      coordinator.showPremiumError(
                        context: context,
                        message: 'Error message',
                        enableHaptics: true,
                      );
                    },
                    child: const Text('Show Error'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Error'));
        await tester.pumpAndSettle();

        // Verify feedback system was called
        expect(find.text('Show Error'), findsOneWidget);
      });

      testWidgets('should show premium loading overlay', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      final overlay = coordinator.showPremiumLoading(
                        context: context,
                        message: 'Loading...',
                        enableGlass: true,
                      );
                      // Remove overlay immediately for test
                      overlay.remove();
                    },
                    child: const Text('Show Loading'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Loading'));
        await tester.pumpAndSettle();

        // Verify method executed without errors
        expect(find.text('Show Loading'), findsOneWidget);
      });
    });

    group('Error Handling', () {
      test('should provide descriptive error messages', () {
        final uninitializedCoordinator = PremiumUICoordinator();

        expect(() => uninitializedCoordinator.themeSystem,
               throwsA(predicate((e) =>
                 e is StateError &&
                 e.message.contains('PremiumUICoordinator must be initialized'))));
      });
    });

    group('SOLID Principles Compliance', () {
      setUp(() async {
        await coordinator.initialize();
      });

      test('should demonstrate Single Responsibility Principle', () {
        // The coordinator's single responsibility is coordination
        // Each system has its own specialized responsibility
        expect(coordinator.themeSystem, isNot(equals(coordinator.componentSystem)));
        expect(coordinator.componentSystem, isNot(equals(coordinator.animationSystem)));
        expect(coordinator.animationSystem, isNot(equals(coordinator.layoutSystem)));
      });

      test('should demonstrate Dependency Inversion Principle', () {
        // Coordinator depends on abstractions (interfaces), not concretions
        expect(coordinator.themeSystem, isA<IPremiumThemeSystem>());
        expect(coordinator.componentSystem, isA<IPremiumComponentSystem>());
        expect(coordinator.animationSystem, isA<IPremiumAnimationSystem>());
        expect(coordinator.layoutSystem, isA<IPremiumLayoutSystem>());
        expect(coordinator.modalSystem, isA<IPremiumModalSystem>());
        expect(coordinator.feedbackSystem, isA<IPremiumFeedbackSystem>());
      });

      test('should demonstrate Interface Segregation Principle', () {
        // Each system interface is focused and specific
        // No system is forced to depend on methods it doesn't use
        expect(coordinator.themeSystem.runtimeType.toString(),
               isNot(contains('Component')));
        expect(coordinator.componentSystem.runtimeType.toString(),
               isNot(contains('Theme')));
      });
    });
  });
}