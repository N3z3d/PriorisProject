import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/data/repositories/hive_custom_list_repository.dart';
import 'package:prioris/data/repositories/hive_list_item_repository.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';
import 'package:prioris/domain/services/core/lists_filter_service.dart';

/// Test d'architecture pour valider la persistance
/// Ce test vérifie que les données survivent aux redémarrages du controller
void main() {
  group('Architecture Persistence Test', () {
    late Directory tempDir;
    
    setUpAll(() async {
      // Configurer Hive pour les tests
      tempDir = await Directory.systemTemp.createTemp('test_hive');
      Hive.init(tempDir.path);
      
      // Enregistrer les adapters
      if (!Hive.isAdapterRegistered(CustomListAdapter().typeId)) {
        Hive.registerAdapter(CustomListAdapter());
      }
      if (!Hive.isAdapterRegistered(ListItemAdapter().typeId)) {
        Hive.registerAdapter(ListItemAdapter());
      }
      if (!Hive.isAdapterRegistered(ListTypeAdapter().typeId)) {
        Hive.registerAdapter(ListTypeAdapter());
      }
      // Note: ListPriorityAdapter n'existe pas encore
    });
    
    tearDownAll(() async {
      await Hive.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });
    
    test('ARCHITECTURE FIX: Données survivent au redémarrage du controller', () async {
      // === PHASE 1: Créer et sauvegarder des données ===
      
      // Initialiser les repositories
      final listRepo = HiveCustomListRepository();
      final itemRepo = HiveListItemRepository();
      
      await listRepo.initialize();
      await itemRepo.initialize();
      
      // Créer une liste de test
      final now = DateTime.now();
      final testList = CustomList(
        id: 'test-list-1',
        name: 'Liste Test Persistence',
        type: ListType.MOVIES, // Utiliser un type existant
        createdAt: now,
        updatedAt: now,
      );
      
      // Créer des items de test
      final testItems = [
        ListItem(
          id: 'item-1',
          title: 'Item 1',
          listId: 'test-list-1',
          createdAt: DateTime.now(),
        ),
        ListItem(
          id: 'item-2',
          title: 'Item 2',
          listId: 'test-list-1',
          createdAt: DateTime.now(),
        ),
      ];
      
      // Sauvegarder dans Hive
      await listRepo.saveList(testList);
      for (final item in testItems) {
        await itemRepo.add(item);
      }
      
      // Vérifier la sauvegarde
      final savedList = await listRepo.getListById('test-list-1');
      final savedItems = await itemRepo.getByListId('test-list-1');
      
      expect(savedList, isNotNull);
      expect(savedList!.name, 'Liste Test Persistence');
      expect(savedItems.length, 2);
      expect(savedItems.map((i) => i.title), contains('Item 1'));
      expect(savedItems.map((i) => i.title), contains('Item 2'));
      
      print('✅ Phase 1: Données sauvegardées dans Hive');
      
      // === PHASE 2: Simuler redémarrage - nouveaux repositories ===
      
      // Fermer les repositories actuels
      await listRepo.dispose();
      await itemRepo.close();
      
      // Créer de NOUVEAUX repositories (simule redémarrage)
      final newListRepo = HiveCustomListRepository();
      final newItemRepo = HiveListItemRepository();
      
      await newListRepo.initialize();
      await newItemRepo.initialize();
      
      // Vérifier que les données sont toujours là
      final reloadedList = await newListRepo.getListById('test-list-1');
      final reloadedItems = await newItemRepo.getByListId('test-list-1');
      
      expect(reloadedList, isNotNull);
      expect(reloadedList!.name, 'Liste Test Persistence');
      expect(reloadedItems.length, 2);
      expect(reloadedItems.map((i) => i.title), contains('Item 1'));
      expect(reloadedItems.map((i) => i.title), contains('Item 2'));
      
      print('✅ Phase 2: Données persistantes après redémarrage');
      
      // === PHASE 3: Test architecture Controller ===
      
      // Simuler l'architecture réelle avec Futures
      final listRepoFuture = Future.value(newListRepo);
      final itemRepoFuture = Future.value(newItemRepo);
      
      // Créer un controller comme dans l'app réelle
      final controller = ListsController(
        listRepoFuture, 
        itemRepoFuture, 
        ListsFilterService(),
      );
      
      // Attendre l'initialisation
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Vérifier que le controller a chargé les données
      final state = controller.state;
      expect(state.lists.length, 1);
      expect(state.lists.first.name, 'Liste Test Persistence');
      expect(state.lists.first.items.length, 2);
      
      print('✅ Phase 3: Controller architecture fonctionne');
      
      // Nettoyer
      await newListRepo.dispose();
      await newItemRepo.close();
    });
  });
}