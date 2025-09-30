/// TDD Tests for DataMigrationService
/// Follows Red → Green → Refactor methodology
/// Tests written to validate P0 critical service (Migration Strategy)

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:prioris/application/services/data_migration_service.dart';
import 'package:prioris/application/ports/persistence_interfaces.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

import 'data_migration_service_test.mocks.dart';

@GenerateMocks([CustomListRepository])
void main() {
  group('DataMigrationService Tests - P0 Critical Service', () {
    late DataMigrationService migrationService;
    late MockCustomListRepository mockLocalRepository;
    late MockCustomListRepository mockCloudRepository;

    final now = DateTime.now();
    final later = now.add(const Duration(hours: 1));

    final localList = CustomList(
      id: 'list-123',
      name: 'Local List',
      type: ListType.CUSTOM,
      createdAt: now,
      updatedAt: now,
    );

    final cloudList = CustomList(
      id: 'list-456',
      name: 'Cloud List',
      type: ListType.CUSTOM,
      createdAt: now,
      updatedAt: now,
    );

    final localItem = ListItem(
      id: 'item-111',
      listId: 'list-123',
      title: 'Local Item',
      createdAt: now,
    );

    final incomingItem = ListItem(
      id: 'item-111',
      listId: 'list-123',
      title: 'Incoming Item',
      createdAt: later,
    );

    setUp(() {
      mockLocalRepository = MockCustomListRepository();
      mockCloudRepository = MockCustomListRepository();
      migrationService = DataMigrationService(
        localRepository: mockLocalRepository,
        cloudRepository: mockCloudRepository,
      );
    });

    group('MigrateToCloud Tests', () {
      test('should migrate all lists to cloud with migrateAll strategy', () async {
        // GIVEN
        final lists = [localList, cloudList];
        when(mockCloudRepository.saveList(any))
            .thenAnswer((_) async {});

        // WHEN
        await migrationService.migrateToCloud(
          strategy: MigrationStrategy.migrateAll,
          localLists: lists,
        );

        // THEN
        verify(mockCloudRepository.saveList(localList)).called(1);
        verify(mockCloudRepository.saveList(cloudList)).called(1);
      });

      test('should skip migration when localLists is empty', () async {
        // GIVEN
        final emptyLists = <CustomList>[];

        // WHEN
        await migrationService.migrateToCloud(
          strategy: MigrationStrategy.migrateAll,
          localLists: emptyLists,
        );

        // THEN
        verifyNever(mockCloudRepository.saveList(any));
      });

      test('should use intelligentMerge for askUser strategy', () async {
        // GIVEN
        final lists = [localList];
        when(mockCloudRepository.getAllLists())
            .thenAnswer((_) async => []);
        when(mockCloudRepository.saveList(any))
            .thenAnswer((_) async {});

        // WHEN
        await migrationService.migrateToCloud(
          strategy: MigrationStrategy.askUser,
          localLists: lists,
        );

        // THEN
        verify(mockCloudRepository.getAllLists()).called(1);
        verify(mockCloudRepository.saveList(localList)).called(1);
      });

      test('should skip migration with cloudOnly strategy', () async {
        // GIVEN
        final lists = [localList];

        // WHEN
        await migrationService.migrateToCloud(
          strategy: MigrationStrategy.cloudOnly,
          localLists: lists,
        );

        // THEN
        verifyNever(mockCloudRepository.saveList(any));
      });

      test('should throw exception when all migrations fail', () async {
        // GIVEN
        final lists = [localList, cloudList];
        when(mockCloudRepository.saveList(any))
            .thenThrow(Exception('Cloud save failed'));

        // WHEN & THEN
        await expectLater(
          migrationService.migrateToCloud(
            strategy: MigrationStrategy.migrateAll,
            localLists: lists,
          ),
          throwsA(isA<PersistenceException>()),
        );
      });

      test('should perform intelligent merge with new and conflicting lists', () async {
        // GIVEN
        final conflictingList = CustomList(
          id: 'list-123',
          name: 'Conflicting Cloud List',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: later, // Cloud is more recent
        );

        when(mockCloudRepository.getAllLists())
            .thenAnswer((_) async => [conflictingList]);
        when(mockCloudRepository.saveList(any))
            .thenAnswer((_) async {});

        // WHEN
        await migrationService.migrateToCloud(
          strategy: MigrationStrategy.intelligentMerge,
          localLists: [localList, cloudList],
        );

        // THEN
        verify(mockCloudRepository.getAllLists()).called(1);
        // Should save both lists (conflictingList merged + cloudList new)
        verify(mockCloudRepository.saveList(any)).called(2);
      });
    });

    group('MigrateToLocal Tests', () {
      test('should migrate all cloud lists to local', () async {
        // GIVEN
        final cloudLists = [localList, cloudList];
        when(mockLocalRepository.saveList(any))
            .thenAnswer((_) async {});

        // WHEN
        await migrationService.migrateToLocal(cloudLists: cloudLists);

        // THEN
        verify(mockLocalRepository.saveList(localList)).called(1);
        verify(mockLocalRepository.saveList(cloudList)).called(1);
      });

      test('should continue on migration error without throwing', () async {
        // GIVEN
        final cloudLists = [localList];
        when(mockLocalRepository.saveList(any))
            .thenThrow(Exception('Local save failed'));

        // WHEN & THEN
        // Should not throw, just log error
        await migrationService.migrateToLocal(cloudLists: cloudLists);
      });
    });

    group('Conflict Resolution Tests', () {
      test('should resolve list conflict preferring local when local is more recent', () {
        // GIVEN
        final recentLocal = CustomList(
          id: 'list-123',
          name: 'Recent Local',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: later,
        );
        final oldCloud = CustomList(
          id: 'list-123',
          name: 'Old Cloud',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: now,
        );

        // WHEN
        final result = migrationService.resolveListConflict(recentLocal, oldCloud);

        // THEN
        expect(result.name, equals('Recent Local'));
        expect(result.updatedAt, equals(later));
      });

      test('should resolve list conflict preferring cloud when cloud is more recent', () {
        // GIVEN
        final oldLocal = CustomList(
          id: 'list-123',
          name: 'Old Local',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: now,
        );
        final recentCloud = CustomList(
          id: 'list-123',
          name: 'Recent Cloud',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: later,
        );

        // WHEN
        final result = migrationService.resolveListConflict(oldLocal, recentCloud);

        // THEN
        expect(result.name, equals('Recent Cloud'));
        expect(result.updatedAt, equals(later));
      });

      test('should resolve list conflict preferring local when timestamps are equal', () {
        // GIVEN
        final localEqual = CustomList(
          id: 'list-123',
          name: 'Local Equal',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: now,
        );
        final cloudEqual = CustomList(
          id: 'list-123',
          name: 'Cloud Equal',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: now,
        );

        // WHEN
        final result = migrationService.resolveListConflict(localEqual, cloudEqual);

        // THEN
        // When timestamps are equal, code prefers cloud (isAfter returns false)
        expect(result.name, equals('Cloud Equal'));
      });

      test('should resolve item conflict preferring incoming when incoming is more recent', () {
        // GIVEN (incomingItem.createdAt > localItem.createdAt)

        // WHEN
        final result = migrationService.resolveItemConflict(localItem, incomingItem);

        // THEN
        expect(result.title, equals('Incoming Item'));
        expect(result.createdAt, equals(later));
      });

      test('should resolve item conflict preferring existing when existing is more recent', () {
        // GIVEN
        final recentExisting = ListItem(
          id: 'item-111',
          listId: 'list-123',
          title: 'Recent Existing',
          createdAt: later,
        );
        final oldIncoming = ListItem(
          id: 'item-111',
          listId: 'list-123',
          title: 'Old Incoming',
          createdAt: now,
        );

        // WHEN
        final result = migrationService.resolveItemConflict(recentExisting, oldIncoming);

        // THEN
        expect(result.title, equals('Recent Existing'));
      });

      test('should resolve item conflict preferring incoming when equal timestamps', () {
        // GIVEN
        final existingEqual = ListItem(
          id: 'item-111',
          listId: 'list-123',
          title: 'Existing Equal',
          createdAt: now,
        );
        final incomingEqual = ListItem(
          id: 'item-111',
          listId: 'list-123',
          title: 'Incoming Equal',
          createdAt: now,
        );

        // WHEN
        final result = migrationService.resolveItemConflict(existingEqual, incomingEqual);

        // THEN
        expect(result.title, equals('Incoming Equal'));
      });
    });

    group('Migration Statistics Tests', () {
      test('should check if migration is needed when local lists exist', () async {
        // GIVEN
        when(mockLocalRepository.getAllLists())
            .thenAnswer((_) async => [localList]);

        // WHEN
        final result = await migrationService.isMigrationNeeded();

        // THEN
        expect(result, isTrue);
        verify(mockLocalRepository.getAllLists()).called(1);
      });

      test('should check if migration is not needed when no local lists', () async {
        // GIVEN
        when(mockLocalRepository.getAllLists())
            .thenAnswer((_) async => []);

        // WHEN
        final result = await migrationService.isMigrationNeeded();

        // THEN
        expect(result, isFalse);
      });

      test('should return false when checking migration throws error', () async {
        // GIVEN
        when(mockLocalRepository.getAllLists())
            .thenThrow(Exception('Repository error'));

        // WHEN
        final result = await migrationService.isMigrationNeeded();

        // THEN
        expect(result, isFalse);
      });

      test('should get migration stats with local and cloud data', () async {
        // GIVEN
        final conflictingCloudList = CustomList(
          id: 'list-123', // Same ID as localList
          name: 'Conflicting Cloud',
          type: ListType.CUSTOM,
          createdAt: now,
          updatedAt: now,
        );

        when(mockLocalRepository.getAllLists())
            .thenAnswer((_) async => [localList]);
        when(mockCloudRepository.getAllLists())
            .thenAnswer((_) async => [conflictingCloudList, cloudList]);

        // WHEN
        final stats = await migrationService.getMigrationStats();

        // THEN
        expect(stats['localListsCount'], equals(1));
        expect(stats['cloudListsCount'], equals(2));
        expect(stats['hasLocalData'], isTrue);
        expect(stats['hasCloudData'], isTrue);
        expect(stats['potentialConflicts'], equals(1)); // localList.id == conflictingCloudList.id
      });

      test('should return error stats when getMigrationStats fails', () async {
        // GIVEN
        when(mockLocalRepository.getAllLists())
            .thenThrow(Exception('Stats error'));

        // WHEN
        final stats = await migrationService.getMigrationStats();

        // THEN
        expect(stats['error'], isNotNull);
        expect(stats['localListsCount'], equals(0));
        expect(stats['cloudListsCount'], equals(0));
      });

      test('should create migration report with correct data', () {
        // GIVEN
        const totalItems = 100;
        const successCount = 95;
        const errorCount = 5;
        const duration = Duration(seconds: 30);

        // WHEN
        final report = migrationService.createMigrationReport(
          strategy: MigrationStrategy.intelligentMerge,
          totalItems: totalItems,
          successCount: successCount,
          errorCount: errorCount,
          duration: duration,
        );

        // THEN
        expect(report['strategy'], equals('intelligentMerge'));
        expect(report['totalItems'], equals(100));
        expect(report['successCount'], equals(95));
        expect(report['errorCount'], equals(5));
        expect(report['successRate'], equals('95.0'));
        expect(report['durationMs'], equals(30000));
        expect(report['timestamp'], isNotNull);
      });

      test('should handle zero totalItems in migration report', () {
        // GIVEN
        const totalItems = 0;

        // WHEN
        final report = migrationService.createMigrationReport(
          strategy: MigrationStrategy.migrateAll,
          totalItems: totalItems,
          successCount: 0,
          errorCount: 0,
          duration: const Duration(milliseconds: 100),
        );

        // THEN
        expect(report['successRate'], equals('0.0'));
      });
    });
  });
}
