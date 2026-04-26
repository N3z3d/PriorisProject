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

## Deferred from: code review of 7-3-feedback-visuel-operations-longues (2026-04-25)

- **IdGenerationService instanciée inline** [list_detail_page.dart] : `final idService = IdGenerationService()` dans le callback `onSubmit` — violation DIP pré-existante, non testable sans monkey-patching. À injecter lors d'un prochain refactoring.
- **addMultipleItemsToList alias vide** [lists_controller_slim.dart] : méthode qui délègue à `addMultipleItems` sans valeur ajoutée. Pré-existant, supprimable lors du prochain nettoyage du controller.
- **verifyItemPersistence dans la boucle de sauvegarde** [lists_persistence_manager.dart] : appel `await verifyItemPersistence(items[i].id)` après chaque item ajoute un aller-retour non spécifié dans la story. Comportement pré-existant — à évaluer si les performances sur grands imports posent problème.
