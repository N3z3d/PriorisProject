import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/glassmorphism.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/services/premium_haptic_service.dart';

/// Floating Action Button Premium avec glassmorphisme et animations
/// 
/// Un bouton d'action flottant au design premium avec:
/// - Effet glassmorphisme
/// - Animations fluides au hover et tap  
/// - Support des états (normal, loading, disabled)
/// - Feedback haptique
/// - Design adapté aux écrans mobiles et desktop
class PremiumFAB extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isLoading;
  final bool enableAnimations;
  final bool enableHaptics;
  final String? heroTag;
  final double? elevation;

  const PremiumFAB({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.isLoading = false,
    this.enableAnimations = true,
    this.enableHaptics = true,
    this.heroTag,
    this.elevation = 8.0,
  });

  @override
  State<PremiumFAB> createState() => _PremiumFABState();
}

class _PremiumFABState extends State<PremiumFAB> 
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) async {
    if (widget.isLoading || widget.onPressed == null) return;
    
    setState(() {
      _isPressed = true;
    });
    
    if (widget.enableAnimations) {
      _scaleController.forward();
    }
    
    if (widget.enableHaptics) {
      await PremiumHapticService.instance.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isLoading || widget.onPressed == null) return;
    
    setState(() {
      _isPressed = false;
    });
    
    if (widget.enableAnimations) {
      _scaleController.reverse();
    }
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    
    if (widget.enableAnimations) {
      _scaleController.reverse();
    }
  }

  void _handleTap() async {
    if (widget.isLoading || widget.onPressed == null) return;
    
    if (widget.enableHaptics) {
      await PremiumHapticService.instance.mediumImpact();
    }
    
    widget.onPressed!();
  }

  void _handleHover(bool isHovering) {
    if (widget.isLoading || widget.onPressed == null) return;
    
    setState(() {
      _isHovered = isHovering;
    });
    
    if (widget.enableAnimations) {
      if (isHovering) {
        _glowController.forward();
      } else {
        _glowController.reverse();
      }
    }
  }

  Color get _backgroundColor {
    if (widget.onPressed == null) {
      return Colors.grey.withValues(alpha: 0.3);
    }
    return widget.backgroundColor ?? AppTheme.primaryColor;
  }

  Color get _foregroundColor {
    if (widget.onPressed == null) {
      return Colors.grey.withValues(alpha: 0.6);
    }
    return widget.foregroundColor ?? Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
          builder: (context, child) {
            return AnimatedScale(
              scale: widget.enableAnimations ? _scaleAnimation.value : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    // Glow effect
                    if (widget.enableAnimations && (_isHovered || _isPressed))
                      BoxShadow(
                        color: _backgroundColor.withValues(alpha: 0.4),
                        blurRadius: 20 * _glowAnimation.value,
                        spreadRadius: 5 * _glowAnimation.value,
                        offset: const Offset(0, 0),
                      ),
                    // Regular shadow
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: widget.elevation ?? 8.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      // Glassmorphism background
                      color: _backgroundColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.1),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.isLoading)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(_foregroundColor),
                            ),
                          )
                        else
                          Icon(
                            widget.icon,
                            color: _foregroundColor,
                            size: 20,
                          ),
                        const SizedBox(width: 8),
                        Text(
                          widget.text,
                          style: TextStyle(
                            color: _foregroundColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}