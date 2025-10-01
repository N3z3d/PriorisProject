/// Comprehensive test suite for SOLID-compliant refactored components
/// Tests all interfaces, services, DI container, and strategy patterns

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:prioris/core/interfaces/lists_interfaces.dart';
import 'package:prioris/core/di/lists_dependency_container.dart';
import 'package:prioris/core/patterns/persistence_strategy.dart';
import 'package:prioris/core/patterns/concrete_persistence_strategies.dart';
import 'package:prioris/core/patterns/persistence_strategy_factory.dart';
import 'package:prioris/application/services/lists_persistence_service.dart';
import 'package:prioris/application/services/lists_state_manager.dart';
import 'package:prioris/application/services/lists_transaction_manager.dart';
import 'package:prioris/application/services/lists_error_handler.dart';
import 'package:prioris/application/services/lists_loading_manager.dart';
import 'package:prioris/application/services/enhanced_lists_persistence_service.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';

// Generate mocks for testing
@GenerateMocks([
  CustomListRepository,
  ListItemRepository,
  IListsPersistenceService,
  IListsStateManager,
  IListsTransactionManager,
  IListsErrorHandler,
  IListsLoadingManager,
  IListsFilterService,
  IPersistenceStrategy,
])
import 'solid_compliance_test_suite.mocks.dart';

