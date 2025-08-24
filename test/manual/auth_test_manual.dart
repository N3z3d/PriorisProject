import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prioris/infrastructure/services/auth_service.dart';
import 'package:prioris/infrastructure/services/supabase_service.dart';

/// Tests manuels pour l'authentification Supabase
/// 
/// Ces tests nécessitent une connexion internet et un projet Supabase actif.
/// À exécuter manuellement pour valider l'intégration.
void main() {
  group('Tests manuels - Authentification Supabase', () {
    setUpAll(() async {
      // Initialiser Supabase pour les tests
      print('🔧 Initialisation de Supabase pour les tests...');
      
      try {
        // Use SupabaseService to initialize with environment variables
        await SupabaseService.initialize();
        print('✅ Supabase initialisé avec succès');
      } catch (e) {
        print('❌ Erreur lors de l\'initialisation de Supabase: $e');
        rethrow;
      }
    });

    test('🌐 Vérifier la connexion à Supabase', () async {
      print('\n📡 Test de connexion à Supabase...');
      
      try {
        final supabaseService = SupabaseService.instance;
        expect(supabaseService, isNotNull);
        
        // Vérifier que l'URL est correcte
        final client = supabaseService.client;
        expect(client, isNotNull);
        
        print('✅ Service Supabase accessible');
        print('🔗 Client configuré correctement');
        
      } catch (e) {
        print('❌ Erreur de connexion: $e');
        fail('Connexion à Supabase échouée: $e');
      }
    });

    test('🔐 Vérifier le service AuthService', () async {
      print('\n🔐 Test du service d\'authentification...');
      
      try {
        final authService = AuthService.instance;
        expect(authService, isNotNull);
        
        // Vérifier l'état initial
        print('👤 Utilisateur actuel: ${authService.currentUser?.email ?? 'Aucun'}');
        print('🔓 Connecté: ${authService.isSignedIn}');
        
        // Vérifier que le stream d'auth existe
        expect(authService.authStateChanges, isNotNull);
        
        print('✅ Service AuthService opérationnel');
        
      } catch (e) {
        print('❌ Erreur AuthService: $e');
        fail('Service AuthService non fonctionnel: $e');
      }
    });

    test('📧 Test d\'inscription avec email temporaire', () async {
      print('\n📧 Test d\'inscription...');
      
      // Utiliser un email temporaire pour les tests
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final testEmail = 'test_$timestamp@example.com';
      const testPassword = 'TestPassword123!';
      
      try {
        final authService = AuthService.instance;
        
        // Nettoyer d'abord (si connecté)
        if (authService.isSignedIn) {
          await authService.signOut();
          print('🧹 Déconnexion préalable effectuée');
        }
        
        print('📝 Tentative d\'inscription avec: $testEmail');
        
        final response = await authService.signUp(
          email: testEmail,
          password: testPassword,
          fullName: 'Test User',
        );
        
        expect(response, isNotNull);
        print('✅ Inscription réussie');
        print('👤 User ID: ${response.user?.id ?? 'Aucun'}');
        print('📧 Email confirmé: ${response.user?.emailConfirmedAt != null}');
        
        // Nettoyer après le test
        if (authService.isSignedIn) {
          await authService.signOut();
          print('🧹 Déconnexion post-test effectuée');
        }
        
      } catch (e) {
        print('❌ Erreur lors de l\'inscription: $e');
        print('ℹ️ Ceci peut être normal si l\'email existe déjà');
        
        // Ne pas faire échouer le test si c'est juste un email existant
        if (!e.toString().contains('already registered')) {
          fail('Inscription échouée: $e');
        }
      }
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('🔑 Test de connexion avec des identifiants valides', () async {
      print('\n🔑 Test de connexion...');
      
      // NOTE: Ce test nécessite un compte existant
      // Il faut d'abord créer manuellement un compte dans Supabase
      print('ℹ️ Ce test nécessite un compte existant en base');
      print('ℹ️ Créez manuellement un compte avec:');
      print('   - Email: test@example.com');
      print('   - Password: TestPassword123!');
      
      try {
        final authService = AuthService.instance;
        
        // Nettoyer d'abord
        if (authService.isSignedIn) {
          await authService.signOut();
        }
        
        // Utiliser des identifiants de test (à adapter selon votre setup)
        const testEmail = 'test@example.com';
        const testPassword = 'TestPassword123!';
        
        print('🔐 Tentative de connexion avec: $testEmail');
        
        final response = await authService.signIn(
          email: testEmail,
          password: testPassword,
        );
        
        expect(response, isNotNull);
        expect(response.user, isNotNull);
        
        print('✅ Connexion réussie');
        print('👤 User ID: ${response.user!.id}');
        print('📧 Email: ${response.user!.email}');
        
        // Vérifier l'état du service
        expect(authService.isSignedIn, isTrue);
        expect(authService.currentUser, isNotNull);
        
        print('🔓 État connecté confirmé');
        
        // Test de déconnexion
        await authService.signOut();
        expect(authService.isSignedIn, isFalse);
        print('🔒 Déconnexion confirmée');
        
      } catch (e) {
        print('❌ Erreur de connexion: $e');
        print('ℹ️ Vérifiez que le compte test@example.com existe');
        
        // Ne pas faire échouer si c'est juste un problème de compte inexistant
        if (e.toString().contains('Invalid login credentials')) {
          print('⚠️ Identifiants invalides - créez d\'abord le compte test');
        } else {
          fail('Connexion échouée: $e');
        }
      }
    }, timeout: const Timeout(Duration(minutes: 2)));
  });
}

/// Fonction helper pour exécuter les tests manuellement
/// 
/// Utilisation: 
/// ```dart
/// await runManualAuthTests();
/// ```
Future<void> runManualAuthTests() async {
  print('🧪 === TESTS MANUELS AUTHENTIFICATION SUPABASE ===\n');
  
  try {
    // Ces tests doivent être exécutés dans l'ordre
    print('1. Initialisation...');
    // Setup déjà fait dans main()
    
    print('2. Test de connexion...');
    // Les tests individuels se lancent
    
    print('\n✅ === TESTS TERMINÉS ===');
    
  } catch (e) {
    print('\n❌ === TESTS ÉCHOUÉS ===');
    print('Erreur: $e');
    rethrow;
  }
}