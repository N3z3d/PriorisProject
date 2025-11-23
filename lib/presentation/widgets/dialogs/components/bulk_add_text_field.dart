import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/dialogs/bulk_add_dialog.dart';

/// Text input field component for BulkAddDialog
///
/// **SRP**: Only responsible for rendering text input with appropriate styling
/// **Size**: < 50 lines (constraint respected)
class BulkAddTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final BulkAddMode mode;
  final String hintText;
  final Function(String) onSubmitted;
  final bool enabled;

  const BulkAddTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.mode,
    required this.hintText,
    required this.onSubmitted,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: focusNode.hasFocus
              ? AppTheme.primaryColor
              : AppTheme.surfaceColor.withValues(alpha: 0.5),
          width: focusNode.hasFocus ? 2 : 1,
        ),
        color: AppTheme.surfaceColor.withValues(alpha: 0.2),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        maxLines: mode == BulkAddMode.multiple ? 5 : 1,
        style: TextStyle(
          color: enabled ? AppTheme.textPrimary : AppTheme.textSecondary.withValues(alpha: 0.5),
          fontSize: 15,
          height: 1.4,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppTheme.textSecondary.withValues(alpha: 0.6),
            fontSize: 15,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        textInputAction: mode == BulkAddMode.single
            ? TextInputAction.done
            : TextInputAction.newline,
        onSubmitted: mode == BulkAddMode.single ? onSubmitted : null,
      ),
    );
  }
}