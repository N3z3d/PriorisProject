import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/interfaces/premium_ui_interfaces.dart';
import 'package:prioris/presentation/theme/glassmorphism.dart';
import 'package:prioris/presentation/animations/particle_effects.dart';
import 'package:prioris/presentation/services/premium_haptic_service.dart';

/// Premium Feedback System - Handles notifications and feedback following SRP
/// Responsibility: All user feedback including success, error, warning, and info messages
class PremiumFeedbackSystem implements IPremiumFeedbackSystem {
  final IPremiumThemeSystem _themeSystem;
  final IPremiumAnimationSystem _animationSystem;
  bool _isInitialized = false;

  PremiumFeedbackSystem(this._themeSystem, this._animationSystem);

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

  // ============ FEEDBACK METHODS ============

  @override
  void showSuccess({
    required BuildContext context,
    required String message,
    SuccessType type = SuccessType.standard,
    bool enableParticles = true,
    bool enableHaptics = true,
  }) {
    _ensureInitialized();

    _showFeedback(
      context: context,
      message: message,
      feedbackType: FeedbackType.success,
      successType: type,
      enableParticles: enableParticles,
      enableHaptics: enableHaptics,
    );
  }

  @override
  void showError({
    required BuildContext context,
    required String message,
    bool enableHaptics = true,
  }) {
    _ensureInitialized();

    _showFeedback(
      context: context,
      message: message,
      feedbackType: FeedbackType.error,
      enableHaptics: enableHaptics,
    );
  }

  @override
  void showWarning({
    required BuildContext context,
    required String message,
    bool enableHaptics = true,
  }) {
    _ensureInitialized();

    _showFeedback(
      context: context,
      message: message,
      feedbackType: FeedbackType.warning,
      enableHaptics: enableHaptics,
    );
  }

  @override
  void showInfo({
    required BuildContext context,
    required String message,
    bool enableHaptics = true,
  }) {
    _ensureInitialized();

    _showFeedback(
      context: context,
      message: message,
      feedbackType: FeedbackType.info,
      enableHaptics: enableHaptics,
    );
  }

  // ============ ADVANCED FEEDBACK METHODS ============

  /// Shows a toast notification
  void showToast({
    required BuildContext context,
    required String message,
    FeedbackType type = FeedbackType.info,
    Duration duration = const Duration(seconds: 3),
    ToastPosition position = ToastPosition.bottom,
  }) {
    _ensureInitialized();

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _PremiumToast(
        message: message,
        feedbackType: type,
        position: position,
        onDismiss: () => entry.remove(),
        themeSystem: _themeSystem,
      ),
    );

    overlay.insert(entry);

    // Auto-dismiss after duration
    Future.delayed(duration, () {
      entry.remove();
    });
  }

  /// Shows a snackbar with premium styling
  void showSnackbar({
    required BuildContext context,
    required String message,
    FeedbackType type = FeedbackType.info,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _ensureInitialized();

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            _themeSystem.getFeedbackIcon(type),
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: _themeSystem.getFeedbackColor(context, type),
      duration: duration,
      action: actionLabel != null && onAction != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onAction,
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // ============ PRIVATE METHODS ============

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('PremiumFeedbackSystem must be initialized before use.');
    }
  }

  void _showFeedback({
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
        themeSystem: _themeSystem,
        animationSystem: _animationSystem,
      ),
    );

    overlay.insert(entry);

    // Auto-dismiss after duration
    Future.delayed(const Duration(seconds: 3), () {
      entry.remove();
    });
  }
}

// ============ INTERNAL FEEDBACK WIDGETS ============

/// Internal feedback overlay widget
class _PremiumFeedbackOverlay extends StatefulWidget {
  final String message;
  final FeedbackType feedbackType;
  final SuccessType? successType;
  final bool enableParticles;
  final bool enableHaptics;
  final VoidCallback onDismiss;
  final IPremiumThemeSystem themeSystem;
  final IPremiumAnimationSystem animationSystem;

  const _PremiumFeedbackOverlay({
    required this.message,
    required this.feedbackType,
    this.successType,
    required this.enableParticles,
    required this.enableHaptics,
    required this.onDismiss,
    required this.themeSystem,
    required this.animationSystem,
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
        case FeedbackType.info:
          await PremiumHapticService.instance.lightImpact();
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
        Center(
          child: widget.animationSystem.createFadeTransition(
            trigger: true,
            child: Glassmorphism.glassToast(
              position: ToastPosition.top,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.themeSystem.getFeedbackIcon(widget.feedbackType),
                    color: widget.themeSystem.getFeedbackColor(context, widget.feedbackType),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      widget.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: widget.themeSystem.getFeedbackColor(context, widget.feedbackType),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
}

/// Internal toast widget
class _PremiumToast extends StatelessWidget {
  final String message;
  final FeedbackType feedbackType;
  final ToastPosition position;
  final VoidCallback onDismiss;
  final IPremiumThemeSystem themeSystem;

  const _PremiumToast({
    required this.message,
    required this.feedbackType,
    required this.position,
    required this.onDismiss,
    required this.themeSystem,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: position == ToastPosition.top ? 80 : null,
      bottom: position == ToastPosition.bottom ? 80 : null,
      left: 16,
      right: 16,
      child: Glassmorphism.glassToast(
        position: position,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              themeSystem.getFeedbackIcon(feedbackType),
              color: themeSystem.getFeedbackColor(context, feedbackType),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: themeSystem.getFeedbackColor(context, feedbackType),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: onDismiss,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal progress indicator widget
class _ProgressIndicator extends StatefulWidget {
  final String message;
  final bool enableGlass;
  final IPremiumThemeSystem themeSystem;

  const _ProgressIndicator({
    required this.message,
    required this.enableGlass,
    required this.themeSystem,
  });

  @override
  State<_ProgressIndicator> createState() => _ProgressIndicatorState();
}

class _ProgressIndicatorState extends State<_ProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CircularProgressIndicator(
                value: _controller.value,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.themeSystem.getPrimaryColor(context),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            widget.message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: widget.themeSystem.getPrimaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    if (widget.enableGlass) {
      return Glassmorphism.glassCard(child: content);
    } else {
      return Container(
        decoration: BoxDecoration(
          color: widget.themeSystem.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: widget.themeSystem.getElevatedShadow(),
        ),
        child: content,
      );
    }
  }
}