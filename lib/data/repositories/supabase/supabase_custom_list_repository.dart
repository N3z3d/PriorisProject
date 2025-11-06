import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/infrastructure/services/auth_service.dart';
import 'package:prioris/infrastructure/services/supabase_service.dart';
import 'package:prioris/infrastructure/services/supabase_table_adapter.dart';

import '../custom_list_repository.dart';

/// Repository Supabase pour les listes personnalisées
/// DI-friendly: Dependencies injected via constructor
class SupabaseCustomListRepository implements CustomListRepository {
  final SupabaseService _supabase;
  final AuthService _auth;
  final SupabaseTableAdapterFactory _tableFactory;

  static const String _tableName = 'custom_lists';

  /// Constructor with dependency injection
  SupabaseCustomListRepository({
    SupabaseService? supabaseService,
    AuthService? authService,
    SupabaseTableAdapterFactory? tableFactory,
  })  : _supabase = supabaseService ?? SupabaseService.instance,
        _auth = authService ?? AuthService.instance,
        _tableFactory = tableFactory ?? defaultSupabaseTableFactory;

  /// Factory constructor for legacy compatibility (deprecated)
  @Deprecated('Use constructor with DI instead')
  factory SupabaseCustomListRepository.withDefaults() => SupabaseCustomListRepository(
    supabaseService: SupabaseService.instance,
    authService: AuthService.instance,
  );

  // Méthodes héritées de BasicCrudRepositoryInterface
  @override
  Future<List<CustomList>> getAll() => getAllLists();

  @override
  Future<CustomList?> getById(String id) => getListById(id);

  @override
  Future<void> save(CustomList entity) => saveList(entity);

  @override
  Future<void> update(CustomList entity) => updateList(entity);

  @override
  Future<void> delete(String id) => deleteList(id);

  @override
  Future<List<CustomList>> getAllLists() async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      final response = await _table().select(
        builder: (query) => query
            .eq('user_id', _auth.currentUser!.id)
            .eq('is_deleted', false)
            .order('created_at', ascending: false),
      );

