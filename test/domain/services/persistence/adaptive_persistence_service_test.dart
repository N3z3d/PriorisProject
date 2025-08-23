import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:prioris/domain/services/persistence/adaptive_persistence_service.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

import 'adaptive_persistence_service_test.mocks.dart';

@GenerateMocks([CustomListRepository, ListItemRepository])
void main() {
  group('AdaptivePersistenceService - Tests Unitaires', () {
    late AdaptivePersistenceService service;
    late MockCustomListRepository mockLocalRepository;
    late MockCustomListRepository mockCloudRepository;
    late MockListItemRepository mockLocalItemRepository;
    late MockListItemRepository mockCloudItemRepository;
    
    late CustomList testList;
    late ListItem testItem;

    setUp(() {
      mockLocalRepository = MockCustomListRepository();
      mockCloudRepository = MockCustomListRepository();
      mockLocalItemRepository = MockListItemRepository();
      mockCloudItemRepository = MockListItemRepository();
      
      service = AdaptivePersistenceService(
        localRepository: mockLocalRepository,
        cloudRepository: mockCloudRepository,
        localItemRepository: mockLocalItemRepository,
        cloudItemRepository: mockCloudItemRepository,
      );
      
      // Données de test
      final now = DateTime.now();
      testList = CustomList(
        id: 'test-list-1',
        name: 'Test List',
        type: ListType.CUSTOM,
        createdAt: now,
        updatedAt: now,
      );
      
      testItem = ListItem(
        id: 'test-item-1',
        title: 'Test Item',
        listId: testList.id,
        createdAt: now,
      );
    });

    group('Initialisation', () {
      test('Doit initialiser en mode localFirst quand non authentifié', () async {
        // Act
        await service.initialize(isAuthenticated: false);
        
        // Assert
        expect(service.currentMode, PersistenceMode.localFirst);
        expect(service.isAuthenticated, false);
      });

      test('Doit initialiser en mode cloudFirst quand authentifié', () async {
        // Act
        await service.initialize(isAuthenticated: true);
        
        // Assert
        expect(service.currentMode, PersistenceMode.cloudFirst);
        expect(service.isAuthenticated, true);
      });
    });

    group('Mode LocalFirst', () {
      setUp(() async {
        await service.initialize(isAuthenticated: false);
      });

      test('Doit utiliser le repository local pour getAllLists', () async {
        // Arrange
        when(mockLocalRepository.getAllLists())
            .thenAnswer((_) async => [testList]);

        // Act
        final result = await service.getAllLists();

        // Assert
        expect(result, [testList]);
        verify(mockLocalRepository.getAllLists()).called(1);
        verifyNever(mockCloudRepository.getAllLists());
      });

      test('Doit utiliser le repository local pour saveList', () async {
        // Act
        await service.saveList(testList);

        // Assert
        verify(mockLocalRepository.saveList(testList)).called(1);
        verifyNever(mockCloudRepository.saveList(any));
      });

      test('Doit utiliser le repository local pour les items', () async {
        // Arrange
        when(mockLocalItemRepository.getByListId(testList.id))
            .thenAnswer((_) async => [testItem]);

        // Act
        final result = await service.getItemsByListId(testList.id);

        // Assert
        expect(result, [testItem]);
        verify(mockLocalItemRepository.getByListId(testList.id)).called(1);
        verifyNever(mockCloudItemRepository.getByListId(any));
      });
    });

    group('Mode CloudFirst', () {
      setUp(() async {
        await service.initialize(isAuthenticated: true);
      });

      test('Doit utiliser le repository cloud avec fallback local', () async {
        // Arrange
        when(mockCloudRepository.getAllLists())
            .thenAnswer((_) async => [testList]);

        // Act
        final result = await service.getAllLists();

        // Assert
        expect(result, [testList]);
        verify(mockCloudRepository.getAllLists()).called(1);
      });

      test('Doit fallback vers local si cloud indisponible', () async {
        // Arrange
        when(mockCloudRepository.getAllLists())
            .thenThrow(Exception('Cloud unavailable'));
        when(mockLocalRepository.getAllLists())
            .thenAnswer((_) async => [testList]);

        // Act
        final result = await service.getAllLists();

        // Assert
        expect(result, [testList]);
        verify(mockCloudRepository.getAllLists()).called(1);
        verify(mockLocalRepository.getAllLists()).called(1);
      });

      test('Doit sauvegarder en local puis sync vers cloud', () async {
        // Act
        await service.saveList(testList);

        // Assert
        verify(mockLocalRepository.saveList(testList)).called(1);
        // Le sync cloud est asynchrone, on vérifie juste que local est appelé immédiatement
      });
    });

    group('Changements d\'authentification', () {
      test('Transition invité → connecté avec migration intelligente', () async {
        // Arrange - Commencer en mode invité
        await service.initialize(isAuthenticated: false);
        
        // Simuler des données locales existantes
        when(mockLocalRepository.getAllLists())
            .thenAnswer((_) async => [testList]);
        when(mockCloudRepository.getAllLists())
            .thenAnswer((_) async => []);

        // Act - Changer vers authentifié
        await service.updateAuthenticationState(isAuthenticated: true);

        // Assert
        expect(service.currentMode, PersistenceMode.cloudFirst);
        expect(service.isAuthenticated, true);
        verify(mockLocalRepository.getAllLists()).called(1);
      });

      test('Transition connecté → invité avec sync cloud vers local', () async {
        // Arrange - Commencer en mode authentifié
        await service.initialize(isAuthenticated: true);
        
        // Simuler des données cloud
        when(mockCloudRepository.getAllLists())
            .thenAnswer((_) async => [testList]);

        // Act - Changer vers invité
        await service.updateAuthenticationState(isAuthenticated: false);

        // Assert
        expect(service.currentMode, PersistenceMode.localFirst);
        expect(service.isAuthenticated, false);
        verify(mockCloudRepository.getAllLists()).called(1);
      });
    });

    group('Migration intelligente', () {
      test('Doit résoudre conflit avec la plus récente', () async {
        // Arrange
        final olderList = testList.copyWith(
          updatedAt: DateTime.now().subtract(const Duration(hours: 1))
        );
        final newerList = testList.copyWith(
          updatedAt: DateTime.now()
        );

        await service.initialize(isAuthenticated: false);
        
        when(mockLocalRepository.getAllLists())
            .thenAnswer((_) async => [newerList]);
        when(mockCloudRepository.getAllLists())
            .thenAnswer((_) async => [olderList]);

        // Act
        await service.updateAuthenticationState(
          isAuthenticated: true,
          migrationStrategy: MigrationStrategy.intelligentMerge,
        );

        // Assert
        verify(mockCloudRepository.saveList(newerList)).called(1);
      });

      test('Doit migrer nouvelles listes locales vers cloud', () async {
        // Arrange
        final newLocalList = testList.copyWith(id: 'new-local-list');
        
        await service.initialize(isAuthenticated: false);
        
        when(mockLocalRepository.getAllLists())
            .thenAnswer((_) async => [newLocalList]);
        when(mockCloudRepository.getAllLists())
            .thenAnswer((_) async => []);

        // Act
        await service.updateAuthenticationState(
          isAuthenticated: true,
          migrationStrategy: MigrationStrategy.intelligentMerge,
        );

        // Assert
        verify(mockCloudRepository.saveList(newLocalList)).called(1);
      });
    });

    group('Gestion d\'erreurs', () {
      test('Doit propager les erreurs de persistance', () async {
        // Arrange
        await service.initialize(isAuthenticated: false);
        when(mockLocalRepository.saveList(any))
            .thenThrow(Exception('Persistence error'));

        // Act & Assert
        expect(
          () => service.saveList(testList),
          throwsException,
        );
      });

      test('Doit gérer les erreurs de migration gracieusement', () async {
        // Arrange
        await service.initialize(isAuthenticated: false);
        when(mockLocalRepository.getAllLists())
            .thenThrow(Exception('Local error'));

        // Act - Ne doit pas faire planter l'app
        await expectLater(
          service.updateAuthenticationState(isAuthenticated: true),
          completes,
        );
      });
    });

    group('Operations CRUD items', () {
      setUp(() async {
        await service.initialize(isAuthenticated: false);
      });

      test('Doit sauvegarder un item en mode local', () async {
        // Act
        await service.saveItem(testItem);

        // Assert
        verify(mockLocalItemRepository.add(testItem)).called(1);
        verifyNever(mockCloudItemRepository.add(any));
      });

      test('Doit mettre à jour un item', () async {
        // Arrange
        final updatedItem = testItem.copyWith(title: 'Updated Title');

        // Act
        await service.updateItem(updatedItem);

        // Assert
        verify(mockLocalItemRepository.update(updatedItem)).called(1);
      });

      test('Doit supprimer un item', () async {
        // Act
        await service.deleteItem(testItem.id);

        // Assert
        verify(mockLocalItemRepository.delete(testItem.id)).called(1);
      });
    });

    group('Stratégies de migration', () {
      test('MigrateAll - doit migrer toutes les données', () async {
        // Arrange
        final list1 = testList;
        final list2 = testList.copyWith(id: 'list-2');
        
        await service.initialize(isAuthenticated: false);
        when(mockLocalRepository.getAllLists())
            .thenAnswer((_) async => [list1, list2]);

        // Act
        await service.updateAuthenticationState(
          isAuthenticated: true,
          migrationStrategy: MigrationStrategy.migrateAll,
        );

        // Assert
        verify(mockCloudRepository.saveList(list1)).called(1);
        verify(mockCloudRepository.saveList(list2)).called(1);
      });

      test('CloudOnly - ne doit pas migrer les données locales', () async {
        // Arrange
        await service.initialize(isAuthenticated: false);
        when(mockLocalRepository.getAllLists())
            .thenAnswer((_) async => [testList]);

        // Act
        await service.updateAuthenticationState(
          isAuthenticated: true,
          migrationStrategy: MigrationStrategy.cloudOnly,
        );

        // Assert
        verifyNever(mockCloudRepository.saveList(any));
      });
    });
  });
}