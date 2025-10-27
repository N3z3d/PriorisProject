import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/pages/lists/widgets/lists_overview_banner.dart';

void main() {
  testWidgets('affiche les totaux de listes et d\'elements', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ListsOverviewBanner(
            totalLists: 3,
            totalItems: 12,
          ),
        ),
      ),
    );

    expect(find.textContaining('3 listes'), findsOneWidget);
    expect(find.textContaining('12 elements'), findsOneWidget);
    expect(find.byIcon(Icons.view_list), findsOneWidget);
  });
}
