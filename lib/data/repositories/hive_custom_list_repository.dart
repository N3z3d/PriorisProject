import 'package:hive_flutter/hive_flutter.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/services/core/error_handling_service.dart';
import 'custom_list_repository.dart';

/// Implémentation Hive pour la persistance locale des listes personnalisées
/// 
/// Cette implémentation utilise les adapters Hive générés automatiquement
/// pour offrir une persistance réelle des données entre les sessions.
class HiveCustomListRepository implements CustomListRepository {
  static const String _boxName = 'custom_lists';
  late Box<CustomList> _box;
  bool _isInitialized = false;
  final ErrorHandlingService _errorService = ErrorHandlingService.defaultInstance();

  // Méthodes de l'interface BasicCrudRepositoryInterface
  @override
  Future<List<CustomList>> getAll() async => getAllLists();

  @override
  Future<CustomList?> getById(String id) async => getListById(id);

  @override
  Future<void> save(CustomList entity) async => saveList(entity);

  @override
  Future<void> update(CustomList entity) async => updateList(entity);

  @override
  Future<void> delete(String id) async => deleteList(id);

  // Méthodes de SearchableRepositoryInterface
  @override
  Future<List<CustomList>> searchByName(String query) async => searchListsByName(query);

  @override
  Future<List<CustomList>> searchByDescription(String query) async => searchListsByDescription(query);

  // Méthodes de FilterableRepositoryInterface
  @override
  Future<List<CustomList>> getByType(ListType type) async => getListsByType(type);

  // Méthodes de CleanableRepositoryInterface
  @override
  Future<void> clearAll() async => clearAllLists();

  /// Initialise la box Hive
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _box = await Hive.openBox<CustomList>(_boxName);
      _isInitialized = true;
    } catch (e, stackTrace) {
      throw _errorService.handleError(
        e,
        context: 'HiveCustomListRepository.initialize',
        stackTrace: stackTrace,
      );
    }
  }

  /// Vérifie que Hive est initialisé
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw _errorService.businessError(
        'HiveCustomListRepository n\'est pas initialisé. Appelez initialize() d\'abord.',
        operation: 'ensureInitialized',
      );
    }
  }

  @override
  Future<List<CustomList>> getAllLists() async {
    _ensureInitialized();
    
    try {
      final lists = _box.values.toList();
      
      // Trier par date de création (plus récent en premier)
      lists.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return lists;
    } catch (e, stackTrace) {
      throw _errorService.handleError(
        e,
        context: 'HiveCustomListRepository.getAllLists',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<CustomList?> getListById(String id) async {
    _ensureInitialized();
    
    try {
      return _box.get(id);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la liste $id: $e');
    }
  }

  @override
  Future<void> saveList(CustomList list) async {
    _ensureInitialized();
    _validateList(list, isNew: true);
    
    try {
      await _box.put(list.id, list);
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde de la liste: $e');
    }
  }

  @override
  Future<void> updateList(CustomList list) async {
    _ensureInitialized();
    
    if (!_box.containsKey(list.id)) {
      throw Exception('Liste non trouvée');
    }
    
    _validateList(list, isNew: false);
    
    try {
      await _box.put(list.id, list);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la liste: $e');
    }
  }

  @override
  Future<void> deleteList(String id) async {
    _ensureInitialized();
    
    try {
      await _box.delete(id);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la liste: $e');
    }
  }

  @override
  Future<List<CustomList>> getListsByType(ListType type) async {
    final allLists = await getAllLists();
    return allLists.where((list) => list.type == type).toList();
  }

  @override
  Future<List<CustomList>> searchListsByName(String query) async {
    final allLists = await getAllLists();
    final lowercaseQuery = query.toLowerCase();
    return allLists
        .where((list) => list.name.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  @override
  Future<List<CustomList>> searchListsByDescription(String query) async {
    final allLists = await getAllLists();
    final lowercaseQuery = query.toLowerCase();
    return allLists
        .where((list) => list.description?.toLowerCase().contains(lowercaseQuery) == true)
        .toList();
  }

  @override
  Future<void> clearAllLists() async {
    _ensureInitialized();
    
    try {
      await _box.clear();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de toutes les listes: $e');
    }
  }

  /// Ferme la box Hive (à appeler lors de l'arrêt de l'application)
  Future<void> dispose() async {
    if (_isInitialized && _box.isOpen) {
      await _box.close();
      _isInitialized = false;
    }
  }

  /// Validation des données avant sauvegarde
  void _validateList(CustomList list, {required bool isNew}) {
    // ID requis
    if (list.id.isEmpty) {
      throw ArgumentError('L\'ID de la liste ne peut pas être vide');
    }

    // Nom requis
    if (list.name.trim().isEmpty) {
      throw ArgumentError('Le nom de la liste ne peut pas être vide');
    }

    // ID unique lors de la création
    if (isNew && _box.containsKey(list.id)) {
      throw Exception('Une liste avec cet ID existe déjà');
    }

    // Cohérence des dates
    if (list.updatedAt.isBefore(list.createdAt)) {
      throw ArgumentError('updatedAt doit être postérieur à createdAt');
    }
  }

  /// Statistiques de la box Hive (pour debug/monitoring)
  Future<Map<String, dynamic>> getStats() async {
    _ensureInitialized();
    
    return {
      'totalLists': _box.length,
      'boxSize': _box.values.length,
      'isOpen': _box.isOpen,
      'path': _box.path,
      'name': _box.name,
    };
  }

  /// Compacte la base de données Hive (optimisation)
  Future<void> compact() async {
    _ensureInitialized();
    
    try {
      await _box.compact();
    } catch (e) {
      throw Exception('Erreur lors de la compaction: $e');
    }
  }
} 
