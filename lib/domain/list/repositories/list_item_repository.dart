import 'package:prioris/domain/models/core/entities/list_item.dart';

/// Port domaine pour la gestion des éléments de liste
abstract class ListItemRepository {
  Future<List<ListItem>> getAll();
  Future<ListItem?> getById(String id);
  Future<ListItem> add(ListItem item);
  Future<ListItem> update(ListItem item);
  Future<void> delete(String id);
  Future<List<ListItem>> getByListId(String listId);
}
