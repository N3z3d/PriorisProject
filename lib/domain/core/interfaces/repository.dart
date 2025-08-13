import '../aggregates/aggregate_root.dart';
import '../specifications/specification.dart';

/// Interface de base pour tous les repositories du domaine
/// 
/// Les repositories sont responsables de l'accès aux données et
/// doivent implémenter cette interface dans la couche d'infrastructure.
abstract class Repository<T extends AggregateRoot> {
  /// Sauvegarde un agrégat
  Future<void> save(T aggregate);

  /// Récupère un agrégat par son identifiant
  Future<T?> findById(String id);

  /// Supprime un agrégat
  Future<void> delete(String id);

  /// Vérifie si un agrégat existe
  Future<bool> exists(String id);

  /// Récupère tous les agrégats
  Future<List<T>> findAll();

  /// Récupère des agrégats selon une spécification
  Future<List<T>> findBySpecification(Specification<T> specification);

  /// Compte le nombre d'agrégats correspondant à une spécification
  Future<int> countBySpecification(Specification<T> specification);
}

/// Interface pour les repositories avec pagination
abstract class PaginatedRepository<T extends AggregateRoot> extends Repository<T> {
  /// Récupère une page d'agrégats
  Future<PageResult<T>> findPage({
    int page = 1,
    int pageSize = 20,
    Specification<T>? specification,
    List<SortCriteria>? sortCriteria,
  });
}

/// Interface pour les repositories avec recherche textuelle
abstract class SearchableRepository<T extends AggregateRoot> extends Repository<T> {
  /// Recherche textuelle dans les agrégats
  Future<List<T>> search(String query, {int limit = 50});

  /// Recherche avec suggestions
  Future<SearchResult<T>> searchWithSuggestions(String query);
}

/// Interface pour les repositories avec cache
abstract class CachedRepository<T extends AggregateRoot> extends Repository<T> {
  /// Invalide le cache pour un agrégat
  Future<void> invalidateCache(String id);

  /// Invalide tout le cache
  Future<void> clearCache();

  /// Précharge des agrégats dans le cache
  Future<void> preloadCache(List<String> ids);
}

/// Résultat paginé
class PageResult<T> {
  final List<T> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PageResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
  }) : hasNextPage = (pageNumber * pageSize) < totalCount,
       hasPreviousPage = pageNumber > 1;

  int get totalPages => (totalCount / pageSize).ceil();
}

/// Critères de tri
class SortCriteria {
  final String fieldName;
  final SortDirection direction;

  const SortCriteria({
    required this.fieldName,
    this.direction = SortDirection.ascending,
  });
}

enum SortDirection { ascending, descending }

/// Résultat de recherche avec suggestions
class SearchResult<T> {
  final List<T> results;
  final List<String> suggestions;
  final int totalMatches;
  final String originalQuery;

  const SearchResult({
    required this.results,
    required this.suggestions,
    required this.totalMatches,
    required this.originalQuery,
  });
}

/// Exception de repository
class RepositoryException implements Exception {
  final String message;
  final String? repositoryName;
  final Object? cause;

  const RepositoryException(this.message, {this.repositoryName, this.cause});

  @override
  String toString() {
    final repo = repositoryName != null ? ' in $repositoryName' : '';
    return 'RepositoryException$repo: $message';
  }
}

/// Exception pour les agrégats non trouvés
class AggregateNotFoundException extends RepositoryException {
  final String aggregateId;
  final String aggregateType;

  const AggregateNotFoundException(this.aggregateId, this.aggregateType)
      : super('$aggregateType with ID $aggregateId not found');
}

/// Exception pour les conflits de concurrence
class ConcurrencyConflictException extends RepositoryException {
  final String aggregateId;
  final int expectedVersion;
  final int actualVersion;

  const ConcurrencyConflictException(
    this.aggregateId,
    this.expectedVersion,
    this.actualVersion,
  ) : super('Concurrency conflict for aggregate $aggregateId: expected version $expectedVersion, actual $actualVersion');
}