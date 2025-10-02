import 'dart:math' as math;
import '../../../core/services/domain_service.dart';
import '../../aggregates/habit_aggregate.dart';

/// Service spécialisé pour le calcul de la consistance des habitudes
/// Applique SRP - Une seule responsabilité: calculer la consistance
class HabitConsistencyCalculator extends LoggableDomainService {

  @override
  String get serviceName => 'HabitConsistencyCalculator';

  /// Analyse la consistance d'une habitude sur une période
  ConsistencyAnalysis calculate(
    HabitAggregate habit, {
    int days = 30,
  }) {
    return executeOperation(() {
      log('Calcul de consistance pour ${habit.name} sur $days jours');

      final now = DateTime.now();
      final completions = <DateTime>[];
      final gaps = <Duration>[];

      DateTime? lastCompletion;

      for (int i = 0; i < days; i++) {
        final date = now.subtract(Duration(days: i));
        final dateKey = _getDateKey(date);
        final value = habit.completions[dateKey];

        final wasCompleted = _isCompletedForDate(habit, value);

        if (wasCompleted) {
          completions.add(date);
          if (lastCompletion != null) {
            gaps.add(lastCompletion.difference(date));
          }
          lastCompletion = date;
        }
      }

      // Calculer les métriques de consistance
      final completionRate = completions.length / days;
      final averageGap = _calculateAverageGap(gaps);
      final maxGap = _calculateMaxGap(gaps);
      final variability = _calculateVariability(gaps, averageGap);

      final analysis = ConsistencyAnalysis(
        completionRate: completionRate,
        totalCompletions: completions.length,
        totalDays: days,
        averageGapDays: averageGap.inDays.toDouble(),
        maxGapDays: maxGap.inDays.toDouble(),
        variabilityScore: variability / Duration.millisecondsPerDay,
        currentStreak: habit.getCurrentStreak(),
        consistency: _calculateConsistencyLevel(completionRate, variability),
      );

      log('Analyse terminée - Taux: ${(completionRate * 100).toStringAsFixed(1)}%, Consistance: ${analysis.consistency.label}');

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

  Duration _calculateAverageGap(List<Duration> gaps) {
    if (gaps.isEmpty) return Duration.zero;

    return Duration(
      milliseconds: gaps
        .map((gap) => gap.inMilliseconds)
        .reduce((a, b) => a + b) ~/ gaps.length
    );
  }

  Duration _calculateMaxGap(List<Duration> gaps) {
    if (gaps.isEmpty) return Duration.zero;
    return gaps.reduce((a, b) => a.inMilliseconds > b.inMilliseconds ? a : b);
  }

  double _calculateVariability(List<Duration> gaps, Duration averageGap) {
    if (gaps.length <= 1) return 0.0;

    final avgGapMillis = averageGap.inMilliseconds;
    final variance = gaps
      .map((gap) => math.pow(gap.inMilliseconds - avgGapMillis, 2))
      .reduce((a, b) => a + b) / gaps.length;

    return math.sqrt(variance);
  }

  ConsistencyLevel _calculateConsistencyLevel(double completionRate, double variability) {
    if (completionRate >= 0.9 && variability < 1.5) return ConsistencyLevel.excellent;
    if (completionRate >= 0.8 && variability < 2.0) return ConsistencyLevel.good;
    if (completionRate >= 0.6) return ConsistencyLevel.fair;
    if (completionRate >= 0.3) return ConsistencyLevel.poor;
    return ConsistencyLevel.veryPoor;
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Analyse de la consistance d'une habitude
class ConsistencyAnalysis {
  final double completionRate;
  final int totalCompletions;
  final int totalDays;
  final double averageGapDays;
  final double maxGapDays;
  final double variabilityScore;
  final int currentStreak;
  final ConsistencyLevel consistency;

  const ConsistencyAnalysis({
    required this.completionRate,
    required this.totalCompletions,
    required this.totalDays,
    required this.averageGapDays,
    required this.maxGapDays,
    required this.variabilityScore,
    required this.currentStreak,
    required this.consistency,
  });
}

enum ConsistencyLevel {
  excellent('Excellent'),
  good('Bon'),
  fair('Moyen'),
  poor('Faible'),
  veryPoor('Très faible');

  const ConsistencyLevel(this.label);
  final String label;
}
