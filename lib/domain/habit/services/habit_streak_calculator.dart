import '../aggregates/habit_aggregate.dart';
import '../events/habit_events.dart';

/// Service métier responsable du calcul des séries (streaks) d'habitudes
///
/// Applique le principe SRP en isolant toute la logique de calcul de streak
class HabitStreakCalculator {
  const HabitStreakCalculator();

  /// Calcule la série actuelle (streak)
  int calculateCurrentStreak({
    required DateTime fromDate,
    required HabitType type,
    required Map<String, dynamic> completions,
    required double? targetValue,
    int maxDays = 365,
  }) {
    var streak = 0;

    for (int i = 0; i < maxDays; i++) {
      final date = fromDate.subtract(Duration(days: i));
      final dateKey = _getDateKey(date);
      final value = completions[dateKey];

      final isSuccess = _isSuccessfulCompletion(
        value: value,
        type: type,
        targetValue: targetValue,
      );

      if (isSuccess) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Vérifie les milestones de streak et retourne l'événement si applicable
  HabitStreakMilestoneEvent? checkStreakMilestone({
    required String habitId,
    required String habitName,
    required int streak,
    required DateTime achievedAt,
  }) {
    final milestones = [3, 7, 30, 100, 365];

    if (milestones.contains(streak)) {
      return HabitStreakMilestoneEvent.create(
        habitId: habitId,
        name: habitName,
        streakLength: streak,
        achievedAt: achievedAt,
      );
    }

    return null;
  }

  /// Trouve la dernière date de completion avant une date donnée
  DateTime? findLastCompletedDate({
    required DateTime before,
    required HabitType type,
    required Map<String, dynamic> completions,
    required double? targetValue,
    int maxDaysToCheck = 365,
  }) {
    for (int i = 1; i <= maxDaysToCheck; i++) {
      final date = before.subtract(Duration(days: i));
      final dateKey = _getDateKey(date);
      final value = completions[dateKey];

      final wasCompleted = _isSuccessfulCompletion(
        value: value,
        type: type,
        targetValue: targetValue,
      );

      if (wasCompleted) {
        return date;
      }
    }

    return null;
  }

  /// Calcule le streak avant une date donnée
  int calculateStreakBefore({
    required DateTime date,
    required HabitType type,
    required Map<String, dynamic> completions,
    required double? targetValue,
    int maxDays = 365,
  }) {
    var streak = 0;

    for (int i = 0; i < maxDays; i++) {
      final checkDate = date.subtract(Duration(days: i));
      final dateKey = _getDateKey(checkDate);
      final value = completions[dateKey];

      final isSuccess = _isSuccessfulCompletion(
        value: value,
        type: type,
        targetValue: targetValue,
      );

      if (isSuccess) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Génère un événement de streak brisé
  HabitStreakBrokenEvent createStreakBrokenEvent({
    required String habitId,
    required String habitName,
    required int previousStreak,
    required DateTime lastCompletedDate,
    required DateTime missedDate,
  }) {
    return HabitStreakBrokenEvent(
      habitId: habitId,
      name: habitName,
      previousStreak: previousStreak,
      lastCompletedDate: lastCompletedDate,
      missedDate: missedDate,
    );
  }

  bool _isSuccessfulCompletion({
    required dynamic value,
    required HabitType type,
    required double? targetValue,
  }) {
    if (type == HabitType.binary) {
      return value == true;
    } else if (type == HabitType.quantitative) {
      return value != null &&
             targetValue != null &&
             (value as double) >= targetValue;
    }
    return false;
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
