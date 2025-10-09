import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'habit_calculation_service.dart';
import 'task_calculation_service.dart';

/// Point de donn��es g��n��r�� par le service de progression.
///
/// Cette structure est agnostique de toute biblioth��que de graphique et
/// contient les informations n��cessaires pour construire un graphique:
/// - [index] permet de positionner le point dans l'ordre chronologique
/// - [value] repr��sente la progression (0-100)
/// - [date] conserve la r��f��rence temporelle exacte
/// - [label] est un libell�� pr��format�� pour l'UI (jour, num��ro, etc.)
class ProgressChartPoint {
  final int index;
  final double value;
  final DateTime date;
  final String label;

  const ProgressChartPoint({
    required this.index,
    required this.value,
    required this.date,
    required this.label,
  });
}

/// Service sp��cialis�� dans les calculs de progression et g��n��ration de
/// donn��es pour les widgets de statistiques.
///
/// Il centralise la logique de calcul afin de conserver les widgets l��gers
/// et facilement testables.
class ProgressCalculationService {
  /// D��termine la couleur de progression bas��e sur une valeur.
  ///
  /// [value] : Valeur entre 0 et 100.
  static Color getProgressColor(double value) {
    if (value >= 80) return AppTheme.successColor;
    if (value >= 60) return AppTheme.primaryColor;
    if (value >= 40) return AppTheme.accentColor;
    return AppTheme.errorColor;
  }

  /// G��n��re les donn��es de progression pour un graphique.
  ///
  /// [period] : '7_days', '30_days', '90_days' ou '365_days'
  /// [habits] : Liste des habitudes
  /// [tasks] : Liste des t��ches
  static List<ProgressChartPoint> generateProgressData(
    String period,
    List<Habit> habits,
    List<Task> tasks,
  ) {
    switch (period) {
      case '7_days':
        return _generateWeeklyProgressData(habits, tasks);
      case '30_days':
        return _generateMonthlyProgressData(habits, tasks);
      case '90_days':
        return _generateQuarterlyProgressData(habits, tasks);
      case '365_days':
        return _generateYearlyProgressData(habits, tasks);
      default:
        return _generateWeeklyProgressData(habits, tasks);
    }
  }

  /// G��n��re les labels de p��riode pour l'axe X.
  static List<String> generatePeriodLabels(String period) {
    switch (period) {
      case '7_days':
        return ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      case '30_days':
        return List.generate(30, (index) => '${index + 1}');
      case '90_days':
        return List.generate(90, (index) => '${index + 1}');
      case '365_days':
        return List.generate(365, (index) => '${index + 1}');
      default:
        return ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    }
  }

  /// Calcule la progression globale bas��e sur les habitudes et t��ches.
  static double calculateOverallProgress(List<Habit> habits, List<Task> tasks) {
    if (habits.isEmpty && tasks.isEmpty) return 0.0;

    var habitProgress = 0.0;
    var taskProgress = 0.0;

    if (habits.isNotEmpty) {
      habitProgress = HabitCalculationService.calculateSuccessRate(habits).toDouble();
    }
    if (tasks.isNotEmpty) {
      taskProgress = TaskCalculationService.calculateCompletionRate(tasks).toDouble();
    }

    if (habits.isNotEmpty && tasks.isNotEmpty) {
      return (habitProgress * 0.7) + (taskProgress * 0.3);
    }
    if (habits.isNotEmpty) {
      return habitProgress;
    }
    return taskProgress;
  }

  /// Calcule des points de progression pour les 7 derniers jours.
  static List<ProgressChartPoint> _generateWeeklyProgressData(
    List<Habit> habits,
    List<Task> tasks,
  ) {
    final List<ProgressChartPoint> data = [];
    final now = _truncateToDay(DateTime.now());

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final progressValue = _calculateDailyProgressValue(habits, tasks, date);
      final index = 6 - i;
      data.add(
        ProgressChartPoint(
          index: index,
          value: progressValue,
          date: date,
          label: _formatWeekdayLabel(date),
        ),
      );
    }

