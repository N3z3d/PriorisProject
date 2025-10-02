import '../aggregates/habit_aggregate.dart';
import '../events/habit_events.dart';
import '../../core/exceptions/domain_exceptions.dart';

/// Service métier responsable de la logique de completion des habitudes
///
/// Applique le principe SRP en extrayant la logique de completion
/// de l'agrégat principal vers un service dédié.
class HabitCompletionService {
  const HabitCompletionService();

  /// Enregistre une completion pour une habitude binaire
  ///
  /// Retourne les événements à publier par l'agrégat
  List<HabitCompletedEvent> markCompleted({
    required String habitId,
    required String habitName,
    required HabitType type,
    required bool completed,
    required DateTime date,
    required Map<String, dynamic> completions,
    required int currentStreak,
    required Function(int streak, DateTime date) onCheckMilestone,
    required Function(DateTime beforeDate) onFindLastCompleted,
  }) {
    if (type != HabitType.binary) {
      throw InvalidHabitRecordException(
        'Utilisez recordValue() pour les habitudes quantitatives'
      );
    }

    final dateKey = _getDateKey(date);
    final previousValue = completions[dateKey];

    final events = <HabitCompletedEvent>[];

    // Vérifier les milestones de streak
    if (completed && currentStreak > 0) {
      onCheckMilestone(currentStreak, date);
    }

    // Vérifier si le streak a été brisé
    if (!completed && previousValue == true) {
      onFindLastCompleted(date);
    }

    events.add(HabitCompletedEvent(
      habitId: habitId,
      name: habitName,
      completedDate: date,
      value: completed,
      type: type.name,
      currentStreak: currentStreak,
      targetReached: completed,
    ));

    return events;
  }

  /// Enregistre une valeur pour une habitude quantitative
  ///
  /// Retourne les événements à publier par l'agrégat
  List<HabitCompletedEvent> recordValue({
    required String habitId,
    required String habitName,
    required HabitType type,
    required double value,
    required DateTime date,
    required double? targetValue,
    required int currentStreak,
  }) {
    if (type != HabitType.quantitative) {
      throw InvalidHabitRecordException(
        'Utilisez markCompleted() pour les habitudes binaires'
      );
    }

    if (value < 0) {
      throw InvalidHabitRecordException('La valeur ne peut pas être négative');
    }

    final targetReached = targetValue != null && value >= targetValue;

    // L'événement HabitTargetReachedEvent est publié séparément par l'agrégat
    return [
      HabitCompletedEvent(
        habitId: habitId,
        name: habitName,
        completedDate: date,
        value: value,
        type: type.name,
        currentStreak: currentStreak,
        targetReached: targetReached,
      )
    ];
  }

  /// Vérifie si l'habitude est complétée pour une date donnée
  bool isCompletedOnDate({
    required DateTime date,
    required HabitType type,
    required Map<String, dynamic> completions,
    required double? targetValue,
  }) {
    final dateKey = _getDateKey(date);
    final value = completions[dateKey];

    if (type == HabitType.binary) {
      return value == true;
    } else {
      return value != null &&
             targetValue != null &&
             (value as double) >= targetValue;
    }
  }

  /// Obtient la valeur pour une date donnée
  dynamic getValueForDate({
    required DateTime date,
    required Map<String, dynamic> completions,
  }) {
    final dateKey = _getDateKey(date);
    return completions[dateKey];
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
