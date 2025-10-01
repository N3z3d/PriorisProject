import 'package:prioris/domain/models/core/entities/list_item.dart';

/// Factory Method Pattern Implementation
///
/// Purpose: Define an interface for creating objects, but let subclasses decide
/// which class to instantiate. Factory Method lets a class defer instantiation
/// to subclasses.

/// Abstract factory interface
abstract class ItemFactory {
  /// Creates an item - the factory method
  ListItem createItem({
    required String title,
    String? description,
    String? category,
  });
}

/// Concrete factory for creating standard list items
class ListItemFactory extends ItemFactory {
  @override
  ListItem createItem({
    required String title,
    String? description,
    String? category,
  }) {
    return ListItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      category: category,
      eloScore: 1200.0,
      createdAt: DateTime.now(),
    );
  }
}

/// Concrete factory for creating high priority items
class HighPriorityItemFactory extends ItemFactory {
  @override
  ListItem createItem({
    required String title,
    String? description,
    String? category,
  }) {
    return ListItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      category: category ?? 'Urgent',
      eloScore: 1400.0, // Higher initial score for urgent items
      createdAt: DateTime.now(),
    );
  }
}

/// Item types enumeration
enum ItemType {
  standard,
  urgent,
  custom,
  unknown,
}

/// Factory Manager - uses Factory Method pattern for runtime factory selection
class ItemFactoryManager {
  final Map<ItemType, ItemFactory> _factories = {};

  ItemFactoryManager() {
    // Register default factories
    _factories[ItemType.standard] = ListItemFactory();
    _factories[ItemType.urgent] = HighPriorityItemFactory();
  }

  /// Register a custom factory
  void registerFactory(ItemType type, ItemFactory factory) {
    _factories[type] = factory;
  }

  /// Create item using appropriate factory
  ListItem createItem(ItemType type, String title, String description, {String? category}) {
    final factory = _factories[type];
    if (factory == null) {
      throw UnsupportedError('No factory registered for type: $type');
    }

    return factory.createItem(
      title: title,
      description: description,
      category: category,
    );
  }

  /// Get available factory types
  List<ItemType> getAvailableTypes() {
    return _factories.keys.toList();
  }
}

/// Example usage class
class ItemCreationService {
  final ItemFactoryManager _factoryManager = ItemFactoryManager();

  /// Create a standard item
  ListItem createStandardItem(String title, [String? description, String? category]) {
    return _factoryManager.createItem(ItemType.standard, title, description ?? '', category: category);
  }

  /// Create an urgent item
  ListItem createUrgentItem(String title, [String? description, String? category]) {
    return _factoryManager.createItem(ItemType.urgent, title, description ?? '', category: category);
  }

  /// Create item by type string
  ListItem createItemByType(String typeString, String title, String description, {String? category}) {
    final type = _parseItemType(typeString);
    return _factoryManager.createItem(type, title, description, category: category);
  }

  /// Get service statistics
  Map<String, dynamic> getServiceStats() {
    return {
      'available_types': _factoryManager.getAvailableTypes().length,
      'registered_factories': _factoryManager.getAvailableTypes().map((t) => t.toString()).toList(),
    };
  }

  ItemType _parseItemType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'standard':
        return ItemType.standard;
      case 'urgent':
        return ItemType.urgent;
      case 'custom':
        return ItemType.custom;
      default:
        throw ArgumentError('Unknown item type: $typeString');
    }
  }
}