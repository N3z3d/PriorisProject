/// SOLID Habits List View Component
/// Single Responsibility: Handle habits list display only

import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/widgets/common/lists/virtualized_list.dart';
import '../interfaces/habits_page_interfaces.dart';

/// Concrete implementation of habits list view
/// Follows Single Responsibility Principle - only handles list display
class HabitsListView implements IHabitsListView {
  final IHabitCardBuilder _cardBuilder;
  final IHabitsPageTheme _themeProvider;

  const HabitsListView({
    required IHabitCardBuilder cardBuilder,
    required IHabitsPageTheme themeProvider,
  })  : _cardBuilder = cardBuilder,
        _themeProvider = themeProvider;

  @override
  Widget buildHabitsList(List<Habit> habits) {
    if (habits.isEmpty) {
      return buildEmptyState();
    }

    return VirtualizedList<Habit>(
      items: habits,
      itemBuilder: (context, habit, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: buildHabitCard(habit),
      ),
      physics: const BouncingScrollPhysics(),
    );
  }

  @override
  Widget buildHabitCard(Habit habit) {
    return _cardBuilder.buildHabitCard(habit);
  }

  @override
  Widget buildEmptyState() {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildEmptyStateconst Icon(),
                const SizedBox(height: 24),
                _buildEmptyStateText(l10n),
                const SizedBox(height: 32),
                _buildEmptyStateButton(l10n),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the empty state icon with gradient background
  Widget _buildEmptyStateconst Icon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.withOpacity(0.1),
            Colors.grey.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(60),
      ),
      child: const Icon(
        Icons.track_changes_outlined,
        size: 48,
        color: Colors.grey[400],
      ),
    );
  }

  /// Builds the empty state text (title and description)
  Widget _buildEmptyStateText(AppLocalizations l10n) {
    return Column(
      children: [
        Text(
          l10n.habitsEmptyTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.habitsEmptySubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  /// Builds the call to action button for empty state
  Widget _buildEmptyStateButton(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6366f1), // Indigo-500
            Color(0xFF8b5cf6), // Violet-500
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366f1).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // This should be handled by the parent widget
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add_circle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.habitsButtonCreate,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  @override
  Widget buildErrorState(Object error) {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildErrorStateconst Icon(),
                const SizedBox(height: 24),
                _buildErrorStateText(l10n, error),
                const SizedBox(height: 32),
                _buildErrorStateButton(l10n),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the error state icon with gradient background
  Widget _buildErrorStateconst Icon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.withOpacity(0.1),
            Colors.red.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(60),
      ),
      child: const Icon(
        Icons.error_outline_rounded,
        size: 48,
        color: Colors.red[400],
      ),
    );
  }

  /// Builds the error state text (title and error message)
  Widget _buildErrorStateText(AppLocalizations l10n, Object error) {
    return Column(
      children: [
        Text(
          l10n.habitsErrorTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.red[700],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _formatErrorMessage(l10n, error),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  /// Builds the retry button for error state
  Widget _buildErrorStateButton(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red[500],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // This should be handled by the parent widget
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.retry,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Format error message for user display
  String _formatErrorMessage(AppLocalizations l10n, Object error) {
    if (error is Exception) {
      final message = error.toString();
      if (message.contains('network') || message.contains('connection')) {
        return l10n.habitsErrorNetwork;
      }
      if (message.contains('timeout')) {
        return l10n.habitsErrorTimeout;
      }
      if (message.contains('permission')) {
        return l10n.habitsErrorPermission;
      }
      return l10n.habitsErrorUnexpected;
    }

    return error.toString().length > 100
        ? '${error.toString().substring(0, 97)}...'
        : error.toString();
  }
}
