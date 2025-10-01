import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

/// Options de tri pour les listes
enum SortOption {
  NAME_ASC,
  NAME_DESC,
  DATE_CREATED_ASC,
  DATE_CREATED_DESC,
  PROGRESS_ASC,
  PROGRESS_DESC,
}

/// Interface pour les opérations de persistance et repository
///
/// Centralise toutes les interactions avec les repositories
/// selon le principe Single Responsibility.
abstract class IListsRepositoryService {
  /// Charge toutes les listes depuis la persistance
  Future<List<CustomList>> getAllLists();

  /// Charge les éléments d'une liste spécifique
  Future<List<ListItem>> getItemsByListId(String listId);

  /// Sauvegarde une liste
  Future<void> saveList(CustomList list);

  /// Met à jour une liste existante
  Future<void> updateList(CustomList list);

  /// Supprime une liste
  Future<void> deleteList(String listId);

  /// Sauvegarde un élément de liste
  Future<void> saveItem(ListItem item);

  /// Met à jour un élément de liste
  Future<void> updateItem(ListItem item);

  /// Supprime un élément de liste
  Future<void> deleteItem(String itemId);

  /// Ajoute plusieurs éléments en une opération
  Future<void> saveMultipleItems(List<ListItem> items);

  /// Efface toutes les données
  Future<void> clearAllData();

  /// Force le rechargement depuis la persistance
  Future<List<CustomList>> forceReloadFromPersistence();

  /// Vérifie la persistance d'une liste
  Future<void> verifyListPersistence(String listId);

  /// Vérifie la persistance d'un élément
  Future<void> verifyItemPersistence(String itemId);
}

/// Interface pour la gestion d'état des listes
///
/// Responsable des transformations d'état et du filtrage
/// selon le principe Single Responsibility.
abstract class IListsStateService {
  /// Applique les filtres aux listes
  List<CustomList> applyFilters(
    List<CustomList> lists, {
    String? searchQuery,
    ListType? selectedType,
    bool? showCompleted,
    bool? showInProgress,
    String? selectedDateFilter,
    SortOption? sortOption,
  });

  /// Met à jour une liste dans la collection
  List<CustomList> updateListInCollection(List<CustomList> lists, CustomList updatedList);

  /// Ajoute une liste à la collection
  List<CustomList> addListToCollection(List<CustomList> lists, CustomList newList);

  /// Supprime une liste de la collection
  List<CustomList> removeListFromCollection(List<CustomList> lists, String listId);

  /// Met à jour les éléments d'une liste spécifique
  List<CustomList> updateListItems(
    List<CustomList> lists,
    String listId,
    List<ListItem> Function(List<ListItem>) updateFunction,
  );

  /// Crée une liste avec des éléments mis à jour
  CustomList createUpdatedList(
    CustomList list,
    List<ListItem> Function(List<ListItem>) updateFunction,
  );

  /// Méthodes utilitaires pour les opérations courantes

  /// Ajoute un élément à une liste dans une collection
  List<CustomList> addItemToListInCollection(
    List<CustomList> lists,
    String listId,
    ListItem item,
  );

  /// Supprime un élément d'une liste dans une collection
  List<CustomList> removeItemFromListInCollection(
    List<CustomList> lists,
    String listId,
    String itemId,
  );

  /// Met à jour un élément dans une liste de la collection
  List<CustomList> updateItemInListInCollection(
    List<CustomList> lists,
    String listId,
    ListItem updatedItem,
  );
}

/// Interface pour le monitoring de performance et la cohérence des données
///
/// Responsable du suivi des performances et de la validation
/// selon le principe Single Responsibility.
abstract class IListsPerformanceMonitor {
  /// Démarre le monitoring d'une opération
  void startOperation(String operationName);

  /// Termine le monitoring d'une opération
  void endOperation(String operationName);

  /// Valide la cohérence des données
  Future<bool> validateDataConsistency(List<CustomList> lists);

  /// Met en cache les listes pour les performances
  void cacheLists(List<CustomList> lists);

  /// Invalide le cache
  void invalidateCache();

  /// Obtient les statistiques de performance
  Map<String, dynamic> getPerformanceStats();

  /// Log une erreur avec contexte
  void logError(String operation, Object error, StackTrace? stackTrace);

  /// Log une information
  void logInfo(String message, {String? context});

  /// Log un avertissement
  void logWarning(String message, {String? context});

  /// Réinitialise toutes les statistiques
  void resetStats();
}

/// Interface pour les opérations de gestion d'état des listes
///
/// Respecte le principe Single Responsibility en se concentrant
/// uniquement sur la gestion d'état.
abstract class IListsStateManager {
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
abstract class IListsCrud {
  /// Charge toutes les listes
  Future<void> loadLists();

  /// Crée une nouvelle liste
  Future<void> createList(CustomList list);

  /// Met à jour une liste existante
  Future<void> updateList(CustomList list);

  /// Supprime une liste
  Future<void> deleteList(String listId);

  /// Force le rechargement complet
  Future<void> forceReloadFromPersistence();

  /// Efface toutes les données
  Future<void> clearAllData();
}

/// Interface pour les opérations sur les éléments de liste
///
/// Séparée des opérations sur les listes selon le principe
/// Interface Segregation.
abstract class IListItemsManager {
  /// Ajoute un élément à une liste
  Future<void> addItemToList(String listId, ListItem item);

  /// Met à jour un élément de liste
  Future<void> updateListItem(String listId, ListItem item);

  /// Supprime un élément de liste
  Future<void> removeItemFromList(String listId, String itemId);

  /// Ajoute plusieurs éléments à une liste
  Future<void> addMultipleItemsToList(String listId, List<String> itemTitles);
}

/// Interface pour les opérations de nettoyage et maintenance
///
/// Séparée des autres opérations selon le principe
/// Interface Segregation.
abstract class IListsMaintenance {
  /// Nettoie les ressources
  void cleanup();

  /// Vérifie si le service est correctement monté/initialisé
  bool get isSafelyMounted;
}

/// Interface complète du contrôleur des listes
///
/// Combine toutes les interfaces spécialisées pour fournir
/// une API complète tout en respectant les principes SOLID.
abstract class IListsController
    implements IListsStateManager, IListsCrud, IListItemsManager, IListsMaintenance {
  // L'interface combine automatiquement toutes les méthodes des interfaces parentes
}