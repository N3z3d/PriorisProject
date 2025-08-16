import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';

/// Repository abstrait pour la gestion des habitudes
abstract class HabitRepository {
  Future<List<Habit>> getAllHabits();
  Future<void> saveHabit(Habit habit);
  Future<void> addHabit(Habit habit); // Ajouter cette méthode
  Future<void> updateHabit(Habit habit);
  Future<void> deleteHabit(String habitId);
  Future<List<Habit>> getHabitsByCategory(String category);
  Future<void> clearAllHabits();
}

/// Implémentation en mémoire du repository des habitudes
class InMemoryHabitRepository implements HabitRepository {
  final List<Habit> _habits = [];
  bool _initialized = false;

  Future<void> _initializeWithSampleData() async {
    if (_initialized) return;
    
    // Pas de données d'exemple - démarrage avec une liste vide
    _initialized = true;
  }

  @override
  Future<List<Habit>> getAllHabits() async {
    await _initializeWithSampleData();
    return List.from(_habits);
  }

  @override
  Future<void> saveHabit(Habit habit) async {
    await _initializeWithSampleData();
    _habits.add(habit);
  }

  @override
  Future<void> addHabit(Habit habit) async {
    await _initializeWithSampleData();
    _habits.add(habit);
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    await _initializeWithSampleData();
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
    }
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    await _initializeWithSampleData();
    _habits.removeWhere((h) => h.id == habitId);
  }

  @override
  Future<List<Habit>> getHabitsByCategory(String category) async {
    await _initializeWithSampleData();
    return _habits.where((h) => h.category == category).toList();
  }

  @override
  Future<void> clearAllHabits() async {
    _habits.clear();
    _initialized = false;
  }
}

/// Provider pour le repository des habitudes
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return InMemoryHabitRepository();
});

/// Provider pour toutes les habitudes
final allHabitsProvider = FutureProvider<List<Habit>>((ref) async {
  final repository = ref.read(habitRepositoryProvider);
  return repository.getAllHabits();
});

/// Provider pour les habitudes avec statistiques
final habitsWithStatsProvider = FutureProvider<List<Habit>>((ref) async {
  final repository = ref.read(habitRepositoryProvider);
  return repository.getAllHabits();
}); 
