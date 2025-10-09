import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_component_library.dart';

void main() {
  group('SkeletonComponentLibrary smoke tests', () {
    testWidgets('builds page header', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonComponentLibrary.pageHeader(),
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('builds stats section with custom options', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkeletonComponentLibrary.statsSection(
              itemCount: 3,
              layout: StatsSectionLayout.compact,
            ),
          ),
        ),
      );

      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('builds recent list section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonComponentLibrary.recentList(itemCount: 4),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
