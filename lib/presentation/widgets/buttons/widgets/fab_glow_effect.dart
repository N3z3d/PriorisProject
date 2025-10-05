import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Glow effect layer for FAB
///
/// SRP: Single responsibility - renders glow visual effect
/// Stateless for better performance
class FABGlowEffect extends StatelessWidget {
  final Animation<double> glowAnimation;
  final Color glowColor;

  const FABGlowEffect({
    super.key,
    required this.glowAnimation,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadiusTokens.radiusXl,
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: glowAnimation.value * 0.3),
              blurRadius: 20 * glowAnimation.value,
              spreadRadius: 2 * glowAnimation.value,
            ),
          ],
        ),
      ),
    );
  }
}
