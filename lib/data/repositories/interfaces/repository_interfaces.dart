export 'package:prioris/domain/list/repositories/custom_list_repository.dart'
    show
        CustomListCrudRepositoryInterface,
        CustomListSearchRepositoryInterface,
        CustomListFilterRepositoryInterface,
        CustomListCleanRepositoryInterface;

/// Interface pour les opérations CRUD de base sur les repositories
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

