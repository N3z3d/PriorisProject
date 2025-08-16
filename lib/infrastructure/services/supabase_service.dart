import 'package:supabase_flutter/supabase_flutter.dart';

/// Service de configuration et gestion Supabase
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  
  SupabaseService._();

  // Configuration Supabase
  static const String supabaseUrl = 'https://vgowxrktjzgwrfivtvse.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZnb3d4cmt0anpnd3JmaXZ0dnNlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUzNDY1OTEsImV4cCI6MjA3MDkyMjU5MX0.cwwBY55OYIVtQPCy5OoD4_TkSf2OFAuLe43BKo7Z-lE';
  
  /// Initialise Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true, // Pour le développement
    );
  }
  
  /// Client Supabase global
  SupabaseClient get client => Supabase.instance.client;
  
  /// Client auth
  GoTrueClient get auth => client.auth;
  
  /// Base de données  
  SupabaseClient get database => client;
  
  /// Utilisateur actuel
  User? get currentUser => auth.currentUser;
  
  /// Stream des changements d'auth
  Stream<AuthState> get authStateChanges => auth.onAuthStateChange;
}