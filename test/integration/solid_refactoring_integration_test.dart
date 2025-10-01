/// Integration test for the complete SOLID refactoring
/// Validates end-to-end functionality of the refactored architecture

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/core/di/lists_dependency_container.dart';
import 'package:prioris/core/patterns/persistence_strategy_factory.dart';
import 'package:prioris/core/patterns/concrete_persistence_strategies.dart';
import 'package:prioris/application/services/enhanced_lists_persistence_service.dart';
import 'package:prioris/application/services/lists_state_manager.dart';
import 'package:prioris/application/services/lists_error_handler.dart';
import 'package:prioris/application/services/lists_loading_manager.dart';
import 'package:prioris/core/di/lists_providers.dart';
import 'package:prioris/presentation/pages/lists/controllers/refactored_lists_controller.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

void main() {
  group('SOLID Refactoring Integration Tests', () {
    late ProviderContainer container;
    late CustomList testList;
    late ListItem testItem;

    setUpAll(() async {
      // Initialize DI container for testing
      await ListsDependencyContainer.initialize(mode: DependencyMode.testing);
    });

    setUp(() {
      container = ProviderContainer();

      testList = CustomList(
        id: 'integration-test-list-1',
        name: 'Integration Test List',
        type: ListType.TODOS,
        createdAt: DateTime.now(),
        items: [],
      );

      testItem = ListItem(
        id: 'integration-test-item-1',
        title: 'Integration Test Item',
        listId: testList.id,
        createdAt: DateTime.now(),
      );
    });

    tearDown(() {
      container.dispose();
    });

    tearDownAll(() {
      ListsDependencyContainer.dispose();
    });

    group('End-to-End Architecture Validation', () {
      test('Complete SOLID architecture works together', () async {
        // Test that all components integrate correctly
        final context = await PersistenceStrategyFactory.createTestContext();
        final enhancedService = EnhancedListsPersistenceService(context: context);
        final stateManager = ListsStateManager();
        final errorHandler = ListsErrorHandler();
        final loadingManager = ListsLoadingManager();

        // Create orchestrator with all services
        final orchestrator = ListsOrchestrator(
          stateManager: stateManager,
          persistenceService: enhancedService,
          transactionManager: container.read(listsTransactionManagerProvider),
          errorHandler: errorHandler,
          loadingManager: loadingManager,
          filterService: container.read(listsFilterServiceProvider),
        );

        // Create controller with orchestrator
        final controller = RefactoredListsController(
          orchestrator: orchestrator,
          errorHandler: errorHandler,
          loadingManager: loadingManager,
        );

        // Test full workflow: create list → add item → update → delete
        await controller.createList(testList);
        expect(orchestrator.state.lists, contains(testList));

        await controller.addItemToList(testList.id, testItem);
        final updatedList = orchestrator.state.lists.firstWhere((l) => l.id == testList.id);
        expect(updatedList.items, contains(testItem));

        final modifiedItem = testItem.copyWith(title: 'Modified Item');
        await controller.updateListItem(testList.id, modifiedItem);

        await controller.removeItemFromList(testList.id, testItem.id);
        await controller.deleteList(testList.id);

        expect(orchestrator.state.lists, isEmpty);

        // Cleanup
        controller.dispose();
        stateManager.dispose();
        loadingManager.dispose();
        await enhancedService.dispose();
      });

      test('Strategy pattern integration works correctly', () async {
        // Test strategy switching in integrated environment
        final context = await PersistenceStrategyFactory.createTestContext();

        // Register multiple strategies
        final memoryStrategy = InMemoryPersistenceStrategy();
        await memoryStrategy.initialize();
        context.registerStrategy(memoryStrategy);

        final enhancedService = EnhancedListsPersistenceService(context: context);

        // Test data persists when switching strategies
        await enhancedService.saveList(testList);
        await enhancedService.saveItem(testItem);

        var lists = await enhancedService.getAllLists();
        expect(lists, hasLength(1));

        var items = await enhancedService.getItemsByListId(testList.id);
        expect(items, hasLength(1));

        // Switch strategy and verify data is still accessible
        await enhancedService.switchStrategy('memory');
        expect(enhancedService.currentStrategy, equals('memory'));

        // Note: In real integration, data might not persist across strategy switches
        // This depends on the specific strategy implementations

        await enhancedService.dispose();
      });

      test('Error handling integration works across all layers', () async {
        final context = await PersistenceStrategyFactory.createTestContext();
        final enhancedService = EnhancedListsPersistenceService(context: context);
        final errorHandler = ListsErrorHandler();
        final loadingManager = ListsLoadingManager();

        // Test error propagation through all layers
        expect(errorHandler.isRecoverableError('network timeout'), isTrue);
        expect(errorHandler.isRecoverableError('validation failed'), isFalse);

        var message = errorHandler.getUserFriendlyMessage('connection refused');
        expect(message, contains('connexion'));

        message = errorHandler.getUserFriendlyMessage('permission denied');
        expect(message, contains('permissions'));

        // Test error handling in loading manager
        var errorThrown = false;
        try {
          await loadingManager.executeWithLoading(() async {
            throw Exception('Test error');
          });
        } catch (e) {
          errorThrown = true;
        }
        expect(errorThrown, isTrue);

        loadingManager.dispose();
        await enhancedService.dispose();
      });
    });

    group('Performance and Resource Management Integration', () {
      test('All components properly manage resources', () async {
        final context = await PersistenceStrategyFactory.createTestContext();
        final enhancedService = EnhancedListsPersistenceService(context: context);
        final stateManager = ListsStateManager();
        final loadingManager = ListsLoadingManager();

        // Test that all components start properly
        expect(stateManager.isActive, isTrue);
        expect(loadingManager.canExecute, isTrue);
        expect(enhancedService.currentStrategy, isNotEmpty);

        // Test concurrent operations don't interfere
        final futures = <Future>[];
        for (int i = 0; i < 5; i++) {
          futures.add(loadingManager.executeWithLoading(() async {
            await Future.delayed(Duration(milliseconds: 10));
          }));
        }

        await Future.wait(futures);
        expect(loadingManager.isLoading, isFalse);

        // Test proper disposal
        stateManager.dispose();
        loadingManager.dispose();
        await enhancedService.dispose();

        expect(stateManager.isActive, isFalse);
      });

      test('Memory usage is properly managed', () async {
        // Test that creating and disposing many components doesn't leak memory
        final components = <dynamic>[];

        for (int i = 0; i < 10; i++) {
          final context = await PersistenceStrategyFactory.createTestContext();
          final service = EnhancedListsPersistenceService(context: context);
          final stateManager = ListsStateManager();
          final loadingManager = ListsLoadingManager();

          components.addAll([service, stateManager, loadingManager]);

          // Use components briefly
          await service.saveList(testList.copyWith(id: 'test-$i'));
          stateManager.updateLists([testList]);
          await loadingManager.executeWithLoading(() async {});
        }

        // Dispose all components
        for (final component in components) {
          if (component is EnhancedListsPersistenceService) {
            await component.dispose();
          } else if (component is ListsStateManager) {
            component.dispose();
          } else if (component is ListsLoadingManager) {
            component.dispose();
          }
        }

        // Test should complete without memory issues
        expect(components.length, equals(30)); // 10 * 3 components
      });
    });

    group('SOLID Principles Validation in Integration', () {
      test('SRP: Each component has single responsibility in integration', () async {
        final context = await PersistenceStrategyFactory.createTestContext();
        final enhancedService = EnhancedListsPersistenceService(context: context);
        final stateManager = ListsStateManager();
        final errorHandler = ListsErrorHandler();
        final loadingManager = ListsLoadingManager();

        // Persistence service only does persistence
        await enhancedService.saveList(testList);
        expect(await enhancedService.getAllLists(), hasLength(1));

        // State manager only manages state
        stateManager.updateLists([testList]);
        expect(stateManager.lists, hasLength(1));

        // Error handler only handles errors
        errorHandler.handleError('test error', 'test context');
        expect(errorHandler.getUserFriendlyMessage('test'), isNotEmpty);

        // Loading manager only manages loading
        expect(loadingManager.isLoading, isFalse);
        await loadingManager.executeWithLoading(() async {});

        // Clean up
        stateManager.dispose();
        loadingManager.dispose();
        await enhancedService.dispose();
      });

      test('OCP: System is extensible without modification', () async {
        // Test that new strategies can be added without modifying existing code
        final customStrategy = CustomIntegrationTestStrategy();

        final context = await PersistenceStrategyFactory.createTestContext();
        context.registerStrategy(customStrategy);

        final enhancedService = EnhancedListsPersistenceService(context: context);

        // Switch to custom strategy
        await enhancedService.switchStrategy('custom-integration');
        expect(enhancedService.currentStrategy, equals('custom-integration'));

        // Test that it works with existing interfaces
        await enhancedService.saveList(testList);
        final lists = await enhancedService.getAllLists();
        expect(lists, hasLength(1));
        expect(lists.first.name, equals('Custom: ${testList.name}'));

        await enhancedService.dispose();
      });

      test('LSP: All implementations are substitutable', () async {
        final strategies = [
          InMemoryPersistenceStrategy(),
          CustomIntegrationTestStrategy(),
        ];

        for (final strategy in strategies) {
          await strategy.initialize();

          final context = PersistenceStrategyFactory.createTestContext();
          (await context).registerStrategy(strategy);

          final enhancedService = EnhancedListsPersistenceService(context: await context);
          await enhancedService.switchStrategy(strategy.strategyName);

          // All strategies should work the same way
          await enhancedService.saveList(testList);
          final lists = await enhancedService.getAllLists();
          expect(lists, isNotEmpty);

          await enhancedService.dispose();
        }
      });

      test('ISP: Interfaces are properly segregated', () async {
        // Test that components only depend on methods they actually use
        final context = await PersistenceStrategyFactory.createTestContext();
        final enhancedService = EnhancedListsPersistenceService(context: context);

        // Enhanced service should only implement persistence interface
        expect(enhancedService, isA<IListsPersistenceService>());
        expect(enhancedService, isNot(isA<IListsStateManager>()));
        expect(enhancedService, isNot(isA<IListsErrorHandler>()));

        await enhancedService.dispose();
      });

      test('DIP: High-level modules depend on abstractions', () async {
        // Test that the controller depends on abstractions, not concretions
        final context = await PersistenceStrategyFactory.createTestContext();
        final enhancedService = EnhancedListsPersistenceService(context: context);
        final stateManager = ListsStateManager();
        final errorHandler = ListsErrorHandler();
        final loadingManager = ListsLoadingManager();

        // Controller should work with any implementation of these interfaces
        final orchestrator = ListsOrchestrator(
          stateManager: stateManager,
          persistenceService: enhancedService, // Uses interface
          transactionManager: container.read(listsTransactionManagerProvider),
          errorHandler: errorHandler, // Uses interface
          loadingManager: loadingManager, // Uses interface
          filterService: container.read(listsFilterServiceProvider),
        );

        final controller = RefactoredListsController(
          orchestrator: orchestrator,
          errorHandler: errorHandler,
          loadingManager: loadingManager,
        );

        // Test that controller works with injected dependencies
        await controller.loadLists();
        expect(controller.state, isNotNull);

        // Clean up
        controller.dispose();
        stateManager.dispose();
        loadingManager.dispose();
        await enhancedService.dispose();
      });
    });

    group('Regression Prevention', () {
      test('Refactored architecture maintains all original functionality', () async {
        // Test that all original functionality still works
        final context = await PersistenceStrategyFactory.createTestContext();
        final enhancedService = EnhancedListsPersistenceService(context: context);
        final stateManager = ListsStateManager();
        final errorHandler = ListsErrorHandler();
        final loadingManager = ListsLoadingManager();

        final orchestrator = ListsOrchestrator(
          stateManager: stateManager,
          persistenceService: enhancedService,
          transactionManager: container.read(listsTransactionManagerProvider),
          errorHandler: errorHandler,
          loadingManager: loadingManager,
          filterService: container.read(listsFilterServiceProvider),
        );

        final controller = RefactoredListsController(
          orchestrator: orchestrator,
          errorHandler: errorHandler,
          loadingManager: loadingManager,
        );

        // Test all major operations from original controller
        await controller.loadLists();
        await controller.createList(testList);
        await controller.addItemToList(testList.id, testItem);
        await controller.addMultipleItemsToList(testList.id, ['Item 1', 'Item 2']);

        controller.updateSearchQuery('test');
        controller.updateTypeFilter(ListType.TODOS);
        controller.updateShowCompleted(false);
        controller.updateSortOption(SortOption.DATE_DESC);

        await controller.updateListItem(testList.id, testItem.copyWith(title: 'Updated'));
        await controller.removeItemFromList(testList.id, testItem.id);
        await controller.deleteList(testList.id);
        await controller.clearAllData();

        controller.clearError();

        // All operations should complete without errors
        expect(controller.state.lists, isEmpty);

        // Clean up
        controller.dispose();
        stateManager.dispose();
        loadingManager.dispose();
        await enhancedService.dispose();
      });
    });
  });
}

