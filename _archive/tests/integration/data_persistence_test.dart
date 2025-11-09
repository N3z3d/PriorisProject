import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

/// Test de persistance des données pour la Tâche 2.3
/// 
/// Valide :
/// - Persistance en mémoire avec InMemoryCustomListRepository
/// - Préparation pour migration vers Hive
/// - Cohérence des données lors des opérations CRUD
void main() {
  group('Data Persistence Test - Tâche 2.3', () {
    late ProviderContainer container;
    late InMemoryCustomListRepository repository;

    setUp(() {
      repository = InMemoryCustomListRepository();
      container = ProviderContainer(
        overrides: [
          // customListRepositoryProvider.overrideWithValue(repository), // Provider consolidé
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Memory Persistence Validation', () {
      test('Should persist lists in memory during session', () async {
        // Arrange: Créer des listes de test
        final lists = [
          CustomList(
            id: 'persist-1',
            name: 'Liste persistante 1',
            type: ListType.SHOPPING,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          CustomList(
            id: 'persist-2',
            name: 'Liste persistante 2',
            type: ListType.TRAVEL,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          CustomList(
            id: 'persist-3',
            name: 'Liste persistante 3',
            type: ListType.CUSTOM,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        // Act: Sauvegarder les listes
        for (final list in lists) {
          await repository.saveList(list);
        }

        // Assert: Vérifier la persistance
        final retrievedLists = await repository.getAllLists();
        expect(retrievedLists, hasLength(3));
        
        // Vérifier que chaque liste est correctement persistée
        for (final originalList in lists) {
          final retrieved = await repository.getListById(originalList.id);
          expect(retrieved, isNotNull);
          expect(retrieved!.id, originalList.id);
          expect(retrieved.name, originalList.name);
          expect(retrieved.type, originalList.type);
        }
      });

      test('Should maintain data integrity across operations', () async {
        // Arrange
        final originalList = CustomList(
          id: 'integrity-test',
          name: 'Test Intégrité',
          description: 'Description originale',
          type: ListType.CUSTOM,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert: Cycle complet CRUD
        // 1. Create
        await repository.saveList(originalList);
        var retrieved = await repository.getListById(originalList.id);
        expect(retrieved, isNotNull);
        expect(retrieved!.name, 'Test Intégrité');

        // 2. Update
        final updatedList = originalList.copyWith(
          name: 'Test Intégrité Modifié',
          description: 'Description mise à jour',
          updatedAt: DateTime.now(),
        );
        await repository.updateList(updatedList);
        retrieved = await repository.getListById(originalList.id);
        expect(retrieved!.name, 'Test Intégrité Modifié');
        expect(retrieved.description, 'Description mise à jour');

        // 3. Delete
        await repository.deleteList(originalList.id);
        retrieved = await repository.getListById(originalList.id);
        expect(retrieved, isNull);
      });

      test('Should handle concurrent operations safely', () async {
        // Test de concurrence pour valider la robustesse
        final futures = <Future>[];
        
        // Créer 10 listes en parallèle
        for (int i = 0; i < 10; i++) {
          futures.add(repository.saveList(CustomList(
            id: 'concurrent-$i',
            name: 'Liste Concurrente $i',
            type: ListType.CUSTOM,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          )));
        }

        // Attendre toutes les opérations
        await Future.wait(futures);

        // Vérifier que toutes les listes sont présentes
        final allLists = await repository.getAllLists();
        expect(allLists, hasLength(10));
        
        // Vérifier l'unicité des IDs
        final ids = allLists.map((l) => l.id).toSet();
        expect(ids, hasLength(10));
      });
    });

    group('Riverpod State Persistence', () {
      test('Should maintain state consistency through controller', () async {
        // Test avec le controller Riverpod
        final controller = container.read(listsControllerProvider.notifier);
        
        // Créer des listes via le controller
        final testLists = [
          CustomList(
            id: 'riverpod-1',
            name: 'Riverpod Test 1',
            type: ListType.SHOPPING,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          CustomList(
            id: 'riverpod-2',
            name: 'Riverpod Test 2',
            type: ListType.TRAVEL,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        for (final list in testLists) {
          await controller.createList(list);
        }

        // Vérifier l'état du provider
        final state = container.read(listsControllerProvider);
        expect(state.lists, hasLength(2));
        expect(state.filteredLists, hasLength(2));
        expect(state.isLoading, false);
        expect(state.error, isNull);

        // Vérifier la persistance dans le repository
        final repositoryLists = await repository.getAllLists();
        expect(repositoryLists, hasLength(2));
      });
    });

    group('Search and Filter Persistence', () {
      test('Should maintain filter state and search results', () async {
        // Préparer des données de test
        final lists = [
          CustomList(
            id: 'search-1',
            name: 'Ma liste de courses',
            type: ListType.SHOPPING,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          CustomList(
            id: 'search-2',
            name: 'Voyage à Paris',
            type: ListType.TRAVEL,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          CustomList(
            id: 'search-3',
            name: 'Objectifs personnels',
            type: ListType.CUSTOM,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        for (final list in lists) {
          await repository.saveList(list);
        }

        // Test de recherche
        final searchResults = await repository.searchListsByName('courses');
        expect(searchResults, hasLength(1));
        expect(searchResults.first.name, 'Ma liste de courses');

        // Test de filtrage par type
        final shoppingLists = await repository.getListsByType(ListType.SHOPPING);
        expect(shoppingLists, hasLength(1));
        expect(shoppingLists.first.type, ListType.SHOPPING);

        final travelLists = await repository.getListsByType(ListType.TRAVEL);
        expect(travelLists, hasLength(1));
        expect(travelLists.first.type, ListType.TRAVEL);
      });
    });

    group('Migration Preparation for Hive', () {
      test('Should validate data structure for Hive compatibility', () async {
        // Créer une liste avec toutes les propriétés
        final complexList = CustomList(
          id: 'hive-prep-1',
          name: 'Liste pour Hive',
          description: 'Description complète avec caractères spéciaux: éàùç',
          type: ListType.CUSTOM,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await repository.saveList(complexList);

        // Vérifier que la structure est compatible Hive
        final retrieved = await repository.getListById(complexList.id);
        expect(retrieved, isNotNull);
        
        // Toutes les propriétés doivent être sérialisables
        expect(retrieved!.id, isA<String>());
        expect(retrieved.name, isA<String>());
        expect(retrieved.description, isA<String?>());
        expect(retrieved.type, isA<ListType>());
        expect(retrieved.createdAt, isA<DateTime>());
        expect(retrieved.updatedAt, isA<DateTime>());
        expect(retrieved.items, isA<List>());
      });

      test('Should handle special characters and Unicode', () async {
        // Test avec caractères spéciaux pour Hive
        final unicodeList = CustomList(
          id: 'unicode-test',
          name: 'Liste avec émojis 🛒📝✅',
          description: 'Caractères spéciaux: éàùç ñü 中文 🌟',
          type: ListType.CUSTOM,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await repository.saveList(unicodeList);
        final retrieved = await repository.getListById(unicodeList.id);
        
        expect(retrieved, isNotNull);
        expect(retrieved!.name, unicodeList.name);
        expect(retrieved.description, unicodeList.description);
      });
    });
  });
} 
