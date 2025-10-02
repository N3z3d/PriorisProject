import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Premium Floating Action Button with Material Design elegance and sophisticated animations
class PremiumFAB extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isLoading;
  final String? heroTag;
  final double? elevation;
  final String? contextualText;
  final bool enableHaptics;
  final bool enableAnimations;

  const PremiumFAB({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.isLoading = false,
    this.heroTag,
    this.elevation = 6.0,
    this.contextualText,
    this.enableHaptics = true,
    this.enableAnimations = true,
  });

  @override
  State<PremiumFAB> createState() => _PremiumFABState();
}

class _PremiumFABState extends State<PremiumFAB>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _glowAnimation;
  late Animation<Offset> _shimmerOffset;
  
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Scale animation for press/hover effects
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // Shimmer effect animation
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
    _shimmerOffset = Tween<Offset>(
      begin: const Offset(-1.5, 0),
      end: const Offset(1.5, 0),
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    // Glow animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    if (widget.enableAnimations) {
      _startIdleAnimations();
    }
  }

  void _startIdleAnimations() {
    // CORRECTION: Vérifier que le controller n'est pas disposé
    if (!mounted) return;
    
    // Subtle glow animation loop
    if (!_glowController.isAnimating) {
      _glowController.repeat(reverse: true);
    }
    
    // Occasional shimmer effect
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_isPressed) {
        try {
          _shimmerController.forward().then((_) {
            if (mounted) {
              _shimmerController.reset();
              Future.delayed(const Duration(seconds: 8), () {
                if (mounted) _startIdleAnimations();
              });
            }
          });
        } catch (e) {
          // Controller déjà disposé, ignorer
        }
      }
    });
  }

  @override
  void dispose() {
    // CORRECTION: Arrêter les animations avant de disposer
    try {
      if (_glowController.isAnimating) {
        _glowController.stop();
      }
      if (_shimmerController.isAnimating) {
        _shimmerController.stop();
      }
      if (_scaleController.isAnimating) {
        _scaleController.stop();
      }
    } catch (e) {
      // Ignorer les erreurs si déjà disposé
    }
    
    _scaleController.dispose();
    _shimmerController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Color get _backgroundColor {
    if (widget.onPressed == null) {
      return Colors.grey;
    }
    return widget.backgroundColor ?? AppTheme.primaryColor;
  }

  Color get _foregroundColor {
    if (widget.onPressed == null) {
      return Colors.grey.shade600;
    }
    return widget.foregroundColor ?? Colors.white;
  }

  String get _displayText {
    return widget.contextualText ?? widget.text;
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    if (widget.enableAnimations) {
      _scaleController.forward();
    }
    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    if (widget.enableAnimations) {
      _scaleController.reverse();
    }
    if (widget.onPressed != null) {
      widget.onPressed!();
      if (widget.enableHaptics) {
        HapticFeedback.selectionClick();
      }
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

  void _handleHoverEnter(PointerEnterEvent event) {
    setState(() {
      _isHovered = true;
    });
  }

  void _handleHoverExit(PointerExitEvent event) {
    setState(() {
      _isHovered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.heroTag ?? 'premium_fab',
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _scaleAnimation,
          _glowAnimation,
          _shimmerAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: widget.enableAnimations ? _scaleAnimation.value : 1.0,
            child: MouseRegion(
              onEnter: _handleHoverEnter,
              onExit: _handleHoverExit,
              child: GestureDetector(
                onTapDown: widget.isLoading ? null : _handleTapDown,
                onTapUp: widget.isLoading ? null : _handleTapUp,
                onTapCancel: _handleTapCancel,
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 56,
                    minWidth: 120,
                  ),
                  child: Stack(
                    children: [
                      if (widget.enableAnimations) _buildGlowEffectLayer(),
                      _buildPremiumMaterialButton(),
                      if (widget.enableAnimations && _shimmerAnimation.value > 0)
                        _buildShimmerOverlay(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build animated glow effect layer behind the button
  Widget _buildGlowEffectLayer() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadiusTokens.radiusXl,
          boxShadow: [
            BoxShadow(
              color: _backgroundColor.withValues(alpha: _glowAnimation.value * 0.3),
              blurRadius: 20 * _glowAnimation.value,
              spreadRadius: 2 * _glowAnimation.value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumMaterialButton() {
    return Container(
      decoration: _buildOuterDecoration(),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: _buildInnerDecoration(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: _buildButtonContent(),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildOuterDecoration() {
    final baseColor = _backgroundColor;
    final isInteractive = widget.onPressed != null;

    return BoxDecoration(
      gradient: _buildButtonGradient(baseColor, isInteractive),
      borderRadius: BorderRadiusTokens.radiusXl,
      border: _buildButtonBorder(isInteractive),
      boxShadow: _buildButtonBoxShadows(baseColor, isInteractive),
    );
  }

  LinearGradient _buildButtonGradient(Color baseColor, bool isInteractive) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: _isPressed
          ? [
              baseColor.withValues(alpha: 0.85),
              baseColor.withValues(alpha: 0.95),
            ]
          : _isHovered && isInteractive
              ? [
                  baseColor.withValues(alpha: 0.95),
                  baseColor,
                ]
              : [
                  baseColor.withValues(alpha: 0.9),
                  baseColor.withValues(alpha: 0.95),
                ],
    );
  }

  Border _buildButtonBorder(bool isInteractive) {
    return Border.all(
      color: _isHovered && isInteractive
          ? Colors.white.withValues(alpha: 0.4)
          : Colors.white.withValues(alpha: 0.2),
      width: _isPressed ? 1.0 : 1.5,
    );
  }

  List<BoxShadow> _buildButtonBoxShadows(Color baseColor, bool isInteractive) {
    return [
      // Primary elevated shadow
      BoxShadow(
        color: baseColor.withValues(
          alpha: _isPressed ? 0.1 : (_isHovered && isInteractive ? 0.25 : 0.18),
        ),
        blurRadius: _isPressed ? 8 : (_isHovered && isInteractive ? 20 : 15),
        offset: _isPressed
            ? const Offset(0, 4)
            : (_isHovered && isInteractive
                ? const Offset(0, 12)
                : const Offset(0, 8)),
        spreadRadius: _isPressed ? -1 : -2,
      ),
      // Secondary depth shadow
      BoxShadow(
        color: Colors.black.withValues(
          alpha: _isPressed ? 0.08 : (_isHovered && isInteractive ? 0.12 : 0.06),
        ),
        blurRadius: _isPressed ? 4 : (_isHovered && isInteractive ? 10 : 8),
        offset: _isPressed
            ? const Offset(0, 1)
            : (_isHovered && isInteractive
                ? const Offset(0, 4)
                : const Offset(0, 2)),
        spreadRadius: 0,
      ),
      // Inner highlight (top edge)
      if (_isHovered && isInteractive && !_isPressed)
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.15),
          blurRadius: 1,
          offset: const Offset(0, -1),
          spreadRadius: -1,
        ),
    ];
  }

  BoxDecoration _buildInnerDecoration() {
    final isInteractive = widget.onPressed != null;

    return BoxDecoration(
      borderRadius: BorderRadiusTokens.radiusXl,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: _isHovered && isInteractive ? 0.08 : 0.05),
          Colors.transparent,
          Colors.black.withValues(alpha: _isPressed ? 0.08 : 0.03),
        ],
        stops: const [0.0, 0.5, 1.0],
      ),
    );
  }

  Widget _buildButtonContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon or loading indicator with elegant animation
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: widget.isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  key: const ValueKey('loading'),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(_foregroundColor),
                  ),
                )
              : TweenAnimationBuilder<double>(
                  key: const ValueKey('icon'),
                  duration: const Duration(milliseconds: 200),
                  tween: Tween<double>(begin: 0.8, end: _isPressed ? 0.9 : 1.0),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Icon(
                        widget.icon,
                        size: 20,
                        color: _foregroundColor.withValues(
                          alpha: _isHovered ? 1.0 : 0.9,
                        ),
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(width: 12),
        // Text with subtle animation
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: _foregroundColor.withValues(
              alpha: _isHovered ? 1.0 : 0.9,
            ),
            letterSpacing: 0.5,
          ),
          child: Text(_displayText),
        ),
      ],
    );
  }

  Widget _buildShimmerOverlay() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadiusTokens.radiusXl,
        child: AnimatedBuilder(
          animation: _shimmerOffset,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                _shimmerOffset.value.dx * 100,
                _shimmerOffset.value.dy,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.3 * _shimmerAnimation.value),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
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