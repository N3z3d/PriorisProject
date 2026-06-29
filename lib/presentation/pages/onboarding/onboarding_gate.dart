import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/onboarding_providers.dart';
import 'package:prioris/presentation/pages/home_page.dart';
import 'package:prioris/presentation/pages/onboarding/controllers/onboarding_flow_controller.dart';
import 'package:prioris/presentation/pages/onboarding/onboarding_flow_page.dart';

/// Décide entre l'onboarding actif et HomePage pour un utilisateur consenti.
///
/// La décision est **latchée** au premier résultat : une fois l'onboarding
/// monté, il reste affiché jusqu'à l'état terminal `finished` du contrôleur.
/// Sans ce latch, l'invalidation de `allPrioritizationTasksProvider` déclenchée
/// par le flux lui-même (capture → duels) ferait passer `shouldShowOnboarding`
/// à `false` et démonterait les Actes 2/3 en plein milieu.
///
/// Fail-open : en cas d'erreur de lecture du flag, ne jamais bloquer l'accès.
class OnboardingGate extends ConsumerStatefulWidget {
  const OnboardingGate({super.key});

  @override
  ConsumerState<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends ConsumerState<OnboardingGate> {
  /// `null` tant que la décision initiale n'est pas résolue, puis figée.
  bool? _showOnboarding;

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding == false) return const HomePage();
    if (_showOnboarding == true) {
      // Sortie pilotée par le contrôleur, pas par le compteur de tâches.
      final finished = ref.watch(
        onboardingFlowControllerProvider.select((s) => s.finished),
      );
      return finished ? const HomePage() : const OnboardingFlowPage();
    }

    final shouldShow = ref.watch(shouldShowOnboardingProvider);
    return shouldShow.when(
      // Latch la décision : les rebuilds suivants court-circuitent avant tout
      // watch du compteur de tâches, donc l'invalidation ne démonte plus rien.
      data: (show) {
        _showOnboarding = show;
        return show ? const OnboardingFlowPage() : const HomePage();
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const HomePage(),
    );
  }
}
