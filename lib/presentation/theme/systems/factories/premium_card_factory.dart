import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/interfaces/premium_ui_interfaces.dart';
import 'package:prioris/presentation/theme/glassmorphism.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/animations/physics_animations.dart';
import 'package:prioris/presentation/widgets/loading/premium_skeletons.dart';
import 'package:prioris/presentation/services/premium_haptic_service.dart';

/// Factory for creating premium card widgets
/// Responsibility: Building styled card components with loading states
class PremiumCardFactory {
  const PremiumCardFactory(this._themeSystem);

  final IPremiumThemeSystem _themeSystem;

  /// Creates a premium card with optional interactions
  Widget createCard({
    required Widget child,
    VoidCallback? onTap,
    bool enableHaptics = true,
    bool enablePhysics = true,
    bool enableGlass = false,
    bool showLoading = false,
    SkeletonType skeletonType = SkeletonType.custom,
    EdgeInsets? padding,
    double? elevation,
  }) {
    return _PremiumCard(
      onTap: onTap,
      enableHaptics: enableHaptics,
      enablePhysics: enablePhysics,
      enableGlass: enableGlass,
      showLoading: showLoading,
      skeletonType: skeletonType,
      padding: padding,
      elevation: elevation,
      themeSystem: _themeSystem,
      child: child,
    );
  }
}

/// Internal premium card widget
class _PremiumCard extends StatelessWidget {
  const _PremiumCard({
    this.onTap,
    required this.enableHaptics,
    required this.enablePhysics,
    required this.enableGlass,
    required this.showLoading,
    required this.skeletonType,
    this.padding,
    this.elevation,
    required this.themeSystem,
    required this.child,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool enableHaptics;
  final bool enablePhysics;
  final bool enableGlass;
  final bool showLoading;
  final SkeletonType skeletonType;
  final EdgeInsets? padding;
  final double? elevation;
  final IPremiumThemeSystem themeSystem;

  @override
  Widget build(BuildContext context) {
    Widget card = _buildCardContainer(context);

    if (enableGlass) {
      card = Glassmorphism.glassCard(child: card);
    }

    if (onTap != null) {
      card = _wrapWithInteraction(card);
    }

    return card;
  }

  Widget _buildCardContainer(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: _buildCardDecoration(context),
      child: AdaptiveSkeletonLoader(
        isLoading: showLoading,
        skeletonType: skeletonType,
        child: child,
      ),
    );
  }

  BoxDecoration _buildCardDecoration(BuildContext context) {
    return BoxDecoration(
      color: themeSystem.getSurfaceColor(context),
      borderRadius: BorderRadiusTokens.card,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: elevation ?? 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _wrapWithInteraction(Widget card) {
    if (enablePhysics) {
      return PhysicsAnimations.springScale(
        onTap: () async {
          if (enableHaptics) {
            await PremiumHapticService.instance.lightImpact();
          }
          onTap!();
        },
        child: card,
      );
    } else {
      return GestureDetector(
        onTap: () async {
          if (enableHaptics) {
            await PremiumHapticService.instance.lightImpact();
          }
          onTap!();
        },
        child: card,
      );
    }
  }
}
