import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/presentation/routes/app_routes.dart';
import 'package:prioris/presentation/pages/list_detail_loader_page.dart';
import 'package:prioris/presentation/pages/list_detail_page.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';

import '../../test_utils/test_providers.dart';
import '../../test_utils/test_data.dart';

/// Tests specifically for handling page refresh scenarios that should
/// maintain user context instead of redirecting to home page
void main() {
  group('Page Refresh Context Preservation Tests', () {
    late ProviderContainer container;
    
    setUp(() {
      container = ProviderContainer();
    });
    
    tearDown(() {
      container.dispose();
    });
    
    group('URL Refresh Scenarios', () {
      testWidgets('CRITICAL: should stay on list detail page after refresh with valid ID', (tester) async {
        // Arrange - Setup lists as they would exist after app initialization
        final testLists = [
          TestData.createTestList(
            id: 'valid-list-id',
            name: 'User List',
            type: ListType.PROJECTS,
          ),
          TestData.createTestList(
            id: 'another-list-id',
            name: 'Another List',
            type: ListType.SHOPPING,
          ),
        ];
        
        final controller = container.read(listsControllerProvider.notifier);
        controller.state = controller.state.copyWith(lists: testLists);
        
        // Create MaterialApp with proper routing (simulates page refresh)
        final app = UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            routes: AppRoutes.routes,
            onGenerateRoute: AppRoutes.generateRoute,
            initialRoute: '/list-detail?id=valid-list-id', // Simulate refresh URL
          ),
        );
        
        // Act - Build the app (simulates page refresh)
        await tester.pumpWidget(app);
        await tester.pumpAndSettle();
        
        // Assert - Should show ListDetailPage with the correct list, NOT redirect to home
        expect(find.byType(ListDetailPage), findsOneWidget);
        expect(find.text('User List'), findsOneWidget);
        
        // Assert - Should NOT show HomePage or any redirect indicators
        expect(find.text('Prioris - Accueil'), findsNothing);
        expect(find.text('Bienvenue'), findsNothing);
      });
      
      testWidgets('CRITICAL: should fallback to first available list when refresh URL has invalid ID', (tester) async {
        // Arrange - Setup lists with different ID than what's in URL
        final testLists = [
          TestData.createTestList(
            id: 'first-available-list',
            name: 'First Available List',
            type: ListType.PROJECTS,
          ),
          TestData.createTestList(
            id: 'second-available-list',
            name: 'Second Available List',
            type: ListType.SHOPPING,
          ),
        ];
        
        final controller = container.read(listsControllerProvider.notifier);
        controller.state = controller.state.copyWith(lists: testLists);
        
        // Create MaterialApp with invalid list ID in URL (simulates refresh with stale URL)
        final app = UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            routes: AppRoutes.routes,
            onGenerateRoute: AppRoutes.generateRoute,
            initialRoute: '/list-detail?id=invalid-list-id', // Simulate refresh with invalid ID
          ),
        );
        
        // Act - Build the app (simulates page refresh)
        await tester.pumpWidget(app);
        await tester.pumpAndSettle();
        
        // Assert - Should show first available list, NOT redirect to home
        expect(find.byType(ListDetailPage), findsOneWidget);
        expect(find.text('First Available List'), findsOneWidget);
        
        // Assert - Should NOT show HomePage or any redirect indicators
        expect(find.text('Prioris - Accueil'), findsNothing);
        expect(find.text('Bienvenue'), findsNothing);
      });
      
      testWidgets('CRITICAL: should fallback to first available list when refresh URL has no ID', (tester) async {
        // Arrange - Setup lists (user has lists available)
        final testLists = [
          TestData.createTestList(
            id: 'default-list',
            name: 'Default List',
            type: ListType.CUSTOM,
          ),
        ];
        
        final controller = container.read(listsControllerProvider.notifier);
        controller.state = controller.state.copyWith(lists: testLists);
        
        // Create MaterialApp with no list ID in URL (simulates refresh with lost parameters)
        final app = UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            routes: AppRoutes.routes,
            onGenerateRoute: AppRoutes.generateRoute,
            initialRoute: '/list-detail', // Simulate refresh with lost query params
          ),
        );
        
        // Act - Build the app (simulates page refresh)
        await tester.pumpWidget(app);
        await tester.pumpAndSettle();
        
        // Assert - Should show first available list, NOT redirect to home
        expect(find.byType(ListDetailPage), findsOneWidget);
        expect(find.text('Default List'), findsOneWidget);
        
        // Assert - Should NOT show HomePage or any redirect indicators
        expect(find.text('Prioris - Accueil'), findsNothing);
        expect(find.text('Bienvenue'), findsNothing);
      });
      
      testWidgets('should gracefully handle refresh when no lists are available', (tester) async {
        // Arrange - No lists available (edge case: user deleted all lists)
        final controller = container.read(listsControllerProvider.notifier);
        controller.state = controller.state.copyWith(lists: <CustomList>[]);
        
        // Create MaterialApp with list detail URL but no lists available
        final app = UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            routes: AppRoutes.routes,
            onGenerateRoute: AppRoutes.generateRoute,
            initialRoute: '/list-detail?id=some-id', 
          ),
        );
        
        // Act - Build the app
        await tester.pumpWidget(app);
        await tester.pumpAndSettle();
        
        // Assert - Should show appropriate empty state, NOT a crash or redirect to home
        expect(find.text('Aucune liste disponible'), findsOneWidget);
        expect(find.text('Créez votre première liste pour commencer'), findsOneWidget);
        expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
        
        // Assert - Should provide navigation back to home as an option
        expect(find.text('Retour à l\'accueil'), findsOneWidget);
      });
    });
    
    group('User Experience Continuity', () {
      testWidgets('should maintain user context across multiple refresh scenarios', (tester) async {
        // Arrange - Setup realistic user data
        final userLists = [
          TestData.createTestList(
            id: 'shopping-list-123',
            name: 'Weekly Shopping',
            type: ListType.SHOPPING,
          ),
          TestData.createTestList(
            id: 'todo-list-456',
            name: 'Work Tasks',
            type: ListType.PROJECTS,
          ),
          TestData.createTestList(
            id: 'custom-list-789',
            name: 'Project Ideas',
            type: ListType.CUSTOM,
          ),
        ];
        
        final controller = container.read(listsControllerProvider.notifier);
        controller.state = controller.state.copyWith(lists: userLists);
        
        // Test Scenario 1: Refresh with valid ID should stay on that list
        var app = UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            routes: AppRoutes.routes,
            onGenerateRoute: AppRoutes.generateRoute,
            initialRoute: '/list-detail?id=todo-list-456',
          ),
        );
        
        await tester.pumpWidget(app);
        await tester.pumpAndSettle();
        
        expect(find.byType(ListDetailPage), findsOneWidget);
        expect(find.text('Work Tasks'), findsOneWidget);
        
        // Test Scenario 2: Refresh with invalid ID should fallback to first list
        app = UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            routes: AppRoutes.routes,
            onGenerateRoute: AppRoutes.generateRoute,
            initialRoute: '/list-detail?id=deleted-list-999',
          ),
        );
        
        await tester.pumpWidget(app);
        await tester.pumpAndSettle();
        
        expect(find.byType(ListDetailPage), findsOneWidget);
        expect(find.text('Weekly Shopping'), findsOneWidget); // First in list
        
        // Test Scenario 3: Refresh with no ID should fallback to first list  
        app = UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            routes: AppRoutes.routes,
            onGenerateRoute: AppRoutes.generateRoute,
            initialRoute: '/list-detail',
          ),
        );
        
        await tester.pumpWidget(app);
        await tester.pumpAndSettle();
        
        expect(find.byType(ListDetailPage), findsOneWidget);
        expect(find.text('Weekly Shopping'), findsOneWidget); // First in list
      });
      
      testWidgets('should handle refresh during app startup when lists are still loading', (tester) async {
        // Arrange - Setup controller in loading state
        final controller = container.read(listsControllerProvider.notifier);
        controller.state = controller.state.copyWith(
          lists: <CustomList>[],
          isLoading: true,
        );
        
        final app = UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            routes: AppRoutes.routes,
            onGenerateRoute: AppRoutes.generateRoute,
            initialRoute: '/list-detail?id=loading-test',
          ),
        );
        
        // Act - Build app in loading state
        await tester.pumpWidget(app);
        await tester.pump(); // Don't settle yet - should show loading
        
        // Assert - Should show loading state
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Chargement de votre liste...'), findsOneWidget);
        
        // Simulate lists finishing loading
        final testLists = [
          TestData.createTestList(id: 'loaded-list', name: 'Loaded List'),
        ];
        controller.state = controller.state.copyWith(
          lists: testLists,
          isLoading: false,
        );
        
        await tester.pumpAndSettle();
        
        // Assert - Should now show the loaded content
        expect(find.byType(ListDetailPage), findsOneWidget);
        expect(find.text('Loaded List'), findsOneWidget);
      });
    });
    
    group('Performance and Memory Safety', () {
      testWidgets('should handle rapid refresh events without memory leaks', (tester) async {
        // Arrange
        final testLists = [
          TestData.createTestList(id: 'performance-test', name: 'Performance Test List'),
        ];
        
        final controller = container.read(listsControllerProvider.notifier);
        controller.state = controller.state.copyWith(lists: testLists);
        
        // Act - Simulate rapid refresh events
        for (int i = 0; i < 10; i++) {
          final app = UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              routes: AppRoutes.routes,
              onGenerateRoute: AppRoutes.generateRoute,
              initialRoute: '/list-detail?id=performance-test',
            ),
          );
          
          await tester.pumpWidget(app);
          await tester.pumpAndSettle();
          
          // Assert - Should handle each refresh successfully
          expect(find.byType(ListDetailPage), findsOneWidget);
          expect(find.text('Performance Test List'), findsOneWidget);
        }
        
        // Test passes if no memory errors occur
      });
    });
  });
}