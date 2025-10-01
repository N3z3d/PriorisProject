import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/pages/habits/widgets/habit_form_widget.dart';

/// Add form component for habits following SRP
class HabitAddForm extends StatelessWidget {
  final Function(Habit) onSubmit;

  const HabitAddForm({
    super.key,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: HabitFormWidget(
        onSubmit: onSubmit,
      ),
    );
  }
}
