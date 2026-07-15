import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/ports/onboarding_repository.dart';

/// Implémentation in-memory servant à vérifier le *contrat* du port, sans
/// infrastructure : `loadState` doit refléter les écritures `markCompleted` /
/// `touchLastSeen`. Toute implémentation concrète (Supabase) doit respecter ce
/// contrat.
class _InMemoryOnboardingRepository implements IOnboardingRepository {
  _InMemoryOnboardingRepository(this._now);
  final DateTime Function() _now;

  DateTime? _completedAt;
  DateTime? _lastSeenAt;

  @override
  Future<OnboardingState> loadState() async =>
      OnboardingState(completedAt: _completedAt, lastSeenAt: _lastSeenAt);

  @override
  Future<void> markCompleted() async {
    final now = _now();
    _completedAt ??= now; // idempotent : ne réécrit pas la première date.
    _lastSeenAt ??= now;
  }

  @override
  Future<void> touchLastSeen() async {
    _lastSeenAt = _now();
  }
}

void main() {
  group('OnboardingState (value object)', () {
    test('par défaut : jamais complété, jamais vu', () {
      const state = OnboardingState();
      expect(state.completedAt, isNull);
      expect(state.lastSeenAt, isNull);
      expect(state.hasCompleted, isFalse);
    });

    test('hasCompleted vrai dès que completedAt est posé', () {
      final state = OnboardingState(completedAt: DateTime.utc(2026, 1, 1));
      expect(state.hasCompleted, isTrue);
    });
  });

  group('Contrat IOnboardingRepository (fake in-memory)', () {
    test('état initial : completedAt et lastSeenAt nuls', () async {
      final repo = _InMemoryOnboardingRepository(() => DateTime.utc(2026, 7, 15));
      final state = await repo.loadState();
      expect(state.completedAt, isNull);
      expect(state.lastSeenAt, isNull);
    });

    test('markCompleted → loadState reflète completedAt', () async {
      final now = DateTime.utc(2026, 7, 15, 10);
      final repo = _InMemoryOnboardingRepository(() => now);

      await repo.markCompleted();

      final state = await repo.loadState();
      expect(state.completedAt, now);
      expect(state.hasCompleted, isTrue);
    });

    test('markCompleted est idempotent : la première date est conservée',
        () async {
      var clock = DateTime.utc(2026, 7, 15, 10);
      final repo = _InMemoryOnboardingRepository(() => clock);

      await repo.markCompleted();
      clock = DateTime.utc(2026, 12, 25, 10); // avance l'horloge
      await repo.markCompleted();

      final state = await repo.loadState();
      expect(state.completedAt, DateTime.utc(2026, 7, 15, 10));
    });

    test('touchLastSeen → loadState reflète le dernier passage', () async {
      var clock = DateTime.utc(2026, 7, 15, 10);
      final repo = _InMemoryOnboardingRepository(() => clock);

      await repo.touchLastSeen();
      expect((await repo.loadState()).lastSeenAt, DateTime.utc(2026, 7, 15, 10));

      clock = DateTime.utc(2026, 8, 1, 9);
      await repo.touchLastSeen();
      expect((await repo.loadState()).lastSeenAt, DateTime.utc(2026, 8, 1, 9));
    });
  });
}
