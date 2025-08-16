import 'package:flutter/material.dart';
import 'package:prioris/presentation/animations/physics_animations.dart';
import 'package:prioris/presentation/animations/particle_effects.dart';
import 'package:prioris/presentation/theme/glassmorphism.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/loading/premium_skeletons.dart';
import 'package:prioris/presentation/services/premium_haptic_service.dart';

/// Système UI Premium unifié qui combine tous les éléments haut de gamme
class PremiumUISystem {
  static PremiumUISystem? _instance;
  static PremiumUISystem get instance => _instance ??= PremiumUISystem._();
  
  PremiumUISystem._();

  // ============ INITIALIZATION ============

  /// Initialise tous les services premium
  static Future<void> initialize() async {
    await PremiumHapticService.instance.initialize();
  }

  // ============ PREMIUM BUTTONS ============

  /// Bouton premium avec toutes les fonctionnalités
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
    return _PremiumButton(
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

  /// Floating Action Button premium
  static Widget premiumFAB({
    required VoidCallback onPressed,
    required Widget child,
    bool enableHaptics = true,
    bool enablePhysics = true,
    bool enableGlass = true,
    Color? color,
  }) {
    return _PremiumFAB(
      onPressed: onPressed,
      enableHaptics: enableHaptics,
      enablePhysics: enablePhysics,
      enableGlass: enableGlass,
      color: color,
      child: child,
    );
  }

  // ============ PREMIUM CARDS ============

  /// Carte premium avec toutes les fonctionnalités
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
    return _PremiumCard(
      onTap: onTap,
      enableHaptics: enableHaptics,
      enablePhysics: enablePhysics,
      enableGlass: enableGlass,
      showLoading: showLoading,
      skeletonType: skeletonType,
      padding: padding,
      elevation: elevation,
      child: child,
    );
  }

  // ============ PREMIUM MODALS ============

  /// Modal premium avec glassmorphisme et animations
  static Future<T?> showPremiumModal<T>({
    required BuildContext context,
    required Widget child,
    bool enableGlass = true,
    bool enablePhysics = true,
    bool enableHaptics = true,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.transparent,
      builder: (context) => _PremiumModal(
        enableGlass: enableGlass,
        enablePhysics: enablePhysics,
        enableHaptics: enableHaptics,
        onDismiss: barrierDismissible ? () => Navigator.of(context).pop() : null,
        child: child,
      ),
    );
  }

  /// Bottom sheet premium
  static Future<T?> showPremiumBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool enableGlass = true,
    bool enablePhysics = true,
    bool enableHaptics = true,
    double height = 400,
    bool enableDragHandle = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _PremiumBottomSheet(
        height: height,
        enableGlass: enableGlass,
        enablePhysics: enablePhysics,
        enableHaptics: enableHaptics,
        enableDragHandle: enableDragHandle,
        child: child,
      ),
    );
  }

  // ============ PREMIUM FEEDBACK ============

  /// Affiche un succès avec toutes les animations premium
  static void showPremiumSuccess({
    required BuildContext context,
    required String message,
    SuccessType type = SuccessType.standard,
    bool enableParticles = true,
    bool enableHaptics = true,
  }) {
    _showPremiumFeedback(
      context: context,
      message: message,
      feedbackType: FeedbackType.success,
      successType: type,
      enableParticles: enableParticles,
      enableHaptics: enableHaptics,
    );
  }

  /// Affiche une erreur avec animations
  static void showPremiumError({
    required BuildContext context,
    required String message,
    bool enableHaptics = true,
  }) {
    _showPremiumFeedback(
      context: context,
      message: message,
      feedbackType: FeedbackType.error,
      enableHaptics: enableHaptics,
    );
  }

  /// Affiche un avertissement avec animations
  static void showPremiumWarning({
    required BuildContext context,
    required String message,
    bool enableHaptics = true,
  }) {
    _showPremiumFeedback(
      context: context,
      message: message,
      feedbackType: FeedbackType.warning,
      enableHaptics: enableHaptics,
    );
  }

  // ============ PREMIUM LOADING ============

  /// Overlay de loading premium
  static OverlayEntry showPremiumLoading({
    required BuildContext context,
    String? message,
    bool enableGlass = true,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (context) => _PremiumLoadingOverlay(
        message: message,
        enableGlass: enableGlass,
        onDismiss: () => entry.remove(),
      ),
    );
    
    overlay.insert(entry);
    return entry;
  }

  // ============ PREMIUM LIST ITEMS ============

  /// Item de liste premium avec toutes les fonctionnalités
  static Widget premiumListItem({
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
      child: child,
    );
  }

  // ============ MÉTHODES PRIVÉES ============

  static void _showPremiumFeedback({
    required BuildContext context,
    required String message,
    required FeedbackType feedbackType,
    SuccessType? successType,
    bool enableParticles = false,
    bool enableHaptics = true,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (context) => _PremiumFeedbackOverlay(
        message: message,
        feedbackType: feedbackType,
        successType: successType,
        enableParticles: enableParticles,
        enableHaptics: enableHaptics,
        onDismiss: () => entry.remove(),
      ),
    );
    
    overlay.insert(entry);
    
    // Auto-dismiss après quelques secondes
    Future.delayed(const Duration(seconds: 3), () {
      entry.remove();
    });
  }
}

