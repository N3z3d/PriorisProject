import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';
import 'package:prioris/data/providers/prioritization_providers.dart';
import 'package:prioris/data/repositories/shared_preferences_onboarding_repository.dart';
import 'package:prioris/domain/ports/onboarding_repository.dart';

/// Adapter SharedPreferences pour l'état d'onboarding (ADR-001).
final onboardingRepositoryProvider = Provider<IOnboardingRepository>(
  (ref) => SharedPreferencesOnboardingRepository(),
);

/// Vrai si l'utilisateur a déjà complété ou passé l'onboarding (flag durable).
final onboardingCompletedProvider = FutureProvider<bool>((ref) {
  return ref.watch(onboardingRepositoryProvider).hasCompletedOnboarding();
});

/// Nombre total de tâches de l'utilisateur : tâches classiques + items de listes.
///
/// Compter les deux sources évite qu'un utilisateur possédant uniquement des
/// items de listes voie l'onboarding réservé aux nouveaux comptes.
final totalTaskCountProvider = FutureProvider<int>((ref) async {
  final classic = await ref.watch(allPrioritizationTasksProvider.future);
  final lists = ref.watch(listsProvider);
  final listItemCount =
      lists.fold<int>(0, (sum, list) => sum + list.items.length);
  return classic.length + listItemCount;
});

/// Décide si l'onboarding actif doit être affiché.
///
/// Invariant robuste : l'afficher uniquement à un *nouvel* utilisateur
/// (0 tâche au total) qui n'a pas déjà complété ou passé l'onboarding. Le flag
/// persisté évite de re-piéger un utilisateur ayant skippé puis vidé ses tâches.
final shouldShowOnboardingProvider = FutureProvider<bool>((ref) async {
  final completed = await ref.watch(onboardingCompletedProvider.future);
  if (completed) return false;
  final total = await ref.watch(totalTaskCountProvider.future);
  return total == 0;
});
