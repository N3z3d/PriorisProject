/// **LOCAL PERSISTENCE INTERFACE** - ISP Compliant
///
/// Interface segregée pour les opérations de persistance locale uniquement.
/// Respecte le principe ISP (Interface Segregation Principle).

import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

/// **Interface pour la persistance locale**
///
/// **Responsabilité unique** : Opérations CRUD locales
/// **ISP** : Interface minimale et cohérente
abstract class ILocalPersistenceService {
  // === List Operations ===

  /// Récupère toutes les listes depuis le stockage local
  Future<List<CustomList>> getLocalLists();

  /// Sauvegarde une liste localement avec déduplication
  Future<void> saveLocalList(CustomList list);

  /// Met à jour une liste locale
  Future<void> updateLocalList(CustomList list);

  /// Supprime une liste locale
  Future<void> deleteLocalList(String listId);

  // === Item Operations ===

  /// Récupère les items d'une liste depuis le stockage local
  Future<List<ListItem>> getLocalItems(String listId);

  /// Sauvegarde un item localement avec déduplication
  Future<void> saveLocalItem(ListItem item);

  /// Met à jour un item local
  Future<void> updateLocalItem(ListItem item);

  /// Supprime un item local
  Future<void> deleteLocalItem(String itemId);

  // === Batch Operations ===

  /// Sauvegarde multiple d'items avec transaction
  Future<void> saveMultipleLocalItems(List<ListItem> items);

  /// Efface toutes les données locales
  Future<void> clearLocalData();

  // === Verification ===

  /// Vérifie qu'une liste existe localement
  Future<bool> verifyLocalList(String listId);

  /// Vérifie qu'un item existe localement
  Future<bool> verifyLocalItem(String itemId);
}