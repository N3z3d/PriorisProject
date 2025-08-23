import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/common/accessibility/accessible_loading_state.dart';

void main() {
  group('AccessibleLoadingState', () {
    testWidgets('WCAG 4.1.3 - Should announce loading state to screen readers', (tester) async {
      // ARRANGE
      const testChild = Text('Test content');
      
      // ACT - Afficher en état de chargement
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleLoadingState(
              isLoading: true,
              loadingMessage: 'Chargement des données',
              child: testChild,
            ),
          ),
        ),
      );
      
      // ASSERT - Vérifier présence d'indicateur de chargement accessible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // ASSERT - Vérifier que le message de chargement est présent
      expect(find.text('Chargement des données'), findsOneWidget);
      
      // ASSERT - Vérifier que le contenu original est présent mais atténué
      expect(find.text('Test content'), findsOneWidget);
    });

    testWidgets('WCAG 4.1.3 - Should announce error state to screen readers', (tester) async {
      // ARRANGE
      const testChild = Text('Test content');
      const errorMessage = 'Erreur de connexion réseau';
      
      // ACT - Afficher en état d'erreur
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleLoadingState(
              isLoading: false,
              error: errorMessage,
              child: testChild,
            ),
          ),
        ),
      );
      
      // ASSERT - Vérifier présence du message d'erreur
      expect(find.text(errorMessage), findsOneWidget);
      
      // ASSERT - Vérifier présence de l'icône d'erreur
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      
      // ASSERT - Vérifier que le contenu original est toujours visible
      expect(find.text('Test content'), findsOneWidget);
    });

    testWidgets('Should display normal content when no loading or error', (tester) async {
      // ARRANGE
      const testChild = Text('Test content');
      
      // ACT - Afficher en état normal
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleLoadingState(
              isLoading: false,
              error: null,
              child: testChild,
            ),
          ),
        ),
      );
      
      // ASSERT - Seul le contenu original doit être visible
      expect(find.text('Test content'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('WCAG 2.5.5 - Error message should have adequate touch target', (tester) async {
      // ARRANGE
      const testChild = Text('Test content');
      const errorMessage = 'Erreur de test';
      
      // ACT
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleLoadingState(
              isLoading: false,
              error: errorMessage,
              child: testChild,
            ),
          ),
        ),
      );
      
      // ASSERT - Vérifier que le container d'erreur a une taille suffisante
      final errorContainer = tester.widget<Container>(
        find.ancestor(
          of: find.text(errorMessage),
          matching: find.byType(Container),
        ).first,
      );
      
      expect(errorContainer.padding, const EdgeInsets.all(12));
    });
  });

  group('AccessibleStatusAnnouncement', () {
    testWidgets('WCAG 4.1.3 - Should announce status changes', (tester) async {
      String? currentMessage;
      
      // ACT - Widget initial sans message
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    AccessibleStatusAnnouncement(
                      message: currentMessage,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentMessage = 'Données sauvegardées avec succès';
                        });
                      },
                      child: const Text('Déclencher annonce'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
      
      // ASSERT - Initialement pas d'annonce
      expect(find.text('Données sauvegardées avec succès'), findsNothing);
      
      // ACT - Déclencher l'annonce
      await tester.tap(find.text('Déclencher annonce'));
      await tester.pump();
      
      // ASSERT - L'annonce doit être présente (même si invisible visuellement)
      // La recherche trouve le texte même s'il est stylistiquement caché
      expect(find.text('Données sauvegardées avec succès'), findsOneWidget);
    });

    testWidgets('Should auto-hide announcement after duration', (tester) async {
      // ARRANGE
      const testDuration = Duration(milliseconds: 100);
      
      // ACT
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleStatusAnnouncement(
              message: 'Message temporaire',
              duration: testDuration,
            ),
          ),
        ),
      );
      
      // ASSERT - Message initialement présent
      expect(find.text('Message temporaire'), findsOneWidget);
      
      // ACT - Attendre la durée + un peu plus
      await tester.pump(testDuration + const Duration(milliseconds: 50));
      
      // ASSERT - Message doit avoir disparu
      expect(find.text('Message temporaire'), findsNothing);
    });
  });
}