      return response.map<CustomList>((json) => CustomList.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch lists: $e');
    }
  }

  @override
  Future<CustomList?> getListById(String id) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      final response = await _table().selectSingle(
        builder: (query) => query
            .eq('id', id)
            .eq('user_id', _auth.currentUser!.id)
            .eq('is_deleted', false),
      );

      return response != null ? CustomList.fromJson(response) : null;
    } catch (e) {
      throw Exception('Failed to fetch list by id: $e');
    }
  }

  @override
  Future<void> saveList(CustomList list) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      final listData = list.toJson();
      listData['user_id'] = _auth.currentUser!.id;
      listData['user_email'] = _auth.currentUser!.email;
      // Remove items from JSON as they're stored separately in list_items table
      listData.remove('items');
      
      await _table().insert(listData);
    } catch (e) {
      throw Exception('Failed to create list: $e');
    }
  }

  @override
  Future<void> updateList(CustomList list) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      final listData = list.toJson();
      // Remove items from JSON as they're stored separately in list_items table
      listData.remove('items');
      
      await _table().update(
        values: listData,
        builder: (query) => query
            .eq('id', list.id)
            .eq('user_id', _auth.currentUser!.id),
      );
    } catch (e) {
      throw Exception('Failed to update list: $e');
    }
  }

  @override
  Future<void> deleteList(String id) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      // Soft delete
      await _table().update(
        values: {
          'is_deleted': true,
        },
        builder: (query) => query
            .eq('id', id)
            .eq('user_id', _auth.currentUser!.id),
      );
    } catch (e) {
      throw Exception('Failed to delete list: $e');
    }
  }

  // Méthodes de filtrage et recherche (CustomListRepository)
  
  @override
  Future<List<CustomList>> getListsByType(ListType type) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      final response = await _table().select(
        builder: (query) => query
            .eq('user_id', _auth.currentUser!.id)
            .eq('list_type', type.name)
            .eq('is_deleted', false)
            .order('created_at', ascending: false),
      );

      return response.map<CustomList>((json) => CustomList.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch lists by type: $e');
    }
  }

  @override
  Future<List<CustomList>> searchListsByName(String query) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      // Sanitize query to prevent potential injection
      final sanitizedQuery = _sanitizeSearchQuery(query);

      final response = await _table().select(
        builder: (query) => query
            .eq('user_id', _auth.currentUser!.id)
            .eq('is_deleted', false)
            .ilike('name', '%$sanitizedQuery%')
            .order('created_at', ascending: false),
      );

      return response.map<CustomList>((json) => CustomList.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search lists by name: $e');
    }
  }

  @override
  Future<List<CustomList>> searchListsByDescription(String query) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      // Sanitize query to prevent potential injection
      final sanitizedQuery = _sanitizeSearchQuery(query);

      final response = await _table().select(
        builder: (query) => query
            .eq('user_id', _auth.currentUser!.id)
            .eq('is_deleted', false)
            .ilike('description', '%$sanitizedQuery%')
            .order('created_at', ascending: false),
      );

      return response.map<CustomList>((json) => CustomList.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search lists by description: $e');
    }
  }

  @override
  Future<List<CustomList>> searchByName(String query) => searchListsByName(query);

  @override
  Future<List<CustomList>> searchByDescription(String query) => searchListsByDescription(query);

  @override
  Future<List<CustomList>> getByType(ListType type) => getListsByType(type);

  @override
  Future<void> clearAll() => clearAllLists();

  /// Sanitizes search query to prevent potential SQL injection via ilike
  String _sanitizeSearchQuery(String query) {
    if (query.isEmpty) return query;
    
    // Escape SQL wildcards that could be exploited
    return query
        .replaceAll('\\', '\\\\')  // Escape backslashes first
        .replaceAll('%', '\\%')    // Escape percent signs
        .replaceAll('_', '\\_')    // Escape underscores
        .replaceAll('[', '\\[')    // Escape brackets
        .replaceAll(']', '\\]')    // Escape closing brackets
        .trim();                   // Remove leading/trailing spaces
  }

  @override 
  Future<void> clearAllLists() async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      // Soft delete toutes les listes de l'utilisateur
      await _table().update(
        values: {
          'is_deleted': true,
        },
        builder: (query) => query.eq('user_id', _auth.currentUser!.id),
      );
    } catch (e) {
      throw Exception('Failed to clear all lists: $e');
    }
  }

  // Méthode legacy (à migrer)
  Future<List<CustomList>> getByTypeString(String type) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      final response = await _table().select(
        builder: (query) => query
            .eq('user_id', _auth.currentUser!.id)
            .eq('list_type', type)
            .eq('is_deleted', false)
            .order('created_at', ascending: false),
      );

      return response.map<CustomList>((json) => CustomList.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch lists by type: $e');
    }
  }

  /// Méthodes spécifiques Supabase

  /// Synchronise avec les données locales (si Hive est encore utilisé)
  Future<void> syncWithLocal() async {
    // Pending: Implémenter sync avec Hive si nécessaire
  }

  /// Écoute les changements en temps réel
  Stream<List<CustomList>> watchAll() {
    if (!_auth.isSignedIn) {
      return Stream.error('User not authenticated');
    }

    return _table()
        .stream(
          primaryKey: const ['id'],
          builder: (query) => query
              .eq('user_id', _auth.currentUser!.id)
              .eq('is_deleted', false),
        )
        .map(
          (data) => data.map<CustomList>((json) => CustomList.fromJson(json)).toList(),
        );
  }

  /// Obtient les statistiques de l'utilisateur
  Future<Map<String, int>> getStats() async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      final response = await _table().select(
        columns: 'list_type',
        builder: (query) => query
            .eq('user_id', _auth.currentUser!.id)
            .eq('is_deleted', false),
      );

      final stats = <String, int>{};
      for (final item in response) {
        final type = item['list_type'] as String;
        stats[type] = (stats[type] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw Exception('Failed to get stats: $e');
    }
  }

  SupabaseTableAdapter _table() => _tableFactory(_supabase, _tableName);
}
