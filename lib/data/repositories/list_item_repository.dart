export 'package:prioris/domain/list/repositories/list_item_repository.dart';
import 'package:prioris/domain/list/repositories/list_item_repository.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

/// Implémentation en mémoire du repository (pour tests/démo)
class InMemoryListItemRepository implements ListItemRepository {
  final List<ListItem> _items = [];

  @override
  Future<List<ListItem>> getAll() async {
    return List.unmodifiable(_items);
  }

  @override
  Future<ListItem?> getById(String id) async {
    return _items.firstWhereOrNull((item) => item.id == id);
  }

  @override
  Future<ListItem> add(ListItem item) async {
    if (_items.any((i) => i.id == item.id)) {
      throw StateError('Un item avec cet id existe déjà');
    }
    _items.add(item);
    return item;
  }

  @override
  Future<ListItem> update(ListItem item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index == -1) {
      throw StateError('Aucun item avec cet id');
    }
    _items[index] = item;
    return item;
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((item) => item.id == id);
  }
  
  @override
  Future<List<ListItem>> getByListId(String listId) async {
    return _items.where((item) => item.listId == listId).toList();
  }
}

extension _FirstWhereOrNull<E> on List<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
} 
