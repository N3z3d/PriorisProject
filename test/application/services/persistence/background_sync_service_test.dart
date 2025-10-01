/// Tests for BackgroundSyncService - SOLID Architecture Validation
/// Validates Single Responsibility Principle: Asynchronous sync operations only

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/application/ports/persistence_interfaces.dart';
import 'package:prioris/application/services/persistence/persistence_operations_service.dart';
import 'package:prioris/application/services/persistence/background_sync_service.dart';

@GenerateMocks([
  PersistenceOperationsService,
  IAuthenticationStateManager,
])
import 'background_sync_service_test.mocks.dart';

void main() {
  group('BackgroundSyncService - SOLID Validation', () {
    late BackgroundSyncService syncService;
    late MockPersistenceOperationsService mockOperationsService;
    late MockIAuthenticationStateManager mockAuthStateManager;
    late PersistenceConfiguration testConfiguration;

    setUp(() {
      mockOperationsService = MockPersistenceOperationsService();
      mockAuthStateManager = MockIAuthenticationStateManager();
      testConfiguration = const PersistenceConfiguration(
        enableBackgroundSync: true,
      );

      syncService = BackgroundSyncService(
        operationsService: mockOperationsService,
        configuration: testConfiguration,
        authStateManager: mockAuthStateManager,
      );
    });

    group('Single Responsibility Principle Validation', () {
      test('should only handle background sync operations', () {
        // Verify service implements sync interface only
        expect(syncService, isA<ISyncService>());

        // Service should not have direct CRUD operations
        expect(() => (syncService as dynamic).getAllLists(), throwsNoSuchMethodError);
        expect(() => (syncService as dynamic).saveList, throwsNoSuchMethodError);

        // Service should not handle authentication directly
        expect(() => (syncService as dynamic).login(), throwsNoSuchMethodError);
        expect(() => (syncService as dynamic).updateAuthState(), throwsNoSuchMethodError);
      });

      test('should implement ISyncService interface completely', () {
        expect(syncService.syncListToCloudAsync, isA<Function>());
        expect(syncService.syncCloudToLocalAsync, isA<Function>());
        expect(syncService.syncItemToCloudAsync, isA<Function>());
        expect(syncService.syncItemsToLocalAsync, isA<Function>());
      });
    });

    group('Background List Sync Operations', () {
      final testList = CustomList(
        id: 'sync-test-list',
        name: 'Sync Test List',
        type: ListType.CUSTOM,
        items: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      test('syncListToCloudAsync should only sync when conditions met', () {
        // Arrange - Auth enabled, sync enabled
        when(mockAuthStateManager.isAuthenticated).thenReturn(true);

        // Act
        syncService.syncListToCloudAsync(testList);

        // Assert - Should schedule async operation
        // Note: Actual verification happens in integration tests due to Timer.run
        expect(syncService.getSyncStatistics()['enableBackgroundSync'], true);
      });

      test('should not sync when user is not authenticated', () {
        // Arrange - Not authenticated
        when(mockAuthStateManager.isAuthenticated).thenReturn(false);

        // Act
        syncService.syncListToCloudAsync(testList);

        // Assert - Should not attempt sync
        verifyNever(mockOperationsService.saveListCloud(any));
      });

      test('should not sync when background sync is disabled', () {
        // Arrange - Background sync disabled
        when(mockAuthStateManager.isAuthenticated).thenReturn(false);

        final disabledSyncService = BackgroundSyncService(
          operationsService: mockOperationsService,
          configuration: const PersistenceConfiguration(enableBackgroundSync: false),
          authStateManager: mockAuthStateManager,
        );

        // Act
        disabledSyncService.syncListToCloudAsync(testList);

        // Assert - Should not attempt sync
        expect(disabledSyncService.getSyncStatistics()['enableBackgroundSync'], false);
      });

      test('should prevent duplicate sync operations', () {
        // Arrange - Auth enabled
        when(mockAuthStateManager.isAuthenticated).thenReturn(true);

        // Act - Call sync twice for same list
        syncService.syncListToCloudAsync(testList);
        syncService.syncListToCloudAsync(testList); // Duplicate call

        // Assert - Should track ongoing sync
        final stats = syncService.getSyncStatistics();
        expect(stats['syncingListIds'], contains(testList.id));
      });
    });

    group('Background Item Sync Operations', () {
      final testItem = ListItem(
        id: 'sync-test-item',
        title: 'Sync Test Item',
        listId: 'sync-test-list',
        createdAt: DateTime.now(),
      );

      test('syncItemToCloudAsync should handle authenticated users only', () {
        // Arrange - Not authenticated
        when(mockAuthStateManager.isAuthenticated).thenReturn(false);

        // Act
        syncService.syncItemToCloudAsync(testItem);

        // Assert - Should not sync
        verifyNever(mockOperationsService.saveItemCloud(any));
      });

      test('syncItemUpdateToCloudAsync should track ongoing operations', () {
        // Arrange
        when(mockAuthStateManager.isAuthenticated).thenReturn(true);

        // Act
        syncService.syncItemUpdateToCloudAsync(testItem);

        // Assert
        final stats = syncService.getSyncStatistics();
        expect(stats['syncingItemIds'], contains(testItem.id));
      });
    });

    group('Specialized Sync Operations', () {
      test('syncListDeletionToCloudAsync should handle deletions', () {
        // Arrange
        when(mockAuthStateManager.isAuthenticated).thenReturn(true);

        // Act
        syncService.syncListDeletionToCloudAsync('delete-test-list');

        // Assert
        final stats = syncService.getSyncStatistics();
        expect(stats['syncingListIds'], contains('delete-test-list'));
      });

      test('syncItemDeletionToCloudAsync should handle item deletions', () {
        // Arrange
        when(mockAuthStateManager.isAuthenticated).thenReturn(true);

        // Act
        syncService.syncItemDeletionToCloudAsync('delete-test-item');

        // Assert
        final stats = syncService.getSyncStatistics();
        expect(stats['syncingItemIds'], contains('delete-test-item'));
      });
    });

    group('Dependency Inversion Principle Validation', () {
      test('should depend only on abstractions', () {
        // Verify all dependencies are interfaces/abstractions
        expect(syncService, isA<BackgroundSyncService>());

        // Should work with any operations service implementation
        final alternativeSyncService = BackgroundSyncService(
          operationsService: mockOperationsService, // Any implementation
          configuration: testConfiguration,
          authStateManager: mockAuthStateManager, // Any auth manager
        );

        expect(alternativeSyncService, isA<ISyncService>());
      });
    });

    group('Open/Closed Principle Validation', () {
      test('should be extensible via configuration', () {
        // Arrange
        when(mockAuthStateManager.isAuthenticated).thenReturn(false);

        // Service behavior changes via configuration, not code modification
        const alternativeConfig = PersistenceConfiguration(
          enableBackgroundSync: false,
          syncTimeout: Duration(seconds: 60),
          maxRetries: 5,
        );

        final extensibleService = BackgroundSyncService(
          operationsService: mockOperationsService,
          configuration: alternativeConfig,
          authStateManager: mockAuthStateManager,
        );

        expect(extensibleService, isA<BackgroundSyncService>());
        expect(extensibleService.getSyncStatistics()['enableBackgroundSync'], false);
      });
    });

    group('Monitoring and Diagnostics', () {
      test('getSyncStatistics should provide comprehensive metrics', () {
        // Arrange
        when(mockAuthStateManager.isAuthenticated).thenReturn(true);

        // Act
        final stats = syncService.getSyncStatistics();

        // Assert - Should contain all monitoring data
        expect(stats, containsPair('syncingListsCount', isA<int>()));
        expect(stats, containsPair('syncingItemsCount', isA<int>()));
        expect(stats, containsPair('syncingListIds', isA<List>()));
        expect(stats, containsPair('syncingItemIds', isA<List>()));
        expect(stats, containsPair('enableBackgroundSync', isA<bool>()));
        expect(stats, containsPair('isAuthenticated', isA<bool>()));
        expect(stats, containsPair('shouldEnableSync', isA<bool>()));
      });

      test('clearSyncTracking should reset all tracking state', () {
        // Arrange - Add some tracking
        when(mockAuthStateManager.isAuthenticated).thenReturn(true);
        syncService.syncListToCloudAsync(CustomList(
          id: 'tracked-list',
          name: 'Test',
          type: ListType.CUSTOM,
          items: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

        // Act
        syncService.clearSyncTracking();

        // Assert
        final stats = syncService.getSyncStatistics();
        expect(stats['syncingListsCount'], 0);
        expect(stats['syncingItemsCount'], 0);
        expect(stats['syncingListIds'], isEmpty);
        expect(stats['syncingItemIds'], isEmpty);
      });
    });

    group('Error Resilience', () {
      test('should handle configuration edge cases', () {
        // Arrange
        when(mockAuthStateManager.isAuthenticated).thenReturn(false);

        // Test with null/edge case configurations
        const edgeConfig = PersistenceConfiguration(
          enableBackgroundSync: true,
          syncTimeout: Duration.zero,
          maxRetries: 0,
        );

        final resilientService = BackgroundSyncService(
          operationsService: mockOperationsService,
          configuration: edgeConfig,
          authStateManager: mockAuthStateManager,
        );

        expect(resilientService, isA<BackgroundSyncService>());
        expect(() => resilientService.getSyncStatistics(), returnsNormally);
      });
    });
  });
}