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

/// Tests TDD pour reproduire le BUG de perte de données lors de la création de listes
/// 
/// Phase RED : Ces tests reproduisent exactement le problème signalé par l'utilisateur
/// 
/// PROBLÈME IDENTIFIÉ :
/// 1. Les listes créées ne persistent pas après un redémarrage/refresh
/// 2. Les items ajoutés à une liste disparaissent après refresh  
/// 3. Problème de synchronisation entre l'état local et la persistance Supabase
/// 4. Gestion d'erreurs insuffisante lors des opérations de sauvegarde
void main() {
  group('BUG REPRODUCTION - Perte de données lors de création de listes', () {
    late MockCustomListRepositoryTest mockCustomListRepository;
    late MockListItemRepositoryTest mockListItemRepository;
    late ProviderContainer container;
    
    setUp(() {
      mockCustomListRepository = MockCustomListRepositoryTest();
      mockListItemRepository = MockListItemRepositoryTest();
      
      container = ProviderContainer(
        overrides: [
          customListRepositoryAsyncProvider.overrideWith(
            (ref) => Future.value(mockCustomListRepository),
          ),
          listItemRepositoryAsyncProvider.overrideWith(
            (ref) => Future.value(mockListItemRepository),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('RED PHASE - Tests qui échouent (reproduisent le bug)', () {
      
      test('BUG 1: Liste créée disparaît après restart - EXPECTED TO FAIL', () async {
        // ARRANGE
        final newList = CustomList(
          id: 'new-list-123',
          name: 'Ma nouvelle liste',
          type: ListType.CUSTOM,
          description: 'Liste qui devrait persister',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Mock: Simuler qu'au démarrage, aucune liste n'existe
        when(mockCustomListRepository.getAllLists())
            .thenAnswer((_) async => []);
        
        // Mock: Simuler la sauvegarde réussie
        when(mockCustomListRepository.saveList(any))
            .thenAnswer((_) async => {});
        
        // ACT - Phase 1: Démarrage avec liste vide
        final controller = container.read(listsControllerProvider.notifier);
        await controller.loadLists();
        
        var state = container.read(listsControllerProvider);
        expect(state.lists, isEmpty, reason: 'Au démarrage, aucune liste');
        
        // ACT - Phase 2: Créer une nouvelle liste
        await controller.createList(newList);
        
        state = container.read(listsControllerProvider);
        expect(state.lists, hasLength(1), reason: 'Liste ajoutée à l\'état');
        expect(state.lists.first.name, equals('Ma nouvelle liste'));
        
        // Vérifier que saveList a été appelé
        verify(mockCustomListRepository.saveList(any)).called(1);
        
        // ACT - Phase 3: Simuler un redémarrage (recharger tout)
        // PROBLÈME: Après sauvegarde, la liste devrait être récupérée
        // Mais on simule que getAllLists() retourne encore une liste vide
        // C'est exactement le bug rapporté !
        when(mockCustomListRepository.getAllLists())
            .thenAnswer((_) async => []); // BUG: devrait retourner [newList]
        
        // Nouveau chargement (simule redémarrage app)
        await controller.loadLists();
        
        // ASSERT - CE TEST DOIT ÉCHOUER : la liste a disparu !
        state = container.read(listsControllerProvider);
        expect(state.lists, hasLength(1), 
            reason: 'ÉCHEC ATTENDU: La liste devrait persister après redémarrage');
      });

      test('BUG 2: Items ajoutés disparaissent après refresh - EXPECTED TO FAIL', () async {
        // ARRANGE
        final existingList = CustomList(
          id: 'existing-list-456',
          name: 'Liste existante',
          type: ListType.SHOPPING,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        final newItem = ListItem(
          id: 'new-item-789',
          title: 'Nouvel élément important',
          listId: existingList.id,
          createdAt: DateTime.now(),
        );

        // Mock: Liste existante au démarrage
        when(mockCustomListRepository.getAllLists())
            .thenAnswer((_) async => [existingList]);
        when(mockListItemRepository.getByListId(existingList.id))
            .thenAnswer((_) async => []); // Pas d'items au démarrage
        
        // Mock: Ajout d'item réussit
        when(mockListItemRepository.add(any))
            .thenAnswer((invocation) async => invocation.positionalArguments[0] as ListItem);
        
        // ACT - Phase 1: Chargement initial
        final controller = container.read(listsControllerProvider.notifier);
        await controller.loadLists();
        
        var state = container.read(listsControllerProvider);
        expect(state.lists, hasLength(1));
        expect(state.lists.first.items, isEmpty);
        
        // ACT - Phase 2: Ajouter un item
        await controller.addItemToList(existingList.id, newItem);
        
        state = container.read(listsControllerProvider);
        expect(state.lists.first.items, hasLength(1));
        expect(state.lists.first.items.first.title, equals('Nouvel élément important'));
        
        // Vérifier que add() a été appelé
        verify(mockListItemRepository.add(any)).called(1);
        
        // ACT - Phase 3: Simuler refresh (recharger)
        // PROBLÈME: getByListId devrait retourner le nouvel item
        // Mais on simule qu'il retourne toujours vide
        when(mockListItemRepository.getByListId(existingList.id))
            .thenAnswer((_) async => []); // BUG: devrait retourner [newItem]
        
        // Recharger la liste
        await controller.loadLists();
        
        // ASSERT - CE TEST DOIT ÉCHOUER : l'item a disparu !
        state = container.read(listsControllerProvider);
        expect(state.lists.first.items, hasLength(1),
            reason: 'ÉCHEC ATTENDU: L\'item devrait persister après refresh');
      });
      
      test('BUG 3: Erreur de sauvegarde non gérée - EXPECTED TO FAIL', () async {
        // ARRANGE
        final newList = CustomList(
          id: 'fail-list-999',
          name: 'Liste qui va échouer',
          type: ListType.CUSTOM,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Mock: Simuler une erreur de sauvegarde
        when(mockCustomListRepository.saveList(any))
            .thenThrow(Exception('Erreur réseau Supabase'));
        
        when(mockCustomListRepository.getAllLists())
            .thenAnswer((_) async => []);
        
        // ACT
        final controller = container.read(listsControllerProvider.notifier);
        await controller.loadLists();
        
        // Tentative de création qui va échouer
        await controller.createList(newList);
        
        // ASSERT - L'état devrait refléter l'erreur
        final state = container.read(listsControllerProvider);
        
        // PROBLÈME: Si l'erreur n'est pas gérée, l'état peut être incohérent
        expect(state.error, isNotNull, 
            reason: 'Une erreur de sauvegarde devrait être signalée');
        
        // La liste ne devrait PAS être dans l'état si la sauvegarde a échoué
        expect(state.lists, isEmpty,
            reason: 'ÉCHEC ATTENDU: Liste ne devrait pas être en état si sauvegarde échoue');
      });

      test('BUG 4: Bulk add avec échec partiel - EXPECTED TO FAIL', () async {
        // ARRANGE
        final existingList = CustomList(
          id: 'bulk-list-111',
          name: 'Liste pour bulk add',
          type: ListType.CUSTOM,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        final itemTitles = ['Item 1', 'Item 2', 'Item 3', 'Item 4'];

        when(mockCustomListRepository.getAllLists())
            .thenAnswer((_) async => [existingList]);
        when(mockListItemRepository.getByListId(existingList.id))
            .thenAnswer((_) async => []);
        
        // Mock: Simuler qu'un des ajouts échoue (le 3ème)
        var callCount = 0;
        when(mockListItemRepository.add(any)).thenAnswer((invocation) async {
          callCount++;
          if (callCount == 3) {
            throw Exception('Échec sauvegarde item 3');
          }
          return invocation.positionalArguments[0] as ListItem;
        });
        
        // ACT
        final controller = container.read(listsControllerProvider.notifier);
        await controller.loadLists();
        
        // Bulk add qui va partiellement échouer
        await controller.addMultipleItemsToList(existingList.id, itemTitles);
        
        // ASSERT
        final state = container.read(listsControllerProvider);
        
        // PROBLÈME: Que se passe-t-il si seulement certains items sont sauvegardés ?
        // L'état local peut être incohérent avec la persistance
        expect(state.lists.first.items.length, lessThan(4),
            reason: 'ÉCHEC ATTENDU: Tous les items ne devraient pas être là si échec partiel');
        
        expect(state.error, isNotNull,
            reason: 'Une erreur devrait être reportée en cas d\'échec partiel');
      });
    });

    group('Diagnostics - État du système', () {
      test('DIAGNOSTIC: Vérifier le flux de données complet', () async {
        // Ce test diagnostique le flux complet de données
        // pour identifier où la perte se produit
        
        final testList = CustomList(
          id: 'diagnostic-flow',
          name: 'Test Flow',
          type: ListType.CUSTOM,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // Tracer chaque étape
        when(mockCustomListRepository.getAllLists())
            .thenAnswer((_) async {
              print('📊 DIAGNOSTIC: getAllLists() appelé');
              return [];
            });
        
        when(mockCustomListRepository.saveList(any))
            .thenAnswer((invocation) async {
              final list = invocation.positionalArguments[0] as CustomList;
              print('📊 DIAGNOSTIC: saveList() appelé pour ${list.name}');
            });
        
        final controller = container.read(listsControllerProvider.notifier);
        
        print('📊 DIAGNOSTIC: Démarrage du flux');
        await controller.loadLists();
        
        print('📊 DIAGNOSTIC: Création de la liste');
        await controller.createList(testList);
        
        print('📊 DIAGNOSTIC: Fin du flux');
        
        // Vérifier que les méthodes ont été appelées dans le bon ordre
        verifyInOrder([
          mockCustomListRepository.getAllLists(),
          mockCustomListRepository.saveList(any),
        ]);
      });
    });
  });
}