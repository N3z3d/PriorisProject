import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Header component for BulkAddDialog
///
/// **SRP**: Only responsible for rendering title and close button
/// **Size**: < 50 lines (constraint respected)
class BulkAddHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const BulkAddHeader({
    super.key,
    required this.title,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: title,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 20),
            color: AppTheme.textSecondary,
            splashRadius: 20,
            tooltip: 'Close dialog',
          ),
        ],
      ),
    );
  }
}