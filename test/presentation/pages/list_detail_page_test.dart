import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';
import 'package:prioris/domain/core/interfaces/logger_interface.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/pages/list_detail_page.dart';
import 'package:prioris/presentation/pages/lists/models/task_sort_field.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_item_card.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_contextual_fab.dart';
import 'package:prioris/presentation/pages/lists/controllers/refactored/lists_controller_slim.dart';
import 'package:prioris/presentation/pages/lists/controllers/operations/lists_crud_operations.dart';
import 'package:prioris/presentation/pages/lists/controllers/operations/lists_validation_service.dart';
import 'package:prioris/presentation/pages/lists/controllers/state/lists_state_manager.dart';
import 'package:prioris/presentation/pages/lists/interfaces/lists_managers_interfaces.dart';
import 'package:prioris/presentation/pages/lists/managers/lists_filter_manager.dart';
import 'package:prioris/presentation/pages/lists/services/list_item_sync_service.dart';

ListsControllerSlim _buildControllerWithLists(List<CustomList> initialLists) {
  final persistence =
      _InMemoryListsPersistenceManager(initialLists: initialLists);
  final stateManager = ListsStateManager();
  final crud = ListsCrudOperations(
    persistence: persistence,
    validator: ListsValidationService(),
    filterManager: ListsFilterManager(),
    stateManager: stateManager,
    logger: _NoopLogger(),
  );

  return _SpyListsController(
    initializationManager: _ImmediateInitManager(),
    performanceMonitor: _NoopPerformanceMonitor(),
    crudOperations: crud,
    stateManager: stateManager,
    syncService: ListItemSyncService(stateManager),
    logger: _NoopLogger(),
  );
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _waitForCondition(WidgetTester tester, bool Function() predicate) async {
  for (var i = 0; i < 100; i++) {
    if (predicate()) {
      return;
    }
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _pumpListDetailPage(
  WidgetTester tester, {
  required CustomList list,
  ListsControllerSlim? controller,
}) async {
  final effectiveController =
      controller ?? _buildControllerWithLists([list]);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        listsControllerProvider.overrideWith((ref) => effectiveController),
      ],
      child: MaterialApp(
        home: ListDetailPage(list: list),
      ),
    ),
  );

  await _settle(tester);
}

