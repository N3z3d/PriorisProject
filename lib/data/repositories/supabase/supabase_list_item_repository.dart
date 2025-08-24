import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/infrastructure/services/supabase_service.dart';
import 'package:prioris/infrastructure/services/auth_service.dart';

/// Repository Supabase pour les éléments de liste
/// DI-friendly: Dependencies injected via constructor
class SupabaseListItemRepository implements ListItemRepository {
  final SupabaseService _supabase;
  final AuthService _auth;

  static const String _tableName = 'list_items';

  /// Constructor with dependency injection
  const SupabaseListItemRepository({
    required SupabaseService supabaseService,
    required AuthService authService,
  }) : _supabase = supabaseService,
       _auth = authService;

  /// Factory constructor for legacy compatibility (deprecated)
  @Deprecated('Use constructor with DI instead')
  factory SupabaseListItemRepository.withDefaults() => SupabaseListItemRepository(
    supabaseService: SupabaseService.instance,
    authService: AuthService.instance,
  );

  @override
  Future<List<ListItem>> getAll() async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      final response = await _supabase.client
          .from(_tableName)
          .select()
          .eq('user_id', _auth.currentUser!.id)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      return response.map<ListItem>((json) => _fromSupabaseJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch list items: $e');
    }
  }

  @override
  Future<ListItem?> getById(String id) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      final response = await _supabase.client
          .from(_tableName)
          .select()
          .eq('id', id)
          .eq('user_id', _auth.currentUser!.id)
          .eq('is_deleted', false)
          .maybeSingle();

      return response != null ? _fromSupabaseJson(response) : null;
    } catch (e) {
      throw Exception('Failed to fetch list item by id: $e');
    }
  }

  @override
  Future<ListItem> add(ListItem item) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      final itemData = _toSupabaseJson(item);
      itemData['user_id'] = _auth.currentUser!.id;
      itemData['user_email'] = _auth.currentUser!.email;
      itemData['created_at'] = DateTime.now().toIso8601String();
      itemData['updated_at'] = DateTime.now().toIso8601String();
      
      await _supabase.client
          .from(_tableName)
          .insert(itemData);

      return item;
    } catch (e) {
      throw Exception('Failed to create list item: $e');
    }
  }

  @override
  Future<ListItem> update(ListItem item) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      final itemData = _toSupabaseJson(item);
      itemData['updated_at'] = DateTime.now().toIso8601String();
      
      await _supabase.client
          .from(_tableName)
          .update(itemData)
          .eq('id', item.id)
          .eq('user_id', _auth.currentUser!.id);

      return item;
    } catch (e) {
      throw Exception('Failed to update list item: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
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
      throw Exception('Failed to delete list item: $e');
    }
  }

  @override
  Future<List<ListItem>> getByListId(String listId) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      final response = await _supabase.client
          .from(_tableName)
          .select()
          .eq('user_id', _auth.currentUser!.id)
          .eq('list_id', listId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      return response.map<ListItem>((json) => _fromSupabaseJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch list items by list id: $e');
    }
  }

  /// Méthodes spécifiques Supabase

  /// Écoute les changements en temps réel pour une liste
  Stream<List<ListItem>> watchByListId(String listId) {
    if (!_auth.isSignedIn) {
      return Stream.error('User not authenticated');
    }

    return _supabase.client
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .map((data) => data
            .where((json) => 
                json['user_id'] == _auth.currentUser!.id && 
                json['list_id'] == listId &&
                json['is_deleted'] == false)
            .map<ListItem>((json) => _fromSupabaseJson(json))
            .toList());
  }

  /// Obtient les statistiques des éléments d'une liste
  Future<Map<String, dynamic>> getStatsForList(String listId) async {
    try {
      if (!_auth.isSignedIn) throw Exception('User not authenticated');

      final response = await _supabase.client
          .from(_tableName)
          .select('is_completed, elo_score')
          .eq('user_id', _auth.currentUser!.id)
          .eq('list_id', listId)
          .eq('is_deleted', false);

      int completed = 0;
      int total = response.length;
      double avgElo = 0;

      if (total > 0) {
        for (final item in response) {
          if (item['is_completed'] == true) completed++;
          avgElo += item['elo_score'] ?? 1200.0;
        }
        avgElo /= total;
      }

      return {
        'total': total,
        'completed': completed,
        'pending': total - completed,
        'completionRate': total > 0 ? completed / total : 0.0,
        'averageEloScore': avgElo,
      };
    } catch (e) {
      throw Exception('Failed to get list stats: $e');
    }
  }

  /// Convertit un ListItem vers le format Supabase
  Map<String, dynamic> _toSupabaseJson(ListItem item) {
    return {
      'id': item.id,
      'list_id': item.listId,
      'title': item.title,
      'description': item.description,
      'category': item.category,
      'elo_score': item.eloScore,
      'is_completed': item.isCompleted,
      'completed_at': item.completedAt?.toIso8601String(),
      'due_date': item.dueDate?.toIso8601String(),
      'notes': item.notes,
    };
  }

  /// Convertit depuis le format Supabase vers ListItem
  ListItem _fromSupabaseJson(Map<String, dynamic> json) {
    return ListItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      eloScore: (json['elo_score'] as num?)?.toDouble() ?? 1200.0,
      isCompleted: json['is_completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      dueDate: json['due_date'] != null 
          ? DateTime.parse(json['due_date'] as String) 
          : null,
      notes: json['notes'] as String?,
      listId: json['list_id'] as String,
    );
  }
}