import 'dart:async';

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
import 'package:prioris/presentation/pages/lists/interfaces/lists_managers_interfaces.dart';
import 'package:prioris/presentation/pages/onboarding/services/onboarding_persistence.dart';

/// Repository in-memory renvoyant un état d'onboarding figé.
class _FakeOnboardingRepository implements IOnboardingRepository {
  _FakeOnboardingRepository(this._state);
  OnboardingState _state;

  @override
  Future<OnboardingState> loadState() async => _state;

  @override
  Future<void> markCompleted() async {
    _state = OnboardingState(
      completedAt: _state.completedAt ?? DateTime.utc(2026),
      lastSeenAt: _state.lastSeenAt,
    );
  }

  @override
  Future<void> touchLastSeen() async {}
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
  required OnboardingState state,
  List<Task> classicTasks = const [],
  List<CustomList> lists = const [],
  DateTime Function()? now,
}) {
  return ProviderContainer(
    overrides: [
      onboardingRepositoryProvider
          .overrideWithValue(_FakeOnboardingRepository(state)),
      allPrioritizationTasksProvider.overrideWith((ref) async => classicTasks),
      listsProvider.overrideWithValue(lists),
      // Court-circuite la chaîne d'init des listes : la valeur de listsProvider
      // est déjà fournie ci-dessus, on a seulement besoin que l'attente passe.
      ensureListsLoadedProvider.overrideWith((ref) async {}),
      if (now != null) nowProvider.overrideWithValue(now),
    ],
  );
}

void main() {
  group('shouldShowOnboarding — état lu depuis le compte (AC1/AC3)', () {
    test('true : jamais complété (completedAt == null)', () async {
      final c = _container(state: const OnboardingState());
      addTearDown(c.dispose);

      expect(await c.read(shouldShowOnboardingProvider.future), isTrue);
    });

    test('false : complété récemment', () async {
      final now = DateTime.utc(2026, 7, 15);
      final c = _container(
        state: OnboardingState(
          completedAt: DateTime.utc(2026, 1, 1),
          lastSeenAt: DateTime.utc(2026, 7, 10), // il y a 5 jours
        ),
        now: () => now,
      );
      addTearDown(c.dispose);

      expect(await c.read(shouldShowOnboardingProvider.future), isFalse);
    });
  });

  group('shouldShowOnboarding — dormance 90j (AC2/AC4, horloge injectable)', () {
    final completed = DateTime.utc(2025, 1, 1);
    final now = DateTime.utc(2026, 7, 15, 12);

    test('false : dernière connexion il y a 89 jours (< seuil)', () async {
      final c = _container(
        state: OnboardingState(
          completedAt: completed,
          lastSeenAt: now.subtract(const Duration(days: 89)),
        ),
        now: () => now,
      );
      addTearDown(c.dispose);

      expect(await c.read(shouldShowOnboardingProvider.future), isFalse);
    });

    test('true : dernière connexion il y a 91 jours (> seuil)', () async {
      final c = _container(
        state: OnboardingState(
          completedAt: completed,
          lastSeenAt: now.subtract(const Duration(days: 91)),
        ),
        now: () => now,
      );
      addTearDown(c.dispose);

      expect(await c.read(shouldShowOnboardingProvider.future), isTrue);
    });

    test('false : complété mais lastSeenAt absent (pas de repère de dormance)',
        () async {
      final c = _container(
        state: OnboardingState(completedAt: completed),
        now: () => now,
      );
      addTearDown(c.dispose);

      expect(await c.read(shouldShowOnboardingProvider.future), isFalse);
    });
  });

  group('onboardingMode — décidé sur un comptage fiable', () {
    test('real : aucune tâche existante', () async {
      final c = _container(state: const OnboardingState());
      addTearDown(c.dispose);

      expect(await c.read(onboardingModeProvider.future), OnboardingMode.real);
    });

    test('sandbox : au moins une tâche classique', () async {
      final c = _container(
        state: const OnboardingState(),
        classicTasks: [Task(title: 'A')],
      );
      addTearDown(c.dispose);

      expect(
          await c.read(onboardingModeProvider.future), OnboardingMode.sandbox);
    });

    test('sandbox : seulement des items de listes', () async {
      // Le cas qui a causé la corruption : un utilisateur dont toutes les
      // données sont des items de listes doit être classé sandbox.
      final c = _container(
        state: const OnboardingState(),
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
        state: const OnboardingState(),
        classicTasks: [Task(title: 'A'), Task(title: 'B')],
        lists: [_listWithItems(3)],
      );
      addTearDown(c.dispose);

      expect(await c.read(totalTaskCountProvider.future), 5);
    });
  });

  group('onboardingMode — attend la fin réelle du chargement des listes (race)',
      () {
    // Régression : sans attente de la fin du bootstrap du contrôleur, le
    // `loadLists()` explicite de `ensureListsLoadedProvider` est un no-op
    // silencieux (garde `!controllerInitialized` de l'executor) tant que le
    // bootstrap n'a pas posé son flag. Le compteur lisait alors des listes
    // vides et classait `real` un utilisateur « listes seules » — la corruption
    // exacte que la story 11.10 combat. Même garde que DuelService.
    test(
      'sandbox : un utilisateur « listes seules » n\'est pas classé real pendant le bootstrap',
      () async {
        // Le bootstrap du contrôleur est bloqué tant que initializeAsync n'est
        // pas résolu : c'est la fenêtre de la race.
        final initGate = Completer<void>();

        final container = ProviderContainer(overrides: [
          allPrioritizationTasksProvider.overrideWith((ref) async => const []),
          listsInitializationManagerProvider
              .overrideWith((_) async => _GatedInitManager(initGate.future)),
          listsPersistenceManagerProvider
              .overrideWith((_) async => _PersistenceManagerWithLists([
                    _listWithItems(2),
                  ])),
        ]);
        addTearDown(container.dispose);

        // Démarre la résolution du mode ; le bootstrap atteint sa porte bloquée.
        final modeFuture = container.read(onboardingModeProvider.future);
        await Future.delayed(const Duration(milliseconds: 20));

        // Débloque le bootstrap : les 2 items de liste deviennent visibles.
        initGate.complete();

        expect(await modeFuture, OnboardingMode.sandbox);
      },
    );
  });
}

