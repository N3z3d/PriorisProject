import 'package:prioris/infrastructure/services/supabase_service.dart';

/// Service d'administration pour nettoyer et gérer la base de données
class AdminService {
  static AdminService? _instance;
  static AdminService get instance => _instance ??= AdminService._();
  
  AdminService._();
  
  final _supabase = SupabaseService.instance;

  /// Nettoie TOUTES les données de TOUS les utilisateurs
  /// ⚠️ ATTENTION: Cette méthode est destructive !
  Future<void> clearAllData() async {
    try {
      // Supprimer dans l'ordre des dépendances
      await _supabase.client.from('habit_completions').delete().neq('id', '00000000-0000-0000-0000-000000000000');
      await _supabase.client.from('list_items').delete().neq('id', '00000000-0000-0000-0000-000000000000');
      await _supabase.client.from('custom_lists').delete().neq('id', '00000000-0000-0000-0000-000000000000');
      await _supabase.client.from('habits').delete().neq('id', '00000000-0000-0000-0000-000000000000');
      await _supabase.client.from('profiles').delete().neq('id', '00000000-0000-0000-0000-000000000000');
      
    } catch (e) {
      throw Exception('Failed to clear all data: $e');
    }
  }

  /// Obtient des statistiques globales sur la base de données
  Future<Map<String, dynamic>> getGlobalStats() async {
    try {
      final profiles = await _supabase.client.from('profiles').select('id, email');
      final lists = await _supabase.client.from('custom_lists').select('id, user_email');
      final items = await _supabase.client.from('list_items').select('id, user_email');
      final habits = await _supabase.client.from('habits').select('id, user_id');
      
      // Compter les utilisateurs uniques
      final uniqueUsers = <String>{};
      for (final profile in profiles) {
        if (profile['email'] != null) uniqueUsers.add(profile['email']);
      }
      for (final list in lists) {
        if (list['user_email'] != null) uniqueUsers.add(list['user_email']);
      }
      for (final item in items) {
        if (item['user_email'] != null) uniqueUsers.add(item['user_email']);
      }
      
      return {
        'totalUsers': uniqueUsers.length,
        'userEmails': uniqueUsers.toList(),
        'totalProfiles': profiles.length,
        'totalLists': lists.length,
        'totalItems': items.length,
        'totalHabits': habits.length,
      };
    } catch (e) {
      throw Exception('Failed to get global stats: $e');
    }
  }

  /// Affiche les données par utilisateur
  Future<Map<String, dynamic>> getUserBreakdown() async {
    try {
      final stats = await getGlobalStats();
      final userEmails = stats['userEmails'] as List<String>;
      
      final breakdown = <String, Map<String, int>>{};
      
      for (final email in userEmails) {
        final userLists = await _supabase.client
            .from('custom_lists')
            .select('id')
            .eq('user_email', email);
            
        final userItems = await _supabase.client
            .from('list_items')
            .select('id')
            .eq('user_email', email);
        
        breakdown[email] = {
          'lists': userLists.length,
          'items': userItems.length,
        };
      }
      
      return {
        'totalUsers': userEmails.length,
        'breakdown': breakdown,
      };
    } catch (e) {
      throw Exception('Failed to get user breakdown: $e');
    }
  }

  /// Supprime les données d'un utilisateur spécifique par email
  Future<void> clearUserDataByEmail(String email) async {
    try {
      // Supprimer les données de cet utilisateur
      await _supabase.client.from('list_items').delete().eq('user_email', email);
      await _supabase.client.from('custom_lists').delete().eq('user_email', email);
      
    } catch (e) {
      throw Exception('Failed to clear user data for $email: $e');
    }
  }

  /// Compte le nombre total d'enregistrements
  Future<int> getTotalRecords() async {
    try {
      final stats = await getGlobalStats();
      return stats['totalProfiles'] + stats['totalLists'] + stats['totalItems'] + stats['totalHabits'];
    } catch (e) {
      throw Exception('Failed to count total records: $e');
    }
  }
}