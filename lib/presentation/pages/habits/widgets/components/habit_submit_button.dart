import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/common/forms/common_button.dart';
import 'package:prioris/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: CommonButton(
        text: isEditing ? l10n.save : l10n.habitFormSubmitCreate,
        onPressed: onPressed,
        type: ButtonType.primary,
        icon: isEditing ? Icons.save : Icons.add,
      ),
    );
  }
}
