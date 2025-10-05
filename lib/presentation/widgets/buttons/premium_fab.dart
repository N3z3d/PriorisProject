import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/buttons/premium_fab_exports.dart';

/// Premium Floating Action Button with Material Design elegance and sophisticated animations
///
/// SRP: Manages UI rendering and user interactions
/// Uses composition (mixin + extracted widgets) to delegate animation and visual effects
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
    with TickerProviderStateMixin, FABAnimationMixin<PremiumFAB> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  bool get enableAnimations => widget.enableAnimations;

  @override
  bool get isButtonPressed => _isPressed;

  @override
  void initState() {
    super.initState();
    initializeAnimations();
  }

  @override
  void dispose() {
    disposeAnimations();
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
    setState(() => _isPressed = true);
    if (widget.enableAnimations) scaleController.forward();
    if (widget.enableHaptics) HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    if (widget.enableAnimations) scaleController.reverse();
    if (widget.onPressed != null) {
      widget.onPressed!();
      if (widget.enableHaptics) HapticFeedback.selectionClick();
    }
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    if (widget.enableAnimations) scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.heroTag ?? 'premium_fab',
      child: AnimatedBuilder(
        animation: Listenable.merge([scaleAnimation, glowAnimation, shimmerAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: widget.enableAnimations ? scaleAnimation.value : 1.0,
            child: MouseRegion(
              onEnter: (event) => setState(() => _isHovered = true),
              onExit: (event) => setState(() => _isHovered = false),
              child: GestureDetector(
                onTapDown: widget.isLoading ? null : _handleTapDown,
                onTapUp: widget.isLoading ? null : _handleTapUp,
                onTapCancel: _handleTapCancel,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 56, minWidth: 120),
                  child: Stack(
                    children: [
                      if (widget.enableAnimations)
                        FABGlowEffect(
                          glowAnimation: glowAnimation,
                          glowColor: _backgroundColor,
                        ),
                      _buildPremiumMaterialButton(),
                      if (widget.enableAnimations)
                        FABShimmerEffect(
                          shimmerAnimation: shimmerAnimation,
                          shimmerOffset: shimmerOffset,
                        ),
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
        _buildIconOrLoading(),
        const SizedBox(width: 12),
        _buildAnimatedText(),
      ],
    );
  }

  Widget _buildIconOrLoading() {
    return AnimatedSwitcher(
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
          : _buildAnimatedIcon(),
    );
  }

  Widget _buildAnimatedIcon() {
    return TweenAnimationBuilder<double>(
      key: const ValueKey('icon'),
      duration: const Duration(milliseconds: 200),
      tween: Tween<double>(begin: 0.8, end: _isPressed ? 0.9 : 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Icon(
            widget.icon,
            size: 20,
            color: _foregroundColor.withValues(alpha: _isHovered ? 1.0 : 0.9),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedText() {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: _foregroundColor.withValues(alpha: _isHovered ? 1.0 : 0.9),
        letterSpacing: 0.5,
      ),
      child: Text(_displayText),
    );
  }
}