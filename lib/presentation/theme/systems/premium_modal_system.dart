import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/interfaces/premium_ui_interfaces.dart';
import 'package:prioris/presentation/theme/glassmorphism.dart';
import 'package:prioris/presentation/animations/physics_animations.dart';
import 'package:prioris/presentation/services/premium_haptic_service.dart';

/// Premium Modal System - Handles modals and overlays following SRP
/// Responsibility: All modal dialogs, bottom sheets, and overlay management
class PremiumModalSystem implements IPremiumModalSystem {
  final IPremiumThemeSystem _themeSystem;
  final IPremiumAnimationSystem _animationSystem;
  bool _isInitialized = false;

  PremiumModalSystem(this._themeSystem, this._animationSystem);

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    await Future.wait([
      _themeSystem.initialize(),
      _animationSystem.initialize(),
    ]);
    _isInitialized = true;
  }

  @override
  bool get isInitialized => _isInitialized;

  // ============ MODAL MANAGEMENT ============

  @override
  Future<T?> showModal<T>({
    required BuildContext context,
    required Widget child,
    bool enableGlass = true,
    bool enablePhysics = true,
    bool enableHaptics = true,
    bool barrierDismissible = true,
  }) {
    _ensureInitialized();

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.transparent,
      builder: (context) => _PremiumModal(
        enableGlass: enableGlass,
        enablePhysics: enablePhysics,
        enableHaptics: enableHaptics,
        barrierDismissible: barrierDismissible,
        onDismiss: () => Navigator.of(context).pop(),
        themeSystem: _themeSystem,
        animationSystem: _animationSystem,
        child: child,
      ),
    );
  }

  @override
  Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool enableGlass = true,
    bool enablePhysics = true,
    bool enableHaptics = true,
    double height = 400,
    bool enableDragHandle = true,
  }) {
    _ensureInitialized();

    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _PremiumBottomSheet(
        height: height,
        enableGlass: enableGlass,
        enablePhysics: enablePhysics,
        enableHaptics: enableHaptics,
        enableDragHandle: enableDragHandle,
        themeSystem: _themeSystem,
        animationSystem: _animationSystem,
        child: child,
      ),
    );
  }

  // ============ OVERLAY MANAGEMENT ============

  @override
  OverlayEntry showLoading({
    required BuildContext context,
    String? message,
    bool enableGlass = true,
  }) {
    _ensureInitialized();

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _PremiumLoadingOverlay(
        message: message,
        enableGlass: enableGlass,
        onDismiss: () => entry.remove(),
        themeSystem: _themeSystem,
      ),
    );

    overlay.insert(entry);
    return entry;
  }

  @override
  void dismissLoading(OverlayEntry entry) {
    entry.remove();
  }

  // ============ ADVANCED MODAL METHODS ============

  /// Shows a confirmation dialog
  Future<bool?> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool enableGlass = true,
    bool enableHaptics = true,
  }) {
    _ensureInitialized();

    return showModal<bool>(
      context: context,
      enableGlass: enableGlass,
      enableHaptics: enableHaptics,
      child: _ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        themeSystem: _themeSystem,
      ),
    );
  }

  /// Shows a custom alert dialog
  Future<void> showAlert({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    bool enableGlass = true,
    bool enableHaptics = true,
  }) {
    _ensureInitialized();

    return showModal<void>(
      context: context,
      enableGlass: enableGlass,
      enableHaptics: enableHaptics,
      child: _AlertDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        themeSystem: _themeSystem,
      ),
    );
  }

  // ============ PRIVATE METHODS ============

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('PremiumModalSystem must be initialized before use.');
    }
  }
}

// ============ INTERNAL MODAL WIDGETS ============

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
      bottomSheet = Glassmorphism.glassBottomSheet(
        height: widget.height,
        enableDragHandle: widget.enableDragHandle,
        child: bottomSheet,
      );
    } else {
      bottomSheet = Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: widget.themeSystem.getSurfaceColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            if (widget.enableDragHandle)
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            Expanded(child: bottomSheet),
          ],
        ),
      );
    }

    return bottomSheet;
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
    Widget loading = Container(
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
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: themeSystem.getPrimaryColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Row(
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
          ),
        ],
      ),
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
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: themeSystem.getPrimaryColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeSystem.getPrimaryColor(context),
              ),
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}