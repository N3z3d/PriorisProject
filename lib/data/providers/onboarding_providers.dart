import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';
import 'package:prioris/data/providers/prioritization_providers.dart';
import 'package:prioris/data/repositories/shared_preferences_onboarding_repository.dart';
import 'package:prioris/domain/ports/onboarding_repository.dart';
import 'package:prioris/presentation/pages/onboarding/services/onboarding_persistence.dart';

/// Adapter SharedPreferences pour l'état d'onboarding (ADR-001).
final onboardingRepositoryProvider = Provider<IOnboardingRepository>(
  (ref) => SharedPreferencesOnboardingRepository(),
);

/// Vrai si l'utilisateur a déjà complété ou passé l'onboarding (flag durable).
final onboardingCompletedProvider = FutureProvider<bool>((ref) {
  return ref.watch(onboardingRepositoryProvider).hasCompletedOnboarding();
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
/// Décision produit : l'onboarding s'affiche pour **tout le monde**, pas
/// seulement aux comptes vides. Le nombre de tâches ne conditionne donc plus
/// l'affichage — il ne décide que le *mode* (cf. [onboardingModeProvider]). Le
/// flag persisté reste le seul verrou : il évite de re-piéger un utilisateur
/// qui a déjà complété ou passé le flux.
final shouldShowOnboardingProvider = FutureProvider<bool>((ref) async {
  final completed = await ref.watch(onboardingCompletedProvider.future);
  return !completed;
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
