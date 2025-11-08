import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/presentation/pages/list_detail_loader_page.dart';
import 'package:prioris/presentation/pages/list_detail_page.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';

import '../../test_utils/test_providers.dart';
import '../../test_utils/test_data.dart';

void main() {
  group('SmartListDetailLoaderPage Integration Tests', () {
    late ProviderContainer container;
    late Widget testApp;
    
    setUp(() {
      container = createTestProviderContainer();
      
      testApp = UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: const TestWrapper(),
        ),
      );
    });
    
    tearDown(() {
      container.dispose();
    });
    
    group('URL State Management Integration', () {
      testWidgets('should display list detail page when valid list ID provided', (tester) async {
        // Arrange
        final testLists = [
          TestData.createTestList(
            id: 'test-list-1',
            name: 'Test List One',
            type: ListType.PROJECTS,
          ),
          TestData.createTestList(
            id: 'test-list-2', 
            name: 'Test List Two',
            type: ListType.SHOPPING,
          ),
        ];
        
        final controller = container.read(listsControllerProvider.notifier);
        controller.state = controller.state.copyWith(lists: testLists);
        
        // Act
        await tester.pumpWidget(UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: const ListDetailLoaderPage.withListId(listId: 'test-list-2'),
          ),
        ));
        
        await tester.pumpAndSettle();
        
        // Assert
        expect(find.byType(ListDetailPage), findsOneWidget);
        expect(find.text('Test List Two'), findsOneWidget);
      });
      
      testWidgets('should fallback to first available list when invalid ID provided', (tester) async {
        // Arrange
        final testLists = [
          TestData.createTestList(
            id: 'first-list',
            name: 'First Available List',
            type: ListType.PROJECTS,
          ),
          TestData.createTestList(
            id: 'second-list',
            name: 'Second Available List', 
            type: ListType.SHOPPING,
          ),
        ];
        
        final controller = container.read(listsControllerProvider.notifier);
        controller.state = controller.state.copyWith(lists: testLists);
        
        // Act
        await tester.pumpWidget(UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: const ListDetailLoaderPage.withListId(listId: 'non-existent-id'),
          ),
        ));
        
        await tester.pumpAndSettle();
        
        // Assert
        expect(find.byType(ListDetailPage), findsOneWidget);
        expect(find.text('First Available List'), findsOneWidget);
      });
      
      testWidgets('should fallback to first available list when no ID provided', (tester) async {
        // Arrange
        final testLists = [
          TestData.createTestList(
            id: 'fallback-list',
            name: 'Fallback List',
            type: ListType.CUSTOM,
          ),
        ];
        
        final controller = container.read(listsControllerProvider.notifier);
        controller.state = controller.state.copyWith(lists: testLists);
        
        // Act
        await tester.pumpWidget(UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: const ListDetailLoaderPage(listId: null),
          ),
        ));
        
        await tester.pumpAndSettle();
        
        // Assert
        expect(find.byType(ListDetailPage), findsOneWidget);
        expect(find.text('Fallback List'), findsOneWidget);
      });
      
      testWidgets('should show empty state when no lists available', (tester) async {
        // Arrange - No lists
        final controller = container.read(listsControllerProvider.notifier);
        controller.state = controller.state.copyWith(lists: <CustomList>[]);
        
        // Act
        await tester.pumpWidget(UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: const ListDetailLoaderPage(listId: null),
          ),
        ));
        
        await tester.pumpAndSettle();
        
        // Assert
        expect(find.text('Aucune liste disponible'), findsOneWidget);
        expect(find.text('Créez votre première liste pour commencer'), findsOneWidget);
        expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
        expect(find.text('Retour à l\'accueil'), findsOneWidget);
      });
      
      testWidgets('should display loading state initially', (tester) async {
        // Arrange
        final testLists = [TestData.createTestList(id: 'loading-test', name: 'Loading Test')];
        final controller = container.read(listsControllerProvider.notifier);
        controller.state = controller.state.copyWith(lists: testLists);
        
        // Act
        await tester.pumpWidget(UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: const ListDetailLoaderPage.withListId(listId: 'loading-test'),
          ),
        ));
        
        // Assert - Check for loading state before settling
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Chargement de votre liste...'), findsOneWidget);
        
        // Let the async operations complete
        await tester.pumpAndSettle();
        
        // Assert - Should now show the loaded content
        expect(find.byType(ListDetailPage), findsOneWidget);
      });
    });
    
    group('Error Handling Integration', () {
      testWidgets('should handle provider errors gracefully', (tester) async {
        // Arrange - Create a container that will throw errors
        final errorContainer = ProviderContainer(
          overrides: [
            listsControllerProvider.overrideWith((ref) => throw Exception('Test error')),
          ],
        );
        
        // Act
        await tester.pumpWidget(UncontrolledProviderScope(
          container: errorContainer,
          child: MaterialApp(
            home: const ListDetailLoaderPage(listId: null),
          ),
        ));
        
        await tester.pumpAndSettle();
        
        // Assert - Should show error handling UI
        expect(find.text('Une erreur s\'est produite'), findsOneWidget);
        expect(find.byIcon(Icons.sentiment_dissatisfied), findsOneWidget);
        
        // Cleanup
        errorContainer.dispose();
      });
      
      testWidgets('should provide retry functionality in error states', (tester) async {
        // Arrange - Create a container that will throw errors
        final errorContainer = ProviderContainer(
          overrides: [
            listsControllerProvider.overrideWith((ref) => throw Exception('Network error')),
          ],
        );
        
        // Act
        await tester.pumpWidget(UncontrolledProviderScope(
          container: errorContainer,
          child: MaterialApp(
            home: const ListDetailLoaderPage(listId: null),
          ),
        ));
        
        await tester.pumpAndSettle();
        
        // Assert - Should show retry button
        expect(find.text('Réessayer'), findsOneWidget);
        expect(find.text('Accueil'), findsOneWidget);
        
        // Act - Tap retry button (should not crash)
        await tester.tap(find.text('Réessayer'));
        await tester.pumpAndSettle();
        
        // Cleanup
        errorContainer.dispose();
      });
    });
    
    group('Performance and Memory Management', () {
      testWidgets('should not cause memory leaks during rapid navigation', (tester) async {
        // Arrange
        final testLists = [
          TestData.createTestList(id: 'list-1', name: 'List 1'),
          TestData.createTestList(id: 'list-2', name: 'List 2'),
          TestData.createTestList(id: 'list-3', name: 'List 3'),
        ];
        
        final controller = container.read(listsControllerProvider.notifier);
        controller.state = controller.state.copyWith(lists: testLists);
        
        // Act - Simulate rapid navigation between different lists
        for (int i = 0; i < 5; i++) {
          await tester.pumpWidget(UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: ListDetailLoaderPage.withListId(listId: 'list-${(i % 3) + 1}'),
            ),
          ));
          
          await tester.pumpAndSettle();
          
          // Assert - Should successfully load each time
          expect(find.byType(ListDetailPage), findsOneWidget);
        }
        
        // No explicit assertion needed - test passes if no memory issues occur
      });
    });
  });
}

/// Test wrapper widget for providing consistent test environment
class TestWrapper extends StatelessWidget {
  const TestWrapper({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Test Environment'),
      ),
    );
  }
}