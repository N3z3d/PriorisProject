import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/services/navigation/list_resolution_service.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';

import '../../../test_utils/test_providers.dart';
import '../../../test_utils/test_data.dart';

void main() {
  group('ListResolutionService', () {
    late ProviderContainer container;
    late ListResolutionService service;
    
    setUp(() {
      container = createTestProviderContainer();
      
      // Create test lists
      final testLists = [
        TestData.createTestList(
          id: 'list1',
          name: 'First List',
          type: ListType.TODO,
        ),
        TestData.createTestList(
          id: 'list2',
          name: 'Second List',
          type: ListType.SHOPPING,
        ),
        TestData.createTestList(
          id: 'list3',
          name: 'Third List',
          type: ListType.IDEAS,
        ),
      ];
      
      // Set up the lists state
      final controller = container.read(listsControllerProvider.notifier);
      controller.state = controller.state.copyWith(lists: testLists);
      
      service = container.read(listResolutionServiceProvider);
    });
    
    tearDown(() {
      container.dispose();
    });
    
    group('resolveListWithFallback', () {
      test('should return requested list when ID is valid', () {
        // Arrange
        const requestedId = 'list2';
        
        // Act
        final result = service.resolveListWithFallback(requestedId);
        
        // Assert
        expect(result.isSuccessful, true);
        expect(result.resolvedList?.id, equals(requestedId));
        expect(result.resolvedList?.name, equals('Second List'));
        expect(result.usedFallback, false);
        expect(result.fallbackReason, isNull);
      });
      
      test('should use fallback to first list when ID is invalid', () {
        // Arrange
        const invalidId = 'non-existent-id';
        
        // Act
        final result = service.resolveListWithFallback(invalidId);
        
        // Assert
        expect(result.isSuccessful, true);
        expect(result.resolvedList?.id, equals('list1'));
        expect(result.resolvedList?.name, equals('First List'));
        expect(result.usedFallback, true);
        expect(result.fallbackReason, contains('not found'));
      });
      
      test('should use fallback to first list when ID is null', () {
        // Act
        final result = service.resolveListWithFallback(null);
        
        // Assert
        expect(result.isSuccessful, true);
        expect(result.resolvedList?.id, equals('list1'));
        expect(result.resolvedList?.name, equals('First List'));
        expect(result.usedFallback, true);
        expect(result.fallbackReason, contains('No list ID provided'));
      });
      
      test('should use fallback to first list when ID is empty', () {
        // Act
        final result = service.resolveListWithFallback('');
        
        // Assert
        expect(result.isSuccessful, true);
        expect(result.resolvedList?.id, equals('list1'));
        expect(result.resolvedList?.name, equals('First List'));
        expect(result.usedFallback, true);
        expect(result.fallbackReason, contains('No list ID provided'));
      });
      
      test('should return null result when no lists are available', () {
        // Arrange - Clear all lists
        final controller = container.read(listsControllerProvider.notifier);
        controller.state = controller.state.copyWith(lists: <CustomList>[]);
        
        // Act
        final result = service.resolveListWithFallback('any-id');
        
        // Assert
        expect(result.isSuccessful, false);
        expect(result.resolvedList, isNull);
        expect(result.resolvedListId, isNull);
        expect(result.usedFallback, false);
        expect(result.isNoListsAvailable, true);
        expect(result.fallbackReason, contains('No lists available'));
      });
    });
    
    group('hasAvailableLists', () {
      test('should return true when lists are available', () {
        expect(service.hasAvailableLists, true);
      });
      
      test('should return false when no lists are available', () {
        // Arrange - Clear all lists
        final controller = container.read(listsControllerProvider.notifier);
        controller.state = controller.state.copyWith(lists: <CustomList>[]);
        
        // Act & Assert
        expect(service.hasAvailableLists, false);
      });
    });
    
    group('availableListsCount', () {
      test('should return correct count of available lists', () {
        expect(service.availableListsCount, 3);
      });
    });
    
    group('availableListIds', () {
      test('should return all available list IDs', () {
        // Act
        final ids = service.availableListIds;
        
        // Assert
        expect(ids, hasLength(3));
        expect(ids, contains('list1'));
        expect(ids, contains('list2'));
        expect(ids, contains('list3'));
      });
    });
  });
  
  group('ListResolutionResult', () {
    test('should correctly identify successful resolution', () {
      // Arrange
      final list = TestData.createTestList(id: 'test-id', name: 'Test List');
      const result = ListResolutionResult(
        resolvedList: list,
        resolvedListId: 'test-id',
        usedFallback: false,
      );
      
      // Assert
      expect(result.isSuccessful, true);
      expect(result.isNoListsAvailable, false);
    });
    
    test('should correctly identify no lists available state', () {
      // Arrange
      const result = ListResolutionResult(
        resolvedList: null,
        resolvedListId: null,
        usedFallback: false,
        fallbackReason: 'No lists available',
      );
      
      // Assert
      expect(result.isSuccessful, false);
      expect(result.isNoListsAvailable, true);
    });
    
    test('should correctly identify fallback usage', () {
      // Arrange
      final list = TestData.createTestList(id: 'fallback-id', name: 'Fallback List');
      const result = ListResolutionResult(
        resolvedList: list,
        resolvedListId: 'fallback-id',
        usedFallback: true,
        fallbackReason: 'Original list not found',
      );
      
      // Assert
      expect(result.isSuccessful, true);
      expect(result.usedFallback, true);
      expect(result.fallbackReason, isNotNull);
    });
    
    test('toString should provide useful debug information', () {
      // Arrange
      final list = TestData.createTestList(id: 'test-id', name: 'Test List');
      const result = ListResolutionResult(
        resolvedList: list,
        resolvedListId: 'test-id',
        usedFallback: true,
        fallbackReason: 'Test fallback',
      );
      
      // Act
      final stringRepresentation = result.toString();
      
      // Assert
      expect(stringRepresentation, contains('Test List'));
      expect(stringRepresentation, contains('test-id'));
      expect(stringRepresentation, contains('fallback: true'));
      expect(stringRepresentation, contains('Test fallback'));
    });
  });
}