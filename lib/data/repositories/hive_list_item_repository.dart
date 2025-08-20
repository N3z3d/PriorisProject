import 'package:hive_flutter/hive_flutter.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';

/// Repository Hive pour la persistance des ListItem
/// 
/// Implémente ListItemRepository en utilisant Hive pour la persistance locale.
/// Les données sont automatiquement sauvegardées et persistent entre les redémarrages.
class HiveListItemRepository implements ListItemRepository {
  static const String _boxName = 'list_items';
  Box<ListItem>? _box;

  /// Initialise le repository Hive
  Future<void> initialize() async {
    if (!Hive.isAdapterRegistered(ListItemAdapter().typeId)) {
      Hive.registerAdapter(ListItemAdapter());
    }
    _box = await Hive.openBox<ListItem>(_boxName);
  }

  /// Vérifie que le box est initialisé
  void _ensureInitialized() {
    if (_box == null || !_box!.isOpen) {
      throw StateError('HiveListItemRepository non initialisé. Appelez initialize() d\'abord.');
    }
  }

  @override
  Future<List<ListItem>> getAll() async {
    _ensureInitialized();
    return _box!.values.toList();
  }

  @override
  Future<ListItem?> getById(String id) async {
    _ensureInitialized();
    return _box!.get(id);
  }

  @override
  Future<ListItem> add(ListItem item) async {
    _ensureInitialized();
    
    if (_box!.containsKey(item.id)) {
      throw StateError('Un item avec cet id existe déjà: ${item.id}');
    }
    
    await _box!.put(item.id, item);
    return item;
  }

  @override
  Future<ListItem> update(ListItem item) async {
    _ensureInitialized();
    
    if (!_box!.containsKey(item.id)) {
      throw StateError('Aucun item avec cet id: ${item.id}');
    }
    
    await _box!.put(item.id, item);
    return item;
  }

  @override
  Future<void> delete(String id) async {
    _ensureInitialized();
    await _box!.delete(id);
  }

  @override
  Future<List<ListItem>> getByListId(String listId) async {
    _ensureInitialized();
    return _box!.values
        .where((item) => item.listId == listId)
        .toList();
  }

  /// Ferme le repository
  Future<void> close() async {
    await _box?.close();
    _box = null;
  }

  /// Vide toutes les données (pour tests/debug)
  Future<void> clear() async {
    _ensureInitialized();
    await _box!.clear();
  }

  /// Retourne le nombre d'éléments stockés
  int get count {
    _ensureInitialized();
    return _box!.length;
  }

  /// Vérifie si le repository est vide
  bool get isEmpty {
    _ensureInitialized();
    return _box!.isEmpty;
  }

  /// Vérifie si le repository contient des données
  bool get isNotEmpty => !isEmpty;
}