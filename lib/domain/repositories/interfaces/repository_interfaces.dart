/// Repository Interfaces - SOLID Architecture
/// Defines contracts for data access layer following Dependency Inversion Principle

import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

/// Interface for CustomList repository operations
abstract class ICustomListRepository {
  Future<List<CustomList>> getAllLists();
  Future<List<CustomList>> getAll(); // Alias for migration compatibility
  Future<CustomList?> getListById(String id);
  Future<CustomList?> getById(String id); // Alias for migration compatibility
  Future<CustomList> addList(CustomList list);
  Future<CustomList> add(CustomList list); // Alias for migration compatibility
  Future<CustomList> updateList(CustomList list);
  Future<CustomList> update(CustomList list); // Alias for migration compatibility
  Future<void> deleteList(String id);
  Future<void> delete(String id); // Alias for migration compatibility
  Future<void> clearAll();
}

/// Interface for ListItem repository operations
abstract class IListItemRepository {
  Future<List<ListItem>> getByListId(String listId);
  Future<ListItem?> getById(String id);
  Future<ListItem> add(ListItem item);
  Future<ListItem> update(ListItem item);
  Future<void> delete(String id);
  Future<void> deleteByListId(String listId);
  Future<void> clearAll();
}

/// Authentication state management interface
abstract class IAuthenticationStateManager {
  bool get isAuthenticated;
  String? get currentUserId;
  Future<void> signOut();
  Stream<bool> get authStateChanges;
}

/// Data migration service interface
abstract class IDataMigrationService {
  Future<bool> migrateData();
  bool get needsMigration;
  String get currentVersion;
}

/// Deduplication service interface
abstract class IDeduplicationService {
  List<CustomList> deduplicateLists(List<CustomList> lists);
  List<ListItem> deduplicateItems(List<ListItem> items);
}