import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/presentation/widgets/dialogs/premium_logout_dialog.dart';

void main() {
  group('PremiumLogoutDialog Tests', () {
    testWidgets('can be created without errors', (WidgetTester tester) async {
      // Basic test to ensure widget can be instantiated
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: const SizedBox(
                width: 400,
                height: 600,
                child: PremiumLogoutDialog(
                  enablePhysicsAnimations: false,
                  enableParticles: false,
                  enableHaptics: false,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      
      // Should find the dialog widget
      expect(find.byType(PremiumLogoutDialog), findsOneWidget);
    });

    testWidgets('displays glassmorphism elements', (WidgetTester tester) async {
      // Test that glassmorphism elements are present
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: const SizedBox(
                width: 400,
                height: 600,
                child: PremiumLogoutDialog(
                  enablePhysicsAnimations: false,
                  enableParticles: false,
                  enableHaptics: false,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      
      // Should find glassmorphism elements
      expect(find.byType(BackdropFilter), findsWidgets);
    });

    testWidgets('supports basic functionality without animations', (WidgetTester tester) async {
      // Test basic functionality with animations disabled
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: const SizedBox(
                width: 400,
                height: 600,
                child: PremiumLogoutDialog(
                  enablePhysicsAnimations: false,
                  enableParticles: false,
                  enableHaptics: false,
                  respectReducedMotion: true,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      
      // Should find the dialog widget
      expect(find.byType(PremiumLogoutDialog), findsOneWidget);
    });
  });

  group('PremiumLogoutHelper Tests', () {
    testWidgets('helper class exists', (WidgetTester tester) async {
      // Basic test to ensure helper class can be accessed
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Test'),
          ),
        ),
      );

      // Test that helper class exists (compile-time check)
      expect(PremiumLogoutHelper, isNotNull);
    });
  });
}