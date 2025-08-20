import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/widgets/dialogs/task_edit_dialog.dart';

/// Tests d'intégration spécifiques pour TaskEditDialog
/// Teste l'interface utilisateur et les interactions de base
void main() {
  group('TaskEditDialog Integration', () {
    late Task testTask;

    setUp(() {
      testTask = Task(
        id: 'test-id',
        title: 'Test Task Title',
        description: 'Test description',
        category: 'Work',
        eloScore: 1350.0,
      );
    });

    testWidgets('should display glassmorphism design elements', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => TaskEditDialog(
                    initialTask: testTask,
                    onSubmit: (task) {},
                  ),
                ),
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      // Ouvrir le dialogue
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Vérifier la présence des éléments visuels premium
      expect(find.text('Modifier la tâche'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      
      // Vérifier les champs sont pré-remplis avec les données de la tâche
      expect(find.text('Test Task Title'), findsOneWidget);
      expect(find.text('Test description'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
    });

    testWidgets('should validate and display error messages properly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => TaskEditDialog(
                    onSubmit: (task) {},
                  ),
                ),
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      // Ouvrir le dialogue
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Vider le champ titre
      await tester.enterText(find.byType(TextField).first, '');
      
      // Essayer de soumettre
      await tester.tap(find.text('Ajouter'));
      await tester.pump();

      // Vérifier le message d'erreur
      expect(find.text('Le titre est obligatoire pour identifier cette tâche'), findsOneWidget);
    });

    testWidgets('should handle form submission correctly', (tester) async {
      Task? submittedTask;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => TaskEditDialog(
                    initialTask: testTask,
                    onSubmit: (task) {
                      submittedTask = task;
                    },
                  ),
                ),
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      // Ouvrir le dialogue
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Modifier le titre
      await tester.enterText(find.byType(TextField).first, 'Modified Title');
      
      // Soumettre
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      // Vérifier que la tâche a été soumise avec les bonnes données
      expect(submittedTask, isNotNull);
      expect(submittedTask!.title, equals('Modified Title'));
      expect(submittedTask!.description, equals('Test description'));
      expect(submittedTask!.category, equals('Work'));
      expect(submittedTask!.id, equals('test-id')); // L'ID doit être préservé
    });

    testWidgets('should close dialog when cancel is pressed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => TaskEditDialog(
                    onSubmit: (task) {},
                  ),
                ),
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      // Ouvrir le dialogue
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Vérifier que le dialogue est ouvert
      expect(find.text('Ajouter une tâche'), findsOneWidget);

      // Taper sur Annuler
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      // Vérifier que le dialogue est fermé
      expect(find.text('Ajouter une tâche'), findsNothing);
    });

    testWidgets('should handle empty optional fields correctly', (tester) async {
      Task? submittedTask;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => TaskEditDialog(
                    onSubmit: (task) {
                      submittedTask = task;
                    },
                  ),
                ),
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      // Ouvrir le dialogue
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Remplir seulement le titre
      await tester.enterText(find.byType(TextField).first, 'Simple Task');
      
      // Laisser description et catégorie vides
      
      // Soumettre
      await tester.tap(find.text('Ajouter'));
      await tester.pumpAndSettle();

      // Vérifier que la tâche a été créée correctement
      expect(submittedTask, isNotNull);
      expect(submittedTask!.title, equals('Simple Task'));
      expect(submittedTask!.description, isNull);
      expect(submittedTask!.category, isNull);
      expect(submittedTask!.eloScore, equals(1200.0)); // Score par défaut
    });

    testWidgets('should trim whitespace from input fields', (tester) async {
      Task? submittedTask;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => TaskEditDialog(
                    onSubmit: (task) {
                      submittedTask = task;
                    },
                  ),
                ),
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      // Ouvrir le dialogue
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Remplir avec des espaces avant/après
      await tester.enterText(find.byType(TextField).at(0), '  Trimmed Title  ');
      await tester.enterText(find.byType(TextField).at(1), '  Trimmed Description  ');
      await tester.enterText(find.byType(TextField).at(2), '  Trimmed Category  ');
      
      // Soumettre
      await tester.tap(find.text('Ajouter'));
      await tester.pumpAndSettle();

      // Vérifier que les espaces ont été supprimés
      expect(submittedTask!.title, equals('Trimmed Title'));
      expect(submittedTask!.description, equals('Trimmed Description'));
      expect(submittedTask!.category, equals('Trimmed Category'));
    });
  });
}