// ============ WIDGETS INTERNES ============

/// Bouton premium interne
class _PremiumButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final PremiumButtonStyle style;
  final ButtonSize size;
  final bool enableHaptics;
  final bool enablePhysics;
  final bool enableGlass;

  const _PremiumButton({
    required this.text,
    required this.onPressed,
    this.icon,
    required this.style,
    required this.size,
    required this.enableHaptics,
    required this.enablePhysics,
    required this.enableGlass,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      height: size.height,
      padding: EdgeInsets.symmetric(
        horizontal: size.horizontalPadding,
        vertical: size.verticalPadding,
      ),
      decoration: BoxDecoration(
        color: style.backgroundColor(context),
        borderRadius: BorderRadiusTokens.button,
        boxShadow: [
          BoxShadow(
            color: style.shadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: style.foregroundColor(context),
              size: size.iconSize,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              color: style.foregroundColor(context),
              fontSize: size.fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if (enableGlass) {
      button = Glassmorphism.glassButton(
        onPressed: onPressed,
        child: button,
      );
    }

    if (enablePhysics) {
      button = PhysicsAnimations.springScale(
        onTap: () async {
          if (enableHaptics) {
            await PremiumHapticService.instance.mediumImpact();
          }
          onPressed();
        },
        child: button,
      );
    } else {
      button = GestureDetector(
        onTap: () async {
          if (enableHaptics) {
            await PremiumHapticService.instance.mediumImpact();
          }
          onPressed();
        },
        child: button,
      );
    }

    return button;
  }
}

/// FAB premium interne
class _PremiumFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final bool enableHaptics;
  final bool enablePhysics;
  final bool enableGlass;
  final Color? color;

  const _PremiumFAB({
    required this.onPressed,
    required this.child,
    required this.enableHaptics,
    required this.enablePhysics,
    required this.enableGlass,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    Widget fab = FloatingActionButton(
      onPressed: () async {
        if (enableHaptics) {
          await PremiumHapticService.instance.heavyImpact();
        }
        onPressed();
      },
      backgroundColor: color ?? Theme.of(context).primaryColor,
      child: child,
    );

    if (enableGlass) {
      fab = Glassmorphism.glassFAB(
        onPressed: onPressed,
        backgroundColor: color ?? Theme.of(context).primaryColor,
        child: child,
      );
    }

    if (enablePhysics) {
      fab = PhysicsAnimations.elasticBounce(
        trigger: false, // Géré par le tap
        child: fab,
      );
    }

    return fab;
  }
}

/// Carte premium interne
class _PremiumCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool enableHaptics;
  final bool enablePhysics;
  final bool enableGlass;
  final bool showLoading;
  final SkeletonType skeletonType;
  final EdgeInsets? padding;
  final double? elevation;

  const _PremiumCard({
    required this.child,
    this.onTap,
    required this.enableHaptics,
    required this.enablePhysics,
    required this.enableGlass,
    required this.showLoading,
    required this.skeletonType,
    this.padding,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadiusTokens.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: elevation ?? 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AdaptiveSkeletonLoader(
        isLoading: showLoading,
        skeletonType: skeletonType,
        child: child,
      ),
    );

    if (enableGlass) {
      card = Glassmorphism.glassCard(
        child: card,
      );
    }

    if (onTap != null) {
      if (enablePhysics) {
        card = PhysicsAnimations.springScale(
          onTap: () async {
            if (enableHaptics) {
              await PremiumHapticService.instance.lightImpact();
            }
            onTap!();
          },
          child: card,
        );
      } else {
        card = GestureDetector(
          onTap: () async {
            if (enableHaptics) {
              await PremiumHapticService.instance.lightImpact();
            }
            onTap!();
          },
          child: card,
        );
      }
    }

    return card;
  }
}

/// Modal premium interne
class _PremiumModal extends StatefulWidget {
  final Widget child;
  final bool enableGlass;
  final bool enablePhysics;
  final bool enableHaptics;
  final VoidCallback? onDismiss;

  const _PremiumModal({
    required this.child,
    required this.enableGlass,
    required this.enablePhysics,
    required this.enableHaptics,
    this.onDismiss,
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
        onDismiss: widget.onDismiss,
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

/// Bottom sheet premium interne
class _PremiumBottomSheet extends StatefulWidget {
  final Widget child;
  final double height;
  final bool enableGlass;
  final bool enablePhysics;
  final bool enableHaptics;
  final bool enableDragHandle;

  const _PremiumBottomSheet({
    required this.child,
    required this.height,
    required this.enableGlass,
    required this.enablePhysics,
    required this.enableHaptics,
    required this.enableDragHandle,
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
    }

    return bottomSheet;
  }
}

/// Overlay de feedback premium
class _PremiumFeedbackOverlay extends StatefulWidget {
  final String message;
  final FeedbackType feedbackType;
  final SuccessType? successType;
  final bool enableParticles;
  final bool enableHaptics;
  final VoidCallback onDismiss;

  const _PremiumFeedbackOverlay({
    required this.message,
    required this.feedbackType,
    this.successType,
    required this.enableParticles,
    required this.enableHaptics,
    required this.onDismiss,
  });

  @override
  State<_PremiumFeedbackOverlay> createState() => _PremiumFeedbackOverlayState();
}

class _PremiumFeedbackOverlayState extends State<_PremiumFeedbackOverlay> {
  bool _showParticles = false;

  @override
  void initState() {
    super.initState();
    _initializeFeedback();
  }

  void _initializeFeedback() async {
    if (widget.enableHaptics) {
      switch (widget.feedbackType) {
        case FeedbackType.success:
          await PremiumHapticService.instance.success();
          break;
        case FeedbackType.error:
          await PremiumHapticService.instance.error();
          break;
        case FeedbackType.warning:
          await PremiumHapticService.instance.warning();
          break;
      }
    }

    if (widget.enableParticles && widget.feedbackType == FeedbackType.success) {
      setState(() {
        _showParticles = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Feedback message
        Glassmorphism.glassToast(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getIconForFeedbackType(),
                color: _getColorForFeedbackType(context),
              ),
              const SizedBox(width: 12),
              Text(
                widget.message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _getColorForFeedbackType(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        // Particle effects
        if (_showParticles && widget.successType != null)
          _buildParticleEffect(),
      ],
    );
  }

  Widget _buildParticleEffect() {
    switch (widget.successType!) {
      case SuccessType.standard:
        return ParticleEffects.sparkleEffect(trigger: _showParticles);
      case SuccessType.major:
        return ParticleEffects.confettiExplosion(trigger: _showParticles);
      case SuccessType.milestone:
        return ParticleEffects.fireworksEffect(trigger: _showParticles);
      case SuccessType.favorite:
        return ParticleEffects.floatingHearts(trigger: _showParticles);
    }
  }

  IconData _getIconForFeedbackType() {
    switch (widget.feedbackType) {
      case FeedbackType.success:
        return Icons.check_circle;
      case FeedbackType.error:
        return Icons.error;
      case FeedbackType.warning:
        return Icons.warning;
    }
  }

  Color _getColorForFeedbackType(BuildContext context) {
    switch (widget.feedbackType) {
      case FeedbackType.success:
        return Colors.green;
      case FeedbackType.error:
        return Theme.of(context).colorScheme.error;
      case FeedbackType.warning:
        return Colors.orange;
    }
  }
}

/// Overlay de loading premium
class _PremiumLoadingOverlay extends StatelessWidget {
  final String? message;
  final bool enableGlass;
  final VoidCallback onDismiss;

  const _PremiumLoadingOverlay({
    this.message,
    required this.enableGlass,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    Widget loading = Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
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
    }

    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(child: loading),
    );
  }
}

/// Item de liste premium
class _PremiumListItem extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final List<Widget>? swipeActions;
  final bool enableHaptics;
  final bool enablePhysics;
  final bool showLoading;

  const _PremiumListItem({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.swipeActions,
    required this.enableHaptics,
    required this.enablePhysics,
    required this.showLoading,
  });

  @override
  Widget build(BuildContext context) {
    Widget item = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadiusTokens.card,
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: AdaptiveSkeletonLoader(
        isLoading: showLoading,
        skeletonType: SkeletonType.list,
        child: child,
      ),
    );

    if (onTap != null || onLongPress != null) {
      if (enablePhysics) {
        item = PhysicsAnimations.springScale(
          onTap: () async {
            if (enableHaptics) {
              await PremiumHapticService.instance.lightImpact();
            }
            onTap?.call();
          },
          child: item,
        );
      } else {
        item = GestureDetector(
          onTap: () async {
            if (enableHaptics) {
              await PremiumHapticService.instance.lightImpact();
            }
            onTap?.call();
          },
          onLongPress: () async {
            if (enableHaptics) {
              await PremiumHapticService.instance.heavyImpact();
            }
            onLongPress?.call();
          },
          child: item,
        );
      }
    }

    // TODO: Ajouter support pour swipe actions si nécessaire

    return item;
  }
}

// ============ ENUMS ET TYPES ============

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
}

enum SuccessType {
  standard,
  major,
  milestone,
  favorite,
}

// ============ EXTENSIONS ============

extension PremiumButtonStyleExtension on PremiumButtonStyle {
  Color backgroundColor(BuildContext context) {
    switch (this) {
      case PremiumButtonStyle.primary:
        return Theme.of(context).primaryColor;
      case PremiumButtonStyle.secondary:
        return Theme.of(context).colorScheme.secondary;
      case PremiumButtonStyle.outline:
        return Colors.transparent;
      case PremiumButtonStyle.text:
        return Colors.transparent;
    }
  }

  Color foregroundColor(BuildContext context) {
    switch (this) {
      case PremiumButtonStyle.primary:
        return Theme.of(context).colorScheme.onPrimary;
      case PremiumButtonStyle.secondary:
        return Theme.of(context).colorScheme.onSecondary;
      case PremiumButtonStyle.outline:
        return Theme.of(context).primaryColor;
      case PremiumButtonStyle.text:
        return Theme.of(context).primaryColor;
    }
  }

  Color shadowColor(BuildContext context) {
    switch (this) {
      case PremiumButtonStyle.primary:
        return Theme.of(context).primaryColor.withValues(alpha: 0.3);
      case PremiumButtonStyle.secondary:
        return Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3);
      case PremiumButtonStyle.outline:
        return Colors.black.withValues(alpha: 0.1);
      case PremiumButtonStyle.text:
        return Colors.transparent;
    }
  }
}