import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Acte 3 — moment révélateur : la tâche prioritaire mise en avant.
class OnboardingRevealStep extends StatelessWidget {
  final Task? task;
  final VoidCallback onContinue;
  final VoidCallback onMarkDone;

  /// Verrouille les boutons pendant la finalisation (anti double-tap : éviter un
  /// double markCompleted / une mutation après démontage du contrôleur).
  final bool processing;

  const OnboardingRevealStep({
    super.key,
    required this.task,
    required this.onContinue,
    required this.onMarkDone,
    this.processing = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.onboardingRevealTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          if (task != null) _buildRevealCard(context, task!),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: processing ? null : onMarkDone,
            child: Text(l10n.onboardingRevealMarkDone),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: processing ? null : onContinue,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(l10n.onboardingRevealContinue),
          ),
        ],
      ),
    );
  }

  Widget _buildRevealCard(BuildContext context, Task task) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Card(
        color: AppTheme.cardColor,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            task.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ),
    );
  }
}