void main() {
  group('SOLID Compliance Test Suite', () {
    late MockCustomListRepository mockListRepo;
    late MockListItemRepository mockItemRepo;
    late CustomList testList;
    late ListItem testItem;

    setUpAll(() async {
      // Initialize DI container for testing
      await ListsDependencyContainer.initialize(mode: DependencyMode.testing);
    });

    setUp(() {
      mockListRepo = MockCustomListRepository();
      mockItemRepo = MockListItemRepository();

      testList = CustomList(
        id: 'test-list-1',
        name: 'Test List',
        type: ListType.TODOS,
        createdAt: DateTime.now(),
        items: [],
      );

      testItem = ListItem(
        id: 'test-item-1',
        title: 'Test Item',
        listId: testList.id,
        createdAt: DateTime.now(),
      );
    });

    tearDownAll(() {
      ListsDependencyContainer.dispose();
    });

    group('ISP (Interface Segregation Principle) Tests', () {
      test('IListsPersistenceService interface is focused and cohesive', () {
        // Test that the interface only contains persistence-related methods
        final interface = IListsPersistenceService;

        // Verify interface exists and can be implemented
        expect(interface, isNotNull);

        // Create a concrete implementation to test interface compliance
        final implementation = ListsPersistenceService.local(mockListRepo, mockItemRepo);
        expect(implementation, isA<IListsPersistenceService>());
      });

      test('IListsStateManager interface is focused on state only', () {
        final stateManager = ListsStateManager();
        expect(stateManager, isA<IListsStateManager>());

        // Test state management methods exist
        expect(stateManager.lists, isA<List<CustomList>>());
        expect(stateManager.isLoading, isA<bool>());
        expect(stateManager.error, isA<String?>());
      });

      test('IListsErrorHandler interface is focused on error handling only', () {
        final errorHandler = ListsErrorHandler();
        expect(errorHandler, isA<IListsErrorHandler>());

        // Test error handling methods
        expect(() => errorHandler.handleError('test error', 'test context'), returnsNormally);
        expect(errorHandler.getUserFriendlyMessage('test error'), isA<String>());
        expect(errorHandler.isRecoverableError('network error'), isA<bool>());
      });

      test('IListsLoadingManager interface is focused on loading management only', () {
        final loadingManager = ListsLoadingManager();
        expect(loadingManager, isA<IListsLoadingManager>());

        // Test loading management properties
        expect(loadingManager.isLoading, isA<bool>());
        expect(loadingManager.canExecute, isA<bool>());
      });
    });

    group('SRP (Single Responsibility Principle) Tests', () {
      test('ListsPersistenceService only handles persistence operations', () async {
        // Setup mocks
        when(mockListRepo.getAllLists()).thenAnswer((_) async => [testList]);
        when(mockListRepo.saveList(any)).thenAnswer((_) async {});

        final service = ListsPersistenceService.local(mockListRepo, mockItemRepo);

        // Test that service only does persistence operations
        final lists = await service.getAllLists();
        expect(lists, isA<List<CustomList>>());

        await service.saveList(testList);
        verify(mockListRepo.saveList(testList)).called(1);

        // Verify it doesn't do state management, error handling, etc.
        expect(service, isNot(isA<IListsStateManager>()));
        expect(service, isNot(isA<IListsErrorHandler>()));
      });

      test('ListsStateManager only handles state management', () {
        final stateManager = ListsStateManager();

        // Test state management operations
        stateManager.updateLists([testList]);
        expect(stateManager.lists, contains(testList));

        stateManager.setLoading(true);
        expect(stateManager.isLoading, isTrue);

        stateManager.setError('test error');
        expect(stateManager.error, equals('test error'));

        // Verify it doesn't do persistence, transactions, etc.
        expect(stateManager, isNot(isA<IListsPersistenceService>()));
        expect(stateManager, isNot(isA<IListsTransactionManager>()));
      });

      test('ListsErrorHandler only handles error operations', () {
        final errorHandler = ListsErrorHandler();

        // Test error handling operations
        expect(() => errorHandler.handleError('error', 'context'), returnsNormally);
        expect(errorHandler.getUserFriendlyMessage('network error'), isNotEmpty);
        expect(errorHandler.isRecoverableError('timeout'), isA<bool>());

        // Verify it doesn't do other operations
        expect(errorHandler, isNot(isA<IListsPersistenceService>()));
        expect(errorHandler, isNot(isA<IListsStateManager>()));
      });

      test('ListsTransactionManager only handles transactions', () {
        final mockPersistence = MockIListsPersistenceService();
        final transactionManager = ListsTransactionManager(persistenceService: mockPersistence);

        // Test transaction operations
        expect(transactionManager.activeTransactionsCount, equals(0));

        // Verify it doesn't do other operations
        expect(transactionManager, isNot(isA<IListsPersistenceService>()));
        expect(transactionManager, isNot(isA<IListsStateManager>()));
      });
    });

    group('OCP (Open/Closed Principle) Tests', () {
      test('New persistence strategies can be added without modifying existing code', () async {
        // Create a new custom strategy without modifying existing classes
        final customStrategy = TestCustomPersistenceStrategy();
        expect(customStrategy, isA<IPersistenceStrategy>());

        // Test that it can be used in the context
        final context = PersistenceContext(customStrategy);
        expect(context.currentStrategyName, equals('custom-test'));

        // Register another strategy
        final memoryStrategy = InMemoryPersistenceStrategy();
        context.registerStrategy(memoryStrategy);
        expect(context.availableStrategies, contains('memory'));
      });

      test('New error handling strategies can be added', () {
        // Test that error handler can be extended without modification
        final customErrorHandler = TestCustomErrorHandler();
        expect(customErrorHandler, isA<IListsErrorHandler>());

        // Test custom behavior
        final message = customErrorHandler.getUserFriendlyMessage('custom error');
        expect(message, equals('Custom handled: custom error'));
      });

      test('DI container can be extended with new factories', () {
        // Test that new service factories can be registered
        final customFactory = TestCustomServiceFactory();

        ListsDependencyContainer.registerFactory<TestCustomService>(customFactory);
        expect(ListsDependencyContainer.isRegistered<TestCustomService>(), isTrue);
      });
    });

    group('LSP (Liskov Substitution Principle) Tests', () {
      test('All persistence strategies are substitutable', () async {
        final strategies = [
          InMemoryPersistenceStrategy(),
          TestCustomPersistenceStrategy(),
        ];

        for (final strategy in strategies) {
          await strategy.initialize();

          // Test that all strategies implement the same contract
          expect(strategy.isAvailable(), completes);
          expect(strategy.getAllLists(), completes);
          expect(strategy.strategyName, isNotEmpty);

          // Test that they can be used interchangeably
          final context = PersistenceContext(strategy);
          expect(context.getAllLists(), completes);
        }
      });

      test('All error handlers are substitutable', () {
        final handlers = [
          ListsErrorHandler(),
          TestCustomErrorHandler(),
        ];

        for (final handler in handlers) {
          // Test that all handlers implement the same contract
          expect(() => handler.handleError('error', 'context'), returnsNormally);
          expect(handler.getUserFriendlyMessage('error'), isNotEmpty);
          expect(handler.isRecoverableError('error'), isA<bool>());
        }
      });
    });

    group('DIP (Dependency Inversion Principle) Tests', () {
      test('High-level modules depend on abstractions, not concretions', () {
        // Test that ListsTransactionManager depends on IListsPersistenceService
        final mockPersistence = MockIListsPersistenceService();
        final transactionManager = ListsTransactionManager(persistenceService: mockPersistence);

        expect(transactionManager, isNotNull);

        // Test that it works with any implementation of the interface
        final anotherMockPersistence = MockIListsPersistenceService();
        final anotherTransactionManager = ListsTransactionManager(persistenceService: anotherMockPersistence);

        expect(anotherTransactionManager, isNotNull);
      });

      test('Enhanced persistence service depends on strategy abstraction', () async {
        final context = await PersistenceStrategyFactory.createTestContext();
        final enhancedService = EnhancedListsPersistenceService(context: context);

        // Test that it works with any strategy implementation
        expect(enhancedService.currentStrategy, isNotEmpty);
        expect(enhancedService.getAllLists(), completes);
      });
    });

    group('Strategy Pattern Tests', () {
      test('Strategy context can switch between strategies', () async {
        final memoryStrategy = InMemoryPersistenceStrategy();
        await memoryStrategy.initialize();

        final context = PersistenceContext(memoryStrategy);
        expect(context.currentStrategyName, equals('memory'));

        // Register and switch to custom strategy
        final customStrategy = TestCustomPersistenceStrategy();
        await customStrategy.initialize();
        context.registerStrategy(customStrategy);

        await context.switchStrategy('custom-test');
        expect(context.currentStrategyName, equals('custom-test'));
      });

      test('Strategy factory creates correct strategies', () async {
        // Test memory strategy creation
        final memoryConfig = StrategyConfig.memory();
        final memoryStrategy = await PersistenceStrategyFactory.createStrategy(memoryConfig);
        expect(memoryStrategy, isA<InMemoryPersistenceStrategy>());

        // Test local strategy creation
        final localConfig = StrategyConfig.local(
          listRepository: mockListRepo,
          itemRepository: mockItemRepo,
        );
        final localStrategy = await PersistenceStrategyFactory.createStrategy(localConfig);
        expect(localStrategy, isA<LocalPersistenceStrategy>());
      });

      test('Strategy selection policies work correctly', () async {
        final smartPolicy = SmartStrategySelectionPolicy();

        // Test authenticated online user gets adaptive strategy
        var context = {'isAuthenticated': true, 'isOnline': true};
        var strategy = await smartPolicy.selectStrategy(context);
        expect(strategy, equals(StrategyType.adaptive));

        // Test offline user gets local strategy
        context = {'isAuthenticated': false, 'isOnline': false};
        strategy = await smartPolicy.selectStrategy(context);
        expect(strategy, equals(StrategyType.local));

        // Test testing policy always returns memory
        final testPolicy = TestingStrategySelectionPolicy();
        strategy = await testPolicy.selectStrategy({});
        expect(strategy, equals(StrategyType.memory));
      });
    });

    group('Error Handling and Recovery Tests', () {
      test('Error handler provides user-friendly messages', () {
        final errorHandler = ListsErrorHandler();

        // Test different error types get appropriate messages
        var message = errorHandler.getUserFriendlyMessage('network timeout');
        expect(message, contains('connexion'));

        message = errorHandler.getUserFriendlyMessage('permission denied');
        expect(message, contains('permissions'));

        message = errorHandler.getUserFriendlyMessage('validation failed');
        expect(message, contains('valides'));
      });

      test('Transaction manager handles rollbacks correctly', () async {
        final mockPersistence = MockIListsPersistenceService();
        final transactionManager = ListsTransactionManager(persistenceService: mockPersistence);

        // Test successful operation
        var operationExecuted = false;
        await transactionManager.executeTransaction(() async {
          operationExecuted = true;
        });
        expect(operationExecuted, isTrue);

        // Test rollback on failure
        var rollbackExecuted = false;
        try {
          await transactionManager.executeWithRollback(
            () async => throw Exception('Test error'),
            () async => rollbackExecuted = true,
          );
        } catch (e) {
          // Expected to throw
        }
        expect(rollbackExecuted, isTrue);
      });
    });

    group('Performance and Resource Management Tests', () {
      test('Loading manager handles concurrent operations', () async {
        final loadingManager = ListsLoadingManager();

        expect(loadingManager.canExecute, isTrue);
        expect(loadingManager.isLoading, isFalse);

        // Test concurrent operations
        final futures = <Future>[];
        for (int i = 0; i < 3; i++) {
          futures.add(loadingManager.executeWithLoading(() async {
            await Future.delayed(Duration(milliseconds: 10));
          }));
        }

        await Future.wait(futures);
        expect(loadingManager.isLoading, isFalse);
      });

      test('Resources are properly disposed', () async {
        final stateManager = ListsStateManager();
        final loadingManager = ListsLoadingManager();

        expect(stateManager.isActive, isTrue);

        stateManager.dispose();
        loadingManager.dispose();

        expect(stateManager.isActive, isFalse);
      });
    });
  });
}

