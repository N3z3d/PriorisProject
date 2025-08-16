import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/data/repositories/interfaces/repository_interfaces.dart';
import 'package:prioris/infrastructure/services/supabase_service.dart';
import 'package:prioris/infrastructure/services/auth_service.dart';

/// Repository Supabase pour les listes personnalisées
class SupabaseCustomListRepository implements CustomListCrudRepositoryInterface {
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
      listData['created_at'] = DateTime.now().toIso8601String();
      listData['updated_at'] = DateTime.now().toIso8601String();
      
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
      listData['updated_at'] = DateTime.now().toIso8601String();
      
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
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .eq('user_id', _auth.currentUser!.id);
    } catch (e) {
      throw Exception('Failed to delete list: $e');
    }
  }

  Future<List<CustomList>> getByType(String type) async {
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