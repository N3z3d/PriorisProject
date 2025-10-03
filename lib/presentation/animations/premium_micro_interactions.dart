import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'widgets/export.dart';

/// Premium Micro-Interactions System
///
/// Features:
/// - Subtle hover effects with spring animations
/// - Haptic feedback integration
/// - Accessibility-aware animations
/// - Premium scaling and glow effects
/// - Performance-optimized with reduced motion support
class PremiumMicroInteractions {
  /// Creates a pressable widget with premium micro-interactions
  static Widget pressable({
    required Widget child,
    required VoidCallback onPressed,
    bool enableHaptics = true,
    bool enableScaleEffect = true,
    bool enableGlowEffect = false,
    double scaleFactor = 0.97,
    Duration duration = const Duration(milliseconds: 150),
    Color? glowColor,
  }) {
    return PressableWidget(
      onPressed: onPressed,
      enableHaptics: enableHaptics,
      enableScaleEffect: enableScaleEffect,
      enableGlowEffect: enableGlowEffect,
      scaleFactor: scaleFactor,
      duration: duration,
      glowColor: glowColor,
      child: child,
    );
  }

  /// Creates a hoverable widget with premium hover effects
  static Widget hoverable({
    required Widget child,
    bool enableScaleEffect = true,
    bool enableGlowEffect = false,
    double scaleFactorHover = 1.03,
    Duration duration = const Duration(milliseconds: 200),
    Color? glowColor,
  }) {
    return HoverableWidget(
      enableScaleEffect: enableScaleEffect,
      enableGlowEffect: enableGlowEffect,
      scaleFactorHover: scaleFactorHover,
      duration: duration,
      glowColor: glowColor,
      child: child,
    );
  }

  /// Creates a shimmer loading effect for premium placeholders
  static Widget shimmer({
    required Widget child,
    bool enabled = true,
    Color? baseColor,
    Color? highlightColor,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    if (!enabled) return child;

    return ShimmerWidget(
      baseColor: baseColor ?? AppTheme.grey200,
      highlightColor: highlightColor ?? AppTheme.grey100,
      duration: duration,
      child: child,
    );
  }

  /// Creates a bounce animation for success feedback
  static Widget bounce({
    required Widget child,
    bool trigger = false,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return BounceWidget(
      trigger: trigger,
      duration: duration,
      child: child,
    );
  }

  /// Creates a staggered entrance animation for lists
  static Widget staggeredEntrance({
    required Widget child,
    required int index,
    Duration delay = const Duration(milliseconds: 100),
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return StaggeredEntranceWidget(
      index: index,
      delay: delay,
      duration: duration,
      child: child,
    );
  }
}