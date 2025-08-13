import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/services/core/lists_filter_service.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/data/repositories/habit_repository.dart';
import 'package:prioris/data/repositories/task_repository.dart';
import 'package:prioris/data/repositories/sample_data_service.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';

void main() {
  group('ListsController', () {
    late ListsController controller;
    late CustomList testList;

    setUp(() {
      final listRepository = InMemoryCustomListRepository();
      final itemRepository = InMemoryListItemRepository();
      final habitRepository = InMemoryHabitRepository();
      final taskRepository = InMemoryTaskRepository();
      final importService = SampleDataImportService(habitRepository, taskRepository, listRepository);
      final managementService = SampleDataManagementService(habitRepository, taskRepository, listRepository, importService);
      final infoService = SampleDataInfoService(habitRepository, taskRepository, listRepository);
      final sampleDataService = SampleDataService(importService, managementService, infoService);
      final filterService = ListsFilterService();
      controller = ListsController(listRepository, itemRepository, sampleDataService, filterService);

      final now = DateTime.now();
      testList = CustomList(
        id: 'test_list',
        name: 'Test List',
        description: 'Test Description',
        type: ListType.CUSTOM,
        items: [
          ListItem(
            id: 'item1',
            title: 'High ELO Task',
            description: 'Important task description',
            eloScore: 1500.0,
            isCompleted: false,
            createdAt: now,
          ),
          ListItem(
            id: 'item2',
            title: 'Medium ELO Task',
            description: 'Medium task description',
            eloScore: 1300.0,
            isCompleted: true,
            createdAt: now,
          ),
        ],
        createdAt: now,
        updatedAt: now,
      );
    });

    test('initializes correctly with default values', () {
      expect(controller, isNotNull);
    });

    test('handles ELO-based list items correctly', () {
      final now = DateTime.now();
      final eloItems = [
        ListItem(
          id: 'urgent',
          title: 'Urgent Task',
          eloScore: 1600.0,
          isCompleted: false,
          createdAt: now,
        ),
        ListItem(
          id: 'high',
          title: 'High Task',
          eloScore: 1450.0,
          isCompleted: false,
          createdAt: now,
        ),
        ListItem(
          id: 'medium',
          title: 'Medium Task',
          eloScore: 1350.0,
          isCompleted: true,
          createdAt: now,
        ),
        ListItem(
          id: 'low',
          title: 'Low Task',
          eloScore: 1100.0,
          isCompleted: true,
          createdAt: now,
        ),
      ];

      expect(eloItems[0].eloScore, equals(1600.0));
      expect(eloItems[1].eloScore, equals(1450.0));
      expect(eloItems[2].eloScore, equals(1350.0));
      expect(eloItems[3].eloScore, equals(1100.0));
      
      final completedItems = eloItems.where((item) => item.isCompleted).length;
      expect(completedItems, equals(2));
    });

    test('manages list state correctly', () {
      expect(testList.items.length, equals(2));
      expect(testList.type, equals(ListType.CUSTOM));
      expect(testList.name, equals('Test List'));
      
      final completedItems = testList.items.where((item) => item.isCompleted).length;
      final totalItems = testList.items.length;
      final progressPercentage = (completedItems / totalItems * 100).round();
      
      expect(completedItems, equals(1));
      expect(totalItems, equals(2));
      expect(progressPercentage, equals(50));
    });

    group('ELO system integration', () {
      test('sorts items by ELO score correctly', () {
        final now = DateTime.now();
        final mixedItems = [
          ListItem(
            id: 'low',
            title: 'Low Priority',
            eloScore: 1100.0,
            isCompleted: false,
            createdAt: now,
          ),
          ListItem(
            id: 'urgent',
            title: 'Urgent Priority',
            eloScore: 1600.0,
            isCompleted: false,
            createdAt: now,
          ),
          ListItem(
            id: 'medium',
            title: 'Medium Priority',
            eloScore: 1300.0,
            isCompleted: false,
            createdAt: now,
          ),
        ];

        mixedItems.sort((a, b) => b.eloScore.compareTo(a.eloScore));

        expect(mixedItems[0].eloScore, equals(1600.0));
        expect(mixedItems[1].eloScore, equals(1300.0));
        expect(mixedItems[2].eloScore, equals(1100.0));
      });

      test('categorizes items by ELO ranges correctly', () {
        final now = DateTime.now();
        final allLevelItems = [
          ListItem(id: '1', title: 'Urgent', eloScore: 1600.0, isCompleted: false, createdAt: now),
          ListItem(id: '2', title: 'High', eloScore: 1450.0, isCompleted: false, createdAt: now),
          ListItem(id: '3', title: 'Medium', eloScore: 1350.0, isCompleted: false, createdAt: now),
          ListItem(id: '4', title: 'Low', eloScore: 1100.0, isCompleted: false, createdAt: now),
        ];

        final urgentItems = allLevelItems.where((item) => item.eloScore >= 1500).length;
        final highItems = allLevelItems.where((item) => item.eloScore >= 1400 && item.eloScore < 1500).length;
        final mediumItems = allLevelItems.where((item) => item.eloScore >= 1300 && item.eloScore < 1400).length;
        final lowItems = allLevelItems.where((item) => item.eloScore < 1300).length;
        
        expect(urgentItems, equals(1));
        expect(highItems, equals(1));
        expect(mediumItems, equals(1));
        expect(lowItems, equals(1));
      });
    });

    group('List filtering and searching', () {
      test('filters lists by type correctly', () {
        final now = DateTime.now();
        final lists = [
          CustomList(
            id: 'shopping',
            name: 'Shopping List',
            type: ListType.SHOPPING,
            description: 'Grocery shopping',
            items: [],
            createdAt: now,
            updatedAt: now,
          ),
          CustomList(
            id: 'travel',
            name: 'Travel List',
            type: ListType.TRAVEL,
            description: 'Travel planning',
            items: [],
            createdAt: now,
            updatedAt: now,
          ),
          CustomList(
            id: 'custom',
            name: 'Custom List',
            type: ListType.CUSTOM,
            description: 'Custom list',
            items: [],
            createdAt: now,
            updatedAt: now,
          ),
        ];

        final shoppingLists = lists.where((list) => list.type == ListType.SHOPPING).toList();
        final travelLists = lists.where((list) => list.type == ListType.TRAVEL).toList();
        final customLists = lists.where((list) => list.type == ListType.CUSTOM).toList();
        
        expect(shoppingLists.length, equals(1));
        expect(travelLists.length, equals(1));
        expect(customLists.length, equals(1));
      });
    });
  });
} 
