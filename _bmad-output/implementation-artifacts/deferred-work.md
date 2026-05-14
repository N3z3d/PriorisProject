# Deferred Work

## Deferred from: code review of 10-3-supprimer-fichiers-orphelins-erreurs-analyse-dart (2026-05-15)

- **TextEditingControllers non disposés dans HabitFormWidget** [lib/presentation/pages/habits/widgets/habit_form_widget.dart] : `_cycleActiveController` et `_cycleLengthController` créés dans `_HabitFormWidgetState` mais absents du `dispose()`. Leak mémoire silencieux, assertion Flutter en debug à chaque démontage. Pré-existant.
- **Mauvais callbacks pour les champs cycle (cycle active/length)** [lib/presentation/pages/habits/widgets/components/advanced_habit_tracking_section.dart] : `onTimesChanged` câblé sur le champ cycleActive et `onIntervalEveryChanged` sur cycleLength — met à jour les mauvaises variables d'état (`_timesCount` / `_intervalEvery` au lieu de `_cycleActive` / `_cycleLength`). Données saisies silencieusement ignorées à la soumission. Pré-existant.
- **Boutons no-op dans HabitsListView** [lib/presentation/pages/habits/components/habits_list_view.dart] : CTA "créer habitude" (empty state) et bouton retry (error state) sont `onTap: () {}` — tappables visuellement mais sans effet. ISP/DIP violation : IHabitsListView sans callbacks pour ces actions. Pré-existant.
- **Triplicated switch icon/couleur pour ListType** [list_type_style_helper.dart, list_type_selector.dart, list_type_helpers.dart] : trois tables switch indépendantes avec valeurs divergentes (ex. TODO : `Icons.check_circle_outline` vs `Icons.check_box`). DRY violation — chaque nouveau ListType doit être ajouté dans 3 endroits. Pré-existant.
- **Chaîne 'Type de liste' hard-codée FR** [lib/presentation/pages/lists/widgets/list_type_selector.dart:33] : label non localisé dans un widget qui utilise AppLocalizations pour d'autres strings. Pré-existant.
- **Risque setState après dispose dans showDatePicker async** [habit_tracking_section.dart / advanced_habit_tracking_section.dart] : callbacks `onCycleStartDateChanged` / `onSpecificDateChanged` appelés après `await showDatePicker`, susceptibles de déclencher `setState` sur un parent démontê. Pattern pré-existant dans les deux variantes du widget. Pré-existant.
- **Incohérence couleur ListType entre colorValue et helpers UI** [lib/domain/models/core/enums/list_enums.dart vs list_type_style_helper.dart] : TODO → `0xFF3F51B5` (indigo via colorValue) vs `Colors.teal` (helpers). RESTAURANTS → `0xFFE91E63` (pink) vs `Colors.red`. Contextes utilisant `colorValue` vs `getColorForType` afficheront des couleurs différentes. Pré-existant.
- **SortOption triple définition — racine de T3.3 non résolue** [lists_state.dart, lists_controller_interfaces.dart, lists_filter_service.dart] : trois `enum SortOption` coexistent. T3.3 a supprimé le seul fichier qui importait les deux sources en conflit, mais les 3 définitions restent. Toute future file important les deux sources presentation réintroduira l'ambiguïté. Spec intent : "un seul point de définition". Pré-existant (aggravé).
- **accessibility_service.dart importe flutter/material.dart depuis lib/domain/** [lib/domain/services/ui/accessibility_service.dart:1] : violation de la règle hexagonale `lib/domain/CLAUDE.md` (seul `flutter/foundation.dart` est autorisé dans lib/domain/). Importé par 6+ fichiers de présentation. Pré-existant.
- **Switch _toDomainSortOption non exhaustif** [lists_controller.dart] : 6 cas sur 8 valeurs domain (`ITEMS_COUNT_ASC` et `ITEMS_COUNT_DESC` non mappés). Feature gap silencieux. Pré-existant.
- **Swallow silencieux de toutes exceptions dans _safeCurrentUser** [lib/presentation/pages/habits/widgets/habit_form_widget.dart] : `catch (_)` absorbe `Error` subclasses — habits créées sans `userId` si `AuthService` lève pendant l'initialisation. Pré-existant.
- **HabitTrackingSection potentiellement dead code** [lib/presentation/pages/habits/widgets/components/habit_tracking_section.dart] : `HabitFormWidget` instancie `AdvancedHabitTrackingSection`, pas `HabitTrackingSection`. Le fix de context propagation (story 10.3) peut ne pas couvrir le chemin runtime réel si le widget n'est plus appelé. À vérifier et supprimer si dead code confirmé. Pré-existant.

## Deferred from: code review of 10-2-versionner-mocks-corriger-compatibilite-dart-ci (2026-05-14)

- **Mocks stale sans détection CI** [`.github/workflows/ci.yml`] : les `.mocks.dart` versionnés peuvent dériver de la source (ex. interface renommée, mockito mis à jour) sans qu'aucun step CI ne le détecte. Solution potentielle : step `build_runner build` + `git diff --exit-code` — mais réintroduit build_runner. À adresser dans une story dédiée (CI governance).
- **Nouveau `@GenerateMocks` sans mock commité** [`.gitignore`, `ci.yml`] : un développeur peut ajouter une annotation `@GenerateMocks` et oublier de commiter le `.mocks.dart` sibling. Aucun lint/CI ne valide que chaque annotation a son fichier généré présent. À adresser via documentation ou script de validation.
- **`subosito/flutter-action@v2` non pinné** [`.github/workflows/ci.yml`] : l'action GitHub n'est pas fixée par SHA — une mise à jour de l'action peut changer la résolution de la version Flutter. Risque faible à court terme, bonne pratique de sécurité supply-chain.
- **`continue-on-error: true` sur le job `test`** [`.github/workflows/ci.yml:38`] : tous les échecs de tests (y compris les mocks manquants) sont silencieusement absorbés. Intentionnel jusqu'à la story 11-2 qui réactivera le gate bloquant.
- **`dart --version` informatif sans assertion** [`.github/workflows/ci.yml`] : le step ne fait qu'afficher la version, ne bloque pas si la version est inattendue. Suffisant pour le diagnostic mais sans valeur de guard.
- **`dart --version` absent du second job CI** [`.github/workflows/ci.yml:102`] : le job de deploy n'a pas le step de vérification de version Dart ajouté au job test. Minor observability gap.

Aucun item différé au 2026-04-22.

## Deferred from: code review of 8-7-polish-ux-snackbar-import-et-avertissement-fermeture (2026-05-07)

- **Multiple SnackBars en file derrière `duration: days(1)`** [home_page.dart] : si un autre snackbar est déjà affiché, la bannière d'import interrompu est bloquée derrière. Pas de `clearSnackBars()` ni de mécanisme de priorité. Pré-existant, non introduit par 8.7.
- **Warning `importDoNotClose` figé si widget unmounted pendant debounce** [bulk_add_dialog.dart] : en mode keep-open, si le widget est démontré pendant les 300 ms de debounce après `await Future.wait`, le `if (mounted)` saute le `setState(_isSubmitting = false)` → avertissement visible indéfiniment. Pré-existant dans l'architecture keep-open.
- **Race `_totalCount == 0` + keep-open mode** [bulk_add_dialog.dart] : si `_totalCount` est 0 lors d'une re-soumission en keep-open et `_isSubmitting` passe à `true`, la section de progression et l'avertissement sont affichés dans un état indéterminé. Très étroit, pré-existant.
- **`AppLocalizations.of(context)!` null-deref sans delegate** [home_page.dart dans `addPostFrameCallback`] : si `HomePage` est pompée sans `localizationsDelegates`, le `!` provoque un crash. Pattern global pré-existant dans le projet (voir defer 7-6).

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

## Deferred from: code review of 8-4-corriger-bugs-connus-ui-encodage-etoile-cartes (2026-05-07)

- **Fallback `'Général'` non matché dans `_getHabitIcon`** [habit_avatar.dart:38] : `habit.category ?? 'Général'` → `'général'` ne correspond à aucun `case` du switch → tombe en `default`. Design smell pré-existant, intention opaque.
- **`_getHabitIcon` dupliqué** [habit_avatar.dart:45 + habit_card_builder.dart:434] : deux implémentations indépendantes, switch axis différent. DRY violation pré-existante, hors scope story 8.4.
- **`FractionallySizedBox.widthFactor` non borné** [habit_progress_display.dart `_buildProgressBar`] : `widthFactor: progress` sans `.clamp(0.0, 1.0)`. Flutter lance une assertion si la valeur dépasse 1.0 ou est négative. Pré-existant, non touché par le diff.
- **Streak stale** [habit_progress_display.dart `_buildStatsHeader`] : `habit.getCurrentStreak()` (calcul live) peut diverger du champ persisté `currentStreak` (HiveField 20) sur des données importées ou après crash. Pré-existant.

## Deferred from: code review of 8-5-corriger-formule-calculateaverageperday-et-cast-int-double-supabase (2026-05-07)

- **7 fichiers production conservent `(value as double)` non corrigés** [lib/domain/habit/services/habit_streak_calculator.dart:147, habit_progress_calculator.dart:111, habit_completion_service.dart:113, analytics/habit_pattern_analyzer.dart:89, analytics/habit_consistency_calculator.dart:72, lib/domain/services/calculation/progress_calculation_service.dart:310, lib/data/providers/list_providers.dart:229-231] : mêmes `CastError` latents que le bug corrigé en 8-5. À traiter en lot dans une story dédiée.
- **Hive adapter `habit.g.dart:25` — `targetValue: fields[5] as double?`** : le path désérialisation Hive n'est pas couvert par le fix `fromJson`. Si une habitude est relue depuis Hive avec un `targetValue` entier, `CastError` possible. Généré — à corriger manuellement ou en regénérant l'adaptateur après modification du modèle.
- **Présentation — silent null cast `as double?`** [habit_card.dart:91, habit_progress_bar.dart:88-104, habit_record_dialog.dart:34] : `todayValue as double? ?? 0.0` retourne silencieusement `null` (cast rate) quand la valeur est un `int` Supabase — la barre de progression et le champ pré-rempli affichent toujours 0. Pré-existant.
- **Hardcoded `7` en double occurrence dans `habit_progress_display.dart`** [ligne 17 `getSuccessRate(days:7)` et ligne 145 `habitProgressSuccessfulDays(successfulDays, 7)`] : les deux occurrences ne partagent pas une constante — si la fenêtre change d'un côté, l'autre reste à 7. Pré-existant.
- **ARB `@habitProgressSuccessfulDays` placeholders sans `"type": "int"`** [lib/l10n/app_de.arb, app_es.arb] : déclarés comme `{}` (type implicite `Object`) — cohérent avec le reste du projet mais empêche la validation de type ICU. Pré-existant.

## Deferred from: code review of 9-4-corriger-lsp-getstats-hive-supabase-custom-list-repository (2026-05-12)

- **`cleanOldData @override` sans méthode parente dans `CustomListRepository`** [test/test_utils/recording_list_repository.dart:226] : `@override` génère un lint warning `override_on_non_overriding_member` — pré-existant avant 9-4, non introduit par le diff.
- **`getStats()` hérité appelle `getAllLists()` → throw si `getAllLists` configuré en échec sur `RecordingListRepository`** : changement comportemental silencieux — l'ancien override retournait des métriques directement. Aucun test affecté (grep confirmé), risque faible.
- **Cast `(listRepo2 as HiveCustomListRepository)` dans `data_loss_diagnostic_test.dart:760`** : by design (T3.4 — registre type `CustomListRepository`) ; cast non gardé en test-code, échouera si le registre retourne un type différent.
- **`supabase_integration_validation_test.dart:115` teste désormais le default domain plutôt que Supabase-specific `getStats()`** : dérive sémantique intentionnelle — analysée et acceptée dans Dev Notes 9-4.
- **`HiveCustomListRepository.getStats()` retourne `items: 0`** : `getAllLists()` ne charge pas les items (design Hive intentionnel), la méthode `getStats()` héritée du domaine compte toujours 0 items. Latent pré-existant — personne n'appelle via le port.
- **Méthodes `getDiagnostics()`/`getTypeDistribution()` publiques sur classes qui étendent le port domaine** : méthodes infrastructure publiques sur des subclasses du port — not a contract violation mais polluent la surface polymorphique. Non-breaking, design choice documenté.
- **`implements` → `extends` couplage structurel plus fort que pure interface** : ADR-001 architecture hexagonale préconise des ports comme interfaces pures ; `extends` crée un couplage d'héritage. Décision d'architecture acceptée pour hériter du default `getStats()`.
- **`InMemoryCustomListRepository` utilise encore `implements` (incohérence post-9-4)** : seul adapter restant avec `implements` — explicitement exclu du scope 9-4 (conforme, `getStats()` override sémantiquement correct).

## Deferred from: code review of 9-3-deplacement-ports-customlist-et-listitem-vers-domaine (2026-05-11)

- **Double méthodes génériques+domaine dans les 4 ISP sub-interfaces** [lib/domain/list/repositories/custom_list_repository.dart] : trade-off intentionnel T1.2 (éviter import domain←data) ; doublement de la surface contractuelle (10+4+2+2 au lieu de 5+2+1+1). À consolider en supprimant les alias génériques si tous les appelants migrent vers les noms domaine.
- **`getStats()` retourne des structures sémantiquement incompatibles selon l'implémentation (LSP)** [supabase_custom_list_repository.dart:295, hive_custom_list_repository.dart:250] : SupabaseCustomListRepository retourne `Map<String,int>` avec les types de listes ; HiveCustomListRepository retourne les stats infra Hive ; InMemoryCustomListRepository retourne `{count, completed, items}`. Violation LSP sémantique pré-existante — non introduite par 9-3. Priorité HIGH.
- **Constructeurs Supabase no-arg accèdent aux singletons sans initialisation explicite dans les tests contrat** [test/domain/list/repositories/*_contract_test.dart:15,14] : pattern identique à 9-1, tests passent en pratique, fragile en CI sans Supabase init.
- **`HiveCustomListRepository.getStats()` shadow silencieux du default domaine sans `@override`** [hive_custom_list_repository.dart:250] : retourne métriques infra Hive au lieu des stats domaine ; appelant polymorphe obtient des clés inattendues. Pré-existant.
- **`abstract class` au lieu de `abstract interface class` Dart 3+ pour les ports domaine** [custom_list_repository.dart, list_item_repository.dart domain] : `interface class` force l'implémentation explicite et empêche l'héritage de `getStats()`. À évaluer lors d'une story de consolidation des ports.
- **`InMemoryCustomListRepository.save()` lève sur ID dupliqué via `saveList(isNew: true)`** [custom_list_repository.dart data] : comportement pré-existant — les appelants utilisant `save()` comme upsert obtiennent une exception après le premier appel.

## Deferred from: code review of 9-2-typer-providers-riverpod-sur-interface-domain-habit (2026-05-11)

- **`print()` debug en production dans `HabitsNotifier`** [lib/data/providers/habits_state_provider.dart:~58] : `print('[HabitsProvider] I: Fetched...')` pré-existant, non nettoyé dans le scope 9.2 (changements purement statiques de typage).
- **Race autoDispose+StateNotifier entre `saveHabit`/`updateHabit` et `loadHabits()`** [lib/data/providers/habits_state_provider.dart:78-81,110-118] : si le notifier est disposé entre le `await repository.saveHabit()` et le `await loadHabits()` suivant (navigation away), `state = state.copyWith(...)` lève `StateError`. Pré-existant — hors scope typage pur de 9.2.
- **`addHabit`, `deleteHabit`, `updateHabit` non couverts par tests de typage sur l'interface domain** [test/data/providers/habits_state_provider_test.dart] : spec 9.2 exigeait uniquement la preuve de typage sur `loadHabits()` et le provider. Les 3 méthodes restantes avec annotation `HabitRepository` sont non exercées sous l'interface domain. À ajouter dans une story de consolidation des tests.

## Deferred from: code review of 9-1-deplacement-port-habit-repository-vers-domaine (2026-05-10)

- **`SupabaseHabitRepository()` dans le test contrat — singleton fallback** [test/domain/habit/repositories/habit_repository_contract_test.dart:14] : constructeur tombe sur `SupabaseService.instance` si aucun argument passé. Fonctionnel (tests passent), mais fragile si le singleton n'est pas initialisé dans certains environnements CI. Spec approuvait explicitement l'approche nullable.
- **`saveHabit` et `addHabit` identiques dans `InMemoryHabitRepository`** [lib/data/repositories/habit_repository.dart:27-35] : les deux méthodes appellent `_habits.add(habit)` sans distinction — pas de garde sur ID dupliqué. Sémantique du port ambiguë (upsert vs insert). Pré-existant.
- **`allHabitsProvider` === `habitsWithStatsProvider`** [lib/data/repositories/habit_repository.dart:76-85] : deux providers identiques, aucune distinction sémantique. Pré-existant.
- **`ref.read` dans `FutureProvider` au lieu de `ref.watch`** [lib/data/repositories/habit_repository.dart:77,83] : providers `allHabitsProvider` et `habitsWithStatsProvider` ne se recalculent pas lors d'une invalidation. Pré-existant.
- **`updateHabit` no-op silencieux sur ID inexistant** [lib/data/repositories/habit_repository.dart:39-44] : `indexWhere` retourne -1 sans erreur ni signal au caller. Pré-existant dans `InMemoryHabitRepository`.
- **`SupabaseHabitRepository` : `watchAllHabits`/`getStatsByCategory` hors port** [supabase_habit_repository.dart:185-225] : deux méthodes concrètes absentes du port `HabitRepository` — à supprimer ou intégrer au port dans une story dédiée. Pré-existant.
- **`habits_state_provider.dart` résout `HabitRepository` transitivement via data layer** [lib/data/providers/habits_state_provider.dart] : n'importe pas directement depuis `lib/domain/`. Si le fichier data est refactorisé sans re-export, compile en erreur. Intentionnel per T4.1 — faible risque.

## Deferred from: code review of 8-9-corriger-value-as-double-latent-services-et-presentation (2026-05-10)

- **Valeur `bool` dans completions d'une habitude quantitative → `TypeError` sur `(value as num)`** [lib/domain/habit/services/ ×6] : si une habitude est passée de binary à quantitative sans migrer les completions, la valeur `true`/`false` déclenche une `TypeError`. Pré-existant — même comportement avec l'ancien `(value as double)`.
- **`task.g.dart` / `list_item.g.dart` — `eloScore: fields[3|4] as double`** [lib/domain/models/core/entities/] : même classe de bug que le fix 8.9 sur `targetValue`. Hive peut désérialiser un `int` → `TypeError`. Hors scope 8.9 (spec exclut explicitement eloScore).
- **`elo_score.dart` / `priority.dart` / `list_item.dart` — `as double` sur champs JSON** [lib/domain/core/value_objects/, lib/domain/list/value_objects/] : Supabase peut retourner un `int` JSON pour ces colonnes → `CastError`. Hors scope 8.9.
- **`premium_habit_card.dart` — `widget.todayValue as num` (non-nullable) sans guard `bool`** [lib/presentation/widgets/cards/premium_habit_card.dart:173] : `HabitCard` a été corrigé, `PremiumHabitCard` ne l'a pas été. Si `todayValue` est un `bool` (habitude binary mal typée), `TypeError`. Pré-existant.
- **`_applyAdvancedFilter` — `minItems`/`maxItems` utilisent encore `as int`** [lib/data/providers/list_providers.dart:233-235] : `minProgress`/`maxProgress` ont été corrigés en 8.9 mais `minItems`/`maxItems` restent en `as int` — `TypeError` si un `double` est passé. Pré-existant, hors scope.
- **`_statusText` — espace trailing si `unit` null, `"0.0 / 0.0 "` si `targetValue` null** [lib/presentation/widgets/progress/habit_progress_bar.dart:107] : pré-existant, non introduit par 8.9.
- **`habit_recommendation_engine.dart` — `value is double` exclut silencieusement les `int` Supabase** [lib/domain/habit/services/analytics/habit_recommendation_engine.dart:163] : asymétrie avec les 6 services corrigés en 8.9 qui utilisent désormais `as num`. Mauvaise moyenne silencieuse. Hors scope 8.9.
- **Valeur `String` dans completions (JSONB round-trip) → `TypeError` sur `as num`** [lib/domain/habit/services/] : Supabase PostgREST peut retourner des nombres JSON comme strings dans certaines requêtes RPC. Pré-existant, hors scope.
- **`double.nan` dans completions — cast silencieux, sous-comptage séries et pré-remplissage `"NaN"` dans le dialog** [lib/domain/habit/services/ + habit_record_dialog.dart:34] : `nan >= target` est toujours `false`, séries sous-comptées sans erreur. Pré-existant.

## Deferred from: code review of 8-8-reprendre-import-interrompu-depuis-liste (2026-05-07)

- **`_startupInterrupt` reste en mémoire si utilisateur ne navigue pas vers la liste** [import_interrupt_service.dart] : intentionnel per Dev Notes 8.8 — `peekStartupInterrupt()` est non-destructif, `_startupInterrupt` n'est effacé que par `consumePendingResume()`. Si l'utilisateur ne visite jamais la liste dans la session, la mémoire reste occupée jusqu'à la fermeture de l'app. Borné à la session (SharedPreferences déjà nettoyées au démarrage). Acceptable per design.

## Deferred from: code review of 8-3-detecter-quit-refresh-pendant-import-massif (2026-05-06)

- **Race condition écritures `onProgress` concurrentes** [import_interrupt_service.dart:28] : fire-and-forget par design, dernière écriture gagne — les valeurs `current`/`total` sont idempotentes (la dernière valeur est toujours la plus récente). Tradeoff documenté en spec.
- **`checkAndLoadPersistedState` non idempotente sur double-appel** [import_interrupt_service.dart:13] : le second appel lit des prefs déjà effacées par le premier → `_startupInterrupt` silencieusement null. Appelée une seule fois par AppInitializer par design ; double-appel théorique.
- **Isolation singleton dans les tests** : `ImportInterruptService.instance` est statique — les tests partagent la même instance en mémoire. `setUp` avec `onComplete()` atténue le problème. Isolation parfaite nécessiterait DI (hors scope Epic 8).
- **Absence de gestion d'erreur `Future.wait([prefs.remove])`** [import_interrupt_service.dart:37] : `SharedPreferences.remove` échoue rarement en pratique ; si ça arrive, l'exception se propage au caller. Risque acceptable.
- **`_totalCount` diverge après skip doublons** [list_detail_page.dart:282] : si l'interruption survient entre la décision de skip et le `onProgress(titlesToAdd.length, titlesToAdd.length)` final, le `total` persisté est le compte pré-dedup. Complexité pré-existante dans `list_detail_page.dart`, hors scope story 8.3.
- **Fermeture onglet web sans lifecycle `paused`/`detached`** : limitation Flutter Web documentée (Dev Notes §6 de la story) — `beforeunload` non câblé. Les écritures `onProgress` successives in-progress dans localStorage couvrent le cas d'usage attendu.
- **Plusieurs `BulkAddDialog` simultanés — dernière écriture gagne** : non possible dans le flux UX actuel. Chaque dialog écrirait ses propres `current`/`total`, last-writer-wins, résultat non déterministe. Sans impact réel.
- **Geste "predictive back" Android 14+ sans `onComplete`** : `PopScope(canPop: !_isSubmitting)` bloque les pops normaux pendant l'import. Le cas predictive-back sous Android 14+ avec `onPopInvokedWithResult` non implémenté est très plateforme-spécifique et rare en pratique.
