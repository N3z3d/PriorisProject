import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/widgets/dialogs/task_edit_dialog.dart';

void main() {
  group('TaskEditDialog', () {
    late Task testTask;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 30);
      testTask = Task(
        id: 'test-task-id',
        title: 'Test Task',
        description: 'Test description',
        category: 'Work',
        eloScore: 1250.0,
        createdAt: testDate,
      );
    });

    testWidgets('should display task creation dialog', (tester) async {
      bool submitted = false;
      Task? submittedTask;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => TaskEditDialog(
                    onSubmit: (task) {
                      submitted = true;
                      submittedTask = task;
                    },
                  ),
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      // Ouvrir le dialogue
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Vérifier que le dialogue est affiché
      expect(find.text('Ajouter une tâche'), findsOneWidget);
      expect(find.text('Titre'), findsOneWidget);
      expect(find.text('Description (optionnel)'), findsOneWidget);
      expect(find.text('Catégorie (optionnel)'), findsOneWidget);

      // Remplir les champs
      await tester.enterText(find.byType(TextField).first, 'New Task');
      await tester.enterText(find.byType(TextField).at(1), 'New description');
      await tester.enterText(find.byType(TextField).at(2), 'Personal');

      // Soumettre
      await tester.tap(find.text('Ajouter'));
      await tester.pumpAndSettle();

      // Vérifier la soumission
      expect(submitted, isTrue);
      expect(submittedTask?.title, equals('New Task'));
      expect(submittedTask?.description, equals('New description'));
      expect(submittedTask?.category, equals('Personal'));
      expect(submittedTask?.eloScore, equals(1200.0)); // Score par défaut
    });

    testWidgets('should display task edit dialog', (tester) async {
      bool submitted = false;
      Task? submittedTask;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => TaskEditDialog(
                    initialTask: testTask,
                    onSubmit: (task) {
                      submitted = true;
                      submittedTask = task;
                    },
                  ),
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      // Ouvrir le dialogue
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Vérifier que le dialogue est affiché avec les données existantes
      expect(find.text('Modifier la tâche'), findsOneWidget);
      expect(find.text('Test Task'), findsOneWidget);
      expect(find.text('Test description'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);

      // Modifier le titre
      await tester.enterText(find.byType(TextField).first, 'Modified Task');

      // Soumettre
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      // Vérifier la soumission
      expect(submitted, isTrue);
      expect(submittedTask?.id, equals('test-task-id'));
      expect(submittedTask?.title, equals('Modified Task'));
      expect(submittedTask?.description, equals('Test description'));
      expect(submittedTask?.category, equals('Work'));
    });

    testWidgets('should validate required fields', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => TaskEditDialog(
                    onSubmit: (task) {},
                  ),
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      // Ouvrir le dialogue
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Essayer de soumettre sans titre
      await tester.tap(find.text('Ajouter'));
      await tester.pump();

      // Vérifier le message d'erreur
      expect(find.text('Le titre est obligatoire pour identifier cette tâche'), findsOneWidget);

      // Entrer un titre trop court
      await tester.enterText(find.byType(TextField).first, 'A');
      await tester.tap(find.text('Ajouter'));
      await tester.pump();

      expect(find.text('Le titre doit contenir au moins 2 caractères'), findsOneWidget);
    });

    testWidgets('should cancel dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => TaskEditDialog(
                    onSubmit: (task) {},
                  ),
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      // Ouvrir le dialogue
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Annuler
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      // Vérifier que le dialogue est fermé
      expect(find.text('Ajouter une tâche'), findsNothing);
    });

    testWidgets('should handle long text inputs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => TaskEditDialog(
                    onSubmit: (task) {},
                  ),
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      // Ouvrir le dialogue
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Entrer un titre très long
      final longTitle = 'A' * 250;
      await tester.enterText(find.byType(TextField).first, longTitle);
      await tester.tap(find.text('Ajouter'));
      await tester.pump();

      // Vérifier le message d'erreur
      expect(find.textContaining('Le titre ne peut pas dépasser 200 caractères'), findsOneWidget);
    });
  });
}