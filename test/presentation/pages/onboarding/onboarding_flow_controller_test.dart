import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/providers/prioritization_providers.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/ports/onboarding_repository.dart';
import 'package:prioris/presentation/pages/duel/services/duel_service.dart';
import 'package:prioris/presentation/pages/onboarding/controllers/onboarding_flow_controller.dart';

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

  @override
  Future<List<Task>> loadDuelTasks({required int count}) async =>
      [Task(title: 'Gauche'), Task(title: 'Droite')];

  @override
  Future<void> processWinner(Task winner, Task loser) async {
    processWinnerCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

void main() {
  late _FakeOnboardingRepository fakeRepo;
  late _FakeDuelService fakeDuel;
  late ProviderContainer container;

  setUp(() {
    fakeRepo = _FakeOnboardingRepository();
    fakeDuel = _FakeDuelService();
    container = ProviderContainer(
      overrides: [
        onboardingFlowControllerProvider.overrideWith(
          (ref) => OnboardingFlowController(
            ref,
            duelService: fakeDuel,
            onboardingRepository: fakeRepo,
          ),
        ),
      ],
    );
    // Garde le notifier autoDispose vivant pendant le test.
    final sub = container.listen(onboardingFlowControllerProvider, (_, __) {});
    addTearDown(sub.close);
    addTearDown(container.dispose);
  });

  OnboardingFlowController controller() =>
      container.read(onboardingFlowControllerProvider.notifier);
  OnboardingFlowState state() =>
      container.read(onboardingFlowControllerProvider);

  group('OnboardingFlowController', () {
    test('parse + dédup insensible à la casse lors de la capture', () async {
      await controller().submitCapturedTasks('Sport\nCourses\n sport \n\nAppeler\nSport');
      final tasks = await container.read(allPrioritizationTasksProvider.future);
      expect(tasks.map((t) => t.title), ['Sport', 'Courses', 'Appeler']);
    });

    test('transition capture → duel dès 5 tâches', () async {
      await controller().submitCapturedTasks('A\nB\nC\nD\nE');
      expect(state().step, OnboardingStep.duel);
      expect(state().currentPair.length, 2);
      expect(state().duelIndex, 0);
    });

    test('moins de 2 tâches : reste en capture', () async {
      await controller().submitCapturedTasks('Seule');
      expect(state().step, OnboardingStep.capture);
    });

    test('5 lignes mais 1 seul titre unique : reste en capture, pas de reveal',
        () async {
      // Doublons massifs : la dédup ramène sous le minimum technique → la garde
      // doit bloquer (ni duel, ni reveal, ni faux activation event).
      await controller().submitCapturedTasks('a\na\nA\na\na');
      expect(state().step, OnboardingStep.capture);
      expect(state().revealedTask, isNull);
      expect(fakeDuel.processWinnerCalls, 0);
    });

    test('transition duel → reveal après 5 duels', () async {
      await controller().submitCapturedTasks('A\nB\nC\nD\nE');
      for (var i = 0; i < OnboardingFlowController.totalDuels; i++) {
        final pair = state().currentPair;
        await controller().recordDuelChoice(pair[0], pair[1]);
      }
      expect(state().step, OnboardingStep.reveal);
      expect(state().revealedTask, isNotNull);
      expect(fakeDuel.processWinnerCalls, OnboardingFlowController.totalDuels);
    });

    test('reveal persiste le flag de façon atomique (AC4)', () async {
      // Le flag doit être écrit dès l'entrée au reveal — pas seulement au tap
      // « Continuer » — pour qu'une fermeture au moment révélateur ne réaffiche
      // pas l'onboarding au prochain lancement.
      await controller().submitCapturedTasks('A\nB\nC\nD\nE');
      for (var i = 0; i < OnboardingFlowController.totalDuels; i++) {
        final pair = state().currentPair;
        await controller().recordDuelChoice(pair[0], pair[1]);
      }
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
}
