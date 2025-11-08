/// Habit action handler responsible for user interactions around habits.
/// Focuses on orchestration and delegates domain logic to providers/services.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/habits_state_provider.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/habits/services/habit_form_dialog_service.dart';
import '../interfaces/habits_page_interfaces.dart';

class HabitActionHandler implements IHabitActionHandler {
  const HabitActionHandler({required BuildContext context, required WidgetRef ref})
      : _context = context,
        _ref = ref;

  final BuildContext _context;
  final WidgetRef _ref;

  AppLocalizations get _l10n => AppLocalizations.of(_context)!;

  @override
  void handleHabitAction(String action, Habit habit) {
    switch (action.toLowerCase()) {
      case 'record':
        recordHabit(habit);
        break;
      case 'edit':
        editHabit(habit);
        break;
      case 'add':
        addNewHabit();
        break;
      case 'delete':
        deleteHabit(habit);
        break;
      default:
        _showActionError(_l10n.habitsActionUnsupported(action));
    }
  }

  @override
  Future<void> recordHabit(Habit habit) async {
    try {
      _showLoadingDialog(_l10n.habitsLoadingRecord);
      await _ref.read(habitsStateProvider.notifier).updateHabit(habit);
      if (_context.mounted) {
        Navigator.of(_context).pop();
      }
      _showSuccessSnackBar(
        _l10n.habitsActionRecordSuccess(habit.name),
      );
    } catch (error) {
      if (_context.mounted) {
        Navigator.of(_context).pop();
      }
      _showActionError(
        _l10n.habitsActionRecordError(error.toString()),
      );
    }
  }

  @override
  Future<void> editHabit(Habit habit) async {
    try {
      await HabitFormDialogService(context: _context, ref: _ref)
          .showHabitForm(initialHabit: habit);
    } catch (error) {
      _showActionError(
        _l10n.habitsActionUpdateError(error.toString()),
      );
    }
  }

  @override
  Future<void> deleteHabit(Habit habit) async {
    try {
      final confirmed = await _showDeleteConfirmationDialog(habit);
      if (!confirmed) return;

      _showLoadingDialog(_l10n.habitsLoadingDelete);
      await _ref.read(habitsStateProvider.notifier).deleteHabit(habit.id);
      if (_context.mounted) {
        Navigator.of(_context).pop();
      }
      _showSuccessSnackBar(
        _l10n.habitsActionDeleteSuccess(habit.name),
      );
    } catch (error) {
      if (_context.mounted) {
        Navigator.of(_context).pop();
      }
      _showActionError(
        _l10n.habitsActionDeleteError(error.toString()),
      );
    }
  }

  @override
  Future<void> addNewHabit() async {
    try {
      await HabitFormDialogService(context: _context, ref: _ref).showHabitForm();
    } catch (error) {
      _showActionError(
        _l10n.habitsActionCreateError(error.toString()),
      );
    }
  }

  Future<bool> _showDeleteConfirmationDialog(Habit habit) async {
    return await showDialog<bool>(
          context: _context,
          builder: (context) => AlertDialog(
            title: Text(_l10n.habitsDialogDeleteTitle),
            content: Text(
              _l10n.habitsDialogDeleteMessage(habit.name),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(_l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(_l10n.delete),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ) ??
        false;
  }

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

  void _showSuccessSnackBar(String message) {
    if (!_context.mounted) return;

    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showActionError(String message) {
    if (!_context.mounted) return;

    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

