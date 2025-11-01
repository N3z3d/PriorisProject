import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/habits_state_provider.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/pages/habits/controllers/habits_controller.dart';
import 'package:prioris/presentation/pages/habits/widgets/habit_form_widget.dart';

class HabitFormDialogService {
  HabitFormDialogService({
    required this.context,
    required this.ref,
  });

  final BuildContext context;
  final WidgetRef ref;

  Future<void> showHabitForm({Habit? initialHabit}) async {
    final existingCategories = _collectExistingCategories();

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
                final controller =
                    ref.read(habitsControllerProvider.notifier);

                if (initialHabit == null) {
                  await controller.addHabit(habit);
                } else {
                  await controller.updateHabit(habit);
                }

                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ),
        );
      },
    );
  }

  List<String> _collectExistingCategories() {
    final habits = ref.read(habitsStateProvider).habits;
    final categories = habits
        .map((habit) => habit.category)
        .whereType<String>()
        .map((category) => category.trim())
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();

    categories.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return categories;
  }
}
