import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/interfaces/premium_ui_interfaces.dart';
import 'package:prioris/presentation/theme/glassmorphism.dart';
import 'package:prioris/presentation/animations/physics_animations.dart';
import 'package:prioris/presentation/services/premium_haptic_service.dart';

/// Premium Bottom Sheet Builder - Handles bottom sheet construction following SRP
/// Responsibility: All bottom sheet widget construction
class PremiumBottomSheetBuilder {
  final IPremiumThemeSystem _themeSystem;
  final IPremiumAnimationSystem _animationSystem;

  const PremiumBottomSheetBuilder(this._themeSystem, this._animationSystem);

  /// Builds a premium bottom sheet widget
  Widget buildBottomSheet({
    required Widget child,
    required double height,
    required bool enableGlass,
    required bool enablePhysics,
    required bool enableHaptics,
    required bool enableDragHandle,
  }) {
    return _PremiumBottomSheet(
      height: height,
      enableGlass: enableGlass,
      enablePhysics: enablePhysics,
      enableHaptics: enableHaptics,
      enableDragHandle: enableDragHandle,
      themeSystem: _themeSystem,
      animationSystem: _animationSystem,
      child: child,
    );
  }
}

// ============ INTERNAL BOTTOM SHEET WIDGETS ============

/// Internal premium bottom sheet widget
class _PremiumBottomSheet extends StatefulWidget {
  final Widget child;
  final double height;
  final bool enableGlass;
  final bool enablePhysics;
  final bool enableHaptics;
  final bool enableDragHandle;
  final IPremiumThemeSystem themeSystem;
  final IPremiumAnimationSystem animationSystem;

  const _PremiumBottomSheet({
    required this.child,
    required this.height,
    required this.enableGlass,
    required this.enablePhysics,
    required this.enableHaptics,
    required this.enableDragHandle,
    required this.themeSystem,
    required this.animationSystem,
  });

  @override
  State<_PremiumBottomSheet> createState() => _PremiumBottomSheetState();
}

class _PremiumBottomSheetState extends State<_PremiumBottomSheet> {
  @override
  void initState() {
    super.initState();
    if (widget.enableHaptics) {
      PremiumHapticService.instance.modalOpened();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget bottomSheet = widget.child;

    if (widget.enablePhysics) {
      bottomSheet = PhysicsAnimations.gravityBounce(
        trigger: true,
        child: bottomSheet,
      );
    }

    if (widget.enableGlass) {
      bottomSheet = _buildGlassBottomSheet(bottomSheet);
    } else {
      bottomSheet = _buildStandardBottomSheet(bottomSheet);
    }

    return bottomSheet;
  }

  Widget _buildGlassBottomSheet(Widget child) {
    return Glassmorphism.glassBottomSheet(
      height: widget.height,
      enableDragHandle: widget.enableDragHandle,
      child: child,
    );
  }

  Widget _buildStandardBottomSheet(Widget child) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.themeSystem.getSurfaceColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          if (widget.enableDragHandle) _buildDragHandle(),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
