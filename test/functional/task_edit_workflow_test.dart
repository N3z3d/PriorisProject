import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/widgets/dialogs/task_edit_dialog.dart';
import 'package:prioris/presentation/pages/duel/widgets/duel_task_card.dart';

/// Tests fonctionnels pour le workflow complet d'édition de tâches
/// Simule le parcours utilisateur depuis le bouton d'édition jusqu'à la sauvegarde
void main() {
  group('Task Edit Workflow', () {
    testWidgets('Complete edit workflow: button -> dialog -> submit', (tester) async {
      // Données de test
      final originalTask = Task(
        id: 'workflow-test-id',
        title: 'Tâche originale',
        description: 'Description originale',
        category: 'Test',
        eloScore: 1300.0,
      );

      Task? editedTask;

      // Interface utilisateur simplifiée
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: DuelTaskCard(
                task: originalTask,
                onTap: () {},
                onEdit: () {
                  showDialog(
                    context: tester.element(find.byType(DuelTaskCard)),
                    builder: (context) => TaskEditDialog(
                      initialTask: originalTask,
                      onSubmit: (task) {
                        editedTask = task;
                      },
                    ),
                  );
                },
                hideElo: false,
              ),
            ),
          ),
        ),
      );

      // ÉTAPE 1: Vérifier l'état initial
      expect(find.text('Tâche originale'), findsOneWidget);
      expect(find.text('Description originale'), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);

      // ÉTAPE 2: Cliquer sur le bouton d'édition
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // ÉTAPE 3: Vérifier que le dialog s'est ouvert avec les bonnes données
      expect(find.text('Modifier la tâche'), findsOneWidget);
      expect(find.text('Tâche originale'), findsNWidgets(2)); // Une fois dans la carte, une fois dans le dialog

      // ÉTAPE 4: Modifier les données dans le formulaire
      await tester.enterText(find.byType(TextField).first, 'Tâche modifiée');
      await tester.enterText(find.byType(TextField).at(1), 'Nouvelle description');
      await tester.enterText(find.byType(TextField).at(2), 'Nouvelle catégorie');

      // ÉTAPE 5: Soumettre les modifications
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      // ÉTAPE 6: Vérifier que la tâche a été correctement mise à jour
      expect(editedTask, isNotNull);
      expect(editedTask!.id, equals('workflow-test-id')); // ID préservé
      expect(editedTask!.title, equals('Tâche modifiée'));
      expect(editedTask!.description, equals('Nouvelle description'));
      expect(editedTask!.category, equals('Nouvelle catégorie'));
      expect(editedTask!.eloScore, equals(1300.0)); // Score ELO préservé

      // ÉTAPE 7: Vérifier que le dialog s'est fermé
      expect(find.text('Modifier la tâche'), findsNothing);
    });

    testWidgets('Cancel edit workflow should not modify task', (tester) async {
      final originalTask = Task(
        id: 'cancel-test-id',
        title: 'Tâche à ne pas modifier',
        description: 'Description à préserver',
        eloScore: 1250.0,
      );

      Task? modifiedTask;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: tester.element(find.byType(ElevatedButton)),
                    builder: (context) => TaskEditDialog(
                      initialTask: originalTask,
                      onSubmit: (task) {
                        modifiedTask = task;
                      },
                    ),
                  );
                },
                child: const Text('Éditer'),
              ),
            ),
          ),
        ),
      );

      // Ouvrir le dialog
      await tester.tap(find.text('Éditer'));
      await tester.pumpAndSettle();

      // Modifier quelque chose
      await tester.enterText(find.byType(TextField).first, 'Modification temporaire');

      // Annuler au lieu de sauvegarder
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      // Vérifier qu'aucune tâche n'a été soumise
      expect(modifiedTask, isNull);
      expect(find.text('Modifier la tâche'), findsNothing);
    });

    testWidgets('Validation errors should prevent submission', (tester) async {
      Task? submittedTask;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: tester.element(find.byType(ElevatedButton)),
                    builder: (context) => TaskEditDialog(
                      onSubmit: (task) {
                        submittedTask = task;
                      },
                    ),
                  );
                },
                child: const Text('Nouvelle tâche'),
              ),
            ),
          ),
        ),
      );

      // Ouvrir le dialog
      await tester.tap(find.text('Nouvelle tâche'));
      await tester.pumpAndSettle();

      // Essayer de soumettre sans titre
      await tester.tap(find.text('Ajouter'));
      await tester.pump();

      // Vérifier que le message d'erreur est affiché
      expect(find.text('Le titre est obligatoire pour identifier cette tâche'), findsOneWidget);
      
      // Vérifier qu'aucune tâche n'a été soumise
      expect(submittedTask, isNull);
      
      // Vérifier que le dialog est toujours ouvert
      expect(find.text('Ajouter une tâche'), findsOneWidget);

      // Corriger l'erreur
      await tester.enterText(find.byType(TextField).first, 'Titre valide');
      await tester.tap(find.text('Ajouter'));
      await tester.pumpAndSettle();

      // Maintenant la tâche doit être soumise
      expect(submittedTask, isNotNull);
      expect(submittedTask!.title, equals('Titre valide'));
    });

    testWidgets('Edit workflow should preserve task relationships', (tester) async {
      final taskWithRelationships = Task(
        id: 'relationship-test',
        title: 'Tâche avec relations',
        description: 'Description originale',
        category: 'Important',
        eloScore: 1450.0,
        createdAt: DateTime(2024, 1, 15),
        tags: ['urgent', 'projet'],
        priority: 5,
        dueDate: DateTime(2024, 2, 1),
      );

      Task? editedTask;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: tester.element(find.byType(ElevatedButton)),
                    builder: (context) => TaskEditDialog(
                      initialTask: taskWithRelationships,
                      onSubmit: (task) {
                        editedTask = task;
                      },
                    ),
                  );
                },
                child: const Text('Éditer tâche complexe'),
              ),
            ),
          ),
        ),
      );

      // Ouvrir et modifier seulement le titre
      await tester.tap(find.text('Éditer tâche complexe'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Titre modifié');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      // Vérifier que les propriétés non-éditables sont préservées
      expect(editedTask!.id, equals('relationship-test'));
      expect(editedTask!.title, equals('Titre modifié')); // Modifié
      expect(editedTask!.eloScore, equals(1450.0)); // Préservé
      expect(editedTask!.createdAt, equals(DateTime(2024, 1, 15))); // Préservé
      expect(editedTask!.tags, equals(['urgent', 'projet'])); // Préservé
      expect(editedTask!.priority, equals(5)); // Préservé
      expect(editedTask!.dueDate, equals(DateTime(2024, 2, 1))); // Préservé
    });
  });
}