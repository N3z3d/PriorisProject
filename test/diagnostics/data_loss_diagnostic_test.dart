import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:hive_flutter/hive_flutter.dart';

import 'package:prioris/domain/models/core/entities/custom_list.dart';

import 'package:prioris/domain/models/core/entities/list_item.dart';

import 'package:prioris/domain/models/core/enums/list_enums.dart';

import 'package:prioris/data/repositories/hive_custom_list_repository.dart';

import 'package:prioris/data/repositories/hive_list_item_repository.dart';

import 'package:prioris/data/providers/repository_providers.dart';

import 'package:prioris/data/repositories/base/hive_repository_registry.dart';



/// DIAGNOSTIC TEST: Investigate Complete Data Loss on Reconnection

/// 

/// This test suite investigates the critical bug where users lose ALL their data

/// when they restart the application or reconnect. This tests specifically:

/// 

/// 1. Hive box lifecycle and persistence behavior

/// 2. Repository initialization and data retrieval

/// 3. Platform-specific storage issues (Web vs Native)

/// 4. Data corruption or path issues

void main() {

  group('Data Loss Diagnostic Tests', () {

    late Directory tempDir;

    late String hivePath;

    

    setUpAll(() async {

      // Create a temporary directory that mimics real app storage

      tempDir = await Directory.systemTemp.createTemp('prioris_diagnostic');

      hivePath = tempDir.path;

      

      print('ð DIAGNOSTIC: Using Hive path: $hivePath');

      

      // Initialize Hive with temporary directory

      Hive.init(hivePath);

      

      // Register adapters if not already registered

      if (!Hive.isAdapterRegistered(CustomListAdapter().typeId)) {

        Hive.registerAdapter(CustomListAdapter());

      }

      if (!Hive.isAdapterRegistered(ListItemAdapter().typeId)) {

        Hive.registerAdapter(ListItemAdapter());

      }

      if (!Hive.isAdapterRegistered(ListTypeAdapter().typeId)) {

        Hive.registerAdapter(ListTypeAdapter());

      }

    });

    

    tearDownAll(() async {

      await Hive.close();

      if (tempDir.existsSync()) {

        tempDir.deleteSync(recursive: true);

      }

    });

    

    group('CRITICAL: Box Persistence Validation', () {

      test('ISSUE 1: Verify box files are actually created on disk', () async {

        print('\nð DIAGNOSTIC TEST 1: Box File Creation');

        

        // Create repository and save data

        final listRepo = HiveCustomListRepository();

        await listRepo.initialize();

        

        final testList = CustomList(

          id: 'diagnostic-1',

          name: 'Diagnostic Test List',

          type: ListType.CUSTOM,

          createdAt: DateTime.now(),

          updatedAt: DateTime.now(),

        );

        

        await listRepo.saveList(testList);

        

        // Check if box files actually exist on disk

        final boxFiles = Directory(hivePath).listSync()

            .where((file) => file.path.contains('custom_lists'))

            .toList();

        

        print('ð Box files found: ${boxFiles.map((f) => f.path)}');

        

        expect(boxFiles, isNotEmpty, 

          reason: 'CRITICAL: No Hive box files found on disk! Data is not being persisted.');

        

        // Verify file size > 0 (contains data)

        if (boxFiles.isNotEmpty) {

          final boxFile = boxFiles.first as File;

          final fileSize = await boxFile.length();

          print('ð Box file size: $fileSize bytes');

          

          expect(fileSize, greaterThan(0), 

            reason: 'CRITICAL: Box file exists but is empty! Data is not being written.');

        }

        

        await listRepo.dispose();

      });

      

      test('ISSUE 2: Verify data survives box close/reopen cycle', () async {

        print('\nð DIAGNOSTIC TEST 2: Box Close/Reopen Cycle');

        

        // === PHASE 1: Write data ===

        final listRepo1 = HiveCustomListRepository();

        await listRepo1.initialize();

        

        final testList = CustomList(

          id: 'persistence-test',

          name: 'Persistence Test List',

          description: 'This data must survive box closure',

          type: ListType.MOVIES,

          createdAt: DateTime.now(),

          updatedAt: DateTime.now(),

        );

        

        await listRepo1.saveList(testList);

        

        // Verify data is written

        final retrievedBefore = await listRepo1.getListById('persistence-test');

        expect(retrievedBefore, isNotNull);

        print('â Data written successfully');

        

        // Get box statistics before closing

        final statsBefore = await listRepo1.getStats();

        print('ð Stats before close: $statsBefore');

        

        // Close the repository (simulates app shutdown)

        await listRepo1.dispose();

        print('ð Repository disposed');

        

        // === PHASE 2: Verify data persists after reopen ===

        

        // Create new repository instance (simulates app restart)

        final listRepo2 = HiveCustomListRepository();

        await listRepo2.initialize();

        print('ð New repository initialized');

        

        // Get box statistics after reopening

        final statsAfter = await listRepo2.getStats();

        print('ð Stats after reopen: $statsAfter');

        

        // Try to retrieve the data

        final retrievedAfter = await listRepo2.getListById('persistence-test');

        

        if (retrievedAfter == null) {

          print('â CRITICAL BUG IDENTIFIED: Data lost after box close/reopen!');

          

          // Additional diagnostics

          final allLists = await listRepo2.getAllLists();

          print('ð All lists after reopen: ${allLists.length}');

          

          // Check if box is empty

          final finalStats = await listRepo2.getStats();

          print('ð Final stats: $finalStats');

          

          fail('CRITICAL BUG: Data was lost during box close/reopen cycle. This is the root cause of user data loss!');

        } else {

          print('â Data successfully retrieved after reopen');

          expect(retrievedAfter.name, 'Persistence Test List');

          expect(retrievedAfter.description, 'This data must survive box closure');

        }

        

        await listRepo2.dispose();

      });

      

      test('ISSUE 3: Verify HiveRepositoryRegistry initialization', () async {

        print('\nð DIAGNOSTIC TEST 3: Repository Registry');

        

        // Test the registry initialization that happens at app startup

        await HiveRepositoryRegistry.initialize();

        

        expect(HiveRepositoryRegistry.instance.isInitialized, isTrue,

          reason: 'Repository registry should be initialized');

        

        // Test that repositories are accessible

        final customListRepo = HiveRepositoryRegistry.instance.customListRepository;

        final listItemRepo = HiveRepositoryRegistry.instance.listItemRepository;

        

        expect(customListRepo, isNotNull);

        expect(listItemRepo, isNotNull);

        

        // Test data persistence through registry

        final testList = CustomList(

          id: 'registry-test',

          name: 'Registry Test',

          type: ListType.CUSTOM,

          createdAt: DateTime.now(),

          updatedAt: DateTime.now(),

        );

        

        await customListRepo.saveList(testList);

        final retrieved = await customListRepo.getListById('registry-test');

        

        expect(retrieved, isNotNull);

        expect(retrieved!.name, 'Registry Test');

        

        print('â Repository registry working correctly');

      });

    });

    

    group('CRITICAL: Data Corruption Detection', () {

      test('ISSUE 4: Check for data corruption during write/read', () async {

        print('\nð DIAGNOSTIC TEST 4: Data Corruption Detection');

        

        final listRepo = HiveCustomListRepository();

        await listRepo.initialize();

        

        // Create test data with various data types

        final complexList = CustomList(

          id: 'corruption-test',

          name: 'Complex Data Test ð§ª',

          description: 'Special chars: Ã©Ã Ã¹ Ã±Ã§ ä¸­æ ð "quotes" \'apostrophes\' &amp; <tags>',

          type: ListType.BOOKS,

          createdAt: DateTime.parse('2024-01-15T10:30:00.000Z'),

          updatedAt: DateTime.parse('2024-01-15T15:45:30.123Z'),

        );

        

        await listRepo.saveList(complexList);

        

        // Retrieve and verify data integrity

        final retrieved = await listRepo.getListById('corruption-test');

        

        expect(retrieved, isNotNull);

        expect(retrieved!.name, complexList.name);

        expect(retrieved.description, complexList.description);

        expect(retrieved.type, complexList.type);

        expect(retrieved.createdAt.toIso8601String(), complexList.createdAt.toIso8601String());

        expect(retrieved.updatedAt.toIso8601String(), complexList.updatedAt.toIso8601String());

        

        print('â No data corruption detected');

        

        await listRepo.dispose();

      });

      

      test('ISSUE 5: Check for concurrent access issues', () async {

        print('\nð DIAGNOSTIC TEST 5: Concurrent Access');

        

        final listRepo = HiveCustomListRepository();

        await listRepo.initialize();

        

        // Simulate concurrent writes (potential race condition)

        final futures = <Future>[];

        

        for (int i = 0; i < 10; i++) {

          futures.add(listRepo.saveList(CustomList(

            id: 'concurrent-$i',

            name: 'Concurrent Test $i',

            type: ListType.CUSTOM,

            createdAt: DateTime.now(),

            updatedAt: DateTime.now(),

          )));

        }

        

        await Future.wait(futures);

        

        // Verify all data was written correctly

        final allLists = await listRepo.getAllLists();

        final concurrentLists = allLists.where((l) => l.id.startsWith('concurrent-')).toList();

        

        expect(concurrentLists.length, 10, 

          reason: 'Concurrent writes may be causing data loss');

        

        // Verify each list individually

        for (int i = 0; i < 10; i++) {

          final retrieved = await listRepo.getListById('concurrent-$i');

          expect(retrieved, isNotNull, 

            reason: 'Concurrent write $i was lost');

          expect(retrieved!.name, 'Concurrent Test $i');

        }

        

        print('â Concurrent access working correctly');

        

        await listRepo.dispose();

      });

    });

    

    group('CRITICAL: Platform-Specific Issues', () {

      test('ISSUE 6: Check storage path and permissions', () async {

        print('\nð DIAGNOSTIC TEST 6: Storage Path and Permissions');

        

        // Check if we can create and modify files in the storage directory

        final testFile = File('${tempDir.path}/permission_test.txt');

        

        try {

          await testFile.writeAsString('Permission test');

          final content = await testFile.readAsString();

          expect(content, 'Permission test');

          await testFile.delete();

          print('â File system permissions OK');

        } catch (e) {

          fail('CRITICAL: File system permission issue: $e');

        }

        

        // Test Hive-specific operations

        final listRepo = HiveCustomListRepository();

        await listRepo.initialize();

        

        // Test compaction (can detect some storage issues)

        try {

          await listRepo.compact();

          print('â Hive box compaction successful');

        } catch (e) {

          print('â ï¸ Box compaction failed: $e');

        }

        

        await listRepo.dispose();

      });

    });

    

    group('CRITICAL: App Lifecycle Simulation', () {

      test('ISSUE 7: Simulate complete app restart cycle', () async {

        print('\nð DIAGNOSTIC TEST 7: Complete App Restart Simulation');

        

        // === PHASE 1: App startup and data creation ===

        print('ð± Simulating app startup...');

        

        await HiveRepositoryRegistry.initialize();

        

        final listRepo1 = HiveRepositoryRegistry.instance.customListRepository;

        final itemRepo1 = HiveRepositoryRegistry.instance.listItemRepository;

        

        // Create user data

        final userList = CustomList(

          id: 'user-list-1',

          name: 'My Important List',

          description: 'This is my important data that must not be lost',

          type: ListType.PROJECTS,

          createdAt: DateTime.now(),

          updatedAt: DateTime.now(),

        );

        

        final userItems = [

          ListItem(

            id: 'item-1',

            title: 'Important task 1',

            listId: 'user-list-1',

            createdAt: DateTime.now(),

          ),

          ListItem(

            id: 'item-2',

            title: 'Important task 2',

            listId: 'user-list-1',

            createdAt: DateTime.now(),

          ),

        ];

        

        await listRepo1.saveList(userList);

        for (final item in userItems) {

          await itemRepo1.add(item);

        }

        

        print('â User data created');

        

        // === PHASE 2: App shutdown ===

        print('ð± Simulating app shutdown...');

        

        await HiveRepositoryRegistry.dispose();

        

        // === PHASE 3: App restart ===

        print('ð± Simulating app restart...');

        

        await HiveRepositoryRegistry.initialize();

        

        final listRepo2 = HiveRepositoryRegistry.instance.customListRepository;

        final itemRepo2 = HiveRepositoryRegistry.instance.listItemRepository;

        

        // === PHASE 4: Verify data survival ===

        print('ð Checking if user data survived...');

        

        final retrievedList = await listRepo2.getListById('user-list-1');

        final retrievedItems = await itemRepo2.getByListId('user-list-1');

        

        if (retrievedList == null) {

          print('â CRITICAL BUG CONFIRMED: User list was lost during app restart!');

          

          // Detailed diagnostics

          final allLists = await listRepo2.getAllLists();

          final allItems = await itemRepo2.getAll();

          

          print('ð Lists after restart: ${allLists.length}');

          print('ð Items after restart: ${allItems.length}');

          

          final listStats = await listRepo2.getStats();

          print('ð List box stats: $listStats');

          

          fail('CRITICAL BUG CONFIRMED: Complete data loss on app restart - this is the reported bug!');

        } else {

          print('â User list survived restart');

          expect(retrievedList.name, 'My Important List');

          expect(retrievedItems.length, 2);

          print('â All user data intact after restart');

        }

        

        await HiveRepositoryRegistry.dispose();

      });

    });

  });

}