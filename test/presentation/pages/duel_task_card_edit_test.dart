import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/pages/duel/widgets/duel_task_card.dart';

/// Tests pour vérifier la fonctionnalité d'édition dans les cartes de duel
void main() {
  group('DuelTaskCard Edit Functionality', () {
    late Task testTask;

    setUp(() {
      testTask = Task(
        id: 'test-task-1',
        title: 'Ma tâche de test',
        description: 'Description détaillée',
        category: 'Travail',
        eloScore: 1400.0,
      );
    });

    testWidgets('should display edit button when onEdit callback is provided', (tester) async {
      bool editButtonTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 300,
              child: DuelTaskCard(
                task: testTask,
                onTap: () {},
                onEdit: () => editButtonTapped = true,
                hideElo: false,
              ),
            ),
          ),
        ),
      );

      // Vérifier que le bouton d'édition est présent
      expect(find.byIcon(Icons.edit), findsOneWidget);
      
      // Vérifier que le callback fonctionne
      await tester.tap(find.byIcon(Icons.edit));
      expect(editButtonTapped, isTrue);
    });

    testWidgets('should not display edit button when onEdit is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 300,
              child: DuelTaskCard(
                task: testTask,
                onTap: () {},
                onEdit: null, // Pas de callback d'édition
                hideElo: false,
              ),
            ),
          ),
        ),
      );

      // Vérifier que le bouton d'édition n'est pas présent
      expect(find.byIcon(Icons.edit), findsNothing);
    });

    testWidgets('should display task content and edit button together', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 300,
              child: DuelTaskCard(
                task: testTask,
                onTap: () {},
                onEdit: () {},
                hideElo: false,
              ),
            ),
          ),
        ),
      );

      // Vérifier que le contenu de la tâche est affiché
      expect(find.text('Ma tâche de test'), findsOneWidget);
      expect(find.text('Description détaillée'), findsOneWidget);
      expect(find.text('Travail'), findsOneWidget);
      
      // Vérifier que le score ELO est affiché
      expect(find.text('1400'), findsOneWidget);
      
      // Vérifier que le bouton d'édition est toujours présent
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('should hide ELO score but show edit button when hideElo is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 300,
              child: DuelTaskCard(
                task: testTask,
                onTap: () {},
                onEdit: () {},
                hideElo: true, // Masquer le score ELO
              ),
            ),
          ),
        ),
      );

      // Vérifier que le score ELO n'est pas affiché
      expect(find.text('1400'), findsNothing);
      
      // Vérifier que le bouton d'édition est toujours présent
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('should handle edit button tap without affecting main card tap', (tester) async {
      bool cardTapped = false;
      bool editTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 300,
              child: DuelTaskCard(
                task: testTask,
                onTap: () => cardTapped = true,
                onEdit: () => editTapped = true,
                hideElo: false,
              ),
            ),
          ),
        ),
      );

      // Taper sur le bouton d'édition
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Vérifier que seul le callback d'édition a été appelé
      expect(editTapped, isTrue);
      expect(cardTapped, isFalse);

      // Reset pour tester le tap sur la carte
      editTapped = false;
      cardTapped = false;

      // Taper sur le titre de la tâche (zone principale)
      await tester.tap(find.text('Ma tâche de test'));
      await tester.pumpAndSettle();

      // Vérifier que seul le callback principal a été appelé
      expect(cardTapped, isTrue);
      expect(editTapped, isFalse);
    });

    testWidgets('should handle task with minimal information', (tester) async {
      final minimalTask = Task(
        title: 'Tâche simple',
        eloScore: 1200.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 300,
              child: DuelTaskCard(
                task: minimalTask,
                onTap: () {},
                onEdit: () {},
                hideElo: false,
              ),
            ),
          ),
        ),
      );

      // Vérifier que le titre est affiché
      expect(find.text('Tâche simple'), findsOneWidget);
      
      // Vérifier que le bouton d'édition est présent même avec des données minimales
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });
  });
}