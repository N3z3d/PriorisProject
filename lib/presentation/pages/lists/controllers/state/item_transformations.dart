import 'package:prioris/domain/models/core/entities/list_item.dart';

typedef ItemTransformation = List<ListItem> Function(List<ListItem>);

class ItemTransformations {
  const ItemTransformations._();

  static ItemTransformation append(ListItem item) =>
      (items) => [...items, item];

  static ItemTransformation appendMany(List<ListItem> itemsToAdd) =>
      (items) => [...items, ...itemsToAdd];

  static ItemTransformation replace(ListItem replacement) => (items) => [
        for (final item in items)
          if (item.id == replacement.id) replacement else item,
      ];

  static ItemTransformation remove(String itemId) =>
      (items) => items.where((item) => item.id != itemId).toList();
}
