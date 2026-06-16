import 'package:hive_flutter/hive_flutter.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/services/core/error_handling_service.dart';
import 'package:prioris/domain/list/repositories/custom_list_repository.dart';

/// Implémentation Hive pour la persistance locale des listes personnalisées
/// 
/// Cette implémentation utilise les adapters Hive générés automatiquement
/// pour offrir une persistance réelle des données entre les sessions.
class HiveCustomListRepository extends CustomListRepository {
  static const String _boxName = 'custom_lists';
  late Box<CustomList> _box;
  bool _isInitialized = false;
  final ErrorHandlingService _errorService = ErrorHandlingService.defaultInstance();

  /// Initialise la box Hive
  Future<void> initialize() async {
    if (_isInitialized && _box.isOpen) return;
    
    try {
      // Si une box existe mais est fermée, essayer de la rouvrir
      if (_isInitialized && !_box.isOpen) {
        _box = await Hive.openBox<CustomList>(_boxName);
      } else {
        _box = await Hive.openBox<CustomList>(_boxName);
        _isInitialized = true;
      }
    } catch (e, stackTrace) {
      throw _errorService.handleError(
        e,
        context: 'HiveCustomListRepository.initialize',
        stackTrace: stackTrace,
      );
    }
  }
  
  /// Réinitialise le repository (pour recovery après erreur)
  Future<void> reinitialize() async {
    _isInitialized = false;
    await initialize();
  }

  /// Vérifie que Hive est initialisé et que la box est ouverte
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      throw _errorService.businessError(
        'HiveCustomListRepository n\'est pas initialisé. Appelez initialize() d\'abord.',
        operation: 'ensureInitialized',
      );
    }
    
    if (!_box.isOpen) {
      // CRITICAL FIX: Attempt automatic recovery when box is closed
      try {
        print('🔄 Auto-recovering closed Hive box...');
        _box = await Hive.openBox<CustomList>(_boxName);
        print('✅ Hive box auto-recovery successful');
      } catch (e) {
        throw _errorService.businessError(
          'La box Hive est fermée et la récupération automatique a échoué: $e',
          operation: 'autoRecovery',
        );
      }
    }
  }

  @override
  Future<List<CustomList>> getAllLists() async {
    await _ensureInitialized();
    
    try {
      final lists = _box.values.toList();
      
      // ARCHITECTURE FIX: Utiliser le repository partagé via Provider
      // Ne pas créer une nouvelle instance
      final listsWithItems = <CustomList>[];
      for (final list in lists) {
        // Les items seront chargés par le repository partagé
        // Cette méthode ne charge que la structure des listes
        listsWithItems.add(list);
      }
      
      // Trier par date de création (plus récent en premier)
      listsWithItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return listsWithItems;
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
    await _ensureInitialized();
    
    try {
      final list = _box.get(id);
      if (list == null) return null;
      
      // ARCHITECTURE FIX: Retourner la liste sans charger les items ici
      // Les items seront gérés par la couche controller avec le repository partagé
      return list;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la liste $id: $e');
    }
  }

  @override
  Future<void> saveList(CustomList list) async {
    await _ensureInitialized();
    _validateList(list, isNew: true);
    
    try {
      await _box.put(list.id, list);
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde de la liste: $e');
    }
  }

  @override
  Future<void> updateList(CustomList list) async {
    await _ensureInitialized();
    
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
    await _ensureInitialized();
    
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
    await _ensureInitialized();
    
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

    // ID unique lors de la création - SEULEMENT si la box est ouverte
    if (isNew && _isInitialized && _box.isOpen && _box.containsKey(list.id)) {
      throw Exception('Une liste avec cet ID existe déjà');
    }

    // Cohérence des dates
    if (list.updatedAt.isBefore(list.createdAt)) {
      throw ArgumentError('updatedAt doit être postérieur à createdAt');
    }
  }

  /// Métriques de diagnostic de la box Hive (debug/monitoring) — non lié au contrat du port domaine
  Future<Map<String, dynamic>> getDiagnostics() async {
    await _ensureInitialized();
    
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
    await _ensureInitialized();
    
    try {
      await _box.compact();
    } catch (e) {
      throw Exception('Erreur lors de la compaction: $e');
    }
  }
} 