/// Manager d'init dont `initializeAsync` reste bloqué jusqu'à [_gate] :
/// reproduit la fenêtre où le contrôleur de listes n'est pas encore initialisé.
class _GatedInitManager implements IListsInitializationManager {
  _GatedInitManager(this._gate);
  final Future<void> _gate;

  @override
  Future<void> initializeAsync() => _gate;

  @override
  Future<void> initializeAdaptive() async {}

  @override
  Future<void> initializeLegacy() async {}

  @override
  bool get isInitialized => false;

  @override
  String get initializationMode => 'gated';
}

class _PersistenceManagerWithLists implements IListsPersistenceManager {
  _PersistenceManagerWithLists(this._lists);
  final List<CustomList> _lists;

  @override
  Future<List<CustomList>> loadAllLists() async => _lists;

  @override
  Future<List<CustomList>> forceReloadFromPersistence() async => _lists;

  @override
  Future<void> saveList(CustomList list) async {}

  @override
  Future<void> updateList(CustomList list) async {}

  @override
  Future<void> deleteList(String listId) async {}

  @override
  Future<List<ListItem>> loadListItems(String listId) async => const [];

  @override
  Future<void> saveListItem(ListItem item) async {}

  @override
  Future<void> updateListItem(ListItem item) async {}

  @override
  Future<void> deleteListItem(String itemId) async {}

  @override
  Future<void> saveMultipleItems(List<ListItem> items,
      {void Function(int, int)? onProgress}) async {}

  @override
  Future<void> clearAllData() async {}

  @override
  Future<void> verifyListPersistence(String listId) async {}

  @override
  Future<void> verifyItemPersistence(String itemId) async {}

  @override
  Future<void> rollbackItems(List<ListItem> items) async {}
}
