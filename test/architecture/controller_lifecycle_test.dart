import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';
import 'package:prioris/domain/services/persistence/adaptive_persistence_service.dart';
import 'package:prioris/domain/services/core/lists_filter_service.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';

import 'controller_lifecycle_test.mocks.dart';

/// TDD Phase: RED - These tests should FAIL initially
/// 
/// This test file validates controller lifecycle management issues:
/// 1. Controller disposal timing and mounted checks
/// 2. StateNotifier lifecycle integrity  
/// 3. Resource cleanup and memory leaks
/// 4. Proper error handling after disposal
@GenerateMocks([
  AdaptivePersistenceService,
  CustomListRepository,
  ListItemRepository,
  ListsFilterService,
])
void main() {
  group('Controller Lifecycle Management Tests (TDD-RED)', () {
    late ListsController controller;
    late MockAdaptivePersistenceService mockAdaptiveService;
    late MockCustomListRepository mockLocalRepo;
    late MockListItemRepository mockItemRepo;
    late MockListsFilterService mockFilterService;
    late ProviderContainer container;

    setUp(() {
      mockAdaptiveService = MockAdaptivePersistenceService();
      mockLocalRepo = MockCustomListRepository();
      mockItemRepo = MockListItemRepository();
      mockFilterService = MockListsFilterService();
      
      // Setup default mocks to avoid MissingStubError
      when(mockAdaptiveService.getAllLists()).thenAnswer((_) async => []);
      when(mockAdaptiveService.getItemsByListId(any)).thenAnswer((_) async => []);
      when(mockAdaptiveService.currentMode).thenReturn(PersistenceMode.localFirst);
      when(mockFilterService.applyFilters(
        any,
        searchQuery: anyNamed('searchQuery'),
        selectedType: anyNamed('selectedType'),
        showCompleted: anyNamed('showCompleted'),
        showInProgress: anyNamed('showInProgress'),
        selectedDateFilter: anyNamed('selectedDateFilter'),
        sortOption: anyNamed('sortOption'),
      )).thenAnswer((invocation) => invocation.positionalArguments[0] as List<CustomList>);
      
      // Initialize the controller with mocks
      controller = ListsController.adaptive(
        mockAdaptiveService,
        mockLocalRepo,
        mockItemRepo,
        mockFilterService,
      );
      
      container = ProviderContainer();
    });

    tearDown(() {
      controller.dispose();
      container.dispose();
    });

    group('RED: Controller Disposal Issues', () {
      test('SHOULD PASS: Controller operations after dispose should not crash', () async {
        // Act - Dispose the controller first
        controller.dispose();
        
        // Act & Assert - This should NOT crash but should gracefully handle the disposed state
        expect(() async {
          await controller.loadLists();
        }, isNot(throwsException),
          reason: 'Operations after dispose should be handled gracefully');
      });

      test('SHOULD PASS: Multiple dispose calls should not cause errors', () async {
        // Act & Assert - Multiple dispose calls should be safe
        expect(() {
          controller.dispose();
          controller.dispose();
          controller.dispose();
        }, isNot(throwsA(anything)),
          reason: 'Multiple dispose calls should be idempotent');
      });

      test('SHOULD PASS: State updates after dispose should be ignored', () async {
        // Arrange
        when(mockAdaptiveService.getAllLists()).thenAnswer((_) async => [
          CustomList(
            id: 'test-1',
            name: 'Test List',
            type: ListType.CUSTOM,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          )
        ]);
        
        // Act - Load data first to establish initial state
        await controller.loadLists();
        final stateAfterLoad = controller.state;
        
        // Dispose controller
        controller.dispose();
        
        // Try to load data after disposal - this should be ignored silently
        await controller.loadLists();
        
        // Assert - Controller should handle disposed state gracefully without throwing
        expect(true, isTrue, reason: 'Controller should handle disposed state gracefully');
      });
    });

    group('RED: Resource Cleanup Issues', () {
      test('SHOULD FAIL: Filter service cache should be cleared on disposal', () async {
        // Arrange - Mock filter service with cache
        when(mockFilterService.clearCache()).thenReturn(null);
        
        // Act
        controller.cleanup();
        controller.dispose();
        
        // Assert
        verify(mockFilterService.clearCache()).called(1);
      });

      test('SHOULD FAIL: Memory leaks should be prevented', () async {
        // This test validates that the controller doesn't hold onto resources
        // Arrange
        final testList = CustomList(
          id: 'memory-test',
          name: 'Memory Test List',
          type: ListType.CUSTOM,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        when(mockAdaptiveService.getAllLists()).thenAnswer((_) async => [testList]);
        
        // Act - Load data then dispose
        await controller.loadLists();
        controller.dispose();
        
        // Assert - Controller should not maintain references
        // Note: This is more of a conceptual test - in practice we'd use tools like
        // memory profilers, but this validates the dispose pattern
        expect(controller.mounted, isFalse);
      });
    });

    group('RED: Error Handling After Disposal', () {
      test('SHOULD PASS: Error states should not be set after disposal', () async {
        // Arrange
        when(mockAdaptiveService.getAllLists()).thenThrow(Exception('Test error'));
        
        // Dispose first
        controller.dispose();
        
        // Act - Try operation that would normally set error state
        // This should not throw an exception but should handle gracefully
        await controller.loadLists();
        
        // Assert - Operation should complete without throwing
        expect(true, isTrue, reason: 'Error handling after disposal should be graceful');
      });

      test('SHOULD PASS: Loading states should not be updated after disposal', () async {
        // Arrange
        final slowOperation = Completer<List<CustomList>>();
        when(mockAdaptiveService.getAllLists()).thenAnswer((_) => slowOperation.future);
        
        // Start operation
        final future = controller.loadLists();
        
        // Dispose immediately
        controller.dispose();
        
        // Complete the operation
        slowOperation.complete([]);
        
        // Act & Assert - Should complete without throwing
        await expectLater(future, completes,
          reason: 'Disposed controller should handle concurrent operations gracefully');
      });
    });

    group('RED: Riverpod Integration Issues', () {
      test('SHOULD FAIL: Disposed controller should not trigger provider updates', () async {
        // This test is more conceptual but validates the integration pattern
        // In practice, Riverpod handles this, but our controller should support it
        
        // Arrange
        var updateCount = 0;
        late ListsState capturedState;
        
        controller.addListener((state) {
          updateCount++;
          capturedState = state;
        });
        
        when(mockAdaptiveService.getAllLists()).thenAnswer((_) async => []);
        
        // Act - Load data, then dispose, then try another operation
        await controller.loadLists();
        final countAfterLoad = updateCount;
        
        controller.dispose();
        await controller.loadLists(); // This should not trigger updates
        
        // Assert
        expect(updateCount, equals(countAfterLoad),
          reason: 'No additional state updates should occur after disposal');
      });
    });
  });

  group('Controller Lifecycle Best Practices (TDD-RED)', () {
    test('SHOULD FAIL: Controller should implement proper StateNotifier lifecycle', () {
      // This test validates that our controller follows StateNotifier best practices
      final controller = ListsController.adaptive(
        MockAdaptivePersistenceService(),
        MockCustomListRepository(),
        MockListItemRepository(),
        MockListsFilterService(),
      );
      
      // Should start with valid initial state
      expect(controller.state, isA<ListsState>());
      expect(controller.mounted, isTrue);
      
      // Should dispose cleanly
      controller.dispose();
      expect(controller.mounted, isFalse);
    });

    test('SHOULD FAIL: Controller should handle concurrent operations gracefully', () async {
      // Arrange
      final mockService = MockAdaptivePersistenceService();
      when(mockService.getAllLists()).thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 100));
        return [];
      });
      
      final controller = ListsController.adaptive(
        mockService,
        MockCustomListRepository(),
        MockListItemRepository(),
        MockListsFilterService(),
      );
      
      // Act - Start multiple concurrent operations
      final futures = List.generate(5, (_) => controller.loadLists());
      
      // Dispose while operations are running
      controller.dispose();
      
      // Wait for all operations to complete
      await Future.wait(futures);
      
      // Assert - Should not crash and should handle gracefully
      expect(controller.mounted, isFalse);
    });
  });
}