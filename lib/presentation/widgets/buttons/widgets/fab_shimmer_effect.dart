import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Shimmer effect overlay for FAB
///
/// SRP: Single responsibility - renders shimmer visual effect
/// Stateless for better performance (no internal state management)
class FABShimmerEffect extends StatelessWidget {
  final Animation<double> shimmerAnimation;
  final Animation<Offset> shimmerOffset;
  final Color effectColor;

  const FABShimmerEffect({
    super.key,
    required this.shimmerAnimation,
    required this.shimmerOffset,
    this.effectColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    if (shimmerAnimation.value <= 0) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadiusTokens.radiusXl,
        child: AnimatedBuilder(
          animation: shimmerOffset,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                shimmerOffset.value.dx * 100,
                shimmerOffset.value.dy,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      effectColor.withValues(alpha: 0.3 * shimmerAnimation.value),
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
