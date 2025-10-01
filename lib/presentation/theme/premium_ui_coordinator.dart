import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/interfaces/premium_ui_interfaces.dart';
import 'package:prioris/presentation/theme/systems/premium_theme_system.dart';
import 'package:prioris/presentation/theme/systems/premium_component_system.dart';
import 'package:prioris/presentation/theme/systems/premium_animation_system.dart';
import 'package:prioris/presentation/theme/systems/premium_layout_system.dart';
import 'package:prioris/presentation/theme/systems/premium_modal_system.dart';
import 'package:prioris/presentation/theme/systems/premium_feedback_system.dart';
import 'package:prioris/presentation/widgets/loading/premium_skeletons.dart';
import 'package:prioris/presentation/services/premium_haptic_service.dart';

/// Main Premium UI Coordinator that coordinates all specialized UI systems
/// Following SOLID principles with single responsibility coordination
class PremiumUICoordinator implements IPremiumUICoordinator {
  static PremiumUICoordinator? _instance;
  static PremiumUICoordinator get instance => _instance ??= PremiumUICoordinator._();

  PremiumUICoordinator._();

  // Specialized UI systems - Dependency injection pattern
  late final IPremiumThemeSystem _themeSystem;
  late final IPremiumComponentSystem _componentSystem;
  late final IPremiumAnimationSystem _animationSystem;
  late final IPremiumLayoutSystem _layoutSystem;
  late final IPremiumModalSystem _modalSystem;
  late final IPremiumFeedbackSystem _feedbackSystem;

  bool _isInitialized = false;

  // ============ SYSTEM INITIALIZATION ============

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize haptic service first (dependency for other systems)
    await PremiumHapticService.instance.initialize();

    // Initialize all specialized systems with dependency injection
    _themeSystem = PremiumThemeSystem();
    _componentSystem = PremiumComponentSystem(_themeSystem);
    _animationSystem = PremiumAnimationSystem();
    _layoutSystem = PremiumLayoutSystem();
    _modalSystem = PremiumModalSystem(_themeSystem, _animationSystem);
    _feedbackSystem = PremiumFeedbackSystem(_themeSystem, _animationSystem);

    // Initialize each system
    await Future.wait([
      _themeSystem.initialize(),
      _componentSystem.initialize(),
      _animationSystem.initialize(),
      _layoutSystem.initialize(),
      _modalSystem.initialize(),
      _feedbackSystem.initialize(),
    ]);

    _isInitialized = true;
  }

  @override
  bool get isInitialized => _isInitialized;

  // ============ SYSTEM ACCESSORS ============

  @override
  IPremiumThemeSystem get themeSystem {
    _ensureInitialized();
    return _themeSystem;
  }

  @override
  IPremiumComponentSystem get componentSystem {
    _ensureInitialized();
    return _componentSystem;
  }

  @override
  IPremiumAnimationSystem get animationSystem {
    _ensureInitialized();
    return _animationSystem;
  }

  @override
  IPremiumLayoutSystem get layoutSystem {
    _ensureInitialized();
    return _layoutSystem;
  }

  @override
  IPremiumModalSystem get modalSystem {
    _ensureInitialized();
    return _modalSystem;
  }

  @override
  IPremiumFeedbackSystem get feedbackSystem {
    _ensureInitialized();
    return _feedbackSystem;
  }

  // ============ BACKWARD COMPATIBILITY METHODS ============
  // These delegate to specialized systems for seamless migration

  @override
  Widget premiumButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    PremiumButtonStyle style = PremiumButtonStyle.primary,
    ButtonSize size = ButtonSize.medium,
    bool enableHaptics = true,
    bool enablePhysics = true,
    bool enableGlass = false,
  }) {
    return componentSystem.createButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      style: style,
      size: size,
      enableHaptics: enableHaptics,
      enablePhysics: enablePhysics,
      enableGlass: enableGlass,
    );
  }

  @override
  Widget premiumCard({
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
    return componentSystem.createCard(
      child: child,
      onTap: onTap,
      enableHaptics: enableHaptics,
      enablePhysics: enablePhysics,
      enableGlass: enableGlass,
      showLoading: showLoading,
      skeletonType: skeletonType,
      padding: padding,
      elevation: elevation,
    );
  }

  @override
  Future<T?> showPremiumModal<T>({
    required BuildContext context,
    required Widget child,
    bool enableGlass = true,
    bool enablePhysics = true,
    bool enableHaptics = true,
    bool barrierDismissible = true,
  }) {
    return modalSystem.showModal<T>(
      context: context,
      child: child,
      enableGlass: enableGlass,
      enablePhysics: enablePhysics,
      enableHaptics: enableHaptics,
      barrierDismissible: barrierDismissible,
    );
  }

  // ============ CONVENIENCE METHODS ============

  /// Creates premium FAB using component system
  Widget premiumFAB({
    required VoidCallback onPressed,
    required Widget child,
    bool enableHaptics = true,
    bool enablePhysics = true,
    bool enableGlass = true,
    Color? color,
  }) {
    return componentSystem.createFAB(
      onPressed: onPressed,
      child: child,
      enableHaptics: enableHaptics,
      enablePhysics: enablePhysics,
      enableGlass: enableGlass,
      color: color,
    );
  }

  /// Shows premium bottom sheet using modal system
  Future<T?> showPremiumBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool enableGlass = true,
    bool enablePhysics = true,
    bool enableHaptics = true,
    double height = 400,
    bool enableDragHandle = true,
  }) {
    return modalSystem.showBottomSheet<T>(
      context: context,
      child: child,
      enableGlass: enableGlass,
      enablePhysics: enablePhysics,
      enableHaptics: enableHaptics,
      height: height,
      enableDragHandle: enableDragHandle,
    );
  }

  /// Shows premium success feedback
  void showPremiumSuccess({
    required BuildContext context,
    required String message,
    SuccessType type = SuccessType.standard,
    bool enableParticles = true,
    bool enableHaptics = true,
  }) {
    feedbackSystem.showSuccess(
      context: context,
      message: message,
      type: type,
      enableParticles: enableParticles,
      enableHaptics: enableHaptics,
    );
  }

  /// Shows premium error feedback
  void showPremiumError({
    required BuildContext context,
    required String message,
    bool enableHaptics = true,
  }) {
    feedbackSystem.showError(
      context: context,
      message: message,
      enableHaptics: enableHaptics,
    );
  }

  /// Shows premium loading overlay
  OverlayEntry showPremiumLoading({
    required BuildContext context,
    String? message,
    bool enableGlass = true,
  }) {
    return modalSystem.showLoading(
      context: context,
      message: message,
      enableGlass: enableGlass,
    );
  }

  // ============ PRIVATE METHODS ============

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('PremiumUICoordinator must be initialized before use. Call initialize() first.');
    }
  }
}