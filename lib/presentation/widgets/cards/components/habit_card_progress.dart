import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/theme/premium_exports.dart';

/// Widget de progression pour PremiumHabitCard
///
/// Responsabilité: Afficher la progression du jour avec barre animée
class HabitCardProgress extends StatelessWidget {
  final Habit habit;
  final double progress;
  final bool enableEffects;

  const HabitCardProgress({
    super.key,
    required this.habit,
    required this.progress,
    required this.enableEffects,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progression du jour',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: habit.habitColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildProgressBar(),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: habit.habitColor.withValues(alpha: 0.1),
        borderRadius: BorderRadiusTokens.progressBar,
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: habit.habitColor,
            borderRadius: BorderRadiusTokens.progressBar,
            boxShadow: progress > 0.5 ? [
              BoxShadow(
                color: habit.habitColor.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
        ),
      ),
    );
  }
}
