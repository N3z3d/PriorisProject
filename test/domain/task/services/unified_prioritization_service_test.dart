import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/task/services/unified_prioritization_service.dart';
import 'package:prioris/domain/task/services/list_item_task_converter.dart';
import 'package:prioris/data/repositories/task_repository.dart';

// Generate mock classes
@GenerateNiceMocks([MockSpec<TaskRepository>()])
import 'unified_prioritization_service_test.mocks.dart';

void main() {
  group('UnifiedPrioritizationService', () {
    late UnifiedPrioritizationService service;
    late MockTaskRepository mockTaskRepository;
    late ListItemTaskConverter converter;
    late DateTime testDate;

    setUp(() {
      mockTaskRepository = MockTaskRepository();
      converter = ListItemTaskConverter();
      service = UnifiedPrioritizationService(
        taskRepository: mockTaskRepository,
        converter: converter,
      );
      testDate = DateTime(2024, 1, 15, 10, 30);
    });

    group('getTasksForPrioritization', () {
      test('should return tasks sorted by ELO score', () async {
        // Arrange
        final tasks = [
          Task(id: '1', title: 'Low Priority', eloScore: 1100, createdAt: testDate),
          Task(id: '2', title: 'High Priority', eloScore: 1400, createdAt: testDate),
          Task(id: '3', title: 'Medium Priority', eloScore: 1250, createdAt: testDate),
        ];
        when(mockTaskRepository.getAllTasks()).thenAnswer((_) async => tasks);

        // Act
        final result = await service.getTasksForPrioritization();

        // Assert
        expect(result, hasLength(3));
        expect(result[0].title, equals('High Priority'));
        expect(result[1].title, equals('Medium Priority'));
        expect(result[2].title, equals('Low Priority'));
        verify(mockTaskRepository.getAllTasks()).called(1);
      });

      test('should filter out completed tasks', () async {
        // Arrange
        final tasks = [
          Task(id: '1', title: 'Pending Task', isCompleted: false, createdAt: testDate),
          Task(id: '2', title: 'Completed Task', isCompleted: true, createdAt: testDate),
          Task(id: '3', title: 'Another Pending', isCompleted: false, createdAt: testDate),
        ];
        when(mockTaskRepository.getAllTasks()).thenAnswer((_) async => tasks);

        // Act
        final result = await service.getTasksForPrioritization();

        // Assert
        expect(result, hasLength(2));
        expect(result.every((task) => !task.isCompleted), isTrue);
      });
    });

    group('getListItemsAsTasks', () {
      test('should convert ListItems to Tasks for prioritization', () async {
        // Arrange
        final listItems = [
          ListItem(id: '1', title: 'ListItem 1', eloScore: 1300, createdAt: testDate, listId: 'list-1'),
          ListItem(id: '2', title: 'ListItem 2', eloScore: 1150, createdAt: testDate, listId: 'list-2'),
        ];

        // Act
        final result = service.getListItemsAsTasks(listItems);

        // Assert
        expect(result, hasLength(2));
        expect(result[0].title, equals('ListItem 1'));
        expect(result[0].eloScore, equals(1300));
        expect(result[0].tags, contains('list-1'));
        expect(result[1].tags, contains('list-2'));
      });

      test('should filter incomplete ListItems and sort by ELO', () async {
        // Arrange
        final listItems = [
          ListItem(id: '1', title: 'Completed', isCompleted: true, eloScore: 1400, createdAt: testDate),
          ListItem(id: '2', title: 'High Priority', isCompleted: false, eloScore: 1350, createdAt: testDate),
          ListItem(id: '3', title: 'Low Priority', isCompleted: false, eloScore: 1200, createdAt: testDate),
        ];

        // Act
        final result = service.getListItemsAsTasks(listItems);

        // Assert
        expect(result, hasLength(2));
        expect(result[0].title, equals('High Priority'));
        expect(result[1].title, equals('Low Priority'));
      });
    });

    group('createDuelFromListItems', () {
      test('should return null when less than 2 items available', () {
        // Arrange
        final listItems = [
          ListItem(id: '1', title: 'Only One', createdAt: testDate),
        ];

        // Act
        final result = service.createDuelFromListItems(listItems);

        // Assert
        expect(result, isNull);
      });

      test('should return 2 tasks from available ListItems', () {
        // Arrange
        final listItems = [
          ListItem(id: '1', title: 'Item 1', createdAt: testDate),
          ListItem(id: '2', title: 'Item 2', createdAt: testDate),
          ListItem(id: '3', title: 'Item 3', createdAt: testDate),
          ListItem(id: '4', title: 'Item 4', createdAt: testDate),
        ];

        // Act
        final result = service.createDuelFromListItems(listItems);

        // Assert
        expect(result, isNotNull);
        expect(result, hasLength(2));
        expect(result![0].title, isNotEmpty);
        expect(result[1].title, isNotEmpty);
        expect(result[0].id, isNot(equals(result[1].id)));
      });

      test('should only include incomplete items', () {
        // Arrange
        final listItems = [
          ListItem(id: '1', title: 'Available 1', isCompleted: false, createdAt: testDate),
          ListItem(id: '2', title: 'Completed', isCompleted: true, createdAt: testDate),
          ListItem(id: '3', title: 'Available 2', isCompleted: false, createdAt: testDate),
        ];

        // Act
        final result = service.createDuelFromListItems(listItems);

        // Assert
        expect(result, isNotNull);
        expect(result, hasLength(2));
        expect(result!.every((task) => !task.isCompleted), isTrue);
      });
    });

    group('updateEloScoresFromDuel', () {
      test('should update ELO scores for both tasks and return updated tasks', () async {
        // Arrange
        final winner = Task(id: '1', title: 'Winner', eloScore: 1200, createdAt: testDate);
        final loser = Task(id: '2', title: 'Loser', eloScore: 1200, createdAt: testDate);

        when(mockTaskRepository.updateEloScores(any, any)).thenAnswer((_) async {});

        // Act
        final result = await service.updateEloScoresFromDuel(winner, loser);

        // Assert
        expect(result.winner.eloScore, greaterThan(1200));
        expect(result.loser.eloScore, lessThan(1200));
        verify(mockTaskRepository.updateEloScores(any, any)).called(1);
      });
    });
  });
}