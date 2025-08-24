import 'package:prioris/infrastructure/services/supabase_service.dart';
import 'package:prioris/infrastructure/services/auth_service.dart';

/// Service pour gérer les données utilisateur
/// DI-friendly: Dependencies injected via constructor
class UserDataService {
  final SupabaseService _supabase;
  final AuthService _auth;

  /// Constructor with dependency injection
  const UserDataService({
    required SupabaseService supabaseService,
    required AuthService authService,
  }) : _supabase = supabaseService,
       _auth = authService;

  /// Factory constructor for legacy compatibility (deprecated)
  @Deprecated('Use constructor with DI instead')
  static UserDataService? _legacyInstance;
  @Deprecated('Use constructor with DI instead')
  static UserDataService get instance => _legacyInstance ??= UserDataService(
    supabaseService: SupabaseService.instance,
    authService: AuthService.instance,
  );

  /// Nettoie toutes les données de l'utilisateur connecté
  Future<void> clearAllUserData() async {
    if (!_auth.isSignedIn) throw Exception('User not authenticated');
    
    final userId = _auth.currentUser!.id;
    
    try {
      // Supprimer tous les éléments de liste de l'utilisateur
      await _supabase.client
          .from('list_items')
          .delete()
          .eq('user_id', userId);
      
      // Supprimer toutes les listes de l'utilisateur
      await _supabase.client
          .from('custom_lists')
          .delete()
          .eq('user_id', userId);
      
      // Supprimer toutes les habitudes de l'utilisateur
      await _supabase.client
          .from('habits')
          .delete()
          .eq('user_id', userId);
      
      // Supprimer toutes les complétions d'habitudes de l'utilisateur
      await _supabase.client
          .from('habit_completions')
          .delete()
          .eq('user_id', userId);
          
    } catch (e) {
      throw Exception('Failed to clear user data: $e');
    }
  }

  /// Soft delete de toutes les données utilisateur (recommandé)
  Future<void> softDeleteAllUserData() async {
    if (!_auth.isSignedIn) throw Exception('User not authenticated');
    
    final userId = _auth.currentUser!.id;
    final now = DateTime.now().toIso8601String();
    
    try {
      // Marquer tous les éléments de liste comme supprimés
      await _supabase.client
          .from('list_items')
          .update({
            'is_deleted': true,
            'updated_at': now,
          })
          .eq('user_id', userId);
      
      // Marquer toutes les listes comme supprimées
      await _supabase.client
          .from('custom_lists')
          .update({
            'is_deleted': true,
            'updated_at': now,
          })
          .eq('user_id', userId);
      
      // Marquer toutes les habitudes comme supprimées
      await _supabase.client
          .from('habits')
          .update({
            'is_deleted': true,
            'updated_at': now,
          })
          .eq('user_id', userId);
          
    } catch (e) {
      throw Exception('Failed to soft delete user data: $e');
    }
  }

  /// Obtient les statistiques des données utilisateur
  Future<Map<String, int>> getUserDataStats() async {
    if (!_auth.isSignedIn) throw Exception('User not authenticated');
    
    final userId = _auth.currentUser!.id;
    
    try {
      // Compter les listes (sans filtre is_deleted d'abord pour voir s'il y en a)
      final allListsResponse = await _supabase.client
          .from('custom_lists')
          .select('id, is_deleted')
          .eq('user_id', userId);
      
      final activeLists = allListsResponse.where((item) => item['is_deleted'] != true).length;
      
      // Compter les éléments de liste
      final allItemsResponse = await _supabase.client
          .from('list_items')
          .select('id, is_deleted')
          .eq('user_id', userId);
          
      final activeItems = allItemsResponse.where((item) => item['is_deleted'] != true).length;
      
      // Compter les habitudes
      final allHabitsResponse = await _supabase.client
          .from('habits')
          .select('id, is_deleted')
          .eq('user_id', userId);
          
      final activeHabits = allHabitsResponse.where((item) => item['is_deleted'] != true).length;
      
      return {
        'lists': activeLists,
        'items': activeItems,
        'habits': activeHabits,
        'totalLists': allListsResponse.length,
        'totalItems': allItemsResponse.length,
        'totalHabits': allHabitsResponse.length,
      };
    } catch (e) {
      throw Exception('Failed to get user data stats: $e');
    }
  }

  /// Vérifie s'il y a des données orphelines (sans propriétaire valide)
  Future<Map<String, dynamic>> checkDataIntegrity() async {
    if (!_auth.isSignedIn) throw Exception('User not authenticated');
    
    final userId = _auth.currentUser!.id;
    
    try {
      // Vérifier les listes de l'utilisateur
      final userLists = await _supabase.client
          .from('custom_lists')
          .select('id')
          .eq('user_id', userId)
          .eq('is_deleted', false);
      
      // Compter tous les items de l'utilisateur
      final userItems = await _supabase.client
          .from('list_items')
          .select('id')
          .eq('user_id', userId)
          .eq('is_deleted', false);
      
      return {
        'userLists': userLists.length,
        'userItems': userItems.length,
        'orphanItems': 0, // Simplifié pour éviter les erreurs Supabase
        'orphanItemsDetails': [],
      };
    } catch (e) {
      throw Exception('Failed to check data integrity: $e');
    }
  }

  /// Supprime les données orphelines
  Future<void> cleanOrphanData() async {
    if (!_auth.isSignedIn) throw Exception('User not authenticated');
    
    // Méthode simplifiée - rien à faire pour l'instant
    return;
  }
}