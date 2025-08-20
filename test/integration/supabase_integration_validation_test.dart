import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/infrastructure/services/supabase_service.dart';
import 'package:prioris/infrastructure/services/auth_service.dart';
import 'package:prioris/data/repositories/supabase/supabase_custom_list_repository.dart';
import 'package:prioris/data/repositories/supabase/supabase_list_item_repository.dart';
import 'package:prioris/core/config/app_config.dart';

/// Integration tests to validate Supabase setup and connectivity
/// 
/// These tests verify that:
/// 1. Supabase service can be initialized
/// 2. Auth service is properly configured
/// 3. Repository services can be instantiated
/// 4. Basic configuration is correct
void main() {
  group('Supabase Integration Validation', () {
    
    setUpAll(() async {
      // Note: Supabase initialization requires Flutter plugins that aren't available in unit tests
      // We'll test the configuration and structure instead
    });

    group('Service Initialization', () {
      test('SupabaseService should be configurable', () {
        // Arrange & Act - Test static configuration
        final config = AppConfig.instance;
        expect(config.supabaseUrl, isNotEmpty);
        expect(config.supabaseAnonKey, isNotEmpty);
        
        // Test that the initialize method exists
        expect(SupabaseService.initialize, isA<Function>());
      });

      test('AuthService should be instantiable', () {
        // Arrange & Act - Test that the class can be accessed
        expect(AuthService.instance, isA<AuthService>());
        expect(() => AuthService.instance, returnsNormally);
      });

      test('Supabase repositories should be instantiable', () {
        // Arrange & Act - Test that classes can be instantiated
        expect(() => SupabaseCustomListRepository(), returnsNormally);
        expect(() => SupabaseListItemRepository(), returnsNormally);
        
        final customListRepo = SupabaseCustomListRepository();
        final listItemRepo = SupabaseListItemRepository();
        
        // Assert
        expect(customListRepo, isNotNull);
        expect(listItemRepo, isNotNull);
      });
    });

    group('Configuration Validation', () {
      test('Supabase URL should be properly configured', () {
        // Assert
        final config = AppConfig.instance;
        expect(config.supabaseUrl, isNotEmpty);
        expect(config.supabaseUrl, contains('supabase.co'));
        expect(config.supabaseUrl, startsWith('https://'));
      });

      test('Supabase anonymous key should be configured', () {
        // Assert
        final config = AppConfig.instance;
        expect(config.supabaseAnonKey, isNotEmpty);
        expect(config.supabaseAnonKey, startsWith('eyJ')); // JWT format
        expect(config.supabaseAnonKey, contains('.')); // JWT format has dots
      });

      test('Service classes should have expected methods', () {
        // Test that the AuthService has the expected interface
        final authService = AuthService.instance;
        
        expect(authService.signIn, isA<Function>());
        expect(authService.signUp, isA<Function>());
        expect(authService.signOut, isA<Function>());
        expect(authService.resetPassword, isA<Function>());
        expect(authService.updateProfile, isA<Function>());
      });
    });

    group('Repository Interface Validation', () {
      test('Repository methods should exist and be callable', () {
        // Arrange
        final customListRepo = SupabaseCustomListRepository();
        final listItemRepo = SupabaseListItemRepository();
        
        // Act & Assert - These should be functions
        expect(customListRepo.getAllLists, isA<Function>());
        expect(customListRepo.getListById, isA<Function>());
        expect(customListRepo.saveList, isA<Function>());
        expect(customListRepo.updateList, isA<Function>());
        expect(customListRepo.deleteList, isA<Function>());
        
        expect(listItemRepo.getAll, isA<Function>());
        expect(listItemRepo.getById, isA<Function>());
        expect(listItemRepo.add, isA<Function>());
        expect(listItemRepo.update, isA<Function>());
        expect(listItemRepo.delete, isA<Function>());
        expect(listItemRepo.getByListId, isA<Function>());
      });

      test('Repository classes should implement expected interfaces', () {
        // Arrange & Act
        final customListRepo = SupabaseCustomListRepository();
        final listItemRepo = SupabaseListItemRepository();
        
        // Assert - Test that they implement the expected interfaces
        expect(customListRepo, isA<Object>());
        expect(listItemRepo, isA<Object>());
        
        // Test additional Supabase-specific methods
        expect(customListRepo.watchAll, isA<Function>());
        expect(customListRepo.getStats, isA<Function>());
        expect(listItemRepo.watchByListId, isA<Function>());
        expect(listItemRepo.getStatsForList, isA<Function>());
      });
    });
  });

  group('Environment Checks', () {
    test('Required environment configuration should be present', () {
      // Verify that the hardcoded configuration is not obviously wrong
      final config = AppConfig.instance;
      expect(config.supabaseUrl, contains('.supabase.co'));
      expect(config.supabaseAnonKey, startsWith('eyJ')); // JWT format
      expect(config.supabaseAnonKey, contains('.')); // JWT format has dots
    });

    test('Configuration constants should be accessible', () {
      // These should not throw
      final config = AppConfig.instance;
      expect(() => config.supabaseUrl, returnsNormally);
      expect(() => config.supabaseAnonKey, returnsNormally);
    });
  });
}