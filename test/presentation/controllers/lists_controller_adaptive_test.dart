import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';
import 'package:prioris/domain/services/persistence/adaptive_persistence_service.dart';
import 'package:prioris/domain/services/core/lists_filter_service.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

import 'lists_controller_adaptive_test.mocks.dart';

void clearInvocations(Object mock) => reset(mock);

@GenerateMocks([AdaptivePersistenceService, ListsFilterService])
void main() {
  group('ListsController Adaptive - Tests Fonctionnels', () {
    late ListsController controller;
    late MockAdaptivePersistenceService mockAdaptiveService;
    late MockListsFilterService mockFilterService;
    
    late CustomList testList1;
    late CustomList testList2;
    late ListItem testItem1;
    late ListItem testItem2;

    setUp(() {
      mockAdaptiveService = MockAdaptivePersistenceService();
      mockFilterService = MockListsFilterService();

      when(mockAdaptiveService.currentMode)
          .thenReturn(PersistenceMode.localFirst);
      when(mockAdaptiveService.isAuthenticated).thenReturn(false);
      when(mockAdaptiveService.initialize(isAuthenticated: anyNamed('isAuthenticated')))
          .thenAnswer((_) async {});
      when(mockAdaptiveService.updateAuthenticationState(
              isAuthenticated: anyNamed('isAuthenticated')))
          .thenAnswer((_) async {});
      when(mockAdaptiveService.getAllLists())
          .thenAnswer((_) async => <CustomList>[]);
      when(mockAdaptiveService.getItemsByListId(any))
          .thenAnswer((_) async => <ListItem>[]);
      when(mockAdaptiveService.getLists())
          .thenAnswer((_) async => <CustomList>[]);
      when(mockAdaptiveService.getListItems(any))
          .thenAnswer((_) async => <ListItem>[]);

      controller = ListsController.adaptive(
        mockAdaptiveService,
        mockFilterService,
      );
      
      // Données de test
      final now = DateTime.now();
      
      testList1 = CustomList(
        id: 'list-1',
        name: 'Liste de Courses',
        type: ListType.CUSTOM,
        createdAt: now,
        updatedAt: now,
        items: [],
      );
      
      testList2 = CustomList(
        id: 'list-2',
        name: 'Liste de Tâches',
        type: ListType.CUSTOM,
        createdAt: now.add(const Duration(minutes: 1)),
        updatedAt: now.add(const Duration(minutes: 1)),
        items: [],
      );
      
      testItem1 = ListItem(
        id: 'item-1',
        title: 'Acheter du lait',
        listId: testList1.id,
        createdAt: now,
      );
      
      testItem2 = ListItem(
        id: 'item-2',
        title: 'Faire les courses',
        listId: testList1.id,
        createdAt: now.add(const Duration(minutes: 1)),
      );
    });

    tearDown(() {
      controller.dispose();
    });

    group('Chargement initial', () {
      test('Doit charger les listes via le service adaptatif', () async {
        // Arrange
        when(mockAdaptiveService.getAllLists())
            .thenAnswer((_) async => [testList1, testList2]);
        when(mockAdaptiveService.getItemsByListId(testList1.id))
            .thenAnswer((_) async => [testItem1, testItem2]);
        when(mockAdaptiveService.getItemsByListId(testList2.id))
            .thenAnswer((_) async => []);
        when(mockFilterService.applyFilters(
          any,
          searchQuery: anyNamed('searchQuery'),
          selectedType: anyNamed('selectedType'),
          showCompleted: anyNamed('showCompleted'),
          showInProgress: anyNamed('showInProgress'),
          selectedDateFilter: anyNamed('selectedDateFilter'),
          sortOption: anyNamed('sortOption'),
        )).thenReturn([testList1, testList2]);

        // Act
        await controller.loadLists();

        // Assert
        expect(controller.state.lists.length, 2);
        expect(controller.state.lists[0].items.length, 2);
        expect(controller.state.isLoading, false);
        expect(controller.state.error, null);
        
        verify(mockAdaptiveService.getAllLists()).called(1);
        verify(mockAdaptiveService.getItemsByListId(testList1.id)).called(1);
        verify(mockAdaptiveService.getItemsByListId(testList2.id)).called(1);
      });

      test('Doit gérer les erreurs de chargement', () async {
        // Arrange
        when(mockAdaptiveService.getAllLists())
            .thenThrow(Exception('Erreur de connexion'));

        // Act
        await controller.loadLists();

        // Assert
        expect(controller.state.isLoading, false);
        expect(controller.state.error, isNotNull);
        expect(controller.state.error!.contains('Erreur de connexion'), true);
      });
    });

    group('Création de listes', () {
      test('Doit créer une liste via le service adaptatif', () async {
        // Arrange
        when(mockAdaptiveService.saveList(testList1))
            .thenAnswer((_) async => {});
        when(mockAdaptiveService.getAllLists())
            .thenAnswer((_) async => [testList1]);
        when(mockAdaptiveService.getItemsByListId(testList1.id))
            .thenAnswer((_) async => []);
        when(mockFilterService.applyFilters(
          any,
          searchQuery: anyNamed('searchQuery'),
          selectedType: anyNamed('selectedType'),
          showCompleted: anyNamed('showCompleted'),
          showInProgress: anyNamed('showInProgress'),
          selectedDateFilter: anyNamed('selectedDateFilter'),
          sortOption: anyNamed('sortOption'),
        )).thenReturn([testList1]);

        // Act
        await controller.createList(testList1);

        // Assert
        verify(mockAdaptiveService.saveList(testList1)).called(1);
        expect(controller.state.lists.length, 1);
        expect(controller.state.lists[0].id, testList1.id);
        expect(controller.state.isLoading, false);
      });

      test('Doit gérer les erreurs de création', () async {
        // Arrange
        when(mockAdaptiveService.saveList(testList1))
            .thenThrow(Exception('Erreur de sauvegarde'));

        // Act
        await controller.createList(testList1);

        // Assert
        expect(controller.state.error, isNotNull);
        expect(controller.state.error!.contains('Erreur de sauvegarde'), true);
        expect(controller.state.lists.length, 0);
      });
    });

    group('Gestion des items', () {
      setUp(() async {
        // Setup initial avec une liste
        when(mockAdaptiveService.getAllLists())
            .thenAnswer((_) async => [testList1]);
        when(mockAdaptiveService.getItemsByListId(testList1.id))
            .thenAnswer((_) async => []);
        when(mockFilterService.applyFilters(
          any,
          searchQuery: anyNamed('searchQuery'),
          selectedType: anyNamed('selectedType'),
          showCompleted: anyNamed('showCompleted'),
          showInProgress: anyNamed('showInProgress'),
          selectedDateFilter: anyNamed('selectedDateFilter'),
          sortOption: anyNamed('sortOption'),
        )).thenReturn([testList1]);
        
        await controller.loadLists();
        clearInvocations(mockAdaptiveService);
      });

      test('Doit ajouter un item à une liste', () async {
        // Arrange
        when(mockAdaptiveService.saveItem(testItem1))
            .thenAnswer((_) async => {});
        when(mockAdaptiveService.getAllLists())
            .thenAnswer((_) async => [testList1]);
        when(mockAdaptiveService.getItemsByListId(testList1.id))
            .thenAnswer((_) async => [testItem1]);

        // Act
        await controller.addItemToList(testList1.id, testItem1);

        // Assert
        verify(mockAdaptiveService.saveItem(testItem1)).called(1);
        
        // Vérifier l'état local (l'item devrait être ajouté)
        final listInState = controller.state.lists
            .firstWhere((list) => list.id == testList1.id);
        expect(listInState.items.length, 1);
        expect(listInState.items[0].id, testItem1.id);
      });

      test('Doit mettre à jour un item', () async {
        // Arrange - Ajouter d'abord un item
        when(mockAdaptiveService.saveItem(testItem1))
            .thenAnswer((_) async => {});
        when(mockAdaptiveService.getAllLists())
            .thenAnswer((_) async => [testList1]);
        when(mockAdaptiveService.getItemsByListId(testList1.id))
            .thenAnswer((_) async => [testItem1]);
        
        await controller.addItemToList(testList1.id, testItem1);
        
        // Arrange - Préparer la mise à jour
        final updatedItem = testItem1.copyWith(title: 'Acheter du pain');
        when(mockAdaptiveService.updateItem(updatedItem))
            .thenAnswer((_) async => {});

        // Act
        await controller.updateListItem(testList1.id, updatedItem);

        // Assert
        verify(mockAdaptiveService.updateItem(updatedItem)).called(1);
        
        // Vérifier l'état local
        final listInState = controller.state.lists
            .firstWhere((list) => list.id == testList1.id);
        expect(listInState.items[0].title, 'Acheter du pain');
      });

      test('Doit supprimer un item', () async {
        // Arrange - Ajouter d'abord un item
        when(mockAdaptiveService.saveItem(testItem1))
            .thenAnswer((_) async => {});
        when(mockAdaptiveService.getAllLists())
            .thenAnswer((_) async => [testList1]);
        when(mockAdaptiveService.getItemsByListId(testList1.id))
            .thenAnswer((_) async => [testItem1]);
        
        await controller.addItemToList(testList1.id, testItem1);
        
        // Arrange - Préparer la suppression
        when(mockAdaptiveService.deleteItem(testItem1.id))
            .thenAnswer((_) async => {});

        // Act
        await controller.removeItemFromList(testList1.id, testItem1.id);

        // Assert
        verify(mockAdaptiveService.deleteItem(testItem1.id)).called(1);
        
        // Vérifier l'état local
        final listInState = controller.state.lists
            .firstWhere((list) => list.id == testList1.id);
        expect(listInState.items.length, 0);
      });
    });

    group('Ajout multiple d\'items', () {
      setUp(() async {
        // Setup initial
        when(mockAdaptiveService.getAllLists())
            .thenAnswer((_) async => [testList1]);
        when(mockAdaptiveService.getItemsByListId(testList1.id))
            .thenAnswer((_) async => []);
        when(mockFilterService.applyFilters(
          any,
          searchQuery: anyNamed('searchQuery'),
          selectedType: anyNamed('selectedType'),
          showCompleted: anyNamed('showCompleted'),
          showInProgress: anyNamed('showInProgress'),
          selectedDateFilter: anyNamed('selectedDateFilter'),
          sortOption: anyNamed('sortOption'),
        )).thenReturn([testList1]);
        
        await controller.loadLists();
        clearInvocations(mockAdaptiveService);
      });

      test('Doit ajouter plusieurs items d\'un coup', () async {
        // Arrange
        final itemTitles = ['Item 1', 'Item 2', 'Item 3'];
        when(mockAdaptiveService.saveItem(any))
            .thenAnswer((_) async => {});
        when(mockAdaptiveService.getAllLists())
            .thenAnswer((_) async => [testList1]);
        when(mockAdaptiveService.getItemsByListId(testList1.id))
            .thenAnswer((_) async => []);

        // Act
        await controller.addMultipleItemsToList(testList1.id, itemTitles);

        // Assert
        verify(mockAdaptiveService.saveItem(any)).called(3);
        
        // Vérifier l'état local
        final listInState = controller.state.lists
            .firstWhere((list) => list.id == testList1.id);
        expect(listInState.items.length, 3);
      });

      test('Doit faire un rollback en cas d\'erreur partielle', () async {
        // Arrange
        final itemTitles = ['Item 1', 'Item 2', 'Item 3'];
        
        // Le deuxième item va échouer
        when(mockAdaptiveService.saveItem(any))
            .thenAnswer((invocation) async {
          final item = invocation.positionalArguments[0] as ListItem;
          if (item.title == 'Item 2') {
            throw Exception('Erreur de sauvegarde');
          }
        });
        when(mockAdaptiveService.deleteItem(any))
            .thenAnswer((_) async => {});

        // Act
        try {
          await controller.addMultipleItemsToList(testList1.id, itemTitles);
        } catch (e) {
          // Expected
        }

        // Assert - Rollback doit être appelé
        verify(mockAdaptiveService.deleteItem(any)).called(1);
        expect(controller.state.error, isNotNull);
      });
    });

    group('Nettoyage complet', () {
      test('Doit effacer toutes les données', () async {
        // Arrange
        when(mockAdaptiveService.getAllLists())
            .thenAnswer((_) async => [testList1, testList2]);
        when(mockAdaptiveService.getItemsByListId(testList1.id))
            .thenAnswer((_) async => [testItem1, testItem2]);
        when(mockAdaptiveService.getItemsByListId(testList2.id))
            .thenAnswer((_) async => []);
        when(mockAdaptiveService.deleteList(any))
            .thenAnswer((_) async => {});
        when(mockAdaptiveService.deleteItem(any))
            .thenAnswer((_) async => {});

        // Act
        await controller.clearAllData();

        // Assert
        verify(mockAdaptiveService.deleteList(testList1.id)).called(1);
        verify(mockAdaptiveService.deleteList(testList2.id)).called(1);
        verify(mockAdaptiveService.deleteItem(testItem1.id)).called(1);
        verify(mockAdaptiveService.deleteItem(testItem2.id)).called(1);
        
        expect(controller.state.lists.length, 0);
        expect(controller.state.filteredLists.length, 0);
      });
    });

    group('Rechargement forcé', () {
      test('Doit recharger depuis la persistance', () async {
        // Arrange
        when(mockAdaptiveService.getAllLists())
            .thenAnswer((_) async => [testList1]);
        when(mockAdaptiveService.getItemsByListId(testList1.id))
            .thenAnswer((_) async => [testItem1]);
        when(mockFilterService.applyFilters(
          any,
          searchQuery: anyNamed('searchQuery'),
          selectedType: anyNamed('selectedType'),
          showCompleted: anyNamed('showCompleted'),
          showInProgress: anyNamed('showInProgress'),
          selectedDateFilter: anyNamed('selectedDateFilter'),
          sortOption: anyNamed('sortOption'),
        )).thenReturn([testList1]);

        // Act
        await controller.forceReloadFromPersistence();

        // Assert
        verify(mockAdaptiveService.getAllLists()).called(1);
        verify(mockAdaptiveService.getItemsByListId(testList1.id)).called(1);
        
        expect(controller.state.lists.length, 1);
        expect(controller.state.lists[0].items.length, 1);
      });
    });

    group('États de chargement et d\'erreur', () {
      test('Doit gérer l\'état de chargement correctement', () async {
        // Arrange
        when(mockAdaptiveService.getAllLists())
            .thenAnswer((_) async {
          // Simuler une opération lente
          await Future.delayed(const Duration(milliseconds: 100));
          return [testList1];
        });
        when(mockAdaptiveService.getItemsByListId(testList1.id))
            .thenAnswer((_) async => []);
        when(mockFilterService.applyFilters(
          any,
          searchQuery: anyNamed('searchQuery'),
          selectedType: anyNamed('selectedType'),
          showCompleted: anyNamed('showCompleted'),
          showInProgress: anyNamed('showInProgress'),
          selectedDateFilter: anyNamed('selectedDateFilter'),
          sortOption: anyNamed('sortOption'),
        )).thenReturn([testList1]);

        // Act & Assert
        final future = controller.loadLists();
        
        // Pendant le chargement
        expect(controller.state.isLoading, true);
        expect(controller.state.error, null);
        
        await future;
        
        // Après le chargement
        expect(controller.state.isLoading, false);
        expect(controller.state.error, null);
        expect(controller.state.lists.length, 1);
      });

      test('Doit pouvoir effacer les erreurs', () async {
        // Arrange - Provoquer une erreur
        when(mockAdaptiveService.getAllLists())
            .thenThrow(Exception('Erreur test'));
        
        await controller.loadLists();
        expect(controller.state.error, isNotNull);

        // Act
        controller.clearError();

        // Assert
        expect(controller.state.error, null);
      });
    });
  });
}
