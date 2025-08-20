import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/buttons/premium_fab.dart';

void main() {
  group('Premium FAB UI/UX Tests', () {
    testWidgets('Premium FAB should have glassmorphism design', (tester) async {
      // RED: Test should fail initially
      
      const testText = 'Ajouter';
      var wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumFAB(
              text: testText,
              icon: Icons.add,
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      // Test visual elements
      expect(find.text(testText), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Test glassmorphism container
      expect(find.byType(Container), findsWidgets);
      
      // Test button functionality
      await tester.tap(find.byType(PremiumFAB));
      await tester.pump();
      
      expect(wasPressed, true);
    });

    testWidgets('Premium FAB should have premium animations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumFAB(
              text: 'Ajouter',
              icon: Icons.add,
              onPressed: () {},
              enableAnimations: true,
            ),
          ),
        ),
      );

      // Hover animation test
      final fabFinder = find.byType(PremiumFAB);
      await tester.tap(fabFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should have scale animation
      expect(find.byType(AnimatedScale), findsOneWidget);
    });

    testWidgets('Premium FAB should support different states', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                PremiumFAB(
                  text: 'Normal',
                  icon: Icons.add,
                  onPressed: () {},
                ),
                PremiumFAB(
                  text: 'Loading',
                  icon: Icons.add,
                  onPressed: () {},
                  isLoading: true,
                ),
                PremiumFAB(
                  text: 'Disabled',
                  icon: Icons.add,
                  onPressed: null,
                ),
              ],
            ),
          ),
        ),
      );

      // Normal state
      expect(find.text('Normal'), findsOneWidget);
      
      // Loading state should show progress indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Disabled state should be grayed out
      expect(find.text('Disabled'), findsOneWidget);
    });
  });
}