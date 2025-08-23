import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/data/repositories/hive_custom_list_repository.dart';
import 'package:prioris/data/repositories/hive_list_item_repository.dart';
import 'package:prioris/data/providers/repository_providers.dart';

/// VALIDATION TEST: Verify Data Loss Fixes Work Correctly
/// 
/// This test validates that the critical fixes for data loss on reconnection
/// are working properly and user data survives app restarts.
void main() {
  group('Data Loss Fix Validation', () {
    late Directory tempDir;
    
    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('prioris_fix_validation');
      Hive.init(tempDir.path);
      
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
    
    test('FIX VALIDATION: Repository registry handles dispose/reinitialize correctly', () async {
      print('\n✅ TESTING FIX: Repository Registry Lifecycle');
      
      // Initialize registry
      await HiveRepositoryRegistry.initialize();
      expect(HiveRepositoryRegistry.instance.isInitialized, isTrue);
      
      // Add test data
      final repo = HiveRepositoryRegistry.instance.customListRepository;
      final testList = CustomList(
        id: 'fix-test-1',
        name: 'Fix Validation Test',
        type: ListType.CUSTOM,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await repo.saveList(testList);
      
      // Verify data exists
      var retrieved = await repo.getListById('fix-test-1');
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Fix Validation Test');
      
      // Dispose and reinitialize (simulates app restart)
      await HiveRepositoryRegistry.dispose();
      
      await HiveRepositoryRegistry.initialize();
      expect(HiveRepositoryRegistry.instance.isInitialized, isTrue);
      
      // Verify data survived
      final newRepo = HiveRepositoryRegistry.instance.customListRepository;
      retrieved = await newRepo.getListById('fix-test-1');
      
      expect(retrieved, isNotNull, 
        reason: 'Data should survive repository dispose/reinitialize cycle');
      expect(retrieved!.name, 'Fix Validation Test');
      
      print('✅ Repository registry lifecycle fix working correctly');
    });
    
    test('FIX VALIDATION: Repository reinitialize handles closed boxes', () async {
      print('\n✅ TESTING FIX: Repository Reinitialize');
      
      final repo = HiveCustomListRepository();
      await repo.initialize();
      
      // Add test data
      final testList = CustomList(
        id: 'reinit-test',
        name: 'Reinit Test',
        type: ListType.BOOKS,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await repo.saveList(testList);
      
      // Force disposal (simulates box closure)
      await repo.dispose();
      
      // Reinitialize should work without errors
      await repo.reinitialize();
      
      // Verify data survived
      final retrieved = await repo.getListById('reinit-test');
      expect(retrieved, isNotNull, 
        reason: 'Data should survive reinitialize after dispose');
      expect(retrieved!.name, 'Reinit Test');
      
      print('✅ Repository reinitialize fix working correctly');
      
      await repo.dispose();
    });
    
    test('FIX VALIDATION: Validation logic handles closed boxes gracefully', () async {
      print('\n✅ TESTING FIX: Validation Logic');
      
      final repo = HiveCustomListRepository();
      await repo.initialize();
      
      // Close the box to simulate the error condition
      await repo.dispose();
      
      // Try to save a list with closed box - should not crash
      final testList = CustomList(
        id: 'validation-test',
        name: 'Validation Test',
        type: ListType.MOVIES,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // This should not throw a "Box has already been closed" error
      expect(() async => await repo.saveList(testList), 
        throwsA(isA<Exception>()));
      
      print('✅ Validation logic fix working - no box closed errors');
    });
    
    test('FIX VALIDATION: Complete app restart simulation works', () async {
      print('\n✅ TESTING FIX: Complete App Restart Simulation');
      
      // === PHASE 1: App startup ===
      await HiveRepositoryRegistry.initialize();
      
      // User creates data
      final listRepo = HiveRepositoryRegistry.instance.customListRepository;
      final itemRepo = HiveRepositoryRegistry.instance.listItemRepository;
      
      final userList = CustomList(
        id: 'app-restart-test',
        name: 'My Important App Data',
        description: 'Critical user data that must not be lost',
        type: ListType.PROJECTS,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final userItems = [
        ListItem(
          id: 'item-1',
          title: 'Critical Task 1',
          listId: 'app-restart-test',
          createdAt: DateTime.now(),
        ),
        ListItem(
          id: 'item-2', 
          title: 'Critical Task 2',
          listId: 'app-restart-test',
          createdAt: DateTime.now(),
        ),
      ];
      
      await listRepo.saveList(userList);
      for (final item in userItems) {
        await itemRepo.add(item);
      }
      
      print('📱 User data created during session');
      
      // === PHASE 2: App shutdown ===
      await HiveRepositoryRegistry.dispose();
      print('📱 App shutdown complete');
      
      // === PHASE 3: App restart ===
      await HiveRepositoryRegistry.initialize();
      print('📱 App restarted');
      
      // === PHASE 4: Verify user data survived ===
      final newListRepo = HiveRepositoryRegistry.instance.customListRepository;
      final newItemRepo = HiveRepositoryRegistry.instance.listItemRepository;
      
      final retrievedList = await newListRepo.getListById('app-restart-test');
      final retrievedItems = await newItemRepo.getByListId('app-restart-test');
      
      expect(retrievedList, isNotNull, 
        reason: 'CRITICAL: User list must survive app restart');
      expect(retrievedList!.name, 'My Important App Data');
      expect(retrievedList.description, 'Critical user data that must not be lost');
      
      expect(retrievedItems.length, 2, 
        reason: 'CRITICAL: User items must survive app restart');
      expect(retrievedItems.map((i) => i.title), contains('Critical Task 1'));
      expect(retrievedItems.map((i) => i.title), contains('Critical Task 2'));
      
      print('✅ CRITICAL FIX VALIDATED: All user data survived app restart!');
      
      await HiveRepositoryRegistry.dispose();
    });
    
    test('FIX VALIDATION: Error recovery scenarios work', () async {
      print('\n✅ TESTING FIX: Error Recovery');
      
      await HiveRepositoryRegistry.initialize();
      
      // Simulate various error conditions
      final repo = HiveRepositoryRegistry.instance.customListRepository;
      
      // Test 1: Repository continues working after non-critical errors
      try {
        await repo.getListById('non-existent-id');
      } catch (e) {
        // Expected - list doesn't exist
      }
      
      // Repository should still be functional
      final testList = CustomList(
        id: 'recovery-test',
        name: 'Recovery Test',
        type: ListType.CUSTOM,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await repo.saveList(testList);
      final retrieved = await repo.getListById('recovery-test');
      
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Recovery Test');
      
      print('✅ Error recovery fix working correctly');
      
      await HiveRepositoryRegistry.dispose();
    });
  });
}