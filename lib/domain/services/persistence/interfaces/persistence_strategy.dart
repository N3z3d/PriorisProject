import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

/// Strategy interface for persistence operations following Strategy Pattern
/// Allows different persistence implementations to be swapped at runtime
abstract class PersistenceStrategy {
  /// Saves a list using the specific strategy
  Future<void> saveList(CustomList list);
  
  /// Retrieves all lists using the specific strategy
  Future<List<CustomList>> getAllLists();
  
  /// Deletes a list using the specific strategy
  Future<void> deleteList(String listId);
  
  /// Saves an item using the specific strategy
  Future<void> saveItem(ListItem item);
  
  /// Retrieves items by list ID using the specific strategy
  Future<List<ListItem>> getItemsByListId(String listId);
  
  /// Updates an item using the specific strategy
  Future<void> updateItem(ListItem item);
  
  /// Deletes an item using the specific strategy
  Future<void> deleteItem(String itemId);
  
  /// Handles authentication state changes
  Future<void> handleAuthenticationChange(bool isAuthenticated);
  
  /// Gets the strategy name for logging/debugging
  String get strategyName;
}
