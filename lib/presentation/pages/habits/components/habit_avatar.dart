import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Avatar component for habit following SRP
class HabitAvatar extends StatelessWidget {
  final Habit habit;

  const HabitAvatar({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.accentColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        _getHabitIcon(habit.category ?? 'Général'),
        color: Colors.white,
        size: 24,
      ),
    );
  }

  IconData _getHabitIcon(String category) {
    switch (category.toLowerCase()) {
      case 'santé':
        return Icons.favorite;
      case 'sport':
        return Icons.fitness_center;
      case 'productivité':
        return Icons.work;
      case 'développement personnel':
        return Icons.psychology;
      case 'créativité':
        return Icons.palette;
      case 'sociale':
        return Icons.people;
      default:
        return Icons.star;
    }
  }
}
