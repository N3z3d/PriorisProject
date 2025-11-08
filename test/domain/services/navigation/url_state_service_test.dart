import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/services/navigation/url_state_service.dart';
import 'package:prioris/domain/services/navigation/list_resolution_service.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';

import '../../../test_utils/test_providers.dart';
import '../../../test_utils/test_data.dart';

void main() {
  group('UrlStateService', () {
    late ProviderContainer container;
    late Widget testApp;
    
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
      ];
      
      // Set up the lists state
      final controller = container.read(listsControllerProvider.notifier);
      controller.state = controller.state.copyWith(lists: testLists);
      
      // Create test app
      testApp = UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: const TestWidget(),
          onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (context) => const TestWidget(),
            settings: settings,
          ),
        ),
      );
    });
    
    tearDown(() {
      container.dispose();
    });
    
    group('generateListDetailUrl', () {
      testWidgets('should generate correct URL for list detail', (tester) async {
        // Arrange
        await tester.pumpWidget(testApp);
        final context = tester.element(find.byType(TestWidget));
        final manager = container.read(urlStateServiceProvider(context));
        
        // Act
        final url = manager.generateListDetailUrl('test-list-id');
        
        // Assert
        expect(url, equals('/list-detail?id=test-list-id'));
      });
    });
    
    group('isUrlConsistentWithState', () {
      testWidgets('should return true when URL matches state', (tester) async {
        // Arrange
        await tester.pumpWidget(testApp);
        final context = tester.element(find.byType(TestWidget));
        final manager = container.read(urlStateServiceProvider(context));
        
        // Act & Assert
        expect(manager.isUrlConsistentWithState('list1', 'list1'), true);
      });
      
      testWidgets('should return false when URL does not match state', (tester) async {
        // Arrange
        await tester.pumpWidget(testApp);
        final context = tester.element(find.byType(TestWidget));
        final manager = container.read(urlStateServiceProvider(context));
        
        // Act & Assert
        expect(manager.isUrlConsistentWithState('list1', 'list2'), false);
      });
      
      testWidgets('should handle null values correctly', (tester) async {
        // Arrange
        await tester.pumpWidget(testApp);
        final context = tester.element(find.byType(TestWidget));
        final manager = container.read(urlStateServiceProvider(context));
        
        // Act & Assert
        expect(manager.isUrlConsistentWithState(null, null), true);
        expect(manager.isUrlConsistentWithState('list1', null), false);
        expect(manager.isUrlConsistentWithState(null, 'list1'), false);
      });
    });
    
    group('resolveAndUpdateUrlState', () {
      testWidgets('should resolve valid list ID without fallback', (tester) async {
        // Arrange
        await tester.pumpWidget(testApp);

        // Re-populate lists after widget initialization (which auto-loads from empty repository)
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
        ];
        final controller = container.read(listsControllerProvider.notifier);
        controller.state = controller.state.copyWith(lists: testLists);

        final context = tester.element(find.byType(TestWidget));
        final manager = container.read(urlStateServiceProvider(context));

        // Act
        final result = manager.resolveAndUpdateUrlState('list2');

        // Assert
        expect(result.isSuccessful, true);
        expect(result.resolvedList?.id, equals('list2'));
        expect(result.resolvedList?.name, equals('Second List'));
        expect(result.usedFallback, false);
      });
      
      testWidgets('should use fallback for invalid list ID', (tester) async {
        // Arrange
        await tester.pumpWidget(testApp);

        // Re-populate lists after widget initialization
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
        ];
        final controller = container.read(listsControllerProvider.notifier);
        controller.state = controller.state.copyWith(lists: testLists);

        final context = tester.element(find.byType(TestWidget));
        final manager = container.read(urlStateServiceProvider(context));

        // Act
        final result = manager.resolveAndUpdateUrlState('invalid-id');

        // Assert
        expect(result.isSuccessful, true);
        expect(result.resolvedList?.id, equals('list1')); // First available list
        expect(result.usedFallback, true);
        expect(result.fallbackReason, contains('not found'));
      });
      
      testWidgets('should use fallback for null list ID', (tester) async {
        // Arrange
        await tester.pumpWidget(testApp);

        // Re-populate lists after widget initialization
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
        ];
        final controller = container.read(listsControllerProvider.notifier);
        controller.state = controller.state.copyWith(lists: testLists);

        final context = tester.element(find.byType(TestWidget));
        final manager = container.read(urlStateServiceProvider(context));

        // Act
        final result = manager.resolveAndUpdateUrlState(null);

        // Assert
        expect(result.isSuccessful, true);
        expect(result.resolvedList?.id, equals('list1')); // First available list
        expect(result.usedFallback, true);
        expect(result.fallbackReason, contains('No list ID provided'));
      });
      
      testWidgets('should handle no lists available scenario', (tester) async {
        // Arrange - Clear all lists
        final controller = container.read(listsControllerProvider.notifier);
        controller.state = controller.state.copyWith(lists: <CustomList>[]);
        
        await tester.pumpWidget(testApp);
        final context = tester.element(find.byType(TestWidget));
        final manager = container.read(urlStateServiceProvider(context));
        
        // Act
        final result = manager.resolveAndUpdateUrlState('any-id');
        
        // Assert
        expect(result.isSuccessful, false);
        expect(result.resolvedList, isNull);
        expect(result.isNoListsAvailable, true);
      });
    });
    
    group('updateUrlToResolvedList', () {
      testWidgets('should handle URL update without throwing', (tester) async {
        // Arrange
        await tester.pumpWidget(testApp);
        final context = tester.element(find.byType(TestWidget));
        final manager = container.read(urlStateServiceProvider(context));
        
        // Act & Assert - Should not throw
        expect(() => manager.updateUrlToResolvedList('list1'), returnsNormally);
        
        // Allow for post-frame callback to execute
        await tester.pump();
      });
    });
  });
}

/// Test widget for providing BuildContext in tests
class TestWidget extends StatelessWidget {
  const TestWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Test Widget'),
      ),
    );
  }
}
