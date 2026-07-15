import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/repositories/supabase/supabase_onboarding_repository.dart';
import 'package:prioris/domain/ports/auth_service.dart';
import 'package:prioris/infrastructure/services/supabase_table_adapter.dart';

/// Auth signé-in figée pour les tests.
class _SignedInAuth implements IAuthService {
  _SignedInAuth(this.currentUserId);
  @override
  final String? currentUserId;
  @override
  bool get isSignedIn => true;
  @override
  String? get currentUserEmail => 'user@test.dev';
}

/// Faux [SupabaseTableAdapter] simulant une table mono-ligne (une par
/// utilisateur). Exécute le `builder` contre une requête enregistreuse pour
/// **asservir le scoping** `.eq('user_id', ...)` — le cœur sécurité de la story.
class _FakeTableAdapter extends SupabaseTableAdapter {
  _FakeTableAdapter() : super(Object());

  Map<String, dynamic>? row;
  final List<Map<String, dynamic>> inserts = [];
  final List<Map<String, dynamic>> updates = [];

  /// Filtres `.eq(colonne, valeur)` capturés depuis les `builder`.
  final List<({String column, Object? value})> eqFilters = [];

  void _capture(SupabaseQueryBuilderCallback? builder) {
    if (builder != null) builder(_RecordingQuery(eqFilters));
  }

  @override
  Future<Map<String, dynamic>?> selectSingle({
    String columns = '*',
    SupabaseQueryBuilderCallback? builder,
  }) async {
    _capture(builder);
    return row == null ? null : Map<String, dynamic>.from(row!);
  }

  @override
  Future<void> insert(Map<String, dynamic> values) async {
    inserts.add(Map<String, dynamic>.from(values));
    row = Map<String, dynamic>.from(values);
  }

  @override
  Future<void> update({
    required Map<String, dynamic> values,
    SupabaseQueryBuilderCallback? builder,
  }) async {
    _capture(builder);
    updates.add(Map<String, dynamic>.from(values));
    row = {...?row, ...values};
  }
}

/// Requête factice enregistrant les appels `.eq(...)` du `builder`.
class _RecordingQuery {
  _RecordingQuery(this._sink);
  final List<({String column, Object? value})> _sink;

  dynamic eq(String column, dynamic value) {
    _sink.add((column: column, value: value));
    return this;
  }
}

SupabaseOnboardingRepository _repo(
  _FakeTableAdapter table, {
  IAuthService? auth,
  DateTime Function()? now,
}) {
  return SupabaseOnboardingRepository(
    authService: auth ?? _SignedInAuth('user-1'),
    tableFactory: (service, tableName) => table,
    now: now,
  );
}

void main() {
  group('SupabaseOnboardingRepository', () {
    test('loadState : ligne absente → état vide', () async {
      final table = _FakeTableAdapter();
      final state = await _repo(table).loadState();
      expect(state.completedAt, isNull);
      expect(state.lastSeenAt, isNull);
    });

    test('loadState : mappe completed_at et last_seen_at (colonnes → VO)',
        () async {
      final table = _FakeTableAdapter()
        ..row = {
          'user_id': 'user-1',
          'completed_at': '2026-07-15T10:00:00.000Z',
          'last_seen_at': '2026-07-20T08:30:00.000Z',
        };

      final state = await _repo(table).loadState();

      expect(state.completedAt, DateTime.utc(2026, 7, 15, 10));
      expect(state.lastSeenAt, DateTime.utc(2026, 7, 20, 8, 30));
    });

    test('markCompleted : insère completed_at avec le bon user_id', () async {
      final table = _FakeTableAdapter();
      final now = DateTime.utc(2026, 7, 15, 12);

      await _repo(table, auth: _SignedInAuth('user-42'), now: () => now)
          .markCompleted();

      expect(table.inserts, hasLength(1));
      final inserted = table.inserts.single;
      expect(inserted['user_id'], 'user-42');
      expect(inserted['completed_at'], now.toIso8601String());
    });

    test('markCompleted : idempotent, ne réécrit pas une complétion existante',
        () async {
      final table = _FakeTableAdapter()
        ..row = {
          'user_id': 'user-1',
          'completed_at': '2026-01-01T00:00:00.000Z',
          'last_seen_at': '2026-01-01T00:00:00.000Z',
        };

      await _repo(table, now: () => DateTime.utc(2026, 7, 15)).markCompleted();

      // Aucune écriture : la date de complétion d'origine est préservée.
      expect(table.inserts, isEmpty);
      expect(table.updates, isEmpty);
      expect(table.row!['completed_at'], '2026-01-01T00:00:00.000Z');
    });

    test('touchLastSeen : met à jour last_seen_at sur une ligne existante',
        () async {
      final table = _FakeTableAdapter()
        ..row = {
          'user_id': 'user-1',
          'completed_at': '2026-01-01T00:00:00.000Z',
          'last_seen_at': '2026-01-01T00:00:00.000Z',
        };
      final now = DateTime.utc(2026, 7, 15, 9);

      await _repo(table, now: () => now).touchLastSeen();

      expect(table.updates, hasLength(1));
      expect(table.updates.single['last_seen_at'], now.toIso8601String());
    });

    test('touchLastSeen : crée la ligne si absente', () async {
      final table = _FakeTableAdapter();
      final now = DateTime.utc(2026, 7, 15, 9);

      await _repo(table, auth: _SignedInAuth('user-7'), now: () => now)
          .touchLastSeen();

      expect(table.inserts, hasLength(1));
      expect(table.inserts.single['user_id'], 'user-7');
      expect(table.inserts.single['last_seen_at'], now.toIso8601String());
    });

    test(
        'markCompleted : ligne pré-existante sans completed_at → update (pas insert)',
        () async {
      // Vrai chemin nouveau-compte : le gate a créé la ligne via touchLastSeen,
      // puis l'utilisateur termine l'onboarding → completed_at posé par update.
      final table = _FakeTableAdapter()
        ..row = {
          'user_id': 'user-1',
          'last_seen_at': '2026-07-01T00:00:00.000Z',
        };
      final now = DateTime.utc(2026, 7, 15, 12);

      await _repo(table, now: () => now).markCompleted();

      expect(table.inserts, isEmpty);
      expect(table.updates, hasLength(1));
      expect(table.updates.single['completed_at'], now.toIso8601String());
    });

    test('scoping : les écritures/lectures filtrent user_id = compte courant',
        () async {
      final table = _FakeTableAdapter();
      final repo = _repo(table, auth: _SignedInAuth('user-99'));

      await repo.loadState(); // selectSingle
      await repo.touchLastSeen(); // insert (ligne absente) → pas d'eq
      table.row = {'user_id': 'user-99', 'last_seen_at': 'x'};
      await repo.touchLastSeen(); // update → eq

      expect(
        table.eqFilters,
        everyElement(
          predicate<({String column, Object? value})>(
            (f) => f.column == 'user_id' && f.value == 'user-99',
            'filtre user_id = user-99',
          ),
        ),
      );
      expect(
        table.eqFilters,
        contains((column: 'user_id', value: 'user-99')),
      );
    });

    test('sans authentification → lève une erreur d\'authentification',
        () async {
      final table = _FakeTableAdapter();
      final repo = _repo(table, auth: const NullAuthService());

      final authError = throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('not authenticated'),
        ),
      );
      expect(repo.loadState(), authError);
      expect(repo.markCompleted(), authError);
      expect(repo.touchLastSeen(), authError);
    });
  });
}
