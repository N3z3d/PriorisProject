import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/habit/repositories/habit_repository.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/data/repositories/habit_repository.dart'
    show InMemoryHabitRepository;
import 'package:prioris/data/repositories/supabase/supabase_habit_repository.dart';

void main() {
  group('HabitRepository — contrat de port domaine', () {
    test('InMemoryHabitRepository implémente HabitRepository du domaine', () {
      expect(InMemoryHabitRepository(), isA<HabitRepository>());
    });

    test('SupabaseHabitRepository implémente HabitRepository du domaine', () {
      expect(SupabaseHabitRepository(), isA<HabitRepository>());
    });

    test('HabitRepository est dans lib/domain/, non dans lib/data/', () {
      // Test documentaire : si ce test compile, l'import domain est correct.
      HabitRepository? repo;
      expect(repo, isNull);
    });
  });

  group('InMemoryHabitRepository — comportement de base', () {
    late HabitRepository repo;

    setUp(() {
      repo = InMemoryHabitRepository();
    });

    Habit _makeHabit({String id = 'h1', String name = 'Test', String category = 'Santé'}) {
      return Habit(
        id: id,
        name: name,
        type: HabitType.binary,
        category: category,
      );
    }

    test('getAllHabits retourne liste vide initialement', () async {
      final habits = await repo.getAllHabits();
      expect(habits, isEmpty);
    });

    test('addHabit puis getAllHabits retourne l\'habitude ajoutée', () async {
      final habit = _makeHabit();
      await repo.addHabit(habit);

      final habits = await repo.getAllHabits();
      expect(habits, hasLength(1));
      expect(habits.first.id, equals('h1'));
    });

    test('deleteHabit supprime l\'habitude existante', () async {
      await repo.addHabit(_makeHabit(id: 'h1'));
      await repo.addHabit(_makeHabit(id: 'h2', name: 'Autre'));

      await repo.deleteHabit('h1');

      final habits = await repo.getAllHabits();
      expect(habits, hasLength(1));
      expect(habits.first.id, equals('h2'));
    });

    test('deleteHabit sur ID inexistant ne lève pas d\'exception', () async {
      await expectLater(
        () => repo.deleteHabit('id-inexistant'),
        returnsNormally,
      );
    });

    test('clearAllHabits vide le repository', () async {
      await repo.addHabit(_makeHabit(id: 'h1'));
      await repo.addHabit(_makeHabit(id: 'h2', name: 'Autre'));

      await repo.clearAllHabits();

      final habits = await repo.getAllHabits();
      expect(habits, isEmpty);
    });
  });
}
