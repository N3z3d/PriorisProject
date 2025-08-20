import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/task/services/unified_prioritization_service.dart';
import 'package:prioris/domain/task/services/list_item_task_converter.dart';
import 'package:prioris/data/repositories/task_repository.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/services/core/lists_filter_service.dart';

// Generate mock classes
@GenerateNiceMocks([
  MockSpec<TaskRepository>(),
  MockSpec<CustomListRepository>(),
  MockSpec<ListItemRepository>(),
  MockSpec<ListsFilterService>(),
])
import 'duel_list_item_integration_test.mocks.dart';

void main() {
  group('DuelPage ListItem Integration', () {
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

    group('ListItem to Task Conversion', () {
      test('should convert ListItems to Tasks successfully', () {
        // ARRANGE - TDD RED Phase: Test the core conversion logic
        final listItems = [
          ListItem(
            id: 'item1',
            title: 'Acheter du lait',
            eloScore: 1200,
            createdAt: testDate,
            listId: 'list1',
            isCompleted: false,
          ),
          ListItem(
            id: 'item2',
            title: 'Faire les courses',
            eloScore: 1250,
            createdAt: testDate,
            listId: 'list1',
            isCompleted: false,
          ),
          ListItem(
            id: 'item3',
            title: 'Tâche complétée',
            eloScore: 1180,
            createdAt: testDate,
            listId: 'list1',
            isCompleted: true, // Cette tâche ne devrait pas apparaître
          ),
        ];

        // ACT
        final tasks = prioritizationService.getListItemsAsTasks(listItems);

        // ASSERT - Only incomplete ListItems should be converted
        expect(tasks.length, equals(2));
        expect(tasks[0].title, equals('Faire les courses')); // Higher ELO score first
        expect(tasks[1].title, equals('Acheter du lait'));
        expect(tasks[0].eloScore, equals(1250));
        expect(tasks[1].eloScore, equals(1200));
        
        // Verify Task properties from ListItem
        expect(tasks[0].isCompleted, equals(false));
        expect(tasks[1].isCompleted, equals(false));
        expect(tasks[0].tags, contains('list1'));
        expect(tasks[1].tags, contains('list1'));
      });

      test('should create duel from ListItems correctly', () {
        // ARRANGE
        final listItems = [
          ListItem(
            id: 'item1',
            title: 'Task 1',
            eloScore: 1200,
            createdAt: testDate,
            listId: 'list1',
            isCompleted: false,
          ),
          ListItem(
            id: 'item2', 
            title: 'Task 2',
            eloScore: 1250,
            createdAt: testDate,
            listId: 'list1',
            isCompleted: false,
          ),
        ];

        // ACT
        final duel = prioritizationService.createDuelFromListItems(listItems);

        // ASSERT
        expect(duel, isNotNull);
        expect(duel!.length, equals(2));
        expect(duel.every((task) => !task.isCompleted), isTrue);
      });

      test('should return null for duel when less than 2 items available', () {
        // ARRANGE
        final listItems = [
          ListItem(
            id: 'item1',
            title: 'Single task',
            eloScore: 1200,
            createdAt: testDate,
            listId: 'list1',
            isCompleted: false,
          ),
        ];

        // ACT
        final duel = prioritizationService.createDuelFromListItems(listItems);

        // ASSERT
        expect(duel, isNull);
      });

      test('should filter out completed items for duel', () {
        // ARRANGE
        final listItems = [
          ListItem(
            id: 'item1',
            title: 'Completed task',
            eloScore: 1200,
            createdAt: testDate,
            listId: 'list1',
            isCompleted: true,
          ),
          ListItem(
            id: 'item2',
            title: 'Another completed',
            eloScore: 1250,
            createdAt: testDate,
            listId: 'list1',
            isCompleted: true,
          ),
        ];

        // ACT
        final duel = prioritizationService.createDuelFromListItems(listItems);

        // ASSERT - No duel possible with only completed items
        expect(duel, isNull);
      });
    });

    group('ELO Score Management for ListItems', () {
      test('should update ELO scores correctly after duel', () async {
        // ARRANGE
        final task1 = Task(
          id: 'item1',
          title: 'Task 1',
          eloScore: 1200,
          createdAt: testDate,
          isCompleted: false,
        );

        final task2 = Task(
          id: 'item2',
          title: 'Task 2',
          eloScore: 1250,
          createdAt: testDate,
          isCompleted: false,
        );

        // Mock repository response
        when(mockTaskRepository.updateEloScores(any, any))
            .thenAnswer((_) async {});

        // ACT
        final result = await prioritizationService.updateEloScoresFromDuel(task1, task2);

        // ASSERT
        expect(result.winner.id, equals('item1'));
        expect(result.loser.id, equals('item2'));
        expect(result.winner.eloScore, greaterThan(1200)); // Winner should gain points
        expect(result.loser.eloScore, lessThan(1250)); // Loser should lose points
        verify(mockTaskRepository.updateEloScores(any, any)).called(1);
      });

      test('should convert Task back to ListItem correctly', () {
        // ARRANGE
        final task = Task(
          id: 'item1',
          title: 'Test Task',
          description: 'Test description',
          eloScore: 1300,
          createdAt: testDate,
          isCompleted: false,
          tags: ['list1'],
        );

        // ACT
        final listItem = prioritizationService.convertTaskBackToListItem(task);

        // ASSERT
        expect(listItem.id, equals('item1'));
        expect(listItem.title, equals('Test Task'));
        expect(listItem.description, equals('Test description'));
        expect(listItem.eloScore, equals(1300));
        expect(listItem.listId, equals('list1'));
        expect(listItem.isCompleted, equals(false));
      });
    });

    group('Integration with Multiple Lists', () {
      test('should handle multiple lists with different types', () {
        // ARRANGE
        final shoppingItems = [
          ListItem(
            id: 'shop1',
            title: 'Milk',
            eloScore: 1200,
            createdAt: testDate,
            listId: 'shopping-list',
            isCompleted: false,
          ),
          ListItem(
            id: 'shop2',
            title: 'Bread',
            eloScore: 1150,
            createdAt: testDate,
            listId: 'shopping-list',
            isCompleted: false,
          ),
        ];

        final movieItems = [
          ListItem(
            id: 'movie1',
            title: 'Inception',
            eloScore: 1400,
            createdAt: testDate,
            listId: 'movie-list',
            isCompleted: false,
          ),
        ];

        final allItems = [...shoppingItems, ...movieItems];

        // ACT
        final tasks = prioritizationService.getListItemsAsTasks(allItems);

        // ASSERT
        expect(tasks.length, equals(3));
        expect(tasks[0].title, equals('Inception')); // Highest ELO
        expect(tasks[1].title, equals('Milk'));
        expect(tasks[2].title, equals('Bread'));
        
        // Verify list IDs are preserved in tags
        expect(tasks[0].tags, contains('movie-list'));
        expect(tasks[1].tags, contains('shopping-list'));
        expect(tasks[2].tags, contains('shopping-list'));
      });
    });
  });
}