import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/pages/statistics/widgets/analytics/habits_stats_widget.dart';
import 'package:prioris/presentation/pages/statistics/widgets/charts/streaks_chart_widget.dart';
import 'package:prioris/presentation/pages/statistics/widgets/smart/top_habits_widget.dart';

/// Widget affichant l'onglet Habitudes des statistiques.
///
/// Il regroupe :
/// - les statistiques des habitudes
/// - le graphique des séries (streaks)
/// - le top des habitudes
class HabitsTabWidget extends StatelessWidget {
  final List<Habit> habits;

  const HabitsTabWidget({
    super.key,
    required this.habits,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HabitsStatsWidget(habits: habits),
          const SizedBox(height: 24),
          StreaksChartWidget(
            entries: _buildStreakEntries(),
            period: const Duration(days: 30),
          ),
          const SizedBox(height: 24),
          TopHabitsWidget(
            topHabits: _getTopHabits(),
          ),
        ],
      ),
    );
  }

  List<StreakChartEntry> _buildStreakEntries() {
    if (habits.isEmpty) {
      return const [];
    }

    final displayHabits = habits.take(4).toList();
    return displayHabits
        .map(
          (habit) => StreakChartEntry(
            name: habit.name,
            streakLength: habit.getCurrentStreak().toDouble(),
            category: habit.category ?? 'Général',
          ),
        )
        .toList();
  }

  List<TopHabit> _getTopHabits() {
    if (habits.isEmpty) return const [];

    final List<Map<String, dynamic>> habitsWithRate = habits.map((habit) {
      final rate = habit.getSuccessRate() * 100;
      return {
        'habit': habit,
        'rate': rate,
      };
    }).toList();

    habitsWithRate.sort((a, b) => (b['rate'] as double).compareTo(a['rate'] as double));

    final top5 = habitsWithRate.take(5).toList();

    return top5.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final habit = data['habit'] as Habit;
      final rate = data['rate'] as double;

      return TopHabit(
        name: habit.name,
        percentage: '${rate.toInt()}%',
        rank: index + 1,
      );
    }).toList();
  }
}
