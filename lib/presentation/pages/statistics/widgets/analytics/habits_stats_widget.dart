import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/pages/statistics/services/statistics_calculation_service.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/pages/statistics/widgets/summary/stat_item.dart';

/// Widget affichant les statistiques des habitudes (actives, taux, série, moyenne)
/// [habits] : Liste des habitudes à analyser
class HabitsStatsWidget extends StatelessWidget {
  final List<Habit> habits;

  const HabitsStatsWidget({
    super.key,
    required this.habits,
  });

  @override
  Widget build(BuildContext context) {
    final activeHabits = habits.length;
    final averageRate = StatisticsCalculationService.calculateHabitSuccessRate(habits);
    final longestStreak = StatisticsCalculationService.calculateCurrentStreak(habits);
    final averagePerDay = _calculateAveragePerDay(habits);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusTokens.card),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎯 Statistiques des Habitudes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: StatItem(
                    value: '$activeHabits',
                    label: 'Habitudes actives',
                    icon: Icons.check_circle_outline,
                  ),
                ),
                Expanded(
                  child: StatItem(
                    value: '$averageRate%',
                    label: 'Taux moyen',
                    icon: Icons.trending_up,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatItem(
                    value: '$longestStreak j',
                    label: 'Série la plus longue',
                    icon: Icons.local_fire_department,
                  ),
                ),
                Expanded(
                  child: StatItem(
                    value: averagePerDay.toStringAsFixed(1),
                    label: 'Moyenne/jour',
                    icon: Icons.analytics,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Calcule la moyenne d'habitudes complétées par jour
  double _calculateAveragePerDay(List<Habit> habits) {
    if (habits.isEmpty) return 0.0;
    
    final totalCompletions = habits
        .map((habit) => habit.getSuccessRate())
        .reduce((a, b) => a + b);
    
    return (totalCompletions / habits.length) * habits.length;
  }
} 
