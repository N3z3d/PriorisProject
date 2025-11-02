import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Premium Elo badge with gradient, glow effect, and sophisticated styling
class EloBadge extends StatefulWidget {
  final double score;
  final bool compact;

  const EloBadge({
    super.key,
    required this.score,
    this.compact = false,
  });

  @override
  State<EloBadge> createState() => _EloBadgeState();
}

class _EloBadgeState extends State<EloBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tier = _resolveTier(widget.score);
    final padding = widget.compact
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 5)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 8);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      child: _EloBadgeContent(
        tier: tier,
        score: widget.score,
        compact: widget.compact,
      ),
      builder: (context, child) {
        return Container(
          padding: padding,
          decoration: _badgeDecoration(tier, widget.compact),
          child: child,
        );
      },
    );
  }

  BoxDecoration _badgeDecoration(_EloTier tier, bool compact) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          tier.primaryColor.withValues(alpha: 0.15),
          tier.secondaryColor.withValues(alpha: 0.12),
        ],
      ),
      borderRadius: BorderRadius.circular(compact ? 14 : 16),
      border: Border.all(
        color: tier.primaryColor.withValues(alpha: 0.4),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: tier.primaryColor.withValues(alpha: 0.2 * _pulseAnimation.value),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static _EloTier _resolveTier(double score) {
    if (score >= 1400) {
      return _EloTier(
        name: 'Expert',
        primaryColor: const Color(0xFFD97706), // Amber 600
        secondaryColor: const Color(0xFFF59E0B), // Amber 500
        icon: Icons.workspace_premium_rounded,
      );
    }
    if (score >= 1200) {
      return _EloTier(
        name: 'Advanced',
        primaryColor: AppTheme.accentColor,
        secondaryColor: const Color(0xFF8B5CF6), // Purple 500
        icon: Icons.stars_rounded,
      );
    }
    return _EloTier(
      name: 'Beginner',
      primaryColor: AppTheme.grey500,
      secondaryColor: AppTheme.grey400,
      icon: Icons.trending_up_rounded,
    );
  }
}

class _EloTier {
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;

  _EloTier({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
  });
}

class _EloBadgeContent extends StatelessWidget {
  const _EloBadgeContent({
    required this.tier,
    required this.score,
    required this.compact,
  });

  final _EloTier tier;
  final double score;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: compact ? 12 : 14,
          color: Colors.white,
          letterSpacing: 0.5,
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GradientIcon(
          icon: tier.icon,
          primary: tier.primaryColor,
          secondary: tier.secondaryColor,
          size: compact ? 14 : 16,
        ),
        const SizedBox(width: 6),
        _GradientText(
          text: score.toStringAsFixed(0),
          primary: tier.primaryColor,
          secondary: tier.secondaryColor,
          style: textStyle,
        ),
      ],
    );
  }
}

class _GradientIcon extends StatelessWidget {
  const _GradientIcon({
    required this.icon,
    required this.primary,
    required this.secondary,
    required this.size,
  });

  final IconData icon;
  final Color primary;
  final Color secondary;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [primary, secondary],
      ).createShader(bounds),
      child: Icon(icon, size: size, color: Colors.white),
    );
  }
}

class _GradientText extends StatelessWidget {
  const _GradientText({
    required this.text,
    required this.primary,
    required this.secondary,
    required this.style,
  });

  final String text;
  final Color primary;
  final Color secondary;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [primary, secondary],
      ).createShader(bounds),
      child: Text(text, style: style),
    );
  }
}
