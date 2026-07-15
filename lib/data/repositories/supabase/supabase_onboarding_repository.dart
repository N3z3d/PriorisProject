import 'package:logger/logger.dart';
import 'package:prioris/domain/ports/auth_service.dart';
import 'package:prioris/domain/ports/onboarding_repository.dart';
import 'package:prioris/infrastructure/services/supabase_service.dart';
import 'package:prioris/infrastructure/services/supabase_table_adapter.dart';

/// Adapter Supabase account-scoped pour l'état d'onboarding.
///
/// Calqué sur [SupabaseHabitRepository] : dépendances injectées, garde
/// `isSignedIn`, filtrage `user_id = currentUserId`. Une ligne par utilisateur
/// dans `onboarding_state` (pas d'`upsert` natif → `selectSingle` puis
/// `insert`/`update`). C'est le pattern « état par compte » que la story 11.7
/// (consentement) réutilisera.
class SupabaseOnboardingRepository implements IOnboardingRepository {
  final SupabaseService _supabase;
  final IAuthService _auth;
  final SupabaseTableAdapterFactory _tableFactory;
  final DateTime Function() _now;
  final Logger _logger;

  static const String _tableName = 'onboarding_state';

  SupabaseOnboardingRepository({
    SupabaseService? supabaseService,
    IAuthService? authService,
    SupabaseTableAdapterFactory? tableFactory,
    DateTime Function()? now,
    Logger? logger,
  })  : _supabase = supabaseService ?? SupabaseService.instance,
        _auth = authService ?? const NullAuthService(),
        _tableFactory = tableFactory ?? defaultSupabaseTableFactory,
        _now = now ?? (() => DateTime.now().toUtc()),
        _logger = logger ?? Logger();

  @override
  Future<OnboardingState> loadState() async {
    final row = await _requireRow();
    if (row == null) return const OnboardingState();
    return OnboardingState(
      completedAt: _parseTimestamp(row['completed_at']),
      lastSeenAt: _parseTimestamp(row['last_seen_at']),
    );
  }

  @override
  Future<void> markCompleted() async {
    final row = await _requireRow();
    // Idempotent : ne jamais réécrire une complétion déjà enregistrée.
    if (row != null && row['completed_at'] != null) return;

    final now = _now().toIso8601String();
    if (row == null) {
      await _table().insert({
        'user_id': _auth.currentUserId!,
        'completed_at': now,
        'last_seen_at': now,
        'updated_at': now,
      });
    } else {
      await _table().update(
        values: {'completed_at': now, 'updated_at': now},
        builder: (query) => query.eq('user_id', _auth.currentUserId!),
      );
    }
    _logger.i('Onboarding marqué complété pour ${_auth.currentUserId}');
  }

  @override
  Future<void> touchLastSeen() async {
    final row = await _requireRow();
    final now = _now().toIso8601String();
    if (row == null) {
      await _table().insert({
        'user_id': _auth.currentUserId!,
        'last_seen_at': now,
        'updated_at': now,
      });
    } else {
      await _table().update(
        values: {'last_seen_at': now, 'updated_at': now},
        builder: (query) => query.eq('user_id', _auth.currentUserId!),
      );
    }
  }

  /// Charge la ligne du compte courant après avoir garanti l'authentification.
  Future<Map<String, dynamic>?> _requireRow() async {
    if (!_auth.isSignedIn) {
      _logger.w('Accès à onboarding_state sans authentification');
      throw Exception('User not authenticated');
    }
    return _table().selectSingle(
      builder: (query) => query.eq('user_id', _auth.currentUserId!),
    );
  }

  DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    return DateTime.parse(value as String).toUtc();
  }

  SupabaseTableAdapter _table() => _tableFactory(_supabase, _tableName);
}
