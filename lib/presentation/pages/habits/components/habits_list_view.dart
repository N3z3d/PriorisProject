/// SOLID Habits List View Component
/// Single Responsibility: Handle habits list display only

import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
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
  }) : _cardBuilder = cardBuilder,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state illustration
            Container(
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
              child: Icon(
                Icons.track_changes_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
            ),

            const SizedBox(height: 24),

            // Empty state text
            Text(
              'Aucune habitude créée',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Commencez par créer votre première habitude\ndans l\'onglet "Ajouter"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // Call to action button
            Container(
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
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_circle_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Créer ma première habitude',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error illustration
            Container(
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
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red[400],
              ),
            ),

            const SizedBox(height: 24),

            // Error title
            Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
              ),
            ),

            const SizedBox(height: 8),

            // Error details
            Text(
              _formatErrorMessage(error),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // Retry button
            Container(
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
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Réessayer',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Format error message for user display
  String _formatErrorMessage(Object error) {
    if (error is Exception) {
      final message = error.toString();
      if (message.contains('network') || message.contains('connection')) {
        return 'Problème de connexion réseau.\nVérifiez votre connexion internet.';
      }
      if (message.contains('timeout')) {
        return 'La requête a pris trop de temps.\nVeuillez réessayer.';
      }
      if (message.contains('permission')) {
        return 'Permissions insuffisantes.\nVérifiez vos autorisations.';
      }
      return 'Une erreur inattendue s\'est produite.\nVeuillez réessayer plus tard.';
    }

    return error.toString().length > 100
        ? '${error.toString().substring(0, 97)}...'
        : error.toString();
  }
}