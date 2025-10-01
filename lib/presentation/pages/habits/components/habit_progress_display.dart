import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Progress display component for habit following SRP
class HabitProgressDisplay extends StatelessWidget {
  final Habit habit;

  const HabitProgressDisplay({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    final progress = habit.getSuccessRate(days: 7);
    final streak = habit.getCurrentStreak();
    final completedToday = habit.isCompletedToday();
    final successfulDays = (progress * 7).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _buildContainerDecoration(),
      child: Column(
        children: [
          _buildStatsHeader(progress, streak),
          const SizedBox(height: 12),
          _buildProgressBar(progress),
          const SizedBox(height: 8),
          _buildProgressDetails(successfulDays, completedToday),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(double progress, int streak) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildProgressPercentage(progress),
        if (streak > 0) _buildStreakBadge(streak),
      ],
    );
  }

  Widget _buildProgressPercentage(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${(progress * 100).round()}%',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: progress > 0.5 ? AppTheme.successColor : AppTheme.textSecondary,
          ),
        ),
        Text(
          'cette semaine',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textTertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakBadge(int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.successColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            '$streak jour${streak > 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.successColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: AppTheme.grey200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.accentColor,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDetails(int successfulDays, bool completedToday) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$successfulDays/7 jours réussis',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textTertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (completedToday) _buildCompletedTodayBadge(),
      ],
    );
  }

  Widget _buildCompletedTodayBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.successColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'Fait aujourd\'hui',
        style: TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  BoxDecoration _buildContainerDecoration() {
    return BoxDecoration(
      color: AppTheme.subtleBackgroundColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppTheme.grey200,
        width: 1,
      ),
    );
  }
}
