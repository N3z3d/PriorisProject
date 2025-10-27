import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/habits_state_provider.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/pages/habits/components/habits_body.dart';
import 'package:prioris/presentation/pages/habits/components/habits_header.dart';
import 'package:prioris/presentation/pages/habits/controllers/habits_controller.dart';
import 'package:prioris/presentation/pages/habits/widgets/habit_form_widget.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

class HabitsPage extends ConsumerStatefulWidget {
  const HabitsPage({super.key});

  @override
  ConsumerState<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends ConsumerState<HabitsPage> {
  @override
  Widget build(BuildContext context) {
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
                label: const Text('Cr\u00e9er une habitude'),
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
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer l\'habitude'),
        content: Text('Supprimer "$habitName" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ref.read(habitsControllerProvider.notifier).deleteHabit(
                    habitId,
                    habitName,
                  );
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateHabitModal({Habit? initialHabit}) async {
    final existingCategories = ref
        .read(habitsStateProvider)
        .habits
        .map((habit) => habit.category)
        .whereType<String>()
        .where((category) => category.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: HabitFormWidget(
              initialHabit: initialHabit,
              availableCategories: existingCategories,
              onSubmit: (habit) async {
                final controller = ref.read(habitsControllerProvider.notifier);

                if (initialHabit == null) {
                  await controller.addHabit(habit);
                } else {
                  await controller.updateHabit(habit);
                }

                if (mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ),
        );
      },
    );
  }
}
