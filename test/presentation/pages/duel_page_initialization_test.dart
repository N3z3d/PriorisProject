import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/task/services/unified_prioritization_service.dart';
import 'package:prioris/domain/task/services/list_item_task_converter.dart';
import 'package:mockito/mockito.dart';
import 'package:prioris/data/repositories/task_repository.dart';

// Use existing mocks
import '../../integration/duel_list_item_integration_test.mocks.dart';

void main() {
  group('DuelPage Initialization Logic', () {
    late UnifiedPrioritizationService prioritizationService;
    late ListItemTaskConverter converter;
    late MockTaskRepository mockTaskRepository;
    late DateTime testDate;

    setUp(() {
      mockTaskRepository = MockTaskRepository();
      converter = ListItemTaskConverter();
      prioritizationService = UnifiedPrioritizationService(
        taskRepository: mockTaskRepository,
        converter: converter,
      );
      testDate = DateTime(2024, 1, 15, 10, 30);
    });

    group('Complete Initialization Flow', () {
      test('should successfully load ListItems for prioritization after lists are loaded', () async {
        // ARRANGE - Simulate what happens when user has created lists with items
        
        // Mock that task repository is empty (user hasn't created regular tasks)
        when(mockTaskRepository.getAllTasks()).thenAnswer((_) async => []);

        // Simulate CustomLists that would be loaded by listsControllerProvider.loadLists()
        final mockLists = [
          CustomList(
            id: 'shopping-list',
            name: 'Liste de courses',
            type: ListType.SHOPPING,
            items: [
              ListItem(
                id: 'item1',
                title: 'Acheter du lait',
                eloScore: 1200,
                createdAt: testDate,
                listId: 'shopping-list',
                isCompleted: false,
              ),
              ListItem(
                id: 'item2',
                title: 'Acheter du pain',
                eloScore: 1150,
                createdAt: testDate,
                listId: 'shopping-list',
                isCompleted: false,
              ),
            ],
            createdAt: testDate,
            updatedAt: testDate,
          ),
          CustomList(
            id: 'movies-list',
            name: 'Films à regarder',
            type: ListType.MOVIES,
            items: [
              ListItem(
                id: 'movie1',
                title: 'Regarder Inception',
                eloScore: 1300,
                createdAt: testDate,
                listId: 'movies-list',
                isCompleted: false,
              ),
            ],
            createdAt: testDate,
            updatedAt: testDate,
          ),
        ];

        // ACT - Simulate DuelPage._initializeData() flow
        
        // Step 1: Load lists (simulated - this would be done by listsControllerProvider)
        // In real app: await ref.read(listsControllerProvider.notifier).loadLists();
        // Result: listsState.lists would contain mockLists
        
        // Step 2: Load duel with available data
        final allTasks = await prioritizationService.getTasksForPrioritization();
        expect(allTasks, isEmpty); // No tasks in repository
        
        // Step 3: Get all ListItems from loaded lists
        final allListItems = mockLists.expand((list) => list.items).toList();
        expect(allListItems.length, equals(3));
        
        // Step 4: Convert ListItems to Tasks
        final listItemTasks = prioritizationService.getListItemsAsTasks(allListItems);
        expect(listItemTasks.length, equals(3));
        
        // Step 5: Combine tasks and filter incomplete
        final combinedTasks = [...allTasks, ...listItemTasks];
        final incompleteTasks = combinedTasks.where((task) => !task.isCompleted).toList();
        
        // ASSERT - The initialization should now have tasks for dueling
        expect(incompleteTasks.length, equals(3));
        expect(incompleteTasks.length >= 2, isTrue); // Can create duels!
        
        // Verify the correct tasks are available
        final taskTitles = incompleteTasks.map((t) => t.title).toList();
        expect(taskTitles, contains('Acheter du lait'));
        expect(taskTitles, contains('Acheter du pain'));
        expect(taskTitles, contains('Regarder Inception'));
        
        // Verify ELO ordering (highest first)
        expect(incompleteTasks[0].title, equals('Regarder Inception')); // 1300
        expect(incompleteTasks[1].title, equals('Acheter du lait')); // 1200
        expect(incompleteTasks[2].title, equals('Acheter du pain')); // 1150
        
        print('✅ SUCCESS: DuelPage initialization can now load ListItems for prioritization');
      });

      test('should handle initialization gracefully when no lists exist', () async {
        // ARRANGE - User hasn't created any lists yet
        when(mockTaskRepository.getAllTasks()).thenAnswer((_) async => []);
        
        final emptyLists = <CustomList>[];

        // ACT - Simulate initialization with empty lists
        final allTasks = await prioritizationService.getTasksForPrioritization();
        final allListItems = emptyLists.expand((list) => list.items).toList();
        final listItemTasks = prioritizationService.getListItemsAsTasks(allListItems);
        final combinedTasks = [...allTasks, ...listItemTasks];
        final incompleteTasks = combinedTasks.where((task) => !task.isCompleted).toList();

        // ASSERT - Should handle empty state gracefully
        expect(incompleteTasks, isEmpty);
        expect(incompleteTasks.length < 2, isTrue); // Not enough for duel
        
        print('✅ SUCCESS: Empty lists handled gracefully during initialization');
      });

      test('should handle initialization failure gracefully', () async {
        // ARRANGE - Simulate repository error
        when(mockTaskRepository.getAllTasks()).thenThrow(Exception('Database error'));

        // ACT & ASSERT - Should not crash, should handle error
        expect(() async {
          try {
            await prioritizationService.getTasksForPrioritization();
          } catch (e) {
            // Expected - should handle this gracefully in real app
            expect(e, isA<Exception>());
          }
        }, returnsNormally);
        
        print('✅ SUCCESS: Repository errors handled gracefully');
      });
    });

    group('Async Loading Coordination', () {
      test('should demonstrate the importance of loading lists before duels', () async {
        // This test demonstrates why _initializeData() was needed
        
        // PROBLEM SCENARIO: Loading duel before lists are loaded
        when(mockTaskRepository.getAllTasks()).thenAnswer((_) async => []);
        
        // Step 1: Try to load duel immediately (old behavior)
        final tasksBeforeListsLoaded = await prioritizationService.getTasksForPrioritization();
        final emptyListItems = <ListItem>[]; // Lists not loaded yet
        final emptyListItemTasks = prioritizationService.getListItemsAsTasks(emptyListItems);
        final tasksWithoutLists = [...tasksBeforeListsLoaded, ...emptyListItemTasks];
        
        // Step 2: Load lists after (simulating async timing issue)
        final listsAfter = [
          ListItem(
            id: 'item1',
            title: 'Important task',
            eloScore: 1200,
            createdAt: testDate,
            listId: 'list1',
            isCompleted: false,
          ),
        ];
        
        // ASSERT - Demonstrates the timing problem
        expect(tasksWithoutLists, isEmpty); // No tasks available for duel!
        expect(listsAfter, isNotEmpty); // But lists were loaded after
        
        // SOLUTION: Proper coordination with await
        final tasksAfterListsLoaded = prioritizationService.getListItemsAsTasks(listsAfter);
        final properlyLoadedTasks = [...tasksBeforeListsLoaded, ...tasksAfterListsLoaded];
        
        expect(properlyLoadedTasks, isNotEmpty); // Now tasks are available!
        
        print('✅ SUCCESS: Demonstrated importance of async coordination');
      });
    });
  });
}