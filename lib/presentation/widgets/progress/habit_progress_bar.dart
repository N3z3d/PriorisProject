import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Widget affichant la barre de progression d'une habitude
class HabitProgressBar extends StatelessWidget {
  final Habit habit;
  final dynamic todayValue;
  final Animation<double> progressAnimation;

  const HabitProgressBar({
    super.key,
    required this.habit,
    required this.todayValue,
    required this.progressAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabels(context),
        const SizedBox(height: AppTheme.spacingSM),
        _buildProgressBar(),
      ],
    );
  }

  Widget _buildLabels(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Progrès du jour',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        Text(
          _statusText,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: _progressColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: progressAnimation,
      builder: (context, child) {
        return Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.textTertiary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppTheme.radiusXS),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progressAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: _progressColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                boxShadow: [
                  BoxShadow(
                    color: _progressColor.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double _getProgressValue() {
    if (habit.type == HabitType.binary) {
      return todayValue == true ? 1.0 : 0.0;
    }
    if (habit.targetValue == null || habit.targetValue == 0) {
      return 0.0;
    }
    final currentValue = todayValue as double? ?? 0.0;
    return (currentValue / habit.targetValue!).clamp(0.0, 1.0);
  }

  Color get _progressColor {
    final progress = _getProgressValue();
    if (progress >= 1.0) return AppTheme.successColor;
    if (progress >= 0.7) return AppTheme.warningColor;
    if (progress > 0) return AppTheme.infoColor;
    return AppTheme.textTertiary;
  }

  String get _statusText {
    if (habit.type == HabitType.binary) {
      return todayValue == true ? 'Terminé' : 'En attente';
    }
    final currentValue = todayValue as double? ?? 0.0;
    final target = habit.targetValue ?? 0.0;
    final unit = habit.unit ?? '';
    return '$currentValue / $target $unit';
  }
}
