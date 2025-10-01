import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/interfaces/premium_ui_interfaces.dart';
import 'package:prioris/presentation/theme/glassmorphism.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/animations/physics_animations.dart';
import 'package:prioris/presentation/widgets/loading/premium_skeletons.dart';
import 'package:prioris/presentation/services/premium_haptic_service.dart';

/// Premium Component System - Handles UI component builders following SRP
/// Responsibility: Creating and styling premium UI components
class PremiumComponentSystem implements IPremiumComponentSystem {
  final IPremiumThemeSystem _themeSystem;
  bool _isInitialized = false;

  PremiumComponentSystem(this._themeSystem);

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    await _themeSystem.initialize();
    _isInitialized = true;
  }

  @override
  bool get isInitialized => _isInitialized;

  // ============ BUTTON COMPONENTS ============

  @override
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
    _ensureInitialized();

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

  @override
  Widget createFAB({
    required VoidCallback onPressed,
    required Widget child,
    bool enableHaptics = true,
    bool enablePhysics = true,
    bool enableGlass = true,
    Color? color,
  }) {
    _ensureInitialized();

    return _PremiumFAB(
      onPressed: onPressed,
      child: child,
      enableHaptics: enableHaptics,
      enablePhysics: enablePhysics,
      enableGlass: enableGlass,
      color: color,
      themeSystem: _themeSystem,
    );
  }

  // ============ CARD COMPONENTS ============

  @override
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
    _ensureInitialized();

    return _PremiumCard(
      child: child,
      onTap: onTap,
      enableHaptics: enableHaptics,
      enablePhysics: enablePhysics,
      enableGlass: enableGlass,
      showLoading: showLoading,
      skeletonType: skeletonType,
      padding: padding,
      elevation: elevation,
      themeSystem: _themeSystem,
    );
  }

  // ============ LIST COMPONENTS ============

  @override
  Widget createListItem({
    required Widget child,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    List<Widget>? swipeActions,
    bool enableHaptics = true,
    bool enablePhysics = true,
    bool showLoading = false,
  }) {
    _ensureInitialized();

    return _PremiumListItem(
      child: child,
      onTap: onTap,
      onLongPress: onLongPress,
      swipeActions: swipeActions,
      enableHaptics: enableHaptics,
      enablePhysics: enablePhysics,
      showLoading: showLoading,
      themeSystem: _themeSystem,
    );
  }

  // ============ PRIVATE METHODS ============

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('PremiumComponentSystem must be initialized before use.');
    }
  }
}

// ============ INTERNAL COMPONENT WIDGETS ============

/// Internal premium button widget
class _PremiumButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final PremiumButtonStyle style;
  final ButtonSize size;
  final bool enableHaptics;
  final bool enablePhysics;
  final bool enableGlass;
  final IPremiumThemeSystem themeSystem;

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

  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      height: size.height,
      padding: EdgeInsets.symmetric(
        horizontal: size.horizontalPadding,
        vertical: size.verticalPadding,
      ),
      decoration: BoxDecoration(
        color: themeSystem.getButtonBackgroundColor(context, style),
        borderRadius: BorderRadiusTokens.button,
        boxShadow: [
          BoxShadow(
            color: themeSystem.getButtonShadowColor(context, style),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
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
      ),
    );

    if (enableGlass) {
      button = Glassmorphism.glassButton(
        onPressed: onPressed,
        child: button,
      );
    }

    return _wrapWithInteraction(
      button: button,
      onPressed: onPressed,
      enableHaptics: enableHaptics,
      enablePhysics: enablePhysics,
      hapticType: HapticType.medium,
    );
  }

  Widget _wrapWithInteraction({
    required Widget button,
    required VoidCallback onPressed,
    required bool enableHaptics,
    required bool enablePhysics,
    required HapticType hapticType,
  }) {
    if (enablePhysics) {
      return PhysicsAnimations.springScale(
        onTap: () => _handleTap(onPressed, enableHaptics, hapticType),
        child: button,
      );
    } else {
      return GestureDetector(
        onTap: () => _handleTap(onPressed, enableHaptics, hapticType),
        child: button,
      );
    }
  }

  Future<void> _handleTap(
    VoidCallback onPressed,
    bool enableHaptics,
    HapticType hapticType,
  ) async {
    if (enableHaptics) {
      switch (hapticType) {
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
    onPressed();
  }
}

/// Internal premium FAB widget
class _PremiumFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final bool enableHaptics;
  final bool enablePhysics;
  final bool enableGlass;
  final Color? color;
  final IPremiumThemeSystem themeSystem;

  const _PremiumFAB({
    required this.onPressed,
    required this.child,
    required this.enableHaptics,
    required this.enablePhysics,
    required this.enableGlass,
    this.color,
    required this.themeSystem,
  });

  @override
  Widget build(BuildContext context) {
    final fabColor = color ?? themeSystem.getPrimaryColor(context);

    Widget fab = FloatingActionButton(
      onPressed: () async {
        if (enableHaptics) {
          await PremiumHapticService.instance.heavyImpact();
        }
        onPressed();
      },
      backgroundColor: fabColor,
      child: child,
    );

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
}

/// Internal premium card widget
class _PremiumCard extends StatelessWidget {
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

  const _PremiumCard({
    required this.child,
    this.onTap,
    required this.enableHaptics,
    required this.enablePhysics,
    required this.enableGlass,
    required this.showLoading,
    required this.skeletonType,
    this.padding,
    this.elevation,
    required this.themeSystem,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeSystem.getSurfaceColor(context),
        borderRadius: BorderRadiusTokens.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: elevation ?? 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AdaptiveSkeletonLoader(
        isLoading: showLoading,
        skeletonType: skeletonType,
        child: child,
      ),
    );

    if (enableGlass) {
      card = Glassmorphism.glassCard(child: card);
    }

    if (onTap != null) {
      if (enablePhysics) {
        card = PhysicsAnimations.springScale(
          onTap: () async {
            if (enableHaptics) {
              await PremiumHapticService.instance.lightImpact();
            }
            onTap!();
          },
          child: card,
        );
      } else {
        card = GestureDetector(
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

    return card;
  }
}

/// Internal premium list item widget
class _PremiumListItem extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final List<Widget>? swipeActions;
  final bool enableHaptics;
  final bool enablePhysics;
  final bool showLoading;
  final IPremiumThemeSystem themeSystem;

  const _PremiumListItem({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.swipeActions,
    required this.enableHaptics,
    required this.enablePhysics,
    required this.showLoading,
    required this.themeSystem,
  });

  @override
  Widget build(BuildContext context) {
    Widget item = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeSystem.getSurfaceColor(context),
        borderRadius: BorderRadiusTokens.card,
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: AdaptiveSkeletonLoader(
        isLoading: showLoading,
        skeletonType: SkeletonType.list,
        child: child,
      ),
    );

    if (onTap != null || onLongPress != null) {
      if (enablePhysics) {
        item = PhysicsAnimations.springScale(
          onTap: () async {
            if (enableHaptics) {
              await PremiumHapticService.instance.lightImpact();
            }
            onTap?.call();
          },
          child: item,
        );
      } else {
        item = GestureDetector(
          onTap: () async {
            if (enableHaptics) {
              await PremiumHapticService.instance.lightImpact();
            }
            onTap?.call();
          },
          onLongPress: () async {
            if (enableHaptics) {
              await PremiumHapticService.instance.heavyImpact();
            }
            onLongPress?.call();
          },
          child: item,
        );
      }
    }

    // TODO: Add swipe actions support if needed
    return item;
  }
}

// ============ ENUMS ============

enum HapticType {
  light,
  medium,
  heavy,
}