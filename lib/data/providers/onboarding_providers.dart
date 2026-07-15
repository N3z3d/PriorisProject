import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/auth_providers.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';
import 'package:prioris/data/providers/prioritization_providers.dart';
import 'package:prioris/data/providers/service_providers.dart';
import 'package:prioris/data/repositories/supabase/supabase_onboarding_repository.dart';
import 'package:prioris/domain/ports/onboarding_repository.dart';
import 'package:prioris/presentation/pages/onboarding/services/onboarding_persistence.dart';

/// Seuil de dormance : au-delà de cette absence, l'onboarding est reproposé.
///
/// Constante nommée (AC4) — pas de nombre magique. Règle produit (2026-07-12) :
/// reproposer l'onboarding après 90 jours sans connexion.
const Duration kOnboardingDormancyThreshold = Duration(days: 90);

/// Horloge injectable pour la logique de décision temporelle (AC4).
///
/// Overridable en test pour figer le temps. Ne **jamais** appeler
/// `DateTime.now()` directement dans la logique de dormance — mémoire projet
/// (tests flaky dépendants de la date, cf. story 11.8).
final nowProvider = Provider<DateTime Function()>(
  (ref) => () => DateTime.now().toUtc(),
);

/// Adapter **account-scoped** de l'état d'onboarding (ADR-001).
///
/// L'état suit le compte (Supabase), pas le device : un utilisateur qui a
/// complété l'onboarding ne le revoit pas sur un navigateur/appareil neuf. Le
/// tunnel d'onboarding vit toujours derrière l'authentification
/// (`auth_wrapper.dart`), donc l'adapter — qui exige l'auth — est la seule
/// source de vérité (pas de fallback device).
final onboardingRepositoryProvider = Provider<IOnboardingRepository>((ref) {
  return SupabaseOnboardingRepository(
    supabaseService: ref.read(supabaseServiceProvider),
    authService: ref.read(authServiceProvider),
  );
});

/// Garantit que les listes sont chargées avant tout comptage.
///
/// `listsProvider` est synchrone et vide pendant le bootstrap async : sans cette
/// attente, un utilisateur existant ne possédant *que* des items de listes
/// verrait brièvement l'onboarding (faux positif), le compteur valant 0 le temps
/// du chargement. Isolé en provider pour rester trivialement mockable en test
/// (override `ensureListsLoadedProvider` en no-op), sans tirer toute la chaîne
/// d'init des listes dans les tests des providers d'onboarding.
final ensureListsLoadedProvider = FutureProvider<void>((ref) async {
  await ref.watch(listsInitializationManagerProvider.future);
  await ref.watch(listsPersistenceManagerProvider.future);
  await ref.read(listsControllerProvider.notifier).loadLists();
  await _waitForListsToFinishLoading(ref);
});

/// Attend la fin *effective* du chargement des listes.
///
/// Le `loadLists()` ci-dessus peut être un no-op silencieux : tant que le
/// bootstrap du contrôleur n'a pas posé son flag d'initialisation, l'executor
/// ignore l'appel (`!controllerInitialized`). Sans cette attente, le comptage
/// qui suit lirait des listes vides et classerait `real` un utilisateur qui
/// possède déjà des données — la corruption que l'onboarding doit éviter. Même
/// garde que `DuelService._waitForListsToFinishLoading`.
Future<void> _waitForListsToFinishLoading(
  Ref ref, {
  Duration pollInterval = const Duration(milliseconds: 50),
  Duration timeout = const Duration(seconds: 2),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (!ref.read(listsControllerProvider).isLoading) return;
    await Future.delayed(pollInterval);
  }
}

/// Nombre total de tâches de l'utilisateur : tâches classiques + items de listes.
///
/// Compter les deux sources évite qu'un utilisateur possédant uniquement des
/// items de listes voie l'onboarding réservé aux nouveaux comptes.
final totalTaskCountProvider = FutureProvider<int>((ref) async {
  final classic = await ref.watch(allPrioritizationTasksProvider.future);
  await ref.watch(ensureListsLoadedProvider.future);
  final lists = ref.watch(listsProvider);
  final listItemCount =
      lists.fold<int>(0, (sum, list) => sum + list.items.length);
  return classic.length + listItemCount;
});

/// Décide si l'onboarding actif doit être affiché.
///
/// Deux verrous, lus depuis le **compte** (pas le device) :
/// 1. jamais complété (`completedAt == null`) → afficher ;
/// 2. complété mais dormant : dernière connexion il y a plus de
///    [kOnboardingDormancyThreshold] → re-accueil.
///
/// Le nombre de tâches ne conditionne pas l'affichage — il ne décide que le
/// *mode* (cf. [onboardingModeProvider]).
final shouldShowOnboardingProvider = FutureProvider<bool>((ref) async {
  final state = await ref.watch(onboardingRepositoryProvider).loadState();
  if (!state.hasCompleted) return true;

  final lastSeen = state.lastSeenAt;
  if (lastSeen == null) return false; // complété sans repère : pas dormant.

  final now = ref.watch(nowProvider)();
  return now.difference(lastSeen) > kOnboardingDormancyThreshold;
});

/// Décide le mode de l'onboarding, une fois, explicitement.
///
/// S'appuie sur [totalTaskCountProvider], qui attend le chargement effectif des
/// listes ([ensureListsLoadedProvider]) : sans cette attente, un utilisateur
/// existant serait compté à 0 pendant le bootstrap, classé [OnboardingMode.real]
/// — et on lui créerait une liste en écrasant la promesse « aucune écriture ».
final onboardingModeProvider = FutureProvider<OnboardingMode>((ref) async {
  final total = await ref.watch(totalTaskCountProvider.future);
  return total == 0 ? OnboardingMode.real : OnboardingMode.sandbox;
});

/// Écritures de listes exposées à l'onboarding (mode réel uniquement).
final onboardingListsWriterProvider = Provider<OnboardingListsWriter>((ref) {
  return ListsControllerWriter(() => ref.read(listsControllerProvider.notifier));
});
