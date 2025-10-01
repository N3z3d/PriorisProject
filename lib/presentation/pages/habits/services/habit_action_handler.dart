/// SOLID Habit Action Handler Service
/// Single Responsibility: Handle habit actions and business logic only

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/habits_state_provider.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/widgets/dialogs/dialogs.dart';
import '../interfaces/habits_page_interfaces.dart';

/// Concrete implementation of habit action handler
/// Follows Single Responsibility Principle - only handles habit actions
class HabitActionHandler implements IHabitActionHandler {
  final BuildContext _context;
  final WidgetRef _ref;

  const HabitActionHandler({
    required BuildContext context,
    required WidgetRef ref,
  }) : _context = context,
       _ref = ref;

  @override
  void handleHabitAction(String action, Habit habit) {
    switch (action.toLowerCase()) {
      case 'record':
        recordHabit(habit);
        break;
      case 'edit':
        editHabit(habit);
        break;
      case 'delete':
        deleteHabit(habit);
        break;
      default:
        _showActionError('Action non supportée: $action');
    }
  }

  @override
  Future<void> recordHabit(Habit habit) async {
    try {
      // Show loading indicator
      _showLoadingDialog('Enregistrement...');

      // Record habit completion by updating the habit with new completion data
      // TODO: Implement proper habit completion logic
      await _ref.read(habitsStateProvider.notifier).updateHabit(habit);

      // Close loading dialog
      if (_context.mounted) {
        Navigator.of(_context).pop();
      }

      // Show success feedback
      _showSuccessSnackBar('Habitude "${habit.name}" enregistrée !');

    } catch (error) {
      // Close loading dialog if still showing
      if (_context.mounted) {
        Navigator.of(_context).pop();
      }

      // Show error message
      _showActionError('Erreur lors de l\'enregistrement: $error');
    }
  }

  @override
  Future<void> editHabit(Habit habit) async {
    try {
      // Navigate to edit habit dialog/page
      final result = await showDialog<bool>(
        context: _context,
        builder: (context) => _EditHabitDialog(habit: habit),
      );

      if (result == true && _context.mounted) {
        // Refresh habits list after edit
        await _ref.read(habitsStateProvider.notifier).loadHabits();
        _showSuccessSnackBar('Habitude modifiée avec succès !');
      }

    } catch (error) {
      _showActionError('Erreur lors de la modification: $error');
    }
  }

  @override
  Future<void> deleteHabit(Habit habit) async {
    try {
      // Show confirmation dialog
      final confirmed = await _showDeleteConfirmationDialog(habit);

      if (!confirmed) return;

      // Show loading indicator
      _showLoadingDialog('Suppression...');

      // Delete the habit
      await _ref.read(habitsStateProvider.notifier).deleteHabit(habit.id);

      // Close loading dialog
      if (_context.mounted) {
        Navigator.of(_context).pop();
      }

      // Show success feedback
      _showSuccessSnackBar('Habitude "${habit.name}" supprimée');

    } catch (error) {
      // Close loading dialog if still showing
      if (_context.mounted) {
        Navigator.of(_context).pop();
      }

      // Show error message
      _showActionError('Erreur lors de la suppression: $error');
    }
  }

  @override
  Future<void> addNewHabit() async {
    try {
      // Navigate to add habit dialog/page
      final result = await showDialog<bool>(
        context: _context,
        builder: (context) => const _AddHabitDialog(),
      );

      if (result == true && _context.mounted) {
        // Refresh habits list after adding
        await _ref.read(habitsStateProvider.notifier).loadHabits();
        _showSuccessSnackBar('Nouvelle habitude créée !');
      }

    } catch (error) {
      _showActionError('Erreur lors de la création: $error');
    }
  }

  /// Show delete confirmation dialog
  Future<bool> _showDeleteConfirmationDialog(Habit habit) async {
    return await showDialog<bool>(
      context: _context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'habitude'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${habit.name}" ?\n\n'
          'Cette action est irréversible et supprimera également tout l\'historique associé.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ) ?? false;
  }

  /// Show loading dialog
  void _showLoadingDialog(String message) {
    showDialog(
      context: _context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(child: Text(message)),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Show success snack bar
  void _showSuccessSnackBar(String message) {
    if (!_context.mounted) return;

    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show action error
  void _showActionError(String message) {
    if (!_context.mounted) return;

    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

/// Edit habit dialog widget
class _EditHabitDialog extends StatelessWidget {
  final Habit habit;

  const _EditHabitDialog({required this.habit});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier l\'habitude'),
      content: const Text('Fonctionnalité de modification à implémenter'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Sauvegarder'),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

/// Add habit dialog widget
class _AddHabitDialog extends StatelessWidget {
  const _AddHabitDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter une habitude'),
      content: const Text('Fonctionnalité d\'ajout à implémenter'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Créer'),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

/// Extension for habit action handler utilities
extension HabitActionHandlerExtensions on HabitActionHandler {
  /// Check if an action is supported
  static bool isActionSupported(String action) {
    const supportedActions = ['record', 'edit', 'delete', 'add'];
    return supportedActions.contains(action.toLowerCase());
  }

  /// Get user-friendly action names
  static Map<String, String> getActionDisplayNames() {
    return {
      'record': 'Marquer comme fait',
      'edit': 'Modifier',
      'delete': 'Supprimer',
      'add': 'Ajouter',
    };
  }

  /// Get action icons
  static Map<String, IconData> getActionIcons() {
    return {
      'record': Icons.check_circle_rounded,
      'edit': Icons.edit_rounded,
      'delete': Icons.delete_rounded,
      'add': Icons.add_circle_rounded,
    };
  }
}