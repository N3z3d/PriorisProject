import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

/// Port domaine — sous-interface CRUD pour les listes personnalisées (ISP)
abstract class CustomListCrudRepositoryInterface {
  Future<List<CustomList>> getAllLists();
  Future<CustomList?> getListById(String id);
  Future<void> saveList(CustomList list);
  Future<void> updateList(CustomList list);
  Future<void> deleteList(String id);
}

/// Port domaine — sous-interface recherche (ISP)
abstract class CustomListSearchRepositoryInterface {
  Future<List<CustomList>> searchListsByName(String query);
  Future<List<CustomList>> searchListsByDescription(String query);
}

/// Port domaine — sous-interface filtrage (ISP)
abstract class CustomListFilterRepositoryInterface {
  Future<List<CustomList>> getListsByType(ListType type);
}

/// Port domaine — sous-interface nettoyage (ISP)
abstract class CustomListCleanRepositoryInterface {
  Future<void> clearAllLists();
}

/// Port domaine principal pour la gestion des listes personnalisées
abstract class CustomListRepository
    implements
        CustomListCrudRepositoryInterface,
        CustomListSearchRepositoryInterface,
        CustomListFilterRepositoryInterface,
        CustomListCleanRepositoryInterface {
  Future<Map<String, dynamic>> getStats() async {
    final lists = await getAllLists();
    final completed = lists.where((list) => list.isCompleted).length;
    final itemCount = lists.fold<int>(0, (count, list) => count + list.items.length);
    return {'count': lists.length, 'completed': completed, 'items': itemCount};
  }
}
