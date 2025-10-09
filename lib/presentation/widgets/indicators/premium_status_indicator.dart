import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Enum for different status types with premium visual treatment
enum StatusType {
  pending,
  inProgress,
  completed,
  paused,
  failed,
}

/// Premium Status Indicator with elegant animations and sophisticated design
///
/// Features:
/// - WCAG AA compliant color contrast
/// - Smooth micro-animations with haptic feedback
/// - Premium glassmorphism aesthetic
/// - Accessibility support with proper semantics
/// - Responsive design with adaptive sizing
class PremiumStatusIndicator extends StatefulWidget {
  final StatusType status;
  final String? customLabel;
  final bool showLabel;
  final bool enableAnimation;
  final bool enableHaptics;
  final double size;
  final VoidCallback? onTap;

  const PremiumStatusIndicator({
    super.key,
    required this.status,
    this.customLabel,
    this.showLabel = true,
    this.enableAnimation = true,
    this.enableHaptics = true,
    this.size = 32.0,
    this.onTap,
  });

  @override
  State<PremiumStatusIndicator> createState() => _PremiumStatusIndicatorState();
}

class _PremiumStatusIndicatorState extends State<PremiumStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    if (widget.enableAnimation) {
      _controller.forward();
    }
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(PremiumStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status && widget.enableAnimation) {
      _controller.reset();
      _controller.forward();

      if (widget.enableHaptics) {
        HapticFeedback.lightImpact();
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
    return Semantics(
      label: _getAccessibilityLabel(),
      hint: widget.onTap != null ? 'Appuyez pour plus de détails' : null,
      button: widget.onTap != null,
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.enableAnimation ? _scaleAnimation.value : 1.0,
              child: Container(
                constraints: BoxConstraints(
                  minWidth: widget.showLabel ? 80 : widget.size,
                  minHeight: widget.size,
                ),
                child: widget.showLabel ? _buildLabelIndicator() : _buildIconIndicator(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabelIndicator() {
    final config = _getStatusConfig();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: config.borderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: config.primaryColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          if (widget.status == StatusType.completed)
            BoxShadow(
              color: config.primaryColor.withOpacity(0.3 * _glowAnimation.value),
              blurRadius: 12 * _glowAnimation.value,
              spreadRadius: 2 * _glowAnimation.value,
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusIcon(config, 16),
          const SizedBox(width: 6),
          Text(
            widget.customLabel ?? config.label,
            style: TextStyle(
              color: config.textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconIndicator() {
    final config = _getStatusConfig();

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: config.borderColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: config.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          if (widget.status == StatusType.completed)
            BoxShadow(
              color: config.primaryColor.withOpacity(0.4 * _glowAnimation.value),
              blurRadius: 16 * _glowAnimation.value,
              spreadRadius: 3 * _glowAnimation.value,
            ),
        ],
      ),
      child: _buildStatusIcon(config, widget.size * 0.5),
    );
  }

  Widget _buildStatusIcon(StatusConfig config, double size) {
    if (widget.status == StatusType.inProgress) {
      return SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(config.primaryColor),
        ),
      );
    }

    return Icon(
      config.icon,
      size: size,
      color: config.primaryColor,
      semanticLabel: config.label,
    );
  }

  StatusConfig _getStatusConfig() {
    switch (widget.status) {
      case StatusType.pending:
        return _buildStatusConfig('En attente', Icons.schedule_rounded, AppTheme.warningColor);
      case StatusType.inProgress:
        return _buildStatusConfig('En cours', Icons.play_circle_outline_rounded, AppTheme.primaryColor);
      case StatusType.completed:
        return _buildStatusConfig('Termine', Icons.check_circle_rounded, AppTheme.successColor);
      case StatusType.paused:
        return _buildStatusConfig('En pause', Icons.pause_circle_outline_rounded, AppTheme.grey600);
      case StatusType.failed:
        return _buildStatusConfig('Echoue', Icons.error_rounded, AppTheme.errorColor);
    }
  }

  StatusConfig _buildStatusConfig(String label, IconData icon, Color color) {
    return StatusConfig(
      label: label,
      icon: icon,
      primaryColor: color,
      backgroundColor: color.withOpacity(0.1),
      borderColor: color.withOpacity(0.3),
      textColor: color,
    );
  }


  String _getAccessibilityLabel() {
    final config = _getStatusConfig();
    return widget.customLabel ?? config.label;
  }

  void _handleTap() {
    if (widget.onTap != null) {
      if (widget.enableHaptics) {
        HapticFeedback.lightImpact();
      }
      widget.onTap!();
    }
  }
}

/// Configuration class for status styling
class StatusConfig {
  final String label;
  final IconData icon;
  final Color primaryColor;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const StatusConfig({
    required this.label,
    required this.icon,
    required this.primaryColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });
}