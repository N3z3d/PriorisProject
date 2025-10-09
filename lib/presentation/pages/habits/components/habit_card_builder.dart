/// SOLID Habit Card Builder Component
/// Single Responsibility: Build individual habit card components only

import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import '../interfaces/habits_page_interfaces.dart';

/// Concrete implementation of habit card builder
/// Follows Single Responsibility Principle - only handles card building
class HabitCardBuilder implements IHabitCardBuilder {
  final IHabitsPageTheme _themeProvider;
  final void Function(String, Habit)? _onActionCallback;

  const HabitCardBuilder({
    required IHabitsPageTheme themeProvider,
    void Function(String, Habit)? onActionCallback,
  }) : _themeProvider = themeProvider,
       _onActionCallback = onActionCallback;

  Widget buildHabitCard(Habit habit) {
    return Container(
      decoration: _themeProvider.getCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with avatar, title, and menu
            Row(
              children: [
                buildHabitAvatar(habit),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildHabitTitle(habit),
                      const SizedBox(height: 2),
                      buildHabitSubtitle(habit),
                    ],
                  ),
                ),
                buildHabitMenu(habit, onMenuSelected: () {}),
              ],
            ),

            const SizedBox(height: 16),

            // Progress section
            buildHabitProgress(habit),

            const SizedBox(height: 12),

            // Action buttons
            _buildActionButtons(habit),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildHabitAvatar(Habit habit) {
    return Container(
      width: 48,
      height: 48,
      decoration: _themeProvider.getAvatarDecoration(habit),
      child: Icon(
        _getHabitIcon(habit),
        color: Colors.white,
        size: 24,
      ),
    );
  }

  @override
  Widget buildHabitTitle(Habit habit) {
    return Text(
      habit.name,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1e293b),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget buildHabitSubtitle(Habit habit) {
    final frequency = _formatFrequency(habit);
    final category = habit.category ?? 'Général';

    return Text(
      '$frequency • $category',
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
        fontWeight: FontWeight.w500,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget buildHabitMenu(Habit habit, {required VoidCallback onMenuSelected}) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        color: Colors.grey[600],
        size: 20,
      ),
      onSelected: (action) {
        _onActionCallback?.call(action, habit);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_rounded, size: 18),
              SizedBox(width: 12),
              Text('Modifier'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_rounded, size: 18, color: Colors.red),
              SizedBox(width: 12),
              Text('Supprimer', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
    );
  }

  @override
  Widget buildHabitProgress(Habit habit) {
    final progress = _calculateProgress(habit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProgressHeader(habit, progress),
        const SizedBox(height: 8),
        _buildProgressBarWidget(habit, progress),
        const SizedBox(height: 8),
        _buildProgressDetails(habit),
      ],
    );
  }

  /// Build progress header with label and percentage
  Widget _buildProgressHeader(Habit habit, double progress) {
    final progressPercentage = (progress * 100).round();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Progression',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        Text(
          '$progressPercentage%',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _themeProvider.getHabitTypeColor(habit.type?.name ?? 'default'),
          ),
        ),
      ],
    );
  }

  /// Build animated progress bar
  Widget _buildProgressBarWidget(Habit habit, double progress) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        widthFactor: progress,
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: _themeProvider.getHabitTypeColor(habit.type?.name ?? 'default'),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  /// Build action buttons for the habit card
  Widget _buildActionButtons(Habit habit) {
    return Row(
      children: [
        Expanded(child: _buildCompleteAction(habit)),
        const SizedBox(width: 12),
        Expanded(child: _buildSkipAction(habit)),
        const SizedBox(width: 12),
        _buildQuickEditButton(habit),
      ],
    );
  }

  Widget _buildCompleteAction(Habit habit) {
    return _buildFilledActionButton(
      icon: Icons.check_circle_rounded,
      label: 'Marquer comme terminee',
      subtitle: 'Garde votre streak actif',
      gradientColors: const [Color(0xFF4ADE80), Color(0xFF22C55E)],
      shadowColor: const Color(0x3322C55E),
      onTap: () => _onActionCallback?.call('complete', habit),
    );
  }

  Widget _buildSkipAction(Habit habit) {
    return _buildOutlinedActionButton(
      icon: Icons.skip_next_rounded,
      label: 'Reporter',
      subtitle: 'Deplacer a plus tard',
      borderColor: const Color(0xFFCBD5F5),
      backgroundColor: const Color(0xFFF8FAFC),
      onTap: () => _onActionCallback?.call('skip', habit),
    );
  }

  Widget _buildQuickEditButton(Habit habit) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(BorderRadiusTokens.sm),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(BorderRadiusTokens.sm),
          onTap: () => _onActionCallback?.call('edit', habit),
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(
              Icons.edit_rounded,
              color: Color(0xFF4B5563),
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilledActionButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required List<Color> gradientColors,
    required Color shadowColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadiusTokens.buttonRounded,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadiusTokens.buttonRounded,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Colors.white, size: 22),
                    const SizedBox(width: 12),
                    _buildButtonTexts(
                      label: label,
                      subtitle: subtitle,
                      textColor: Colors.white,
                    ),
                  ],
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedActionButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color borderColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadiusTokens.buttonRounded,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadiusTokens.buttonRounded,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF475569), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildButtonTexts(
                    label: label,
                    subtitle: subtitle,
                    textColor: const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonTexts({
    required String label,
    required String subtitle,
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: textColor.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  /// Build detailed progress information
  Widget _buildProgressDetails(Habit habit) {
    final streakDays = _calculateStreak(habit);
    final completionsThisWeek = _calculateWeeklyCompletions(habit);

    return Row(
      children: [
        // Streak indicator
        Icon(
          Icons.local_fire_department_rounded,
          size: 16,
          color: Colors.orange[600],
        ),
        const SizedBox(width: 4),
        Text(
          '$streakDays jours',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(width: 16),

        // Weekly completions
        Icon(
          Icons.calendar_today_rounded,
          size: 16,
          color: Colors.blue[600],
        ),
        const SizedBox(width: 4),
        Text(
          '$completionsThisWeek/7 cette semaine',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Get appropriate icon for habit type
  IconData _getHabitIcon(Habit habit) {
    switch (habit.type?.name.toLowerCase()) {
      case 'health':
        return Icons.favorite_rounded;
      case 'productivity':
        return Icons.trending_up_rounded;
      case 'mindfulness':
        return Icons.self_improvement_rounded;
      case 'social':
        return Icons.people_rounded;
      case 'learning':
        return Icons.school_rounded;
      default:
        return Icons.track_changes_rounded;
    }
  }

  /// Format frequency for display
  String _formatFrequency(Habit habit) {
    // This would depend on your Habit model structure
    return 'Quotidien'; // Placeholder
  }

  /// Calculate habit progress (0.0 to 1.0)
  double _calculateProgress(Habit habit) {
    // This would depend on your Habit model and completion tracking
    return 0.7; // Placeholder
  }

  /// Calculate current streak
  int _calculateStreak(Habit habit) {
    // This would depend on your habit completion tracking
    return 5; // Placeholder
  }

  /// Calculate weekly completions
  int _calculateWeeklyCompletions(Habit habit) {
    // This would depend on your habit completion tracking
    return 4; // Placeholder
  }
}