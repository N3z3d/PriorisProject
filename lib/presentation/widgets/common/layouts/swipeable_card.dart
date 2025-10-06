import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Widget pour carte avec swipe gestures
class SwipeableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onTap;
  final Color? leftActionColor;
  final Color? rightActionColor;
  final IconData? leftActionIcon;
  final IconData? rightActionIcon;
  final String? leftActionLabel;
  final String? rightActionLabel;

  const SwipeableCard({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onTap,
    this.leftActionColor,
    this.rightActionColor,
    this.leftActionIcon,
    this.rightActionIcon,
    this.leftActionLabel,
    this.rightActionLabel,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  double _dragExtent = 0;
  bool _isSwipingLeft = false;
  bool _isSwipingRight = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _dragExtent = 0;
    setState(() {
      _isSwipingLeft = false;
      _isSwipingRight = false;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent += details.primaryDelta ?? 0;
      _isSwipingLeft = _dragExtent < -50;
      _isSwipingRight = _dragExtent > 50;
    });
    
    // Feedback haptique au seuil de déclenchement
    if ((_dragExtent.abs() > 100 && _dragExtent.abs() < 110) ||
        (_dragExtent.abs() > 110 && _dragExtent.abs() < 120)) {
      HapticFeedback.selectionClick();
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final threshold = 100.0;

    if (_dragExtent.abs() > threshold || velocity.abs() > 500) {
      if (_dragExtent < 0 && widget.onSwipeLeft != null) {
        // Swipe vers la gauche
        _animateOut(true);
        widget.onSwipeLeft!();
      } else if (_dragExtent > 0 && widget.onSwipeRight != null) {
        // Swipe vers la droite
        _animateOut(false);
        widget.onSwipeRight!();
      } else {
        _resetPosition();
      }
    } else {
      _resetPosition();
    }
  }

  void _animateOut(bool toLeft) {
    _controller.reset();
    
    final currentOffset = _dragExtent / MediaQuery.of(context).size.width;
    
    _animation = Tween<Offset>(
      begin: Offset(currentOffset, 0),
      end: Offset(toLeft ? -1.5 : 1.5, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _controller.forward().then((_) {
      if (mounted) {
        // Attendre un peu avant de reset pour que l'action soit visible
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _resetToInitialState();
          }
        });
      }
    });
  }
  
  void _resetToInitialState() {
    if (!mounted) return;
    
    // Utilise WidgetsBinding pour s'assurer que le reset se fait au bon moment
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.reset();
        _animation = Tween<Offset>(
          begin: Offset.zero,
          end: Offset.zero,
        ).animate(_controller);
        
        setState(() {
          _dragExtent = 0;
          _isSwipingLeft = false;
          _isSwipingRight = false;
        });
      }
    });
  }

  void _resetPosition() {
    if (!mounted) return;
    
    _controller.reset(); // Important: reset avant de changer l'animation
    
    final currentOffset = _dragExtent / MediaQuery.of(context).size.width;
    
    _animation = Tween<Offset>(
      begin: Offset(currentOffset, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _controller.forward().then((_) {
      // Reset final après animation avec verification mounté
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _dragExtent = 0;
              _isSwipingLeft = false;
              _isSwipingRight = false;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: Stack(
        children: [
          if (_isSwipingLeft || _isSwipingRight) _buildSwipeBackground(),
          _buildAnimatedCard(),
        ],
      ),
    );
  }

  Widget _buildSwipeBackground() {
    return Container(
      decoration: BoxDecoration(
        color: _isSwipingLeft
            ? (widget.leftActionColor ?? AppTheme.errorColor)
            : (widget.rightActionColor ?? AppTheme.successColor),
        borderRadius: BorderRadiusTokens.radiusMd,
      ),
      child: Align(
        alignment: _isSwipingLeft
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildActionContent(),
        ),
      ),
    );
  }

  Widget _buildActionContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _isSwipingLeft
              ? (widget.leftActionIcon ?? Icons.delete)
              : (widget.rightActionIcon ?? Icons.check),
          color: Colors.white,
          size: 28,
        ),
        if (_isSwipingLeft && widget.leftActionLabel != null ||
            _isSwipingRight && widget.rightActionLabel != null)
          const SizedBox(height: 4),
        if (_isSwipingLeft && widget.leftActionLabel != null)
          Text(
            widget.leftActionLabel!,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        if (_isSwipingRight && widget.rightActionLabel != null)
          Text(
            widget.rightActionLabel!,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
      ],
    );
  }

  Widget _buildAnimatedCard() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_dragExtent, 0),
          child: SlideTransition(
            position: _animation,
            child: widget.child,
          ),
        );
      },
    );
  }
}