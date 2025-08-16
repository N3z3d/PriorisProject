import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/presentation/widgets/dialogs/list_item_form_dialog.dart';

void main() {
  group('ListItemFormDialog Tests', () {
    testWidgets('affiche le dialogue de création d\'item', (WidgetTester tester) async {
      // Arrange
      // Variable inutilisée supprimée
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await showDialog<ListItem>(
                  context: context,
                  builder: (context) => ListItemFormDialog(
                    listId: 'test-list-id',
                    onSubmit: (_) {},
                  ),
                );
              },
              child: const Text('Ouvrir'),
            ),
          ),
        ),
      ));

      // Act
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Ajouter un élément'), findsOneWidget);
      expect(find.text('Titre'), findsOneWidget);
      expect(find.text('Description (optionnel)'), findsOneWidget);
      expect(find.text('Catégorie (optionnel)'), findsOneWidget);
      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('Ajouter'), findsOneWidget);
    });

    testWidgets('crée un item avec les données saisies', (WidgetTester tester) async {
      // Arrange
      ListItem? result;
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await showDialog<ListItem>(
                  context: context,
                  builder: (context) => ListItemFormDialog(
                    listId: 'test-list-id',
                    onSubmit: (item) {
                      result = item;
                    },
                  ),
                );
              },
              child: const Text('Ouvrir'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(find.byType(TextFormField).at(0), 'Test Item');
      await tester.enterText(find.byType(TextFormField).at(1), 'Test Description');
      await tester.enterText(find.byType(TextFormField).at(2), 'Test Category');

      await tester.tap(find.text('Ajouter'));
      await tester.pumpAndSettle();

      // Assert
      expect(result, isNotNull);
      expect(result!.title, equals('Test Item'));
      expect(result!.description, equals('Test Description'));
      expect(result!.category, equals('Test Category'));
      expect(result!.eloScore, equals(1200.0)); // Score par défaut
      expect(result!.isCompleted, isFalse);
    });

    testWidgets('valide le titre obligatoire', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await showDialog<ListItem>(
                  context: context,
                  builder: (context) => ListItemFormDialog(
                    listId: 'test-list-id',
                    onSubmit: (item) {},
                  ),
                );
              },
              child: const Text('Ouvrir'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      // Act - Tenter de créer sans titre
      await tester.tap(find.text('Ajouter'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Le titre est obligatoire pour identifier cet élément'), findsOneWidget);
    });

    testWidgets('édite un item existant', (WidgetTester tester) async {
      // Arrange
      final existingItem = ListItem(
        id: 'test_id',
        listId: 'test-list-id',
        title: 'Item Existant',
        description: 'Description existante',
        category: 'Catégorie existante',
        eloScore: 1550.0,
        isCompleted: false,
        createdAt: DateTime.now(),
      );
      
      ListItem? result;
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await showDialog<ListItem>(
                  context: context,
                  builder: (context) => ListItemFormDialog(
                    listId: 'test-list-id',
                    initialItem: existingItem,
                    onSubmit: (item) {
                      result = item;
                    },
                  ),
                );
              },
              child: const Text('Ouvrir'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      // Assert - Vérifier que les champs sont pré-remplis
      expect(find.text('Modifier l\'élément'), findsOneWidget);
      expect(find.text('Item Existant'), findsOneWidget);
      expect(find.text('Description existante'), findsOneWidget);
      expect(find.text('Catégorie existante'), findsOneWidget);
      expect(find.text('Enregistrer'), findsOneWidget);

      // Act - Modifier le titre
      await tester.enterText(find.byType(TextFormField).at(0), 'Item Modifié');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      // Assert
      expect(result, isNotNull);
      expect(result!.id, equals('test_id'));
      expect(result!.title, equals('Item Modifié'));
      expect(result!.eloScore, equals(1550.0)); // Score préservé
    });

    testWidgets('gère l\'annulation', (WidgetTester tester) async {
      // Arrange
      ListItem? result;
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDialog<ListItem>(
                  context: context,
                  builder: (context) => ListItemFormDialog(
                    listId: 'test-list-id',
                    onSubmit: (item) {
                      result = item;
                    },
                  ),
                );
              },
              child: const Text('Ouvrir'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      // Assert
      expect(result, isNull);
    });

    testWidgets('valide la longueur maximale du titre', (WidgetTester tester) async {
      // Arrange
      final longTitle = 'a' * 250; // Titre trop long
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await showDialog<ListItem>(
                  context: context,
                  builder: (context) => ListItemFormDialog(
                    listId: 'test-list-id',
                    onSubmit: (item) {},
                  ),
                );
              },
              child: const Text('Ouvrir'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(find.byType(TextFormField).at(0), longTitle);
      await tester.tap(find.text('Ajouter'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('ne peut pas dépasser 200 caractères'), findsOneWidget);
    });

    testWidgets('permet la saisie de description et catégorie optionnelles', (WidgetTester tester) async {
      // Arrange
      ListItem? result;
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await showDialog<ListItem>(
                  context: context,
                  builder: (context) => ListItemFormDialog(
                    listId: 'test-list-id',
                    onSubmit: (item) {
                      result = item;
                    },
                  ),
                );
              },
              child: const Text('Ouvrir'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      // Act - Créer item avec seulement le titre
      await tester.enterText(find.byType(TextFormField).at(0), 'Titre seulement');
      await tester.tap(find.text('Ajouter'));
      await tester.pumpAndSettle();

      // Assert
      expect(result, isNotNull);
      expect(result!.title, equals('Titre seulement'));
      expect(result!.description, isNull);
      expect(result!.category, isNull);
    });
  });
}

