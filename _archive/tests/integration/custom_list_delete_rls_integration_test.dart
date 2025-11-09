import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:prioris/main.dart' as app;
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/infrastructure/services/auth_service.dart';
import 'package:prioris/infrastructure/config/app_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

/// Test d'intégration pour valider la suppression de listes avec RLS
/// 
/// Ce test valide le workflow complet :
/// 1. Authentification utilisateur
/// 2. Création d'une liste de test
/// 3. Suppression de la liste
/// 4. Vérification que la suppression cloud fonctionne
/// 5. Validation que la liste ne réapparaît pas après redémarrage
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Suppression de Liste - Test RLS Intégration', () {
    late ProviderContainer container;
    late CustomListRepository repository;
    late AuthService authService;
    
    const testUserEmail = 'test-delete@prioris.app';
    const testUserPassword = 'TestDelete123!';

    setUpAll(() async {
      // Initialiser la configuration
      await AppConfig.initialize();
      
      // Créer le container Riverpod
      container = ProviderContainer();
      
      // Récupérer les services
      authService = AuthService.instance;
      
      // Note: En environnement de test, utiliser le repository Supabase directement
      // repository = container.read(customListRepositoryProvider);
    });

    tearDownAll(() {
      container.dispose();
    });

    group('Workflow complet de suppression', () {
      testWidgets('DOIT supprimer une liste et la garder supprimée après redémarrage', (WidgetTester tester) async {
        // ====================================
        // ÉTAPE 1: AUTHENTIFICATION
        // ====================================
        
        // Se connecter avec un utilisateur de test
        try {
          await authService.signInWithEmailAndPassword(
            testUserEmail, 
            testUserPassword,
          );
        } catch (e) {
          // Si l'utilisateur n'existe pas, le créer
          await authService.signUpWithEmailAndPassword(
            testUserEmail, 
            testUserPassword,
          );
        }

        // Vérifier l'authentification
        expect(authService.isSignedIn, isTrue, 
          reason: 'L\'utilisateur doit être authentifié');
        expect(authService.currentUser?.email, equals(testUserEmail));

        // ====================================
        // ÉTAPE 2: CRÉATION DE LISTE DE TEST
        // ====================================
        
        final testList = CustomList(
          id: const Uuid().v4(),
          title: 'Liste Test Suppression RLS',
          description: 'Liste créée pour tester la suppression avec RLS',
          listType: ListType.CUSTOM,
          color: 0xFF2196F3,
          icon: 0xe5ca,
          items: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Sauvegarder la liste
        await repository.saveList(testList);
        
        // Vérifier que la liste est créée
        final createdList = await repository.getListById(testList.id);
        expect(createdList, isNotNull, 
          reason: 'La liste doit être créée avec succès');
        expect(createdList!.title, equals(testList.title));

        // ====================================
        // ÉTAPE 3: SUPPRESSION DE LA LISTE  
        // ====================================
        
        // Supprimer la liste
        await repository.deleteList(testList.id);

        // Vérifier que la liste n'est plus accessible (soft delete)
        final deletedList = await repository.getListById(testList.id);
        expect(deletedList, isNull, 
          reason: 'La liste supprimée ne doit plus être accessible');

        // Vérifier que la liste n'apparaît plus dans getAllLists
        final allLists = await repository.getAllLists();
        final foundList = allLists.any((list) => list.id == testList.id);
        expect(foundList, isFalse, 
          reason: 'La liste supprimée ne doit plus apparaître dans getAllLists');

        // ====================================
        // ÉTAPE 4: VALIDATION PERSISTANCE CLOUD
        // ====================================
        
        // Attendre un peu pour la propagation
        await tester.pump(const Duration(seconds: 2));

        // Forcer un reload depuis le cloud
        final reloadedLists = await repository.getAllLists();
        final stillExists = reloadedLists.any((list) => list.id == testList.id);
        expect(stillExists, isFalse, 
          reason: 'La liste ne doit plus exister après reload cloud');

        // ====================================
        // ÉTAPE 5: SIMULATION REDÉMARRAGE APP
        // ====================================
        
        // Simuler un redémarrage en réinitialisant et rechargeant
        // (Dans un vrai test d'intégration, on relancerait l'app)
        
        // Se déconnecter et reconnecter
        await authService.signOut();
        expect(authService.isSignedIn, isFalse);
        
        await authService.signInWithEmailAndPassword(
          testUserEmail, 
          testUserPassword,
        );
        expect(authService.isSignedIn, isTrue);

        // Recharger les listes après "redémarrage"
        final postRestartLists = await repository.getAllLists();
        final listStillGone = postRestartLists.every((list) => list.id != testList.id);
        expect(listStillGone, isTrue, 
          reason: 'La liste doit rester supprimée même après redémarrage');

        print('✅ Test de suppression RLS réussi !');
        print('📊 Listes trouvées après suppression: ${postRestartLists.length}');
      });

      testWidgets('DOIT échouer la suppression d\'une liste d\'un autre utilisateur', (WidgetTester tester) async {
        // ====================================
        // ÉTAPE 1: CRÉER UNE LISTE AVEC USER 1
        // ====================================
        
        // Se connecter avec le premier utilisateur
        await authService.signInWithEmailAndPassword(
          testUserEmail, 
          testUserPassword,
        );
        
        final testList = CustomList(
          id: const Uuid().v4(),
          title: 'Liste Utilisateur 1',
          description: 'Liste qui ne doit pas être supprimable par user 2',
          listType: ListType.CUSTOM,
          color: 0xFF2196F3,
          icon: 0xe5ca,
          items: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await repository.saveList(testList);
        final listId = testList.id;

        // ====================================
        // ÉTAPE 2: ESSAYER DE SUPPRIMER AVEC USER 2
        // ====================================
        
        // Se déconnecter du user 1
        await authService.signOut();
        
        // Se connecter avec un autre utilisateur
        const otherUserEmail = 'other-test@prioris.app';
        const otherUserPassword = 'OtherTest123!';
        
        try {
          await authService.signInWithEmailAndPassword(
            otherUserEmail, 
            otherUserPassword,
          );
        } catch (e) {
          await authService.signUpWithEmailAndPassword(
            otherUserEmail, 
            otherUserPassword,
          );
        }

        // Essayer de supprimer la liste de l'autre utilisateur
        // Cela DOIT échouer grâce aux politiques RLS
        await expectLater(
          repository.deleteList(listId),
          throwsA(isA<Exception>()),
          reason: 'La suppression d\'une liste d\'un autre utilisateur doit échouer',
        );

        // ====================================
        // ÉTAPE 3: VÉRIFIER QUE LA LISTE EXISTE TOUJOURS
        // ====================================
        
        // Se reconnecter avec le user 1 original
        await authService.signOut();
        await authService.signInWithEmailAndPassword(
          testUserEmail, 
          testUserPassword,
        );

        // Vérifier que la liste existe toujours
        final stillExistingList = await repository.getListById(listId);
        expect(stillExistingList, isNotNull, 
          reason: 'La liste doit toujours exister car la suppression par l\'autre user a échoué');
        
        // Nettoyer - supprimer la liste avec le bon utilisateur
        await repository.deleteList(listId);
        
        print('✅ Test de sécurité RLS réussi !');
      });
    });

    group('Tests de performance et robustesse', () {
      testWidgets('DOIT gérer la suppression de multiples listes', (WidgetTester tester) async {
        // Authentification
        await authService.signInWithEmailAndPassword(
          testUserEmail, 
          testUserPassword,
        );

        // Créer plusieurs listes
        final testLists = <CustomList>[];
        for (int i = 0; i < 5; i++) {
          final list = CustomList(
            id: const Uuid().v4(),
            title: 'Liste Test Bulk $i',
            description: 'Liste $i pour test suppression en masse',
            listType: ListType.CUSTOM,
            color: 0xFF2196F3,
            icon: 0xe5ca,
            items: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          testLists.add(list);
          await repository.saveList(list);
        }

        // Vérifier que toutes sont créées
        final allListsBeforeDelete = await repository.getAllLists();
        for (final list in testLists) {
          expect(
            allListsBeforeDelete.any((l) => l.id == list.id), 
            isTrue,
            reason: 'Liste ${list.title} doit exister avant suppression',
          );
        }

        // Supprimer toutes les listes
        for (final list in testLists) {
          await repository.deleteList(list.id);
        }

        // Vérifier que toutes sont supprimées
        final allListsAfterDelete = await repository.getAllLists();
        for (final list in testLists) {
          expect(
            allListsAfterDelete.any((l) => l.id == list.id), 
            isFalse,
            reason: 'Liste ${list.title} doit être supprimée',
          );
        }

        print('✅ Test de suppression en masse réussi !');
        print('📊 ${testLists.length} listes supprimées avec succès');
      });
    });
  });
}