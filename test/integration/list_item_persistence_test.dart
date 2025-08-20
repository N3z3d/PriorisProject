import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/data/providers/repository_providers.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';

void main() {
  group('List Item Persistence Integration Test', () {
    late ProviderContainer container;

    setUp(() async {
      // Initialize Hive for testing
      await Hive.initFlutter();
      Hive.registerAdapter(ListItemAdapter());
      
      // Clear existing test boxes
      if (Hive.isBoxOpen('test_list_items')) {
        await Hive.box('test_list_items').clear();
      }
      
      container = ProviderContainer();
    });

    tearDown(() async {
      container.dispose();
      await Hive.close();
    });

    testWidgets('CRITICAL: List items should persist after app restart', (tester) async {
      // RED: This test should FAIL initially
      
      // === PHASE 1: Create and save data ===
      final controller1 = container.read(listsControllerProvider.notifier);
      
      // Create test items
      const listId = 'test-list-id';
      final testItems = [
        'Terminer le rapport projet',
        'Préparer présentation client', 
        'Réviser documentation technique',
      ];
      
      // Add items to the list
      await controller1.addMultipleItemsToList(listId, testItems);
      
      // Verify items were added to memory
      final state1 = container.read(listsControllerProvider);
      expect(state1.lists.isNotEmpty, true, reason: 'Items should be in memory');
      
      // === PHASE 2: Simulate app restart ===
      container.dispose(); // Simulate app shutdown
      
      // Create new container (simulates app restart)  
      final newContainer = ProviderContainer();
      final controller2 = newContainer.read(listsControllerProvider.notifier);
      
      // Load data from persistence
      await controller2.loadLists();
      
      // === PHASE 3: Verify data persistence ===
      final state2 = newContainer.read(listsControllerProvider);
      
      // CRITICAL TEST: Data should survive app restart
      expect(state2.lists.isNotEmpty, true, 
        reason: 'CRITICAL: Data should persist after app restart');
      
      // Find our test list
      final testList = state2.lists.firstWhere(
        (list) => list.id == listId,
        orElse: () => throw StateError('Test list not found after restart'),
      );
      
      // Verify all items are present
      expect(testList.items.length, equals(3), 
        reason: 'All 3 items should be persisted');
        
      final itemTitles = testList.items.map((item) => item.title).toList();
      for (final expectedTitle in testItems) {
        expect(itemTitles, contains(expectedTitle),
          reason: 'Item "$expectedTitle" should be persisted');
      }
      
      newContainer.dispose();
    });

    testWidgets('List items should use Hive for offline persistence', (tester) async {
      // Test that repository uses Hive when offline
      final repository = container.read(listItemRepositoryProvider);
      
      // This should NOT be InMemoryListItemRepository
      expect(repository.runtimeType.toString(), isNot('InMemoryListItemRepository'),
        reason: 'Should use persistent repository, not in-memory');
        
      // Should be Hive-based or adaptive repository
      expect(
        repository.runtimeType.toString().contains('Hive') ||
        repository.runtimeType.toString().contains('Adaptive'),
        true,
        reason: 'Repository should use Hive for persistence'
      );
    });
  });
}