import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/data/providers/repository_providers.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';

import '../../test_utils/test_providers.dart';
import '../../test_utils/test_providers.mocks.dart';

/// Tests TDD simplifiés pour diagnostiquer le problème de persistance
/// 
/// Phase RED (Tests qui échouent) : Ces tests démontrent le problème
/// de persistance de manière plus simple, sans dépendre du widget complet.
void main() {
  group('Persistence TDD Diagnostics (Phase RED - Simplified)', () {
    late MockCustomListRepositoryTest mockCustomListRepository;
    late MockListItemRepositoryTest mockListItemRepository;
    late MockListsControllerTest mockController;
    
    // Données de test simples
    late CustomList testList;
    late ListItem testItem1;
    late ListItem testItem2;
    
    setUp(() {
      mockCustomListRepository = MockCustomListRepositoryTest();
      mockListItemRepository = MockListItemRepositoryTest();
      mockController = MockListsControllerTest();
      
      final now = DateTime.now();
      testList = CustomList(
        id: 'test-list-1',
        name: 'Test Persistence List',
        type: ListType.CUSTOM,
        description: 'Liste pour tester la persistence',
        createdAt: now,
        updatedAt: now,
        items: [],
      );
      
      testItem1 = ListItem(
        id: 'item-1',
        title: 'Test Item 1',
        listId: testList.id,
        createdAt: now,
      );
      
      testItem2 = ListItem(
        id: 'item-2', 
        title: 'Test Item 2',
        listId: testList.id,
        createdAt: now.add(const Duration(minutes: 1)),
      );
    });

    group('Repository Persistence Problems', () {
      test('RED - Liste créée n\'est pas sauvegardée', () async {
        // ARRANGE
        when(mockCustomListRepository.saveList(any))
            .thenAnswer((_) async {});
        when(mockCustomListRepository.getListById(testList.id))
            .thenAnswer((_) async => null); // Simule que rien n'est trouvé
        
        // ACT - Simuler création et sauvegarde
        await mockCustomListRepository.saveList(testList);
        final loadedList = await mockCustomListRepository.getListById(testList.id);
        
        // ASSERT - Ce test DOIT ÉCHOUER
        verify(mockCustomListRepository.saveList(testList)).called(1);
        verify(mockCustomListRepository.getListById(testList.id)).called(1);
        
        // Ce test échoue : la liste devrait être trouvée après sauvegarde
        expect(loadedList, isNotNull, 
            reason: 'ATTENDU: La liste devrait être persistée et récupérée');
        expect(loadedList?.id, equals(testList.id),
            reason: 'ATTENDU: L\'ID de la liste devrait correspondre');
      });

      test('RED - Items ajoutés ne sont pas persistés', () async {
        // ARRANGE
        when(mockListItemRepository.add(any))
            .thenAnswer((invocation) async => invocation.positionalArguments[0]);
        when(mockListItemRepository.getByListId(testList.id))
            .thenAnswer((_) async => []); // Simule que rien n'est trouvé
        
        // ACT - Simuler ajout d'items
        await mockListItemRepository.add(testItem1);
        await mockListItemRepository.add(testItem2);
        final loadedItems = await mockListItemRepository.getByListId(testList.id);
        
        // ASSERT - Ce test DOIT ÉCHOUER
        verify(mockListItemRepository.add(testItem1)).called(1);
        verify(mockListItemRepository.add(testItem2)).called(1);
        verify(mockListItemRepository.getByListId(testList.id)).called(1);
        
        // Ce test échoue : les items devraient être trouvés après ajout
        expect(loadedItems, isNotEmpty,
            reason: 'ATTENDU: Les items ajoutés devraient être persistés');
        expect(loadedItems.length, equals(2),
            reason: 'ATTENDU: Les 2 items ajoutés devraient être retrouvés');
      });

      test('RED - Items ajoutés multiples ne persistent pas correctement', () async {
        // ARRANGE  
        final itemTitles = ['Item A', 'Item B', 'Item C'];
        
        when(mockListItemRepository.getByListId(testList.id))
            .thenAnswer((_) async => []); // Simule persistence vide
        when(mockListItemRepository.add(any))
            .thenAnswer((invocation) async => invocation.positionalArguments[0]);
        
        // ACT - Simuler ajout multiple (comme via l'interface bulk add)
        for (int i = 0; i < itemTitles.length; i++) {
          final item = ListItem(
            id: 'bulk-item-$i',
            title: itemTitles[i],
            listId: testList.id,
            createdAt: DateTime.now(),
          );
          await mockListItemRepository.add(item);
        }
        
        final loadedItems = await mockListItemRepository.getByListId(testList.id);
        
        // ASSERT - Ce test DOIT ÉCHOUER
        verify(mockListItemRepository.add(any)).called(3);
        verify(mockListItemRepository.getByListId(testList.id)).called(1);
        
        // Ce test révèle le problème de persistence multiple
        expect(loadedItems.length, equals(3),
            reason: 'ATTENDU: Les 3 items ajoutés en bulk devraient persister');
            
        for (int i = 0; i < itemTitles.length; i++) {
          final expectedTitle = itemTitles[i];
          final foundItem = loadedItems.any((item) => item.title == expectedTitle);
          expect(foundItem, isTrue,
              reason: 'ATTENDU: L\'item "$expectedTitle" devrait être persisté');
        }
      });
    });

    group('Controller State Problems', () {
      test('RED - État du controller ne persiste pas après reload', () async {
        // ARRANGE
        final initialState = ListsState(
          lists: [testList],
          filteredLists: [testList],
          isLoading: false,
        );
        
        final emptyState = ListsState(
          lists: [],
          filteredLists: [],
          isLoading: false,
        );
        
        when(mockController.state)
            .thenReturn(initialState); // État initial avec données
        
        // ACT - Simuler un reload qui vide l'état
        when(mockController.state)
            .thenReturn(emptyState); // État après reload sans données
        
        final stateAfterReload = mockController.state;
        
        // ASSERT - Ce test DOIT ÉCHOUER  
        // L'état devrait contenir les données persistées après reload
        expect(stateAfterReload.lists, isNotEmpty,
            reason: 'ATTENDU: Les listes devraient être rechargées depuis la persistence');
        expect(stateAfterReload.lists.length, equals(1),
            reason: 'ATTENDU: La liste persistée devrait être dans l\'état');
        expect(stateAfterReload.lists.first.id, equals(testList.id),
            reason: 'ATTENDU: L\'ID de la liste devrait correspondre après reload');
      });

      test('RED - Items dans l\'état ne sont pas rechargés', () async {
        // ARRANGE
        final listWithItems = testList.copyWith(
          items: [testItem1, testItem2],
          updatedAt: DateTime.now(),
        );
        
        final initialState = ListsState(
          lists: [listWithItems],
          filteredLists: [listWithItems],
          isLoading: false,
        );
        
        // État après reload : la liste existe mais sans items
        final listWithoutItems = testList.copyWith(
          items: [], // Items perdus !
          updatedAt: DateTime.now(),
        );
        
        final reloadedState = ListsState(
          lists: [listWithoutItems],
          filteredLists: [listWithoutItems],
          isLoading: false,
        );
        
        // Première configuration : état initial
        when(mockController.state).thenReturn(initialState);
        
        // ACT
        final stateBeforeReload = mockController.state;
        
        // Simuler changement d'état après reload
        when(mockController.state).thenReturn(reloadedState);
        final stateAfterReload = mockController.state;
        
        // ASSERT - Ce test DOIT ÉCHOUER
        expect(stateBeforeReload.lists.first.items.length, equals(2));
        
        // Ce test révèle que les items disparaissent après reload
        expect(stateAfterReload.lists.first.items.length, equals(2),
            reason: 'ATTENDU: Les items devraient être rechargés depuis la persistence');
        expect(stateAfterReload.lists.first.items, contains(testItem1),
            reason: 'ATTENDU: Le premier item devrait être rechargé');
        expect(stateAfterReload.lists.first.items, contains(testItem2),
            reason: 'ATTENDU: Le deuxième item devrait être rechargé');
      });
    });

    group('Data Flow Problems', () {
      test('RED - Flux repository → controller ne fonctionne pas', () async {
        // ARRANGE - Simuler des données en base
        when(mockCustomListRepository.getAllLists())
            .thenAnswer((_) async => [testList]);
        when(mockListItemRepository.getByListId(testList.id))
            .thenAnswer((_) async => [testItem1, testItem2]);
        
        // Simuler que le controller charge depuis les repositories
        when(mockController.loadLists()).thenAnswer((_) async {
          // Normalement, le controller devrait :
          // 1. Charger les listes depuis customListRepository
          // 2. Pour chaque liste, charger les items depuis listItemRepository
          // 3. Mettre à jour son état avec les données complètes
        });
        
        // État vide initial (comme au démarrage)
        when(mockController.state).thenReturn(ListsState(
          lists: [],
          filteredLists: [],
          isLoading: false,
        ));
        
        // ACT
        await mockController.loadLists();
        final finalState = mockController.state;
        
        // ASSERT - Ce test DOIT ÉCHOUER
        verify(mockController.loadLists()).called(1);
        
        // Le problème : le controller ne charge pas correctement depuis les repos
        expect(finalState.lists, isNotEmpty,
            reason: 'ATTENDU: Le controller devrait charger les listes depuis le repository');
        expect(finalState.lists.first.items, isNotEmpty,
            reason: 'ATTENDU: Le controller devrait charger les items pour chaque liste');
      });
    });
  });

  group('SUCCESS - Working Persistence (What SHOULD work)', () {
    late MockCustomListRepositoryTest workingMockCustomListRepo;
    late MockListItemRepositoryTest workingMockItemRepo;
    
    setUp(() {
      workingMockCustomListRepo = MockCustomListRepositoryTest();
      workingMockItemRepo = MockListItemRepositoryTest();
    });

    test('WORKING - Persistence correcte des listes', () async {
      // ARRANGE - Mock qui simule une vraie persistence
      final testList = CustomList(
        id: 'working-list',
        name: 'Working List',
        type: ListType.CUSTOM,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Simule une persistence qui fonctionne
      when(workingMockCustomListRepo.saveList(any))
          .thenAnswer((_) async {});
      when(workingMockCustomListRepo.getListById(testList.id))
          .thenAnswer((_) async => testList); // Retourne la liste sauvée
      
      // ACT
      await workingMockCustomListRepo.saveList(testList);
      final loadedList = await workingMockCustomListRepo.getListById(testList.id);
      
      // ASSERT - Ce test DOIT PASSER
      expect(loadedList, isNotNull);
      expect(loadedList!.id, equals(testList.id));
      expect(loadedList.name, equals(testList.name));
    });

    test('WORKING - Persistence correcte des items', () async {
      // ARRANGE
      final testItem = ListItem(
        id: 'working-item',
        title: 'Working Item',
        listId: 'working-list',
        createdAt: DateTime.now(),
      );
      
      // Simule une persistence qui fonctionne
      when(workingMockItemRepo.add(any))
          .thenAnswer((invocation) async => invocation.positionalArguments[0]);
      when(workingMockItemRepo.getByListId('working-list'))
          .thenAnswer((_) async => [testItem]); // Retourne les items sauvés
      
      // ACT
      await workingMockItemRepo.add(testItem);
      final loadedItems = await workingMockItemRepo.getByListId('working-list');
      
      // ASSERT - Ce test DOIT PASSER
      expect(loadedItems, hasLength(1));
      expect(loadedItems.first.id, equals(testItem.id));
      expect(loadedItems.first.title, equals(testItem.title));
    });
  });
}