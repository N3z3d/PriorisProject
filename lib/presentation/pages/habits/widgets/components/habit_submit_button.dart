import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/common/forms/common_button.dart';

class HabitSubmitButton extends StatelessWidget {
  const HabitSubmitButton({
    super.key,
    required this.isEditing,
    required this.onPressed,
  });

  final bool isEditing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CommonButton(
        text: isEditing ? 'Enregistrer' : 'Créer l\'habitude',
        onPressed: onPressed,
        type: ButtonType.primary,
        icon: isEditing ? Icons.save : Icons.add,
      ),
    );
  }
}
