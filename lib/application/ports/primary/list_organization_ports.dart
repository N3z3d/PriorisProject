/// HEXAGONAL ARCHITECTURE - PRIMARY PORTS
/// List Organization Use Case Interfaces
///
/// Primary ports for list management and organization capabilities.
/// These define how external systems interact with our List domain.

import '../../../domain/models/core/entities/custom_list.dart';
import '../../../domain/models/core/entities/list_item.dart';
import '../../../domain/models/core/enums/list_enums.dart';
import '../../../domain/core/value_objects/export.dart';

/// List Management Port
/// Core list CRUD operations
abstract class IListManagementPort {
  Future<CustomList> createList({
    required String name,
    String? description,
    ListType type = ListType.CUSTOM,
  });

  Future<List<CustomList>> getAllLists();
  Future<CustomList?> getListById(String listId);
  Future<CustomList> updateList(String listId, {
    String? name,
    String? description,
    ListType? type,
  });
  Future<void> deleteList(String listId);
}

/// List Item Management Port
/// Operations on individual list items
abstract class IListItemPort {
  Future<ListItem> addItemToList({
    required String listId,
    required String title,
    String? description,
    Priority? priority,
  });

  Future<List<ListItem>> getItemsByListId(String listId);
  Future<ListItem> updateListItem(String itemId, {
    String? title,
    String? description,
    Priority? priority,
    bool? isCompleted,
  });
  Future<void> deleteListItem(String itemId);
  Future<void> moveItemToList(String itemId, String targetListId);
}

/// List Analytics Port
/// List insights and analytics
abstract class IListAnalyticsPort {
  Future<Map<String, dynamic>> getListStatistics(String listId);
  Future<double> getOverallProgress();
  Future<List<CustomList>> getMostProductiveLists();
  Future<Map<String, int>> getListTypeDistribution();
}

/// Combined List Organization Port
abstract class IListOrganizationPort
    implements IListManagementPort, IListItemPort, IListAnalyticsPort {
  String get portName => 'ListOrganization';
  String get version => '1.0.0';

  Future<bool> isHealthy();
  Future<void> initialize();
  Future<void> dispose();
}