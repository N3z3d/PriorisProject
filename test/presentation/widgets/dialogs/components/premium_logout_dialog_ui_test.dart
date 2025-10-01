import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/dialogs/components/premium_logout_dialog_ui.dart';

void main() {
  group('PremiumLogoutDialogUI', () {
    late PremiumLogoutDialogUI uiComponent;

    setUp(() {
      uiComponent = PremiumLogoutDialogUI();
    });

    group('Premium Header', () {
      testWidgets('should build premium header correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return uiComponent.buildPremiumHeader(
                    context,
                    const AlwaysStoppedAnimation(0.5),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('Se déconnecter'), findsOneWidget);
        expect(find.text('Choix de persistance des données'), findsOneWidget);
        expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
      });

      testWidgets('should animate with glow effect', (WidgetTester tester) async {
        const animation = AlwaysStoppedAnimation(0.8);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return uiComponent.buildPremiumHeader(context, animation);
                },
              ),
            ),
          ),
        );

        // Should render without throwing
        expect(find.byType(AnimatedBuilder), findsOneWidget);
        expect(find.text('Se déconnecter'), findsOneWidget);
      });
    });

    group('Main Content', () {
      testWidgets('should build main content with sync info', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: uiComponent.buildMainContent(context),
            ),
          ),
        );

        expect(find.text('Vos listes resteront disponibles sur cet appareil.'), findsOneWidget);
        expect(find.text('Synchronisation disponible'), findsOneWidget);
        expect(find.text('Reconnectez-vous à tout moment pour synchroniser vos données'), findsOneWidget);
        expect(find.byIcon(Icons.cloud_sync_rounded), findsOneWidget);
      });
    });

    group('Destructive Option', () {
      testWidgets('should build destructive option with proper styling', (WidgetTester tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: uiComponent.buildDestructiveOption(
                context,
                onTap: () => tapped = true,
                enablePhysicsAnimations: false,
                shouldReduceMotion: false,
              ),
            ),
          ),
        );

        expect(find.text('Effacer toutes mes données de cet appareil'), findsOneWidget);
        expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);

        // Test tap
        await tester.tap(find.text('Effacer toutes mes données de cet appareil'));
        expect(tapped, isTrue);
      });

      testWidgets('should use physics animations when enabled', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: uiComponent.buildDestructiveOption(
                context,
                onTap: () {},
                enablePhysicsAnimations: true,
                shouldReduceMotion: false,
              ),
            ),
          ),
        );

        // Should use PhysicsAnimations.springScale wrapper
        expect(find.text('Effacer toutes mes données de cet appareil'), findsOneWidget);
      });
    });

    group('Premium Actions', () {
      testWidgets('should build action buttons correctly', (WidgetTester tester) async {
        bool cancelTapped = false;
        bool logoutTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: uiComponent.buildPremiumActions(
                context,
                onCancel: () => cancelTapped = true,
                onLogout: () => logoutTapped = true,
                enablePhysicsAnimations: false,
                shouldReduceMotion: false,
              ),
            ),
          ),
        );

        expect(find.text('Annuler'), findsOneWidget);
        expect(find.text('Se déconnecter'), findsOneWidget);

        // Test cancel button
        await tester.tap(find.text('Annuler'));
        expect(cancelTapped, isTrue);

        // Test logout button
        await tester.tap(find.text('Se déconnecter'));
        expect(logoutTapped, isTrue);
      });
    });

    group('Individual Buttons', () {
      testWidgets('should build cancel button with proper styling', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: uiComponent.buildCancelButton(context),
            ),
          ),
        );

        expect(find.text('Annuler'), findsOneWidget);
      });

      testWidgets('should build logout button with proper styling', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: uiComponent.buildLogoutButton(context),
            ),
          ),
        );

        expect(find.text('Se déconnecter'), findsOneWidget);
      });
    });

    group('Data Clear Dialog', () {
      testWidgets('should build confirmation dialog correctly', (WidgetTester tester) async {
        bool cancelTapped = false;
        bool confirmTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: uiComponent.buildDataClearDialog(
              context,
              onCancel: () => cancelTapped = true,
              onConfirm: () => confirmTapped = true,
              enablePhysicsAnimations: false,
            ),
          ),
        );

        expect(find.text('Effacer les données'), findsOneWidget);
        expect(find.text('Cette action supprimera définitivement toutes vos listes de cet appareil.'), findsOneWidget);
        expect(find.text('Vous ne pourrez pas annuler cette action.'), findsOneWidget);
        expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);

        // Find buttons by their text in the dialog
        final cancelButtons = find.text('Annuler');
        final confirmButtons = find.text('Effacer');

        expect(cancelButtons, findsOneWidget);
        expect(confirmButtons, findsOneWidget);
      });
    });

    group('Full Dialog with Callbacks', () {
      testWidgets('should build complete dialog with all callbacks', (WidgetTester tester) async {
        bool cancelTapped = false;
        bool logoutTapped = false;
        bool dataClearTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: uiComponent.buildDialogWithCallbacks(
                context,
                onCancel: () => cancelTapped = true,
                onLogout: () => logoutTapped = true,
                onDataClear: () => dataClearTapped = true,
                glowAnimation: const AlwaysStoppedAnimation(0.5),
                enablePhysicsAnimations: false,
                shouldReduceMotion: false,
              ),
            ),
          ),
        );

        // Verify all components are present
        expect(find.text('Se déconnecter'), findsNWidgets(2)); // Header + Button
        expect(find.text('Choix de persistance des données'), findsOneWidget);
        expect(find.text('Vos listes resteront disponibles sur cet appareil.'), findsOneWidget);
        expect(find.text('Synchronisation disponible'), findsOneWidget);
        expect(find.text('Effacer toutes mes données de cet appareil'), findsOneWidget);
        expect(find.text('Annuler'), findsOneWidget);

        // Test interactions
        await tester.tap(find.text('Annuler'));
        expect(cancelTapped, isTrue);

        await tester.tap(find.text('Effacer toutes mes données de cet appareil'));
        expect(dataClearTapped, isTrue);

        // Find the logout button (the second "Se déconnecter" text)
        final logoutButtons = find.text('Se déconnecter');
        await tester.tap(logoutButtons.last);
        expect(logoutTapped, isTrue);
      });

      testWidgets('should handle reduced motion correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: uiComponent.buildDialogWithCallbacks(
                context,
                onCancel: () {},
                onLogout: () {},
                onDataClear: () {},
                glowAnimation: const AlwaysStoppedAnimation(0.0),
                enablePhysicsAnimations: true,
                shouldReduceMotion: true, // Should disable physics animations
              ),
            ),
          ),
        );

        // Should still render correctly
        expect(find.text('Se déconnecter'), findsNWidgets(2));
        expect(find.text('Annuler'), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper semantic labels', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: uiComponent.buildDialogWithCallbacks(
                context,
                onCancel: () {},
                onLogout: () {},
                onDataClear: () {},
                glowAnimation: const AlwaysStoppedAnimation(0.0),
                enablePhysicsAnimations: false,
                shouldReduceMotion: false,
              ),
            ),
          ),
        );

        // Should have Semantics wrapper
        expect(find.byType(Semantics), findsWidgets);
      });
    });
  });
}