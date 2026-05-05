// ignore_for_file: avoid_print

@Tags(['integration'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/repositories/supabase/supabase_habit_repository.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';

import '../helpers/supabase_test_harness.dart';

/// Tests d'integration Supabase reelle -- CRUD habitudes
///
/// Prerequis :
///   1. Migration 003_add_habits_columns.sql appliquee dans Supabase
///   2. Reseau disponible (ces tests appellent l'API Supabase reelle)
///   3. Compte de test valide dans test/manual/test_credentials.txt
///
/// Execution :
///   flutter test test/integration/repositories/supabase_habit_repository_integration_test.dart --tags integration
///
/// NE PAS inclure dans flutter test standard (CI) -- reseau requis.
void main() {
  group('SupabaseHabitRepository -- Integration Supabase reelle', () {
    late SupabaseHabitRepository repository;
    String testHabitId = '';

    setUpAll(() async {
      await SupabaseTestHarness.setUp();
      repository = SupabaseHabitRepository();
    });

    tearDownAll(() async {
      if (testHabitId.isNotEmpty) {
        try {
          await repository.deleteHabit(testHabitId);
          print('Cleanup: habit $testHabitId deleted');
        } catch (e) {
          print('Cleanup warning: could not delete $testHabitId -- $e');
        }
      }
      await SupabaseTestHarness.tearDown();
    });

    test('CRUD complet sans PostgrestException', () async {
      final habit = Habit(
        name: 'Test 7.1 Schema CRUD',
        type: HabitType.binary,
      );
      testHabitId = habit.id;

      // CREATE -- valide que category (et autres colonnes) existent dans le schema
      await expectLater(
        () => repository.saveHabit(habit),
        returnsNormally,
        reason: 'saveHabit must not throw PostgrestException',
      );

      // READ — search by name: DB trigger may overwrite the Dart-generated UUID
      final allHabits = await repository.getAllHabits();
      final savedHabits = allHabits.where((h) => h.name == 'Test 7.1 Schema CRUD').toList();
      expect(
        savedHabits.isNotEmpty,
        isTrue,
        reason: 'getAllHabits must return the created habit',
      );
      testHabitId = savedHabits.first.id; // use actual DB id for cleanup + DELETE

      // UPDATE — use fetched habit (carries real user_id for RLS WITH CHECK)
      final updated = savedHabits.first.copyWith(name: 'Test 7.1 Schema Updated');
      await expectLater(
        () => repository.updateHabit(updated),
        returnsNormally,
        reason: 'updateHabit must not throw PostgrestException',
      );

      // DELETE
      await expectLater(
        () => repository.deleteHabit(testHabitId),
        returnsNormally,
        reason: 'deleteHabit must not throw PostgrestException',
      );
      testHabitId = '';
    });

    test('saveHabit avec category non-nulle ne leve pas PGRST204', () async {
      final habit = Habit(
        name: 'Test 7.1 Category',
        type: HabitType.binary,
        category: 'Sante',
      );
      testHabitId = habit.id;

      await expectLater(
        () => repository.saveHabit(habit),
        returnsNormally,
        reason: 'saveHabit with category must succeed after migration',
      );

      await repository.deleteHabit(testHabitId);
      testHabitId = '';
    });

    test('getAllHabits retourne une liste typee', () async {
      final habits = await repository.getAllHabits();
      expect(habits, isA<List<Habit>>());
    });

    test('getHabitsByCategory ne leve pas d exception', () async {
      await expectLater(
        () => repository.getHabitsByCategory('Sante'),
        returnsNormally,
      );
    });
  });
}
