import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Modern status indicator widget with cleaner design
class StatusIndicator extends StatelessWidget {
  final bool isCompleted;
  final String? completedLabel;
  final String? pendingLabel;
  final double size;
  final bool showText;
  final StatusStyle style;

  const StatusIndicator({
    super.key,
    required this.isCompleted,
    this.completedLabel,
    this.pendingLabel,
    this.size = 24,
    this.showText = true,
    this.style = StatusStyle.minimal,
  });

  /// Factory for minimal icon-only status
  const StatusIndicator.minimal({
    super.key,
    required this.isCompleted,
    this.size = 20,
  }) : completedLabel = null,
       pendingLabel = null,
       showText = false,
       style = StatusStyle.minimal;

  /// Factory for badge style status
  const StatusIndicator.badge({
    super.key,
    required this.isCompleted,
    this.completedLabel = 'Fait',
    this.pendingLabel = 'À faire',
    this.size = 16,
  }) : showText = true,
       style = StatusStyle.badge;

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case StatusStyle.minimal:
        return _buildMinimalIndicator();
      case StatusStyle.badge:
        return _buildBadgeIndicator();
      case StatusStyle.chip:
        return _buildChipIndicator();
    }
  }

  /// Builds minimal icon-only indicator
  Widget _buildMinimalIndicator() {
    return Icon(
      isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
      color: isCompleted ? AppTheme.successColor : AppTheme.textTertiary,
      size: size,
      semanticLabel: isCompleted ? 'Terminé' : 'En cours',
    );
  }

  /// Builds badge-style indicator with text
  Widget _buildBadgeIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppTheme.successColor.withValues(alpha: 0.1)
            : AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? AppTheme.successColor.withValues(alpha: 0.3)
              : AppTheme.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.schedule,
            color: isCompleted ? AppTheme.successColor : AppTheme.primaryColor,
            size: size,
          ),
          if (showText) ...[
            const SizedBox(width: 4),
            Text(
              isCompleted
                  ? (completedLabel ?? 'Fait')
                  : (pendingLabel ?? 'À faire'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isCompleted ? AppTheme.successColor : AppTheme.primaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds chip-style indicator
  Widget _buildChipIndicator() {
    return Chip(
      avatar: Icon(
        isCompleted ? Icons.check_circle : Icons.schedule,
        color: isCompleted ? AppTheme.successColor : AppTheme.primaryColor,
        size: size,
      ),
      label: Text(
        isCompleted
            ? (completedLabel ?? 'Terminé')
            : (pendingLabel ?? 'En cours'),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isCompleted ? AppTheme.successColor : AppTheme.primaryColor,
        ),
      ),
      backgroundColor: isCompleted
          ? AppTheme.successColor.withValues(alpha: 0.1)
          : AppTheme.primaryColor.withValues(alpha: 0.1),
      side: BorderSide(
        color: isCompleted
            ? AppTheme.successColor.withValues(alpha: 0.3)
            : AppTheme.primaryColor.withValues(alpha: 0.3),
        width: 1,
      ),
    );
  }
}

enum StatusStyle {
  minimal,
  badge,
  chip,
}