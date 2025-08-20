import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/pages/list_detail_page.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';

/// Test de validation de la réactivité de ListDetailPage
/// 
/// Ce test vérifie que la page se met à jour automatiquement
/// quand des éléments sont ajoutés/modifiés/supprimés.
void main() {
  group('ListDetailPage Réactivité', () {
    late ProviderContainer container;
    late CustomList testList;

    setUp(() {
      container = ProviderContainer();
      testList = CustomList(
        id: 'test-list-id',
        name: 'Test List',
        type: ListType.CUSTOM,
        items: [
          ListItem(
            id: 'item-1',
            title: 'Item 1',
            listId: 'test-list-id',
            createdAt: DateTime.now(),
          ),
          ListItem(
            id: 'item-2', 
            title: 'Item 2',
            listId: 'test-list-id',
            createdAt: DateTime.now(),
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('Provider retourne la liste correcte par ID', (tester) async {
      // Setup: Ajouter la liste au state
      final controller = container.read(listsControllerProvider.notifier);
      await controller.createList(testList);

      // Test: Vérifier que le provider retourne la liste
      final foundList = container.read(listByIdProvider('test-list-id'));
      
      expect(foundList, isNotNull);
      expect(foundList?.id, equals('test-list-id'));
      expect(foundList?.name, equals('Test List'));
      expect(foundList?.items.length, equals(2));
    });

    testWidgets('Provider se met à jour quand un élément est ajouté', (tester) async {
      // Setup: Ajouter la liste au state
      final controller = container.read(listsControllerProvider.notifier);
      await controller.createList(testList);

      // Vérifier l'état initial
      var foundList = container.read(listByIdProvider('test-list-id'));
      expect(foundList?.items.length, equals(2));

      // Action: Ajouter un nouvel élément
      final newItem = ListItem(
        id: 'item-3',
        title: 'Item 3',
        listId: 'test-list-id',
        createdAt: DateTime.now(),
      );
      await controller.addItemToList('test-list-id', newItem);

      // Vérification: Le provider doit retourner la liste mise à jour
      foundList = container.read(listByIdProvider('test-list-id'));
      expect(foundList?.items.length, equals(3));
      expect(foundList?.items.any((item) => item.id == 'item-3'), isTrue);
    });

    testWidgets('Provider se met à jour quand un élément est modifié', (tester) async {
      // Setup: Ajouter la liste au state
      final controller = container.read(listsControllerProvider.notifier);
      await controller.createList(testList);

      // Action: Modifier un élément existant
      final updatedItem = testList.items.first.copyWith(
        title: 'Item 1 Modified',
        isCompleted: true,
      );
      await controller.updateListItem('test-list-id', updatedItem);

      // Vérification: Le provider doit retourner la liste mise à jour
      final foundList = container.read(listByIdProvider('test-list-id'));
      final modifiedItem = foundList?.items.firstWhere((item) => item.id == 'item-1');
      
      expect(modifiedItem?.title, equals('Item 1 Modified'));
      expect(modifiedItem?.isCompleted, isTrue);
    });

    testWidgets('Provider se met à jour quand un élément est supprimé', (tester) async {
      // Setup: Ajouter la liste au state
      final controller = container.read(listsControllerProvider.notifier);
      await controller.createList(testList);

      // Vérifier l'état initial
      var foundList = container.read(listByIdProvider('test-list-id'));
      expect(foundList?.items.length, equals(2));

      // Action: Supprimer un élément
      await controller.removeItemFromList('test-list-id', 'item-1');

      // Vérification: Le provider doit retourner la liste mise à jour
      foundList = container.read(listByIdProvider('test-list-id'));
      expect(foundList?.items.length, equals(1));
      expect(foundList?.items.any((item) => item.id == 'item-1'), isFalse);
    });

    testWidgets('Provider retourne null pour une liste inexistante', (tester) async {
      // Test: Rechercher une liste qui n'existe pas
      final foundList = container.read(listByIdProvider('inexistent-id'));
      
      expect(foundList, isNull);
    });

    testWidgets('ListDetailPage gère correctement une liste qui n\'existe plus', (tester) async {
      // Ce test simule le cas où une liste est supprimée pendant qu'on la consulte
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Override pour retourner null (liste supprimée)
            listByIdProvider('test-list-id').overrideWith((ref) => null),
          ],
          child: MaterialApp(
            home: ListDetailPage(list: testList),
          ),
        ),
      );

      await tester.pump();

      // Vérifier qu'un indicateur de chargement est affiché
      // (en attendant la navigation)
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}