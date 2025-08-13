import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

/// Interface pour les opérations CRUD de base sur les repositories
/// 
/// Respecte le principe Interface Segregation en se concentrant
/// uniquement sur les opérations essentielles.
abstract class BasicCrudRepositoryInterface<T, ID> {
  /// Récupère toutes les entités
  Future<List<T>> getAll();
  
  /// Récupère une entité par son ID
  Future<T?> getById(ID id);
  
  /// Sauvegarde une nouvelle entité
  Future<void> save(T entity);
  
  /// Met à jour une entité existante
  Future<void> update(T entity);
  
  /// Supprime une entité
  Future<void> delete(ID id);
}

/// Interface pour les opérations de recherche sur les repositories
/// 
/// Séparée des opérations CRUD selon le principe Interface Segregation.
abstract class SearchableRepositoryInterface<T> {
  /// Recherche des entités par nom
  Future<List<T>> searchByName(String query);
  
  /// Recherche des entités par description
  Future<List<T>> searchByDescription(String query);
}

/// Interface pour les opérations de filtrage sur les repositories
/// 
/// Séparée des opérations de recherche selon le principe Interface Segregation.
abstract class FilterableRepositoryInterface<T, FilterType> {
  /// Filtre les entités par type
  Future<List<T>> getByType(FilterType type);
}

/// Interface pour les opérations de nettoyage sur les repositories
/// 
/// Séparée des autres opérations selon le principe Interface Segregation.
abstract class CleanableRepositoryInterface {
  /// Supprime toutes les entités (utilisé pour les tests)
  Future<void> clearAll();
}

/// Interface spécialisée pour les listes personnalisées (CRUD)
abstract class CustomListCrudRepositoryInterface 
    extends BasicCrudRepositoryInterface<CustomList, String> {
  
  @override
  Future<List<CustomList>> getAll() => getAllLists();
  
  @override
  Future<CustomList?> getById(String id) => getListById(id);
  
  @override
  Future<void> save(CustomList list) => saveList(list);
  
  @override
  Future<void> update(CustomList list) => updateList(list);
  
  @override
  Future<void> delete(String id) => deleteList(id);
  
  /// Récupère toutes les listes
  Future<List<CustomList>> getAllLists();
  
  /// Récupère une liste par son ID
  Future<CustomList?> getListById(String id);
  
  /// Sauvegarde une nouvelle liste
  Future<void> saveList(CustomList list);
  
  /// Met à jour une liste existante
  Future<void> updateList(CustomList list);
  
  /// Supprime une liste
  Future<void> deleteList(String id);
}

/// Interface spécialisée pour la recherche dans les listes
abstract class CustomListSearchRepositoryInterface 
    extends SearchableRepositoryInterface<CustomList> {
  
  /// Recherche des listes par nom
  @override
  Future<List<CustomList>> searchByName(String query) => searchListsByName(query);
  
  /// Recherche des listes par description
  @override
  Future<List<CustomList>> searchByDescription(String query) => searchListsByDescription(query);
  
  /// Recherche des listes par nom
  Future<List<CustomList>> searchListsByName(String query);
  
  /// Recherche des listes par description
  Future<List<CustomList>> searchListsByDescription(String query);
}

/// Interface spécialisée pour le filtrage des listes
abstract class CustomListFilterRepositoryInterface 
    extends FilterableRepositoryInterface<CustomList, ListType> {
  
  /// Filtre les listes par type
  @override
  Future<List<CustomList>> getByType(ListType type) => getListsByType(type);
  
  /// Filtre les listes par type
  Future<List<CustomList>> getListsByType(ListType type);
}

/// Interface spécialisée pour le nettoyage des listes
abstract class CustomListCleanRepositoryInterface 
    extends CleanableRepositoryInterface {
  
  /// Supprime toutes les listes (utilisé pour les tests)
  @override
  Future<void> clearAll() => clearAllLists();
  
  /// Supprime toutes les listes (utilisé pour les tests)
  Future<void> clearAllLists();
}