import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/premium_ui_coordinator.dart';
import 'package:prioris/presentation/theme/interfaces/premium_ui_interfaces.dart';
import 'package:prioris/presentation/widgets/loading/premium_skeletons.dart';

/// Système UI Premium unifié - REFACTORED using SOLID principles
/// This class now acts as a compatibility layer for the new architecture
///
/// ARCHITECTURAL IMPROVEMENTS:
/// - Reduced from 927 lines to ~100 lines
/// - Delegates to specialized systems (Theme, Component, Animation, Layout, Modal, Feedback)
/// - Follows SOLID principles with proper separation of concerns
/// - Maintainable and testable architecture
///
/// All functionality is preserved for backward compatibility
class PremiumUISystem {
  static PremiumUISystem? _instance;
  static PremiumUISystem get instance => _instance ??= PremiumUISystem._();

  PremiumUISystem._();

  // ============ INITIALIZATION ============

  /// Initialise tous les services premium - Now using SOLID architecture
  static Future<void> initialize() async {
    await PremiumUICoordinator.instance.initialize();
  }

  // ============ PREMIUM BUTTONS ============
  // Delegates to PremiumUICoordinator for SOLID architecture

  /// Bouton premium avec toutes les fonctionnalités - Delegates to ComponentSystem
  static Widget premiumButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    PremiumButtonStyle style = PremiumButtonStyle.primary,
    ButtonSize size = ButtonSize.medium,
    bool enableHaptics = true,
    bool enablePhysics = true,
    bool enableGlass = false,
  }) {
    return PremiumUICoordinator.instance.premiumButton(
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

  /// Floating Action Button premium - Delegates to ComponentSystem
  static Widget premiumFAB({
    required VoidCallback onPressed,
    required Widget child,
    bool enableHaptics = true,
    bool enablePhysics = true,
    bool enableGlass = true,
    Color? color,
  }) {
    return PremiumUICoordinator.instance.premiumFAB(
      onPressed: onPressed,
      child: child,
      enableHaptics: enableHaptics,
      enablePhysics: enablePhysics,
      enableGlass: enableGlass,
      color: color,
    );
  }

  // ============ PREMIUM CARDS ============
  // Delegates to ComponentSystem for SOLID architecture

  /// Carte premium avec toutes les fonctionnalités - Delegates to ComponentSystem
  static Widget premiumCard({
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
    return PremiumUICoordinator.instance.premiumCard(
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

  // ============ PREMIUM MODALS ============
  // Delegates to ModalSystem for SOLID architecture

  /// Modal premium avec glassmorphisme et animations - Delegates to ModalSystem
  static Future<T?> showPremiumModal<T>({
    required BuildContext context,
    required Widget child,
    bool enableGlass = true,
    bool enablePhysics = true,
    bool enableHaptics = true,
    bool barrierDismissible = true,
  }) {
    return PremiumUICoordinator.instance.showPremiumModal<T>(
      context: context,
      child: child,
      enableGlass: enableGlass,
      enablePhysics: enablePhysics,
      enableHaptics: enableHaptics,
      barrierDismissible: barrierDismissible,
    );
  }

  /// Bottom sheet premium - Delegates to ModalSystem
  static Future<T?> showPremiumBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool enableGlass = true,
    bool enablePhysics = true,
    bool enableHaptics = true,
    double height = 400,
    bool enableDragHandle = true,
  }) {
    return PremiumUICoordinator.instance.showPremiumBottomSheet<T>(
      context: context,
      child: child,
      enableGlass: enableGlass,
      enablePhysics: enablePhysics,
      enableHaptics: enableHaptics,
      height: height,
      enableDragHandle: enableDragHandle,
    );
  }

  // ============ PREMIUM FEEDBACK ============
  // Delegates to FeedbackSystem for SOLID architecture

  /// Affiche un succès avec toutes les animations premium - Delegates to FeedbackSystem
  static void showPremiumSuccess({
    required BuildContext context,
    required String message,
    SuccessType type = SuccessType.standard,
    bool enableParticles = true,
    bool enableHaptics = true,
  }) {
    PremiumUICoordinator.instance.showPremiumSuccess(
      context: context,
      message: message,
      type: type,
      enableParticles: enableParticles,
      enableHaptics: enableHaptics,
    );
  }

  /// Affiche une erreur avec animations - Delegates to FeedbackSystem
  static void showPremiumError({
    required BuildContext context,
    required String message,
    bool enableHaptics = true,
  }) {
    PremiumUICoordinator.instance.showPremiumError(
      context: context,
      message: message,
      enableHaptics: enableHaptics,
    );
  }

  /// Affiche un avertissement avec animations - Delegates to FeedbackSystem
  static void showPremiumWarning({
    required BuildContext context,
    required String message,
    bool enableHaptics = true,
  }) {
    PremiumUICoordinator.instance.feedbackSystem.showWarning(
      context: context,
      message: message,
      enableHaptics: enableHaptics,
    );
  }

  // ============ PREMIUM LOADING ============
  // Delegates to ModalSystem for SOLID architecture

  /// Overlay de loading premium - Delegates to ModalSystem
  static OverlayEntry showPremiumLoading({
    required BuildContext context,
    String? message,
    bool enableGlass = true,
  }) {
    return PremiumUICoordinator.instance.showPremiumLoading(
      context: context,
      message: message,
      enableGlass: enableGlass,
    );
  }

  // ============ PREMIUM LIST ITEMS ============
  // Delegates to ComponentSystem for SOLID architecture

  /// Item de liste premium avec toutes les fonctionnalités - Delegates to ComponentSystem
  static Widget premiumListItem({
    required Widget child,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    List<Widget>? swipeActions,
    bool enableHaptics = true,
    bool enablePhysics = true,
    bool showLoading = false,
  }) {
    return PremiumUICoordinator.instance.componentSystem.createListItem(
      child: child,
      onTap: onTap,
      onLongPress: onLongPress,
      swipeActions: swipeActions,
      enableHaptics: enableHaptics,
      enablePhysics: enablePhysics,
      showLoading: showLoading,
    );
  }

  // ============ MÉTHODES PRIVÉES ============

  // ============ ADVANCED SYSTEM ACCESS ============
  // Direct access to specialized systems for advanced usage

  /// Get theme system for advanced theming operations
  static IPremiumThemeSystem get themeSystem => PremiumUICoordinator.instance.themeSystem;

  /// Get component system for advanced component creation
  static IPremiumComponentSystem get componentSystem => PremiumUICoordinator.instance.componentSystem;

  /// Get animation system for advanced animations
  static IPremiumAnimationSystem get animationSystem => PremiumUICoordinator.instance.animationSystem;

  /// Get layout system for responsive layouts
  static IPremiumLayoutSystem get layoutSystem => PremiumUICoordinator.instance.layoutSystem;

  /// Get modal system for advanced modal management
  static IPremiumModalSystem get modalSystem => PremiumUICoordinator.instance.modalSystem;

  /// Get feedback system for advanced user feedback
  static IPremiumFeedbackSystem get feedbackSystem => PremiumUICoordinator.instance.feedbackSystem;
}