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
    
    // Ajouter des habitudes d'exemple
    final now = DateTime.now();
    
    final meditationHabit = Habit(
      name: 'Méditation matinale',
      type: HabitType.quantitative,
      category: 'Santé',
      recurrenceType: RecurrenceType.dailyInterval,
      targetValue: 10.0,
      unit: 'minutes',
    );
    
    final readingHabit = Habit(
      name: 'Lecture quotidienne',
      type: HabitType.binary,
      category: 'Développement personnel',
      recurrenceType: RecurrenceType.dailyInterval,
    );
    
    final exerciseHabit = Habit(
      name: 'Exercice physique',
      type: HabitType.binary,
      category: 'Sport',
      recurrenceType: RecurrenceType.weekdays,
    );
    
    final waterHabit = Habit(
      name: 'Boire de l\'eau',
      type: HabitType.quantitative,
      category: 'Santé',
      recurrenceType: RecurrenceType.dailyInterval,
      targetValue: 8.0,
      unit: 'verres',
    );
    
    // Simuler quelques jours d'accomplissement
    for (int i = 0; i < 5; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // Méditation : 10-15 minutes
      meditationHabit.completions[dateKey] = 10.0 + (i * 1.0);
      
      // Lecture : fait 4 jours sur 5
      if (i < 4) readingHabit.completions[dateKey] = true;
      
      // Exercice : fait 3 jours sur 5
      if (i < 3) exerciseHabit.completions[dateKey] = true;
      
      // Eau : 6-9 verres
      waterHabit.completions[dateKey] = 6.0 + (i * 0.5);
    }
    
    _habits.addAll([
      meditationHabit,
      readingHabit,
      exerciseHabit,
      waterHabit,
    ]);
    
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
