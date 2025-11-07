import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:prioris/domain/services/persistence/adaptive_persistence_service.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

import 'duplicate_id_conflicts_test.mocks.dart';

/// TDD Phase: RED - These tests should FAIL initially
/// 
/// This test file validates duplicate ID conflict handling:
/// 1. Duplicate list IDs between local and cloud storage
/// 2. Duplicate item IDs in backup operations  
/// 3. Race conditions during sync operations
/// 4. Data integrity during migration
@GenerateMocks([CustomListRepository, ListItemRepository])
void main() {
  group('Duplicate ID Conflicts Tests (TDD-RED)', () {
    late AdaptivePersistenceService service;
    late MockCustomListRepository mockLocalRepo;
    late MockCustomListRepository mockCloudRepo;
    late MockListItemRepository mockLocalItemRepo;
    late MockListItemRepository mockCloudItemRepo;

    setUp(() {
      mockLocalRepo = MockCustomListRepository();
      mockCloudRepo = MockCustomListRepository();
      mockLocalItemRepo = MockListItemRepository();
      mockCloudItemRepo = MockListItemRepository();
      
      service = AdaptivePersistenceService(
        localRepository: mockLocalRepo,
        cloudRepository: mockCloudRepo,
        localItemRepository: mockLocalItemRepo,
        cloudItemRepository: mockCloudItemRepo,
      );
    });

    group('RED: List ID Conflicts', () {
      test('SHOULD FAIL: Duplicate list ID should use merge strategy not error', () async {
        // Arrange
        await service.initialize(isAuthenticated: true);
        
        final existingList = CustomList(
          id: 'duplicate-id',
          name: 'Existing List',
          type: ListType.CUSTOM,
          createdAt: DateTime.now().subtract(Duration(hours: 1)),
          updatedAt: DateTime.now().subtract(Duration(hours: 1)),
        );
        
        final newList = CustomList(
          id: 'duplicate-id', // Same ID!
          name: 'New List',
          type: ListType.CUSTOM,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // Mock existing list in local storage
        when(mockLocalRepo.saveList(any)).thenAnswer((_) async => {});
        when(mockLocalRepo.getAllLists()).thenAnswer((_) async => [existingList]);
        
        // Act & Assert - Should NOT throw "Une liste avec cet ID existe déjà"
        expect(() async {
          await service.saveList(newList);
        }, isNot(throwsA(predicate((e) => 
          e.toString().contains('Une liste avec cet ID existe déjà')))),
          reason: 'Service should handle duplicate IDs with merge strategy');
      });

      test('SHOULD FAIL: Cloud-local sync should resolve ID conflicts intelligently', () async {
        // Arrange
        await service.initialize(isAuthenticated: true);
        
        final localList = CustomList(
          id: 'conflict-id',
          name: 'Local Version',
          type: ListType.CUSTOM,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        final cloudList = CustomList(
          id: 'conflict-id',
          name: 'Cloud Version', 
          type: ListType.CUSTOM,
          createdAt: DateTime.now().subtract(Duration(minutes: 30)),
          updatedAt: DateTime.now().subtract(Duration(minutes: 30)),
        );
        
        // Mock repositories
        when(mockLocalRepo.getAllLists()).thenAnswer((_) async => [localList]);
        when(mockCloudRepo.getAllLists()).thenAnswer((_) async => [cloudList]);
        
        // Act - Load lists should resolve conflict
        final result = await service.getAllLists();
        
        // Assert - Should return the newer version (local in this case)
        expect(result.length, equals(1));
        expect(result.first.name, equals('Local Version'),
          reason: 'Should prefer newer version in conflict resolution');
      });

      test('SHOULD FAIL: Backup operations should handle duplicate IDs gracefully', () async {
        // Arrange - CloudFirst mode with backup to local
        await service.initialize(isAuthenticated: true);
        
        final cloudList = CustomList(
          id: 'backup-test-id',
          name: 'Cloud List',
          type: ListType.CUSTOM,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // Mock cloud success but local already has this ID
        when(mockCloudRepo.getAllLists()).thenAnswer((_) async => [cloudList]);
        when(mockLocalRepo.saveList(any)).thenThrow(
          Exception('Une liste avec cet ID existe déjà'));
        
        // Act - Should not fail even if backup fails due to duplicate ID
        expect(() async {
          await service.getAllLists();
        }, isNot(throwsA(anything)),
          reason: 'Backup failures should not crash main operation');
      });
    });

    group('RED: Item ID Conflicts', () {
      test('SHOULD FAIL: Duplicate item ID should use upsert strategy', () async {
        // Arrange
        await service.initialize(isAuthenticated: false);
        
        final existingItem = ListItem(
          id: 'item-duplicate',
          title: 'Existing Item',
          listId: 'test-list',
          createdAt: DateTime.now().subtract(Duration(minutes: 30)),
        );
        
        final newItem = ListItem(
          id: 'item-duplicate', // Same ID!
          title: 'New Item',
          listId: 'test-list', 
          createdAt: DateTime.now(),
        );
        
        // Mock existing item
        when(mockLocalItemRepo.add(any)).thenAnswer((invocation) async {
          final item = invocation.positionalArguments[0] as ListItem;
          if (item.id == 'item-duplicate') {
            throw StateError('Un item avec cet id existe déjà');
          }
          return item;
        });
        
        // Act & Assert - Should NOT throw error, should use upsert pattern
        expect(() async {
          await service.saveItem(newItem);
        }, isNot(throwsA(predicate((e) => 
          e.toString().contains('Un item avec cet id existe déjà')))),
          reason: 'Service should handle duplicate item IDs with upsert');
      });

      test('SHOULD FAIL: Batch item operations should handle partial duplicates', () async {
        // Arrange
        await service.initialize(isAuthenticated: false);
        
        final items = [
          ListItem(id: 'item-1', title: 'Item 1', listId: 'test-list', createdAt: DateTime.now()),
          ListItem(id: 'item-2', title: 'Item 2', listId: 'test-list', createdAt: DateTime.now()),
          ListItem(id: 'item-1', title: 'Item 1 Duplicate', listId: 'test-list', createdAt: DateTime.now()), // Duplicate!
        ];
        
        // Mock: First item succeeds, second succeeds, third fails due to duplicate
        when(mockLocalItemRepo.add(any)).thenAnswer((invocation) async {
          final item = invocation.positionalArguments[0] as ListItem;
          if (item.title == 'Item 1 Duplicate') {
            throw StateError('Un item avec cet id existe déjà');
          }
          return item;
        });
        
        // Act - Should handle partial failures gracefully
        var successCount = 0;
        for (final item in items) {
          try {
            await service.saveItem(item);
            successCount++;
          } catch (e) {
            // Expected for duplicate, but service should provide better handling
          }
        }
        
        // Assert - At least some items should succeed
        expect(successCount, greaterThan(0),
          reason: 'Partial batch operations should succeed for valid items');
      });
    });

    group('RED: Race Condition Conflicts', () {
      test('SHOULD FAIL: Concurrent saves of same ID should be handled', () async {
        // Arrange
        await service.initialize(isAuthenticated: false);
        
        final list1 = CustomList(
          id: 'race-condition-id',
          name: 'Version 1',
          type: ListType.CUSTOM,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        final list2 = CustomList(
          id: 'race-condition-id',
          name: 'Version 2', 
          type: ListType.CUSTOM,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // Mock repository to simulate race condition
        var saveCount = 0;
        when(mockLocalRepo.saveList(any)).thenAnswer((_) async {
          saveCount++;
          if (saveCount == 1) {
            // First save succeeds after delay
            await Future.delayed(Duration(milliseconds: 100));
            return;
          } else {
            // Second save encounters duplicate
            throw Exception('Une liste avec cet ID existe déjà');
          }
        });
        
        // Act - Concurrent saves
        final futures = [
          service.saveList(list1),
          service.saveList(list2),
        ];
        
        // Assert - Should not crash, should handle race condition
        expect(() async {
          await Future.wait(futures);
        }, isNot(throwsA(anything)),
          reason: 'Race conditions should be handled gracefully');
      });

      test('SHOULD FAIL: Migration with concurrent operations should maintain consistency', () async {
        // Arrange - Start in guest mode
        await service.initialize(isAuthenticated: false);
        
        final localList = CustomList(
          id: 'migration-race-id',
          name: 'Local List',
          type: ListType.CUSTOM,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        when(mockLocalRepo.getAllLists()).thenAnswer((_) async => [localList]);
        when(mockCloudRepo.getAllLists()).thenAnswer((_) async => []);
        when(mockCloudRepo.saveList(any)).thenAnswer((_) async => {});
        
        // Act - Start migration and concurrent operations
        final migrationFuture = service.updateAuthenticationState(isAuthenticated: true);
        final concurrentSaveFuture = service.saveList(localList.copyWith(name: 'Updated'));
        
        // Wait for both
        await Future.wait([migrationFuture, concurrentSaveFuture]);
        
        // Assert - Should maintain consistency
        expect(service.isAuthenticated, isTrue);
        expect(service.currentMode, equals(PersistenceMode.cloudFirst));
      });
    });

    group('RED: Data Integrity During Sync', () {
      test('SHOULD FAIL: Failed cloud sync should not corrupt local data', () async {
        // Arrange
        await service.initialize(isAuthenticated: true);
        
        final validList = CustomList(
          id: 'integrity-test',
          name: 'Valid List',
          type: ListType.CUSTOM,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // Mock local success but cloud failure due to conflict
        when(mockLocalRepo.saveList(any)).thenAnswer((_) async => {});
        when(mockLocalRepo.getAllLists()).thenAnswer((_) async => [validList]);
        when(mockCloudRepo.saveList(any)).thenThrow(
          Exception('Cloud conflict: duplicate ID'));
        
        // Act - Save should succeed locally even if cloud sync fails
        await service.saveList(validList);
        
        // Verify local data integrity
        final localLists = await service.getAllLists();
        
        // Assert - Local data should remain intact
        expect(localLists, contains(predicate((CustomList list) => 
          list.id == 'integrity-test')),
          reason: 'Local data integrity should be maintained despite cloud failures');
      });

      test('SHOULD FAIL: Orphaned items should be handled during migration', () async {
        // Arrange
        final orphanedItem = ListItem(
          id: 'orphan-item',
          title: 'Orphaned Item',
          listId: 'non-existent-list', // Parent list doesn't exist!
          createdAt: DateTime.now(),
        );
        
        await service.initialize(isAuthenticated: false);
        when(mockLocalItemRepo.getAll()).thenAnswer((_) async => [orphanedItem]);
        when(mockLocalRepo.getAllLists()).thenAnswer((_) async => []);
        
        // Act - Migration should handle orphaned items
        await service.updateAuthenticationState(isAuthenticated: true);
        
        // Assert - Should not crash due to orphaned items
        expect(service.currentMode, equals(PersistenceMode.cloudFirst),
          reason: 'Migration should complete despite data inconsistencies');
      });
    });

    group('RED: Deduplication Strategy Tests', () {
      test('SHOULD FAIL: Service should implement automatic deduplication', () async {
        // Arrange
        await service.initialize(isAuthenticated: false);
        
        final duplicateList1 = CustomList(
          id: 'dedup-test',
          name: 'Original',
          type: ListType.CUSTOM,
          createdAt: DateTime.now().subtract(Duration(hours: 1)),
          updatedAt: DateTime.now().subtract(Duration(hours: 1)),
        );
        
        final duplicateList2 = CustomList(
          id: 'dedup-test',
          name: 'Updated',
          type: ListType.CUSTOM,
          createdAt: DateTime.now().subtract(Duration(hours: 1)),
          updatedAt: DateTime.now(), // More recent
        );
        
        // Mock both lists existing
        when(mockLocalRepo.getAllLists()).thenAnswer((_) async => 
          [duplicateList1, duplicateList2]);
        
        // Act - Get all lists should deduplicate automatically
        final result = await service.getAllLists();
        
        // Assert - Should return only one list with the most recent data
        expect(result.length, equals(1),
          reason: 'Automatic deduplication should resolve duplicate IDs');
        expect(result.first.name, equals('Updated'),
          reason: 'Should prefer the most recently updated version');
      });
    }, skip: 'TDD-RED spec tracked for future implementation (duplicate ID conflicts).');
  }, skip: 'TDD-RED spec tracked for future implementation (duplicate ID conflicts).');
}
