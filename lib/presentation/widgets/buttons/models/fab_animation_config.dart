import 'package:flutter/animation.dart';

/// Configuration for FAB animation parameters
///
/// Follows OCP: Can be extended with new animation configs without modifying existing code
class FABAnimationConfig {
  final Duration scaleDuration;
  final Duration shimmerDuration;
  final Duration glowDuration;
  final Curve scaleCurve;
  final Curve shimmerCurve;
  final Curve glowCurve;
  final double scaleBegin;
  final double scaleEnd;
  final double shimmerBegin;
  final double shimmerEnd;
  final double glowBegin;
  final double glowEnd;

  const FABAnimationConfig({
    required this.scaleDuration,
    required this.shimmerDuration,
    required this.glowDuration,
    required this.scaleCurve,
    required this.shimmerCurve,
    required this.glowCurve,
    required this.scaleBegin,
    required this.scaleEnd,
    required this.shimmerBegin,
    required this.shimmerEnd,
    required this.glowBegin,
    required this.glowEnd,
  });

  /// Default configuration matching original premium FAB behavior
  factory FABAnimationConfig.defaults() {
    return const FABAnimationConfig(
      scaleDuration: Duration(milliseconds: 150),
      shimmerDuration: Duration(milliseconds: 2000),
      glowDuration: Duration(milliseconds: 1500),
      scaleCurve: Curves.easeInOut,
      shimmerCurve: Curves.easeInOut,
      glowCurve: Curves.easeInOut,
      scaleBegin: 1.0,
      scaleEnd: 0.95,
      shimmerBegin: 0.0,
      shimmerEnd: 1.0,
      glowBegin: 0.3,
      glowEnd: 1.0,
    );
  }
}
