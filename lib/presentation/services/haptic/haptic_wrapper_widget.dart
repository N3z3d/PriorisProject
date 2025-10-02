import 'package:flutter/material.dart';
import '../premium_haptic_service.dart';

/// Widget wrapper qui ajoute automatiquement des feedbacks haptiques
/// Séparé du service pour respecter le Single Responsibility Principle
class HapticWrapper extends StatelessWidget {
  const HapticWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.tapIntensity = HapticIntensity.medium,
    this.longPressIntensity = HapticIntensity.heavy,
    this.enableHaptics = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final HapticIntensity tapIntensity;
  final HapticIntensity longPressIntensity;
  final bool enableHaptics;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap != null ? () async {
        if (enableHaptics) {
          await _executeHaptic(tapIntensity);
        }
        onTap!();
      } : null,
      onLongPress: onLongPress != null ? () async {
        if (enableHaptics) {
          await _executeHaptic(longPressIntensity);
        }
        onLongPress!();
      } : null,
      child: child,
    );
  }

  Future<void> _executeHaptic(HapticIntensity intensity) async {
    final service = PremiumHapticService.instance;
    switch (intensity) {
      case HapticIntensity.light:
        await service.lightImpact();
        break;
      case HapticIntensity.medium:
        await service.mediumImpact();
        break;
      case HapticIntensity.heavy:
        await service.heavyImpact();
        break;
    }
  }
}
