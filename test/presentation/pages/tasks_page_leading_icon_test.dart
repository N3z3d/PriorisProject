import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/repositories/task_repository.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/tasks_page.dart';

class _FakeTaskRepository implements TaskRepository {
  final List<Task> _tasks;
  final List<Task> updatedTasks = [];

  _FakeTaskRepository(List<Task> tasks) : _tasks = List.from(tasks);

  @override
  Future<List<Task>> getAllTasks() async => List.from(_tasks);

  @override
  Future<void> updateTask(Task task) async {
    updatedTasks.add(task);
    final i = _tasks.indexWhere((t) => t.id == task.id);
    if (i != -1) _tasks[i] = task;
  }

  @override
  Future<void> saveTask(Task task) async => _tasks.add(task);

  @override
  Future<void> deleteTask(String id) async =>
      _tasks.removeWhere((t) => t.id == id);

  @override
  Future<List<Task>> getActiveTasks() async =>
      _tasks.where((t) => !t.isCompleted).toList();

  @override
  Future<List<Task>> getCompletedTasks() async =>
      _tasks.where((t) => t.isCompleted).toList();

  @override
  Future<List<Task>> getTasksByCategory(String category) async =>
      _tasks.where((t) => t.category == category).toList();

  @override
  Future<void> clearAllTasks() async => _tasks.clear();

  @override
  Future<void> updateEloScores(Task winner, Task loser) async {}

  @override
  Future<List<Task>> getRandomTasksForDuel() async => [];
}

Widget _buildApp(_FakeTaskRepository repo) {
  return ProviderScope(
    overrides: [
      taskRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp(
      locale: const Locale('fr'),
      theme: ThemeData(splashFactory: InkRipple.splashFactory),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr'), Locale('en')],
      home: const TasksPage(),
    ),
  );
}

void main() {
  group('TasksPage — leading icon tappable (AC1)', () {
    testWidgets(
        'tapper le leading d\'une tâche non complétée → updateTask avec isCompleted=true',
        (tester) async {
      final handle = tester.ensureSemantics();
      final task = Task(title: 'Tâche à faire', isCompleted: false);
      final repo = _FakeTaskRepository([task]);

      await tester.pumpWidget(_buildApp(repo));
      await tester.pumpAndSettle();

      expect(find.text('Tâche à faire'), findsOneWidget);
      expect(repo.updatedTasks, isEmpty);

      await tester.tap(find.bySemanticsLabel('Marquer fait'));
      await tester.pumpAndSettle();

      expect(repo.updatedTasks, hasLength(1));
      expect(repo.updatedTasks.first.isCompleted, isTrue);
      expect(repo.updatedTasks.first.completedAt, isNotNull);
      handle.dispose();
    });

    testWidgets(
        'tapper le leading d\'une tâche complétée → updateTask avec isCompleted=false',
        (tester) async {
      final handle = tester.ensureSemantics();
      final task = Task(
        title: 'Tâche terminée',
        isCompleted: true,
        completedAt: DateTime(2024, 1, 1),
      );
      final repo = _FakeTaskRepository([task]);

      await tester.pumpWidget(_buildApp(repo));
      await tester.pumpAndSettle();

      expect(find.text('Tâche terminée'), findsOneWidget);
      expect(repo.updatedTasks, isEmpty);

      await tester.tap(find.bySemanticsLabel('Marquer non fait'));
      await tester.pumpAndSettle();

      expect(repo.updatedTasks, hasLength(1));
      expect(repo.updatedTasks.first.isCompleted, isFalse);
      handle.dispose();
    });

    testWidgets(
        'avec deux tâches, tapper le leading de la deuxième ne met à jour que la deuxième',
        (tester) async {
      final handle = tester.ensureSemantics();
      final task1 = Task(title: 'Tâche 1', isCompleted: false);
      final task2 = Task(title: 'Tâche 2', isCompleted: false);
      final repo = _FakeTaskRepository([task1, task2]);

      await tester.pumpWidget(_buildApp(repo));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Marquer fait'), findsNWidgets(2));

      await tester.tap(find.bySemanticsLabel('Marquer fait').at(1));
      await tester.pumpAndSettle();

      expect(repo.updatedTasks, hasLength(1));
      expect(repo.updatedTasks.first.id, equals(task2.id));
      expect(repo.updatedTasks.first.isCompleted, isTrue);
      handle.dispose();
    });
  });
}
