import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/repositories/base/repository_interfaces.dart';
import 'package:prioris/data/repositories/impl/task_repository_impl.dart';
import 'package:prioris/domain/models/core/entities/task.dart';

class _TestTaskRepository extends TaskRepositoryImpl {
  _TestTaskRepository(this._tasks);

  final List<Task> _tasks;

  @override
  Future<List<Task>> getAll() async => List<Task>.from(_tasks);

  @override
  Future<Task> sanitize(Task entity) async => entity;
}

void main() {
  group('TaskRepositoryImpl.sortBy', () {
    late DateTime baseDate;

    setUp(() {
      baseDate = DateTime(2024, 1, 1);
    });

    test('sortBy handles due date ordering with null safety', () async {
      final tasks = [
        Task(
          title: 'No due',
          dueDate: null,
          priority: 2,
          createdAt: baseDate,
          updatedAt: baseDate,
        ),
        Task(
          title: 'Due Jan 3',
          dueDate: baseDate.add(const Duration(days: 2)),
          priority: 1,
          createdAt: baseDate,
          updatedAt: baseDate,
        ),
        Task(
          title: 'Due Jan 1',
          dueDate: baseDate,
          priority: 3,
          createdAt: baseDate,
          updatedAt: baseDate,
        ),
      ];

      final repo = _TestTaskRepository(tasks);

      final ascending = await repo.sortBy('due');
      expect(
        ascending.map((task) => task.title),
        equals(['Due Jan 1', 'Due Jan 3', 'No due']),
      );

      final descending = await repo.sortBy('due', ascending: false);
      expect(
        descending.map((task) => task.title),
        equals(['No due', 'Due Jan 3', 'Due Jan 1']),
      );
    });

    test('sortBy falls back to eloScore descending for unknown field', () async {
      final tasks = [
        Task(
          title: 'Low',
          eloScore: 900,
          createdAt: baseDate,
          updatedAt: baseDate,
        ),
        Task(
          title: 'High',
          eloScore: 1800,
          createdAt: baseDate,
          updatedAt: baseDate,
        ),
        Task(
          title: 'Mid',
          eloScore: 1200,
          createdAt: baseDate,
          updatedAt: baseDate,
        ),
      ];

      final repo = _TestTaskRepository(tasks);
      final result = await repo.sortBy('unknown-field');

      expect(result.first.title, equals('High'));
      expect(result.last.title, equals('Low'));
    });

    test('sortByMultiple applies comparators in order', () async {
      final tasks = [
        Task(
          title: 'Alpha',
          priority: 2,
          createdAt: baseDate,
          updatedAt: baseDate,
        ),
        Task(
          title: 'Beta',
          priority: 1,
          createdAt: baseDate.add(const Duration(days: 1)),
          updatedAt: baseDate.add(const Duration(days: 1)),
        ),
        Task(
          title: 'Gamma',
          priority: 1,
          createdAt: baseDate,
          updatedAt: baseDate,
        ),
      ];

      final repo = _TestTaskRepository(tasks);
      final result = await repo.sortByMultiple(const [
        SortCriteria(field: 'priority', ascending: true),
        SortCriteria(field: 'title', ascending: true),
      ]);

      expect(
        result.map((task) => task.title),
        equals(['Beta', 'Gamma', 'Alpha']),
      );
    });
  });

  group('TaskRepositoryImpl.getValidationErrors', () {
    test('reports simple title validation issues', () async {
      final task = Task(
        title: '',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final repo = _TestTaskRepository([]);
      final errors = await repo.getValidationErrors(task);

      expect(errors, contains('Le titre ne peut pas être vide'));
    });

    test('aggregates complex validation errors', () async {
      final createdAt = DateTime(2024, 1, 2);
      final invalidTask = Task(
        title: 'X' * 201,
        description: 'D' * 1001,
        priority: 0,
        eloScore: -5,
        createdAt: createdAt,
        updatedAt: createdAt.subtract(const Duration(days: 1)),
        dueDate: createdAt.subtract(const Duration(days: 1)),
        tags: List<String>.generate(
          11,
          (index) => index == 0 ? '' : 'tag-${'x' * 30}',
        ),
      );

      final repo = _TestTaskRepository([]);
      final errors = await repo.getValidationErrors(invalidTask);

      expect(errors, contains('Le titre ne peut pas dépasser 200 caractères'));
      expect(errors, contains('La description ne peut pas dépasser 1000 caractères'));
      expect(errors, contains('La priorité doit être entre 1 et 5'));
      expect(errors, contains('Le score ELO ne peut pas être négatif'));
      expect(errors, contains('La date d\'échéance ne peut pas être antérieure à la date de création'));
      expect(errors, contains('La date de mise à jour ne peut pas être antérieure à la date de création'));
      expect(errors, contains('Une tâche ne peut pas avoir plus de 10 tags'));
      expect(errors, contains('Les tags ne peuvent pas être vides'));
      expect(errors, contains('Les tags ne peuvent pas dépasser 30 caractères'));
    });
  });
}
