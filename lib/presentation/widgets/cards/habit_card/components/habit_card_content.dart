import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Content section of HabitCard displaying title and optional description.
///
/// Responsibilities:
/// - Display habit name with appropriate typography
/// - Display optional description with truncation
/// - Maintain consistent spacing
///
/// SOLID: SRP - Single responsibility (content text display)
class HabitCardContent extends StatelessWidget {
  const HabitCardContent({
    super.key,
    required this.habit,
  });

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          habit.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        if (_hasDescription) ...[
          const SizedBox(height: AppTheme.spacingSM),
          Text(
            habit.description!,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  bool get _hasDescription => habit.description?.isNotEmpty == true;
}
