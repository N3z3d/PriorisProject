import 'package:flutter/material.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Action buttons component for BulkAddDialog
///
/// **SRP**: Only responsible for rendering cancel and submit buttons
/// **Size**: < 50 lines (constraint respected)
class BulkAddActionButtons extends StatelessWidget {
  final bool isValid;
  final bool isSubmitting;
  final VoidCallback? onCancel;
  final VoidCallback onSubmit;

  const BulkAddActionButtons({
    super.key,
    required this.isValid,
    this.isSubmitting = false,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.cancel,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            key: const ValueKey('bulk_add_submit_button'),
            onPressed: isValid ? onSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isValid ? AppTheme.primaryColor : AppTheme.textSecondary.withValues(alpha: 0.3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: isValid ? 2 : 0,
              shadowColor: AppTheme.primaryColor.withValues(alpha: 0.3),
            ),
            child: Text(
              l10n.add,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}