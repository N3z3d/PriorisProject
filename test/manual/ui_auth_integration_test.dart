import 'dart:io';
import 'dart:math';

/// Test d'intégration manuel pour l'interface d'authentification Supabase
/// 
/// L'app doit être lancée sur http://localhost:8081 avant d'exécuter ce script
/// Usage: dart run test/manual/ui_auth_integration_test.dart
void main() async {
  print('🧪 === TEST D\'INTÉGRATION UI AUTHENTIFICATION ===\n');
  
  try {
    // 1. Vérifier que l'app est accessible
    print('1. 🌐 Vérification de l\'accès à l\'application...');
    await _checkAppAccess();
    
    // 2. Instructions pour tester l'interface
    print('\n2. 🧪 TESTS MANUELS DE L\'INTERFACE:');
    print('');
    print('   📱 Accédez à: http://localhost:8081');
    print('');
    print('   ✅ Vérifications visuelles à effectuer:');
    print('   ☐ La page de login s\'affiche correctement');
    print('   ☐ Logo Prioris visible avec icône checklist');
    print('   ☐ Titre "Connectez-vous" affiché');
    print('   ☐ Champs Email et Mot de passe présents');
    print('   ☐ Bouton "Se connecter" présent');
    print('   ☐ Lien "Pas de compte ? Créer un compte" présent');
    print('   ☐ Lien "Mot de passe oublié ?" présent');
    print('');
    
    // 3. Test de basculement inscription/connexion
    print('   🔄 Test de basculement mode inscription:');
    print('   ☐ Cliquer sur "Pas de compte ? Créer un compte"');
    print('   ☐ Vérifier que le titre change en "Créer un compte"');
    print('   ☐ Vérifier que le bouton devient "Créer le compte"');
    print('   ☐ Vérifier que le lien devient "Déjà un compte ? Se connecter"');
    print('   ☐ Vérifier que "Mot de passe oublié ?" disparaît');
    print('');
    
    // 4. Test de validation des champs
    print('   ✅ Test de validation des champs:');
    print('   ☐ Laisser les champs vides et cliquer sur "Se connecter"');
    print('   ☐ Vérifier que "Email requis" s\'affiche');
    print('   ☐ Vérifier que "Mot de passe requis" s\'affiche');
    print('   ☐ Saisir un email invalide (sans @) et valider');
    print('   ☐ Vérifier que "Email invalide" s\'affiche');
    print('   ☐ En mode inscription, saisir un mot de passe < 6 caractères');
    print('   ☐ Vérifier que "Au moins 6 caractères" s\'affiche');
    print('');
    
    // 5. Test d'inscription avec Supabase
    await _generateTestInstructions();
    
    // 6. Test de connexion
    print('   🔑 Test de connexion:');
    print('   ☐ Basculer en mode "Se connecter"');
    print('   ☐ Utiliser l\'email de test créé précédemment');
    print('   ☐ Saisir le mot de passe');
    print('   ☐ Cliquer sur "Se connecter"');
    print('   ☐ Vérifier que "Chargement..." s\'affiche brièvement');
    print('   ☐ Vérifier la redirection vers la page principale');
    print('   ☐ Vérifier que l\'app affiche le contenu principal');
    print('');
    
    // 7. Test de persistence
    print('   💾 Test de persistence de session:');
    print('   ☐ Actualiser la page (F5)');
    print('   ☐ Vérifier que l\'utilisateur reste connecté');
    print('   ☐ Fermer l\'onglet et rouvrir http://localhost:8081');
    print('   ☐ Vérifier que l\'utilisateur reste connecté');
    print('');
    
    // 8. Test de déconnexion
    print('   🚪 Test de déconnexion:');
    print('   ☐ Trouver et cliquer sur le bouton de déconnexion');
    print('   ☐ Vérifier le retour à la page de login');
    print('   ☐ Vérifier que les champs sont vides');
    print('');
    
    // 9. Test d'erreurs d'authentification
    print('   ❌ Test de gestion d\'erreurs:');
    print('   ☐ Tenter de se connecter avec des identifiants invalides');
    print('   ☐ Vérifier qu\'un message d\'erreur s\'affiche en rouge');
    print('   ☐ Vérifier que le message est informatif');
    print('   ☐ Vérifier que les champs restent remplis');
    print('');
    
    // 10. Test responsive
    print('   📱 Test responsive:');
    print('   ☐ Redimensionner la fenêtre du navigateur');
    print('   ☐ Vérifier que l\'interface s\'adapte');
    print('   ☐ Tester en mode mobile (F12 > Toggle device toolbar)');
    print('   ☐ Vérifier que l\'interface reste utilisable');
    print('');
    
    // 11. Résultats attendus
    print('✅ === RÉSULTATS ATTENDUS ===');
    print('');
    print('   🎯 Interface utilisateur:');
    print('   • Design cohérent avec le thème Prioris');
    print('   • Transitions fluides entre les modes');
    print('   • Messages d\'erreur clairs et utiles');
    print('   • Interface responsive sur tous les écrans');
    print('');
    print('   🔐 Authentification Supabase:');
    print('   • Inscription fonctionnelle avec email de confirmation');
    print('   • Connexion fonctionnelle avec redirection');
    print('   • Session persistante après actualisation');
    print('   • Déconnexion fonctionnelle');
    print('   • Gestion d\'erreurs appropriée');
    print('');
    
    print('✅ === TEST TERMINÉ ===');
    print('📝 Remplissez la checklist ci-dessus pour valider l\'authentification');
    
  } catch (e) {
    print('❌ Erreur lors du test: $e');
    exit(1);
  }
}

/// Vérifie que l'app est accessible
Future<void> _checkAppAccess() async {
  try {
    final result = await Process.run('curl', ['-s', '-o', '/dev/null', '-w', '%{http_code}', 'http://localhost:8081']);
    
    if (result.stdout == '200') {
      print('   ✅ Application accessible sur http://localhost:8081');
    } else {
      print('   ⚠️ Application non accessible (code: ${result.stdout})');
      print('   💡 Lancez d\'abord: flutter run -d web-server --web-port=8081');
    }
  } catch (e) {
    print('   ⚠️ Impossible de vérifier l\'accès: $e');
    print('   💡 Assurez-vous que curl est installé');
  }
}

/// Génère des instructions de test avec des identifiants uniques
Future<void> _generateTestInstructions() async {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final randomSuffix = Random().nextInt(1000);
  final testEmail = 'test_${timestamp}_$randomSuffix@example.com';
  final testPassword = 'TestPassword123!';
  
  print('   📝 Test d\'inscription avec Supabase:');
  print('   ☐ Basculer en mode "Créer un compte"');
  print('   ☐ Saisir l\'email de test: $testEmail');
  print('   ☐ Saisir le mot de passe: $testPassword');
  print('   ☐ Cliquer sur "Créer le compte"');
  print('   ☐ Vérifier que "Chargement..." s\'affiche brièvement');
  print('   ☐ Vérifier le message de confirmation d\'inscription');
  print('   ☐ (Optionnel) Vérifier la réception d\'email de confirmation');
  print('');
  
  // Sauvegarder les identifiants pour les tests suivants
  await _saveTestCredentials(testEmail, testPassword);
}

/// Sauvegarde les identifiants de test
Future<void> _saveTestCredentials(String email, String password) async {
  try {
    final file = File('test/manual/test_credentials.txt');
    await file.writeAsString('Email: $email\nPassword: $password\n');
    print('   💾 Identifiants sauvegardés dans: ${file.path}');
  } catch (e) {
    print('   ⚠️ Impossible de sauvegarder les identifiants: $e');
  }
}