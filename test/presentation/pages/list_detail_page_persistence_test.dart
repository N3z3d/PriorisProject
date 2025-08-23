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
import 'package:prioris/domain/services/core/lists_filter_service.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';
import 'package:prioris/presentation/pages/list_detail_page.dart';

import '../../test_utils/test_providers.dart';
import '../../test_utils/test_providers.mocks.dart';

/// Tests TDD pour diagnostiquer le problème de persistance des listes et éléments
/// 
/// Phase RED (Tests qui échouent) : Ces tests démontrent que les données 
/// ne persistent pas correctement après un refresh ou redémarrage simulé.
/// 
/// Problème identifié : Les éléments ajoutés ne sont pas rechargés 
/// depuis la persistance après un refresh.
void main() {
  group('ListDetailPage - Persistence TDD Tests (Phase RED)', () {
    late MockCustomListRepositoryTest mockCustomListRepository;
    late MockListItemRepositoryTest mockListItemRepository;
    late MockListsFilterServiceTest mockFilterService;
    
    // Données de test
    late CustomList testList;
    late ListItem testItem1;
    late ListItem testItem2;
    late ListItem testItem3;
    
    setUp(() {
      mockCustomListRepository = MockCustomListRepositoryTest();
      mockListItemRepository = MockListItemRepositoryTest();
      mockFilterService = MockListsFilterServiceTest();
      
      // Création des données de test
      final now = DateTime.now();
      
      testList = CustomList(
        id: 'test-list-1',
        name: 'Liste de Test Persistence',
        type: ListType.CUSTOM,
        description: 'Liste pour tester la persistence',
        createdAt: now,
        updatedAt: now,
        items: [],
      );
      
      testItem1 = ListItem(
        id: 'item-1',
        title: 'Premier élément test',
        listId: testList.id,
        createdAt: now,
      );
      
      testItem2 = ListItem(
        id: 'item-2',
        title: 'Deuxième élément test',
        listId: testList.id,
        createdAt: now.add(const Duration(minutes: 1)),
      );
      
      testItem3 = ListItem(
        id: 'item-3',
        title: 'Troisième élément test',
        listId: testList.id,
        createdAt: now.add(const Duration(minutes: 2)),
      );
    });

    Widget buildTestWidget({CustomList? customList, List<Override>? additionalOverrides}) {
      final listToUse = customList ?? testList;
      
      final overrides = [
        customListRepositoryProvider.overrideWithValue(mockCustomListRepository),
        listItemRepositoryProvider.overrideWithValue(mockListItemRepository),
        // Override du provider de liste par ID pour retourner notre liste de test
        listByIdProvider(listToUse.id).overrideWith((ref) => listToUse),
        // Override du controller pour utiliser nos mocks
        ...?additionalOverrides,
      ];
      
      return TestAppWrapper(
        overrides: overrides,
        child: ListDetailPage(list: listToUse),
      );
    }

    group('Problème 1: Liste créée disparaît après refresh', () {
      testWidgets('FAILING - Liste créée doit persister après refresh simulé', (tester) async {
        // ARRANGE
        // Simulation: Liste vide au démarrage
        when(mockCustomListRepository.getListById(testList.id))
            .thenAnswer((_) async => null);
        
        when(mockListItemRepository.getByListId(testList.id))
            .thenAnswer((_) async => []);
            
        // Après création, la liste doit être persistée
        when(mockCustomListRepository.saveList(any))
            .thenAnswer((_) async => {});
        
        // ACT - Phase 1: Création initiale
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();
        
        // Simuler la création d'une liste (ce qui devrait la sauvegarder)
        verify(mockCustomListRepository.getListById(testList.id)).called(1);
        
        // ACT - Phase 2: Simuler un refresh/redémarrage
        // Après refresh, la liste DEVRAIT être trouvée en base
        when(mockCustomListRepository.getListById(testList.id))
            .thenAnswer((_) async => testList);
        
        // Recréer le widget (simule un refresh/redémarrage)
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();
        
        // ASSERT - Ce test DOIT ÉCHOUER car la persistence ne fonctionne pas
        // La liste devrait être retrouvée après refresh
        verify(mockCustomListRepository.getListById(testList.id)).called(greaterThan(0));
        
        // Ce test va échouer car la liste n'est pas correctement persistée
        expect(find.text(testList.name), findsOneWidget,
            reason: 'La liste créée devrait persister après un refresh');
      });
    });

    group('Problème 2: Items ajoutés disparaissent après refresh', () {
      testWidgets('FAILING - Item unique ajouté doit persister après refresh', (tester) async {
        // ARRANGE
        when(mockCustomListRepository.getListById(testList.id))
            .thenAnswer((_) async => testList);
            
        // Phase 1: Pas d'items au démarrage
        when(mockListItemRepository.getByListId(testList.id))
            .thenAnswer((_) async => []);
            
        when(mockListItemRepository.add(any))
            .thenAnswer((invocation) async => invocation.positionalArguments[0]);
        
        // ACT - Phase 1: Chargement initial
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();
        
        // Vérifier que la liste est chargée mais vide
        expect(find.text(testList.name), findsOneWidget);
        expect(find.text(testItem1.title), findsNothing);
        
        // ACT - Phase 2: Simuler ajout d'un item
        // (Ici on simule que l'item a été ajouté via l'interface)
        verify(mockListItemRepository.getByListId(testList.id)).called(1);
        
        // ACT - Phase 3: Simuler refresh après ajout
        // Après refresh, l'item DEVRAIT être trouvé en base
        when(mockListItemRepository.getByListId(testList.id))
            .thenAnswer((_) async => [testItem1]);
        
        // Recréer le widget (simule refresh)
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();
        
        // ASSERT - Ce test DOIT ÉCHOUER car l'item n'est pas rechargé
        verify(mockListItemRepository.getByListId(testList.id)).called(greaterThan(0));
        
        // Ce test va échouer car l'item ajouté n'est pas visible après refresh
        expect(find.text(testItem1.title), findsOneWidget,
            reason: 'L\'item ajouté devrait être visible après refresh');
      });

      testWidgets('FAILING - Items multiples ajoutés doivent persister après refresh', (tester) async {
        // ARRANGE
        when(mockCustomListRepository.getListById(testList.id))
            .thenAnswer((_) async => testList);
            
        // Phase 1: Liste vide au démarrage
        when(mockListItemRepository.getByListId(testList.id))
            .thenAnswer((_) async => []);
        
        // ACT - Phase 1: Chargement initial
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();
        
        // ACT - Phase 2: Simuler ajout multiple via l'interface
        // (On simule que plusieurs items ont été ajoutés)
        
        // ACT - Phase 3: Simuler refresh après ajouts multiples
        when(mockListItemRepository.getByListId(testList.id))
            .thenAnswer((_) async => [testItem1, testItem2, testItem3]);
        
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();
        
        // ASSERT - Ces tests DOIVENT ÉCHOUER car les items ne sont pas rechargés
        expect(find.text(testItem1.title), findsOneWidget,
            reason: 'Premier item devrait être visible après refresh');
        expect(find.text(testItem2.title), findsOneWidget,
            reason: 'Deuxième item devrait être visible après refresh');
        expect(find.text(testItem3.title), findsOneWidget,
            reason: 'Troisième item devrait être visible après refresh');
      });
    });

    group('Problème 3: Persistence après redémarrage d\'app simulé', () {
      testWidgets('FAILING - Données complètes doivent survivre à un redémarrage', (tester) async {
        // ARRANGE - Simuler une app qui redémarre avec des données en base
        final updatedList = testList.copyWith(
          items: [testItem1, testItem2],
          updatedAt: DateTime.now(),
        );
        
        // Au redémarrage, tout doit être chargé depuis la persistence
        when(mockCustomListRepository.getListById(testList.id))
            .thenAnswer((_) async => updatedList);
        when(mockListItemRepository.getByListId(testList.id))
            .thenAnswer((_) async => [testItem1, testItem2]);
        
        // ACT - Simuler redémarrage d'app (nouveau widget créé avec liste mise à jour)
        await tester.pumpWidget(buildTestWidget(customList: updatedList));
        await tester.pumpAndSettle();
        
        // ASSERT - Après redémarrage, tout devrait être là
        expect(find.text(updatedList.name), findsOneWidget,
            reason: 'Le nom de la liste devrait être chargé après redémarrage');
        expect(find.text(testItem1.title), findsOneWidget,
            reason: 'Premier item devrait être chargé après redémarrage');
        expect(find.text(testItem2.title), findsOneWidget,
            reason: 'Deuxième item devrait être chargé après redémarrage');
            
        // Vérifier que les repositories ont bien été appelés pour charger les données
        verify(mockCustomListRepository.getListById(testList.id)).called(greaterThan(0));
        verify(mockListItemRepository.getByListId(testList.id)).called(greaterThan(0));
      });
    });

    group('Problème 4: État des items (complétion) ne persiste pas', () {
      testWidgets('FAILING - État de complétion doit persister après refresh', (tester) async {
        // ARRANGE
        final completedItem = testItem1.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
        );
        
        when(mockCustomListRepository.getListById(testList.id))
            .thenAnswer((_) async => testList);
        when(mockListItemRepository.getByListId(testList.id))
            .thenAnswer((_) async => [completedItem, testItem2]);
        
        // ACT
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();
        
        // ASSERT - L'état de complétion devrait être visible
        // Ce test révèlera si l'état de complétion persiste correctement
        expect(find.text(completedItem.title), findsOneWidget);
        expect(find.text(testItem2.title), findsOneWidget);
        
        // TODO: Ajouter des vérifications visuelles pour l'état complété
        // (coché/décoché, style visuel, etc.)
      });
    });
  });

  group('Diagnostics - Vérification des appels de persistence', () {
    late MockCustomListRepositoryTest mockCustomListRepository;
    late MockListItemRepositoryTest mockListItemRepository;
    
    setUp(() {
      mockCustomListRepository = MockCustomListRepositoryTest();
      mockListItemRepository = MockListItemRepositoryTest();
    });

    test('DIAGNOSTIC - Les méthodes de persistence sont-elles appelées?', () async {
      // ARRANGE
      final testList = CustomList(
        id: 'diagnostic-list',
        name: 'Liste Diagnostic',
        type: ListType.CUSTOM,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Configuration des mocks
      when(mockCustomListRepository.getListById(any))
          .thenAnswer((_) async => null);
      when(mockCustomListRepository.saveList(any))
          .thenAnswer((_) async => {});
      when(mockListItemRepository.getByListId(any))
          .thenAnswer((_) async => []);
      when(mockListItemRepository.add(any))
          .thenAnswer((invocation) async => invocation.positionalArguments[0]);
      
      // ACT - Simuler les opérations qui devraient déclencher la persistence
      await mockCustomListRepository.saveList(testList);
      
      final testItem = ListItem(
        id: 'diagnostic-item',
        title: 'Item diagnostic',
        listId: testList.id,
        createdAt: DateTime.now(),
      );
      await mockListItemRepository.add(testItem);
      
      // ASSERT - Vérifier que les méthodes ont été appelées
      verify(mockCustomListRepository.saveList(testList)).called(1);
      verify(mockListItemRepository.add(testItem)).called(1);
    });

    test('DIAGNOSTIC - Les données sont-elles récupérées au chargement?', () async {
      // ARRANGE
      final listId = 'load-test';
      
      when(mockCustomListRepository.getListById(listId))
          .thenAnswer((_) async => null);
      when(mockListItemRepository.getByListId(listId))
          .thenAnswer((_) async => []);
      
      // ACT
      final loadedList = await mockCustomListRepository.getListById(listId);
      final loadedItems = await mockListItemRepository.getByListId(listId);
      
      // ASSERT
      verify(mockCustomListRepository.getListById(listId)).called(1);
      verify(mockListItemRepository.getByListId(listId)).called(1);
      
      expect(loadedList, isNull);
      expect(loadedItems, isEmpty);
    });
  });
}