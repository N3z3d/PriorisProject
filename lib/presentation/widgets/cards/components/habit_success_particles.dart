import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/premium_exports.dart';

/// Widget d'effets de particules pour succès d'habitude
///
/// Responsabilité: Afficher les particules animées lors de complétion
class HabitSuccessParticles extends StatelessWidget {
  final bool showParticles;
  final int currentStreak;
  final VoidCallback onComplete;

  const HabitSuccessParticles({
    super.key,
    required this.showParticles,
    required this.currentStreak,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (!showParticles) return const SizedBox.shrink();

    final isMilestone = currentStreak % 7 == 0 && currentStreak > 0;

    if (isMilestone) {
      return ParticleEffects.fireworksEffect(
        trigger: showParticles,
        onComplete: onComplete,
      );
    } else {
      return ParticleEffects.sparkleEffect(
        trigger: showParticles,
        onComplete: onComplete,
      );
    }
  }
}
