import 'package:prioris/domain/models/core/entities/list_item.dart';

enum ItemType { standard, urgent, custom, unknown }

abstract class ItemFactory {
  ListItem createItem({
    required String title,
    String? description,
    String? category,
  });

  double get defaultScore => 1200.0;

  ListItem buildItem({
    required String title,
    String? description,
    String? category,
    double? eloScore,
  }) {
    return ListItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      description: description,
      category: category,
      eloScore: eloScore ?? defaultScore,
      createdAt: DateTime.now(),
    );
  }
}

class ListItemFactory extends ItemFactory {
  @override
  ListItem createItem({
    required String title,
    String? description,
    String? category,
  }) {
    return buildItem(
      title: title,
      description: description,
      category: category,
    );
  }
}

class HighPriorityItemFactory extends ItemFactory {
  @override
  double get defaultScore => 1400.0;

  @override
  ListItem createItem({
    required String title,
    String? description,
    String? category,
  }) {
    return buildItem(
      title: title,
      description: description,
      category: category ?? 'Urgent',
      eloScore: defaultScore,
    );
  }
}

class ItemFactoryManager {
  final Map<ItemType, ItemFactory> _factories = {
    ItemType.standard: ListItemFactory(),
    ItemType.urgent: HighPriorityItemFactory(),
  };

  ListItem createItem(
    ItemType type,
    String title,
    String description, {
    String? category,
  }) {
    final factory = _factories[type];
    if (factory == null) {
      throw UnsupportedError('No factory registered for item type "$type".');
    }
    return factory.createItem(
      title: title,
      description: description,
      category: category,
    );
  }

  void registerFactory(ItemType type, ItemFactory factory) {
    _factories[type] = factory;
  }

  List<ItemType> getAvailableTypes() {
    return List<ItemType>.unmodifiable(
      _factories.keys.where((type) => type != ItemType.custom),
    );
  }
}
