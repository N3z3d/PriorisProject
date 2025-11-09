import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/task/services/unified_prioritization_service.dart';
import 'package:prioris/presentation/pages/duel_page.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';
import 'package:prioris/data/providers/prioritization_providers.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/services/core/lists_filter_service.dart';

// Generate mock classes
@GenerateNiceMocks([
  MockSpec<UnifiedPrioritizationService>(),
  MockSpec<CustomListRepository>(),
  MockSpec<ListItemRepository>(),
  MockSpec<ListsFilterService>(),
])
import 'duel_page_prioritization_test.mocks.dart';

void main() {
  group('DuelPage Prioritization Integration', () {
    late MockUnifiedPrioritizationService mockPrioritizationService;
    late MockCustomListRepository mockListRepository;
    late MockListItemRepository mockItemRepository;
    late MockListsFilterService mockFilterService;
    late DateTime testDate;
    
    setUp(() {
      mockPrioritizationService = MockUnifiedPrioritizationService();
      mockListRepository = MockCustomListRepository();
      mockItemRepository = MockListItemRepository();
      mockFilterService = MockListsFilterService();
      testDate = DateTime(2024, 1, 15, 10, 30);
    });

    group('ListItem to Task Conversion Tests', () {
      testWidgets('should display duel when ListItems exist in lists', (tester) async {
        // ARRANGE - TDD RED Phase
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
        ];

        final testList = CustomList(
          id: 'list1',
          name: 'Courses',
          type: ListType.SHOPPING,
          items: listItems,
          createdAt: testDate,
          updatedAt: testDate,
        );

        // Mock service responses
        when(mockPrioritizationService.getTasksForPrioritization())
            .thenAnswer((_) async => <Task>[]);
        
        when(mockPrioritizationService.getListItemsAsTasks(any))
            .thenReturn([
          Task(
            id: 'item1',
            title: 'Acheter du lait',
            eloScore: 1200,
            createdAt: testDate,
            isCompleted: false,
          ),
          Task(
            id: 'item2',
            title: 'Faire les courses',
            eloScore: 1250,
            createdAt: testDate,
            isCompleted: false,
          ),
        ]);

        // Create test app with mocked providers
        final testApp = ProviderScope(
          overrides: [
            unifiedPrioritizationServiceProvider.overrideWithValue(mockPrioritizationService),
            // Mock the lists controller to return our test data
            listsControllerProvider.overrideWith((ref) => 
                ListsController(mockListRepository, mockItemRepository, mockFilterService)
                  ..state = ListsState(
                    lists: [testList],
                    filteredLists: [testList],
                    isLoading: false,
                    error: null,
                  )),
          ],
          child: const MaterialApp(home: DuelPage()),
        );

        // ACT
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // ASSERT - The test should show that ListItems are converted to Tasks for dueling
        expect(find.text('Acheter du lait'), findsOneWidget);
        expect(find.text('Faire les courses'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);

        // Verify service calls
        verify(mockPrioritizationService.getTasksForPrioritization()).called(1);
        verify(mockPrioritizationService.getListItemsAsTasks(any)).called(1);
      });

      testWidgets('should show no tasks state when no ListItems available', (tester) async {
        // ARRANGE
        when(mockPrioritizationService.getTasksForPrioritization())
            .thenAnswer((_) async => <Task>[]);
        
        when(mockPrioritizationService.getListItemsAsTasks(any))
            .thenReturn(<Task>[]);

        final testApp = ProviderScope(
          overrides: [
            unifiedPrioritizationServiceProvider.overrideWithValue(mockPrioritizationService),
            listsControllerProvider.overrideWith((ref) => 
                ListsController(mockListRepository, mockItemRepository, mockFilterService)
                  ..state = const ListsState(
                    lists: [],
                    filteredLists: [],
                    isLoading: false,
                    error: null,
                  )),
          ],
          child: const MaterialApp(home: DuelPage()),
        );

        // ACT
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // ASSERT
        expect(find.text('Pas assez de tâches'), findsOneWidget);
        expect(find.text('Ajoutez au moins 2 tâches pour commencer à les prioriser'), findsOneWidget);
      });

      testWidgets('should handle completed ListItems correctly', (tester) async {
        // ARRANGE - Mix of completed and incomplete items
        final listItems = [
          ListItem(
            id: 'item1',
            title: 'Tâche complétée',
            eloScore: 1200,
            createdAt: testDate,
            listId: 'list1',
            isCompleted: true, // This should be filtered out
          ),
          ListItem(
            id: 'item2',
            title: 'Tâche active',
            eloScore: 1250,
            createdAt: testDate,
            listId: 'list1',
            isCompleted: false,
          ),
          ListItem(
            id: 'item3',
            title: 'Autre tâche active',
            eloScore: 1100,
            createdAt: testDate,
            listId: 'list1',
            isCompleted: false,
          ),
        ];

        final testList = CustomList(
          id: 'list1',
          name: 'Test List',
          type: ListType.CUSTOM,
          items: listItems,
          createdAt: testDate,
          updatedAt: testDate,
        );

        when(mockPrioritizationService.getTasksForPrioritization())
            .thenAnswer((_) async => <Task>[]);
        
        // Service should only return incomplete items
        when(mockPrioritizationService.getListItemsAsTasks(any))
            .thenReturn([
          Task(
            id: 'item2',
            title: 'Tâche active',
            eloScore: 1250,
            createdAt: testDate,
            isCompleted: false,
          ),
          Task(
            id: 'item3',
            title: 'Autre tâche active',
            eloScore: 1100,
            createdAt: testDate,
            isCompleted: false,
          ),
        ]);

        final testApp = ProviderScope(
          overrides: [
            unifiedPrioritizationServiceProvider.overrideWithValue(mockPrioritizationService),
            listsControllerProvider.overrideWith((ref) => 
                ListsController(mockListRepository, mockItemRepository, mockFilterService)
                  ..state = ListsState(
                    lists: [testList],
                    filteredLists: [testList],
                    isLoading: false,
                    error: null,
                  )),
          ],
          child: const MaterialApp(home: DuelPage()),
        );

        // ACT
        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // ASSERT
        expect(find.text('Tâche complétée'), findsNothing); // Completed task should not appear
        expect(find.text('Tâche active'), findsOneWidget);
        expect(find.text('Autre tâche active'), findsOneWidget);
      });
    });

    group('ELO Score Updates from ListItems', () {
      testWidgets('should update ELO scores when duel completed with ListItem-based tasks', (tester) async {
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

        when(mockPrioritizationService.getTasksForPrioritization())
            .thenAnswer((_) async => <Task>[]);
        
        when(mockPrioritizationService.getListItemsAsTasks(any))
            .thenReturn([task1, task2]);

        when(mockPrioritizationService.updateEloScoresFromDuel(any, any))
            .thenAnswer((_) async => DuelResult(
              winner: task1.copyWith(eloScore: 1216),
              loser: task2.copyWith(eloScore: 1234),
            ));

        final testApp = ProviderScope(
          overrides: [
            unifiedPrioritizationServiceProvider.overrideWithValue(mockPrioritizationService),
            listsControllerProvider.overrideWith((ref) => 
                ListsController(mockListRepository, mockItemRepository, mockFilterService)
                  ..state = ListsState(
                    lists: [
                      CustomList(
                        id: 'list1',
                        name: 'Test',
                        type: ListType.CUSTOM,
                        items: [],
                        createdAt: testDate,
                        updatedAt: testDate,
                      )
                    ],
                    filteredLists: [
                      CustomList(
                        id: 'list1',
                        name: 'Test',
                        type: ListType.CUSTOM,
                        items: [],
                        createdAt: testDate,
                        updatedAt: testDate,
                      )
                    ],
                    isLoading: false,
                    error: null,
                  )),
          ],
          child: const MaterialApp(home: DuelPage()),
        );

        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // ACT - Tap on the first task card to select it as winner
        final firstTaskCard = find.text('Task 1').first;
        await tester.tap(firstTaskCard);
        await tester.pumpAndSettle();

        // ASSERT
        verify(mockPrioritizationService.updateEloScoresFromDuel(task1, task2)).called(1);
      });
    });
  });
}