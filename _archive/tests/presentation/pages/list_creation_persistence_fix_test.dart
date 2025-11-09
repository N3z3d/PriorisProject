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

/// Tests TDD pour valider les corrections des problèmes de persistance
/// 
/// Phase GREEN : Ces tests valident que les corrections fonctionnent
/// et que les données persistent correctement.
void main() {
  group('CORRECTION VALIDÉE - Persistance des données corrigée', () {
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

    group('GREEN PHASE - Tests qui passent (corrections validées)', () {
      
      test('CORRECTION 1: Liste créée persiste après restart - SHOULD PASS', () async {
        // ARRANGE
        final newList = CustomList(
          id: 'persistent-list-123',
          name: 'Liste qui persiste',
          type: ListType.CUSTOM,
          description: 'Liste corrigée',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Mock: Démarrage vide
        when(mockCustomListRepository.getAllLists())
            .thenAnswer((_) async => []);
        
        // Mock: Sauvegarde réussie
        when(mockCustomListRepository.saveList(any))
            .thenAnswer((_) async => {});
        
        // Mock: Vérification de persistance réussie
        when(mockCustomListRepository.getListById(newList.id))
            .thenAnswer((_) async => newList);
        
        // ACT - Phase 1: Créer la liste
        final controller = container.read(listsControllerProvider.notifier);
        await controller.loadLists();
        
        var state = container.read(listsControllerProvider);
        expect(state.lists, isEmpty);
        
        await controller.createList(newList);
        
        // Vérifier que saveList ET getListById ont été appelés (validation de persistance)
        verify(mockCustomListRepository.saveList(any)).called(1);
        verify(mockCustomListRepository.getListById(newList.id)).called(1);
        
        state = container.read(listsControllerProvider);
        expect(state.lists, hasLength(1));
        expect(state.lists.first.name, equals('Liste qui persiste'));
        expect(state.error, isNull);
        
        // ACT - Phase 2: Simuler redémarrage avec données persistées
        when(mockCustomListRepository.getAllLists())
            .thenAnswer((_) async => [newList]);
        
        await controller.forceReloadFromPersistence();
        
        // ASSERT - La liste doit être récupérée
        state = container.read(listsControllerProvider);
        expect(state.lists, hasLength(1));
        expect(state.lists.first.name, equals('Liste qui persiste'));
        expect(state.error, isNull);
      });

      test('CORRECTION 2: Items ajoutés persistent après refresh - SHOULD PASS', () async {
        // ARRANGE
        final existingList = CustomList(
          id: 'list-with-items-456',
          name: 'Liste avec items',
          type: ListType.SHOPPING,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        final newItem = ListItem(
          id: 'persistent-item-789',
          title: 'Item qui persiste',
          listId: existingList.id,
          createdAt: DateTime.now(),
        );

        // Mock: Liste existante
        when(mockCustomListRepository.getAllLists())
            .thenAnswer((_) async => [existingList]);
        when(mockListItemRepository.getByListId(existingList.id))
            .thenAnswer((_) async => []);
        
        // Mock: Ajout d'item avec vérification
        when(mockListItemRepository.add(any))
            .thenAnswer((invocation) async => invocation.positionalArguments[0] as ListItem);
        when(mockListItemRepository.getById(newItem.id))
            .thenAnswer((_) async => newItem);
        
        // ACT - Phase 1: Ajouter item
        final controller = container.read(listsControllerProvider.notifier);
        await controller.loadLists();
        
        await controller.addItemToList(existingList.id, newItem);
        
        // Vérifier que add ET getById ont été appelés (validation de persistance)
        verify(mockListItemRepository.add(any)).called(1);
        verify(mockListItemRepository.getById(newItem.id)).called(1);
        
        var state = container.read(listsControllerProvider);
        expect(state.lists.first.items, hasLength(1));
        expect(state.error, isNull);
        
        // ACT - Phase 2: Simuler refresh avec items persistés
        when(mockListItemRepository.getByListId(existingList.id))
            .thenAnswer((_) async => [newItem]);
        
        await controller.forceReloadFromPersistence();
        
        // ASSERT - L'item doit être récupéré
        state = container.read(listsControllerProvider);
        expect(state.lists.first.items, hasLength(1));
        expect(state.lists.first.items.first.title, equals('Item qui persiste'));
        expect(state.error, isNull);
      });
      
      test('CORRECTION 3: Erreur de sauvegarde bien gérée - SHOULD PASS', () async {
        // ARRANGE
        final failingList = CustomList(
          id: 'failing-list-999',
          name: 'Liste qui échoue',
          type: ListType.CUSTOM,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockCustomListRepository.getAllLists())
            .thenAnswer((_) async => []);
        
        // Mock: Sauvegarde échoue
        when(mockCustomListRepository.saveList(any))
            .thenThrow(Exception('Erreur réseau simulée'));
        
        // ACT
        final controller = container.read(listsControllerProvider.notifier);
        await controller.loadLists();
        
        await controller.createList(failingList);
        
        // ASSERT - L'erreur doit être gérée proprement
        final state = container.read(listsControllerProvider);
        expect(state.error, isNotNull);
        expect(state.error, contains('Échec de création de la liste'));
        
        // La liste ne doit PAS être dans l'état local
        expect(state.lists, isEmpty);
      });

      test('CORRECTION 4: Bulk add avec gestion transactionnelle - SHOULD PASS', () async {
        // ARRANGE
        final existingList = CustomList(
          id: 'bulk-transactional-list',
          name: 'Liste bulk transactionnelle',
          type: ListType.CUSTOM,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        final itemTitles = ['Item 1 OK', 'Item 2 OK', 'Item 3 OK'];

        when(mockCustomListRepository.getAllLists())
            .thenAnswer((_) async => [existingList]);
        when(mockListItemRepository.getByListId(existingList.id))
            .thenAnswer((_) async => []);
        
        // Mock: Tous les ajouts réussissent
        when(mockListItemRepository.add(any))
            .thenAnswer((invocation) async => invocation.positionalArguments[0] as ListItem);
        
        // Mock: Toutes les vérifications réussissent
        when(mockListItemRepository.getById(any))
            .thenAnswer((invocation) async {
              final id = invocation.positionalArguments[0] as String;
              return ListItem(
                id: id,
                title: 'Verified Item',
                listId: existingList.id,
                createdAt: DateTime.now(),
              );
            });
        
        // ACT
        final controller = container.read(listsControllerProvider.notifier);
        await controller.loadLists();
        
        await controller.addMultipleItemsToList(existingList.id, itemTitles);
        
        // ASSERT - Tous les items doivent être ajoutés
        final state = container.read(listsControllerProvider);
        expect(state.lists.first.items, hasLength(3));
        expect(state.error, isNull);
        
        // Vérifier que add() a été appelé 3 fois
        verify(mockListItemRepository.add(any)).called(3);
        // Vérifier que getById() a été appelé 3 fois (validation)
        verify(mockListItemRepository.getById(any)).called(3);
      });

      test('CORRECTION 5: Bulk add avec échec partiel et rollback - SHOULD PASS', () async {
        // ARRANGE
        final existingList = CustomList(
          id: 'bulk-rollback-list',
          name: 'Liste avec rollback',
          type: ListType.CUSTOM,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        final itemTitles = ['Item 1', 'Item 2', 'Item 3 FAIL', 'Item 4'];

        when(mockCustomListRepository.getAllLists())
            .thenAnswer((_) async => [existingList]);
        when(mockListItemRepository.getByListId(existingList.id))
            .thenAnswer((_) async => []);
        
        // Mock: Le 3ème ajout échoue
        var addCallCount = 0;
        when(mockListItemRepository.add(any)).thenAnswer((invocation) async {
          addCallCount++;
          if (addCallCount == 3) {
            throw Exception('Échec simulé sur item 3');
          }
          return invocation.positionalArguments[0] as ListItem;
        });
        
        // Mock: Les vérifications réussissent pour les 2 premiers
        var verifyCallCount = 0;
        when(mockListItemRepository.getById(any)).thenAnswer((invocation) async {
          verifyCallCount++;
          if (verifyCallCount <= 2) {
            final id = invocation.positionalArguments[0] as String;
            return ListItem(
              id: id,
              title: 'Verified Item $verifyCallCount',
              listId: existingList.id,
              createdAt: DateTime.now(),
            );
          }
          throw Exception('Pas de vérification après échec');
        });
        
        // Mock: Delete pour rollback
        when(mockListItemRepository.delete(any))
            .thenAnswer((_) async => {});
        
        // ACT
        final controller = container.read(listsControllerProvider.notifier);
        await controller.loadLists();
        
        await controller.addMultipleItemsToList(existingList.id, itemTitles);
        
        // ASSERT - Opération doit échouer avec rollback
        final state = container.read(listsControllerProvider);
        expect(state.error, isNotNull);
        expect(state.error, contains('Échec d\'ajout multiple'));
        
        // Aucun item ne doit être dans l'état (rollback complet)
        expect(state.lists.first.items, isEmpty);
        
        // Vérifier que delete() a été appelé pour rollback (2 fois pour les 2 premiers items)
        verify(mockListItemRepository.delete(any)).called(2);
      });
    });

    group('Validations supplémentaires', () {
      test('Force reload doit vider et recharger complètement', () async {
        // ARRANGE
        final initialList = CustomList(
          id: 'initial-list',
          name: 'Liste initiale',
          type: ListType.CUSTOM,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        final reloadedList = CustomList(
          id: 'reloaded-list',
          name: 'Liste rechargée',
          type: ListType.CUSTOM,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Mock: Première charge
        when(mockCustomListRepository.getAllLists())
            .thenAnswer((_) async => [initialList]);
        when(mockListItemRepository.getByListId(any))
            .thenAnswer((_) async => []);
        
        // ACT - Chargement initial
        final controller = container.read(listsControllerProvider.notifier);
        await controller.loadLists();
        
        var state = container.read(listsControllerProvider);
        expect(state.lists, hasLength(1));
        expect(state.lists.first.name, equals('Liste initiale'));
        
        // ACT - Force reload avec nouvelles données
        when(mockCustomListRepository.getAllLists())
            .thenAnswer((_) async => [reloadedList]);
        
        await controller.forceReloadFromPersistence();
        
        // ASSERT - Les données doivent être complètement remplacées
        state = container.read(listsControllerProvider);
        expect(state.lists, hasLength(1));
        expect(state.lists.first.name, equals('Liste rechargée'));
        expect(state.lists.first.id, equals('reloaded-list'));
      });
    });
  });
}