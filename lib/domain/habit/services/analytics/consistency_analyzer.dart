import 'dart:math' as math;
import '../../../core/services/domain_service.dart';
import '../../aggregates/habit_aggregate.dart';

/// Consistency Analysis Result
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

/// Consistency Level Classifications
enum ConsistencyLevel {
  excellent('Excellente'),
  good('Bonne'),
  fair('Correcte'),
  poor('Faible'),
  veryPoor('Très faible');

  const ConsistencyLevel(this.label);
  final String label;
}

/// Consistency Analyzer - Analyzes habit consistency and regularity patterns
///
/// SOLID COMPLIANCE:
/// - SRP: Single responsibility for consistency analysis only
/// - OCP: Extensible through analysis parameters and metrics
/// - LSP: Compatible with habit analysis interfaces
/// - ISP: Focused interface for consistency operations only
/// - DIP: Depends on habit aggregate abstractions
///
/// Features:
/// - Completion rate analysis over custom time windows
/// - Gap analysis between completions
/// - Variability scoring using statistical measures
/// - Streak tracking and momentum analysis
/// - Consistency level classification
///
/// CONSTRAINTS: <200 lines (currently ~180 lines)
class ConsistencyAnalyzer extends LoggableDomainService {

  @override
  String get serviceName => 'ConsistencyAnalyzer';

  /// Analyzes consistency of a habit over a specified period
  ConsistencyAnalysis analyzeConsistency(
    HabitAggregate habit, {
    int days = 30,
  }) {
    return executeOperation(() {
      log('Analyzing consistency for ${habit.name} over $days days');

      final now = DateTime.now();
      final completions = <DateTime>[];
      final gaps = <Duration>[];

      DateTime? lastCompletion;

      // Collect completion data
      for (int i = 0; i < days; i++) {
        final date = now.subtract(Duration(days: i));
        final dateKey = _getDateKey(date);
        final value = habit.completions[dateKey];

        bool wasCompleted = false;
        if (habit.type == HabitType.binary && value == true) {
          wasCompleted = true;
        } else if (habit.type == HabitType.quantitative &&
                   value != null &&
                   habit.targetValue != null &&
                   (value as double) >= habit.targetValue!) {
          wasCompleted = true;
        }

        if (wasCompleted) {
          completions.add(date);
          if (lastCompletion != null) {
            gaps.add(lastCompletion.difference(date));
          }
          lastCompletion = date;
        }
      }

      // Calculate consistency metrics
      final completionRate = completions.length / days;
      final averageGap = gaps.isEmpty
        ? Duration.zero
        : Duration(
            milliseconds: gaps
              .map((gap) => gap.inMilliseconds)
              .reduce((a, b) => a + b) ~/ gaps.length
          );

      final maxGap = gaps.isEmpty
        ? Duration.zero
        : gaps.reduce((a, b) => a.inMilliseconds > b.inMilliseconds ? a : b);

      // Calculate variability (standard deviation of intervals)
      double variability = 0;
      if (gaps.length > 1) {
        final avgGapMillis = averageGap.inMilliseconds;
        final variance = gaps
          .map((gap) => math.pow(gap.inMilliseconds - avgGapMillis, 2))
          .reduce((a, b) => a + b) / gaps.length;
        variability = math.sqrt(variance);
      }

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

      log('Consistency analysis completed - Rate: ${(completionRate * 100).toStringAsFixed(1)}%, Level: ${analysis.consistency.label}');

      return analysis;
    });
  }

  /// Analyzes completion momentum over recent days
  MomentumAnalysis analyzeMomentum(
    HabitAggregate habit, {
    int recentDays = 7,
    int comparisonDays = 14,
  }) {
    return executeOperation(() {
      log('Analyzing momentum for ${habit.name}');

      final now = DateTime.now();
      int recentCompletions = 0;
      int comparisonCompletions = 0;

      // Count recent completions
      for (int i = 0; i < recentDays; i++) {
        final date = now.subtract(Duration(days: i));
        if (_wasCompletedOnDate(habit, date)) {
          recentCompletions++;
        }
      }

      // Count comparison period completions
      for (int i = recentDays; i < recentDays + comparisonDays; i++) {
        final date = now.subtract(Duration(days: i));
        if (_wasCompletedOnDate(habit, date)) {
          comparisonCompletions++;
        }
      }

      final recentRate = recentCompletions / recentDays;
      final comparisonRate = comparisonCompletions / comparisonDays;
      final momentum = _calculateMomentumDirection(recentRate, comparisonRate);

      return MomentumAnalysis(
        recentRate: recentRate,
        comparisonRate: comparisonRate,
        momentum: momentum,
        recentCompletions: recentCompletions,
        streakIntact: habit.getCurrentStreak() > 0,
      );
    });
  }

  // === PRIVATE HELPER METHODS ===

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool _wasCompletedOnDate(HabitAggregate habit, DateTime date) {
    final dateKey = _getDateKey(date);
    final value = habit.completions[dateKey];

    if (habit.type == HabitType.binary && value == true) {
      return true;
    } else if (habit.type == HabitType.quantitative &&
               value != null &&
               habit.targetValue != null &&
               (value as double) >= habit.targetValue!) {
      return true;
    }

    return false;
  }

  ConsistencyLevel _calculateConsistencyLevel(double completionRate, double variability) {
    if (completionRate >= 0.9 && variability < 1.5) return ConsistencyLevel.excellent;
    if (completionRate >= 0.8 && variability < 2.0) return ConsistencyLevel.good;
    if (completionRate >= 0.6) return ConsistencyLevel.fair;
    if (completionRate >= 0.3) return ConsistencyLevel.poor;
    return ConsistencyLevel.veryPoor;
  }

  MomentumDirection _calculateMomentumDirection(double recentRate, double comparisonRate) {
    final difference = recentRate - comparisonRate;

    if (difference > 0.2) return MomentumDirection.accelerating;
    if (difference > 0.05) return MomentumDirection.improving;
    if (difference < -0.2) return MomentumDirection.declining;
    if (difference < -0.05) return MomentumDirection.slowing;
    return MomentumDirection.stable;
  }
}

/// Momentum Analysis Result
class MomentumAnalysis {
  final double recentRate;
  final double comparisonRate;
  final MomentumDirection momentum;
  final int recentCompletions;
  final bool streakIntact;

  const MomentumAnalysis({
    required this.recentRate,
    required this.comparisonRate,
    required this.momentum,
    required this.recentCompletions,
    required this.streakIntact,
  });

  double get momentumScore => recentRate - comparisonRate;
}

/// Momentum Direction Classifications
enum MomentumDirection {
  accelerating('En accélération'),
  improving('En amélioration'),
  stable('Stable'),
  slowing('En ralentissement'),
  declining('En déclin');

  const MomentumDirection(this.label);
  final String label;
}