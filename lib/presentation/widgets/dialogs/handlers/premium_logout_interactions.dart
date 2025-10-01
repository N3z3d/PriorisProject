import 'package:flutter/material.dart';
import 'package:prioris/presentation/services/premium_haptic_service.dart';
import 'package:prioris/presentation/widgets/dialogs/interfaces/premium_dialog_interfaces.dart';
import 'package:prioris/presentation/widgets/dialogs/components/premium_logout_dialog_ui.dart';

/// Interaction handler for premium logout dialog
///
/// Handles all user interactions following Single Responsibility Principle:
/// - Haptic feedback management
/// - Navigation and dialog results
/// - Confirmation flow handling
/// - Accessibility support
class PremiumLogoutInteractions implements IPremiumLogoutInteractions {
  final PremiumLogoutDialogUI _uiComponent = PremiumLogoutDialogUI();

  @override
  Future<void> handleCancel(
    BuildContext context, {
    required bool enableHaptics,
    required Future<void> Function() exitAnimation,
    required VoidCallback onComplete,
  }) async {
    if (enableHaptics) {
      await PremiumHapticService.instance.lightImpact();
    }

    await exitAnimation();
    onComplete();
  }

  @override
  Future<void> handleLogout(
    BuildContext context, {
    required bool enableHaptics,
    required VoidCallback triggerParticles,
    required Future<void> Function() exitAnimation,
    required VoidCallback onComplete,
  }) async {
    if (enableHaptics) {
      await PremiumHapticService.instance.success();
    }

    triggerParticles();
    await exitAnimation();
    onComplete();
  }

  @override
  Future<void> showDataClearConfirmation(
    BuildContext context, {
    required bool enableHaptics,
    required bool enablePhysicsAnimations,
    required bool respectReducedMotion,
    required Future<void> Function() exitAnimation,
    required VoidCallback onConfirmed,
  }) async {
    if (enableHaptics) {
      await PremiumHapticService.instance.warning();
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _DataClearConfirmationDialog(
        enableHaptics: enableHaptics,
        enablePhysicsAnimations: enablePhysicsAnimations,
        respectReducedMotion: respectReducedMotion,
        uiComponent: _uiComponent,
      ),
    );

    if (result == true) {
      await exitAnimation();
      onConfirmed();
    }
  }

  @override
  Future<void> triggerInitialHapticFeedback({required bool enableHaptics}) async {
    if (enableHaptics) {
      await PremiumHapticService.instance.modalOpened();
    }
  }

  @override
  bool shouldReduceMotion(BuildContext context, {required bool respectReducedMotion}) {
    return respectReducedMotion &&
        MediaQuery.maybeOf(context)?.disableAnimations == true;
  }
}

/// Internal confirmation dialog for data clearing
class _DataClearConfirmationDialog extends StatefulWidget {
  final bool enableHaptics;
  final bool enablePhysicsAnimations;
  final bool respectReducedMotion;
  final PremiumLogoutDialogUI uiComponent;

  const _DataClearConfirmationDialog({
    required this.enableHaptics,
    required this.enablePhysicsAnimations,
    required this.respectReducedMotion,
    required this.uiComponent,
  });

  @override
  State<_DataClearConfirmationDialog> createState() => _DataClearConfirmationDialogState();
}

class _DataClearConfirmationDialogState extends State<_DataClearConfirmationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startAnimation();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimation() {
    if (!widget.respectReducedMotion ||
        MediaQuery.maybeOf(context)?.disableAnimations != true) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _fadeAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: widget.uiComponent.buildDataClearDialog(
              context,
              onCancel: _handleCancel,
              onConfirm: _handleConfirm,
              enablePhysicsAnimations: widget.enablePhysicsAnimations,
            ),
          ),
        );
      },
    );
  }

  void _handleCancel() async {
    if (widget.enableHaptics) {
      await PremiumHapticService.instance.lightImpact();
    }

    if (mounted) {
      Navigator.of(context).pop(false);
    }
  }

  void _handleConfirm() async {
    if (widget.enableHaptics) {
      await PremiumHapticService.instance.heavyImpact();
    }

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }
}