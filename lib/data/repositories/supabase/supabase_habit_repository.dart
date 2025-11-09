import 'package:logger/logger.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/infrastructure/services/auth_service.dart';
import 'package:prioris/infrastructure/services/supabase_service.dart';
import 'package:prioris/infrastructure/services/supabase_table_adapter.dart';

import '../habit_repository.dart';

/// Supabase repository for habits with multi-user support
/// DI-friendly: Dependencies injected via constructor
class SupabaseHabitRepository implements HabitRepository {
  final SupabaseService _supabase;
  final AuthService _auth;
  final SupabaseTableAdapterFactory _tableFactory;
  final Logger _logger;

  static const String _tableName = 'habits';

  /// Constructor with dependency injection
  SupabaseHabitRepository({
    SupabaseService? supabaseService,
    AuthService? authService,
    SupabaseTableAdapterFactory? tableFactory,
    Logger? logger,
  })  : _supabase = supabaseService ?? SupabaseService.instance,
        _auth = authService ?? AuthService.instance,
        _tableFactory = tableFactory ?? defaultSupabaseTableFactory,
        _logger = logger ?? Logger();

  @override
  Future<List<Habit>> getAllHabits() async {
    try {
      if (!_auth.isSignedIn) {
        _logger.w('Attempted to fetch habits without authentication');
        throw Exception('User not authenticated');
      }

      _logger.d('Fetching all habits for user: ${_auth.currentUser!.id}');

      final response = await _table().select(
        builder: (query) => query
            .eq('user_id', _auth.currentUser!.id)
            .order('created_at', ascending: false),
      );

      final habits = response.map<Habit>((json) => Habit.fromJson(json)).toList();

      _logger.i('Successfully fetched ${habits.length} habits');
      return habits;
    } catch (e) {
      _logger.e('Failed to fetch habits', error: e);
      throw Exception('Failed to fetch habits: $e');
    }
  }

  @override
  Future<void> saveHabit(Habit habit) async {
    try {
      if (!_auth.isSignedIn) {
        _logger.w('Attempted to save habit without authentication');
        throw Exception('User not authenticated');
      }

      _logger.d('Saving habit: ${habit.name} (${habit.id})');

      final habitData = habit.toJson();
      // Ensure user_id and user_email are set (CRITICAL for multi-user)
      habitData['user_id'] = _auth.currentUser!.id;
      habitData['user_email'] = _auth.currentUser!.email;

      await _table().insert(habitData);

      _logger.i('Successfully saved habit: ${habit.name}');
    } catch (e) {
      _logger.e('Failed to save habit: ${habit.name}', error: e);
      throw Exception('Failed to create habit: $e');
    }
  }

  @override
  Future<void> addHabit(Habit habit) async {
    // Alias for saveHabit for backward compatibility
    return saveHabit(habit);
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    try {
      if (!_auth.isSignedIn) {
        _logger.w('Attempted to update habit without authentication');
        throw Exception('User not authenticated');
      }

      _logger.d('Updating habit: ${habit.name} (${habit.id})');

      final habitData = habit.toJson();

      await _table().update(
        values: habitData,
        builder: (query) => query
            .eq('id', habit.id)
            .eq('user_id', _auth.currentUser!.id), // Ensure user owns this habit
      );

      _logger.i('Successfully updated habit: ${habit.name}');
    } catch (e) {
      _logger.e('Failed to update habit: ${habit.name}', error: e);
      throw Exception('Failed to update habit: $e');
    }
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    try {
      if (!_auth.isSignedIn) {
        _logger.w('Attempted to delete habit without authentication');
        throw Exception('User not authenticated');
      }

      _logger.d('Deleting habit: $habitId');

      // Hard delete (no soft delete for habits currently)
      await _table().delete(
        builder: (query) => query
            .eq('id', habitId)
            .eq('user_id', _auth.currentUser!.id), // Ensure user owns this habit
      );

      _logger.i('Successfully deleted habit: $habitId');
    } catch (e) {
      _logger.e('Failed to delete habit: $habitId', error: e);
      throw Exception('Failed to delete habit: $e');
    }
  }

  @override
  Future<List<Habit>> getHabitsByCategory(String category) async {
    try {
      if (!_auth.isSignedIn) {
        _logger.w('Attempted to fetch habits by category without authentication');
        throw Exception('User not authenticated');
      }

      _logger.d('Fetching habits by category: $category');

      final response = await _table().select(
        builder: (query) => query
            .eq('user_id', _auth.currentUser!.id)
            .eq('category', category)
            .order('created_at', ascending: false),
      );

      final habits = response.map<Habit>((json) => Habit.fromJson(json)).toList();

      _logger.i('Found ${habits.length} habits in category: $category');
      return habits;
    } catch (e) {
      _logger.e('Failed to fetch habits by category: $category', error: e);
      throw Exception('Failed to fetch habits by category: $e');
    }
  }

  @override
  Future<void> clearAllHabits() async {
    try {
      if (!_auth.isSignedIn) {
        _logger.w('Attempted to clear all habits without authentication');
        throw Exception('User not authenticated');
      }

      _logger.d('Clearing all habits for user: ${_auth.currentUser!.id}');

      // Delete all habits for current user
      await _table().delete(
        builder: (query) => query.eq('user_id', _auth.currentUser!.id),
      );

      _logger.i('Successfully cleared all habits');
    } catch (e) {
      _logger.e('Failed to clear all habits', error: e);
      throw Exception('Failed to clear all habits: $e');
    }
  }

  /// Real-time stream of all habits for current user
  Stream<List<Habit>> watchAllHabits() {
    if (!_auth.isSignedIn) {
      _logger.w('Attempted to watch habits without authentication');
      return Stream.error('User not authenticated');
    }

    _logger.d('Starting real-time watch for user habits');

    return _table()
        .stream(
          primaryKey: const ['id'],
          builder: (query) => query.eq('user_id', _auth.currentUser!.id),
        )
        .map(
          (data) => data.map<Habit>((json) => Habit.fromJson(json)).toList(),
        );
  }

  /// Get habit statistics by category
  Future<Map<String, int>> getStatsByCategory() async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      final response = await _table().select(
        columns: 'category',
        builder: (query) => query.eq('user_id', _auth.currentUser!.id),
      );

      final stats = <String, int>{};
      for (final item in response) {
        final category = item['category'] as String? ?? 'Uncategorized';
        stats[category] = (stats[category] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      _logger.e('Failed to get category stats', error: e);
      throw Exception('Failed to get stats: $e');
    }
  }

  SupabaseTableAdapter _table() => _tableFactory(_supabase, _tableName);
}
