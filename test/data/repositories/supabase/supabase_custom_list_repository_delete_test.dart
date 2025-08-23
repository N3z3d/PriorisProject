import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/data/repositories/supabase/supabase_custom_list_repository.dart';
import 'package:prioris/infrastructure/services/supabase_service.dart';
import 'package:prioris/infrastructure/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_custom_list_repository_delete_test.mocks.dart';

/// Tests unitaires pour la suppression de listes avec Supabase
/// 
/// Ces tests valident que :
/// 1. La suppression locale fonctionne (soft delete)
/// 2. La suppression cloud respecte les politiques RLS
/// 3. Les erreurs sont gérées correctement
/// 4. L'authentification est vérifiée

@GenerateMocks([
  SupabaseService,
  AuthService,
  SupabaseClient,
  PostgrestFilterBuilder,
  User,
])
void main() {
  group('SupabaseCustomListRepository - Delete Tests', () {
    late SupabaseCustomListRepository repository;
    late MockSupabaseService mockSupabaseService;
    late MockAuthService mockAuthService;
    late MockSupabaseClient mockClient;
    late MockPostgrestFilterBuilder mockFilterBuilder;
    late MockUser mockUser;

    const testUserId = 'da9670fc-6417-4a97-a29c-9cdf46c7bd2a';
    const testListId = '8705e0f2-775a-4b9a-9d17-59bd53e1e475';
    const testEmail = 'test@example.com';

    setUp(() {
      mockSupabaseService = MockSupabaseService();
      mockAuthService = MockAuthService();
      mockClient = MockSupabaseClient();
      mockFilterBuilder = MockPostgrestFilterBuilder();
      mockUser = MockUser();

      // Configuration des mocks par défaut
      when(mockSupabaseService.client).thenReturn(mockClient);
      when(mockAuthService.isSignedIn).thenReturn(true);
      when(mockAuthService.currentUser).thenReturn(mockUser);
      when(mockUser.id).thenReturn(testUserId);
      when(mockUser.email).thenReturn(testEmail);

      // Injection manuelle des mocks (simulation DI)
      SupabaseService.instance = mockSupabaseService;
      AuthService.instance = mockAuthService;

      repository = SupabaseCustomListRepository();
    });

    tearDown(() {
      // Nettoyer les singletons après chaque test
      reset(mockSupabaseService);
      reset(mockAuthService);
      reset(mockClient);
      reset(mockFilterBuilder);
      reset(mockUser);
    });

    group('deleteList - Tests de base', () {
      test('DOIT réussir la suppression quand utilisateur authentifié', () async {
        // Arrange
        when(mockClient.from('custom_lists'))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.update(any))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', testListId))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('user_id', testUserId))
            .thenReturn(mockFilterBuilder);

        // Act & Assert - Ne doit pas lancer d'exception
        await expectLater(
          repository.deleteList(testListId),
          completes,
        );

        // Vérifications
        verify(mockClient.from('custom_lists')).called(1);
        verify(mockFilterBuilder.update({
          'is_deleted': true,
        })).called(1);
        verify(mockFilterBuilder.eq('id', testListId)).called(1);
        verify(mockFilterBuilder.eq('user_id', testUserId)).called(1);
      });

      test('DOIT échouer quand utilisateur non authentifié', () async {
        // Arrange
        when(mockAuthService.isSignedIn).thenReturn(false);

        // Act & Assert
        await expectLater(
          repository.deleteList(testListId),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('User not authenticated'),
          )),
        );

        // Vérifications
        verifyNever(mockClient.from(any));
      });

      test('DOIT échouer quand currentUser est null', () async {
        // Arrange
        when(mockAuthService.isSignedIn).thenReturn(true);
        when(mockAuthService.currentUser).thenReturn(null);

        // Act & Assert
        await expectLater(
          repository.deleteList(testListId),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('deleteList - Tests des erreurs Supabase', () {
      test('DOIT gérer les erreurs RLS (42501)', () async {
        // Arrange - Simuler l'erreur RLS exacte
        final rlsException = PostgrestException(
          message: 'new row violates row-level security policy for table "custom_lists"',
          code: '42501',
          details: '',
          hint: null,
        );

        when(mockClient.from('custom_lists'))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.update(any))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', testListId))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('user_id', testUserId))
            .thenThrow(rlsException);

        // Act & Assert
        await expectLater(
          repository.deleteList(testListId),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('Failed to delete list'),
              contains('42501'),
            ),
          )),
        );
      });

      test('DOIT gérer les erreurs de permission (403)', () async {
        // Arrange
        final forbiddenException = PostgrestException(
          message: 'Forbidden',
          code: '403',
          details: '',
          hint: null,
        );

        when(mockClient.from('custom_lists'))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.update(any))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', testListId))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('user_id', testUserId))
            .thenThrow(forbiddenException);

        // Act & Assert
        await expectLater(
          repository.deleteList(testListId),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to delete list'),
          )),
        );
      });

      test('DOIT gérer les erreurs réseau', () async {
        // Arrange
        when(mockClient.from('custom_lists'))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.update(any))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', testListId))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('user_id', testUserId))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        await expectLater(
          repository.deleteList(testListId),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to delete list'),
          )),
        );
      });
    });

    group('deleteList - Tests de validation des données', () {
      test('DOIT échouer avec ID vide', () async {
        // Act & Assert
        await expectLater(
          repository.deleteList(''),
          throwsA(isA<Exception>()),
        );
      });

      test('DOIT échouer avec ID null (si possible)', () async {
        // Note: Dart ne permet pas null pour String, 
        // mais on peut tester un ID invalide
        await expectLater(
          repository.deleteList('invalid-uuid'),
          throwsA(isA<Exception>()),
        );
      });

      test('DOIT utiliser le bon format de soft delete', () async {
        // Arrange
        when(mockClient.from('custom_lists'))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.update(any))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', testListId))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('user_id', testUserId))
            .thenReturn(mockFilterBuilder);

        // Act
        await repository.deleteList(testListId);

        // Assert - Vérifier que c'est bien un soft delete
        verify(mockFilterBuilder.update({
          'is_deleted': true,
        })).called(1);

        // Vérifier qu'on ne fait PAS de hard delete
        verifyNever(mockFilterBuilder.delete());
      });
    });

    group('deleteList - Tests d\'intégration avec AuthService', () {
      test('DOIT utiliser le bon user_id depuis AuthService', () async {
        // Arrange
        const customUserId = 'custom-user-123';
        when(mockUser.id).thenReturn(customUserId);
        
        when(mockClient.from('custom_lists'))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.update(any))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', testListId))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('user_id', customUserId))
            .thenReturn(mockFilterBuilder);

        // Act
        await repository.deleteList(testListId);

        // Assert
        verify(mockFilterBuilder.eq('user_id', customUserId)).called(1);
        verifyNever(mockFilterBuilder.eq('user_id', testUserId));
      });

      test('DOIT vérifier l\'authentification à chaque appel', () async {
        // Arrange
        when(mockClient.from('custom_lists'))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.update(any))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', testListId))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('user_id', testUserId))
            .thenReturn(mockFilterBuilder);

        // Act
        await repository.deleteList(testListId);

        // Assert
        verify(mockAuthService.isSignedIn).called(1);
        verify(mockAuthService.currentUser).called(1);
      });
    });
  });
}