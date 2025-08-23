import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/data/repositories/interfaces/repository_interfaces.dart';
import 'package:prioris/infrastructure/services/supabase_service.dart';
import 'package:prioris/infrastructure/services/auth_service.dart';

import '../custom_list_repository.dart';

/// Repository Supabase pour les listes personnalisées
class SupabaseCustomListRepository implements CustomListRepository {
  final SupabaseService _supabase = SupabaseService.instance;
  final AuthService _auth = AuthService.instance;

  static const String _tableName = 'custom_lists';

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

      final response = await _supabase.client
          .from(_tableName)
          .select()
          .eq('user_id', _auth.currentUser!.id)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      return response.map<CustomList>((json) => CustomList.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch lists: $e');
    }
  }

  @override
  Future<CustomList?> getListById(String id) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      final response = await _supabase.client
          .from(_tableName)
          .select()
          .eq('id', id)
          .eq('user_id', _auth.currentUser!.id)
          .eq('is_deleted', false)
          .maybeSingle();

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
      
      await _supabase.client
          .from(_tableName)
          .insert(listData);
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
      
      await _supabase.client
          .from(_tableName)
          .update(listData)
          .eq('id', list.id)
          .eq('user_id', _auth.currentUser!.id);
    } catch (e) {
      throw Exception('Failed to update list: $e');
    }
  }

  @override
  Future<void> deleteList(String id) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      // Soft delete
      await _supabase.client
          .from(_tableName)
          .update({
            'is_deleted': true,
          })
          .eq('id', id)
          .eq('user_id', _auth.currentUser!.id);
    } catch (e) {
      throw Exception('Failed to delete list: $e');
    }
  }

  // Méthodes de filtrage et recherche (CustomListRepository)
  
  @override
  Future<List<CustomList>> getListsByType(ListType type) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      final response = await _supabase.client
          .from(_tableName)
          .select()
          .eq('user_id', _auth.currentUser!.id)
          .eq('list_type', type.name)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      return response.map<CustomList>((json) => CustomList.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch lists by type: $e');
    }
  }

  @override
  Future<List<CustomList>> searchListsByName(String query) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      final response = await _supabase.client
          .from(_tableName)
          .select()
          .eq('user_id', _auth.currentUser!.id)
          .eq('is_deleted', false)
          .ilike('name', '%$query%')
          .order('created_at', ascending: false);

      return response.map<CustomList>((json) => CustomList.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search lists by name: $e');
    }
  }

  @override
  Future<List<CustomList>> searchListsByDescription(String query) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      final response = await _supabase.client
          .from(_tableName)
          .select()
          .eq('user_id', _auth.currentUser!.id)
          .eq('is_deleted', false)
          .ilike('description', '%$query%')
          .order('created_at', ascending: false);

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

  @override 
  Future<void> clearAllLists() async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      // Soft delete toutes les listes de l'utilisateur
      await _supabase.client
          .from(_tableName)
          .update({
            'is_deleted': true,
          })
          .eq('user_id', _auth.currentUser!.id);
    } catch (e) {
      throw Exception('Failed to clear all lists: $e');
    }
  }

  // Méthode legacy (à migrer)
  Future<List<CustomList>> getByTypeString(String type) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      final response = await _supabase.client
          .from(_tableName)
          .select()
          .eq('user_id', _auth.currentUser!.id)
          .eq('list_type', type)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      return response.map<CustomList>((json) => CustomList.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch lists by type: $e');
    }
  }

  /// Méthodes spécifiques Supabase

  /// Synchronise avec les données locales (si Hive est encore utilisé)
  Future<void> syncWithLocal() async {
    // TODO: Implémenter sync avec Hive si nécessaire
  }

  /// Écoute les changements en temps réel
  Stream<List<CustomList>> watchAll() {
    if (!_auth.isSignedIn) {
      return Stream.error('User not authenticated');
    }

    return _supabase.client
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .map((data) => data
            .where((json) => 
                json['user_id'] == _auth.currentUser!.id && 
                json['is_deleted'] == false)
            .map<CustomList>((json) => CustomList.fromJson(json))
            .toList());
  }

  /// Obtient les statistiques de l'utilisateur
  Future<Map<String, int>> getStats() async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      final response = await _supabase.client
          .from(_tableName)
          .select('list_type')
          .eq('user_id', _auth.currentUser!.id)
          .eq('is_deleted', false);

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
}