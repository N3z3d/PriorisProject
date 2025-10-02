import 'dart:math' as math;
import '../../../core/services/domain_service.dart';
import '../../aggregates/habit_aggregate.dart';

/// Service spécialisé pour l'analyse des patterns temporels des habitudes
/// Applique SRP - Une seule responsabilité: analyser les patterns
class HabitPatternAnalyzer extends LoggableDomainService {

  @override
  String get serviceName => 'HabitPatternAnalyzer';

  /// Analyse les patterns temporels d'une habitude
  PatternAnalysis analyze(
    HabitAggregate habit, {
    int days = 60,
  }) {
    return executeOperation(() {
      log('Analyse des patterns pour ${habit.name} sur $days jours');

      final completionsByDay = <int, int>{}; // Jour de la semaine -> nombre de complétions
      final weeklyTrends = <int, double>{}; // Semaine -> taux de complétion

      final now = DateTime.now();

      for (int i = 0; i < days; i++) {
        final date = now.subtract(Duration(days: i));
        final dateKey = _getDateKey(date);
        final value = habit.completions[dateKey];

        final wasCompleted = _isCompletedForDate(habit, value);

        if (wasCompleted) {
          // Pattern par jour de la semaine (1 = lundi, 7 = dimanche)
          final dayOfWeek = date.weekday;
          completionsByDay[dayOfWeek] = (completionsByDay[dayOfWeek] ?? 0) + 1;
        }

        // Trend hebdomadaire
        final weekNumber = (i ~/ 7);
        if (!weeklyTrends.containsKey(weekNumber)) {
          weeklyTrends[weekNumber] = 0;
        }
        if (wasCompleted) {
          weeklyTrends[weekNumber] = weeklyTrends[weekNumber]! + (1.0 / 7);
        }
      }

      // Identifier les jours favorables et défavorables
      final bestDays = <int>[];
      final worstDays = <int>[];

      final totalCompletions = completionsByDay.values.fold<int>(0, (a, b) => a + b);
      if (totalCompletions > 0) {
        final sortedDays = completionsByDay.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        if (sortedDays.isNotEmpty) {
          bestDays.add(sortedDays.first.key);
          worstDays.add(sortedDays.last.key);
        }
      }

      // Calculer la tendance générale
      final trend = _calculateTrend(weeklyTrends);

      final analysis = PatternAnalysis(
        completionsByDayOfWeek: completionsByDay,
        weeklyTrends: weeklyTrends,
        bestDays: bestDays,
        worstDays: worstDays,
        trend: trend,
        seasonality: _detectSeasonality(weeklyTrends),
        predictability: _calculatePredictability(completionsByDay, weeklyTrends),
      );

      log('Patterns analysés - Meilleurs jours: ${bestDays.map((d) => _dayName(d)).join(", ")}');

      return analysis;
    });
  }

  bool _isCompletedForDate(HabitAggregate habit, dynamic value) {
    if (habit.type == HabitType.binary && value == true) {
      return true;
    }
    if (habit.type == HabitType.quantitative &&
        value != null &&
        habit.targetValue != null &&
        (value as double) >= habit.targetValue!) {
      return true;
    }
    return false;
  }

  TrendDirection _calculateTrend(Map<int, double> weeklyTrends) {
    if (weeklyTrends.length < 2) return TrendDirection.stable;

    final weeks = weeklyTrends.keys.toList()..sort();
    final recent = weeks.take(weeks.length ~/ 2).map((w) => weeklyTrends[w]!).toList();
    final older = weeks.skip(weeks.length ~/ 2).map((w) => weeklyTrends[w]!).toList();

    if (recent.isEmpty || older.isEmpty) return TrendDirection.stable;

    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final olderAvg = older.reduce((a, b) => a + b) / older.length;

    final difference = recentAvg - olderAvg;

    if (difference > 0.1) return TrendDirection.improving;
    if (difference < -0.1) return TrendDirection.declining;
    return TrendDirection.stable;
  }

  double _detectSeasonality(Map<int, double> weeklyTrends) {
    // Implémentation simple pour détecter les patterns saisonniers
    if (weeklyTrends.length < 4) return 0.0;

    // Pour le moment, retourne une valeur basique
    // Une implémentation plus sophistiquée utiliserait l'analyse de Fourier
    return 0.3;
  }

  double _calculatePredictability(Map<int, int> dayPatterns, Map<int, double> weeklyTrends) {
    // Calculer la prévisibilité basée sur la variance des patterns
    if (dayPatterns.isEmpty) return 0.0;

    final values = dayPatterns.values.toList();
    if (values.length < 2) return 0.0;

    final avg = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((v) => math.pow(v - avg, 2)).reduce((a, b) => a + b) / values.length;

    // Convertir la variance en score de prévisibilité (inverse)
    return math.max(0.0, 1.0 - (variance / (avg + 1)));
  }

  String _dayName(int dayOfWeek) {
    const names = ['', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return names[dayOfWeek];
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Analyse des patterns temporels d'une habitude
class PatternAnalysis {
  final Map<int, int> completionsByDayOfWeek;
  final Map<int, double> weeklyTrends;
  final List<int> bestDays;
  final List<int> worstDays;
  final TrendDirection trend;
  final double seasonality;
  final double predictability;

  const PatternAnalysis({
    required this.completionsByDayOfWeek,
    required this.weeklyTrends,
    required this.bestDays,
    required this.worstDays,
    required this.trend,
    required this.seasonality,
    required this.predictability,
  });
}

enum TrendDirection {
  improving('En amélioration'),
  declining('En déclin'),
  stable('Stable');

  const TrendDirection(this.label);
  final String label;
}
