import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Widget bouton d'action avec animations et états de chargement
class ActionButton extends StatefulWidget {
  /// Icône du bouton
  final IconData icon;
  
  /// Couleur du bouton
  final Color color;
  
  /// Callback appelé lors du tap
  final VoidCallback onTap;
  
  /// Tooltip affiché au survol
  final String tooltip;
  
  /// Indique si le bouton est en cours de chargement
  final bool isLoading;

  const ActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
    this.isLoading = false,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.fastAnimation,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppTheme.defaultCurve,
    ));
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
    
    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTapDown: widget.isLoading ? null : (_) => _controller.forward(),
        onTapUp: widget.isLoading ? null : (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: widget.isLoading ? null : () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.isLoading ? 1.0 : _scaleAnimation.value,
              child: Transform.rotate(
                angle: widget.isLoading ? _rotationAnimation.value * 2 * 3.14159 : 0,
                child: Container(
                  margin: const EdgeInsets.only(left: AppTheme.spacingSM),
                  padding: const EdgeInsets.all(AppTheme.spacingSM),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    border: Border.all(
                      color: widget.color.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 16,
                    color: widget.color,
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
