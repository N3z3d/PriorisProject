import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

/// Options de tri pour les listes
enum SortOption {
  nameAsc,
  nameDesc,
  dateCreatedAsc,
  dateCreatedDesc,
  progressAsc,
  progressDesc,
}

/// Interface pour les opérations de gestion d'état des listes
/// 
/// Respecte le principe Single Responsibility en se concentrant
/// uniquement sur la gestion d'état.
abstract class ListsStateManagerInterface {
  /// Met à jour la requête de recherche
  void updateSearchQuery(String query);

  /// Met à jour le filtre par type
  void updateTypeFilter(ListType? type);

  /// Met à jour le filtre de statut (terminées)
  void updateShowCompleted(bool show);

  /// Met à jour le filtre de statut (en cours)
  void updateShowInProgress(bool show);

  /// Met à jour le filtre par date
  void updateDateFilter(String? filter);

  /// Met à jour l'option de tri
  void updateSortOption(SortOption option);

  /// Efface les erreurs
  void clearError();
}

/// Interface pour les opérations CRUD sur les listes
/// 
/// Séparée de la gestion d'état selon le principe
/// Interface Segregation.
abstract class ListsCrudInterface {
  /// Charge toutes les listes
  Future<void> loadLists();

  /// Crée une nouvelle liste
  Future<void> createList(CustomList list);

  /// Met à jour une liste existante
  Future<void> updateList(CustomList list);

  /// Supprime une liste
  Future<void> deleteList(String listId);
}

/// Interface pour les opérations sur les éléments de liste
/// 
/// Séparée des opérations sur les listes selon le principe
/// Interface Segregation.
abstract class ListItemsManagerInterface {
  /// Ajoute un élément à une liste
  Future<void> addItemToList(String listId, ListItem item);

  /// Met à jour un élément de liste
  Future<void> updateListItem(String listId, ListItem item);

  /// Supprime un élément de liste
  Future<void> removeItemFromList(String listId, String itemId);
}

/// Interface pour les opérations de nettoyage et maintenance
/// 
/// Séparée des autres opérations selon le principe
/// Interface Segregation.
abstract class ListsMaintenanceInterface {
  /// Nettoie les ressources
  void cleanup();
}