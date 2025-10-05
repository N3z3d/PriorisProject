import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/interfaces/premium_ui_interfaces.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/animations/physics_animations.dart';
import 'package:prioris/presentation/widgets/loading/premium_skeletons.dart';
import 'package:prioris/presentation/services/premium_haptic_service.dart';

/// Factory for creating premium list item widgets
/// Responsibility: Building styled list components with interactions
class PremiumListFactory {
  const PremiumListFactory(this._themeSystem);

  final IPremiumThemeSystem _themeSystem;

  /// Creates a premium list item with optional swipe actions
  Widget createListItem({
    required Widget child,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    List<Widget>? swipeActions,
    bool enableHaptics = true,
    bool enablePhysics = true,
    bool showLoading = false,
  }) {
    return _PremiumListItem(
      onTap: onTap,
      onLongPress: onLongPress,
      swipeActions: swipeActions,
      enableHaptics: enableHaptics,
      enablePhysics: enablePhysics,
      showLoading: showLoading,
      themeSystem: _themeSystem,
      child: child,
    );
  }
}

/// Internal premium list item widget
class _PremiumListItem extends StatelessWidget {
  const _PremiumListItem({
    this.onTap,
    this.onLongPress,
    this.swipeActions,
    required this.enableHaptics,
    required this.enablePhysics,
    required this.showLoading,
    required this.themeSystem,
    required this.child,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final List<Widget>? swipeActions;
  final bool enableHaptics;
  final bool enablePhysics;
  final bool showLoading;
  final IPremiumThemeSystem themeSystem;

  @override
  Widget build(BuildContext context) {
    Widget item = _buildListItemContainer(context);

    if (onTap != null || onLongPress != null) {
      item = _wrapWithInteraction(item);
    }

    // TODO: Add swipe actions support if needed
    return item;
  }

  Widget _buildListItemContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _buildListItemDecoration(context),
      child: AdaptiveSkeletonLoader(
        isLoading: showLoading,
        skeletonType: SkeletonType.list,
        child: child,
      ),
    );
  }

  BoxDecoration _buildListItemDecoration(BuildContext context) {
    return BoxDecoration(
      color: themeSystem.getSurfaceColor(context),
      borderRadius: BorderRadiusTokens.card,
      border: Border.all(
        color: Colors.grey.withValues(alpha: 0.2),
        width: 1,
      ),
    );
  }

  Widget _wrapWithInteraction(Widget item) {
    if (enablePhysics) {
      return PhysicsAnimations.springScale(
        onTap: () => _handleTap(),
        child: item,
      );
    } else {
      return GestureDetector(
        onTap: () => _handleTap(),
        onLongPress: () => _handleLongPress(),
        child: item,
      );
    }
  }

  Future<void> _handleTap() async {
    if (enableHaptics) {
      await PremiumHapticService.instance.lightImpact();
    }
    onTap?.call();
  }

  Future<void> _handleLongPress() async {
    if (enableHaptics) {
      await PremiumHapticService.instance.heavyImpact();
    }
    onLongPress?.call();
  }
}
