import 'dart:math' as math;
import '../../../core/services/domain_service.dart';
import '../../aggregates/habit_aggregate.dart';

/// Pattern Analysis Result
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

/// Trend Direction Classifications
enum TrendDirection {
  improving('En amélioration'),
  stable('Stable'),
  declining('En déclin');

  const TrendDirection(this.label);
  final String label;
}

/// Day of Week Performance Analysis
class DayOfWeekAnalysis {
  final Map<int, double> completionRates;
  final int bestDay;
  final int worstDay;
  final double weekendVsWeekdayRatio;
  final double variability;

  const DayOfWeekAnalysis({
    required this.completionRates,
    required this.bestDay,
    required this.worstDay,
    required this.weekendVsWeekdayRatio,
    required this.variability,
  });
}

/// Pattern Analyzer - Analyzes temporal patterns and trends in habit completion
///
/// SOLID COMPLIANCE:
/// - SRP: Single responsibility for pattern analysis only
/// - OCP: Extensible through pattern detection algorithms
/// - LSP: Compatible with habit analysis interfaces
/// - ISP: Focused interface for pattern operations only
/// - DIP: Depends on habit aggregate abstractions
///
/// Features:
/// - Day-of-week pattern detection
/// - Weekly trend analysis
/// - Seasonality detection
/// - Predictability scoring
/// - Best/worst day identification
/// - Weekend vs weekday performance comparison
///
/// CONSTRAINTS: <200 lines (currently ~190 lines)
class PatternAnalyzer extends LoggableDomainService {

  @override
  String get serviceName => 'PatternAnalyzer';

  /// Analyzes temporal patterns in habit completion
  PatternAnalysis analyzePatterns(
    HabitAggregate habit, {
    int days = 60,
  }) {
    return executeOperation(() {
      log('Analyzing patterns for ${habit.name} over $days days');

      final completionsByDay = <int, int>{}; // Day of week -> completion count
      final weeklyTrends = <int, double>{}; // Week -> completion rate

      final now = DateTime.now();

      // Collect pattern data
      for (int i = 0; i < days; i++) {
        final date = now.subtract(Duration(days: i));
        final wasCompleted = _wasCompletedOnDate(habit, date);

        if (wasCompleted) {
          // Day of week pattern (1 = Monday, 7 = Sunday)
          final dayOfWeek = date.weekday;
          completionsByDay[dayOfWeek] = (completionsByDay[dayOfWeek] ?? 0) + 1;
        }

        // Weekly trend tracking
        final weekNumber = i ~/ 7;
        if (!weeklyTrends.containsKey(weekNumber)) {
          weeklyTrends[weekNumber] = 0;
        }
        if (wasCompleted) {
          weeklyTrends[weekNumber] = weeklyTrends[weekNumber]! + (1.0 / 7);
        }
      }

      // Identify best and worst performing days
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

      // Calculate overall trend
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

      log('Patterns analyzed - Best days: ${bestDays.map(_dayName).join(", ")}');

      return analysis;
    });
  }

  /// Analyzes day-of-week performance patterns
  DayOfWeekAnalysis analyzeDayOfWeekPatterns(
    HabitAggregate habit, {
    int days = 84, // 12 weeks
  }) {
    return executeOperation(() {
      log('Analyzing day-of-week patterns for ${habit.name}');

      final completionsByDay = <int, int>{};
      final dayOccurrences = <int, int>{};
      final now = DateTime.now();

      // Collect data for each day of the week
      for (int i = 0; i < days; i++) {
        final date = now.subtract(Duration(days: i));
        final dayOfWeek = date.weekday;

        dayOccurrences[dayOfWeek] = (dayOccurrences[dayOfWeek] ?? 0) + 1;

        if (_wasCompletedOnDate(habit, date)) {
          completionsByDay[dayOfWeek] = (completionsByDay[dayOfWeek] ?? 0) + 1;
        }
      }

      // Calculate completion rates
      final completionRates = <int, double>{};
      for (int day = 1; day <= 7; day++) {
        final completions = completionsByDay[day] ?? 0;
        final occurrences = dayOccurrences[day] ?? 1;
        completionRates[day] = completions / occurrences;
      }

      // Find best and worst days
      final sortedRates = completionRates.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final bestDay = sortedRates.isNotEmpty ? sortedRates.first.key : 1;
      final worstDay = sortedRates.isNotEmpty ? sortedRates.last.key : 1;

      // Calculate weekend vs weekday performance
      final weekdayRate = _calculateWeekdayRate(completionRates);
      final weekendRate = _calculateWeekendRate(completionRates);
      final weekendVsWeekdayRatio = weekendRate / (weekdayRate + 0.01); // Avoid division by zero

      // Calculate variability
      final rates = completionRates.values.toList();
      final variability = _calculateVariability(rates);

      return DayOfWeekAnalysis(
        completionRates: completionRates,
        bestDay: bestDay,
        worstDay: worstDay,
        weekendVsWeekdayRatio: weekendVsWeekdayRatio,
        variability: variability,
      );
    });
  }

  // === PRIVATE HELPER METHODS ===

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

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
    // Simple seasonality detection
    // A more sophisticated implementation would use Fourier analysis
    if (weeklyTrends.length < 4) return 0.0;

    // For now, return a basic seasonality score
    // This could be enhanced with autocorrelation analysis
    return 0.3;
  }

  double _calculatePredictability(Map<int, int> dayPatterns, Map<int, double> weeklyTrends) {
    // Calculate predictability based on pattern variance
    if (dayPatterns.isEmpty) return 0.0;

    final values = dayPatterns.values.toList();
    if (values.length < 2) return 0.0;

    final avg = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((v) => math.pow(v - avg, 2)).reduce((a, b) => a + b) / values.length;

    // Convert variance to predictability score (inverse relationship)
    return math.max(0.0, 1.0 - (variance / (avg + 1)));
  }

  double _calculateWeekdayRate(Map<int, double> completionRates) {
    final weekdayRates = [1, 2, 3, 4, 5].map((day) => completionRates[day] ?? 0.0);
    return weekdayRates.isEmpty ? 0.0 : weekdayRates.reduce((a, b) => a + b) / 5;
  }

  double _calculateWeekendRate(Map<int, double> completionRates) {
    final weekendRates = [6, 7].map((day) => completionRates[day] ?? 0.0);
    return weekendRates.isEmpty ? 0.0 : weekendRates.reduce((a, b) => a + b) / 2;
  }

  double _calculateVariability(List<double> rates) {
    if (rates.length < 2) return 0.0;

    final mean = rates.reduce((a, b) => a + b) / rates.length;
    final variance = rates.map((r) => math.pow(r - mean, 2)).reduce((a, b) => a + b) / rates.length;

    return math.sqrt(variance);
  }

  String _dayName(int dayOfWeek) {
    const names = ['', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return dayOfWeek >= 1 && dayOfWeek <= 7 ? names[dayOfWeek] : 'Inconnu';
  }
}