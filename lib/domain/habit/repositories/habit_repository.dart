import 'package:prioris/domain/models/core/entities/habit.dart';

/// Port de persistance pour les habitudes.
///
/// Déclaré dans le domaine — implémenté dans lib/data/ (Supabase, InMemory).
/// Règle : aucun import hive / supabase_flutter / flutter dans ce fichier.
abstract class HabitRepository {
  Future<List<Habit>> getAllHabits();
  Future<void> saveHabit(Habit habit);
  Future<void> addHabit(Habit habit);
  Future<void> updateHabit(Habit habit);
  Future<void> deleteHabit(String habitId);
  Future<List<Habit>> getHabitsByCategory(String category);
  Future<void> clearAllHabits();
}
