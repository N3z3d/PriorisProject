import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'interfaces/list_service_interface.dart';

/// Service CRUD pour les listes personnalisées
/// 
/// Respecte le principe Single Responsibility en se concentrant
/// uniquement sur les opérations CRUD de base.
class CustomListCrudService implements ListCrudInterface {
  final CustomListRepository _repository;

  CustomListCrudService(this._repository);

  @override
  Future<List<CustomList>> getAllLists() => _repository.getAllLists();

  @override
  Future<void> addList(CustomList list) => _repository.saveList(list);

  @override
  Future<void> updateList(CustomList list) => _repository.updateList(list);

  @override
  Future<void> deleteList(String listId) => _repository.deleteList(listId);

  @override
  Future<void> clearAllLists() => _repository.clearAllLists();
}

/// Service de recherche et filtrage pour les listes
/// 
/// Séparé du service CRUD selon le principe Single Responsibility.
class CustomListSearchService implements ListSearchInterface {
  final CustomListRepository _repository;

  CustomListSearchService(this._repository);

  @override
  Future<List<CustomList>> getListsByType(ListType type) => 
      _repository.getListsByType(type);

  @override
  Future<List<CustomList>> searchLists(String keyword) async {
    final lists = await _repository.getAllLists();
    final lower = keyword.toLowerCase();
    return lists.where((l) =>
      l.name.toLowerCase().contains(lower) ||
      (l.description?.toLowerCase().contains(lower) ?? false)
    ).toList();
  }
}

/// Service de statistiques pour les listes
/// 
/// Séparé des autres services selon le principe Single Responsibility.
class CustomListStatsService implements ListStatsInterface {
  final CustomListRepository _repository;

  CustomListStatsService(this._repository);

  @override
  Future<double> getGlobalProgress() async {
    final lists = await _repository.getAllLists();
    if (lists.isEmpty) return 0.0;
    final totalItems = lists.fold<int>(0, (sum, l) => sum + l.itemCount);
    if (totalItems == 0) return 0.0;
    final completedItems = lists.fold<int>(0, (sum, l) => sum + l.completedCount);
    return completedItems / totalItems;
  }

  @override
  Future<Map<String, dynamic>> getStats() async {
    final lists = await _repository.getAllLists();
    final total = lists.length;
    final totalItems = lists.fold<int>(0, (sum, l) => sum + l.itemCount);
    final completedItems = lists.fold<int>(0, (sum, l) => sum + l.completedCount);
    final avgProgress = total == 0 ? 0.0 : lists.map((l) => l.getProgress()).reduce((a, b) => a + b) / total;
    return {
      'totalLists': total,
      'totalItems': totalItems,
      'completedItems': completedItems,
      'averageProgress': avgProgress,
    };
  }
}

/// Service composite pour les listes personnalisées
/// 
/// Combine les différents services spécialisés tout en respectant
/// le principe de composition over inheritance.
class CustomListService {
  final ListCrudInterface _crudService;
  final ListSearchInterface _searchService;
  final ListStatsInterface _statsService;

  CustomListService(
    this._crudService,
    this._searchService,
    this._statsService,
  );

  // Délégation vers les services spécialisés
  Future<List<CustomList>> getAllLists() => _crudService.getAllLists();
  Future<void> addList(CustomList list) => _crudService.addList(list);
  Future<void> updateList(CustomList list) => _crudService.updateList(list);
  Future<void> deleteList(String listId) => _crudService.deleteList(listId);
  Future<void> clearAllLists() => _crudService.clearAllLists();
  
  Future<List<CustomList>> getListsByType(ListType type) => 
      _searchService.getListsByType(type);
  Future<List<CustomList>> searchLists(String keyword) => 
      _searchService.searchLists(keyword);
      
  Future<double> getGlobalProgress() => _statsService.getGlobalProgress();
  Future<Map<String, dynamic>> getStats() => _statsService.getStats();
}

/// Service métier pour la gestion avancée des listes personnalisées (DEPRECATED)
/// 
/// Utilisez CustomListService à la place pour respecter les principes SOLID.
@Deprecated('Utilisez CustomListService à la place pour respecter les principes SOLID.')
class LegacyCustomListService {
  final CustomListRepository repository;

  LegacyCustomListService(this.repository);

  /// Retourne toutes les listes
  Future<List<CustomList>> getAllLists() => repository.getAllLists();

  /// Ajoute une nouvelle liste
  Future<void> addList(CustomList list) => repository.saveList(list);

  /// Met à jour une liste existante
  Future<void> updateList(CustomList list) => repository.updateList(list);

  /// Supprime une liste par son ID
  Future<void> deleteList(String listId) => repository.deleteList(listId);

  /// Recherche les listes par type
  Future<List<CustomList>> getListsByType(ListType type) => repository.getListsByType(type);

  /// Supprime toutes les listes
  Future<void> clearAllLists() => repository.clearAllLists();

  /// Calcule la progression globale sur toutes les listes
  Future<double> getGlobalProgress() async {
    final lists = await repository.getAllLists();
    if (lists.isEmpty) return 0.0;
    final totalItems = lists.fold<int>(0, (sum, l) => sum + l.itemCount);
    if (totalItems == 0) return 0.0;
    final completedItems = lists.fold<int>(0, (sum, l) => sum + l.completedCount);
    return completedItems / totalItems;
  }

  /// Recherche les listes contenant un mot-clé dans le nom ou la description
  Future<List<CustomList>> searchLists(String keyword) async {
    final lists = await repository.getAllLists();
    final lower = keyword.toLowerCase();
    return lists.where((l) =>
      l.name.toLowerCase().contains(lower) ||
      (l.description?.toLowerCase().contains(lower) ?? false)
    ).toList();
  }

  /// Retourne des statistiques globales sur les listes
  Future<Map<String, dynamic>> getStats() async {
    final lists = await repository.getAllLists();
    final total = lists.length;
    final totalItems = lists.fold<int>(0, (sum, l) => sum + l.itemCount);
    final completedItems = lists.fold<int>(0, (sum, l) => sum + l.completedCount);
    final avgProgress = total == 0 ? 0.0 : lists.map((l) => l.getProgress()).reduce((a, b) => a + b) / total;
    return {
      'totalLists': total,
      'totalItems': totalItems,
      'completedItems': completedItems,
      'averageProgress': avgProgress,
    };
  }
} 
