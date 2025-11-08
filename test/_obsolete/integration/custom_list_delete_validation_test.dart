import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/repositories/supabase/supabase_custom_list_repository.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/infrastructure/services/supabase_service.dart';
import 'package:prioris/infrastructure/services/auth_service.dart';
import 'package:prioris/infrastructure/config/app_config.dart';
import 'package:uuid/uuid.dart';

/// Test de validation simple pour la suppression de listes
/// 
/// Ce test valide que les nouvelles politiques RLS permettent 
/// effectivement la suppression de listes.
void main() {
  group('Validation Suppression RLS', () {
    late SupabaseCustomListRepository repository;
    late AuthService authService;

    setUpAll(() async {
      // Initialiser la configuration
      await AppConfig.initialize();
      
      // Initialiser les services
      await SupabaseService.initialize();
      authService = AuthService.instance;
      repository = SupabaseCustomListRepository();
    });

    test('VALIDATION: La suppression de liste doit fonctionner avec les nouvelles politiques RLS', () async {
      // ====================================
      // ÉTAPE 1: AUTHENTIFICATION
      // ====================================
      print('🔐 Authentification...');
      
      const testEmail = 'rls-test@prioris.app';
      const testPassword = 'RLSTest123!';

      try {
        await authService.signInWithEmailAndPassword(testEmail, testPassword);
        print('✅ Connexion réussie');
      } catch (e) {
        print('📝 Création du compte test...');
        await authService.signUpWithEmailAndPassword(testEmail, testPassword);
        print('✅ Compte créé et connecté');
      }

      expect(authService.isSignedIn, isTrue, 
        reason: 'Utilisateur doit être authentifié');

      // ====================================
      // ÉTAPE 2: CRÉATION D'UNE LISTE TEST
      // ====================================
      print('📝 Création d\'une liste de test...');
      
      final testList = CustomList(
        id: const Uuid().v4(),
        title: 'Test Suppression RLS ${DateTime.now().millisecondsSinceEpoch}',
        description: 'Liste créée pour valider la suppression RLS',
        listType: ListType.CUSTOM,
        color: 0xFF2196F3,
        icon: 0xe5ca,
        items: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.saveList(testList);
      print('✅ Liste créée avec ID: ${testList.id}');

      // Vérifier que la liste existe
      final createdList = await repository.getListById(testList.id);
      expect(createdList, isNotNull);
      expect(createdList!.title, equals(testList.title));
      print('✅ Liste vérifiée dans la base');

      // ====================================
      // ÉTAPE 3: SUPPRESSION (LE TEST CRITIQUE)
      // ====================================
      print('🗑️ Suppression de la liste...');
      
      // Cette opération DOIT réussir avec les nouvelles politiques RLS
      await expectLater(
        repository.deleteList(testList.id),
        completes,
        reason: 'La suppression doit réussir avec les nouvelles politiques RLS',
      );
      
      print('✅ Suppression exécutée sans erreur');

      // ====================================
      // ÉTAPE 4: VALIDATION SUPPRESSION
      // ====================================
      print('🔍 Validation de la suppression...');
      
      // La liste ne doit plus être accessible
      final deletedList = await repository.getListById(testList.id);
      expect(deletedList, isNull, 
        reason: 'Liste supprimée ne doit plus être accessible');
      print('✅ Liste correctement supprimée (soft delete)');

      // La liste ne doit plus apparaître dans getAllLists
      final allLists = await repository.getAllLists();
      final foundInAll = allLists.any((list) => list.id == testList.id);
      expect(foundInAll, isFalse, 
        reason: 'Liste supprimée ne doit plus apparaître dans getAllLists');
      print('✅ Liste absente de getAllLists');

      // ====================================
      // ÉTAPE 5: VALIDATION PERSISTANCE CLOUD
      // ====================================
      print('☁️ Validation persistance cloud...');
      
      // Attendre pour la propagation
      await Future.delayed(const Duration(seconds: 3));
      
      // Recharger depuis le cloud
      final cloudLists = await repository.getAllLists();
      final stillInCloud = cloudLists.any((list) => list.id == testList.id);
      expect(stillInCloud, isFalse, 
        reason: 'Liste ne doit plus exister dans le cloud');
      print('✅ Suppression confirmée dans le cloud');

      // ====================================
      // ÉTAPE 6: TEST DE RECONNEXION
      // ====================================
      print('🔄 Test de reconnexion...');
      
      await authService.signOut();
      await authService.signInWithEmailAndPassword(testEmail, testPassword);
      
      final postReconnectLists = await repository.getAllLists();
      final foundAfterReconnect = postReconnectLists.any((list) => list.id == testList.id);
      expect(foundAfterReconnect, isFalse, 
        reason: 'Liste doit rester supprimée après reconnexion');
      
      print('✅ Suppression persistante après reconnexion');
      
      // ====================================
      // RÉSULTAT FINAL
      // ====================================
      print('');
      print('🎉 VALIDATION COMPLÈTE RÉUSSIE !');
      print('📊 La suppression RLS fonctionne correctement');
      print('✅ Toutes les étapes validées avec succès');
      print('');
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('VALIDATION: Impossible de supprimer une liste inexistante', () async {
      print('🔍 Test suppression liste inexistante...');
      
      const fakeId = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';
      
      // Cette opération ne doit PAS échouer (soft delete sur inexistant)
      // mais ne doit rien faire
      await expectLater(
        repository.deleteList(fakeId),
        completes,
        reason: 'Suppression d\'une liste inexistante doit être gracefully handled',
      );
      
      print('✅ Suppression liste inexistante gérée correctement');
    });

    test('VALIDATION: Échoue si utilisateur non authentifié', () async {
      print('🔒 Test suppression sans authentification...');
      
      // Se déconnecter
      await authService.signOut();
      expect(authService.isSignedIn, isFalse);
      
      // Essayer de supprimer sans être connecté
      await expectLater(
        repository.deleteList('any-id'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message', 
          contains('User not authenticated')
        )),
        reason: 'Suppression sans auth doit échouer',
      );
      
      print('✅ Sécurité authentification validée');
    });
  });
}