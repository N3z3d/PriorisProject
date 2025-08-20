import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/data/repositories/hive_list_item_repository.dart';
import 'dart:io';

void main() {
  group('HiveListItemRepository Persistence Test', () {
    late HiveListItemRepository repository;
    late Directory tempDir;

    setUp(() async {
      // Create temp directory for test
      tempDir = Directory.systemTemp.createTempSync('hive_test_');
      
      // Initialize Hive with temp directory
      Hive.init(tempDir.path);
      
      // Register adapter
      if (!Hive.isAdapterRegistered(ListItemAdapter().typeId)) {
        Hive.registerAdapter(ListItemAdapter());
      }
      
      repository = HiveListItemRepository();
      await repository.initialize();
    });

    tearDown(() async {
      await repository.close();
      await Hive.deleteFromDisk();
      await tempDir.delete(recursive: true);
    });

    test('should persist data between repository instances', () async {
      // === PHASE 1: Create and save data ===
      const listId = 'test-list-123';
      final testItem = ListItem(
        id: 'item-1',
        title: 'Préparer présentation client',
        createdAt: DateTime.now(),
        listId: listId,
      );
      
      // Save item
      await repository.add(testItem);
      
      // Verify it's saved
      final savedItem = await repository.getById('item-1');
      expect(savedItem, isNotNull);
      expect(savedItem!.title, equals('Préparer présentation client'));
      
      // Close the repository
      await repository.close();
      
      // === PHASE 2: Create new repository instance ===
      final newRepository = HiveListItemRepository();
      await newRepository.initialize();
      
      // === PHASE 3: Verify data persistence ===
      final persistedItem = await newRepository.getById('item-1');
      expect(persistedItem, isNotNull, 
        reason: 'Item should persist between repository instances');
      expect(persistedItem!.title, equals('Préparer présentation client'));
      expect(persistedItem.listId, equals(listId));
      
      await newRepository.close();
    });

    test('should correctly handle repository initialization', () async {
      expect(repository.isEmpty, isTrue);
      
      final item = ListItem(
        id: 'test-item',
        title: 'Test persistence',
        createdAt: DateTime.now(),
        listId: 'list-1',
      );
      
      await repository.add(item);
      
      expect(repository.isNotEmpty, isTrue);
      expect(repository.count, equals(1));
    });
  });
}