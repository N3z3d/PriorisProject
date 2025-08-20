import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/task/services/unified_prioritization_service.dart';
import 'package:prioris/domain/task/services/list_item_task_converter.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:prioris/data/repositories/task_repository.dart';

// Utiliser les mocks existants
@GenerateNiceMocks([MockSpec<TaskRepository>()])
import 'duel_list_item_integration_test.mocks.dart';

void main() {
  group('DuelPage ListItem Integration - User Scenario', () {
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

    test('SCENARIO: User creates list with items and can prioritize them', () async {
      // ARRANGE - User has created a shopping list with items
      final shoppingListItems = [
        ListItem(
          id: 'item1',
          title: 'Acheter du lait',
          description: 'Lait entier bio',
          eloScore: 1200,
          createdAt: testDate,
          listId: 'shopping-list',
          isCompleted: false,
        ),
        ListItem(
          id: 'item2',
          title: 'Acheter du pain',
          description: 'Pain complet',
          eloScore: 1150,
          createdAt: testDate,
          listId: 'shopping-list',
          isCompleted: false,
        ),
        ListItem(
          id: 'item3',
          title: 'Acheter des œufs',
          description: 'Œufs biologiques',
          eloScore: 1180,
          createdAt: testDate,
          listId: 'shopping-list',
          isCompleted: false,
        ),
      ];

      final shoppingList = CustomList(
        id: 'shopping-list',
        name: 'Liste de courses',
        type: ListType.SHOPPING,
        description: 'Ma liste de courses hebdomadaire',
        items: shoppingListItems,
        createdAt: testDate,
        updatedAt: testDate,
      );

      // Mock repository response (no tasks in task repository)
      when(mockTaskRepository.getAllTasks()).thenAnswer((_) async => []);

      // ACT - Simulate what DuelPage._loadNewDuel() does

      // 1. Get tasks from task repository (empty in this case)
      final allTasks = await prioritizationService.getTasksForPrioritization();
      expect(allTasks, isEmpty);

      // 2. Convert ListItems from all lists to tasks
      final allListItems = shoppingList.items;
      final listItemTasks = prioritizationService.getListItemsAsTasks(allListItems);

      // 3. Combine all tasks
      final combinedTasks = [...allTasks, ...listItemTasks];
      final incompleteTasks = combinedTasks.where((task) => !task.isCompleted).toList();

      // ASSERT - The system should now have tasks available for dueling
      expect(incompleteTasks.length, equals(3));
      expect(incompleteTasks.length >= 2, isTrue); // Can create duels

      // Verify task details from ListItems
      expect(incompleteTasks.any((task) => task.title == 'Acheter du lait'), isTrue);
      expect(incompleteTasks.any((task) => task.title == 'Acheter du pain'), isTrue);
      expect(incompleteTasks.any((task) => task.title == 'Acheter des œufs'), isTrue);

      // Verify tasks are sorted by ELO (highest first)
      expect(incompleteTasks[0].title, equals('Acheter du lait')); // 1200
      expect(incompleteTasks[1].title, equals('Acheter des œufs')); // 1180
      expect(incompleteTasks[2].title, equals('Acheter du pain')); // 1150

      // 4. Create a duel (simulate random selection)
      final duelTasks = incompleteTasks.take(2).toList();
      expect(duelTasks.length, equals(2));

      // ASSERT - The user can now participate in dueling with their list items
      print('✅ SUCCESS: User can duel between "${duelTasks[0].title}" and "${duelTasks[1].title}"');
    });

    test('SCENARIO: User has mixed Tasks and ListItems', () async {
      // ARRANGE - User has both regular tasks and list items
      final regularTasks = <Task>[
        // Empty for this test - no existing tasks in repository
      ];

      final listItems = [
        ListItem(
          id: 'movie1',
          title: 'Regarder Inception',
          eloScore: 1300,
          createdAt: testDate,
          listId: 'movies',
          isCompleted: false,
        ),
        ListItem(
          id: 'book1',
          title: 'Lire 1984',
          eloScore: 1250,
          createdAt: testDate,
          listId: 'books',
          isCompleted: false,
        ),
      ];

      // Mock task repository with some tasks
      when(mockTaskRepository.getAllTasks()).thenAnswer((_) async => regularTasks);

      // ACT
      final taskRepositoryTasks = await prioritizationService.getTasksForPrioritization();
      final listItemTasks = prioritizationService.getListItemsAsTasks(listItems);
      final allTasks = [...taskRepositoryTasks, ...listItemTasks];

      // ASSERT
      expect(allTasks.length, equals(2)); // 0 regular tasks + 2 list items
      expect(allTasks[0].title, equals('Regarder Inception')); // Higher ELO
      expect(allTasks[1].title, equals('Lire 1984'));

      print('✅ SUCCESS: Mixed tasks and list items work together');
    });

    test('SCENARIO: User completes some items, they should not appear in duels', () async {
      // ARRANGE
      final listItems = [
        ListItem(
          id: 'task1',
          title: 'Completed task',
          eloScore: 1400,
          createdAt: testDate,
          listId: 'list1',
          isCompleted: true, // COMPLETED
        ),
        ListItem(
          id: 'task2',
          title: 'Active task 1',
          eloScore: 1200,
          createdAt: testDate,
          listId: 'list1',
          isCompleted: false,
        ),
        ListItem(
          id: 'task3',
          title: 'Active task 2',
          eloScore: 1180,
          createdAt: testDate,
          listId: 'list1',
          isCompleted: false,
        ),
      ];

      when(mockTaskRepository.getAllTasks()).thenAnswer((_) async => []);

      // ACT
      final allTasks = await prioritizationService.getTasksForPrioritization();
      final listItemTasks = prioritizationService.getListItemsAsTasks(listItems);
      final combinedTasks = [...allTasks, ...listItemTasks];
      final incompleteTasks = combinedTasks.where((task) => !task.isCompleted).toList();

      // ASSERT
      expect(incompleteTasks.length, equals(2)); // Only incomplete items
      expect(incompleteTasks.any((task) => task.title == 'Completed task'), isFalse);
      expect(incompleteTasks.any((task) => task.title == 'Active task 1'), isTrue);
      expect(incompleteTasks.any((task) => task.title == 'Active task 2'), isTrue);

      print('✅ SUCCESS: Completed items are correctly filtered out');
    });

    test('SCENARIO: Empty lists should not break the duel system', () async {
      // ARRANGE - User has empty lists
      when(mockTaskRepository.getAllTasks()).thenAnswer((_) async => []);

      // ACT
      final allTasks = await prioritizationService.getTasksForPrioritization();
      final listItemTasks = prioritizationService.getListItemsAsTasks([]); // Empty lists
      final combinedTasks = [...allTasks, ...listItemTasks];

      // ASSERT
      expect(combinedTasks, isEmpty);
      expect(combinedTasks.length < 2, isTrue); // Not enough for duel
      
      print('✅ SUCCESS: Empty lists handled gracefully');
    });
  });
}