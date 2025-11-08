import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/presentation/pages/list_detail_page.dart';
import 'package:prioris/presentation/widgets/buttons/premium_fab.dart';
import 'package:prioris/presentation/widgets/dialogs/bulk_add_dialog.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';
import '../../test_utils/test_providers.dart';
import '../../test_utils/test_data.dart';

void main() {
  group('ListDetailPage Add Button Tests', () {
    late MockListsController mockController;
    late CustomList testList;
    
    setUp(() {
      mockController = MockListsController();
      testList = TestData.createTestList();
    });

    group('Visual Rendering Tests', () {
      testWidgets('should render PremiumFAB with correct text and icon', (tester) async {
        // ARRANGE
        await tester.pumpWidget(TestAppWrapper(
          overrides: [
            listsControllerProvider.overrideWith((ref) => mockController),
            listByIdProvider(testList.id).overrideWith((ref) => testList),
          ],
          child: ListDetailPage(list: testList),
        ));

        // ACT
        final fabFinder = find.byType(PremiumFAB);

        // ASSERT
        expect(fabFinder, findsOneWidget);
        
        final premiumFab = tester.widget<PremiumFAB>(fabFinder);
        expect(premiumFab.text, 'Ajouter des tâches');
        expect(premiumFab.icon, Icons.add);
        expect(premiumFab.heroTag, 'list_detail_fab');
      });

      testWidgets('should have premium glassmorphism design', (tester) async {
        // ARRANGE
        await tester.pumpWidget(TestAppWrapper(
          overrides: [
            listsControllerProvider.overrideWith((ref) => mockController),
            listByIdProvider(testList.id).overrideWith((ref) => testList),
          ],
          child: ListDetailPage(list: testList),
        ));

        // ACT
        await tester.pumpAndSettle();
        final fabFinder = find.byType(PremiumFAB);

        // ASSERT
        expect(fabFinder, findsOneWidget);
        
        final premiumFab = tester.widget<PremiumFAB>(fabFinder);
        expect(premiumFab.enableHaptics, isTrue);
        expect(premiumFab.elevation, 6.0);
      });

      testWidgets('should be positioned as floating action button', (tester) async {
        // ARRANGE
        await tester.pumpWidget(TestAppWrapper(
          overrides: [
            listsControllerProvider.overrideWith((ref) => mockController),
            listByIdProvider(testList.id).overrideWith((ref) => testList),
          ],
          child: ListDetailPage(list: testList),
        ));

        // ACT & ASSERT
        await tester.pumpAndSettle();
        expect(find.byType(PremiumFAB), findsOneWidget);
      });
    });

    group('Interaction Tests', () {
      testWidgets('should show bulk add dialog when pressed', (tester) async {
        // ARRANGE
        await tester.pumpWidget(TestAppWrapper(
          overrides: [
            listsControllerProvider.overrideWith((ref) => mockController),
            listByIdProvider(testList.id).overrideWith((ref) => testList),
          ],
          child: ListDetailPage(list: testList),
        ));

        // ACT
        final fabFinder = find.byType(PremiumFAB);
        await tester.tap(fabFinder);
        await tester.pumpAndSettle();

        // ASSERT
        expect(find.byType(BulkAddDialog), findsOneWidget);
        expect(find.text('Ajouter des éléments'), findsAtLeast(1));
      });

      testWidgets('should call controller when items are added', (tester) async {
        // ARRANGE
        await tester.pumpWidget(TestAppWrapper(
          overrides: [
            listsControllerProvider.overrideWith((ref) => mockController),
            listByIdProvider(testList.id).overrideWith((ref) => testList),
          ],
          child: ListDetailPage(list: testList),
        ));

        // ACT - Open dialog
        await tester.tap(find.byType(PremiumFAB));
        await tester.pumpAndSettle();

        // ACT - Add item
        await tester.enterText(find.byType(TextField), 'Test Item');
        await tester.tap(find.text('Ajouter'));
        await tester.pumpAndSettle();

        // ASSERT
        verify(mockController.addMultipleItemsToList(testList.id, ['Test Item'])).called(1);
      });

      testWidgets('should handle multiple items input', (tester) async {
        // ARRANGE
        await tester.pumpWidget(TestAppWrapper(
          overrides: [
            listsControllerProvider.overrideWith((ref) => mockController),
            listByIdProvider(testList.id).overrideWith((ref) => testList),
          ],
          child: ListDetailPage(list: testList),
        ));

        // ACT - Open dialog
        await tester.tap(find.byType(PremiumFAB));
        await tester.pumpAndSettle();

        // ACT - Switch to multiple mode
        await tester.tap(find.text('Multiple'));
        await tester.pumpAndSettle();

        // ACT - Add multiple items
        const multipleItems = 'Item 1\nItem 2\nItem 3';
        await tester.enterText(find.byType(TextField), multipleItems);
        await tester.tap(find.text('Ajouter'));
        await tester.pumpAndSettle();

        // ASSERT
        verify(mockController.addMultipleItemsToList(
          testList.id, 
          ['Item 1', 'Item 2', 'Item 3']
        )).called(1);
      });
    });

    group('Loading State Tests', () {
      testWidgets('should show loading state when adding items', (tester) async {
        // ARRANGE
        when(mockController.isLoading).thenReturn(true);
        
        await tester.pumpWidget(TestAppWrapper(
          overrides: [
            listsControllerProvider.overrideWith((ref) => mockController),
            listByIdProvider(testList.id).overrideWith((ref) => testList),
          ],
          child: ListDetailPage(list: testList),
        ));

        // ACT
        await tester.pumpAndSettle();
        final fabFinder = find.byType(PremiumFAB);

        // ASSERT
        expect(fabFinder, findsOneWidget);
        final premiumFab = tester.widget<PremiumFAB>(fabFinder);
        expect(premiumFab.isLoading, isFalse); // FAB itself shouldn't show loading, dialog should
      });
    });

    group('Error Handling Tests', () {
      testWidgets('should handle controller errors gracefully', (tester) async {
        // ARRANGE - Setup mock to throw exception
        when(mockController.addMultipleItemsToList(any, any))
            .thenThrow(Exception('Network error'));
        
        await tester.pumpWidget(TestAppWrapper(
          overrides: [
            listsControllerProvider.overrideWith((ref) => mockController),
            listByIdProvider(testList.id).overrideWith((ref) => testList),
          ],
          child: ListDetailPage(list: testList),
        ));

        // ACT - Open dialog and add item
        await tester.tap(find.byType(PremiumFAB));
        await tester.pumpAndSettle();
        
        await tester.enterText(find.byType(TextField), 'Test Item');
        await tester.tap(find.text('Ajouter'));
        await tester.pumpAndSettle();

        // ASSERT - Verify the method was called (error handling will be in controller)
        verify(mockController.addMultipleItemsToList(testList.id, ['Test Item'])).called(1);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should have proper semantics for add button', (tester) async {
        // ARRANGE
        await tester.pumpWidget(TestAppWrapper(
          overrides: [
            listsControllerProvider.overrideWith((ref) => mockController),
            listByIdProvider(testList.id).overrideWith((ref) => testList),
          ],
          child: ListDetailPage(list: testList),
        ));

        // ACT & ASSERT
        await tester.pumpAndSettle();
        
        // Should find the button
        expect(find.byType(PremiumFAB), findsOneWidget);
      });

      testWidgets('should support keyboard navigation', (tester) async {
        // ARRANGE
        await tester.pumpWidget(TestAppWrapper(
          overrides: [
            listsControllerProvider.overrideWith((ref) => mockController),
            listByIdProvider(testList.id).overrideWith((ref) => testList),
          ],
          child: ListDetailPage(list: testList),
        ));

        // ACT - Focus and activate with keyboard
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab); // Focus FAB
        await tester.sendKeyEvent(LogicalKeyboardKey.enter); // Activate
        await tester.pumpAndSettle();

        // ASSERT
        expect(find.byType(BulkAddDialog), findsOneWidget);
      });
    });

    group('Performance Tests', () {
      testWidgets('should not rebuild unnecessarily', (tester) async {
        // ARRANGE
        int buildCount = 0;
        
        await tester.pumpWidget(TestAppWrapper(
          overrides: [
            listsControllerProvider.overrideWith((ref) => mockController),
            listByIdProvider(testList.id).overrideWith((ref) => testList),
          ],
          child: Builder(
            builder: (context) {
              buildCount++;
              return ListDetailPage(list: testList);
            },
          ),
        ));

        // ACT - Initial build
        await tester.pumpAndSettle();
        final initialBuildCount = buildCount;

        // ACT - Interact with FAB
        await tester.tap(find.byType(PremiumFAB));
        await tester.pumpAndSettle();

        // ASSERT - Should not cause unnecessary rebuilds
        expect(buildCount, equals(initialBuildCount + 1)); // Only dialog should cause rebuild
      });
    });

    group('Visual Design Improvements Tests', () {
      testWidgets('should have adequate background opacity for visibility (TDD)', (tester) async {
        // ARRANGE - Test PremiumFAB directly to isolate design issues
        await tester.pumpWidget(TestAppWrapper(
          child: PremiumFAB(
            text: 'Ajouter des tâches',
            icon: Icons.add,
            onPressed: () {},
          ),
        ));

        // ACT
        await tester.pumpAndSettle();
        final fabFinder = find.byType(PremiumFAB);
        expect(fabFinder, findsOneWidget);

        // ASSERT - Background opacity should be at least 0.25 for visibility
        // This test will FAIL with current implementation (0.1 opacity)
        final containerFinder = find.descendant(
          of: fabFinder,
          matching: find.byType(Container),
        );
        
        expect(containerFinder, findsAtLeast(1));
        
        // Find the inner container with glassmorphism decoration
        final containers = tester.widgetList<Container>(containerFinder).toList();
        final glassContainer = containers.firstWhere((container) {
          final decoration = container.decoration as BoxDecoration?;
          return decoration?.color?.alpha != null;
        });
        
        final decoration = glassContainer.decoration as BoxDecoration;
        final backgroundOpacity = decoration.color!.alpha / 255.0;
        
        // TDD: This should fail with current 0.1 opacity
        expect(backgroundOpacity, greaterThanOrEqualTo(0.25), 
            reason: 'Background opacity should be at least 0.25 for proper visibility');
      });

      testWidgets('should have sufficient border opacity for contrast (TDD)', (tester) async {
        // ARRANGE - Test PremiumFAB directly
        await tester.pumpWidget(TestAppWrapper(
          child: PremiumFAB(
            text: 'Ajouter des tâches',
            icon: Icons.add,
            onPressed: () {},
          ),
        ));

        // ACT
        await tester.pumpAndSettle();
        final fabFinder = find.byType(PremiumFAB);
        expect(fabFinder, findsOneWidget);

        // ASSERT - Border opacity should be at least 0.4 for contrast
        // This test will FAIL with current implementation (0.2 opacity)
        final containerFinder = find.descendant(
          of: fabFinder,
          matching: find.byType(Container),
        );
        
        final containers = tester.widgetList<Container>(containerFinder).toList();
        final glassContainer = containers.firstWhere((container) {
          final decoration = container.decoration as BoxDecoration?;
          return decoration?.border != null;
        });
        
        final decoration = glassContainer.decoration as BoxDecoration;
        final border = decoration.border as Border;
        final borderOpacity = border.top.color.alpha / 255.0;
        
        // TDD: This should fail with current 0.2 opacity
        expect(borderOpacity, greaterThanOrEqualTo(0.4),
            reason: 'Border opacity should be at least 0.4 for sufficient contrast');
      });

      testWidgets('should display contextual text instead of generic message (TDD)', (tester) async {
        // ARRANGE - Test with different context scenarios
        await tester.pumpWidget(TestAppWrapper(
          child: PremiumFAB(
            text: 'Ajouter des tâches', // This is the current generic text
            icon: Icons.add,
            onPressed: () {},
          ),
        ));

        // ACT
        await tester.pumpAndSettle();
        final fabFinder = find.byType(PremiumFAB);
        expect(fabFinder, findsOneWidget);

        // ASSERT - Should show contextual text, not generic "Ajouter des tâches"
        // This test will FAIL with current implementation until we make text contextual
        final premiumFab = tester.widget<PremiumFAB>(fabFinder);
        
        // TDD: This will fail until we implement contextual text logic
        // The button should adapt its text based on context (list type, content state)
        expect(premiumFab.text, isNot(equals('Ajouter des tâches')),
            reason: 'Text should be contextual, not always generic "Ajouter des tâches"');
      });

      testWidgets('should have premium pulse effect with proper box shadow (TDD)', (tester) async {
        // ARRANGE - Test PremiumFAB directly
        await tester.pumpWidget(TestAppWrapper(
          child: PremiumFAB(
            text: 'Ajouter des tâches',
            icon: Icons.add,
            onPressed: () {},
          ),
        ));

        // ACT
        await tester.pumpAndSettle();
        final fabFinder = find.byType(PremiumFAB);
        expect(fabFinder, findsOneWidget);

        // Simulate hover state to trigger pulse effect
        final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: tester.getCenter(fabFinder));
        await tester.pump(const Duration(milliseconds: 150));
        await gesture.moveTo(tester.getCenter(fabFinder));
        await tester.pump(const Duration(milliseconds: 150));

        // ASSERT - Should have pulse effect with proper glow
        // This test ensures the premium design improvements are present
        final containerFinder = find.descendant(
          of: fabFinder,
          matching: find.byType(Container),
        );
        
        final outerContainer = tester.widgetList<Container>(containerFinder).first;
        final decoration = outerContainer.decoration as BoxDecoration;
        
        // Should have multiple box shadows including glow effect
        expect(decoration.boxShadow, isNotNull);
        expect(decoration.boxShadow!.length, greaterThanOrEqualTo(2),
            reason: 'Should have both regular shadow and glow effect');
        
        // Should have glow effect with significant blur radius
        final glowShadows = decoration.boxShadow!.where(
          (shadow) => shadow.blurRadius > 8, // Regular shadow is 8, glow should be higher
        ).toList();
        expect(glowShadows.isNotEmpty, isTrue,
            reason: 'Should have at least one glow shadow with blur radius > 8');
        
        // At least one shadow should have substantial blur for glow effect
        final hasSignificantGlow = glowShadows.any((shadow) => shadow.blurRadius >= 15);
        expect(hasSignificantGlow, isTrue,
            reason: 'Glow effect should have significant blur radius for premium look');
      });

      testWidgets('should adapt text based on list content state (TDD)', (tester) async {
        // ARRANGE - Test with empty list context 
        final emptyList = TestData.createTestList()..items.clear();
        
        await tester.pumpWidget(TestAppWrapper(
          overrides: [
            listsControllerProvider.overrideWith((ref) => mockController),
            listByIdProvider(testList.id).overrideWith((ref) => testList),
          ],
          child: ListDetailPage(list: emptyList),
        ));

        // ACT
        await tester.pumpAndSettle();
        final fabFinder = find.byType(PremiumFAB);
        expect(fabFinder, findsOneWidget);

        // ASSERT - Should adapt text for different states
        // This test will guide the adaptive text implementation
        final premiumFab = tester.widget<PremiumFAB>(fabFinder);
        
        // TDD: Check contextual text (should use contextualText if provided)
        final displayedText = premiumFab.contextualText ?? premiumFab.text;
        expect(
          displayedText.toLowerCase().contains('premier') ||
          displayedText.toLowerCase().contains('commencer') ||
          displayedText.toLowerCase().contains('créer') ||
          displayedText.contains('éléments'),
          isTrue,
          reason: 'Should have contextual text based on list state, got: $displayedText'
        );
      });

      testWidgets('should have enhanced visual hierarchy with improved contrast (TDD)', (tester) async {
        // ARRANGE - Test PremiumFAB directly
        await tester.pumpWidget(TestAppWrapper(
          child: PremiumFAB(
            text: 'Ajouter des tâches',
            icon: Icons.add,
            onPressed: () {},
          ),
        ));

        // ACT
        await tester.pumpAndSettle();
        final fabFinder = find.byType(PremiumFAB);
        expect(fabFinder, findsOneWidget);

        // ASSERT - Visual improvements should be present
        final textFinder = find.descendant(
          of: fabFinder,
          matching: find.byType(Text),
        );
        
        expect(textFinder, findsOneWidget);
        final textWidget = tester.widget<Text>(textFinder);
        final textStyle = textWidget.style!;
        
        // Should have proper font weight for readability
        expect(textStyle.fontWeight, greaterThanOrEqualTo(FontWeight.w600),
            reason: 'Text should have sufficient font weight for readability');
        
        // Should have proper letter spacing for premium look
        expect(textStyle.letterSpacing, greaterThan(0.3),
            reason: 'Should have adequate letter spacing for premium typography');
      });
    });
  });
}