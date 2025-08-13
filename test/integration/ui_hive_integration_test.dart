import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/data/repositories/hive_custom_list_repository.dart';
import 'package:prioris/data/providers/repository_providers.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

/// Adapter fictif pour ListPriority (stub, car ListPriority n’est plus utilisé)
class ListPriorityAdapter extends TypeAdapter<int> {
  @override
  final int typeId = 99;
  @override
  int read(BinaryReader reader) => reader.readInt();
  @override
  void write(BinaryWriter writer, int obj) => writer.writeInt(obj);
}

/// Test d'intégration UI/Hive pour la Phase 3
/// 
/// Valide :
/// - Migration de l'interface vers Hive
/// - Persistance des données entre sessions
/// - Performance de l'interface avec Hive
/// - Gestion des erreurs Hive dans l'UI
void main() {
  group('UI/Hive Integration Test - Phase 3', () {
    late ProviderContainer container;
    late HiveCustomListRepository repository;

    setUpAll(() async {
      // Initialiser Hive pour les tests
      Hive.init('test_hive_ui');
      
      // Enregistrer les adapters Hive
      Hive.registerAdapter(CustomListAdapter());
      Hive.registerAdapter(ListItemAdapter());
      Hive.registerAdapter(ListTypeAdapter());
      Hive.registerAdapter(ListPriorityAdapter());
    });

    setUp(() async {
      repository = HiveCustomListRepository();
      await repository.initialize();
      
      container = ProviderContainer(
        overrides: [
          hiveCustomListRepositoryProvider.overrideWith((ref) async => repository),
        ],
      );
    });

    tearDown(() async {
      await repository.clearAllLists();
      await repository.dispose();
      container.dispose();
    });

    tearDownAll(() async {
      await Hive.close();
    });

    test('should create list via UI controller and persist to Hive', () async {
      // Arrange
      final controller = container.read(listsControllerProvider.notifier);
      final testList = CustomList(
        id: 'ui-test-1',
        name: 'Liste créée via UI',
        description: 'Test de persistance UI/Hive',
        type: ListType.SHOPPING,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      await controller.createList(testList);
      final state = container.read(listsControllerProvider);

      // Assert
      expect(state.lists.length, 1);
      expect(state.lists.first.name, 'Liste créée via UI');
      expect(state.error, isNull);
      
      // Vérifier persistance Hive
      final persistedList = await repository.getListById('ui-test-1');
      expect(persistedList, isNotNull);
      expect(persistedList!.name, 'Liste créée via UI');
    });

    test('should update list via UI controller and persist to Hive', () async {
      // Arrange
      final controller = container.read(listsControllerProvider.notifier);
      final testList = CustomList(
        id: 'ui-test-2',
        name: 'Liste originale',
        type: ListType.CUSTOM,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await controller.createList(testList);
      
      final updatedList = CustomList(
        id: 'ui-test-2',
        name: 'Liste mise à jour',
        description: 'Description ajoutée',
        type: ListType.SHOPPING,
        createdAt: testList.createdAt,
        updatedAt: DateTime.now(),
      );

      // Act
      await controller.updateList(updatedList);
      final state = container.read(listsControllerProvider);

      // Assert
      expect(state.lists.length, 1);
      expect(state.lists.first.name, 'Liste mise à jour');
      expect(state.lists.first.description, 'Description ajoutée');
      expect(state.lists.first.type, ListType.SHOPPING);
      
      // Vérifier persistance Hive
      final persistedList = await repository.getListById('ui-test-2');
      expect(persistedList!.name, 'Liste mise à jour');
    });

    test('should delete list via UI controller and remove from Hive', () async {
      // Arrange
      final controller = container.read(listsControllerProvider.notifier);
      final testList = CustomList(
        id: 'ui-test-3',
        name: 'Liste à supprimer',
        type: ListType.CUSTOM,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await controller.createList(testList);
      expect(container.read(listsControllerProvider).lists.length, 1);

      // Act
      await controller.deleteList('ui-test-3');
      final state = container.read(listsControllerProvider);

      // Assert
      expect(state.lists.length, 0);
      expect(state.error, isNull);
      
      // Vérifier suppression de Hive
      final persistedList = await repository.getListById('ui-test-3');
      expect(persistedList, isNull);
    });

    test('should handle Hive errors gracefully in UI', () async {
      // Arrange
      final controller = container.read(listsControllerProvider.notifier);
      
      // Simuler une erreur Hive en fermant le repository
      await repository.dispose();

      // Act
      await controller.loadLists();
      final state = container.read(listsControllerProvider);

      // Assert
      expect(state.error, isNotNull);
      expect(state.error!.contains('Erreur'), isTrue);
      expect(state.isLoading, false);
    });

    test('should maintain UI state consistency with Hive data', () async {
      // Arrange
      final controller = container.read(listsControllerProvider.notifier);
      final lists = [
        CustomList(
          id: 'ui-test-4',
          name: 'Liste A',
          type: ListType.SHOPPING,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        CustomList(
          id: 'ui-test-5',
          name: 'Liste B',
          type: ListType.TRAVEL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      // Act
      for (final list in lists) {
        await controller.createList(list);
      }
      
      // Appliquer des filtres
      controller.updateTypeFilter(ListType.SHOPPING);
      controller.updateSearchQuery('Liste A');
      
      final state = container.read(listsControllerProvider);

      // Assert
      expect(state.lists.length, 2);
      expect(state.filteredLists.length, 1);
      expect(state.filteredLists.first.name, 'Liste A');
      expect(state.searchQuery, 'Liste A');
      expect(state.selectedType, ListType.SHOPPING);
    });

    test('should handle large datasets efficiently with Hive', () async {
      // Arrange
      final controller = container.read(listsControllerProvider.notifier);
      final startTime = DateTime.now();
      
      // Créer 100 listes
      for (int i = 0; i < 100; i++) {
        final list = CustomList(
          id: 'ui-test-large-$i',
          name: 'Liste $i',
          type: ListType.CUSTOM,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await controller.createList(list);
      }

      // Act
      await controller.loadLists();
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      final state = container.read(listsControllerProvider);

      // Assert
      expect(state.lists.length, 100);
      expect(state.error, isNull);
      expect(duration.inMilliseconds, lessThan(1000)); // Moins d'1 seconde
    });

    test('should persist UI state between app sessions', () async {
      // Arrange
      final controller = container.read(listsControllerProvider.notifier);
      final testList = CustomList(
        id: 'ui-test-session',
        name: 'Liste persistante',
        type: ListType.BOOKS,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await controller.createList(testList);
      
      // Simuler fermeture de l'app
      await repository.dispose();
      
      // Simuler redémarrage de l'app
      final newRepository = HiveCustomListRepository();
      await newRepository.initialize();
      
      final newContainer = ProviderContainer(
        overrides: [
          hiveCustomListRepositoryProvider.overrideWith((ref) async => newRepository),
        ],
      );
      
      final newController = newContainer.read(listsControllerProvider.notifier);

      // Act
      await newController.loadLists();
      final state = newContainer.read(listsControllerProvider);

      // Assert
      expect(state.lists.length, 1);
      expect(state.lists.first.name, 'Liste persistante');
      expect(state.lists.first.type, ListType.BOOKS);
      
      // Cleanup
      await newRepository.dispose();
      newContainer.dispose();
    });
  });
} 
