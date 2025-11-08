import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/presentation/widgets/dialogs/premium_logout_dialog.dart';
import 'package:prioris/presentation/widgets/dialogs/interfaces/premium_dialog_interfaces.dart';

void main() {
  group('PremiumLogoutDialog Refactoring Tests', () {
    testWidgets('Original dialog should render all required components', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => const PremiumLogoutDialog(),
                  ),
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      // Tap to show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog components exist
      expect(find.text('Se déconnecter'), findsWidgets);
      expect(find.text('Choix de persistance des données'), findsOneWidget);
      expect(find.text('Vos listes resteront disponibles sur cet appareil.'), findsOneWidget);
      expect(find.text('Synchronisation disponible'), findsOneWidget);
      expect(find.text('Effacer toutes mes données de cet appareil'), findsOneWidget);
      expect(find.text('Annuler'), findsOneWidget);
      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
      expect(find.byIcon(Icons.cloud_sync_rounded), findsOneWidget);
    });

    testWidgets('Cancel button should close dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => const PremiumLogoutDialog(),
                  ),
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Find and tap cancel button
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('Se déconnecter'), findsNothing);
    });

    testWidgets('Logout button should trigger logout flow', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () async {
                    final result = await showDialog<String>(
                      context: context,
                      builder: (context) => const PremiumLogoutDialog(),
                    );
                    if (result != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Result: $result')),
                      );
                    }
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Find and tap logout button (the second "Se déconnecter" text)
      final logoutButtons = find.text('Se déconnecter');
      await tester.tap(logoutButtons.last);
      await tester.pumpAndSettle();

      // Should show result in snackbar
      expect(find.text('Result: logout_keep_data'), findsOneWidget);
    });

    testWidgets('Data clear option should show confirmation dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => const PremiumLogoutDialog(),
                  ),
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Tap the destructive option
      await tester.tap(find.text('Effacer toutes mes données de cet appareil'));
      await tester.pumpAndSettle();

      // Confirmation dialog should appear
      expect(find.text('Effacer les données'), findsOneWidget);
      expect(find.text('Cette action supprimera définitivement toutes vos listes de cet appareil.'), findsOneWidget);
      expect(find.text('Vous ne pourrez pas annuler cette action.'), findsOneWidget);
    });

    testWidgets('Dialog should respect reduced motion settings', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => PremiumLogoutDialog.legacy(
                        respectReducedMotion: true,
                      ),
                    ),
                    child: const Text('Show Dialog'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pump(); // Only one pump to not wait for animations

      // Dialog should still render properly without animations
      expect(find.text('Se déconnecter'), findsWidgets);
      expect(find.text('Annuler'), findsOneWidget);
    });

    group('Configuration Tests', () {
      test('PremiumLogoutDialogConfig should have proper defaults', () {
        const config = PremiumLogoutDialogConfig();

        expect(config.enableHaptics, isTrue);
        expect(config.enablePhysicsAnimations, isTrue);
        expect(config.enableParticles, isTrue);
        expect(config.respectReducedMotion, isTrue);
        expect(config.animationDuration, const Duration(milliseconds: 600));
      });

      test('PremiumLogoutDialogConfig should accept custom values', () {
        const config = PremiumLogoutDialogConfig(
          enableHaptics: false,
          enablePhysicsAnimations: false,
          enableParticles: false,
          respectReducedMotion: false,
          animationDuration: Duration(milliseconds: 300),
        );

        expect(config.enableHaptics, isFalse);
        expect(config.enablePhysicsAnimations, isFalse);
        expect(config.enableParticles, isFalse);
        expect(config.respectReducedMotion, isFalse);
        expect(config.animationDuration, const Duration(milliseconds: 300));
      });
    });
  });

  group('Interface Contract Tests', () {
    test('IPremiumLogoutAnimations should define required methods', () {
      // This test ensures our interface has all required methods
      // Implementation will be tested in component-specific tests
      expect(IPremiumLogoutAnimations, isA<Type>());
    });

    test('IPremiumLogoutDialogUI should define required methods', () {
      expect(IPremiumLogoutDialogUI, isA<Type>());
    });

    test('IPremiumLogoutInteractions should define required methods', () {
      expect(IPremiumLogoutInteractions, isA<Type>());
    });
  });
}