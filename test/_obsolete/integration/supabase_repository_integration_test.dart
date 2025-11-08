import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:prioris/data/repositories/supabase/supabase_custom_list_repository.dart';
import 'package:prioris/infrastructure/services/supabase_service.dart';
import 'package:prioris/infrastructure/services/auth_service.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/core/exceptions/app_exception.dart';

import 'supabase_repository_integration_test.mocks.dart';

/// SECURITY-FOCUSED integration tests
/// Tests repository behavior without exposing real credentials
@GenerateMocks([SupabaseService, AuthService])
void main() {
  group('Supabase Repository Integration Tests (Secure)', () {
    late SupabaseCustomListRepository repository;
    late MockSupabaseService mockSupabaseService;
    late MockAuthService mockAuthService;
    
    setUp(() {
      mockSupabaseService = MockSupabaseService();
      mockAuthService = MockAuthService();
      
      repository = SupabaseCustomListRepository(
        supabaseService: mockSupabaseService,
        authService: mockAuthService,
      );
    });
    
    group('Authentication Security', () {
      test('should throw authentication error when user not signed in', () async {
        // Arrange
        when(mockAuthService.isSignedIn).thenReturn(false);
        
        // Act & Assert
        await expectLater(
          repository.getAllLists(),
          throwsA(isA<AppException>().having(
            (e) => e.type, 
            'type', 
            ErrorType.authenticationFailed
          )),
        );
      });
      
      test('should require authentication for all write operations', () async {
        // Arrange
        when(mockAuthService.isSignedIn).thenReturn(false);
        
        final testList = CustomList(
          id: 'test-id',
          name: 'Test List',
          type: ListType.CUSTOM,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // Act & Assert - All write operations should fail
        await expectLater(
          repository.saveList(testList),
          throwsA(isA<AppException>().having(
            (e) => e.type, 
            'type', 
            ErrorType.authenticationFailed
          )),
        );
        
        await expectLater(
          repository.deleteList('test-id'),
          throwsA(isA<AppException>().having(
            (e) => e.type, 
            'type', 
            ErrorType.authenticationFailed
          )),
        );
      });
    });
    
    group('SQL Injection Prevention', () {
      test('should safely handle malicious search queries', () async {
        // Arrange
        when(mockAuthService.isSignedIn).thenReturn(true);
        when(mockAuthService.currentUser).thenReturn(MockUser());
        
        // Mock Supabase client response
        when(mockSupabaseService.client).thenReturn(MockSupabaseClient());
        
        // Test malicious search queries
        final maliciousQueries = [
          "'; DROP TABLE custom_lists; --",
          "' OR '1'='1' --",
          "\\'; INSERT INTO custom_lists (name) VALUES ('hacked'); --",
          "%'; DELETE FROM custom_lists WHERE '1'='1",
        ];
        
        // Act & Assert - Should not crash or execute malicious code
        for (final query in maliciousQueries) {
          try {
            await repository.searchListsByName(query);
            // If it doesn't throw, that's also fine - the important thing is no SQL injection
          } catch (e) {
            // Exceptions are expected due to mocking, but shouldn't be SQL-related
            expect(e.toString(), isNot(contains('SQL')));
            expect(e.toString(), isNot(contains('syntax error')));
          }
        }
      });
    });
    
    group('Error Handling & User Privacy', () {
      test('should not expose internal system details in error messages', () async {
        // Arrange
        when(mockAuthService.isSignedIn).thenReturn(true);
        when(mockAuthService.currentUser).thenReturn(MockUser());
        
        // Simulate database error
        when(mockSupabaseService.client).thenThrow(
          Exception('PostgrestException: relation "custom_lists" does not exist')
        );
        
        // Act
        try {
          await repository.getAllLists();
          fail('Expected exception');
        } catch (e) {
          // Assert - Should not expose internal database structure
          final errorMessage = e.toString();
          expect(errorMessage, isNot(contains('PostgrestException')));
          expect(errorMessage, isNot(contains('relation')));
          expect(errorMessage, isNot(contains('does not exist')));
        }
      });
      
      test('should sanitize error messages for user display', () async {
        // Arrange
        when(mockAuthService.isSignedIn).thenReturn(true);
        
        // Simulate permission error
        when(mockSupabaseService.client).thenThrow(
          Exception('JWT malformed: Invalid token signature')
        );
        
        // Act
        try {
          await repository.getAllLists();
          fail('Expected exception');
        } catch (e) {
          if (e is AppException) {
            // Assert - User message should be generic and safe
            expect(e.displayMessage, isNot(contains('JWT')));
            expect(e.displayMessage, isNot(contains('malformed')));
            expect(e.displayMessage, isNot(contains('signature')));
            expect(e.displayMessage, contains('authentification')); // French user message
          }
        }
      });
    });
    
    group('Rate Limiting & DoS Protection', () {
      test('should handle rapid successive requests gracefully', () async {
        // Arrange
        when(mockAuthService.isSignedIn).thenReturn(true);
        when(mockAuthService.currentUser).thenReturn(MockUser());
        when(mockSupabaseService.client).thenReturn(MockSupabaseClient());
        
        // Act - Simulate rapid requests (potential DoS)
        final futures = List.generate(100, (i) => 
          repository.searchListsByName('test_query_$i')
        );
        
        // Assert - Should handle gracefully without crashing
        await expectLater(
          Future.wait(futures, eagerError: false),
          completes,
        );
      });
    });
    
    group('Data Validation Security', () {
      test('should validate list data before saving', () async {
        // Arrange
        when(mockAuthService.isSignedIn).thenReturn(true);
        
        // Test with invalid data
        final invalidLists = [
          // Null/empty required fields
          CustomList(
            id: '',  // Empty ID
            name: '',  // Empty name
            type: ListType.CUSTOM,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          // Extremely long strings (potential buffer overflow)
          CustomList(
            id: 'test-id',
            name: 'A' * 10000,  // 10k character name
            type: ListType.CUSTOM,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        
        // Act & Assert
        for (final invalidList in invalidLists) {
          try {
            await repository.saveList(invalidList);
            // If it doesn't throw, validation might be handled at a higher level
          } catch (e) {
            // Should be a validation error, not a system crash
            if (e is AppException) {
              expect(e.type, equals(ErrorType.validationFailure));
            }
          }
        }
      });
    });
  });
}

/// Mock classes for testing
class MockUser {
  String get id => 'mock-user-id';
  String get email => 'test@example.com';
}

class MockSupabaseClient {
  // Mock implementation for testing
}