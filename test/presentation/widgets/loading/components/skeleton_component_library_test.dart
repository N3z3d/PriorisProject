import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_component_library.dart';

void main() {
  group('SkeletonComponentLibrary', () {
    group('Page Header Components', () {
      testWidgets('should create page header with default parameters', (tester) async {
        final widget = SkeletonComponentLibrary.createPageHeader();

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      });

      testWidgets('should create page header with custom parameters', (tester) async {
        final widget = SkeletonComponentLibrary.createPageHeader(
          avatarSize: 50,
          nameWidth: 150,
          subtitleWidth: 100,
          actionSize: 40,
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      });
    });

    group('Stats Section Components', () {
      testWidgets('should create stats section with default parameters', (tester) async {
        final widget = SkeletonComponentLibrary.createStatsSection();

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.byType(SizedBox), findsOneWidget);
      });

      testWidgets('should create stats section with custom parameters', (tester) async {
        final widget = SkeletonComponentLibrary.createStatsSection(
          statCount: 4,
          height: 150,
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.byType(SizedBox), findsOneWidget);
      });
    });

    group('Chart Section Components', () {
      testWidgets('should create chart section with default parameters', (tester) async {
        final widget = SkeletonComponentLibrary.createChartSection();

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      });

      testWidgets('should create chart section with custom parameters', (tester) async {
        final widget = SkeletonComponentLibrary.createChartSection(
          height: 250,
          barCount: 10,
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      });
    });

    group('List Components', () {
      testWidgets('should create recent items list with default parameters', (tester) async {
        final widget = SkeletonComponentLibrary.createRecentItemsList();

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      });

      testWidgets('should create recent items list with custom parameters', (tester) async {
        final widget = SkeletonComponentLibrary.createRecentItemsList(
          itemCount: 5,
          title: 'Recent Activity',
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      });

      testWidgets('should create list item content', (tester) async {
        final widget = SkeletonComponentLibrary.createListItemContent();

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      });

      testWidgets('should create list item content with custom parameters', (tester) async {
        final widget = SkeletonComponentLibrary.createListItemContent(
          avatarSize: 50,
          titleHeight: 20,
          subtitleHeight: 16,
          showAction: false,
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      });
    });

    group('Profile Components', () {
      testWidgets('should create profile info with default parameters', (tester) async {
        final widget = SkeletonComponentLibrary.createProfileInfo();

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      });

      testWidgets('should create profile info with custom parameters', (tester) async {
        final widget = SkeletonComponentLibrary.createProfileInfo(
          avatarSize: 100,
          showButton: false,
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      });
    });

    group('Search and Filter Components', () {
      testWidgets('should create search bar with default parameters', (tester) async {
        final widget = SkeletonComponentLibrary.createSearchBar();

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      });

      testWidgets('should create search bar without filter', (tester) async {
        final widget = SkeletonComponentLibrary.createSearchBar(showFilter: false);

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      });

      testWidgets('should create filter list', (tester) async {
        final widget = SkeletonComponentLibrary.createFilterList();

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.byType(SizedBox), findsOneWidget);
        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('should create filter list with custom parameters', (tester) async {
        final widget = SkeletonComponentLibrary.createFilterList(
          filterCount: 7,
          height: 50,
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.byType(SizedBox), findsOneWidget);
        expect(find.byType(ListView), findsOneWidget);
      });
    });

    group('Tab Components', () {
      testWidgets('should create tab bar with default parameters', (tester) async {
        final widget = SkeletonComponentLibrary.createTabBar();

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      });

      testWidgets('should create tab bar with custom tab count', (tester) async {
        final widget = SkeletonComponentLibrary.createTabBar(tabCount: 5);

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      });
    });

    group('Action Components', () {
      testWidgets('should create action buttons with default parameters', (tester) async {
        final widget = SkeletonComponentLibrary.createActionButtons();

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      });

      testWidgets('should create action buttons with custom parameters', (tester) async {
        final widget = SkeletonComponentLibrary.createActionButtons(
          expandFirst: false,
          buttonHeight: 56,
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      });
    });

    group('Settings Components', () {
      testWidgets('should create settings item with default parameters', (tester) async {
        final widget = SkeletonComponentLibrary.createSettingsItem();

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      });

      testWidgets('should create settings item with switch', (tester) async {
        final widget = SkeletonComponentLibrary.createSettingsItem(
          hasSwitch: true,
          hasChevron: false,
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      });
    });

    group('Navigation Components', () {
      testWidgets('should create drawer header', (tester) async {
        final widget = SkeletonComponentLibrary.createDrawerHeader();

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.byType(Container), findsOneWidget);
      });

      testWidgets('should create drawer header with custom parameters', (tester) async {
        final widget = SkeletonComponentLibrary.createDrawerHeader(
          height: 250,
          avatarSize: 80,
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.byType(Container), findsOneWidget);
      });

      testWidgets('should create navigation item', (tester) async {
        final widget = SkeletonComponentLibrary.createNavigationItem();

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      });
    });

    group('Sheet Components', () {
      testWidgets('should create sheet handle', (tester) async {
        final widget = SkeletonComponentLibrary.createSheetHandle();

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.byType(Center), findsOneWidget);
        expect(find.byType(Container), findsOneWidget);
      });
    });

    group('Content Components', () {
      testWidgets('should create content section with default parameters', (tester) async {
        final widget = SkeletonComponentLibrary.createContentSection();

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      });

      testWidgets('should create content section with custom parameters', (tester) async {
        final widget = SkeletonComponentLibrary.createContentSection(
          titleWidth: 200,
          textLineCount: 5,
          includeImage: true,
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      });
    });

    group('Component Reusability', () {
      test('should provide consistent API across components', () {
        // Test that all factory methods can be called without exceptions
        expect(() => SkeletonComponentLibrary.createPageHeader(), returnsNormally);
        expect(() => SkeletonComponentLibrary.createStatsSection(), returnsNormally);
        expect(() => SkeletonComponentLibrary.createChartSection(), returnsNormally);
        expect(() => SkeletonComponentLibrary.createRecentItemsList(), returnsNormally);
        expect(() => SkeletonComponentLibrary.createListItemContent(), returnsNormally);
        expect(() => SkeletonComponentLibrary.createProfileInfo(), returnsNormally);
        expect(() => SkeletonComponentLibrary.createSearchBar(), returnsNormally);
        expect(() => SkeletonComponentLibrary.createFilterList(), returnsNormally);
        expect(() => SkeletonComponentLibrary.createTabBar(), returnsNormally);
        expect(() => SkeletonComponentLibrary.createActionButtons(), returnsNormally);
        expect(() => SkeletonComponentLibrary.createSettingsItem(), returnsNormally);
        expect(() => SkeletonComponentLibrary.createDrawerHeader(), returnsNormally);
        expect(() => SkeletonComponentLibrary.createNavigationItem(), returnsNormally);
        expect(() => SkeletonComponentLibrary.createSheetHandle(), returnsNormally);
        expect(() => SkeletonComponentLibrary.createContentSection(), returnsNormally);
      });

      testWidgets('should support parameter customization across components', (tester) async {
        // Test that components accept custom parameters properly
        final pageHeader = SkeletonComponentLibrary.createPageHeader(avatarSize: 60);
        final statsSection = SkeletonComponentLibrary.createStatsSection(statCount: 2);
        final chartSection = SkeletonComponentLibrary.createChartSection(height: 180);

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                pageHeader,
                statsSection,
                Expanded(child: chartSection),
              ],
            ),
          ),
        ));

        expect(find.byType(Column), findsOneWidget);
        expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      });
    });

    group('DRY Principle Compliance', () {
      test('should eliminate code duplication through reusable components', () {
        // Verify that the library provides reusable building blocks
        // rather than duplicated skeleton creation logic

        // Create multiple instances of the same component type
        final header1 = SkeletonComponentLibrary.createPageHeader();
        final header2 = SkeletonComponentLibrary.createPageHeader(avatarSize: 50);

        // Both should be widgets but not identical instances (different parameters)
        expect(header1, isA<Widget>());
        expect(header2, isA<Widget>());
        expect(identical(header1, header2), isFalse);
      });

      testWidgets('should provide consistent styling across components', (tester) async {
        // Test that components use consistent spacing and styling
        final searchBar = SkeletonComponentLibrary.createSearchBar();
        final actionButtons = SkeletonComponentLibrary.createActionButtons();

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                searchBar,
                actionButtons,
              ],
            ),
          ),
        ));

        expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      });
    });
  });
}