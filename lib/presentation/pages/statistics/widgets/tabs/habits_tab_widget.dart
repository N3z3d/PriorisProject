import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/pages/statistics/widgets/analytics/habits_stats_widget.dart';
import 'package:prioris/presentation/pages/statistics/widgets/charts/streaks_chart_widget.dart';
import 'package:prioris/presentation/pages/statistics/widgets/smart/top_habits_widget.dart';

/// Widget affichant l'onglet Habitudes des statistiques
/// 
/// Ce widget regroupe tous les widgets de l'onglet Habitudes :
/// - Statistiques des habitudes (HabitsStatsWidget)
/// - Graphique des séries (StreaksChartWidget)
/// - Top des habitudes (TopHabitsWidget)
class HabitsTabWidget extends StatelessWidget {
  /// Liste des habitudes à analyser
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
          // Statistiques des habitudes
          HabitsStatsWidget(habits: habits),
          const SizedBox(height: 24),
          
          // Graphique des streaks
          StreaksChartWidget(
            habitNames: _getHabitNames(),
            streakData: _getStreakData(),
          ),
          const SizedBox(height: 24),
          
          // Top habitudes
          TopHabitsWidget(
            topHabits: _getTopHabits(),
          ),
        ],
      ),
    );
  }

  /// Génère les noms des habitudes pour le graphique des séries
  List<String> _getHabitNames() {
    if (habits.isEmpty) return [];
    
    // Prendre les 4 premières habitudes ou toutes si moins de 4
    final displayHabits = habits.take(4).toList();
    return displayHabits.map((habit) => habit.name).toList();
  }

  /// Génère les données de séries pour le graphique
  List<double> _getStreakData() {
    if (habits.isEmpty) return [];
    
    // Prendre les 4 premières habitudes ou toutes si moins de 4
    final displayHabits = habits.take(4).toList();
    return displayHabits.map((habit) => habit.getCurrentStreak().toDouble()).toList();
  }

  /// Génère le top des habitudes basé sur leur taux de réussite
  List<TopHabit> _getTopHabits() {
    if (habits.isEmpty) return [];
    
    // Calculer le taux de réussite pour chaque habitude
    final List<Map<String, dynamic>> habitsWithRate = habits.map((habit) {
      final rate = habit.getSuccessRate() * 100;
      return {
        'habit': habit,
        'rate': rate,
      };
    }).toList();
    
    // Trier par taux de réussite décroissant
    habitsWithRate.sort((a, b) => (b['rate'] as double).compareTo(a['rate'] as double));
    
    // Prendre le top 5
    final top5 = habitsWithRate.take(5).toList();
    
    // Convertir en TopHabit
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
