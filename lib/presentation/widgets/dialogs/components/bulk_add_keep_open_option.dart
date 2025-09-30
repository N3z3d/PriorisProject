import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Keep-open checkbox component for BulkAddDialog
///
/// **SRP**: Only responsible for rendering keep-open option
/// **Size**: < 35 lines (constraint respected)
class BulkAddKeepOpenOption extends StatelessWidget {
  final bool value;
  final Function(bool?) onChanged;

  const BulkAddKeepOpenOption({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          'Garder ouvert après ajout',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}