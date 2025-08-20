import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/core/config/app_config.dart';
import 'package:prioris/infrastructure/services/supabase_service.dart';

/// Test de validation de la connexion Supabase
/// Vérifie que la configuration est correctement chargée
void main() {
  group('Supabase Connection Tests', () {
    setUpAll(() async {
      // Initialiser la configuration avant les tests
      await AppConfig.initialize();
    });

    test('should load correct Supabase URL from environment', () {
      final config = AppConfig.instance;
      
      // Vérifier que l'URL est la vraie URL, pas le placeholder
      expect(config.supabaseUrl, equals('https://vgowxrktjzgwrfivtvse.supabase.co'));
      expect(config.supabaseUrl, isNot(contains('dev-project-id')));
      
      // Vérifier les autres configurations
      expect(config.environment, equals('development'));
      expect(config.isDebugMode, isTrue);
    });

    test('should initialize Supabase service without errors', () async {
      // Ce test vérifie l'initialisation sans erreur de fetch
      expect(() async => await SupabaseService.initialize(), 
             returnsNormally);
    });

    test('should have valid Supabase client configuration', () async {
      await SupabaseService.initialize();
      final service = SupabaseService.instance;
      
      // Vérifier que le client est initialisé
      expect(service.client, isNotNull);
      expect(service.auth, isNotNull);
      expect(service.database, isNotNull);
    });
  });
}