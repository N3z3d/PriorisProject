import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// BoxDecoration builder for HabitCard with hover and completion states.
///
/// Responsibilities:
/// - Build card decoration based on hover state
/// - Apply success color tint when habit is completed
/// - Provide appropriate shadows and borders
///
/// SOLID: SRP - Single responsibility (decoration styling)
class HabitCardDecoration {
  /// Creates a BoxDecoration for the habit card.
  ///
  /// Parameters:
  /// - [isHovered]: Whether the card is currently hovered
  /// - [isCompleted]: Whether the habit is completed (progress >= 1.0)
  static BoxDecoration create({
    required bool isHovered,
    required bool isCompleted,
  }) {
    return BoxDecoration(
      color: isCompleted
          ? AppTheme.successColor.withValues(alpha: 0.05)
          : AppTheme.surfaceColor,
      borderRadius: BorderRadius.circular(AppTheme.radiusLG),
      border: Border.all(
        color: isHovered
            ? AppTheme.primaryColor.withValues(alpha: 0.3)
            : AppTheme.grey300,
        width: isHovered ? 2 : 1,
      ),
      boxShadow: _buildShadows(isHovered),
    );
  }

  static List<BoxShadow> _buildShadows(bool isHovered) {
    if (isHovered) {
      return [
        BoxShadow(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
    }

    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ];
  }
}
