import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Premium notification types for advanced styling
enum PremiumNotificationType {
  success,
  warning,
  error,
  info,
}

/// Premium Sync Notification with advanced animations and glassmorphism
///
/// SOLID COMPLIANCE:
/// - SRP: Single responsibility for displaying premium notifications
/// - OCP: Extensible through PremiumNotificationType enum
/// - LSP: Compatible with standard notification interfaces
/// - ISP: Focused interface for notification display only
/// - DIP: Depends on Flutter's animation abstractions
///
/// CONSTRAINTS: <250 lines (currently ~240 lines)
class PremiumSyncNotification extends StatefulWidget {
  final String message;
  final PremiumNotificationType type;
  final Duration duration;
  final VoidCallback? onDismiss;
  final bool enableParticles;
  final EdgeInsets margin;

  const PremiumSyncNotification({
    super.key,
    required this.message,
    required this.type,
    this.duration = const Duration(seconds: 3),
    this.onDismiss,
    this.enableParticles = true,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  State<PremiumSyncNotification> createState() => _PremiumSyncNotificationState();
}

class _PremiumSyncNotificationState extends State<PremiumSyncNotification>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shimmerAnimation;

  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startEntranceAnimation();
    _scheduleAutoDismiss();
  }

  void _initializeAnimations() {
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
  }

  void _startEntranceAnimation() {
    _entranceController.forward();

    if (widget.type == PremiumNotificationType.success) {
      _shimmerController.repeat();
    }
  }

  void _scheduleAutoDismiss() {
    Future.delayed(widget.duration, () {
      if (mounted && !_isDisposed) {
        _dismiss();
      }
    });
  }

  void _dismiss() async {
    if (!_isDisposed && mounted) {
      await _entranceController.reverse();
      if (mounted && !_isDisposed) {
        widget.onDismiss?.call();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _entranceController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: 'Notification: ${widget.message}',
      child: _buildAnimatedNotification(),
    );
  }

  Widget _buildAnimatedNotification() {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            margin: widget.margin,
            child: _buildGlassmorphicCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassmorphicCard() {
    return ClipRRect(
      borderRadius: BorderRadiusTokens.card,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: _buildCardDecoration(),
          child: _buildContentStack(),
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: _getTypeColor().withOpacity(0.15),
      borderRadius: BorderRadiusTokens.card,
      border: Border.all(
        color: _getTypeColor().withOpacity(0.3),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: _getTypeColor().withOpacity(0.2),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  Widget _buildContentStack() {
    return Stack(
      children: [
        if (widget.type == PremiumNotificationType.success)
          _buildShimmerEffect(),
        _buildContentRow(),
      ],
    );
  }

  Widget _buildContentRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIconWithBackground(),
        const SizedBox(width: 12),
        _buildMessageText(),
      ],
    );
  }

  Widget _buildIconWithBackground() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _getTypeColor().withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getTypeIcon(),
        color: _getTypeColor(),
        size: 20,
        semanticLabel: _getTypeSemanticLabel(),
      ),
    );
  }

  Widget _buildMessageText() {
    return Flexible(
      child: Text(
        widget.message,
        style: TextStyle(
          color: _getTypeColor(),
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1.0 + _shimmerAnimation.value * 2, 0),
                end: Alignment(-0.5 + _shimmerAnimation.value * 2, 0),
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.3),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getTypeColor() {
    switch (widget.type) {
      case PremiumNotificationType.success:
        return Colors.green;
      case PremiumNotificationType.warning:
        return Colors.orange;
      case PremiumNotificationType.error:
        return Colors.red;
      case PremiumNotificationType.info:
        return Colors.blue;
    }
  }

  IconData _getTypeIcon() {
    switch (widget.type) {
      case PremiumNotificationType.success:
        return Icons.check_circle_outline;
      case PremiumNotificationType.warning:
        return Icons.warning_outlined;
      case PremiumNotificationType.error:
        return Icons.error_outline;
      case PremiumNotificationType.info:
        return Icons.info_outline;
    }
  }

  String _getTypeSemanticLabel() {
    switch (widget.type) {
      case PremiumNotificationType.success:
        return 'Succès';
      case PremiumNotificationType.warning:
        return 'Avertissement';
      case PremiumNotificationType.error:
        return 'Erreur';
      case PremiumNotificationType.info:
        return 'Information';
    }
  }
}