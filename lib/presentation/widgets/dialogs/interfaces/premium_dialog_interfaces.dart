import 'package:flutter/material.dart';

/// Interface for animation management in premium dialogs
abstract class IPremiumLogoutAnimations {
  /// Initialize all animations with the given configuration
  void initializeAnimations({
    required TickerProvider vsync,
    required Duration animationDuration,
  });

  /// Start the entrance animation sequence
  void startEntranceAnimation({
    required bool respectReducedMotion,
    required bool disableAnimations,
  });

  /// Trigger success particle effects
  void triggerSuccessParticles();

  /// Execute exit animation sequence
  Future<void> exitWithAnimation({required bool shouldReduceMotion});

  /// Get the scale animation for UI components
  Animation<double> get scaleAnimation;

  /// Get the fade animation for UI components
  Animation<double> get fadeAnimation;

  /// Get the blur animation for backdrop effects
  Animation<double> get blurAnimation;

  /// Get the glow animation for premium effects
  Animation<double> get glowAnimation;

  /// Check if particles should be shown
  bool get showParticles;

  /// Dispose all animation controllers
  void dispose();
}

/// Interface for UI component building in premium dialogs
abstract class IPremiumLogoutDialogUI {
  /// Build the main glassmorphism dialog container
  Widget buildGlassmorphismDialog(BuildContext context);

  /// Build dialog with proper callback handling
  Widget buildDialogWithCallbacks(
    BuildContext context, {
    required VoidCallback onCancel,
    required VoidCallback onLogout,
    required VoidCallback onDataClear,
    required Animation<double> glowAnimation,
    required bool enablePhysicsAnimations,
    required bool shouldReduceMotion,
  });

  /// Build the premium header section with glow effects
  Widget buildPremiumHeader(
    BuildContext context,
    Animation<double> glowAnimation,
  );

  /// Build the main content section
  Widget buildMainContent(BuildContext context);

  /// Build the destructive option section
  Widget buildDestructiveOption(
    BuildContext context, {
    required VoidCallback onTap,
    required bool enablePhysicsAnimations,
    required bool shouldReduceMotion,
  });

  /// Build the premium action buttons
  Widget buildPremiumActions(
    BuildContext context, {
    required VoidCallback onCancel,
    required VoidCallback onLogout,
    required bool enablePhysicsAnimations,
    required bool shouldReduceMotion,
  });

  /// Build the cancel button
  Widget buildCancelButton(BuildContext context);

  /// Build the logout button
  Widget buildLogoutButton(BuildContext context);

  /// Build the confirmation dialog for data clearing
  Widget buildDataClearDialog(
    BuildContext context, {
    required VoidCallback onCancel,
    required VoidCallback onConfirm,
    required bool enablePhysicsAnimations,
  });
}

/// Interface for handling user interactions in premium dialogs
abstract class IPremiumLogoutInteractions {
  /// Handle cancel action with haptic feedback
  Future<void> handleCancel(
    BuildContext context, {
    required bool enableHaptics,
    required Future<void> Function() exitAnimation,
    required VoidCallback onComplete,
  });

  /// Handle logout action with haptic feedback
  Future<void> handleLogout(
    BuildContext context, {
    required bool enableHaptics,
    required VoidCallback triggerParticles,
    required Future<void> Function() exitAnimation,
    required VoidCallback onComplete,
  });

  /// Show data clear confirmation dialog
  Future<void> showDataClearConfirmation(
    BuildContext context, {
    required bool enableHaptics,
    required bool enablePhysicsAnimations,
    required bool respectReducedMotion,
    required Future<void> Function() exitAnimation,
    required VoidCallback onConfirmed,
  });

  /// Trigger initial haptic feedback when dialog opens
  Future<void> triggerInitialHapticFeedback({required bool enableHaptics});

  /// Check if animations should be reduced for accessibility
  bool shouldReduceMotion(BuildContext context, {required bool respectReducedMotion});
}

/// Configuration object for premium logout dialog
class PremiumLogoutDialogConfig {
  final bool enableHaptics;
  final bool enablePhysicsAnimations;
  final bool enableParticles;
  final bool respectReducedMotion;
  final Duration animationDuration;

  const PremiumLogoutDialogConfig({
    this.enableHaptics = true,
    this.enablePhysicsAnimations = true,
    this.enableParticles = true,
    this.respectReducedMotion = true,
    this.animationDuration = const Duration(milliseconds: 600),
  });
}