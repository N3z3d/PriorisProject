import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:prioris/data/repositories/supabase/supabase_custom_list_repository.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/infrastructure/services/auth_service.dart';
import 'package:prioris/infrastructure/services/supabase_service.dart';
import 'package:prioris/infrastructure/services/supabase_table_adapter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_custom_list_repository_delete_test.mocks.dart';

@GenerateMocks([SupabaseService, AuthService, User])
void main() {
  group('SupabaseCustomListRepository - Delete Tests', () {
    late SupabaseCustomListRepository repository;
    late MockSupabaseService mockSupabaseService;
    late MockAuthService mockAuthService;
    late _RecordingSupabaseTableAdapter tableAdapter;
    late MockUser mockUser;

    const testUserId = 'da9670fc-6417-4a97-a29c-9cdf46c7bd2a';
    const testListId = '8705e0f2-775a-4b9a-9d17-59bd53e1e475';
    const testEmail = 'test@example.com';

    setUp(() {
      mockSupabaseService = MockSupabaseService();
      mockAuthService = MockAuthService();
      tableAdapter = _RecordingSupabaseTableAdapter();
      mockUser = MockUser();

      when(mockAuthService.isSignedIn).thenReturn(true);
      when(mockAuthService.currentUser).thenReturn(mockUser);
      when(mockUser.id).thenReturn(testUserId);
      when(mockUser.email).thenReturn(testEmail);

      repository = SupabaseCustomListRepository(
        supabaseService: mockSupabaseService,
        authService: mockAuthService,
        tableFactory: (_, __) => tableAdapter,
      );
    });

    tearDown(() {
      reset(mockSupabaseService);
      reset(mockAuthService);
      reset(mockUser);
    });

    group('deleteList - Tests de base', () {
      test('DOIT réussir la suppression quand utilisateur authentifié', () async {
        await expectLater(
          repository.deleteList(testListId),
          completes,
        );

        expect(tableAdapter.lastValues, equals({'is_deleted': true}));

        expect(tableAdapter.lastValues, equals({'is_deleted': true}));
        expect(
          tableAdapter.eqCalls
              .where((entry) => entry.key == 'id' && entry.value == testListId),
          isNotEmpty,
        );
        expect(
          tableAdapter.eqCalls
              .where((entry) => entry.key == 'user_id' && entry.value == testUserId),
          isNotEmpty,
        );
      });

      test('DOIT échouer quand utilisateur non authentifié', () async {
        when(mockAuthService.isSignedIn).thenReturn(false);

        await expectLater(
          repository.deleteList(testListId),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('User not authenticated'),
          )),
        );

        expect(tableAdapter.lastValues, isNull);
      });

      test('DOIT échouer quand currentUser est null', () async {
        when(mockAuthService.isSignedIn).thenReturn(true);
        when(mockAuthService.currentUser).thenReturn(null);

        await expectLater(
          repository.deleteList(testListId),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}

class _RecordingSupabaseTableAdapter extends SupabaseTableAdapter {
  _RecordingSupabaseTableAdapter()
      : _query = _DummyQueryBuilder(),
        super(_DummyQueryBuilder());

  Map<String, dynamic>? lastValues;
  SupabaseQueryBuilderCallback? lastBuilder;
  List<MapEntry<String, dynamic>> get eqCalls => _query.eqCalls;

  final _DummyQueryBuilder _query;

  @override
  Future<void> update({
    required Map<String, dynamic> values,
    SupabaseQueryBuilderCallback? builder,
  }) async {
    lastValues = values;
    lastBuilder = builder;
    if (builder != null) {
      final result = builder(_query);
      if (result is Future) {
        await result;
      }
    }
  }
}

class _DummyQueryBuilder {
  final List<MapEntry<String, dynamic>> eqCalls = [];

  dynamic eq(String column, dynamic value) {
    eqCalls.add(MapEntry(column, value));
    return this;
  }

  dynamic select([String? columns]) => this;
  dynamic update(Map<String, dynamic> _) => this;
  dynamic insert(Map<String, dynamic> _) => this;
  dynamic delete() => this;
  dynamic order(String column, {bool ascending = true}) => this;
  dynamic ilike(String column, String pattern) => this;
  Future<List<Map<String, dynamic>>> call() async => [];
  Stream<List<Map<String, dynamic>>> stream({required List<String> primaryKey}) =>
      const Stream.empty();
}
