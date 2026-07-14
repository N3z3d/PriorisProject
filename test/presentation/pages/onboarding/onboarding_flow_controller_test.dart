import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/providers/onboarding_providers.dart';
import 'package:prioris/data/repositories/task_repository.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/ports/onboarding_repository.dart';
import 'package:prioris/presentation/pages/duel/services/duel_service.dart';
import 'package:prioris/presentation/pages/onboarding/controllers/onboarding_flow_controller.dart';
import 'package:prioris/presentation/pages/onboarding/services/onboarding_persistence.dart';

class _FakeOnboardingRepository implements IOnboardingRepository {
  bool completed = false;
  int markCompletedCalls = 0;

  @override
  Future<bool> hasCompletedOnboarding() async => completed;

  @override
  Future<void> markCompleted() async {
    markCompletedCalls++;
    completed = true;
  }
}

class _FakeDuelService implements DuelFlowService {
  int processWinnerCalls = 0;
  int updateTaskCalls = 0;
  int loadDuelTasksCalls = 0;

  /// Les tâches « personnelles » préexistantes de l'utilisateur. Si le
  /// contrôleur les tire (bug d'origine), elles apparaîtront dans les paires.
  @override
  Future<List<Task>> loadDuelTasks({required int count}) async {
    loadDuelTasksCalls++;
    return [Task(title: 'TACHE PERSO 1'), Task(title: 'TACHE PERSO 2')];
  }

  @override
  Future<void> processWinner(Task winner, Task loser) async {
    processWinnerCalls++;
  }