// Test helper classes

class TestCustomPersistenceStrategy implements IPersistenceStrategy {
  final Map<String, CustomList> _lists = {};
  final Map<String, ListItem> _items = {};

  @override
  String get strategyName => 'custom-test';

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<void> initialize() async {}

  @override
  Future<List<CustomList>> getAllLists() async => _lists.values.toList();

  @override
  Future<CustomList?> getListById(String listId) async => _lists[listId];

  @override
  Future<void> saveList(CustomList list) async => _lists[list.id] = list;

  @override
  Future<void> deleteList(String listId) async => _lists.remove(listId);

  @override
  Future<List<ListItem>> getItemsByListId(String listId) async =>
      _items.values.where((item) => item.listId == listId).toList();

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

class TestCustomErrorHandler implements IListsErrorHandler {
  @override
  void handleError(error, String context) {}

  @override
  Future<T?> handleErrorWithRecovery<T>(
    error,
    String context,
    Future<T> Function()? recovery,
  ) async => null;

  @override
  bool isRecoverableError(error) => true;

  @override
  String getUserFriendlyMessage(error) => 'Custom handled: $error';

  @override
  void logError(error, String context, StackTrace? stackTrace) {}
}

class TestCustomService {}

class TestCustomServiceFactory implements IServiceFactory<TestCustomService> {
  @override
  TestCustomService create() => TestCustomService();

  @override
  void dispose(TestCustomService instance) {}
}