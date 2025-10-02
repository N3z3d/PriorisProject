import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

/// Stub for AdaptivePersistenceService
/// This service was referenced but removed during cleanup
/// Keeping minimal interface for compatibility during transition
abstract class AdaptivePersistenceService {
  String get currentMode;

  Future<List<CustomList>> getAllLists();
  Future<void> saveList(CustomList list);
  Future<void> deleteList(String listId);
  Future<List<ListItem>> getItemsByListId(String listId);
  Future<void> saveItem(ListItem item);
  Future<void> updateItem(ListItem item);
  Future<void> deleteItem(String itemId);
}
