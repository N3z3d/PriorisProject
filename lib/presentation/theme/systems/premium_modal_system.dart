import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/interfaces/premium_ui_interfaces.dart';
import 'package:prioris/presentation/theme/systems/builders/export.dart';

/// Premium Modal System - Handles modals and overlays following SRP
/// Responsibility: Modal orchestration and lifecycle management
class PremiumModalSystem implements IPremiumModalSystem {
  final IPremiumThemeSystem _themeSystem;
  final IPremiumAnimationSystem _animationSystem;
  late final PremiumDialogBuilder _dialogBuilder;
  late final PremiumBottomSheetBuilder _bottomSheetBuilder;
  bool _isInitialized = false;

  PremiumModalSystem(this._themeSystem, this._animationSystem) {
    _dialogBuilder = PremiumDialogBuilder(_themeSystem, _animationSystem);
    _bottomSheetBuilder = PremiumBottomSheetBuilder(_themeSystem, _animationSystem);
  }

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
      builder: (context) => _dialogBuilder.buildModal(
        enableGlass: enableGlass,
        enablePhysics: enablePhysics,
        enableHaptics: enableHaptics,
        barrierDismissible: barrierDismissible,
        onDismiss: () => Navigator.of(context).pop(),
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
      builder: (context) => _bottomSheetBuilder.buildBottomSheet(
        height: height,
        enableGlass: enableGlass,
        enablePhysics: enablePhysics,
        enableHaptics: enableHaptics,
        enableDragHandle: enableDragHandle,
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
      builder: (context) => _dialogBuilder.buildLoadingOverlay(
        message: message,
        enableGlass: enableGlass,
        onDismiss: () => entry.remove(),
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
      child: _dialogBuilder.buildConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
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
      child: _dialogBuilder.buildAlertDialog(
        title: title,
        message: message,
        buttonText: buttonText,
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