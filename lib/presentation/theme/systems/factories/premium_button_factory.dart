import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/interfaces/premium_ui_interfaces.dart';
import 'package:prioris/presentation/theme/glassmorphism.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/animations/physics_animations.dart';
import 'package:prioris/presentation/services/premium_haptic_service.dart';
import 'premium_interaction_helpers.dart';

/// Factory for creating premium button widgets
/// Responsibility: Building styled button components with interactions
class PremiumButtonFactory {
  const PremiumButtonFactory(this._themeSystem);

  final IPremiumThemeSystem _themeSystem;

  /// Creates a premium button with optional icon
  Widget createButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    PremiumButtonStyle style = PremiumButtonStyle.primary,
    ButtonSize size = ButtonSize.medium,
    bool enableHaptics = true,
    bool enablePhysics = true,
    bool enableGlass = false,
  }) {
    return _PremiumButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      style: style,
      size: size,
      enableHaptics: enableHaptics,
      enablePhysics: enablePhysics,
      enableGlass: enableGlass,
      themeSystem: _themeSystem,
    );
  }

  /// Creates a premium FAB (Floating Action Button)
  Widget createFAB({
    required VoidCallback onPressed,
    required Widget child,
    bool enableHaptics = true,
    bool enablePhysics = true,
    bool enableGlass = true,
    Color? color,
  }) {
    return _PremiumFAB(
      onPressed: onPressed,
      enableHaptics: enableHaptics,
      enablePhysics: enablePhysics,
      enableGlass: enableGlass,
      color: color,
      themeSystem: _themeSystem,
      child: child,
    );
  }
}

/// Internal premium button widget
class _PremiumButton extends StatelessWidget {
  const _PremiumButton({
    required this.text,
    required this.onPressed,
    this.icon,
    required this.style,
    required this.size,
    required this.enableHaptics,
    required this.enablePhysics,
    required this.enableGlass,
    required this.themeSystem,
  });

  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final PremiumButtonStyle style;
  final ButtonSize size;
  final bool enableHaptics;
  final bool enablePhysics;
  final bool enableGlass;
  final IPremiumThemeSystem themeSystem;

  @override
  Widget build(BuildContext context) {
    Widget button = _buildButtonContainer(context);

    if (enableGlass) {
      button = Glassmorphism.glassButton(
        onPressed: onPressed,
        child: button,
      );
    }

    return PremiumInteractionHelpers.wrapWithInteraction(
      onPressed: onPressed,
      enableHaptics: enableHaptics,
      enablePhysics: enablePhysics,
      hapticType: HapticType.medium,
      child: button,
    );
  }

  Widget _buildButtonContainer(BuildContext context) {
    return Container(
      height: size.height,
      padding: EdgeInsets.symmetric(
        horizontal: size.horizontalPadding,
        vertical: size.verticalPadding,
      ),
      decoration: _buildButtonDecoration(context),
      child: _buildButtonContent(context),
    );
  }

  BoxDecoration _buildButtonDecoration(BuildContext context) {
    return BoxDecoration(
      color: themeSystem.getButtonBackgroundColor(context, style),
      borderRadius: BorderRadiusTokens.button,
      boxShadow: [
        BoxShadow(
          color: themeSystem.getButtonShadowColor(context, style),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildButtonContent(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: themeSystem.getButtonForegroundColor(context, style),
            size: size.iconSize,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: TextStyle(
            color: themeSystem.getButtonForegroundColor(context, style),
            fontSize: size.fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Internal premium FAB widget
class _PremiumFAB extends StatelessWidget {
  const _PremiumFAB({
    required this.onPressed,
    required this.enableHaptics,
    required this.enablePhysics,
    required this.enableGlass,
    this.color,
    required this.themeSystem,
    required this.child,
  });

  final VoidCallback onPressed;
  final Widget child;
  final bool enableHaptics;
  final bool enablePhysics;
  final bool enableGlass;
  final Color? color;
  final IPremiumThemeSystem themeSystem;

  @override
  Widget build(BuildContext context) {
    final fabColor = color ?? themeSystem.getPrimaryColor(context);
    Widget fab = _buildFAB(fabColor);

    if (enableGlass) {
      fab = Glassmorphism.glassFAB(
        onPressed: onPressed,
        backgroundColor: fabColor,
        child: child,
      );
    }

    if (enablePhysics) {
      fab = PhysicsAnimations.elasticBounce(
        trigger: false,
        child: fab,
      );
    }

    return fab;
  }

  Widget _buildFAB(Color fabColor) {
    return FloatingActionButton(
      onPressed: () async {
        if (enableHaptics) {
          await PremiumHapticService.instance.heavyImpact();
        }
        onPressed();
      },
      backgroundColor: fabColor,
      child: child,
    );
  }
}
