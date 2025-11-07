import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/habits_state_provider.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/habits/components/habits_body.dart';
import 'package:prioris/presentation/pages/habits/components/habits_header.dart';
import 'package:prioris/presentation/pages/habits/controllers/habits_controller.dart';
import 'package:prioris/presentation/pages/habits/services/habit_form_dialog_service.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

class HabitsPage extends ConsumerStatefulWidget {
  const HabitsPage({super.key});

  @override
  ConsumerState<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends ConsumerState<HabitsPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final habits = ref.watch(reactiveHabitsProvider);
    final isLoading = ref.watch(habitsLoadingProvider);
    final error = ref.watch(habitsErrorProvider);
    final controllerState = ref.watch(habitsControllerProvider);

    _autoLoadHabitsIfNeeded(habits, isLoading, error);
    _handleActionResults(context, controllerState);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HabitsHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: ElevatedButton.icon(
                onPressed: _showCreateHabitModal,
                icon: const Icon(Icons.add),
                label: Text(l10n.habitsButtonCreate),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: HabitsBody(
                habits: habits,
                isLoading: isLoading,
                error: error,
                onDeleteHabit: _showDeleteConfirmation,
                onRecordHabit:
                    ref.read(habitsControllerProvider.notifier).recordHabit,
                onCreateHabit: _showCreateHabitModal,
                onEditHabit: (habit) =>
                    _showCreateHabitModal(initialHabit: habit),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _autoLoadHabitsIfNeeded(
    List<Habit> habits,
    bool isLoading,
    String? error,
  ) {
    if (habits.isEmpty && !isLoading && error == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(habitsStateProvider.notifier).loadHabits();
      });
    }
  }

  void _handleActionResults(
    BuildContext context,
    HabitsControllerState state,
  ) {
    if (state.lastActionMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final color = state.actionResult == ActionResult.success
            ? AppTheme.successColor
            : AppTheme.errorColor;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.lastActionMessage!),
            backgroundColor: color,
          ),
        );
        ref.read(habitsControllerProvider.notifier).clearLastAction();
      });
    }
  }

  void _showDeleteConfirmation(String habitId, String habitName) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.habitsDialogDeleteTitle),
        content: Text(l10n.habitsDialogDeleteMessage(habitName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ref.read(habitsControllerProvider.notifier).deleteHabit(
                    habitId,
                    habitName,
                  );
            },
            child: Text(
              l10n.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateHabitModal({Habit? initialHabit}) {
    return HabitFormDialogService(context: context, ref: ref)
        .showHabitForm(initialHabit: initialHabit);
  }
}
