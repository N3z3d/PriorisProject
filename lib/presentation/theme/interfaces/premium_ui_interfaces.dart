import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/premium_skeletons.dart';

/// Base interface for all Premium UI systems following SOLID principles
abstract class IPremiumUISystem {
  Future<void> initialize();
  bool get isInitialized;
}

/// Interface for Premium Theme System - Handles colors, gradients, and theming
abstract class IPremiumThemeSystem extends IPremiumUISystem {
  // Color management
  Color getPrimaryColor(BuildContext context);
  Color getSecondaryColor(BuildContext context);
  Color getAccentColor(BuildContext context);
  Color getSurfaceColor(BuildContext context);
  Color getBackgroundColor(BuildContext context);

  // Gradient management
  LinearGradient getPrimaryGradient();
  LinearGradient getSecondaryGradient();
  LinearGradient getAccentGradient();

  // Shadow management
  List<BoxShadow> getPrimaryShadow();
  List<BoxShadow> getSecondaryShadow();
  List<BoxShadow> getElevatedShadow();

  // Button style helpers
  Color getButtonBackgroundColor(BuildContext context, PremiumButtonStyle style);
  Color getButtonForegroundColor(BuildContext context, PremiumButtonStyle style);
  Color getButtonShadowColor(BuildContext context, PremiumButtonStyle style);

  // Feedback color helpers
  Color getFeedbackColor(BuildContext context, FeedbackType type);
  IconData getFeedbackIcon(FeedbackType type);
}

/// Interface for Premium Component System - Handles UI component builders
abstract class IPremiumComponentSystem extends IPremiumUISystem {
  // Button components
  Widget createButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    PremiumButtonStyle style,
    ButtonSize size,
    bool enableHaptics,
    bool enablePhysics,
    bool enableGlass,
  });

  Widget createFAB({
    required VoidCallback onPressed,
    required Widget child,
    bool enableHaptics,
    bool enablePhysics,
    bool enableGlass,
    Color? color,
  });

  // Card components
  Widget createCard({
    required Widget child,
    VoidCallback? onTap,
    bool enableHaptics,
    bool enablePhysics,
    bool enableGlass,
    bool showLoading,
    SkeletonType skeletonType,
    EdgeInsets? padding,
    double? elevation,
  });

  // List components
  Widget createListItem({
    required Widget child,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    List<Widget>? swipeActions,
    bool enableHaptics,
    bool enablePhysics,
    bool showLoading,
  });
}

/// Interface for Premium Animation System - Handles animations and micro-interactions
abstract class IPremiumAnimationSystem extends IPremiumUISystem {
  // Physics animations
  Widget createSpringScale({
    required Widget child,
    VoidCallback? onTap,
    double scale,
    Duration duration,
  });

  Widget createElasticBounce({
    required Widget child,
    bool trigger,
    double elasticity,
    Duration duration,
  });

  Widget createGravityBounce({
    required Widget child,
    bool trigger,
    double gravity,
    Duration duration,
  });

  // Transition animations
  Widget createFadeTransition({
    required Widget child,
    bool trigger,
    Duration duration,
  });

  Widget createSlideTransition({
    required Widget child,
    bool trigger,
    Offset offset,
    Duration duration,
  });
}

/// Interface for Premium Layout System - Handles layout patterns and responsive design
abstract class IPremiumLayoutSystem extends IPremiumUISystem {
  // Responsive breakpoints
  bool isMobile(BuildContext context);
  bool isTablet(BuildContext context);
  bool isDesktop(BuildContext context);

  // Layout builders
  Widget createResponsiveLayout({
    required BuildContext context,
    Widget? mobile,
    Widget? tablet,
    Widget? desktop,
  });

  Widget createAdaptiveContainer({
    required Widget child,
    required BuildContext context,
    EdgeInsets? padding,
    double? maxWidth,
  });

  // Grid systems
  Widget createResponsiveGrid({
    required List<Widget> children,
    required BuildContext context,
    int? mobileColumns,
    int? tabletColumns,
    int? desktopColumns,
    double spacing,
  });
}

/// Interface for Premium Modal System - Handles modals and overlays
abstract class IPremiumModalSystem extends IPremiumUISystem {
  // Modal management
  Future<T?> showModal<T>({
    required BuildContext context,
    required Widget child,
    bool enableGlass,
    bool enablePhysics,
    bool enableHaptics,
    bool barrierDismissible,
  });

  Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool enableGlass,
    bool enablePhysics,
    bool enableHaptics,
    double height,
    bool enableDragHandle,
  });

  // Overlay management
  OverlayEntry showLoading({
    required BuildContext context,
    String? message,
    bool enableGlass,
  });

  void dismissLoading(OverlayEntry entry);
}

/// Interface for Premium Feedback System - Handles notifications and feedback
abstract class IPremiumFeedbackSystem extends IPremiumUISystem {
  // Feedback types
  void showSuccess({
    required BuildContext context,
    required String message,
    SuccessType type,
    bool enableParticles,
    bool enableHaptics,
  });

  void showError({
    required BuildContext context,
    required String message,
    bool enableHaptics,
  });

  void showWarning({
    required BuildContext context,
    required String message,
    bool enableHaptics,
  });

  void showInfo({
    required BuildContext context,
    required String message,
    bool enableHaptics,
  });
}

/// Main interface for Premium UI Coordinator - Coordinates all UI systems
abstract class IPremiumUICoordinator extends IPremiumUISystem {
  // System accessors
  IPremiumThemeSystem get themeSystem;
  IPremiumComponentSystem get componentSystem;
  IPremiumAnimationSystem get animationSystem;
  IPremiumLayoutSystem get layoutSystem;
  IPremiumModalSystem get modalSystem;
  IPremiumFeedbackSystem get feedbackSystem;

  // Factory methods for backward compatibility
  Widget premiumButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    PremiumButtonStyle style,
    ButtonSize size,
    bool enableHaptics,
    bool enablePhysics,
    bool enableGlass,
  });

  Widget premiumCard({
    required Widget child,
    VoidCallback? onTap,
    bool enableHaptics,
    bool enablePhysics,
    bool enableGlass,
    bool showLoading,
    SkeletonType skeletonType,
    EdgeInsets? padding,
    double? elevation,
  });

  Future<T?> showPremiumModal<T>({
    required BuildContext context,
    required Widget child,
    bool enableGlass,
    bool enablePhysics,
    bool enableHaptics,
    bool barrierDismissible,
  });
}

// ============ ENUMS AND TYPES ============

enum PremiumButtonStyle {
  primary,
  secondary,
  outline,
  text,
}

enum ButtonSize {
  small(28, 12, 6, 14, 16),
  medium(40, 20, 10, 16, 18),
  large(48, 24, 12, 18, 20);

  const ButtonSize(this.height, this.horizontalPadding, this.verticalPadding, this.fontSize, this.iconSize);

  final double height;
  final double horizontalPadding;
  final double verticalPadding;
  final double fontSize;
  final double iconSize;
}

enum FeedbackType {
  success,
  error,
  warning,
  info,
}

enum SuccessType {
  standard,
  major,
  milestone,
  favorite,
}