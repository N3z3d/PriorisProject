import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/pages/duel_page.dart';
import 'package:prioris/presentation/widgets/dialogs/task_edit_dialog.dart';
import 'package:prioris/data/repositories/task_repository.dart';

/// Tests d'intégration TDD pour l'édition de tâches dans le DuelPage
/// Vérifie l'intégration complète du bouton d'édition et du dialog
void main() {
  group('DuelPage Task Edit Integration', () {
    late List<Task> mockTasks;

    setUp(() {
      mockTasks = [
        Task(
          id: 'task-1',
          title: 'Première tâche',
          description: 'Description de la première tâche',
          category: 'Travail',
          eloScore: 1300.0,
        ),
        Task(
          id: 'task-2',
          title: 'Deuxième tâche',
          description: 'Description de la deuxième tâche',
          category: 'Personnel',
          eloScore: 1250.0,
        ),
      ];
    });

    testWidgets('should display edit buttons on task cards', (tester) async {
      // Créer un override du repository pour les tests
      final container = ProviderContainer(
        overrides: [
          taskRepositoryProvider.overrideWith((ref) => TestTaskRepository(mockTasks)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: DuelPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Chercher les boutons d'édition
      final editButtons = find.byIcon(Icons.edit);
      expect(editButtons, findsAtLeastNWidgets(1));
    });

    testWidgets('should open TaskEditDialog when edit button is tapped', (tester) async {
      final container = ProviderContainer(
        overrides: [
          taskRepositoryProvider.overrideWith((ref) => TestTaskRepository(mockTasks)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: DuelPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Trouver et taper sur le premier bouton d'édition
      final firstEditButton = find.byIcon(Icons.edit).first;
      await tester.tap(firstEditButton);
      await tester.pumpAndSettle();

      // Vérifier que le dialog d'édition est affiché
      expect(find.text('Modifier la tâche'), findsOneWidget);
      expect(find.text('Première tâche'), findsOneWidget);
      expect(find.text('Description de la première tâche'), findsOneWidget);
    });

    testWidgets('should edit task and refresh duel when submitted', (tester) async {
      final testRepository = TestTaskRepository(mockTasks);
      final container = ProviderContainer(
        overrides: [
          taskRepositoryProvider.overrideWith((ref) => testRepository),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: DuelPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Ouvrir le dialog d'édition
      final firstEditButton = find.byIcon(Icons.edit).first;
      await tester.tap(firstEditButton);
      await tester.pumpAndSettle();

      // Modifier le titre de la tâche
      final titleField = find.byType(TextField).first;
      await tester.enterText(titleField, 'Tâche modifiée');
      
      // Soumettre les modifications
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      // Vérifier que la tâche a été mise à jour
      expect(testRepository.updatedTasks.length, equals(1));
      expect(testRepository.updatedTasks.first.title, equals('Tâche modifiée'));

      // Vérifier qu'un message de succès est affiché
      expect(find.text('Tâche "Tâche modifiée" mise à jour avec succès'), findsOneWidget);
    });

    testWidgets('should handle edit errors gracefully', (tester) async {
      final testRepository = TestTaskRepository(mockTasks, shouldFailUpdate: true);
      final container = ProviderContainer(
        overrides: [
          taskRepositoryProvider.overrideWith((ref) => testRepository),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: DuelPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Ouvrir le dialog d'édition
      final firstEditButton = find.byIcon(Icons.edit).first;
      await tester.tap(firstEditButton);
      await tester.pumpAndSettle();

      // Modifier le titre
      final titleField = find.byType(TextField).first;
      await tester.enterText(titleField, 'Tâche modifiée');
      
      // Soumettre (cela devrait échouer)
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      // Vérifier qu'un message d'erreur est affiché
      expect(find.textContaining('Erreur lors de la mise à jour'), findsOneWidget);
    });

    testWidgets('should preserve task ELO score when editing', (tester) async {
      final testRepository = TestTaskRepository(mockTasks);
      final container = ProviderContainer(
        overrides: [
          taskRepositoryProvider.overrideWith((ref) => testRepository),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: DuelPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Ouvrir et fermer le dialog sans modifications
      final firstEditButton = find.byIcon(Icons.edit).first;
      await tester.tap(firstEditButton);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      // Vérifier que le score ELO n'a pas changé
      final updatedTask = testRepository.updatedTasks.first;
      expect(updatedTask.eloScore, equals(1300.0));
    });
  });
}

/// Repository de test pour simuler les opérations CRUD
class TestTaskRepository implements TaskRepository {
  final List<Task> _tasks;
  final List<Task> updatedTasks = [];
  final bool shouldFailUpdate;

  TestTaskRepository(this._tasks, {this.shouldFailUpdate = false});

  @override
  Future<List<Task>> getAllTasks() async {
    return List.from(_tasks);
  }

  @override
  Future<void> saveTask(Task task) async {
    _tasks.add(task);
  }

  @override
  Future<void> updateTask(Task task) async {
    if (shouldFailUpdate) {
      throw Exception('Erreur de mise à jour simulée');
    }

    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      updatedTasks.add(task);
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
  }

  @override
  Future<List<Task>> getActiveTasks() async {
    return _tasks.where((task) => !task.isCompleted).toList();
  }

  @override
  Future<List<Task>> getCompletedTasks() async {
    return _tasks.where((task) => task.isCompleted).toList();
  }

  @override
  Future<List<Task>> getTasksByCategory(String category) async {
    return _tasks.where((task) => task.category == category).toList();
  }

  @override
  Future<void> clearAllTasks() async {
    _tasks.clear();
  }

  @override
  Future<void> updateEloScores(Task winner, Task loser) async {
    // Mettre à jour les scores ELO en utilisant la logique interne
    winner.updateEloScore(loser, true);
    loser.updateEloScore(winner, false);
    
    // Sauvegarder les tâches mises à jour
    await updateTask(winner);
    await updateTask(loser);
  }

  @override
  Future<List<Task>> getRandomTasksForDuel() async {
    final activeTasks = await getActiveTasks();
    if (activeTasks.length < 2) {
      return activeTasks;
    }
    
    // Retourner les 2 premiers pour les tests (pas de randomisation)
    return activeTasks.take(2).toList();
  }
}