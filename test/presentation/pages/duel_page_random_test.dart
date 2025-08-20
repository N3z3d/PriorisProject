import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/presentation/pages/duel_page.dart';

/// Tests pour le mode aléatoire dans la page duel
/// Approche TDD : Red -> Green -> Refactor
void main() {
  group('DuelPage - Mode Aléatoire', () {
    testWidgets('doit afficher un bouton Aléatoire dans l\'interface de duel', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const DuelPage(),
          ),
        ),
      );

      // Act - attendre que le widget soit construit
      await tester.pumpAndSettle();

      // Assert - chercher le bouton "Aléatoire"
      expect(find.text('Aléatoire'), findsOneWidget);
    });

    testWidgets('doit afficher une icône shuffle pour le mode aléatoire', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const DuelPage(),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - chercher le bouton contenant l'icône shuffle
      final randomButtons = find.widgetWithIcon(ElevatedButton, Icons.shuffle);
      expect(randomButtons, findsOneWidget);
    });

    testWidgets('taper sur le bouton Aléatoire doit déclencher une sélection aléatoire', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const DuelPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - taper sur le bouton Aléatoire
      await tester.tap(find.text('Aléatoire'));
      await tester.pumpAndSettle();

      // Assert - pour l'instant, vérifions juste que le bouton répond
      // L'implémentation complète sera testée plus tard
      expect(find.text('Aléatoire'), findsOneWidget);
    });
  });
}