import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/animations/physics_animations.dart';
import 'package:prioris/presentation/animations/particle_effects.dart';
import 'package:prioris/presentation/services/premium_haptic_service.dart';
import 'package:prioris/presentation/widgets/indicators/sync_status_indicator.dart';
import 'package:prioris/presentation/widgets/indicators/services/premium_sync_style_service.dart';
import 'package:prioris/presentation/widgets/indicators/premium_sync_notification.dart';

// Export the extracted notification class for backward compatibility
export 'package:prioris/presentation/widgets/indicators/premium_sync_notification.dart';

/// Premium Sync Status Indicator with glassmorphism, micro-animations and advanced UX
///
/// SOLID COMPLIANCE:
/// - SRP: Single responsibility for sync status display
/// - OCP: Extensible through SyncDisplayStatus enum and services
/// - LSP: Compatible with standard indicator interfaces
/// - ISP: Focused interface for sync status visualization only
/// - DIP: Depends on PremiumSyncStyleService abstraction
///
/// Features:
/// - Glassmorphism design with adaptive blur intensity
/// - Physics-based micro-animations with spring curves
/// - Particle effects for status transitions
/// - Premium haptic feedback
/// - Accessibility-first design with reduced motion support
/// - Intelligent "invisible when working" principle
///
/// CONSTRAINTS: <300 lines (currently ~280 lines)
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

  // SOLID DIP: Dependency injection of style service
  final PremiumSyncStyleService _styleService = PremiumSyncStyleService.instance;

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
    // SOLID DIP: Use injected service for styling calculations
    final blurIntensity = _styleService.getAdaptiveBlurIntensity(widget.status, widget.adaptiveBlur);
    final glassOpacity = _styleService.getGlassOpacity(widget.status);

    return Semantics(
      liveRegion: widget.status == SyncDisplayStatus.syncing,
      label: _styleService.getAccessibilityLabel(widget.status, widget.message),
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
              color: _styleService.getGlassColor(context, widget.status).withOpacity(glassOpacity),
              borderRadius: BorderRadiusTokens.button,
              border: Border.all(
                color: _styleService.getBorderColor(context, widget.status),
                width: _styleService.getBorderWidth(widget.status),
              ),
              boxShadow: [
                BoxShadow(
                  color: _styleService.getShadowColor(context, widget.status),
                  blurRadius: _styleService.getShadowBlur(widget.status),
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
                        color: _styleService.getTextColor(context, widget.status),
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

  // === PRIVATE HELPER METHODS ===
  // Style methods now delegated to PremiumSyncStyleService (SOLID DIP)

  void _handleTap() async {
    if (widget.onTap != null) {
      // Premium haptic feedback
      await PremiumHapticService.instance.lightImpact();
      widget.onTap!();
    }
  }
}