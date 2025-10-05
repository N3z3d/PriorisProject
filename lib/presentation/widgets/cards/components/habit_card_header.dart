import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/theme/premium_exports.dart';

/// Header widget pour PremiumHabitCard
///
/// Responsabilité: Afficher l'icône, le titre, le type et le badge de streak
class HabitCardHeader extends StatelessWidget {
  final Habit habit;
  final int currentStreak;
  final bool isCompleted;
  final bool enableEffects;

  const HabitCardHeader({
    super.key,
    required this.habit,
    required this.currentStreak,
    required this.isCompleted,
    required this.enableEffects,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildHabitIcon(),
        const SizedBox(width: 12),
        _buildHabitTitleAndType(context),
        if (currentStreak > 0) _buildStreakBadge(context),
      ],
    );
  }

  Widget _buildHabitIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: habit.habitColor.withValues(alpha: 0.1),
        borderRadius: BorderRadiusTokens.radiusSm,
      ),
      child: Icon(
        habit.habitIcon,
        color: habit.habitColor,
        size: 24,
      ),
    );
  }

  Widget _buildHabitTitleAndType(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            habit.name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: habit.habitColor.withValues(alpha: 0.1),
              borderRadius: BorderRadiusTokens.badge,
            ),
            child: Text(
              habit.type.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: habit.habitColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBadge(BuildContext context) {
    final isMilestone = currentStreak % 7 == 0 && currentStreak > 0;

    Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isMilestone
          ? AppTheme.warningColor.withValues(alpha: 0.1)
          : habit.habitColor.withValues(alpha: 0.1),
        borderRadius: BorderRadiusTokens.badge,
        border: isMilestone
          ? Border.all(color: AppTheme.warningColor, width: 1)
          : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            color: isMilestone ? Colors.white : habit.habitColor,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            currentStreak.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isMilestone ? Colors.white : habit.habitColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    if (isMilestone && enableEffects) {
      badge = MicroInteractions.pulseAnimation(
        duration: const Duration(seconds: 2),
        child: badge,
      );
    }

    return badge;
  }
}
