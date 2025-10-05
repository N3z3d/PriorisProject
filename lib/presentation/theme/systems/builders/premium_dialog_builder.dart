import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/interfaces/premium_ui_interfaces.dart';
import 'package:prioris/presentation/theme/glassmorphism.dart';
import 'package:prioris/presentation/animations/physics_animations.dart';
import 'package:prioris/presentation/services/premium_haptic_service.dart';

/// Premium Dialog Builder - Handles dialog construction following SRP
/// Responsibility: All dialog widget construction (modal, loading, confirmation, alert)
class PremiumDialogBuilder {
  final IPremiumThemeSystem _themeSystem;
  final IPremiumAnimationSystem _animationSystem;

  const PremiumDialogBuilder(this._themeSystem, this._animationSystem);

  /// Builds a premium modal dialog widget
  Widget buildModal({
    required Widget child,
    required bool enableGlass,
    required bool enablePhysics,
    required bool enableHaptics,
    required bool barrierDismissible,
    required VoidCallback onDismiss,
  }) {
    return _PremiumModal(
      enableGlass: enableGlass,
      enablePhysics: enablePhysics,
      enableHaptics: enableHaptics,
      barrierDismissible: barrierDismissible,
      onDismiss: onDismiss,
      themeSystem: _themeSystem,
      animationSystem: _animationSystem,
      child: child,
    );
  }

  /// Builds a loading overlay widget
  Widget buildLoadingOverlay({
    String? message,
    required bool enableGlass,
    required VoidCallback onDismiss,
  }) {
    return _PremiumLoadingOverlay(
      message: message,
      enableGlass: enableGlass,
      onDismiss: onDismiss,
      themeSystem: _themeSystem,
    );
  }

  /// Builds a confirmation dialog content widget
  Widget buildConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
  }) {
    return _ConfirmationDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      themeSystem: _themeSystem,
    );
  }

  /// Builds an alert dialog content widget
  Widget buildAlertDialog({
    required String title,
    required String message,
    required String buttonText,
  }) {
    return _AlertDialog(
      title: title,
      message: message,
      buttonText: buttonText,
      themeSystem: _themeSystem,
    );
  }
}

// ============ INTERNAL DIALOG WIDGETS ============

/// Internal premium modal widget
class _PremiumModal extends StatefulWidget {
  final Widget child;
  final bool enableGlass;
  final bool enablePhysics;
  final bool enableHaptics;
  final bool barrierDismissible;
  final VoidCallback onDismiss;
  final IPremiumThemeSystem themeSystem;
  final IPremiumAnimationSystem animationSystem;

  const _PremiumModal({
    required this.child,
    required this.enableGlass,
    required this.enablePhysics,
    required this.enableHaptics,
    required this.barrierDismissible,
    required this.onDismiss,
    required this.themeSystem,
    required this.animationSystem,
  });

  @override
  State<_PremiumModal> createState() => _PremiumModalState();
}

class _PremiumModalState extends State<_PremiumModal> {
  @override
  void initState() {
    super.initState();
    if (widget.enableHaptics) {
      PremiumHapticService.instance.modalOpened();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget modal = widget.child;

    if (widget.enablePhysics) {
      modal = PhysicsAnimations.springAnimation(
        trigger: true,
        child: modal,
      );
    }

    if (widget.enableGlass) {
      modal = Glassmorphism.glassModal(
        onDismiss: widget.barrierDismissible ? widget.onDismiss : null,
        child: modal,
      );
    } else {
      modal = Dialog(
        backgroundColor: Colors.transparent,
        child: modal,
      );
    }

    return modal;
  }
}

/// Internal premium loading overlay widget
class _PremiumLoadingOverlay extends StatelessWidget {
  final String? message;
  final bool enableGlass;
  final VoidCallback onDismiss;
  final IPremiumThemeSystem themeSystem;

  const _PremiumLoadingOverlay({
    this.message,
    required this.enableGlass,
    required this.onDismiss,
    required this.themeSystem,
  });

  @override
  Widget build(BuildContext context) {
    Widget loading = _buildLoadingContent(context);

    if (enableGlass) {
      loading = Glassmorphism.glassModal(
        child: loading,
        barrierDismissible: false,
      );
    } else {
      loading = Dialog(
        backgroundColor: themeSystem.getSurfaceColor(context),
        child: loading,
      );
    }

    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(child: loading),
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              themeSystem.getPrimaryColor(context),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: themeSystem.getPrimaryColor(context),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Internal confirmation dialog widget
class _ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final IPremiumThemeSystem themeSystem;

  const _ConfirmationDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.themeSystem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(context),
          const SizedBox(height: 16),
          _buildMessage(context),
          const SizedBox(height: 24),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: themeSystem.getPrimaryColor(context),
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildMessage(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: themeSystem.getPrimaryColor(context),
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }
}

/// Internal alert dialog widget
class _AlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final IPremiumThemeSystem themeSystem;

  const _AlertDialog({
    required this.title,
    required this.message,
    required this.buttonText,
    required this.themeSystem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(context),
          const SizedBox(height: 16),
          _buildMessage(context),
          const SizedBox(height: 24),
          _buildAction(context),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: themeSystem.getPrimaryColor(context),
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildMessage(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  Widget _buildAction(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: themeSystem.getPrimaryColor(context),
        ),
        child: Text(buttonText),
      ),
    );
  }
}