    return data;
  }

  /// Calcule des points de progression pour les 30 derniers jours.
  static List<ProgressChartPoint> _generateMonthlyProgressData(
    List<Habit> habits,
    List<Task> tasks,
  ) {
    final List<ProgressChartPoint> data = [];
    final now = _truncateToDay(DateTime.now());

    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final progressValue = _calculateDailyProgressValue(habits, tasks, date);
      final index = 29 - i;
      data.add(
        ProgressChartPoint(
          index: index,
          value: progressValue,
          date: date,
          label: '${index + 1}',
        ),
      );
    }

    return data;
  }

  /// Calcule des points de progression pour les 90 derniers jours.
  static List<ProgressChartPoint> _generateQuarterlyProgressData(
    List<Habit> habits,
    List<Task> tasks,
  ) {
    final List<ProgressChartPoint> data = [];
    final now = _truncateToDay(DateTime.now());

    for (int i = 89; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final progressValue = _calculateDailyProgressValue(habits, tasks, date);
      final index = 89 - i;
      data.add(
        ProgressChartPoint(
          index: index,
          value: progressValue,
          date: date,
          label: '${index + 1}',
        ),
      );
    }

    return data;
  }

  /// Calcule des points de progression pour les 365 derniers jours.
  static List<ProgressChartPoint> _generateYearlyProgressData(
    List<Habit> habits,
    List<Task> tasks,
  ) {
    final List<ProgressChartPoint> data = [];
    final now = _truncateToDay(DateTime.now());

    for (int i = 364; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final progressValue = _calculateDailyProgressValue(habits, tasks, date);
      final index = 364 - i;
      data.add(
        ProgressChartPoint(
          index: index,
          value: progressValue,
          date: date,
          label: '${index + 1}',
        ),
      );
    }

    return data;
  }

  /// Calcule la progression moyenne sur une p��riode donn��e.
  static double calculateAverageProgress(String period, List<Habit> habits, List<Task> tasks) {
    final progressData = generateProgressData(period, habits, tasks);
    if (progressData.isEmpty) return 0.0;

    final totalProgress = progressData.map((point) => point.value).reduce((a, b) => a + b);
    return totalProgress / progressData.length;
  }

  /// Calcule la tendance de progression (croissante, d��croissante ou stable).
  static String calculateProgressTrend(String period, List<Habit> habits, List<Task> tasks) {
    final progressData = generateProgressData(period, habits, tasks);
    if (progressData.length < 2) return 'stable';

    final firstPoints = progressData.take(3).map((point) => point.value).toList();
    final lastPoints = progressData.reversed.take(3).map((point) => point.value).toList();

    final firstAverage = firstPoints.reduce((a, b) => a + b) / firstPoints.length;
    final lastAverage = lastPoints.reduce((a, b) => a + b) / lastPoints.length;
    final difference = lastAverage - firstAverage;

    if (difference > 5) return 'increasing';
    if (difference < -5) return 'decreasing';
    return 'stable';
  }

  /// Calcule le meilleur jour de la p��riode.
  static Map<String, dynamic> calculateBestDay(
    String period,
    List<Habit> habits,
    List<Task> tasks,
  ) {
    final progressData = generateProgressData(period, habits, tasks);
    if (progressData.isEmpty) {
      return {'index': 0, 'value': 0.0};
    }

    double maxValue = progressData.first.value;
    var maxIndex = 0;

    for (int i = 1; i < progressData.length; i++) {
      if (progressData[i].value > maxValue) {
        maxValue = progressData[i].value;
        maxIndex = i;
      }
    }

    return {'index': maxIndex, 'value': maxValue};
  }

  /// Calcule le pire jour de la p��riode.
  static Map<String, dynamic> calculateWorstDay(
    String period,
    List<Habit> habits,
    List<Task> tasks,
  ) {
    final progressData = generateProgressData(period, habits, tasks);
    if (progressData.isEmpty) {
      return {'index': 0, 'value': 0.0};
    }

    double minValue = progressData.first.value;
    var minIndex = 0;

    for (int i = 1; i < progressData.length; i++) {
      if (progressData[i].value < minValue) {
        minValue = progressData[i].value;
        minIndex = i;
      }
    }

    return {'index': minIndex, 'value': minValue};
  }

  static double _calculateDailyProgressValue(
    List<Habit> habits,
    List<Task> tasks,
    DateTime date,
  ) {
    final habitProgress = _calculateHabitProgress(date, habits);
    final taskProgress = _calculateTaskProgress(date, tasks);
    return _combineDailyProgress(
      habitProgress,
      taskProgress,
      habits.isNotEmpty,
      tasks.isNotEmpty,
    );
  }

  static double _calculateHabitProgress(DateTime date, List<Habit> habits) {
    if (habits.isEmpty) {
      return 0.0;
    }

    final dateKey = _getDateKey(date);
    var completedHabits = 0;

    for (final habit in habits) {
      final value = habit.completions[dateKey];
      final completed = habit.type == HabitType.binary
          ? value == true
          : (value != null && habit.targetValue != null && (value as double) >= habit.targetValue!);
      if (completed) {
        completedHabits++;
      }
    }

    return (completedHabits / habits.length) * 100;
  }

  static double _calculateTaskProgress(DateTime date, List<Task> tasks) {
    if (tasks.isEmpty) {
      return 0.0;
    }

    final targetDate = DateTime(date.year, date.month, date.day);
    final tasksCompletedToday = tasks.where((task) {
      if (!task.isCompleted || task.completedAt == null) {
        return false;
      }
      final completedDate = DateTime(
        task.completedAt!.year,
        task.completedAt!.month,
        task.completedAt!.day,
      );
      return completedDate.isAtSameMomentAs(targetDate);
    }).length;

    return (tasksCompletedToday / tasks.length) * 100;
  }

  static double _combineDailyProgress(
    double habitProgress,
    double taskProgress,
    bool hasHabits,
    bool hasTasks,
  ) {
    if (hasHabits && hasTasks) {
      return (habitProgress * 0.7) + (taskProgress * 0.3);
    }
    if (hasHabits) {
      return habitProgress;
    }
    return taskProgress;
  }

  static String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static DateTime _truncateToDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static String _formatWeekdayLabel(DateTime date) {
    const weekdays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final index = date.weekday % 7; // DateTime.weekday : 1 (Lundi) -> 7 (Dimanche)
    return weekdays[index - 1 >= 0 ? index - 1 : 6];
  }
}
