# Deferred Work

Aucun item différé au 2026-04-22.

## Deferred from: code review of 7-0-dette-technique-differee-epic-6 (2026-04-22)

- **Race stabilizer async / LoginPage mount** : `stabilizeFromCurrentOrIncomingSessionIfNeeded` est async (~5s timeout) ; si le callback se termine après que `LoginPage.initState()` ait lu le provider, le flag `_callbackWithoutSession` reste non consommé. Inhérent au design one-shot — acceptable pour MVP pilote.
- **_isSupabaseCallbackRoute edge cases** : double-slash (`//sb`) ou hash percent-encodé (`/%23sb`) non couverts par la normalisation `substring(1)`. Simplification intentionnelle vs l'ancien `replaceAll` ; ces inputs ne sont pas produits par Flutter Web en conditions normales.
- **Suppression _AuthCallbackRedirectPage** : la page intermédiaire avec spinner "Redirection en cours…" a été supprimée ; AuthWrapper gère désormais le feedback loading. À surveiller si les utilisateurs pilotes rapportent un flash visuel sur le flux callback.
- **settings.name remplacé par '/'** : le nom de route original (`/#sb-...`) est perdu pour tout futur NavigatorObserver / analytics. Sans impact actuellement (pas d'observer actif).
- **Race narrow mounted / of(context)** : dans le `addPostFrameCallback` de LoginPage, `AppLocalizations.of(context)` et `ScaffoldMessenger.of(context)` sont appelés après le check `!mounted`. Pattern pré-existant, risque négligeable en pratique.

## Deferred from: code review of 7-2-corriger-elo-calcul-persistance-rafraichissement-ui (2026-04-24)

- **Rename `updateEloScores` → `persistEloScores`** : le nom de l'interface `TaskRepository` ne reflète plus la responsabilité (persistance pure après fix). Touche interface + implémentation + tous les mocks — scope trop large pour cette story.
- **DIP — `ListItemTaskConverter` instancié directement** : `final converter = ListItemTaskConverter()` dans `_persistEloToLists` viole DIP. Classe stateless const, impact faible. À injecter via constructeur `DuelService` lors du prochain refactoring.
- **Silent failure `InMemoryTaskRepository.updateTask`** : `indexWhere` retourne -1 silencieusement si tâche absente — aucun log ni exception. Comportement pré-existant acceptable pour MVP.
- **Gestion d'erreur `processRanking` / `selectRandomTask`** : pas d'isolation d'erreur entre itérations (si duel N échoue, duels 0..N-1 sont déjà persistés). Pré-existant dans `DuelController` et `DuelService`.
- **Test manquant — `eloScore < 0`** : `ListItem` lève `ArgumentError` si `eloScore < 0`, aucun test ELO ne couvre ce chemin d'erreur. À ajouter dans `duel_service_elo_persistence_test.dart`.

## Deferred from: code review of 7-4-detection-et-gestion-doublons-ajout-liste (2026-04-26)

- **Mode _keepOpen + duplicates** [list_detail_page.dart] : en mode keep-open, `showDialog<int>` retourne `null` et le SnackBar n'est jamais affiché ; `skippedCount` est écrasé à chaque soumission successive. Hors scope story — à traiter si le use case keep-open + doublons est validé utilisateur.
- **TextNormalizationService constness sans injection** [duplicate_detection_service.dart:17] : `static const _normalizer` rend impossible l'injection d'un test double. Pré-existant design choice — à extraire en injection constructeur lors d'un refactoring.
- **messenger non protégé post-await** [list_detail_page.dart:223] : `ScaffoldMessenger.of(context)` capturé avant `await` est correct, mais `showSnackBar` peut lever si le Scaffold est démontré. Pattern pré-existant global.
- **Titres whitespace silencieusement écartés** [bulk_add_dialog.dart] : lignes vides ou whitespace-only filtrées sans feedback utilisateur. Pré-existant dans BulkAddDialog.
- **ListItem.title whitespace-only → normalise à ""** [duplicate_detection_service.dart] : un item pré-existant avec titre whitespace-only ferait détecter tout incoming whitespace comme doublon. Cas limite data integrity — impossible via UI normale.
- **CJK/emoji sans normalisation NFC/NFD** [text_normalization_service.dart] : la table de substitution Latin-only ne couvre pas les formes Unicode composées/décomposées. Pré-existant — nécessiterait intl ou characters package.
- **AppLocalizations.of(context)! non protégé** [list_detail_page.dart:224] : null assertion globale dans toute l'app — non spécifique à cette story.
- **Tests d'intégration page-level manquants** : flow complet cancel→BulkAddDialog propre, skip→SnackBar correcte. Coût disproportionné par rapport au risque — les dialog tests couvrent l'essentiel.

## Deferred from: code review of 7-6-verifier-et-completer-couverture-i18n-fr-en (2026-04-27)

- **Pattern `AppLocalizations.of(context)!` sans null guard** : utilisé dans 41 fichiers du projet, y compris les nouveaux ajouts de cette story. Un null check ou `?.` global serait plus robuste mais nécessite un refactoring projet-wide. Risque faible en production (app correctement wrappée), mais les tests sans `localizedApp()` crasheraient.
- **`ListsDialogService` stocke `BuildContext` en champ** [lists_dialog_service.dart:20] : pattern architecturalement fragile — un appelant qui awaite avant d'appeler un dialog service pourrait utiliser un contexte stale. Pré-existant dans le projet, acceptable pour MVP.
- **`_errorRoute` message brut sans sanitisation** [app_routes.dart] : `Text(message)` affiché directement sans troncature ni encoding guard. Un message de route très long ou malformé pourrait dégrader l'affichage. Pré-existant, hors scope i18n.
- **Version '1.0.0' hardcodée dans SettingsPage** [settings_page.dart] : non sourcée depuis `pubspec.yaml` ni `package_info_plus` — ne se mettra pas à jour automatiquement lors de releases. Pré-existant, à traiter lors d'une story de polish.

## Deferred from: code review of 7-5-ameliorer-messages-erreur-et-etats-de-chargement (2026-04-27)

- **`AppErrorWidget` générique collapse 401/403/validation** : tous les `ErrorType` hors network/timeout tombent dans le même message générique. Conception intentionnelle story 7.5 (scope minimal). À enrichir si des scénarios 401 (session expirée) nécessitent un message dédié.
- **`HabitsErrorState` n'utilise pas `AppErrorWidget`** : conserve ses propres clés i18n `habitsError*` et sa logique de détection. Hors scope spec 7.5. Refactoring à planifier si on veut une cohérence globale du widget d'erreur.
- **`habits_body_test.dart` — chemin error-state non couvert** : aucun test n'exerce `HabitsBody` avec `error != null` + `onRetry` non-nul. Wiring simple, risque faible, mais gap de couverture à combler.
- **Test `AppErrorWidget` cas 3 — callback non asserté** : `find.byIcon(Icons.refresh)` seulement, le tap n'est pas simulé. Test fragile qui passerait si `onPressed` était null.
- **`ExceptionHandler.handle` avale les sous-classes `Error`** : `AssertionError`, `StackOverflowError`, `RangeError` → `AppException.unknown`. Bug de programmation masqué en erreur récupérable. Pré-existant.
- **`ExceptionHandler.handle` classification par pattern-matching** : détection 401/403/network via `error.toString().contains(...)`. Fragile contre les messages enrichis (Supabase, wrapped exceptions). Pré-existant, blast radius étendu par 7.5.
- **6 `print()` debug dans `list_detail_loader_page.dart`** : traces emoji-préfixées pré-existantes. Fichier touché par 7.5 mais nettoyage non dans le scope story.
- **`HabitsLoadingState` sans label i18n** : hors scope spec 7.5 (uniquement tasks_page/list_detail_loader). AC2 partiel pour les habitudes.

## Deferred from: code review of 7-7-bases-rgpd-minimales (2026-04-27)

- **ConsentService double getInstance() par méthode** [consent_service.dart] : chaque méthode appelle `SharedPreferences.getInstance()` indépendamment. Design per spec — à injecter via constructeur lors d'un prochain refactoring.
- **Absence de revokeConsent() RGPD Art. 7.3** [consent_service.dart] : le RGPD impose que le consentement soit aussi librement retirable qu'il est donnable. Hors scope minimal explicite — à implémenter avant ouverture publique large.
- **Date consentement locale uniquement** [consent_service.dart] : `_consentDateKey` stocké dans SharedPreferences du device uniquement — perdu en cas de réinstall/changement d'appareil. Pas de preuve d'audit côté serveur. Hors scope MVP.
- **consentServiceProvider expose classe concrète sans interface DIP** [consent_providers.dart:4] : `Provider<ConsentService>` injecte la classe concrète. Violation DIP légère — à abstraire avec `IConsentService` lors d'un refactoring.
- **Date "avril 2026" hardcodée dans PrivacyPolicyPage** [privacy_policy_page.dart:26] : à extraire en constante ou clé i18n lors de la prochaine révision légale.
- **Tests ConsentGatePage vérifient uniquement le texte FR** [consent_gate_page_test.dart] : pattern pré-existant dans le projet — acceptable pour scope pilote FR.
- **consentServiceProvider non autoDispose** [consent_providers.dart:4] : ConsentService est stateless, impact mémoire négligeable. À aligner sur consentProvider.autoDispose lors du prochain refactoring Riverpod.
- **Titre i18n / corps hardcodé FR dans PrivacyPolicyPage** [privacy_policy_page.dart] : AppBar titre localisé mais sections hardcodées FR. Conforme spec AC5 — incohérence multilangue à corriger si le produit s'internationalise.
- **Boucle infinie potentielle si SharedPreferences cassé en permanence** [auth_wrapper.dart:30] : fail-open intentionnel per spec ; si SharedPreferences est définitivement inaccessible, chaque rebuild reémet l'erreur. Cas extrême, risque faible en production.

## Deferred from: code review of 7-9-tests-integration-supabase-harness (2026-04-28)

- **`setUp()` re-entrant sans guard signIn** [supabase_test_harness.dart:38-41] : `signIn()` est appelé à chaque `setUp()`, même si Supabase est déjà initialisé et une session active existe — double-session GoTrue silencieuse en cas de crash-recovery. Faible risque (processus séparés en pratique).
- **Valeurs `.env` entre guillemets passées verbatim** [supabase_test_harness.dart:65-70] : `SUPABASE_URL="https://..."` → URL avec guillemets inclus → `SocketException`. Pré-existant dans `_readDotEnv`, commun sur Windows.
- **`getAllHabits()` lookup par nom → orphelins de runs précédents** [supabase_habit_repository_integration_test.dart:61] : si un run précédent crashe avant `deleteHabit`, les lignes orphelines polluent la DB de test. Trade-off accepté (trigger DB écrase l'UUID Dart).
- **`_isSupabaseInitialized()` catch trop large** [supabase_test_harness.dart:50-57] : `catch (_)` avale toutes les exceptions — un StateError légitime (non-sentinelle) se transformerait en double-init. Théorique tant que le SDK Supabase ne change pas.
- **`_InMemoryGotrueAsyncStorage` partagé sous `--concurrency`** [supabase_test_harness.dart:116] : instance singleton du premier `setUp()` partagée si tests lancés en parallèle → race condition auth. Non applicable avec `flutter test` par défaut.
- **AC6 partiel — autres fichiers d'intégration non tagués** : `auth_flow_integration_test.dart`, `duel_page_list_integration_test.dart`, etc. sans `@Tags(['integration'])` — peuvent s'exécuter en CI sans réseau. Pré-existant, hors scope story 7.9.
- **`AuthService.signIn` dépendance potentielle à `AppConfig`** [supabase_test_harness.dart:38] : en contexte test, `AppConfig` peut ne pas être initialisé ; si `signIn` lit `AppConfig.instance.supabaseUrl`, `ConfigurationException` masque l'erreur réelle. Probable faux-positif (4 tests passent).

## Deferred from: code review of 7-8-insights-apres-stabilisation-du-socle (2026-04-27)

- **autoDispose + rechargement à chaque retour sur InsightsPage** [habits_state_provider.dart] : comportement voulu par AC2 ("recalcul à chaque ouverture") ; la disposition autoDispose est un choix architectural pré-existant. À surveiller si les performances se dégradent sur des jeux de données importants.
- **Tests assertent sur des chaînes FR littérales** [habit_calculation_service_test.dart] : `contains('premières habitudes')`, `contains('excellentes')` couplent les tests au wording FR du service. Pré-existant — à découpler lors d'une éventuelle i18n du service.
- **SRP/DIP — InsightsPage appelle HabitCalculationService directement** [insights_page.dart] : violation architecturale pré-existante dans le projet ; à corriger lors d'un refactoring ViewModel/UseCase.
- **NaN propagation dans `calculateSuccessRate`** [habit_calculation_service.dart] : habitude quantitative avec `targetValue=0` peut produire NaN. Pré-existant dans le service.
- **Cast `int`→`double` depuis JSON Supabase** [habit.dart:getSuccessRate/getCurrentStreak] : `(value as double)` lève `CastError` si Supabase retourne un `int`. Pré-existant dans l'entité Habit.
- **Bug formule `calculateAveragePerDay`** [habit_calculation_service.dart] : `(sum/n)*n == sum` rend la métrique sémantiquement incorrecte. Non utilisé par InsightsPage. Pré-existant.
- **`SmartInsightsWidget._parseInsight` cast non sécurisé** [smart_insights_widget.dart] : `insight['message'] as String` lève si valeur null ou non-String. Widget pré-existant non touché par 7.8.
- **Tests manquants : gap de série, habitudes quantitatives, targetValue=0** [habit_calculation_service_test.dart] : couverture supplémentaire au-delà de l'AC5 — à compléter lors d'une story de tests dédiée.

## Deferred from: code review of 8-2-implementer-revokeconsent-rgpd-art-7-3 (2026-05-04)

- **DIP — `ConsentService` importe `shared_preferences` dans `lib/domain/`** [consent_service.dart:1] : localStorage est un détail d'infrastructure (`lib/domain/CLAUDE.md` l'interdit). Violation pré-existante depuis story 7.7 — non introduite par 8.2. À corriger en Epic 9 : extraire `IConsentRepository` dans `lib/domain/ports/`, déplacer l'implémentation SharedPreferences vers `lib/data/repositories/SharedPreferencesConsentRepository`.
- **Chemin d'erreur `ConsentNotifier.revoke()` non testé** [consent_notifier_revoke_test.dart] : le `catch (e, st)` passe l'état en `AsyncValue.error` mais aucun test ne couvre ce chemin. Nécessite un mock de `ConsentService` (possible via override Riverpod). À ajouter dans une story de consolidation des tests.
- **Navigation post-revoke non testée end-to-end** [settings_page_revoke_test.dart] : le test widget vérifie les prefs effacées mais pas la transition `SettingsPage → ConsentGatePage` via `AuthWrapper`. Couvert implicitement par les tests `auth_wrapper_*` existants — acceptable pour scope story.
- **Clés SharedPreferences hardcodées dans 3 fichiers de test** [consent_service_test, consent_notifier_revoke_test, settings_page_revoke_test] : `'privacy_consent_v1'` dupliqué 4 fois. À exposer via `@visibleForTesting` sur `ConsentService._consentKey` lors du prochain refactoring de la classe.
- **`Future<void>.delayed(Duration.zero)` dans consent_notifier_revoke_test** [consent_notifier_revoke_test.dart:13,28,39] : anti-pattern de synchronisation microtask. À remplacer par un `ConsentService` mocké injecté via override `ProviderContainer` lors de la story de consolidation des tests.

## Deferred from: code review of 7-3-feedback-visuel-operations-longues (2026-04-25)

- **IdGenerationService instanciée inline** [list_detail_page.dart] : `final idService = IdGenerationService()` dans le callback `onSubmit` — violation DIP pré-existante, non testable sans monkey-patching. À injecter lors d'un prochain refactoring.
- **addMultipleItemsToList alias vide** [lists_controller_slim.dart] : méthode qui délègue à `addMultipleItems` sans valeur ajoutée. Pré-existant, supprimable lors du prochain nettoyage du controller.
- **verifyItemPersistence dans la boucle de sauvegarde** [lists_persistence_manager.dart] : appel `await verifyItemPersistence(items[i].id)` après chaque item ajoute un aller-retour non spécifié dans la story. Comportement pré-existant — à évaluer si les performances sur grands imports posent problème.
