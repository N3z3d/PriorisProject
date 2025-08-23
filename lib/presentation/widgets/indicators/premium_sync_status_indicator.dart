import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prioris/presentation/theme/glassmorphism.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/animations/physics_animations.dart';
import 'package:prioris/presentation/animations/particle_effects.dart';
import 'package:prioris/presentation/services/premium_haptic_service.dart';
import 'package:prioris/presentation/widgets/indicators/sync_status_indicator.dart';

/// Premium notification types for advanced styling
enum PremiumNotificationType {
  success,
  warning,
  error,
  info,
}

/// Premium Sync Status Indicator with glassmorphism, micro-animations and advanced UX
/// 
/// Features:
/// - Glassmorphism design with adaptive blur intensity
/// - Physics-based micro-animations with spring curves
/// - Particle effects for status transitions
/// - Premium haptic feedback
/// - Accessibility-first design with reduced motion support
/// - Intelligent "invisible when working" principle
class PremiumSyncStatusIndicator extends StatefulWidget {
  final SyncDisplayStatus status;
  final String? message;
  final VoidCallback? onTap;
  final bool enableParticles;
  final bool enablePhysicsAnimations;
  final bool respectReducedMotion;
  final bool adaptiveBlur;
  final Duration animationDuration;

  const PremiumSyncStatusIndicator({
    super.key,
    required this.status,
    this.message,
    this.onTap,
    this.enableParticles = true,
    this.enablePhysicsAnimations = true,
    this.respectReducedMotion = true,
    this.adaptiveBlur = true,
    this.animationDuration = const Duration(milliseconds: 400),
  });

  @override
  State<PremiumSyncStatusIndicator> createState() => _PremiumSyncStatusIndicatorState();
}

