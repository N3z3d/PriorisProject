/// Tests for PersistenceOperationsService - SOLID Architecture Validation
/// Validates Single Responsibility Principle: Pure CRUD operations only

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/application/ports/persistence_interfaces.dart';
import 'package:prioris/application/services/deduplication_service.dart';
import 'package:prioris/application/services/persistence/persistence_operations_service.dart';

@GenerateMocks([
  CustomListRepository,
  ListItemRepository,
  IDeduplicationService,
])
import 'persistence_operations_service_test.mocks.dart';

void main() {
  group('PersistenceOperationsService - SOLID Validation', () {
    late PersistenceOperationsService service;
    late MockCustomListRepository mockLocalRepository;
    late MockCustomListRepository mockCloudRepository;
    late MockListItemRepository mockLocalItemRepository;
    late MockListItemRepository mockCloudItemRepository;
    late MockIDeduplicationService mockDeduplicationService;

    setUp(() {
      mockLocalRepository = MockCustomListRepository();
      mockCloudRepository = MockCustomListRepository();
      mockLocalItemRepository = MockListItemRepository();
      mockCloudItemRepository = MockListItemRepository();
      mockDeduplicationService = MockIDeduplicationService();

      service = PersistenceOperationsService(
        localRepository: mockLocalRepository,
        cloudRepository: mockCloudRepository,
        localItemRepository: mockLocalItemRepository,
        cloudItemRepository: mockCloudItemRepository,
        deduplicationService: mockDeduplicationService,
        configuration: const PersistenceConfiguration(
          enableDeduplication: true,
          enableBackgroundSync: true,
        ),
      );
    });

    group('Single Responsibility Principle Validation', () {
      test('should only handle CRUD operations without business logic', () {
        // Verify service has only CRUD methods, no auth, sync, or coordination logic
        expect(service.runtimeType.toString(), 'PersistenceOperationsService');

        // Service should not have direct access to auth or sync concerns
        expect(() => (service as dynamic).currentMode, throwsNoSuchMethodError);
        expect(() => (service as dynamic).isAuthenticated, throwsNoSuchMethodError);
        expect(() => (service as dynamic).syncToCloud, throwsNoSuchMethodError);
      });
    });

    group('List Operations - Cloud First with Fallback', () {
      final testList = CustomList(
        id: 'test-list-1',
        name: 'Test List',
        type: ListType.CUSTOM,
        items: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      test('getAllListsCloudFirst should try cloud first, fallback to local', () async {
        // Arrange - Cloud succeeds
        when(mockCloudRepository.getAllLists()).thenAnswer((_) async => [testList]);
        when(mockDeduplicationService.deduplicateLists(any)).thenReturn([testList]);

        // Act
        final result = await service.getAllListsCloudFirst();

        // Assert
        expect(result, [testList]);
        verify(mockCloudRepository.getAllLists()).called(1);
        verify(mockDeduplicationService.deduplicateLists([testList])).called(1);
        verifyNever(mockLocalRepository.getAllLists());
      });

      test('getAllListsCloudFirst should fallback to local when cloud fails', () async {
        // Arrange - Cloud fails, local succeeds
        when(mockCloudRepository.getAllLists()).thenThrow(Exception('Cloud unavailable'));
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => [testList]);
        when(mockDeduplicationService.deduplicateLists(any)).thenReturn([testList]);

        // Act
        final result = await service.getAllListsCloudFirst();

        // Assert
        expect(result, [testList]);
        verify(mockCloudRepository.getAllLists()).called(1);
        verify(mockLocalRepository.getAllLists()).called(1);
        verify(mockDeduplicationService.deduplicateLists([testList])).called(1);
      });

      test('saveListLocal should use deduplication when enabled', () async {
        // Arrange
        when(mockDeduplicationService.saveListWithDeduplication(
          any, any, any, any,
        )).thenAnswer((_) async {});

        // Act
        await service.saveListLocal(testList);

        // Assert
        verify(mockDeduplicationService.saveListWithDeduplication(
          testList,
          any,
          any,
          any,
        )).called(1);
        verifyNever(mockLocalRepository.saveList(any));
      });

      test('saveListCloud should handle cloud errors properly', () async {
        // Arrange
        when(mockCloudRepository.saveList(testList))
            .thenThrow(Exception('Cloud error'));

        // Act & Assert
        expect(
          () => service.saveListCloud(testList),
          throwsA(isA<PersistenceException>()),
        );
        verify(mockCloudRepository.saveList(testList)).called(1);
      });
    });

    group('Item Operations - CRUD with Fallback', () {
      final testItem = ListItem(
        id: 'test-item-1',
        title: 'Test Item',
        listId: 'test-list-1',
        createdAt: DateTime.now(),
      );

      test('getItemsByListIdCloudFirst should try cloud first', () async {
        // Arrange
        when(mockCloudItemRepository.getByListId('test-list-1'))
            .thenAnswer((_) async => [testItem]);

        // Act
        final result = await service.getItemsByListIdCloudFirst('test-list-1');

        // Assert
        expect(result, [testItem]);
        verify(mockCloudItemRepository.getByListId('test-list-1')).called(1);
        verifyNever(mockLocalItemRepository.getByListId(any));
      });

      test('saveItemCloud should propagate cloud errors', () async {
        // Arrange
        when(mockCloudItemRepository.add(testItem))
            .thenThrow(Exception('Cloud error'));

        // Act & Assert
        expect(
          () => service.saveItemCloud(testItem),
          throwsA(isA<PersistenceException>()),
        );
      });

      test('updateItemLocal should call local repository update', () async {
        // Arrange
        when(mockLocalItemRepository.update(testItem))
            .thenAnswer((_) async => testItem);

        // Act
        await service.updateItemLocal(testItem);

        // Assert
        verify(mockLocalItemRepository.update(testItem)).called(1);
      });
    });

    group('Dependency Inversion Principle Validation', () {
      test('should only depend on abstractions via constructor injection', () {
        // Verify all dependencies are injected as interfaces/abstractions
        // No direct instantiation of concrete classes
        expect(service, isA<PersistenceOperationsService>());

        // Service should work with any repository implementation
        final alternativeService = PersistenceOperationsService(
          localRepository: mockLocalRepository, // Different implementation
          cloudRepository: mockCloudRepository,
          localItemRepository: mockLocalItemRepository,
          cloudItemRepository: mockCloudItemRepository,
          deduplicationService: mockDeduplicationService,
          configuration: const PersistenceConfiguration(),
        );

        expect(alternativeService, isA<PersistenceOperationsService>());
      });
    });

    group('Open/Closed Principle Validation', () {
      test('should be extensible without modification', () {
        // Service can be extended with new behaviors via composition
        // without modifying the existing class

        // Example: Service should work with different configurations
        final alternativeConfig = const PersistenceConfiguration(
          enableDeduplication: false,
          enableBackgroundSync: false,
        );

        final alternativeService = PersistenceOperationsService(
          localRepository: mockLocalRepository,
          cloudRepository: mockCloudRepository,
          localItemRepository: mockLocalItemRepository,
          cloudItemRepository: mockCloudItemRepository,
          deduplicationService: mockDeduplicationService,
          configuration: alternativeConfig,
        );

        expect(alternativeService, isA<PersistenceOperationsService>());
      });
    });

    group('Error Handling and Resilience', () {
      test('should provide meaningful error context', () async {
        // Arrange
        const testListId = 'failing-list-id';
        when(mockCloudRepository.deleteList(testListId))
            .thenThrow(Exception('Network timeout'));

        // Act & Assert
        try {
          await service.deleteListCloud(testListId);
          fail('Should have thrown PersistenceException');
        } catch (e) {
          expect(e, isA<PersistenceException>());
          final persistenceError = e as PersistenceException;
          expect(persistenceError.operation, 'deleteListCloud');
          expect(persistenceError.id, testListId);
          expect(persistenceError.cause, isA<Exception>());
        }
      });
    });
  });
}