void main() {
  setUpAll(() {
    ListContextualFab.animationsForcedDisabled = true;
  });

  tearDownAll(() {
    ListContextualFab.animationsForcedDisabled = false;
  });

  group('ListDetailPage', () {
    late CustomList testList;

    setUp(() {
      final now = DateTime.now();
      testList = CustomList(
        id: 'test_list',
        name: 'Test List',
        type: ListType.CUSTOM,
        description: 'Test Description',
        items: [
          ListItem(
            id: 'item1',
            title: 'Urgent Task',
            description: 'Urgent description',
            eloScore: 1600.0,
            isCompleted: false,
            createdAt: now,
            listId: 'test_list',
          ),
          ListItem(
            id: 'item2',
            title: 'Low Priority Task',
            description: 'Low priority description',
            eloScore: 1100.0,
            isCompleted: true,
            createdAt: now,
            listId: 'test_list',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      );
    });

    testWidgets('renders list title and items', (WidgetTester tester) async {
      await _pumpListDetailPage(
        tester,
        list: testList,
      );

      expect(find.text('Test List'), findsOneWidget);
      expect(find.text('Urgent Task'), findsOneWidget);
      expect(find.text('Low Priority Task'), findsOneWidget);
    });

    testWidgets('completion toggle updates controller state',
        (WidgetTester tester) async {
      final controller = _buildControllerWithLists([testList]) as _SpyListsController;

      await _pumpListDetailPage(
        tester,
        list: testList,
        controller: controller,
      );

      expect(controller.state.lists.first.items.first.isCompleted, isFalse);

      final completionButton = find.descendant(
        of: find.byType(ListItemCard).first,
        matching: find.byType(AnimatedContainer),
      );
      await tester.tap(completionButton);
      await _settle(tester);
      await _waitForCondition(
        tester,
        () => controller.state.lists.first.items.first.isCompleted,
      );

      expect(controller.lastUpdatedItem?.isCompleted, isTrue);

      final updatedItems = controller.state.lists.first.items;
      expect(updatedItems.first.isCompleted, isTrue);
    });

    testWidgets('sort random option disables ascending button',
        (WidgetTester tester) async {
      await _pumpListDetailPage(
        tester,
        list: testList,
      );

      final dropdown = find.byType(DropdownButtonFormField<TaskSortField>);
      final dropdownState = tester.state<FormFieldState<TaskSortField>>(dropdown);
      dropdownState.didChange(TaskSortField.random);
      await _settle(tester);

      expect(find.byIcon(Icons.casino), findsOneWidget);

      final sortIconFinder = find.ancestor(
        of: find.byIcon(Icons.arrow_downward),
        matching: find.byType(IconButton),
      );
      final IconButton sortIcon = tester.widget(sortIconFinder);
      expect(sortIcon.onPressed, isNull);
    });

    testWidgets('switching sort back to name re-enables ascending button',
        (WidgetTester tester) async {
      await _pumpListDetailPage(
        tester,
        list: testList,
      );

      final dropdown = find.byType(DropdownButtonFormField<TaskSortField>);
      final dropdownState = tester.state<FormFieldState<TaskSortField>>(dropdown);
      dropdownState.didChange(TaskSortField.random);
      await _settle(tester);

      dropdownState.didChange(TaskSortField.name);
      await _settle(tester);

      final sortIconFinder = find.ancestor(
        of: find.byIcon(Icons.arrow_downward),
        matching: find.byType(IconButton),
      );
      final IconButton sortIcon = tester.widget(sortIconFinder);
      expect(sortIcon.onPressed, isNotNull);
      expect(find.byIcon(Icons.casino), findsNothing);
    });
  });
}

class _SpyListsController extends ListsControllerSlim {
  _SpyListsController({
    required IListsInitializationManager initializationManager,
    required IListsPerformanceMonitor performanceMonitor,
    required ListsCrudOperations crudOperations,
    required ListsStateManager stateManager,
    required ILogger logger,
    required ListItemSyncService syncService,
  }) : super(
          initializationManager: initializationManager,
          performanceMonitor: performanceMonitor,
          crudOperations: crudOperations,
          stateManager: stateManager,
          syncService: syncService,
          logger: logger,
        );

  ListItem? lastUpdatedItem;

  @override
  Future<void> updateListItem(String listId, ListItem item) async {
    lastUpdatedItem = item;
    await super.updateListItem(listId, item);
  }
}

class _InMemoryListsPersistenceManager implements IListsPersistenceManager {
  _InMemoryListsPersistenceManager({required List<CustomList> initialLists})
      : _lists = List<CustomList>.from(initialLists);

  List<CustomList> _lists;

  @override
  Future<List<CustomList>> loadAllLists() async => List.unmodifiable(_lists);

  @override
  Future<void> saveList(CustomList list) async {
    _lists = [
      ..._lists.where((existing) => existing.id != list.id),
      list,
    ];
  }

  @override
  Future<void> updateList(CustomList list) async {
    await saveList(list);
  }

  @override
  Future<void> deleteList(String listId) async {
    _lists = _lists.where((list) => list.id != listId).toList();
  }

  @override
  Future<List<ListItem>> loadListItems(String listId) async {
    final list = _lists.firstWhere(
      (l) => l.id == listId,
      orElse: () => CustomList(
        id: listId,
        name: 'temp',
        type: ListType.CUSTOM,
        description: null,
        items: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return List<ListItem>.from(list.items);
  }

  @override
  Future<void> saveListItem(ListItem item) async {
    _lists = _lists.map((list) {
      if (list.id != item.listId) return list;
      final updatedItems = [...list.items.where((i) => i.id != item.id), item];
      return list.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<void> updateListItem(ListItem item) async {
    _lists = _lists.map((list) {
      if (list.id != item.listId) return list;
      return list.updateItem(item);
    }).toList();
  }

  @override
  Future<void> deleteListItem(String itemId) async {
    _lists = _lists.map((list) {
      final containsItem = list.items.any((item) => item.id == itemId);
      if (!containsItem) return list;
      return list.removeItem(itemId);
    }).toList();
  }

  @override
  Future<void> saveMultipleItems(List<ListItem> items) async {
    for (final item in items) {
      await saveListItem(item);
    }
  }

  @override
  Future<List<CustomList>> forceReloadFromPersistence() async =>
      List.unmodifiable(_lists);

  @override
  Future<void> clearAllData() async {
    _lists = [];
  }

  @override
  Future<void> verifyListPersistence(String listId) async {}

  @override
  Future<void> verifyItemPersistence(String itemId) async {}

  @override
  Future<void> rollbackItems(List<ListItem> items) async {}
}

class _ImmediateInitManager implements IListsInitializationManager {
  bool _initialized = false;

  @override
  Future<void> initializeAdaptive() async {}

  @override
  Future<void> initializeLegacy() async {}

  @override
  Future<void> initializeAsync() async {
    _initialized = true;
  }

  @override
  bool get isInitialized => _initialized;

  @override
  String get initializationMode => 'test';
}

class _NoopPerformanceMonitor implements IListsPerformanceMonitor {
  @override
  void endOperation(String operationName) {}

  @override
  Map<String, dynamic> getDetailedMetrics() => const {};

  @override
  Map<String, dynamic> getPerformanceStats() => const {};

  @override
  void logError(String operation, Object error, [StackTrace? stackTrace]) {}

  @override
  void logInfo(String message, {String? context}) {}

  @override
  void logWarning(String message, {String? context}) {}

  @override
  void monitorCacheOperation(String operation, bool hit) {}

  @override
  void monitorCollectionSize(String collection, int size) {}

  @override
  void resetStats() {}

  @override
  void startOperation(String operationName) {}
}

class _NoopLogger implements ILogger {
  @override
  void debug(String message, {String? context, String? correlationId, dynamic data}) {}

  @override
  void info(String message, {String? context, String? correlationId, dynamic data}) {}

  @override
  void warning(String message, {String? context, String? correlationId, dynamic data}) {}

  @override
  void error(String message, {String? context, String? correlationId, dynamic error, StackTrace? stackTrace}) {}

  @override
  void fatal(String message, {String? context, String? correlationId, dynamic error, StackTrace? stackTrace}) {}

  @override
  void performance(String operation, Duration duration,
      {String? context, String? correlationId, Map<String, dynamic>? metrics}) {}

  @override
  void userAction(String action,
      {String? context, String? correlationId, Map<String, dynamic>? properties}) {}
}
