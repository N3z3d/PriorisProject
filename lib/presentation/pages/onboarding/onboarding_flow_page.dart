import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/onboarding/controllers/onboarding_flow_controller.dart';
import 'package:prioris/presentation/pages/onboarding/widgets/onboarding_capture_step.dart';
import 'package:prioris/presentation/pages/onboarding/widgets/onboarding_duel_step.dart';
import 'package:prioris/presentation/pages/onboarding/widgets/onboarding_reveal_step.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Écran plein affiché avant HomePage pour un nouvel utilisateur.
///
/// Enchaîne les trois actes (capture → duel → reveal) via AnimatedSwitcher.
class OnboardingFlowPage extends ConsumerWidget {
  const OnboardingFlowPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingFlowControllerProvider);
    final controller = ref.read(onboardingFlowControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildStep(context, state, controller),
        ),
      ),
    );
  }

  Widget _buildStep(
    BuildContext context,
    OnboardingFlowState state,
    OnboardingFlowController controller,
  ) {
    switch (state.step) {
      case OnboardingStep.capture:
        return OnboardingCaptureStep(
          key: const ValueKey('onboarding-capture'),
          // Le nom de la liste dédiée est localisé ici : le contrôleur n'a pas
          // de contexte, et une chaîne en dur y serait un bug d'i18n.
          onStart: (rawText) => controller.submitCapturedTasks(
            rawText,
            listName: AppLocalizations.of(context)!.onboardingListName,
          ),
          onSkip: controller.completeOnboarding,
          processing: state.isProcessing,
        );
      case OnboardingStep.duel:
        return OnboardingDuelStep(
          // Clé par index : chaque duel est un nouvel enfant pour
          // l'AnimatedSwitcher → vraie transition + animation d'entrée rejouée.
          key: ValueKey('onboarding-duel-${state.duelIndex}'),
          pair: state.currentPair,
          index: state.duelIndex,
          total: OnboardingFlowController.totalDuels,
          processing: state.isProcessing,
          onChoose: controller.recordDuelChoice,
        );
      case OnboardingStep.reveal:
        return OnboardingRevealStep(
          key: const ValueKey('onboarding-reveal'),
          task: state.revealedTask,
          onContinue: controller.completeOnboarding,
          onMarkDone: controller.markRevealedTaskDoneAndComplete,
          processing: state.isProcessing,
        );
    }
  }
}
