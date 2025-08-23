import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

/// Repository de base avec implémentation générique pour Hive
/// 
/// Implémente le pattern Repository proprement avec séparation
/// claire entre la logique métier et la persistance des données.
abstract class BaseRepository<T> {
  final String boxName;
  Box<T>? _box;

  BaseRepository(this.boxName);

  /// Initialise le repository en ouvrant la box Hive
  Future<void> initialize() async {
    if (!Hive.isBoxOpen(boxName)) {
      _box = await Hive.openBox<T>(boxName);
    } else {
      _box = Hive.box<T>(boxName);
    }
  }

  /// Récupère la box Hive, l'initialise si nécessaire
  Future<Box<T>> get box async {
    if (_box == null || !_box!.isOpen) {
      await initialize();
    }
    return _box!;
  }

  /// Crée une nouvelle entité
  Future<String> create(T entity) async {
    final db = await box;
    final key = const Uuid().v4();
    await db.put(key, entity);
    return key;
  }

  /// Récupère une entité par son ID
  Future<T?> getById(String id) async {
    final db = await box;
    return db.get(id);
  }

  /// Récupère toutes les entités
  Future<List<T>> getAll() async {
    final db = await box;
    return db.values.toList();
  }

  /// Met à jour une entité
  Future<bool> update(String id, T entity) async {
    final db = await box;
    if (db.containsKey(id)) {
      await db.put(id, entity);
      return true;
    }
    return false;
  }

  /// Supprime une entité
  Future<bool> delete(String id) async {
    final db = await box;
    if (db.containsKey(id)) {
      await db.delete(id);
      return true;
    }
    return false;
  }

  /// Supprime toutes les entités
  Future<void> deleteAll() async {
    final db = await box;
    await db.clear();
  }

  /// Compte le nombre d'entités
  Future<int> count() async {
    final db = await box;
    return db.length;
  }

  /// Vérifie si une entité existe
  Future<bool> exists(String id) async {
    final db = await box;
    return db.containsKey(id);
  }

  /// Ferme le repository
  Future<void> close() async {
    await _box?.close();
    _box = null;
  }

  /// Récupère les entités avec pagination
  Future<List<T>> getPaginated({
    required int page,
    required int pageSize,
  }) async {
    final db = await box;
    final allItems = db.values.toList();
    
    final startIndex = page * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, allItems.length);
    
    if (startIndex >= allItems.length) {
      return [];
    }
    
    return allItems.sublist(startIndex, endIndex);
  }

  /// Recherche des entités selon un prédicat
  Future<List<T>> where(bool Function(T) predicate) async {
    final db = await box;
    return db.values.where(predicate).toList();
  }

  /// Récupère la première entité correspondant au prédicat
  Future<T?> firstWhere(
    bool Function(T) predicate, {
    T? Function()? orElse,
  }) async {
    final db = await box;
    try {
      return db.values.firstWhere(predicate);
    } catch (_) {
      return orElse?.call();
    }
  }

  /// Exécute une opération en batch
  Future<void> batch(Future<void> Function(Box<T>) operation) async {
    final db = await box;
    await operation(db);
  }

  /// Observe les changements dans le repository
  Stream<BoxEvent> watch({String? key}) async* {
    final db = await box;
    if (key != null) {
      yield* db.watch(key: key);
    } else {
      yield* db.watch();
    }
  }
}

/// Repository en mémoire pour les tests
class InMemoryRepository<T> extends BaseRepository<T> {
  final Map<String, T> _storage = {};

  InMemoryRepository() : super('in_memory');

  @override
  Future<void> initialize() async {
    // Pas d'initialisation nécessaire pour la version mémoire
  }

  @override
  Future<String> create(T entity) async {
    final key = const Uuid().v4();
    _storage[key] = entity;
    return key;
  }

  @override
  Future<T?> getById(String id) async {
    return _storage[id];
  }

  @override
  Future<List<T>> getAll() async {
    return _storage.values.toList();
  }

  @override
  Future<bool> update(String id, T entity) async {
    if (_storage.containsKey(id)) {
      _storage[id] = entity;
      return true;
    }
    return false;
  }

  @override
  Future<bool> delete(String id) async {
    return _storage.remove(id) != null;
  }

  @override
  Future<void> deleteAll() async {
    _storage.clear();
  }

  @override
  Future<int> count() async {
    return _storage.length;
  }

  @override
  Future<bool> exists(String id) async {
    return _storage.containsKey(id);
  }

  @override
  Future<List<T>> where(bool Function(T) predicate) async {
    return _storage.values.where(predicate).toList();
  }
}