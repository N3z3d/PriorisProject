// ignore_for_file: avoid_print

@Tags(['integration'])
library;

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotrue/gotrue.dart';
import 'package:prioris/data/repositories/supabase/supabase_habit_repository.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/infrastructure/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Lit les credentials Supabase directement depuis .env (bypass flutter_test_config.dart
/// qui injecte une URL de mock 'tests-prioris.supabase.co' pour les tests unitaires).
Map<String, String> _readDotEnv() {
  final file = File('.env');
  if (!file.existsSync()) throw StateError('.env introuvable — lancer depuis la racine du projet');
  final result = <String, String>{};
  for (final line in file.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final idx = trimmed.indexOf('=');
    if (idx < 0) continue;
    result[trimmed.substring(0, idx).trim()] = trimmed.substring(idx + 1).trim();
  }
  return result;
}

/// Storage PKCE en memoire pour les tests VM (pas de shared_preferences requis).
class _InMemoryGotrueAsyncStorage implements GotrueAsyncStorage {
  final Map<String, String> _store = {};

  @override
  Future<String?> getItem({required String key}) async => _store[key];

  @override
  Future<void> setItem({required String key, required String value}) async {
    _store[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async => _store.remove(key);
}

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
      WidgetsFlutterBinding.ensureInitialized();
      final env = _readDotEnv();
      final supabaseUrl = env['SUPABASE_URL']!;
      final supabaseAnonKey = env['SUPABASE_ANON_KEY']!;
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        authOptions: FlutterAuthClientOptions(
          detectSessionInUri: false,
          localStorage: const EmptyLocalStorage(),
          pkceAsyncStorage: _InMemoryGotrueAsyncStorage(),
        ),
      );
      await AuthService.instance.signIn(
        email: 'test_1776892399910_958@example.com',
        password: 'TestPassword123!',
      );
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
      await AuthService.instance.signOut();
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

      // READ
      final allHabits = await repository.getAllHabits();
      expect(
        allHabits.any((h) => h.id == testHabitId),
        isTrue,
        reason: 'getAllHabits must return the created habit',
      );

      // UPDATE
      final updated = habit.copyWith(name: 'Test 7.1 Schema Updated');
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
