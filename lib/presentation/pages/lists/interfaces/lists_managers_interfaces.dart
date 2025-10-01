import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import '../models/lists_state.dart';

/// **Interface Segregation Principle (ISP)**
/// Interfaces spécialisées pour chaque responsabilité du système de listes

/// Interface pour la gestion de l'initialisation des listes
///
/// **Responsabilité unique** : Gérer les différentes stratégies d'initialisation
/// **ISP compliant** : Interface focalisée sur l'initialisation uniquement
abstract class IListsInitializationManager {
  /// Initialise le système avec le service adaptatif
  Future<void> initializeAdaptive();

  /// Initialise avec les repositories legacy
  Future<void> initializeLegacy();

  /// Initialise de manière asynchrone (pour tests)
  Future<void> initializeAsync();

  /// Vérifie si l'initialisation est complète
  bool get isInitialized;

  /// Obtient le mode d'initialisation actuel
  String get initializationMode;
}

/// Interface pour la gestion de la persistance des listes
///
/// **Responsabilité unique** : Gérer toutes les opérations CRUD sur les données
/// **ISP compliant** : Interface focalisée sur la persistance uniquement
abstract class IListsPersistenceManager {
  // === Opérations sur les listes ===

  /// Charge toutes les listes depuis la persistance
  Future<List<CustomList>> loadAllLists();

  /// Sauvegarde une liste
  Future<void> saveList(CustomList list);

  /// Met à jour une liste existante
  Future<void> updateList(CustomList list);

  /// Supprime une liste
  Future<void> deleteList(String listId);

  /// Charge les éléments d'une liste spécifique
  Future<List<ListItem>> loadListItems(String listId);

  // === Opérations sur les éléments ===

  /// Sauvegarde un élément de liste
  Future<void> saveListItem(ListItem item);

  /// Met à jour un élément de liste
  Future<void> updateListItem(ListItem item);

  /// Supprime un élément de liste
  Future<void> deleteListItem(String itemId);

  /// Sauvegarde plusieurs éléments en une opération
  Future<void> saveMultipleItems(List<ListItem> items);

  // === Opérations de maintenance ===

  /// Force le rechargement depuis la persistance
  Future<List<CustomList>> forceReloadFromPersistence();

  /// Efface toutes les données
  Future<void> clearAllData();

  /// Vérifie qu'une liste a été correctement persistée
  Future<void> verifyListPersistence(String listId);

  /// Vérifie qu'un élément a été correctement persisté
  Future<void> verifyItemPersistence(String itemId);

  /// Effectue un rollback d'éléments en cas d'échec
  Future<void> rollbackItems(List<ListItem> items);
}

/// Interface pour la gestion du filtrage et tri des listes
///
/// **Responsabilité unique** : Gérer le filtrage, tri et recherche
/// **ISP compliant** : Interface focalisée sur le filtrage uniquement
abstract class IListsFilterManager {
  /// Applique tous les filtres à une collection de listes
  List<CustomList> applyFilters(
    List<CustomList> lists,
    ListsState state,
  );

  /// Filtre par recherche textuelle
  List<CustomList> filterBySearchQuery(
    List<CustomList> lists,
    String searchQuery,
  );

  /// Filtre par type de liste
  List<CustomList> filterByType(
    List<CustomList> lists,
    String? selectedType,
  );

  /// Filtre par statut (terminé/en cours)
  List<CustomList> filterByStatus(
    List<CustomList> lists, {
    required bool showCompleted,
    required bool showInProgress,
  });

  /// Filtre par date
  List<CustomList> filterByDate(
    List<CustomList> lists,
    String? dateFilter,
  );

  /// Applique le tri aux listes
  List<CustomList> sortLists(
    List<CustomList> lists,
    SortOption sortOption,
  );

  /// Efface le cache des filtres
  void clearCache();

  /// Optimise les filtres pour de grandes collections
  List<CustomList> applyOptimizedFilters(
    List<CustomList> lists,
    ListsState state,
  );
}

/// Interface pour la validation et cohérence des données
///
/// **Responsabilité unique** : Valider les données et maintenir leur cohérence
/// **ISP compliant** : Interface focalisée sur la validation uniquement
abstract class IListsValidationService {
  /// Valide qu'une liste est conforme avant sauvegarde
  bool validateList(CustomList list);

  /// Valide qu'un élément est conforme avant sauvegarde
  bool validateListItem(ListItem item);

  /// Valide la cohérence d'un état complet
  bool validateState(ListsState state);

  /// Valide qu'une collection de listes est cohérente
  bool validateListsCollection(List<CustomList> lists);

  /// Obtient les erreurs de validation d'une liste
  List<String> getListValidationErrors(CustomList list);

  /// Obtient les erreurs de validation d'un élément
  List<String> getItemValidationErrors(ListItem item);

  /// Obtient les erreurs de validation d'un état
  List<String> getStateValidationErrors(ListsState state);

  /// Nettoie et corrige automatiquement les données invalides
  List<CustomList> sanitizeLists(List<CustomList> lists);

  /// Vérifie l'intégrité référentielle entre listes et éléments
  bool checkReferentialIntegrity(List<CustomList> lists);
}

/// Interface pour le monitoring et métriques de performance
///
/// **Responsabilité unique** : Surveiller les performances et collecter des métriques
/// **ISP compliant** : Interface focalisée sur le monitoring uniquement
abstract class IListsPerformanceMonitor {
  /// Démarre le monitoring d'une opération
  void startOperation(String operationName);

  /// Termine le monitoring d'une opération
  void endOperation(String operationName);

  /// Obtient les statistiques de performance
  Map<String, dynamic> getPerformanceStats();

  /// Log une erreur avec contexte complet
  void logError(String operation, Object error, [StackTrace? stackTrace]);

  /// Log une information
  void logInfo(String message, {String? context});

  /// Log un avertissement
  void logWarning(String message, {String? context});

  /// Réinitialise toutes les statistiques
  void resetStats();

  /// Surveille les opérations de cache
  void monitorCacheOperation(String operation, bool hit);

  /// Surveille la taille des collections
  void monitorCollectionSize(String collection, int size);

  /// Obtient les métriques détaillées
  Map<String, dynamic> getDetailedMetrics();
}

/// Interface composite pour la coordination entre managers
///
/// **Dependency Inversion Principle (DIP)**
/// Permet l'injection de tous les managers via une interface unifiée
abstract class IListsManagersCoordinator {
  IListsInitializationManager get initializationManager;
  IListsPersistenceManager get persistenceManager;
  IListsFilterManager get filterManager;
  IListsValidationService get validationService;
  IListsPerformanceMonitor get performanceMonitor;

  /// Initialise tous les managers de manière coordonnée
  Future<void> initializeAll();

  /// Nettoie toutes les ressources des managers
  Future<void> cleanupAll();

  /// Vérifie que tous les managers sont correctement initialisés
  bool get areAllManagersReady;
}