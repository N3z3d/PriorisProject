import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/repositories/supabase/supabase_onboarding_repository.dart';
import 'package:prioris/domain/ports/auth_service.dart';
import 'package:prioris/domain/ports/onboarding_repository.dart';
import 'package:prioris/infrastructure/services/supabase_table_adapter.dart';

/// Implémentation in-memory de référence du port : `loadState` doit refléter les
/// écritures `markCompleted` / `touchLastSeen`.
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

/// Auth signé-in figée pour instancier l'adapter Supabase réel.
class _SignedInAuth implements IAuthService {
  @override
  String? get currentUserId => 'user-1';
  @override
  bool get isSignedIn => true;
  @override
  String? get currentUserEmail => 'user@test.dev';
}

/// Fake [SupabaseTableAdapter] mono-ligne, persistant entre les appels `_table()`
/// (une seule instance par repo). Sert à faire passer le **vrai**
/// [SupabaseOnboardingRepository] par les mêmes assertions de contrat.
class _MonoRowTableAdapter extends SupabaseTableAdapter {
  _MonoRowTableAdapter() : super(Object());

  Map<String, dynamic>? row;

  @override
  Future<Map<String, dynamic>?> selectSingle({
    String columns = '*',
    SupabaseQueryBuilderCallback? builder,
  }) async =>
      row == null ? null : Map<String, dynamic>.from(row!);

  @override
  Future<void> insert(Map<String, dynamic> values) async {
    row = Map<String, dynamic>.from(values);
  }

  @override
  Future<void> update({
    required Map<String, dynamic> values,
    SupabaseQueryBuilderCallback? builder,
  }) async {
    row = {...?row, ...values};
  }
}

/// Exécute le contrat du port contre une implémentation donnée. Le même corps de
/// tests couvre le fake in-memory **et** l'adapter Supabase réel : le contrat
/// n'est plus une tautologie sur une réimplémentation, il contraint le code livré.
void _runContractTests(
  String label,
  IOnboardingRepository Function(DateTime Function() now) create,
) {
  group('Contrat IOnboardingRepository — $label', () {
    test('état initial : completedAt et lastSeenAt nuls', () async {
      final repo = create(() => DateTime.utc(2026, 7, 15));
      final state = await repo.loadState();
      expect(state.completedAt, isNull);
      expect(state.lastSeenAt, isNull);
    });

    test('markCompleted → loadState reflète completedAt', () async {
      final now = DateTime.utc(2026, 7, 15, 10);
      final repo = create(() => now);

      await repo.markCompleted();

      final state = await repo.loadState();
      expect(state.completedAt, now);
      expect(state.hasCompleted, isTrue);
    });

    test('markCompleted est idempotent : la première date est conservée',
        () async {
      var clock = DateTime.utc(2026, 7, 15, 10);
      final repo = create(() => clock);

      await repo.markCompleted();
      clock = DateTime.utc(2026, 12, 25, 10); // avance l'horloge
      await repo.markCompleted();

      final state = await repo.loadState();
      expect(state.completedAt, DateTime.utc(2026, 7, 15, 10));
    });

    test('touchLastSeen → loadState reflète le dernier passage', () async {
      var clock = DateTime.utc(2026, 7, 15, 10);
      final repo = create(() => clock);

      await repo.touchLastSeen();
      expect((await repo.loadState()).lastSeenAt, DateTime.utc(2026, 7, 15, 10));

      clock = DateTime.utc(2026, 8, 1, 9);
      await repo.touchLastSeen();
      expect((await repo.loadState()).lastSeenAt, DateTime.utc(2026, 8, 1, 9));
    });
  });
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

  _runContractTests(
    'fake in-memory',
    (now) => _InMemoryOnboardingRepository(now),
  );

  _runContractTests('adapter Supabase (fake table)', (now) {
    final table = _MonoRowTableAdapter();
    return SupabaseOnboardingRepository(
      authService: _SignedInAuth(),
      tableFactory: (service, tableName) => table,
      now: now,
    );
  });
}
