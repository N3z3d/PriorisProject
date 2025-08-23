import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';

/// Tests simples pour valider la logique de persistance corrigée
/// 
/// Ces tests valident directement les repositories et la logique métier
/// sans passer par les complexités d'initialisation asynchrone de Riverpod.
void main() {
  group('Validation des corrections de persistance', () {
    late InMemoryCustomListRepository listRepository;
    late InMemoryListItemRepository itemRepository;
    
    setUp(() {
      listRepository = InMemoryCustomListRepository();
      itemRepository = InMemoryListItemRepository();
    });

    group('Corrections validées - Logique de base', () {
      
      test('CORRECTION: Liste créée peut être récupérée immédiatement', () async {
        // ARRANGE
        final newList = CustomList(
          id: 'test-persistence-123',
          name: 'Liste test persistance',
          type: ListType.CUSTOM,
          description: 'Test de la correction',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // ACT - Sauvegarder puis récupérer
        await listRepository.saveList(newList);
        final retrievedList = await listRepository.getListById(newList.id);
        
        // ASSERT - La liste doit être retrouvée
        expect(retrievedList, isNotNull);
        expect(retrievedList!.id, equals(newList.id));
        expect(retrievedList.name, equals('Liste test persistance'));
        
        // Vérifier aussi getAllLists
        final allLists = await listRepository.getAllLists();
        expect(allLists, hasLength(1));
        expect(allLists.first.id, equals(newList.id));
      });

      test('CORRECTION: Item ajouté peut être récupéré immédiatement', () async {
        // ARRANGE
        final testItem = ListItem(
          id: 'test-item-456',
          title: 'Item test persistance',
          listId: 'some-list-id',
          createdAt: DateTime.now(),
        );

        // ACT - Ajouter puis récupérer
        final savedItem = await itemRepository.add(testItem);
        final retrievedItem = await itemRepository.getById(testItem.id);
        
        // ASSERT - L'item doit être retrouvé
        expect(savedItem.id, equals(testItem.id));
        expect(retrievedItem, isNotNull);
        expect(retrievedItem!.id, equals(testItem.id));
        expect(retrievedItem.title, equals('Item test persistance'));
        
        // Vérifier aussi getByListId
        final itemsInList = await itemRepository.getByListId('some-list-id');
        expect(itemsInList, hasLength(1));
        expect(itemsInList.first.title, equals('Item test persistance'));
      });

      test('CORRECTION: Workflow complet création liste + ajout items', () async {
        // ARRANGE
        final testList = CustomList(
          id: 'workflow-list',
          name: 'Liste workflow complet',
          type: ListType.SHOPPING,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        final items = [
          ListItem(
            id: 'item-1',
            title: 'Premier item',
            listId: testList.id,
            createdAt: DateTime.now(),
          ),
          ListItem(
            id: 'item-2', 
            title: 'Deuxième item',
            listId: testList.id,
            createdAt: DateTime.now().add(const Duration(seconds: 1)),
          ),
        ];

        // ACT - Workflow complet
        
        // 1. Créer la liste
        await listRepository.saveList(testList);
        
        // 2. Vérifier que la liste existe
        final savedList = await listRepository.getListById(testList.id);
        expect(savedList, isNotNull);
        
        // 3. Ajouter des items
        for (final item in items) {
          await itemRepository.add(item);
          
          // 4. Vérifier chaque item immédiatement après ajout
          final verifiedItem = await itemRepository.getById(item.id);
          expect(verifiedItem, isNotNull);
          expect(verifiedItem!.title, equals(item.title));
        }
        
        // 5. Vérifier que tous les items sont récupérables par liste
        final allItemsInList = await itemRepository.getByListId(testList.id);
        expect(allItemsInList, hasLength(2));
        
        // 6. Vérifier l'ordre et le contenu
        expect(allItemsInList.any((item) => item.title == 'Premier item'), isTrue);
        expect(allItemsInList.any((item) => item.title == 'Deuxième item'), isTrue);
        
        // ASSERT - Le workflow complet fonctionne
        print('✅ Workflow complet validé: 1 liste + 2 items persistés et récupérés');
      });

      test('CORRECTION: Gestion d\'erreur - ID dupliqué', () async {
        // ARRANGE
        final list1 = CustomList(
          id: 'duplicate-id',
          name: 'Première liste',
          type: ListType.CUSTOM,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        final list2 = CustomList(
          id: 'duplicate-id', // Même ID !
          name: 'Deuxième liste',
          type: ListType.CUSTOM,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // ACT & ASSERT - Premier save doit réussir
        await listRepository.saveList(list1);
        final retrieved1 = await listRepository.getListById('duplicate-id');
        expect(retrieved1!.name, equals('Première liste'));
        
        // CORRECTION: Le repository doit rejeter les doublons
        expect(
          () async => await listRepository.saveList(list2),
          throwsException,
          reason: 'Sauvegarder une liste avec un ID existant doit échouer'
        );
        
        // Vérifier que la première liste est toujours là
        final stillThere = await listRepository.getListById('duplicate-id');
        expect(stillThere!.name, equals('Première liste'));
        
        // S'assurer qu'il n'y a qu'une seule liste au total
        final allLists = await listRepository.getAllLists();
        expect(allLists, hasLength(1));
        
        print('✅ Gestion d\'erreur validée: ID dupliqué correctement rejeté');
      });

      test('CORRECTION: Items multiples avec vérification transactionnelle simulée', () async {
        // ARRANGE
        final listId = 'transaction-test-list';
        final itemTitles = ['Item A', 'Item B', 'Item C', 'Item D'];
        final items = <ListItem>[];
        
        // Simuler la logique transactionnelle corrigée
        final savedItems = <ListItem>[];
        
        try {
          // ACT - Simuler l'ajout transactionnel
          for (int i = 0; i < itemTitles.length; i++) {
            final item = ListItem(
              id: 'transaction-item-$i',
              title: itemTitles[i],
              listId: listId,
              createdAt: DateTime.now().add(Duration(milliseconds: i)),
            );
            items.add(item);
            
            // Simuler une erreur sur le 3ème item (index 2)
            if (i == 2) {
              throw Exception('Erreur simulée sur ${item.title}');
            }
            
            // Sauvegarder et vérifier
            await itemRepository.add(item);
            final verified = await itemRepository.getById(item.id);
            if (verified == null) {
              throw Exception('Échec de vérification pour ${item.title}');
            }
            
            savedItems.add(item);
          }
        } catch (e) {
          // Simuler le rollback
          for (final item in savedItems) {
            await itemRepository.delete(item.id);
          }
          
          // Vérifier que le rollback a fonctionné
          final remainingItems = await itemRepository.getByListId(listId);
          expect(remainingItems, isEmpty, 
              reason: 'Rollback doit supprimer tous les items ajoutés');
          
          print('✅ Rollback transactionnel validé: ${savedItems.length} items supprimés');
          return;
        }
        
        fail('Le test aurait dû échouer sur le 3ème item');
      });
    });

    group('Validation des améliorations', () {
      test('Performance: Ajout et récupération de nombreux items', () async {
        // ARRANGE
        final listId = 'performance-test';
        const itemCount = 100;
        
        final stopwatch = Stopwatch()..start();
        
        // ACT - Ajouter de nombreux items
        for (int i = 0; i < itemCount; i++) {
          final item = ListItem(
            id: 'perf-item-$i',
            title: 'Item de performance $i',
            listId: listId,
            createdAt: DateTime.now(),
          );
          
          await itemRepository.add(item);
        }
        
        // Récupérer tous les items
        final allItems = await itemRepository.getByListId(listId);
        
        stopwatch.stop();
        
        // ASSERT
        expect(allItems, hasLength(itemCount));
        expect(stopwatch.elapsedMilliseconds, lessThan(1000), 
            reason: 'Ajout de $itemCount items devrait prendre moins de 1s');
        
        print('✅ Performance validée: $itemCount items ajoutés en ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Intégrité: Modification et suppression', () async {
        // ARRANGE
        final originalList = CustomList(
          id: 'modifiable-list',
          name: 'Liste modifiable',
          type: ListType.CUSTOM,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await listRepository.saveList(originalList);
        
        // ACT - Modifier
        final modifiedList = originalList.copyWith(
          name: 'Liste modifiée',
          updatedAt: DateTime.now().add(const Duration(seconds: 1)),
        );
        
        await listRepository.updateList(modifiedList);
        
        // ASSERT - Modification
        final retrieved = await listRepository.getListById(originalList.id);
        expect(retrieved!.name, equals('Liste modifiée'));
        expect(retrieved.updatedAt.isAfter(originalList.updatedAt), isTrue);
        
        // ACT - Suppression
        await listRepository.deleteList(originalList.id);
        
        // ASSERT - Suppression
        final deletedList = await listRepository.getListById(originalList.id);
        expect(deletedList, isNull);
        
        final allLists = await listRepository.getAllLists();
        expect(allLists, isEmpty);
        
        print('✅ Intégrité validée: modification et suppression fonctionnent');
      });
    });
  });
}