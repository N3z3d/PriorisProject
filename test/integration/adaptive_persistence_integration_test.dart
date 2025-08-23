import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/services/persistence/adaptive_persistence_service.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';
import 'package:prioris/domain/services/core/lists_filter_service.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

import 'adaptive_persistence_integration_test.mocks.dart';

@GenerateMocks([CustomListRepository, ListItemRepository])
void main() {
  group('Adaptive Persistence - Tests d\'Intégration', () {
    late AdaptivePersistenceService adaptiveService;
    late ListsController controller;
    late MockCustomListRepository mockLocalRepository;
    late MockCustomListRepository mockCloudRepository;
    late MockListItemRepository mockLocalItemRepository;
    late MockListItemRepository mockCloudItemRepository;
    late ListsFilterService filterService;

    late CustomList testList;
    late ListItem testItem1;
    late ListItem testItem2;

    setUp(() {
      mockLocalRepository = MockCustomListRepository();
      mockCloudRepository = MockCustomListRepository();
      mockLocalItemRepository = MockListItemRepository();
      mockCloudItemRepository = MockListItemRepository();
      filterService = ListsFilterService();

      adaptiveService = AdaptivePersistenceService(
        localRepository: mockLocalRepository,
        cloudRepository: mockCloudRepository,
        localItemRepository: mockLocalItemRepository,
        cloudItemRepository: mockCloudItemRepository,
      );

      controller = ListsController.adaptive(adaptiveService, filterService);

      // Données de test
      final now = DateTime.now();
      testList = CustomList(
        id: 'integration-test-list',
        name: 'Liste d\'Intégration',
        type: ListType.CUSTOM,
        createdAt: now,
        updatedAt: now,
      );

      testItem1 = ListItem(
        id: 'integration-item-1',
        title: 'Premier élément',
        listId: testList.id,
        createdAt: now,
      );

      testItem2 = ListItem(
        id: 'integration-item-2',
        title: 'Deuxième élément',
        listId: testList.id,
        createdAt: now.add(const Duration(minutes: 1)),
      );
    });

    tearDown(() {
      controller.dispose();
      adaptiveService.dispose();
    });

    group('Workflow complet - Mode Invité', () {
      test('Cycle complet création → modification → suppression en mode local', () async {
        // PHASE 1: Initialisation en mode invité
        await adaptiveService.initialize(isAuthenticated: false);
        expect(adaptiveService.currentMode, PersistenceMode.localFirst);

        // Mock repositories pour mode local
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => []);
        when(mockLocalItemRepository.getByListId(any)).thenAnswer((_) async => []);

        // PHASE 2: Création d'une liste
        when(mockLocalRepository.saveList(testList)).thenAnswer((_) async => {});
        
        await controller.createList(testList);

        verify(mockLocalRepository.saveList(testList)).called(1);
        verifyNever(mockCloudRepository.saveList(any));
        expect(controller.state.lists.length, 1);

        // PHASE 3: Ajout d'éléments
        when(mockLocalItemRepository.add(testItem1)).thenAnswer((_) async => testItem1);
        when(mockLocalItemRepository.add(testItem2)).thenAnswer((_) async => testItem2);
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => [testList]);
        when(mockLocalItemRepository.getByListId(testList.id))
            .thenAnswer((_) async => [testItem1]);

        await controller.addItemToList(testList.id, testItem1);

        verify(mockLocalItemRepository.add(testItem1)).called(1);
        verifyNever(mockCloudItemRepository.add(any));

        // PHASE 4: Modification d'un élément
        final modifiedItem = testItem1.copyWith(title: 'Élément modifié');
        when(mockLocalItemRepository.update(modifiedItem)).thenAnswer((_) async => modifiedItem);

        await controller.updateListItem(testList.id, modifiedItem);

        verify(mockLocalItemRepository.update(modifiedItem)).called(1);

        // PHASE 5: Suppression de la liste
        when(mockLocalRepository.deleteList(testList.id)).thenAnswer((_) async => {});

        await controller.deleteList(testList.id);

        verify(mockLocalRepository.deleteList(testList.id)).called(1);
        verifyNever(mockCloudRepository.deleteList(any));
      });
    });

    group('Workflow complet - Mode Connecté', () {
      test('Cycle complet en mode cloud avec fallback local', () async {
        // PHASE 1: Initialisation en mode connecté
        await adaptiveService.initialize(isAuthenticated: true);
        expect(adaptiveService.currentMode, PersistenceMode.cloudFirst);

        // Mock repositories pour mode cloud
        when(mockCloudRepository.getAllLists()).thenAnswer((_) async => []);
        when(mockCloudItemRepository.getByListId(any)).thenAnswer((_) async => []);
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => []);
        when(mockLocalItemRepository.getByListId(any)).thenAnswer((_) async => []);

        // PHASE 2: Création avec sync cloud
        when(mockLocalRepository.saveList(testList)).thenAnswer((_) async => {});
        when(mockCloudRepository.saveList(testList)).thenAnswer((_) async => {});

        await controller.createList(testList);

        // Doit sauvegarder en local immédiatement
        verify(mockLocalRepository.saveList(testList)).called(1);
        
        // Le sync cloud est asynchrone, mais on peut vérifier que c'est configuré
        expect(controller.state.lists.length, 1);

        // PHASE 3: Test du fallback lors d'une panne cloud
        when(mockCloudRepository.getAllLists())
            .thenThrow(Exception('Connexion perdue'));
        when(mockLocalRepository.getAllLists())
            .thenAnswer((_) async => [testList]);
        when(mockLocalItemRepository.getByListId(testList.id))
            .thenAnswer((_) async => []);

        await controller.loadLists();

        // Doit utiliser les données locales en fallback
        verify(mockCloudRepository.getAllLists()).called(1);
        verify(mockLocalRepository.getAllLists()).called(1);
        expect(controller.state.lists.length, 1);

        // PHASE 4: Récupération de la connexion cloud
        when(mockCloudRepository.getAllLists())
            .thenAnswer((_) async => [testList]);
        when(mockCloudItemRepository.getByListId(testList.id))
            .thenAnswer((_) async => [testItem1]);

        await controller.loadLists();

        // Doit utiliser les données cloud
        verify(mockCloudRepository.getAllLists()).called(2);
        expect(controller.state.lists.length, 1);
      });
    });

    group('Workflow de transition d\'authentification', () {
      test('Transition invité → connecté avec migration intelligente', () async {
        // PHASE 1: Démarrer en mode invité avec des données
        await adaptiveService.initialize(isAuthenticated: false);
        
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => []);
        when(mockLocalItemRepository.getByListId(any)).thenAnswer((_) async => []);
        when(mockLocalRepository.saveList(testList)).thenAnswer((_) async => {});
        
        await controller.createList(testList);
        
        expect(adaptiveService.currentMode, PersistenceMode.localFirst);
        verify(mockLocalRepository.saveList(testList)).called(1);

        // PHASE 2: Ajouter des éléments en mode local
        when(mockLocalItemRepository.add(testItem1)).thenAnswer((_) async => testItem1);
        when(mockLocalItemRepository.add(testItem2)).thenAnswer((_) async => testItem2);
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => [testList]);
        when(mockLocalItemRepository.getByListId(testList.id))
            .thenAnswer((_) async => [testItem1]);

        await controller.addItemToList(testList.id, testItem1);
        await controller.addItemToList(testList.id, testItem2);

        // PHASE 3: Transition vers mode connecté
        when(mockLocalRepository.getAllLists())
            .thenAnswer((_) async => [testList]);
        when(mockCloudRepository.getAllLists())
            .thenAnswer((_) async => []);
        when(mockCloudRepository.saveList(testList))
            .thenAnswer((_) async => {});

        await adaptiveService.updateAuthenticationState(
          isAuthenticated: true,
          migrationStrategy: MigrationStrategy.intelligentMerge,
        );

        // PHASE 4: Vérifier la migration
        expect(adaptiveService.currentMode, PersistenceMode.cloudFirst);
        verify(mockCloudRepository.saveList(testList)).called(1);

        // PHASE 5: Nouvelles opérations doivent utiliser le cloud
        final newList = testList.copyWith(id: 'new-list', name: 'Nouvelle Liste');
        when(mockLocalRepository.saveList(newList)).thenAnswer((_) async => {});
        when(mockCloudRepository.saveList(newList)).thenAnswer((_) async => {});
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => [newList]);
        when(mockLocalItemRepository.getByListId(newList.id)).thenAnswer((_) async => []);

        await controller.createList(newList);

        // Doit utiliser le mode cloud-first
        verify(mockLocalRepository.saveList(newList)).called(1); // Sauvegarde immédiate locale
      });

      test('Transition connecté → invité avec conservation des données', () async {
        // PHASE 1: Démarrer en mode connecté
        await adaptiveService.initialize(isAuthenticated: true);
        
        when(mockCloudRepository.getAllLists()).thenAnswer((_) async => [testList]);
        when(mockCloudItemRepository.getByListId(testList.id))
            .thenAnswer((_) async => [testItem1]);
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => []);
        when(mockLocalItemRepository.getByListId(any)).thenAnswer((_) async => []);

        await controller.loadLists();
        
        expect(controller.state.lists.length, 1);

        // PHASE 2: Transition vers mode invité
        when(mockLocalRepository.saveList(testList)).thenAnswer((_) async => {});

        await adaptiveService.updateAuthenticationState(isAuthenticated: false);

        // PHASE 3: Vérifier la synchronisation locale
        expect(adaptiveService.currentMode, PersistenceMode.localFirst);
        verify(mockLocalRepository.saveList(testList)).called(1);

        // PHASE 4: Nouvelles opérations doivent utiliser le local
        final newItem = ListItem(
          id: 'local-item',
          title: 'Item local',
          listId: testList.id,
          createdAt: DateTime.now(),
        );

        when(mockLocalItemRepository.add(newItem)).thenAnswer((_) async => newItem);
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => [testList]);
        when(mockLocalItemRepository.getByListId(testList.id))
            .thenAnswer((_) async => [newItem]);

        await controller.addItemToList(testList.id, newItem);

        verify(mockLocalItemRepository.add(newItem)).called(1);
        verifyNever(mockCloudItemRepository.add(any));
      });
    });

    group('Scenarios de panne et récupération', () {
      test('Perte de connexion cloud pendant les opérations', () async {
        // PHASE 1: Mode connecté normal
        await adaptiveService.initialize(isAuthenticated: true);
        
        when(mockCloudRepository.getAllLists()).thenAnswer((_) async => []);
        when(mockCloudItemRepository.getByListId(any)).thenAnswer((_) async => []);
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => []);
        when(mockLocalItemRepository.getByListId(any)).thenAnswer((_) async => []);
        when(mockLocalRepository.saveList(testList)).thenAnswer((_) async => {});

        await controller.createList(testList);

        // PHASE 2: Panne cloud soudaine
        when(mockCloudRepository.getAllLists())
            .thenThrow(Exception('Connexion interrompue'));
        when(mockLocalRepository.getAllLists())
            .thenAnswer((_) async => [testList]);
        when(mockLocalItemRepository.getByListId(testList.id))
            .thenAnswer((_) async => []);

        // L'application doit continuer à fonctionner
        await controller.loadLists();

        expect(controller.state.lists.length, 1);
        expect(controller.state.error, null); // Pas d'erreur visible pour l'utilisateur

        // PHASE 3: Ajout d'éléments pendant la panne
        when(mockLocalItemRepository.add(testItem1)).thenAnswer((_) async => testItem1);
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => [testList]);
        when(mockLocalItemRepository.getByListId(testList.id))
            .thenAnswer((_) async => [testItem1]);

        await controller.addItemToList(testList.id, testItem1);

        // Doit fonctionner en mode local
        verify(mockLocalItemRepository.add(testItem1)).called(1);
        expect(controller.state.lists[0].items.length, 1);
      });

      test('Récupération après corruption de données locales', () async {
        // PHASE 1: Mode local avec corruption
        await adaptiveService.initialize(isAuthenticated: false);
        
        when(mockLocalRepository.getAllLists())
            .thenThrow(Exception('Corruption de la base locale'));

        await controller.loadLists();

        // L'erreur doit être gérée gracieusement
        expect(controller.state.error, isNotNull);
        expect(controller.state.lists.length, 0);

        // PHASE 2: Réinitialisation et récupération
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => []);
        when(mockLocalItemRepository.getByListId(any)).thenAnswer((_) async => []);

        controller.clearError();
        await controller.forceReloadFromPersistence();

        expect(controller.state.error, null);
        expect(controller.state.lists.length, 0);
      });
    });

    group('Performance et optimisations', () {
      test('Chargement de grandes quantités de données', () async {
        // PHASE 1: Simuler de gros volumes
        await adaptiveService.initialize(isAuthenticated: true);

        final largeLists = List.generate(100, (index) => CustomList(
          id: 'list-$index',
          name: 'Liste $index',
          type: ListType.CUSTOM,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

        final largeItems = List.generate(1000, (index) => ListItem(
          id: 'item-$index',
          title: 'Item $index',
          listId: 'list-${index % 100}', // Distribuer sur les listes
          createdAt: DateTime.now(),
        ));

        when(mockCloudRepository.getAllLists()).thenAnswer((_) async => largeLists);
        
        // Mock pour chaque liste
        for (int i = 0; i < 100; i++) {
          final listItems = largeItems.where((item) => item.listId == 'list-$i').toList();
          when(mockCloudItemRepository.getByListId('list-$i'))
              .thenAnswer((_) async => listItems);
        }

        // PHASE 2: Mesurer les performances
        final stopwatch = Stopwatch()..start();
        
        await controller.loadLists();
        
        stopwatch.stop();
        
        // PHASE 3: Vérifier les résultats
        expect(controller.state.lists.length, 100);
        expect(controller.state.error, null);
        
        // Le chargement ne devrait pas prendre plus de 2 secondes
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      });

      test('Opérations concurrentes', () async {
        // PHASE 1: Configuration
        await adaptiveService.initialize(isAuthenticated: false);
        
        when(mockLocalRepository.getAllLists()).thenAnswer((_) async => []);
        when(mockLocalItemRepository.getByListId(any)).thenAnswer((_) async => []);
        when(mockLocalRepository.saveList(any)).thenAnswer((_) async => {});
        when(mockLocalItemRepository.add(any)).thenAnswer((invocation) async {
          // Simuler une latence
          await Future.delayed(const Duration(milliseconds: 50));
          return invocation.positionalArguments[0];
        });

        // PHASE 2: Opérations concurrentes
        final futures = <Future>[];
        
        // Créer plusieurs listes en parallèle
        for (int i = 0; i < 5; i++) {
          final list = testList.copyWith(id: 'concurrent-list-$i', name: 'Liste $i');
          futures.add(controller.createList(list));
        }
        
        // Attendre que toutes les opérations se terminent
        await Future.wait(futures);
        
        // PHASE 3: Vérifier l'intégrité
        expect(controller.state.lists.length, 5);
        expect(controller.state.error, null);
        
        // Vérifier que toutes les listes ont été sauvegardées
        verify(mockLocalRepository.saveList(any)).called(5);
      });
    });
  });
}