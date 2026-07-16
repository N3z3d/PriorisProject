import 'package:flutter/material.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/onboarding/onboarding_task_parser.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Acte 1 — capture rapide : champ multi-lignes + chips d'archétypes.
class OnboardingCaptureStep extends StatefulWidget {
  final ValueChanged<String> onStart;
  final VoidCallback onSkip;

  /// Verrouille « Passer » et « C'est parti » pendant la persistance des tâches
  /// (anti double-tap / anti completeOnboarding concurrent à la capture).
  final bool processing;

  /// Nombre de lignes non vides requis pour activer le bouton de démarrage.
  static const int requiredTasks = 5;

  const OnboardingCaptureStep({
    super.key,
    required this.onStart,
    required this.onSkip,
    this.processing = false,
  });

  @override
  State<OnboardingCaptureStep> createState() => _OnboardingCaptureStepState();
}

class _OnboardingCaptureStepState extends State<OnboardingCaptureStep> {
  final TextEditingController _controller = TextEditingController();
  static const OnboardingTaskParser _parser = OnboardingTaskParser();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Tâches *uniques* (même base que le contrôleur) : le compteur reflète
  /// exactement ce qui sera créé — pas un simple décompte de lignes.
  int get _taskCount => _parser.parse(_controller.text).length;

  void _appendArchetype(String label) {
    final lines = _controller.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.any((l) => l.toLowerCase() == label.toLowerCase())) return;
    lines.add(label);
    setState(() {
      _controller.text = '${lines.join('\n')}\n';
      _controller.selection =
          TextSelection.collapsed(offset: _controller.text.length);
    });
  }

  List<String> _archetypes(AppLocalizations l10n) => [
        l10n.onboardingArchetypeSport,
        l10n.onboardingArchetypeCall,
        l10n.onboardingArchetypeReport,
        l10n.onboardingArchetypeEmails,
        l10n.onboardingArchetypeGroceries,
        l10n.onboardingArchetypeRead,
        l10n.onboardingArchetypeTidy,
        l10n.onboardingArchetypeWater,
      ];

  Widget _buildArchetypes(AppLocalizations l10n) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final archetype in _archetypes(l10n))
          ActionChip(
            label: Text(archetype),
            onPressed: () => _appendArchetype(archetype),
          ),
      ],
    );
  }

  /// Compteur de progression vers le seuil (« 3 / 5 ») + aide contextuelle tant
  /// que le seuil n'est pas atteint : le bouton grisé cesse d'être muet (AC1).
  Widget _buildProgress(AppLocalizations l10n) {
    const required = OnboardingCaptureStep.requiredTasks;
    final remaining = required - _taskCount;
    // Numérateur plafonné au seuil : au-delà de 5 tâches on affiche « 5 / 5 »,
    // pas « 7 / 5 » (le surplus est réel mais illisible comme progression).
    final shownCount = _taskCount.clamp(0, required);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.onboardingTaskProgress(shownCount, required),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        if (remaining > 0) ...[
          const SizedBox(height: 4),
          Text(
            l10n.onboardingTasksRemaining(remaining),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canStart =
        _taskCount >= OnboardingCaptureStep.requiredTasks && !widget.processing;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.processing ? null : widget.onSkip,
              child: Text(l10n.onboardingSkip),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.onboardingCaptureTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.onboardingCaptureIntro,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    maxLines: 6,
                    keyboardType: TextInputType.multiline,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: l10n.onboardingCaptureHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.onboardingArchetypesLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  _buildArchetypes(l10n),
                  const SizedBox(height: 16),
                  _buildProgress(l10n),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: canStart ? () => widget.onStart(_controller.text) : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(l10n.onboardingStartButton),
          ),
        ],
      ),
    );
  }
}
