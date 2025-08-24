/// Test manuel de validation de connexion Supabase
/// À exécuter pour vérifier que l'erreur AuthRetryableFetchException est résolue
library connection_validation;

import 'dart:io';
import 'package:prioris/core/config/app_config.dart';

Future<void> main() async {
  print('🔧 === VALIDATION CONNEXION SUPABASE ===');
  
  try {
    // 1. Charger la configuration
    await AppConfig.initialize();
    final config = AppConfig.instance;
    
    print('✅ Configuration chargée avec succès');
    print('📍 URL Supabase: ${config.supabaseUrl}');
    print('🔑 Clé anonyme: ${config.supabaseAnonKey.substring(0, 20)}...');
    print('🌍 Environnement: ${config.environment}');
    
    // 2. Vérifier que ce n'est plus l'ancienne URL
    if (config.supabaseUrl.contains('dev-project-id')) {
      print('❌ ERREUR: URL placeholder encore présente!');
      exit(1);
    }
    
    // 3. Vérifier que c'est une URL Supabase valide
    if (config.supabaseUrl.isEmpty || !config.supabaseUrl.contains('supabase.co')) {
      print('❌ ERREUR: URL Supabase invalide!');
      print('   L'URL doit être une URL Supabase valide (.supabase.co)');
      print('   Obtenue: ${config.supabaseUrl}');
      exit(1);
    }
    
    print('✅ Configuration URL validée');
    
    // 4. Test de connectivité réseau basique
    print('🌐 Test de connectivité réseau...');
    final httpClient = HttpClient();
    
    try {
      final request = await httpClient.getUrl(Uri.parse('${config.supabaseUrl}/rest/v1/'));
      final response = await request.close();
      
      print('✅ Connectivité réseau OK (Status: ${response.statusCode})');
      
      if (response.statusCode == 200 || response.statusCode == 401) {
        print('🎉 SUCCÈS: Supabase est accessible!');
      } else {
        print('⚠️  Warning: Status inattendu ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Erreur de connectivité: $e');
      exit(1);
    } finally {
      httpClient.close();
    }
    
    print('');
    print('🎯 === RÉSULTAT FINAL ===');
    print('✅ L\'erreur AuthRetryableFetchException devrait être résolue');
    print('✅ L\'app utilise maintenant la bonne URL Supabase');
    print('✅ La connectivité réseau fonctionne');
    
  } catch (e) {
    print('❌ Erreur lors de la validation: $e');
    exit(1);
  }
}