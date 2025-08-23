import 'package:uuid/uuid.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

/// Builder pour créer des CustomList facilement
class CustomListBuilder {
  String? _id;
  String? _name;
  String? _description;
  ListType _type = ListType.CUSTOM;
  List<ListItem> _items = [];
  DateTime? _createdAt;
  DateTime? _updatedAt;

  CustomListBuilder();

  CustomListBuilder withId(String id) {
    _id = id;
    return this;
  }

  CustomListBuilder withName(String name) {
    _name = name;
    return this;
  }

  CustomListBuilder withDescription(String? description) {
    _description = description;
    return this;
  }

  CustomListBuilder withType(ListType type) {
    _type = type;
    return this;
  }

  CustomListBuilder withItems(List<ListItem> items) {
    _items = items;
    return this;
  }

  CustomListBuilder withCreatedAt(DateTime createdAt) {
    _createdAt = createdAt;
    return this;
  }

  CustomListBuilder withUpdatedAt(DateTime updatedAt) {
    _updatedAt = updatedAt;
    return this;
  }

  CustomList build() {
    final now = DateTime.now();
    return CustomList(
      id: _id ?? const Uuid().v4(),
      name: _name ?? 'Nouvelle liste',
      description: _description,
      type: _type,
      items: _items,
      createdAt: _createdAt ?? now,
      updatedAt: _updatedAt ?? now,
    );
  }
}