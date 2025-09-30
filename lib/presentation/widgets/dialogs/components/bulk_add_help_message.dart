import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Help message component for BulkAddDialog
///
/// **SRP**: Only responsible for displaying contextual help text
/// **Size**: < 30 lines (constraint respected)
class BulkAddHelpMessage extends StatelessWidget {
  final String message;

  const BulkAddHelpMessage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.info_outline,
          size: 14,
          color: AppTheme.primaryColor.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}