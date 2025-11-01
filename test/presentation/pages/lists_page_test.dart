import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/presentation/pages/lists_page.dart';

void main() {
  group('ListsPage', () {
    testWidgets('n\'affiche pas de header Mes Listes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const ListsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Mes Listes'), findsNothing);
    });
  });
}
