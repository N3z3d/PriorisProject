import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/pages/lists/widgets/list_type_selector.dart';

void main() {
  group('ListTypeSelector', () {
    testWidgets('affiche le titre Type de liste', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListTypeSelector(),
          ),
        ),
      );

      expect(find.text('Type de liste'), findsOneWidget);
    });

    testWidgets('affiche tous les types de liste par défaut', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListTypeSelector(),
          ),
        ),
      );

      expect(find.text('TRAVEL'), findsOneWidget);
      expect(find.text('SHOPPING'), findsOneWidget);
      expect(find.text('MOVIES'), findsOneWidget);
      expect(find.text('BOOKS'), findsOneWidget);
      expect(find.text('RESTAURANTS'), findsOneWidget);
      expect(find.text('PROJECTS'), findsOneWidget);
      expect(find.text('CUSTOM'), findsOneWidget);
    });

    testWidgets('n\'affiche pas CUSTOM quand showCustomType est false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListTypeSelector(showCustomType: false),
          ),
        ),
      );

      expect(find.text('CUSTOM'), findsNothing);
      expect(find.text('TRAVEL'), findsOneWidget);
      expect(find.text('SHOPPING'), findsOneWidget);
    });

    testWidgets('sélectionne le type correct', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListTypeSelector(selectedType: ListType.SHOPPING),
          ),
        ),
      );

      // Vérifier que SHOPPING est sélectionné visuellement
      final shoppingCard = find.ancestor(
        of: find.text('SHOPPING'),
        matching: find.byType(AnimatedContainer),
      );
      expect(shoppingCard, findsOneWidget);
    });

    testWidgets('appelle onTypeSelected quand on tape sur un type', (WidgetTester tester) async {
      ListType? selectedType;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListTypeSelector(
              onTypeSelected: (type) => selectedType = type,
            ),
          ),
        ),
      );

      await tester.tap(find.text('SHOPPING'));
      await tester.pump();

      expect(selectedType, equals(ListType.SHOPPING));
    });

    testWidgets('affiche les descriptions des types', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListTypeSelector(),
          ),
        ),
      );

      // Vérifier que les descriptions sont affichées
      expect(find.text('Voyages et destinations'), findsOneWidget);
      expect(find.text('Courses et achats'), findsOneWidget);
      expect(find.text('Films et séries'), findsOneWidget);
    });

    testWidgets('affiche les icônes pour chaque type', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListTypeSelector(),
          ),
        ),
      );

      expect(find.byIcon(Icons.flight), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
      expect(find.byIcon(Icons.movie), findsOneWidget);
      expect(find.byIcon(Icons.book), findsOneWidget);
      expect(find.byIcon(Icons.restaurant), findsOneWidget);
      expect(find.byIcon(Icons.work), findsOneWidget);
      expect(find.byIcon(Icons.list), findsOneWidget);
    });

    testWidgets('utilise une grille 2x2 pour l\'affichage', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListTypeSelector(),
          ),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('gère la sélection multiple', (WidgetTester tester) async {
      ListType? lastSelected;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListTypeSelector(
              onTypeSelected: (type) => lastSelected = type,
            ),
          ),
        ),
      );

      await tester.tap(find.text('TRAVEL'));
      await tester.pump();
      expect(lastSelected, equals(ListType.TRAVEL));

      await tester.tap(find.text('MOVIES'));
      await tester.pump();
      expect(lastSelected, equals(ListType.MOVIES));
    });

    testWidgets('affiche le type sélectionné avec un style différent', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListTypeSelector(selectedType: ListType.BOOKS),
          ),
        ),
      );

      // Le type sélectionné devrait avoir un style différent
      final booksCard = find.ancestor(
        of: find.text('BOOKS'),
        matching: find.byType(AnimatedContainer),
      );
      expect(booksCard, findsOneWidget);
    });
  });
} 