  @override
  Future<void> updateTask(Task task) async {
    updateTaskCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

/// Repository de tâches à compteurs : prouve l'AC6 (0 écriture en sandbox).
class _SpyTaskRepository implements TaskRepository {
  int saveCount = 0;
  int updateCount = 0;

  @override
  Future<List<Task>> getAllTasks() async => const [];

  @override
  Future<void> saveTask(Task task) async {
    saveCount++;
  }

  @override
  Future<void> updateTask(Task task) async {
    updateCount++;
  }

  @override
  Future<void> updateEloScores(Task winner, Task loser) async {
    updateCount += 2;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

class _SpyListsWriter implements OnboardingListsWriter {
  final List<CustomList> createdLists = [];
  final List<ListItem> addedItems = [];
  final List<ListItem> updatedItems = [];

  @override
  Future<void> createList(CustomList list) async => createdLists.add(list);

  @override
  Future<void> addMultipleItems(String listId, List<ListItem> items) async =>
      addedItems.addAll(items);

  @override
  Future<void> updateListItem(String listId, ListItem item) async =>
      updatedItems.add(item);
}

void main() {
  late _FakeOnboardingRepository fakeRepo;
  late _FakeDuelService fakeDuel;
  late _SpyTaskRepository spyTasks;
  late _SpyListsWriter spyWriter;
  late ProviderContainer container;

  /// Monte le contrôleur dans le mode demandé, avec toutes les écritures
  /// espionnées. `Random` est graine fixe : les paires de duel sont
  /// déterministes.
  void build(OnboardingMode mode) {
    fakeRepo = _FakeOnboardingRepository();
    fakeDuel = _FakeDuelService();
    spyTasks = _SpyTaskRepository();
    spyWriter = _SpyListsWriter();
    container = ProviderContainer(
      overrides: [
        onboardingModeProvider.overrideWith((ref) async => mode),
        onboardingListsWriterProvider.overrideWithValue(spyWriter),
        taskRepositoryProvider.overrideWithValue(spyTasks),
        onboardingFlowControllerProvider.overrideWith(
          (ref) => OnboardingFlowController(
            ref,
            duelService: fakeDuel,
            onboardingRepository: fakeRepo,
            random: math.Random(42),
          ),
        ),
      ],
    );
    final sub = container.listen(onboardingFlowControllerProvider, (_, __) {});
    addTearDown(sub.close);
    addTearDown(container.dispose);
  }

  OnboardingFlowController controller() =>
      container.read(onboardingFlowControllerProvider.notifier);
  OnboardingFlowState state() =>
      container.read(onboardingFlowControllerProvider);

  Future<void> capture(String raw) =>
      controller().submitCapturedTasks(raw, listName: 'Mes priorités');

  /// Joue les 5 duels en choisissant toujours la carte de gauche.
  Future<void> playAllDuels() async {
    for (var i = 0; i < OnboardingFlowController.totalDuels; i++) {
      final pair = state().currentPair;
      await controller().recordDuelChoice(pair[0], pair[1]);
    }
  }

  group('OnboardingFlowController — parcours commun', () {
    setUp(() => build(OnboardingMode.real));

    test('parse + dédup insensible à la casse lors de la capture', () async {
      await capture('Sport\nCourses\n sport \n\nAppeler\nSport');

      expect(controller().capturedTasks.map((t) => t.title),
          ['Sport', 'Courses', 'Appeler']);
    });

    test('transition capture → duel dès 5 tâches', () async {
      await capture('A\nB\nC\nD\nE');

      expect(state().step, OnboardingStep.duel);
      expect(state().currentPair.length, 2);
      expect(state().duelIndex, 0);
    });

    test('moins de 2 tâches : reste en capture', () async {
      await capture('Seule');

      expect(state().step, OnboardingStep.capture);
    });

    test('5 lignes mais 1 seul titre unique : reste en capture, pas de reveal',
        () async {
      // Doublons massifs : la dédup ramène sous le minimum technique → la garde
      // doit bloquer (ni duel, ni reveal, ni faux activation event).
      await capture('a\na\nA\na\na');

      expect(state().step, OnboardingStep.capture);
      expect(state().revealedTask, isNull);
      expect(fakeDuel.processWinnerCalls, 0);
    });

    test('transition duel → reveal après 5 duels', () async {
      await capture('A\nB\nC\nD\nE');
      await playAllDuels();

      expect(state().step, OnboardingStep.reveal);
      expect(state().revealedTask, isNotNull);
      expect(fakeDuel.processWinnerCalls, OnboardingFlowController.totalDuels);
    });

    test('reveal persiste le flag de façon atomique', () async {
      // Le flag doit être écrit dès l'entrée au reveal — pas seulement au tap
      // « Continuer » — pour qu'une fermeture au moment révélateur ne réaffiche
      // pas l'onboarding au prochain lancement.
      await capture('A\nB\nC\nD\nE');
      await playAllDuels();

      expect(state().step, OnboardingStep.reveal);
      expect(fakeRepo.markCompletedCalls, 1);
      expect(fakeRepo.completed, isTrue);
    });

    test('completeOnboarding appelle markCompleted et marque finished',
        () async {
      await controller().completeOnboarding();

      expect(fakeRepo.markCompletedCalls, 1);
      expect(fakeRepo.completed, isTrue);
      expect(state().finished, isTrue);
      expect(state().isProcessing, isFalse);
    });

    test('completeOnboarding ré-entrant : second appel concurrent ignoré',
        () async {
      // Deux taps concurrents (non attendus) → un seul markCompleted grâce à la
      // garde isProcessing.
      final first = controller().completeOnboarding();
      final second = controller().completeOnboarding();
      await Future.wait([first, second]);

      expect(fakeRepo.markCompletedCalls, 1);
    });
  });

  group('Isolation des duels (AC3)', () {
    setUp(() => build(OnboardingMode.real));

    test('les duels ne tirent jamais dans les tâches préexistantes', () async {
      await capture('A\nB\nC\nD\nE');

      final capturedTitles =
          controller().capturedTasks.map((t) => t.title).toSet();
      for (var i = 0; i < OnboardingFlowController.totalDuels; i++) {
        final pair = state().currentPair;
        expect(pair.map((t) => t.title), everyElement(isIn(capturedTitles)),
            reason: 'une tâche hors onboarding est entrée dans un duel');
        await controller().recordDuelChoice(pair[0], pair[1]);
      }

      // La source « toutes les tâches de l'utilisateur » ne doit plus être lue.
      expect(fakeDuel.loadDuelTasksCalls, 0);
    });

    test('une paire ne contient jamais deux fois la même tâche', () async {
      await capture('A\nB\nC\nD\nE');

      for (var i = 0; i < OnboardingFlowController.totalDuels; i++) {
        final pair = state().currentPair;
        expect(pair[0].id, isNot(pair[1].id));
        await controller().recordDuelChoice(pair[0], pair[1]);
      }
    });
  });

  group('Reveal = vainqueur réel des duels (AC4)', () {
    setUp(() => build(OnboardingMode.real));

    test('la tâche révélée est celle de meilleur ELO parmi les tâches captées',
        () async {
      await capture('A\nB\nC\nD\nE');
      await playAllDuels();

      final best = controller()
          .capturedTasks
          .reduce((a, b) => a.eloScore >= b.eloScore ? a : b);
      expect(state().revealedTask!.id, best.id);
      // Garde-fou : sans mise à jour ELO, toutes les tâches restent à 1200 et
      // `reduce` renverrait simplement la première — le bug d'origine.
      expect(best.eloScore, greaterThan(1200.0));
    });

    test('un duel met à jour l\'ELO des deux tâches captées', () async {
      await capture('A\nB\nC\nD\nE');
      final pair = state().currentPair;

      await controller().recordDuelChoice(pair[0], pair[1]);

      final captured = {
        for (final t in controller().capturedTasks) t.id: t.eloScore
      };
      // K=32, scores égaux (1200) → probabilité 0.5 → ±16. Épingle la formule :
      // le mode réel et le mode sandbox doivent produire exactement ceci.
      expect(captured[pair[0].id], closeTo(1216.0, 0.001));
      expect(captured[pair[1].id], closeTo(1184.0, 0.001));
    });
  });

  group('Mode réel : les tâches saisies sont visibles (AC2)', () {
    setUp(() => build(OnboardingMode.real));

    test('une liste dédiée est créée avec les tâches saisies', () async {
      await capture('A\nB\nC\nD\nE');

      expect(spyWriter.createdLists, hasLength(1));
      expect(spyWriter.createdLists.single.name, 'Mes priorités');
      expect(spyWriter.addedItems.map((i) => i.title), ['A', 'B', 'C', 'D', 'E']);
      // Plus aucune Task classique : elles seraient invisibles (tasks_page est
      // du code mort, aucune route ne la monte).
      expect(spyTasks.saveCount, 0);
    });

    test('markRevealedTaskDone coche l\'item dans la liste', () async {
      await capture('A\nB\nC\nD\nE');
      await playAllDuels();

      await controller().markRevealedTaskDoneAndComplete();

      expect(spyWriter.updatedItems, hasLength(1));
      expect(spyWriter.updatedItems.single.isCompleted, isTrue);
      expect(spyWriter.updatedItems.single.id, state().revealedTask!.id);
      expect(state().finished, isTrue);
    });
  });

  group('Mode sandbox : zéro écriture (AC1, AC6)', () {
    setUp(() => build(OnboardingMode.sandbox));

    test('le parcours complet n\'écrit rien dans les données de l\'utilisateur',
        () async {
      await capture('A\nB\nC\nD\nE');
      await playAllDuels();
      await controller().markRevealedTaskDoneAndComplete();

      expect(state().step, OnboardingStep.reveal);
      expect(state().revealedTask, isNotNull);

      // Aucune tâche créée, aucun ELO persisté, aucune liste touchée.
      expect(spyTasks.saveCount, 0);
      expect(spyTasks.updateCount, 0);
      expect(fakeDuel.processWinnerCalls, 0);
      expect(fakeDuel.updateTaskCalls, 0);
      expect(spyWriter.createdLists, isEmpty);
      expect(spyWriter.addedItems, isEmpty);
      expect(spyWriter.updatedItems, isEmpty);
    });

    test('le flag d\'onboarding complété reste écrit (seule écriture légitime)',
        () async {
      await capture('A\nB\nC\nD\nE');
      await playAllDuels();

      // Sans ce flag, l'utilisateur existant se refarait l'onboarding à chaque
      // lancement.
      expect(fakeRepo.completed, isTrue);
    });

    test('le reveal reste le vainqueur réel des duels (démonstration du geste)',
        () async {
      await capture('A\nB\nC\nD\nE');
      await playAllDuels();

      final best = controller()
          .capturedTasks
          .reduce((a, b) => a.eloScore >= b.eloScore ? a : b);
      expect(state().revealedTask!.id, best.id);
      expect(best.eloScore, greaterThan(1200.0));
    });
  });
}
