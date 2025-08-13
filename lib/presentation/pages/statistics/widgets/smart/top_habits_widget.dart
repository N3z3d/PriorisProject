import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Modèle pour une habitude du top
class TopHabit {
  final String name;
  final String percentage;
  final int rank;

  const TopHabit({
    required this.name,
    required this.percentage,
    required this.rank,
  });
}

/// Widget affichant le top des habitudes sous forme de liste stylisée
/// [topHabits] : Liste des habitudes à afficher (TopHabit)
class TopHabitsWidget extends StatelessWidget {
  final List<TopHabit> topHabits;

  const TopHabitsWidget({
    super.key,
    required this.topHabits,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusTokens.card),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🏆 Top 5 Habitudes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...topHabits.map((habit) => _buildHabitRankItem(habit)),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitRankItem(TopHabit habit) {
    final colors = [
      const Color(0xFFFFD700), // Or
      const Color(0xFFC0C0C0), // Argent
      const Color(0xFFCD7F32), // Bronze
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colors[(habit.rank - 1).clamp(0, colors.length - 1)],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${habit.rank}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              habit.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            habit.percentage,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 
