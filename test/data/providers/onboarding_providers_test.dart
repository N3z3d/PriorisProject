import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';
import 'package:prioris/data/providers/onboarding_providers.dart';
import 'package:prioris/data/providers/prioritization_providers.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/ports/onboarding_repository.dart';
import 'package:prioris/presentation/pages/onboarding/services/onboarding_persistence.dart';

class _FakeOnboardingRepository implements IOnboardingRepository {
  _FakeOnboardingRepository(this._completed);
  bool _completed;

  @override
  Future<bool> hasCompletedOnboarding() async => _completed;

  @override
  Future<void> markCompleted() async => _completed = true;
}

CustomList _listWithItems(int count) {
  final now = DateTime.now();
  return CustomList(
    id: 'list-1',
    name: 'Liste',
    type: ListType.CUSTOM,
    createdAt: now,
    updatedAt: now,
    items: List.generate(
      count,
      (i) => ListItem(id: 'item-$i', title: 'Item $i', createdAt: now),
    ),
  );
}

ProviderContainer _container({
  required bool completed,
  required List<Task> classicTasks,
  List<CustomList> lists = const [],
}) {
  return ProviderContainer(
    overrides: [
      onboardingRepositoryProvider
          .overrideWithValue(_FakeOnboardingRepository(completed)),
      allPrioritizationTasksProvider.overrideWith((ref) async => classicTasks),
      listsProvider.overrideWithValue(lists),
      // Court-circuite la chaîne d'init des listes : la valeur de listsProvider
      // est déjà fournie ci-dessus, on a seulement besoin que l'attente passe.
      ensureListsLoadedProvider.overrideWith((ref) async {}),
    ],
  );
}

void main() {
  group('shouldShowOnboarding — l\'onboarding s\'affiche pour tout le monde', () {
    // Décision produit (2026-07-12) : le nombre de tâches ne conditionne plus
    // l'affichage, seulement le MODE. Un utilisateur existant traverse
    // l'onboarding en sandbox, sans qu'aucune de ses données ne soit touchée.

    test('true : nouvel utilisateur (0 tâche) qui n\'a pas fait l\'onboarding',
        () async {
      final c = _container(completed: false, classicTasks: const []);
      addTearDown(c.dispose);

      expect(await c.read(shouldShowOnboardingProvider.future), isTrue);
    });

    test('true : utilisateur existant qui n\'a pas fait l\'onboarding',
        () async {
      final c = _container(
        completed: false,
        classicTasks: [Task(title: 'A')],
        lists: [_listWithItems(2)],
      );
      addTearDown(c.dispose);

      expect(await c.read(shouldShowOnboardingProvider.future), isTrue);
    });

    test('false : onboarding déjà complété ou passé', () async {
      final c = _container(completed: true, classicTasks: const []);
      addTearDown(c.dispose);

      expect(await c.read(shouldShowOnboardingProvider.future), isFalse);
    });
  });

  group('onboardingMode — décidé sur un comptage fiable (AC5)', () {
    test('real : aucune tâche existante', () async {
      final c = _container(completed: false, classicTasks: const []);
      addTearDown(c.dispose);

      expect(await c.read(onboardingModeProvider.future), OnboardingMode.real);
    });

    test('sandbox : au moins une tâche classique', () async {
      final c = _container(completed: false, classicTasks: [Task(title: 'A')]);
      addTearDown(c.dispose);

      expect(
          await c.read(onboardingModeProvider.future), OnboardingMode.sandbox);
    });

    test('sandbox : seulement des items de listes', () async {
      // Le cas qui a causé la corruption : un utilisateur dont toutes les
      // données sont des items de listes doit être classé sandbox.
      final c = _container(
        completed: false,
        classicTasks: const [],
        lists: [_listWithItems(2)],
      );
      addTearDown(c.dispose);

      expect(
          await c.read(onboardingModeProvider.future), OnboardingMode.sandbox);
    });
  });

  group('totalTaskCount', () {
    test('additionne tâches classiques et items de listes', () async {
      final c = _container(
        completed: false,
        classicTasks: [Task(title: 'A'), Task(title: 'B')],
        lists: [_listWithItems(3)],
      );
      addTearDown(c.dispose);

      expect(await c.read(totalTaskCountProvider.future), 5);
    });
  });
}
