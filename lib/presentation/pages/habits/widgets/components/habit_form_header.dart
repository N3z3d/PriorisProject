import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

class HabitFormHeader extends StatelessWidget {
  const HabitFormHeader({super.key, required this.isEditing});

  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.add_circle_outline,
          color: AppTheme.accentColor,
          size: 32,
        ),
        const SizedBox(width: 16),
        Text(
          isEditing ? 'Modifier l\'habitude' : 'Nouvelle habitude',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
