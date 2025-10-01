/// Tests for PersistenceStrategyManager - SOLID Architecture Validation
/// Validates Strategy Pattern implementation and SOLID principles

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/application/ports/persistence_interfaces.dart';
import 'package:prioris/application/services/persistence/persistence_operations_service.dart';
import 'package:prioris/application/services/persistence/background_sync_service.dart';
import 'package:prioris/application/services/persistence/persistence_strategy_manager.dart';

@GenerateMocks([
  PersistenceOperationsService,
  BackgroundSyncService,
  IAuthenticationStateManager,
])
import 'persistence_strategy_manager_test.mocks.dart';

void main() {
  group('PersistenceStrategyManager - SOLID Validation', () {
    late PersistenceStrategyManager strategyManager;
    late MockPersistenceOperationsService mockOperationsService;
    late MockBackgroundSyncService mockSyncService;
    late MockIAuthenticationStateManager mockAuthStateManager;

    setUp(() {
      mockOperationsService = MockPersistenceOperationsService();
      mockSyncService = MockBackgroundSyncService();
      mockAuthStateManager = MockIAuthenticationStateManager();

      strategyManager = PersistenceStrategyManager(
        operationsService: mockOperationsService,
        syncService: mockSyncService,
        authStateManager: mockAuthStateManager,
      );
    });

    group('Strategy Pattern Implementation', () {
      test('should provide different strategies for different modes', () {
        // Act & Assert - Each mode should return a different strategy
        final localStrategy = strategyManager.getStrategy(PersistenceMode.localFirst);
        final cloudStrategy = strategyManager.getStrategy(PersistenceMode.cloudFirst);
        final hybridStrategy = strategyManager.getStrategy(PersistenceMode.hybrid);

        expect(localStrategy, isA<LocalFirstStrategy>());
        expect(cloudStrategy, isA<CloudFirstStrategy>());
        expect(hybridStrategy, isA<HybridStrategy>());

        // Strategies should be different instances
        expect(localStrategy, isNot(same(cloudStrategy)));
        expect(cloudStrategy, isNot(same(hybridStrategy)));
        expect(hybridStrategy, isNot(same(localStrategy)));
      });

      test('currentStrategy should delegate to auth state manager', () {
        // Arrange
        when(mockAuthStateManager.currentMode).thenReturn(PersistenceMode.cloudFirst);

        // Act
        final currentStrategy = strategyManager.currentStrategy;

        // Assert
        expect(currentStrategy, isA<CloudFirstStrategy>());
        verify(mockAuthStateManager.currentMode).called(1);
      });
    });

    group('LocalFirstStrategy Behavior', () {
      late LocalFirstStrategy localStrategy;

      setUp(() {
        localStrategy = strategyManager.getStrategy(PersistenceMode.localFirst) as LocalFirstStrategy;
      });

      test('should use only local operations', () async {
        // Arrange
        final testList = CustomList(
          id: 'local-test',
          name: 'Local Test',
          type: ListType.CUSTOM,
          items: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        when(mockOperationsService.getAllListsLocal()).thenAnswer((_) async => [testList]);

        // Act
        final result = await localStrategy.getAllLists();

        // Assert
        expect(result, [testList]);
        verify(mockOperationsService.getAllListsLocal()).called(1);
        verifyNever(mockOperationsService.getAllListsCloudFirst());
      });

      test('should have correct strategy name', () {
        expect(localStrategy.strategyName, 'LocalFirst');
      });
    });

    group('CloudFirstStrategy Behavior', () {
      late CloudFirstStrategy cloudStrategy;

      setUp(() {
        cloudStrategy = strategyManager.getStrategy(PersistenceMode.cloudFirst) as CloudFirstStrategy;
      });

      test('should use cloud operations with background sync', () async {
        // Arrange
        final testList = CustomList(
          id: 'cloud-test',
          name: 'Cloud Test',
          type: ListType.CUSTOM,
          items: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        when(mockOperationsService.getAllListsCloudFirst()).thenAnswer((_) async => [testList]);

        // Act
        final result = await cloudStrategy.getAllLists();

        // Assert
        expect(result, [testList]);
        verify(mockOperationsService.getAllListsCloudFirst()).called(1);
        verify(mockSyncService.syncCloudToLocalAsync([testList])).called(1);
      });

      test('should save locally first then sync to cloud', () async {
        // Arrange
        final testList = CustomList(
          id: 'save-test',
          name: 'Save Test',
          type: ListType.CUSTOM,
          items: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        await cloudStrategy.saveList(testList);

        // Assert
        verify(mockOperationsService.saveListLocal(testList)).called(1);
        verify(mockSyncService.syncListToCloudAsync(testList)).called(1);
      });

      test('should have correct strategy name', () {
        expect(cloudStrategy.strategyName, 'CloudFirst');
      });
    });

    group('HybridStrategy Behavior', () {
      late HybridStrategy hybridStrategy;

      setUp(() {
        hybridStrategy = strategyManager.getStrategy(PersistenceMode.hybrid) as HybridStrategy;
      });

      test('should use cloud operations when authenticated', () async {
        // Arrange
        when(mockAuthStateManager.isAuthenticated).thenReturn(true);
        final testList = CustomList(
          id: 'hybrid-test',
          name: 'Hybrid Test',
          type: ListType.CUSTOM,
          items: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        when(mockOperationsService.getAllListsCloudFirst()).thenAnswer((_) async => [testList]);

        // Act
        final result = await hybridStrategy.getAllLists();

        // Assert
        expect(result, [testList]);
        verify(mockOperationsService.getAllListsCloudFirst()).called(1);
        verify(mockSyncService.syncCloudToLocalAsync([testList])).called(1);
        verifyNever(mockOperationsService.getAllListsLocal());
      });

      test('should use local operations when not authenticated', () async {
        // Arrange
        when(mockAuthStateManager.isAuthenticated).thenReturn(false);
        final testList = CustomList(
          id: 'hybrid-local-test',
          name: 'Hybrid Local Test',
          type: ListType.CUSTOM,
          items: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        when(mockOperationsService.getAllListsLocal()).thenAnswer((_) async => [testList]);

        // Act
        final result = await hybridStrategy.getAllLists();

        // Assert
        expect(result, [testList]);
        verify(mockOperationsService.getAllListsLocal()).called(1);
        verifyNever(mockOperationsService.getAllListsCloudFirst());
      });

      test('should conditionally sync based on authentication', () async {
        // Test authenticated save
        when(mockAuthStateManager.isAuthenticated).thenReturn(true);
        final testList = CustomList(
          id: 'sync-test',
          name: 'Sync Test',
          type: ListType.CUSTOM,
          items: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await hybridStrategy.saveList(testList);

        verify(mockOperationsService.saveListLocal(testList)).called(1);
        verify(mockSyncService.syncListToCloudAsync(testList)).called(1);

        // Test unauthenticated save
        clearInteractions(mockOperationsService);
        clearInteractions(mockSyncService);
        when(mockAuthStateManager.isAuthenticated).thenReturn(false);

        await hybridStrategy.saveList(testList);

        verify(mockOperationsService.saveListLocal(testList)).called(1);
        verifyNever(mockSyncService.syncListToCloudAsync(any));
      });

      test('should have correct strategy name', () {
        expect(hybridStrategy.strategyName, 'Hybrid');
      });
    });

    group('Liskov Substitution Principle Validation', () {
      test('all strategies should be interchangeable', () async {
        // Arrange - Test data
        final testList = CustomList(
          id: 'substitution-test',
          name: 'Substitution Test',
          type: ListType.CUSTOM,
          items: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockOperationsService.getAllListsLocal()).thenAnswer((_) async => [testList]);
        when(mockOperationsService.getAllListsCloudFirst()).thenAnswer((_) async => [testList]);
        when(mockAuthStateManager.isAuthenticated).thenReturn(true);

        // Act & Assert - All strategies should implement the same interface
        final strategies = [
          strategyManager.getStrategy(PersistenceMode.localFirst),
          strategyManager.getStrategy(PersistenceMode.cloudFirst),
          strategyManager.getStrategy(PersistenceMode.hybrid),
        ];

        for (final strategy in strategies) {
          expect(strategy, isA<PersistenceStrategy>());
          expect(await strategy.getAllLists(), isA<List<CustomList>>());
          expect(() => strategy.saveList(testList), returnsNormally);
          expect(strategy.strategyName, isA<String>());
        }
      });
    });

    group('Open/Closed Principle Validation', () {
      test('should be extensible with new strategies', () {
        // The manager can accept new strategies without modification
        // This is validated by the clean interface design

        expect(strategyManager.getStrategy(PersistenceMode.localFirst), isA<PersistenceStrategy>());
        expect(strategyManager.getStrategy(PersistenceMode.cloudFirst), isA<PersistenceStrategy>());
        expect(strategyManager.getStrategy(PersistenceMode.hybrid), isA<PersistenceStrategy>());

        // Any new strategy implementing PersistenceStrategy would work
        // without modifying the manager
      });
    });

    group('Dependency Inversion Principle Validation', () {
      test('should depend only on abstractions', () {
        // Verify manager works with any service implementations
        final alternativeManager = PersistenceStrategyManager(
          operationsService: mockOperationsService, // Any operations service
          syncService: mockSyncService, // Any sync service
          authStateManager: mockAuthStateManager, // Any auth manager
        );

        expect(alternativeManager, isA<PersistenceStrategyManager>());
        expect(alternativeManager.currentStrategy, isA<PersistenceStrategy>());
      });
    });

    group('Monitoring and Diagnostics', () {
      test('getStrategyDiagnostics should provide comprehensive information', () {
        // Arrange
        when(mockAuthStateManager.currentMode).thenReturn(PersistenceMode.cloudFirst);
        when(mockAuthStateManager.isAuthenticated).thenReturn(true);
        when(mockSyncService.getSyncStatistics()).thenReturn({
          'syncingListsCount': 0,
          'syncingItemsCount': 0,
        });

        // Act
        final diagnostics = strategyManager.getStrategyDiagnostics();

        // Assert
        expect(diagnostics, containsPair('currentMode', 'cloudFirst'));
        expect(diagnostics, containsPair('currentStrategy', 'CloudFirst'));
        expect(diagnostics, containsPair('isAuthenticated', true));
        expect(diagnostics, containsPair('availableStrategies', isA<List<String>>()));
        expect(diagnostics, containsPair('syncStats', isA<Map<String, dynamic>>()));

        // Verify available strategies
        final availableStrategies = diagnostics['availableStrategies'] as List<String>;
        expect(availableStrategies, containsAll(['LocalFirst', 'CloudFirst', 'Hybrid']));
      });
    });

    group('Item Operations Across Strategies', () {
      final testItem = ListItem(
        id: 'strategy-item-test',
        title: 'Strategy Item Test',
        listId: 'strategy-list-test',
        createdAt: DateTime.now(),
      );

      test('LocalFirst strategy should handle items locally only', () async {
        // Arrange
        final strategy = strategyManager.getStrategy(PersistenceMode.localFirst);
        when(mockOperationsService.getItemsByListIdLocal('test-list'))
            .thenAnswer((_) async => [testItem]);

        // Act
        final result = await strategy.getItemsByListId('test-list');

        // Assert
        expect(result, [testItem]);
        verify(mockOperationsService.getItemsByListIdLocal('test-list')).called(1);
        verifyNever(mockOperationsService.getItemsByListIdCloudFirst(any));
      });

      test('CloudFirst strategy should sync item operations', () async {
        // Arrange
        final strategy = strategyManager.getStrategy(PersistenceMode.cloudFirst);

        // Act
        await strategy.saveItem(testItem);

        // Assert
        verify(mockOperationsService.saveItemLocal(testItem)).called(1);
        verify(mockSyncService.syncItemToCloudAsync(testItem)).called(1);
      });

      test('Hybrid strategy should adapt item operations to auth state', () async {
        // Arrange
        final strategy = strategyManager.getStrategy(PersistenceMode.hybrid);

        // Test authenticated behavior
        when(mockAuthStateManager.isAuthenticated).thenReturn(true);
        await strategy.updateItem(testItem);

        verify(mockOperationsService.updateItemLocal(testItem)).called(1);
        verify(mockSyncService.syncItemUpdateToCloudAsync(testItem)).called(1);

        // Reset and test unauthenticated behavior
        clearInteractions(mockOperationsService);
        clearInteractions(mockSyncService);
        when(mockAuthStateManager.isAuthenticated).thenReturn(false);

        await strategy.updateItem(testItem);

        verify(mockOperationsService.updateItemLocal(testItem)).called(1);
        verifyNever(mockSyncService.syncItemUpdateToCloudAsync(any));
      });
    });
  });
}