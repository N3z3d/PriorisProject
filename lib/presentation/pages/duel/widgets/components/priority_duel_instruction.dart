import 'package:flutter/material.dart';
import 'package:prioris/domain/core/value_objects/duel_settings.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Widget affichant une consigne contextuelle selon le mode de jeu
class PriorityDuelInstruction extends StatelessWidget {
  final DuelMode mode;

  const PriorityDuelInstruction({
    super.key,
    required this.mode,
  });

  String get _instruction {
    return mode == DuelMode.winner
        ? 'Choisissez 1 gagnant'
        : 'Classez ces cartes';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Text(
        _instruction,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
          letterSpacing: 0.2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
