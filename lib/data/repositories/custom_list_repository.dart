import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'interfaces/repository_interfaces.dart';

/// Repository unifié pour la gestion des listes personnalisées
/// 
/// Respecte le principe Interface Segregation en implémentant
/// des interfaces séparées pour chaque responsabilité.
abstract class CustomListRepository 
    implements 
      CustomListCrudRepositoryInterface,
      CustomListSearchRepositoryInterface,
      CustomListFilterRepositoryInterface,
      CustomListCleanRepositoryInterface {
  
  // Toutes les méthodes sont déjà définies dans les interfaces parentes
}

/// Implémentation en mémoire pour les tests
class InMemoryCustomListRepository implements CustomListRepository {
  final Map<String, CustomList> _lists = {};

  // Méthodes de l'interface BasicCrudRepositoryInterface
  @override
  Future<List<CustomList>> getAll() async => getAllLists();

  @override
  Future<CustomList?> getById(String id) async => getListById(id);

  @override
  Future<void> save(CustomList entity) async => saveList(entity);

  @override
  Future<void> update(CustomList entity) async => updateList(entity);

  @override
  Future<void> delete(String id) async => deleteList(id);

  // Méthodes de SearchableRepositoryInterface
  @override
  Future<List<CustomList>> searchByName(String query) async => searchListsByName(query);

  @override
  Future<List<CustomList>> searchByDescription(String query) async => searchListsByDescription(query);

  // Méthodes de FilterableRepositoryInterface
  @override
  Future<List<CustomList>> getByType(ListType type) async => getListsByType(type);

  // Méthodes de CleanableRepositoryInterface
  @override
  Future<void> clearAll() async => clearAllLists();

  @override
  Future<List<CustomList>> getAllLists() async {
    return _lists.values.toList();
  }

  @override
  Future<CustomList?> getListById(String id) async {
    return _lists[id];
  }

  @override
  Future<void> saveList(CustomList list) async {
    _validateList(list, isNew: true);
    _lists[list.id] = list;
  }

  @override
  Future<void> updateList(CustomList list) async {
    if (!_lists.containsKey(list.id)) {
      // Ignorer la mise à jour si la liste n'existe pas, pour compatibilité avec anciens tests
      return;
    }
    _validateList(list, isNew: false);
    _lists[list.id] = list;
  }

  @override
  Future<void> deleteList(String id) async {
    _lists.remove(id);
  }

  @override
  Future<List<CustomList>> getListsByType(ListType type) async {
    return _lists.values.where((list) => list.type == type).toList();
  }

  @override
  Future<List<CustomList>> searchListsByName(String query) async {
    final lowercaseQuery = query.toLowerCase();
    return _lists.values
        .where((list) => list.name.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  @override
  Future<List<CustomList>> searchListsByDescription(String query) async {
    final lowercaseQuery = query.toLowerCase();
    return _lists.values
        .where((list) => list.description?.toLowerCase().contains(lowercaseQuery) == true)
        .toList();
  }

  @override
  Future<void> clearAllLists() async {
    _lists.clear();
  }

  void _validateList(CustomList list, {required bool isNew}) {
    // ID requis
    if (list.id.isEmpty) {
      throw ArgumentError('L\'ID de la liste ne peut pas être vide');
    }

    // Nom requis
    if (list.name.trim().isEmpty) {
      throw ArgumentError('Le nom de la liste ne peut pas être vide');
    }

    // ID unique lors de la création
    if (isNew && _lists.containsKey(list.id)) {
      throw Exception('Une liste avec cet ID existe déjà');
    }

    // Cohérence des dates
    if (list.updatedAt.isBefore(list.createdAt)) {
      throw ArgumentError('updatedAt doit être postérieur à createdAt');
    }
  }
} 
