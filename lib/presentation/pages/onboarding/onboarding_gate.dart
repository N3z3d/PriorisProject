import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
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

  /// Garantit un unique `touchLastSeen` par session (le build est ré-exécuté).
  bool _lastSeenTouched = false;

  final Logger _logger = Logger();

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding == false) return _home();
    if (_showOnboarding == true) {
      // Sortie pilotée par le contrôleur, pas par le compteur de tâches.
      final finished = ref.watch(
        onboardingFlowControllerProvider.select((s) => s.finished),
      );
      return finished ? _home() : const OnboardingFlowPage();
    }

    final shouldShow = ref.watch(shouldShowOnboardingProvider);
    return shouldShow.when(
      // Latch la décision : les rebuilds suivants court-circuitent avant tout
      // watch du compteur de tâches, donc l'invalidation ne démonte plus rien.
      data: (show) {
        _showOnboarding = show;
        return show ? const OnboardingFlowPage() : _home();
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      // Fallback d'erreur : l'état n'a pas été lu, donc on n'enregistre pas la
      // connexion (sinon on effacerait la dormance qu'on n'a pas pu mesurer).
      error: (_, __) => _home(recordLastSeen: false),
    );
  }

  /// Rend HomePage et, si la décision a bien lu l'état, enregistre la connexion.
  ///
  /// L'enregistrement se fait **après** que la décision d'affichage a lu l'état
  /// (via `shouldShowOnboardingProvider`) : toucher `last_seen_at` plus tôt —
  /// ou sur le fallback d'erreur (`recordLastSeen: false`), où l'état n'a jamais
  /// été lu — effacerait silencieusement la dormance qu'on veut détecter.
  /// Fire-and-forget et non bloquant : une écriture ratée ne doit jamais
  /// empêcher l'app de s'ouvrir, mais elle est loggée (sinon un échec persistant
  /// gèle `last_seen_at` et réaffiche l'onboarding à 90 j, en silence).
  Widget _home({bool recordLastSeen = true}) {
    if (recordLastSeen && !_lastSeenTouched) {
      _lastSeenTouched = true;
      ref.read(onboardingRepositoryProvider).touchLastSeen().catchError(
        (Object error, StackTrace stack) {
          _logger.w(
            'touchLastSeen a échoué : dormance non mise à jour cette session',
            error: error,
            stackTrace: stack,
          );
        },
      );
    }
    return const HomePage();
  }
}