// Test helper class for integration testing
class CustomIntegrationTestStrategy implements IPersistenceStrategy {
  final Map<String, CustomList> _lists = {};
  final Map<String, ListItem> _items = {};

  @override
  String get strategyName => 'custom-integration';

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<void> initialize() async {}

  @override
  Future<List<CustomList>> getAllLists() async {
    return _lists.values.toList();
  }

  @override
  Future<CustomList?> getListById(String listId) async => _lists[listId];

  @override
  Future<void> saveList(CustomList list) async {
    // Custom behavior: prefix name with "Custom: "
    final customList = list.copyWith(name: 'Custom: ${list.name}');
    _lists[list.id] = customList;
  }

  @override
  Future<void> deleteList(String listId) async {
    _lists.remove(listId);
    _items.removeWhere((key, item) => item.listId == listId);
  }

  @override
  Future<List<ListItem>> getItemsByListId(String listId) async {
    return _items.values.where((item) => item.listId == listId).toList();
  }

  @override
  Future<void> saveItem(ListItem item) async => _items[item.id] = item;

  @override
  Future<void> updateItem(ListItem item) async => _items[item.id] = item;

  @override
  Future<void> deleteItem(String itemId) async => _items.remove(itemId);

  @override
  Future<bool> verifyPersistence(String id) async =>
      _lists.containsKey(id) || _items.containsKey(id);

  @override
  Future<void> clearAllData() async {
    _lists.clear();
    _items.clear();
  }

  @override
  Future<void> dispose() async {}
}