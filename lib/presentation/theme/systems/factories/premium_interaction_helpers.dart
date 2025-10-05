import 'package:flutter/material.dart';
import 'package:prioris/presentation/animations/physics_animations.dart';
import 'package:prioris/presentation/services/premium_haptic_service.dart';

/// Haptic feedback types for premium interactions
enum HapticType {
  light,
  medium,
  heavy,
}

/// Helper class for premium UI interactions
/// Responsibility: Managing haptic feedback and physics animations
class PremiumInteractionHelpers {
  PremiumInteractionHelpers._();

  /// Wraps a widget with interactive behavior (physics + haptics)
  static Widget wrapWithInteraction({
    required VoidCallback onPressed,
    required bool enableHaptics,
    required bool enablePhysics,
    HapticType hapticType = HapticType.medium,
    required Widget child,
  }) {
    if (enablePhysics) {
      return PhysicsAnimations.springScale(
        onTap: () => handleTap(onPressed, enableHaptics, hapticType),
        child: child,
      );
    } else {
      return GestureDetector(
        onTap: () => handleTap(onPressed, enableHaptics, hapticType),
        child: child,
      );
    }
  }

  /// Handles tap with optional haptic feedback
  static Future<void> handleTap(
    VoidCallback onPressed,
    bool enableHaptics,
    HapticType hapticType,
  ) async {
    if (enableHaptics) {
      await _triggerHaptic(hapticType);
    }
    onPressed();
  }

  /// Triggers haptic feedback based on type
  static Future<void> _triggerHaptic(HapticType type) async {
    switch (type) {
      case HapticType.light:
        await PremiumHapticService.instance.lightImpact();
        break;
      case HapticType.medium:
        await PremiumHapticService.instance.mediumImpact();
        break;
      case HapticType.heavy:
        await PremiumHapticService.instance.heavyImpact();
        break;
    }
  }
}
