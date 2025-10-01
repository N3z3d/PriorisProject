import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/dialogs/handlers/premium_logout_interactions.dart';

void main() {
  group('PremiumLogoutInteractions', () {
    late PremiumLogoutInteractions interactionHandler;

    setUp(() {
      interactionHandler = PremiumLogoutInteractions();
    });

    group('Reduced Motion Detection', () {
      testWidgets('should detect reduced motion when disabled animations', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: Builder(
                builder: (context) {
                  final shouldReduce = interactionHandler.shouldReduceMotion(
                    context,
                    respectReducedMotion: true,
                  );
                  return Text(shouldReduce.toString());
                },
              ),
            ),
          ),
        );

        expect(find.text('true'), findsOneWidget);
      });

      testWidgets('should not reduce motion when respectReducedMotion is false', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: Builder(
                builder: (context) {
                  final shouldReduce = interactionHandler.shouldReduceMotion(
                    context,
                    respectReducedMotion: false,
                  );
                  return Text(shouldReduce.toString());
                },
              ),
            ),
          ),
        );

        expect(find.text('false'), findsOneWidget);
      });

      testWidgets('should not reduce motion when animations are enabled', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: false),
              child: Builder(
                builder: (context) {
                  final shouldReduce = interactionHandler.shouldReduceMotion(
                    context,
                    respectReducedMotion: true,
                  );
                  return Text(shouldReduce.toString());
                },
              ),
            ),
          ),
        );

        expect(find.text('false'), findsOneWidget);
      });
    });

    group('Handle Cancel', () {
      testWidgets('should execute cancel flow correctly', (WidgetTester tester) async {
        bool exitAnimationCalled = false;
        bool onCompleteCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await interactionHandler.handleCancel(
                      context,
                      enableHaptics: false, // Disable for testing
                      exitAnimation: () async {
                        exitAnimationCalled = true;
                      },
                      onComplete: () {
                        onCompleteCalled = true;
                      },
                    );
                  },
                  child: const Text('Test Cancel'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Test Cancel'));
        await tester.pumpAndSettle();

        expect(exitAnimationCalled, isTrue);
        expect(onCompleteCalled, isTrue);
      });
    });

    group('Handle Logout', () {
      testWidgets('should execute logout flow correctly', (WidgetTester tester) async {
        bool triggerParticlesCalled = false;
        bool exitAnimationCalled = false;
        bool onCompleteCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await interactionHandler.handleLogout(
                      context,
                      enableHaptics: false, // Disable for testing
                      triggerParticles: () {
                        triggerParticlesCalled = true;
                      },
                      exitAnimation: () async {
                        exitAnimationCalled = true;
                      },
                      onComplete: () {
                        onCompleteCalled = true;
                      },
                    );
                  },
                  child: const Text('Test Logout'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Test Logout'));
        await tester.pumpAndSettle();

        expect(triggerParticlesCalled, isTrue);
        expect(exitAnimationCalled, isTrue);
        expect(onCompleteCalled, isTrue);
      });
    });

    group('Data Clear Confirmation', () {
      testWidgets('should show data clear confirmation dialog', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await interactionHandler.showDataClearConfirmation(
                      context,
                      enableHaptics: false,
                      enablePhysicsAnimations: false,
                      respectReducedMotion: true,
                      exitAnimation: () async {},
                      onConfirmed: () {},
                    );
                  },
                  child: const Text('Show Confirmation'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Show Confirmation'));
        await tester.pumpAndSettle();

        // Confirmation dialog should appear
        expect(find.text('Effacer les données'), findsOneWidget);
        expect(find.text('Cette action supprimera définitivement toutes vos listes de cet appareil.'), findsOneWidget);
        expect(find.text('Vous ne pourrez pas annuler cette action.'), findsOneWidget);
        expect(find.text('Annuler'), findsOneWidget);
        expect(find.text('Effacer'), findsOneWidget);
      });

      testWidgets('should handle confirmation dialog cancel', (WidgetTester tester) async {
        bool exitAnimationCalled = false;
        bool onConfirmedCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await interactionHandler.showDataClearConfirmation(
                      context,
                      enableHaptics: false,
                      enablePhysicsAnimations: false,
                      respectReducedMotion: true,
                      exitAnimation: () async {
                        exitAnimationCalled = true;
                      },
                      onConfirmed: () {
                        onConfirmedCalled = true;
                      },
                    );
                  },
                  child: const Text('Show Confirmation'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Show Confirmation'));
        await tester.pumpAndSettle();

        // Cancel the confirmation dialog
        await tester.tap(find.text('Annuler'));
        await tester.pumpAndSettle();

        // Should not call callbacks when cancelled
        expect(exitAnimationCalled, isFalse);
        expect(onConfirmedCalled, isFalse);
      });

      testWidgets('should handle confirmation dialog confirm', (WidgetTester tester) async {
        bool exitAnimationCalled = false;
        bool onConfirmedCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await interactionHandler.showDataClearConfirmation(
                      context,
                      enableHaptics: false,
                      enablePhysicsAnimations: false,
                      respectReducedMotion: true,
                      exitAnimation: () async {
                        exitAnimationCalled = true;
                      },
                      onConfirmed: () {
                        onConfirmedCalled = true;
                      },
                    );
                  },
                  child: const Text('Show Confirmation'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Show Confirmation'));
        await tester.pumpAndSettle();

        // Confirm the action
        await tester.tap(find.text('Effacer'));
        await tester.pumpAndSettle();

        // Should call both callbacks when confirmed
        expect(exitAnimationCalled, isTrue);
        expect(onConfirmedCalled, isTrue);
      });
    });

    group('Initial Haptic Feedback', () {
      test('should trigger initial haptic feedback when enabled', () async {
        // This test doesn't directly test haptics since they require platform integration
        // but ensures the method completes without error
        await expectLater(
          interactionHandler.triggerInitialHapticFeedback(enableHaptics: true),
          completes,
        );
      });

      test('should skip haptic feedback when disabled', () async {
        await expectLater(
          interactionHandler.triggerInitialHapticFeedback(enableHaptics: false),
          completes,
        );
      });
    });

    group('Integration with UI Component', () {
      testWidgets('should work with data clear confirmation dialog animations', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await interactionHandler.showDataClearConfirmation(
                      context,
                      enableHaptics: false,
                      enablePhysicsAnimations: true, // Enable animations
                      respectReducedMotion: false,
                      exitAnimation: () async {},
                      onConfirmed: () {},
                    );
                  },
                  child: const Text('Show Animated Confirmation'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Show Animated Confirmation'));
        await tester.pump(); // Don't settle to see animation state

        // Dialog should appear with animations
        expect(find.text('Effacer les données'), findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('should handle context being null gracefully', (WidgetTester tester) async {
        // Test that methods don't throw when context conditions are unusual
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                // This should not throw even with basic context
                final shouldReduce = interactionHandler.shouldReduceMotion(
                  context,
                  respectReducedMotion: true,
                );
                return Text(shouldReduce.toString());
              },
            ),
          ),
        );

        expect(find.text('false'), findsOneWidget); // Should default to false
      });
    });
  });
}