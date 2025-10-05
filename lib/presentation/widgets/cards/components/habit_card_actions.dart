import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/premium_exports.dart';

/// Widget d'actions pour PremiumHabitCard
///
/// Responsabilité: Afficher le bouton de complétion et le menu d'actions
class HabitCardActions extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback onComplete;
  final VoidCallback onShowMenu;
  final bool enableEffects;

  const HabitCardActions({
    super.key,
    required this.isCompleted,
    required this.onComplete,
    required this.onShowMenu,
    required this.enableEffects,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PremiumUISystem.premiumButton(
            text: isCompleted ? 'Complété' : 'Marquer accompli',
            onPressed: isCompleted ? () {} : onComplete,
            icon: isCompleted
              ? Icons.check_circle
              : Icons.radio_button_unchecked,
            style: isCompleted
              ? PremiumButtonStyle.secondary
              : PremiumButtonStyle.primary,
            enableHaptics: enableEffects,
            enablePhysics: enableEffects,
          ),
        ),
        const SizedBox(width: 12),
        HapticWrapper(
          enableHaptics: enableEffects,
          tapIntensity: HapticIntensity.light,
          onTap: onShowMenu,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadiusTokens.button,
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Icon(Icons.more_vert, size: 20),
          ),
        ),
      ],
    );
  }
}
