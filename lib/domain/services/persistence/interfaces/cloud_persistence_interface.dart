/// **CLOUD PERSISTENCE INTERFACE** - ISP Compliant
///
/// Interface segregée pour les opérations de persistance cloud uniquement.
/// Respecte le principe ISP (Interface Segregation Principle).

import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

/// **Interface pour la persistance cloud**
///
/// **Responsabilité unique** : Opérations CRUD cloud avec fallback
/// **ISP** : Interface minimale et cohérente
abstract class ICloudPersistenceService {
  // === Authentication State ===

  /// Indique si le service cloud est disponible et authentifié
  bool get isCloudAvailable;

  // === List Operations ===

  /// Récupère toutes les listes depuis le cloud avec fallback local
  Future<List<CustomList>> getCloudLists({bool fallbackToLocal = true});

  /// Sauvegarde une liste vers le cloud avec fallback local
  Future<void> saveCloudList(CustomList list, {bool fallbackToLocal = true});

  /// Met à jour une liste cloud avec fallback local
  Future<void> updateCloudList(CustomList list, {bool fallbackToLocal = true});

  /// Supprime une liste cloud avec fallback local
  Future<void> deleteCloudList(String listId, {bool fallbackToLocal = true});

  // === Item Operations ===

  /// Récupère les items d'une liste depuis le cloud avec fallback local
  Future<List<ListItem>> getCloudItems(String listId, {bool fallbackToLocal = true});

  /// Sauvegarde un item vers le cloud avec fallback local
  Future<void> saveCloudItem(ListItem item, {bool fallbackToLocal = true});

  /// Met à jour un item cloud avec fallback local
  Future<void> updateCloudItem(ListItem item, {bool fallbackToLocal = true});

  /// Supprime un item cloud avec fallback local
  Future<void> deleteCloudItem(String itemId, {bool fallbackToLocal = true});

  // === Batch Operations ===

  /// Sauvegarde multiple d'items vers le cloud
  Future<void> saveMultipleCloudItems(List<ListItem> items, {bool fallbackToLocal = true});

  /// Efface toutes les données cloud
  Future<void> clearCloudData({bool fallbackToLocal = true});

  // === Connectivity & Health ===

  /// Vérifie la connectivité cloud
  Future<bool> checkCloudConnectivity();

  /// Obtient le statut de santé du service cloud
  Future<Map<String, dynamic>> getCloudHealthStatus();
}