class _PremiumSyncStatusIndicatorState extends State<PremiumSyncStatusIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _entranceController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _showParticles = false;
  SyncDisplayStatus? _previousStatus;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _previousStatus = widget.status;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startAppropriateAnimations();
  }

  void _initializeAnimations() {
    // Pulse animation for syncing status
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Glow animation for attention status
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Entrance animation
    _entranceController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
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
  }

  void _startAppropriateAnimations() {
    if (widget.status != SyncDisplayStatus.normal) {
      _entranceController.forward();
    }

    switch (widget.status) {
      case SyncDisplayStatus.syncing:
        if (widget.enablePhysicsAnimations && !_shouldReduceMotion()) {
          _pulseController.repeat(reverse: true);
        }
        break;
      case SyncDisplayStatus.attention:
        if (widget.enablePhysicsAnimations && !_shouldReduceMotion()) {
          _glowController.repeat(reverse: true);
        }
        break;
      case SyncDisplayStatus.merged:
        _triggerParticlesIfEnabled();
        break;
      default:
        break;
    }
  }

  void _triggerParticlesIfEnabled() {
    if (widget.enableParticles && 
        !_shouldReduceMotion() && 
        _previousStatus != SyncDisplayStatus.merged) {
      if (mounted) {
        setState(() {
          _showParticles = true;
        });
        
        // Reset particles after animation
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              _showParticles = false;
            });
          }
        });
      }
    }
  }

  bool _shouldReduceMotion() {
    return widget.respectReducedMotion && 
           MediaQuery.maybeOf(context)?.disableAnimations == true;
  }

  @override
  void didUpdateWidget(PremiumSyncStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.status != widget.status) {
      _handleStatusChange(oldWidget.status);
      _previousStatus = oldWidget.status;
    }
  }

  void _handleStatusChange(SyncDisplayStatus oldStatus) {
    // Stop previous animations
    _pulseController.stop();
    _glowController.stop();
    
    if (widget.status == SyncDisplayStatus.normal) {
      _entranceController.reverse();
    } else {
      _entranceController.forward();
      _startAppropriateAnimations();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Invisible when working principle
    if (widget.status == SyncDisplayStatus.normal) {
      return const SizedBox.shrink();
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Particle effects layer
        if (_showParticles)
          _buildParticleEffects(),
        
        // Main indicator
        _buildMainIndicator(context),
      ],
    );
  }

  Widget _buildParticleEffects() {
    switch (widget.status) {
      case SyncDisplayStatus.merged:
        return ParticleEffects.sparkleEffect(
          trigger: _showParticles,
          sparkleCount: 15,
          maxSize: 6.0,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMainIndicator(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _fadeAnimation,
        _pulseAnimation,
        _glowAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: _buildGlassmorphismContainer(context),
          ),
        );
      },
    );
  }

  Widget _buildGlassmorphismContainer(BuildContext context) {
    final blurIntensity = _getAdaptiveBlurIntensity();
    final glassOpacity = _getGlassOpacity();
    
    return Semantics(
      liveRegion: widget.status == SyncDisplayStatus.syncing,
      label: _getAccessibilityLabel(),
      hint: widget.onTap != null ? 'Appuyez pour plus de détails' : null,
      button: widget.onTap != null,
      child: GestureDetector(
        onTap: _handleTap,
        child: widget.enablePhysicsAnimations && !_shouldReduceMotion()
            ? PhysicsAnimations.springScale(
                onTap: _handleTap,
                scaleFactor: 0.95,
                springCurve: Curves.elasticOut,
                child: _buildGlassContent(context, blurIntensity, glassOpacity),
              )
            : _buildGlassContent(context, blurIntensity, glassOpacity),
      ),
    );
  }

  Widget _buildGlassContent(BuildContext context, double blurIntensity, double glassOpacity) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 44,
        minHeight: 44,
      ),
      child: ClipRRect(
        borderRadius: BorderRadiusTokens.button,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurIntensity,
            sigmaY: blurIntensity,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _getGlassColor().withOpacity(glassOpacity),
              borderRadius: BorderRadiusTokens.button,
              border: Border.all(
                color: _getBorderColor(),
                width: _getBorderWidth(),
              ),
              boxShadow: [
                BoxShadow(
                  color: _getShadowColor(),
                  blurRadius: _getShadowBlur(),
                  offset: const Offset(0, 2),
                ),
                if (widget.status == SyncDisplayStatus.attention)
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3 * _glowAnimation.value),
                    blurRadius: 12 * _glowAnimation.value,
                    spreadRadius: 4 * _glowAnimation.value,
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPremiumIcon(),
                if (widget.message != null) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.message!,
                      style: TextStyle(
                        fontSize: 13,
                        color: _getTextColor(),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumIcon() {
    switch (widget.status) {
      case SyncDisplayStatus.offline:
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        );

      case SyncDisplayStatus.syncing:
        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _shouldReduceMotion() ? 1.0 : _pulseAnimation.value,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.6),
                    ],
                  ),
                ),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            );
          },
        );

      case SyncDisplayStatus.merged:
        return Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.merge_type,
            size: 14,
            color: Colors.blue,
            semanticLabel: 'Données fusionnées automatiquement',
          ),
        );

      case SyncDisplayStatus.attention:
        return AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1 + 0.1 * _glowAnimation.value),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3 * _glowAnimation.value),
                    blurRadius: 8 * _glowAnimation.value,
                  ),
                ],
              ),
              child: Icon(
                Icons.warning_rounded,
                size: 14,
                color: Colors.red,
                semanticLabel: 'Attention requise pour la synchronisation',
              ),
            );
          },
        );

      case SyncDisplayStatus.normal:
        return const SizedBox.shrink();
    }
  }

  double _getAdaptiveBlurIntensity() {
    if (!widget.adaptiveBlur) return 8.0;
    
    switch (widget.status) {
      case SyncDisplayStatus.offline:
        return 6.0;
      case SyncDisplayStatus.syncing:
        return 10.0;
      case SyncDisplayStatus.merged:
        return 8.0;
      case SyncDisplayStatus.attention:
        return 12.0;
      case SyncDisplayStatus.normal:
        return 0.0;
    }
  }

  double _getGlassOpacity() {
    switch (widget.status) {
      case SyncDisplayStatus.offline:
        return 0.15;
      case SyncDisplayStatus.syncing:
        return 0.18;
      case SyncDisplayStatus.merged:
        return 0.12;
      case SyncDisplayStatus.attention:
        return 0.20;
      case SyncDisplayStatus.normal:
        return 0.0;
    }
  }

  Color _getGlassColor() {
    switch (widget.status) {
      case SyncDisplayStatus.offline:
        return Colors.orange;
      case SyncDisplayStatus.syncing:
        return Theme.of(context).primaryColor;
      case SyncDisplayStatus.merged:
        return Colors.blue;
      case SyncDisplayStatus.attention:
        return Colors.red;
      case SyncDisplayStatus.normal:
        return Colors.transparent;
    }
  }

  Color _getBorderColor() {
    return _getGlassColor().withOpacity(0.3);
  }

  double _getBorderWidth() {
    return widget.status == SyncDisplayStatus.attention ? 1.5 : 1.0;
  }

  Color _getShadowColor() {
    return _getGlassColor().withOpacity(0.2);
  }

  double _getShadowBlur() {
    switch (widget.status) {
      case SyncDisplayStatus.attention:
        return 16.0;
      case SyncDisplayStatus.syncing:
        return 12.0;
      default:
        return 8.0;
    }
  }

  Color _getTextColor() {
    return _getGlassColor();
  }

  void _handleTap() async {
    if (widget.onTap != null) {
      // Premium haptic feedback
      await PremiumHapticService.instance.lightImpact();
      widget.onTap!();
    }
  }

  String _getAccessibilityLabel() {
    final baseMessage = widget.message ?? '';
    
    switch (widget.status) {
      case SyncDisplayStatus.offline:
        return 'Statut de synchronisation: Mode hors ligne. ${baseMessage.isNotEmpty ? baseMessage : 'Les données sont disponibles localement'}';
      case SyncDisplayStatus.syncing:
        return 'Statut de synchronisation: Synchronisation en cours. ${baseMessage.isNotEmpty ? baseMessage : 'Veuillez patienter'}';
      case SyncDisplayStatus.merged:
        return 'Statut de synchronisation: Données fusionnées avec succès. ${baseMessage.isNotEmpty ? baseMessage : 'Toutes vos données sont à jour'}';
      case SyncDisplayStatus.attention:
        return 'Statut de synchronisation: Attention requise. ${baseMessage.isNotEmpty ? baseMessage : 'Vérifiez votre connexion'}';
      case SyncDisplayStatus.normal:
        return 'Synchronisation normale, aucune action requise';
    }
  }
}

/// Premium Sync Notification with advanced animations and glassmorphism
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
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: widget.margin,
              child: ClipRRect(
                borderRadius: BorderRadiusTokens.card,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
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
                    ),
                    child: Stack(
                      children: [
                        // Shimmer effect for success
                        if (widget.type == PremiumNotificationType.success)
                          _buildShimmerEffect(),
                        
                        // Content
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
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
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                widget.message,
                                style: TextStyle(
                                  color: _getTypeColor(),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
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