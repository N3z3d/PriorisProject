/// STUB: Adaptive Persistence Service
/// This file was missing from the codebase but referenced by lists_persistence_service.dart
/// Created as minimal stub to allow compilation and testing

import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

/// Abstract interface for adaptive persistence
/// NOTE: This should be replaced with IUnifiedPersistenceService in the future
abstract class AdaptivePersistenceService {
  Future<List<CustomList>> getAllLists();
  Future<void> saveList(CustomList list);
  Future<void> deleteList(String listId);
  Future<List<ListItem>> getItemsByListId(String listId);
  Future<void> saveItem(ListItem item);
  Future<void> updateItem(ListItem item);
  Future<void> deleteItem(String itemId);
}
