import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/theme/premium_micro_interactions.dart';
import 'package:prioris/presentation/pages/habits/components/habit_progress_display.dart';
import 'package:prioris/presentation/pages/habits/components/habit_avatar.dart';
import 'package:prioris/presentation/pages/habits/components/habit_menu.dart';

/// Card component for individual habit following SRP
/// Responsible only for rendering a single habit card
class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onDelete;
  final VoidCallback onRecord;
  final VoidCallback onEdit;
  final VoidCallback onTap;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onDelete,
    required this.onRecord,
    required this.onEdit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumMicroInteractions.elevatedCardAnimation(
      child: PremiumMicroInteractions.hapticFeedbackAnimation(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: _buildCardDecoration(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                HabitProgressDisplay(habit: habit),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        HabitAvatar(habit: habit),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(),
              const SizedBox(height: 4),
              _buildCategory(),
            ],
          ),
        ),
        HabitMenu(
          onRecord: onRecord,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      habit.name,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildCategory() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        habit.category ?? 'Général',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: AppTheme.premiumCardColor,
      borderRadius: BorderRadiusTokens.modal,
      border: Border.all(
        color: AppTheme.grey200,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 2),
          spreadRadius: -2,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }
}
