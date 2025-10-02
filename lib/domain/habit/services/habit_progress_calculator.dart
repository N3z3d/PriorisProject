import '../aggregates/habit_aggregate.dart';
import '../../core/value_objects/progress.dart';

/// Service métier responsable du calcul de la progression des habitudes
///
/// Applique le principe SRP en isolant les calculs de statistiques et progression
class HabitProgressCalculator {
  const HabitProgressCalculator();

  /// Calcule le taux de réussite sur une période
  double calculateSuccessRate({
    required DateTime fromDate,
    required HabitType type,
    required Map<String, dynamic> completions,
    required double? targetValue,
    required int days,
  }) {
    var successfulDays = 0;

    for (int i = 0; i < days; i++) {
      final date = fromDate.subtract(Duration(days: i));
      final dateKey = _getDateKey(date);
      final value = completions[dateKey];

      final isSuccess = _isSuccessfulCompletion(
        value: value,
        type: type,
        targetValue: targetValue,
      );

      if (isSuccess) {
        successfulDays++;
      }
    }

    return days > 0 ? successfulDays / days : 0.0;
  }

  /// Calcule les statistiques de progression
  Progress calculateProgress({
    required DateTime fromDate,
    required HabitType type,
    required Map<String, dynamic> completions,
    required double? targetValue,
    required int days,
  }) {
    int successful = 0;

    for (int i = 0; i < days; i++) {
      final date = fromDate.subtract(Duration(days: i));
      final dateKey = _getDateKey(date);
      final value = completions[dateKey];

      final isSuccess = _isSuccessfulCompletion(
        value: value,
        type: type,
        targetValue: targetValue,
      );

      if (isSuccess) {
        successful++;
      }
    }

    return Progress.fromCounts(
      completed: successful,
      total: days,
      lastUpdated: DateTime.now(),
    );
  }

  /// Compte le nombre de jours réussis dans une période
  int countSuccessfulDays({
    required DateTime fromDate,
    required HabitType type,
    required Map<String, dynamic> completions,
    required double? targetValue,
    required int days,
  }) {
    var successfulDays = 0;

    for (int i = 0; i < days; i++) {
      final date = fromDate.subtract(Duration(days: i));
      final dateKey = _getDateKey(date);
      final value = completions[dateKey];

      final isSuccess = _isSuccessfulCompletion(
        value: value,
        type: type,
        targetValue: targetValue,
      );

      if (isSuccess) {
        successfulDays++;
      }
    }

    return successfulDays;
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
