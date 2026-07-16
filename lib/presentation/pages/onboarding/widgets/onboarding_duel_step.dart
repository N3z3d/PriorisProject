import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Acte 2 — premier duel guidé : deux cartes épurées (titre seul, pas d'ELO).
class OnboardingDuelStep extends StatelessWidget {
  final List<Task> pair;
  final int index;
  final int total;
  final bool processing;
  final void Function(Task winner, Task loser) onChoose;

  const OnboardingDuelStep({
    super.key,
    required this.pair,
    required this.index,
    required this.total,
    required this.onChoose,
    this.processing = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (pair.length < 2) {
      return const Center(child: CircularProgressIndicator());
    }
    final left = pair[0];
    final right = pair[1];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            l10n.onboardingDuelProgress(index + 1, total),
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.onboardingDuelQuestion,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          // Pont posé avant le tout premier duel : l'utilisateur sait combien de
          // choix il va faire et qu'il n'y a ni classement ni chiffre (AC3).
          if (index == 0) ...[
            const SizedBox(height: 12),
            Text(
              l10n.onboardingDuelIntro(total),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 24),
          Expanded(child: _buildCard(context, left, right)),
          const SizedBox(height: 16),
          Expanded(child: _buildCard(context, right, left)),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, Task choice, Task other) {
    return Card(
      color: AppTheme.cardColor,
      child: InkWell(
        onTap: processing ? null : () => onChoose(choice, other),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              choice.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
      ),
    );
  }
}
