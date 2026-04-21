# Story 6.2: Remplacer les points de contact placeholders par un support pilote reel

Status: ready-for-dev

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

En tant que premier utilisateur externe invite,
Je veux trouver des points d'aide, de feedback et d'information pilote reels,
afin de savoir comment demander de l'aide, signaler un probleme et comprendre le cadre du pilote.

## Acceptance Criteria

1. Etant donne un utilisateur pilote deja entre dans le shell du produit, quand il ouvre les entrees `Aide`, `Feedback`, `Confidentialite`, `Conditions` ou les informations de version pertinentes, alors il voit des informations et canaux pilotes reels plutot que de simples placeholders honnetes mais inertes, et ces points de contact restent localises, explicites et comprehensibles pour un utilisateur non createur.
2. Etant donne que le support du pilote reste volontairement minimal, quand l'utilisateur cherche quoi faire en cas de probleme ou de doute sur le perimetre, alors le produit explique le chemin de retour attendu, les limites connues et le niveau de support promis, et aucun etat visible ne suppose un contexte interne du createur ou une connaissance implicite du repo.
3. Etant donne que l'experience pilote doit rester sobre et credible, quand cette story est fermee, alors la preuve de cloture montre le parcours desktop, le parcours telephone et la source de verite des contenus affiches, et la story documente ce qui reste hors scope, comme un centre d'aide riche ou un support operationnel etendu.

## Tasks / Subtasks

- [ ] Reetablir une source de verite unique pour le support pilote minimal et les informations affichees dans le shell. (AC: 1, 2, 3)
  - [ ] Auditer `SettingsPage`, `CompactLanguageSelector`, les informations de version et les contenus legaux/de contact deja presents dans le repo pour supprimer les faux placeholders et les divergences visibles.
  - [ ] Choisir une source de verite explicite pour les contenus pilotes visibles (emails, chemin de retour, limites, version, infos legales minimales) au lieu de disperser ces valeurs dans plusieurs tiles, dialogs ou tests.
  - [ ] Si `assets/legal/mentions_legales.md` est reutilise, n'en extraire que les elements encore vrais et compatibles avec le pilote reel; ne pas republier tel quel un texte stale qui raconte encore une application purement locale.

- [ ] Transformer le chemin `HomePage -> SettingsPage` en surface de support pilote minimale mais reelle. (AC: 1, 2, 3)
  - [ ] Remplacer les tiles placeholder `Aide`, `Feedback`, `Confidentialite`, `Conditions` et `Version` par des actions observables et utiles (dialog, sheet, about, contenu copiable, information localisee) qui exposent un vrai canal ou une vraie information pilote.
  - [ ] Garder une experience sobre et comprehensible pour un non-createur: pas de jargon repo, pas de faux centre d'aide, pas de promesse de support etendu, pas de semantique contradictoire avec `6.1`.
  - [ ] Reutiliser `CompactLanguageSelector` comme vraie action de langue et fermer les residus hardcodes s'il est touche (`Language`, `Cancel`, `changed to ...`).

- [ ] Garder le slice dans les frontieres deja prouvees et eviter les integrations non justifiees. (AC: 2, 3)
  - [ ] Ne pas rouvrir `auth`, `persistance`, `synchro`, ni introduire de nouvelle route publique, de help center heberge, d'analytics ou de billing.
  - [ ] Ne pas ajouter `url_launcher`, `package_info_plus` ou une dependance externe sans justification explicite; preferer les primitives Flutter et la configuration du repo deja presentes si elles suffisent.
  - [ ] Si une action externe minimale est retenue plus tard, documenter pourquoi elle est necessaire pour le pilote reel et pourquoi une solution purement in-app ne suffit pas.

- [ ] Fermer une matrice de preuve desktop + telephone sur le parcours de support pilote. (AC: 1, 2, 3)
  - [ ] Ajouter ou recreer `test/presentation/pages/settings_page_test.dart` pour couvrir la structure localisee, la disparition des placeholders et la presence de vrais points de contact/info pilotes.
  - [ ] Etendre `test/presentation/pages/home_page_test.dart` pour prouver l'ouverture de `SettingsPage` depuis le shell sur desktop et sur telephone, et la lisibilite du support pilote sur `1280x800` et `390x844`.
  - [ ] Revalider `test/presentation/widgets/language_selector_test.dart` si le selector change, puis executer `flutter analyze --no-pub`, les tests widget cibles, et `flutter build web` si la surface web ou les assets visibles changent.

- [ ] Documenter avant implementation les ecarts reels entre les artefacts BMAD existants et le code officiel courant. (AC: 3)
  - [ ] Nommer explicitement dans le closeout que l'artefact `5.3` raconte une `SettingsPage` deja pilote-ready, alors que `main` officiel expose encore une version hardcodee et placeholder.
  - [ ] Lister les fichiers canoniques a lire avant implementation et les surfaces a ne pas reutiliser telles quelles (`onboarding`, anciens tests absents, preuves smoke non presentes dans l'etat officiel).

## Dev Notes

### Story Context

- `Epic 6` ferme le passage entre une shareability repo-owned et un premier pilote externe reel. `6.1` a deja rendu l'instance pilote identifiable et atteignable; `6.2` doit maintenant fermer le support minimal reel promis par le PRD et l'architecture, sans elargir le lane a un produit public plus large. [Source: `_bmad-output/planning-artifacts/epics.md`; `_bmad-output/planning-artifacts/prd.md`; `_bmad-output/planning-artifacts/architecture.md`]
- La base produit attendue pour `6.2` est le shell courant, pas un nouveau parcours: un utilisateur deja connecte ouvre `SettingsPage` depuis `HomePage` et y trouve les points d'aide, de feedback, d'information pilote et de version. [Source: `_bmad-output/planning-artifacts/epics.md`; `lib/presentation/pages/home_page.dart`; `lib/presentation/pages/settings_page.dart`]
- Divergence critique a ne pas masquer: l'artefact d'implementation `5.3` raconte une `SettingsPage` deja transformee en surface pilote honnete, mais le code officiel actuel sur `main` ne porte pas cette implementation. La story `6.2` doit donc etre authorisee contre l'etat reel du code officiel, pas contre le seul recit historique `5.3`. [Source: `_bmad-output/implementation-artifacts/5-3-ouvrir-prioris-progressivement-a-de-premiers-utilisateurs-externes.md`; `lib/presentation/pages/settings_page.dart`]
- `6.2` doit rester le plus petit slice observable apres `6.1`: fermer les points de contact et l'information pilote, pas reouvrir la cible de deploiement, l'auth, la persistance, la synchro ou le closeout global du pilote, qui releve de `6.3`. [Source: `_bmad-output/planning-artifacts/epics.md`; `_bmad-output/implementation-artifacts/6-1-rendre-une-instance-pilote-externe-identifiable-et-atteignable.md`]

### Technical Requirements

- Etat de depart exact a prouver pour `6.2`: utilisateur pilote deja authentifie, deja capable d'atteindre l'instance pilote identifiee par `6.1`, puis ouverture de `SettingsPage` depuis le shell desktop ou mobile pour trouver de vrais points de contact et informations pilotes.
- `SettingsPage` officielle actuelle reste un placeholder:
  - section unique `General`
  - libelles hardcodes en francais
  - tile `Langue` branchee sur une snackbar de dev
  - `Version 1.0.0` fausse par rapport au repo
  - tile `Aide` branchee sur une snackbar de dev
  Cette page doit etre consideree comme le hotspot reel de `6.2`, pas comme une surface deja fermee. [Source: `lib/presentation/pages/settings_page.dart`; `pubspec.yaml`]
- `LanguageSelector` et `CompactLanguageSelector` existent deja, mais portent encore des fallbacks hardcodes visibles (`Language`, `Cancel`, `changed to ...`). Si `6.2` les touche, elle doit fermer ces residus au lieu de les transporter dans la nouvelle surface pilote. [Source: `lib/presentation/widgets/selectors/language_selector.dart`]
- `assets/legal/mentions_legales.md` contient des contacts potentiellement reutilisables (`contact@prioris-app.com`, `support@prioris-app.com`), mais le corps du document raconte encore une application purement locale, sans serveurs externes. Il ne peut donc pas etre affiche tel quel comme verite legale/produit du pilote reel sans revue. [Source: `assets/legal/mentions_legales.md`]
- La version visible doit cesser d'etre fausse. `pubspec.yaml` expose `1.1.0+1`, tandis que `6.1` a deja introduit `PRIORIS_APP_VERSION` dans le lane Pages. `6.2` doit choisir une presentation honnete et unique de la version/build au lieu de rehardcoder un numero. [Source: `pubspec.yaml`; `docs/PILOT_PAGES_DEPLOYMENT.md`; `lib/core/config/app_config.dart`]
- Le support pilote peut rester minimal et in-app, mais il doit etre reel et observable: plus aucun tile interactif ne doit ressembler a une action puis ne rien faire ou afficher seulement `Fonctionnalite en cours de developpement`.
- Toute nouvelle chaine visible doit passer par `AppLocalizations`. Aucun texte durable ne doit etre ajoute en dur dans les widgets, et aucun fichier `lib/l10n/app_localizations*.dart` ne doit etre edite a la main. [Source: `_bmad-output/project-context.md`]

### Architecture Compliance

- Respecter la frontiere existante `HomePage -> SettingsPage -> widgets de presentation / AppConfig / assets ou source de contenu dediee`. Aucun widget de `6.2` ne doit parler directement a Supabase, lire `.env` hors abstraction, ou rouvrir un chemin `presentation -> infrastructure`. [Source: `_bmad-output/planning-artifacts/architecture.md`; `_bmad-output/project-context.md`]
- `6.2` peut toucher:
  - `lib/presentation/pages/settings_page.dart`
  - `lib/presentation/widgets/selectors/language_selector.dart`
  - `lib/presentation/pages/home_page.dart` si la preuve desktop/mobile de navigation doit etre ajustee
  - `lib/core/config/app_config.dart` ou une abstraction voisine si une source unique de version/support/info pilote y est legitime
  - les sources `l10n` `.arb`
  - un nouvel objet/const/widget de presentation dedie au support pilote si cela evite la duplication
  - les tests widget associes
- `6.2` ne doit pas toucher sans nouveau cadrage:
  - `AuthWrapper`, `auth_providers.dart`, `AuthService`
  - `UnifiedPersistenceService`, `PersistenceCoordinator`, repositories adaptatifs
  - la semantique globale de synchro visible
  - une nouvelle route publique, un onboarding riche, un help center heberge, de l'analytics, du billing ou une couche CRM/support outillee
- `6.2` doit reutiliser la semantique pilote deja introduite dans `6.1` (`AppConfig`, titre applicatif, identite pilote) au lieu de recreer une deuxieme histoire du pilote dans `SettingsPage`. [Source: `lib/core/config/app_config.dart`; `lib/presentation/app/prioris_app.dart`; `_bmad-output/implementation-artifacts/6-1-rendre-une-instance-pilote-externe-identifiable-et-atteignable.md`]

### Library / Framework Requirements

- Rester sur la stack actuelle du repo sans upgrade ni dependance nouvelle: Flutter web, Riverpod `2.4.9`, `flutter_localizations`, `intl 0.20.2`, `flutter_dotenv`, `logger`. [Source: `_bmad-output/project-context.md`; `pubspec.yaml`]
- Preferer les primitives Flutter/material deja suffisantes pour une surface sobre de support et d'information (`showDialog`, `SnackBar`, `AboutListTile`, `showAboutDialog`, `showLicensePage`) plutot qu'une sur-architecture ou une dependance externe. [Source: `_bmad-output/implementation-artifacts/5-3-ouvrir-prioris-progressivement-a-de-premiers-utilisateurs-externes.md`]
- Aucune integraton externe n'est requise par le perimetre de `6.2`. Si un futur `dev-story` estime necessaire un package comme `url_launcher`, cela devra etre justifie avant implementation car les garde-fous `5.3`/`6.2` poussent d'abord vers une solution in-app bornee. [Source: `_bmad-output/implementation-artifacts/5-3-ouvrir-prioris-progressivement-a-de-premiers-utilisateurs-externes.md`; `_bmad-output/planning-artifacts/architecture.md`]
- Aucun fichier genere (`lib/l10n/app_localizations*.dart`) ne doit etre edite a la main; passer par les `.arb` puis `flutter gen-l10n`. [Source: `_bmad-output/project-context.md`]

### File Structure Requirements

- Fichiers a lire avant implementation:
  - `lib/presentation/pages/home_page.dart`
  - `lib/presentation/pages/settings_page.dart`
  - `lib/presentation/widgets/selectors/language_selector.dart`
  - `lib/core/config/app_config.dart`
  - `lib/presentation/app/prioris_app.dart`
  - `lib/l10n/app_fr.arb`
  - `lib/l10n/app_en.arb`
  - `lib/l10n/app_es.arb`
  - `lib/l10n/app_de.arb`
  - `assets/legal/mentions_legales.md`
  - `docs/PILOT_PAGES_DEPLOYMENT.md`
  - `test/presentation/pages/home_page_test.dart`
  - `test/presentation/widgets/language_selector_test.dart`
- Fichiers susceptibles d'etre modifies pendant `dev-story`:
  - `lib/presentation/pages/settings_page.dart`
  - `lib/presentation/widgets/selectors/language_selector.dart`
  - `lib/presentation/pages/home_page.dart`
  - `lib/core/config/app_config.dart`
  - `lib/l10n/app_fr.arb`
  - `lib/l10n/app_en.arb`
  - `lib/l10n/app_es.arb`
  - `lib/l10n/app_de.arb`
  - nouveau `test/presentation/pages/settings_page_test.dart`
  - `test/presentation/pages/home_page_test.dart`
  - `test/presentation/widgets/language_selector_test.dart`
- Fichiers/surfaces a ne pas prendre comme base de preuve principale pour `6.2`:
  - anciens widgets `presentation/widgets/onboarding/`
  - textes stale racontant uniquement le runtime local
  - toute preuve smoke ou test absent de l'etat officiel courant
  - l'artefact `5.3` comme preuve que le code courant est deja implemente
- Observation importante pour `dev-story`: `test/presentation/pages/settings_page_test.dart` n'existe pas dans l'etat officiel actuel, malgre le recit historique `5.3`. Il faudra le recreer explicitement au lieu de supposer sa presence.

### Testing Requirements

- Verification ciblee minimale attendue pendant `dev-story`:
  - `flutter gen-l10n` si les `.arb` changent
  - `flutter analyze --no-pub lib/presentation/pages/settings_page.dart lib/presentation/widgets/selectors/language_selector.dart lib/presentation/pages/home_page.dart lib/core/config/app_config.dart test/presentation/pages/settings_page_test.dart test/presentation/widgets/language_selector_test.dart test/presentation/pages/home_page_test.dart`
  - `flutter test test/presentation/pages/settings_page_test.dart`
  - `flutter test test/presentation/widgets/language_selector_test.dart`
  - `flutter test test/presentation/pages/home_page_test.dart`
  - `flutter build web --no-pub --release --base-href=/PriorisProject/ --dart-define=PRIORIS_APP_VERSION=pilot-pages-local` si la surface visible du pilote, les contenus embarques ou les assets web visibles changent
- Cas de test minimaux a couvrir:
  - desktop: depuis `HomePage`, ouverture de `SettingsPage` et lecture claire de vrais points de contact/info pilotes
  - telephone: meme verification sur `390x844`, sans overflow ni labels coupes
  - disparition de la snackbar placeholder et de `Version 1.0.0`
  - toute action interactive de support/info fait reellement quelque chose d'observable
  - les contenus visibles restent localises et n'exposent pas de jargon repo/createur
  - la source de verite choisie pour le support/version/legal est coherente entre UI et tests
- Matrice de preuve requise pour fermer `6.2`:
  - une preuve desktop repo-owned sur `HomePage -> SettingsPage`
  - une preuve telephone repo-owned sur le meme chemin
  - une note explicite sur la source de verite des contenus pilotes affiches
  - une note explicite sur ce qui reste hors scope (`help center` riche, support operationnel etendu, legal public complet)

### Lane Intelligence

- `6.1` a deja ferme l'identite de l'instance pilote dans `AppConfig`, l'entree auth, le shell et la cible Pages. `6.2` doit reposer sur cette meme source de verite pilote, pas recreer une pile parallele de metadata dans `SettingsPage`. [Source: `_bmad-output/implementation-artifacts/6-1-rendre-une-instance-pilote-externe-identifiable-et-atteignable.md`; `lib/core/config/app_config.dart`]
- L'artefact `5.3` reste utile comme intention produit et garde-fou de scope (`pas de dependance externe gratuite`, `pas de faux support`, `pas de route publique supplementaire`), mais il n'est pas une preuve fiable de l'etat courant du code officiel. `6.2` doit reutiliser ses enseignements sans supposer que son implementation est presente. [Source: `_bmad-output/implementation-artifacts/5-3-ouvrir-prioris-progressivement-a-de-premiers-utilisateurs-externes.md`; `lib/presentation/pages/settings_page.dart`]
- Le PRD et l'architecture convergent: le plus petit design acceptable pour le pilote reel est `instance reelle nommee + support minimal reel + gate de sortie`. `6.2` ferme la deuxieme brique seulement; `6.3` fermera le gate documentaire. [Source: `_bmad-output/planning-artifacts/prd.md`; `_bmad-output/planning-artifacts/architecture.md`; `_bmad-output/planning-artifacts/epics.md`]

### Git Intelligence Summary

- Les commits recents du depot portent le lane `6.1` (`pilot identity`, `pilot pages build`, `deploy pilot pages workflow`) et ne ferment pas encore le support pilote au niveau `SettingsPage`. [Source: `git log -5 --pretty=format:"%h %ad %s" --date=short`]
- Le dernier commit touchant `lib/presentation/pages/settings_page.dart` remonte a `2025-10-27` (`chore: checkpoint before widget refactor`) et correspond a une simplification, pas a une surface pilote aboutie. Cette page doit donc etre traitee comme stale, pas comme un pattern deja valide. [Source: `git log --stat -1 -- lib/presentation/pages/settings_page.dart`]
- `lib/presentation/widgets/selectors/language_selector.dart` n'a pas connu d'evolution recente depuis son ajout initial. C'est une primitive de reuse utile, mais pas une preuve qu'elle est deja prete pour un pilote externe. [Source: `git log --stat -1 -- lib/presentation/widgets/selectors/language_selector.dart`]

### Project Context Reference

- `tasks/todo.md` reste la source de verite du slice BMAD courant et doit contenir plan, revue, validations executees et prochaine etape.
- `_bmad-output/project-context.md` impose:
  - pas d'edition manuelle des fichiers generes
  - pas de texte durable hardcode comme solution normale
  - pas de chemin direct `presentation -> infrastructure`
  - petits lots verifies avant de declarer la story terminee
  - replanification immediate si une dependance ou une integration externe devient necessaire
- Le flux BMAD attendu apres cette story est `dev-story`, puis `code-review`.

### Project Structure Notes

- `SettingsPage` est le hotspot reel du lot: tout y est encore hardcode, la version visible est fausse et les actions utiles sont placeholders. [Source: `lib/presentation/pages/settings_page.dart`]
- `HomePage` fournit deja le point d'entree de navigation vers `SettingsPage` sur desktop et mobile; il n'y a aucune raison d'ouvrir une route parallele pour `6.2`. [Source: `lib/presentation/pages/home_page.dart`]
- `CompactLanguageSelector` est la meilleure primitive de reuse pour fermer la langue dans ce slice, mais il reste a realigner si la story le touche. [Source: `lib/presentation/widgets/selectors/language_selector.dart`]
- `assets/legal/mentions_legales.md` est utile comme source candidate de contacts, pas comme bloc de contenu directement publiable pour le pilote reel. [Source: `assets/legal/mentions_legales.md`]

### References

- Planning canonique:
  - `_bmad-output/planning-artifacts/epics.md`
  - `_bmad-output/planning-artifacts/prd.md`
  - `_bmad-output/planning-artifacts/architecture.md`
  - `_bmad-output/planning-artifacts/ux-guidance-minimale.md`
- Contexte implementation:
  - `_bmad-output/implementation-artifacts/5-3-ouvrir-prioris-progressivement-a-de-premiers-utilisateurs-externes.md`
  - `_bmad-output/implementation-artifacts/6-1-rendre-une-instance-pilote-externe-identifiable-et-atteignable.md`
  - `_bmad-output/project-context.md`
- Code et docs:
  - `lib/presentation/pages/home_page.dart`
  - `lib/presentation/pages/settings_page.dart`
  - `lib/presentation/widgets/selectors/language_selector.dart`
  - `lib/core/config/app_config.dart`
  - `lib/presentation/app/prioris_app.dart`
  - `assets/legal/mentions_legales.md`
  - `docs/PILOT_PAGES_DEPLOYMENT.md`
  - `pubspec.yaml`
- Tests:
  - `test/presentation/pages/home_page_test.dart`
  - `test/presentation/widgets/language_selector_test.dart`

## Change Log

- 2026-04-14: story creee via workflow `create-story` pour preparer le slice `support pilote minimal reel` d'`Epic 6`, en l'alignant explicitement sur l'etat reel du code officiel et non sur le seul recit historique `5.3`.

## Dev Agent Record

### Agent Model Used

GPT-5 Codex

### Implementation Plan

- Ecrire d'abord les tests rouges qui prouvent que `SettingsPage` ne montre plus de placeholders et affiche de vrais points de contact/info pilotes sur desktop et telephone.
- Introduire ensuite une source de verite unique pour les contenus visibles du support pilote, puis la brancher sur `SettingsPage` et les affordances associees sans ajouter de dependance non justifiee.
- Fermer enfin la matrice de preuve ciblee (`gen-l10n`, `analyze`, widget tests, `build web` si necessaire) et documenter explicitement la source de verite retenue ainsi que les hors-scope restants.

### Debug Log References

- Workflow `create-story` + analyse de:
  - `_bmad-output/planning-artifacts/epics.md`
  - `_bmad-output/planning-artifacts/prd.md`
  - `_bmad-output/planning-artifacts/architecture.md`
  - `_bmad-output/planning-artifacts/ux-guidance-minimale.md`
  - `_bmad-output/project-context.md`
  - `_bmad-output/implementation-artifacts/5-3-ouvrir-prioris-progressivement-a-de-premiers-utilisateurs-externes.md`
  - `_bmad-output/implementation-artifacts/6-1-rendre-une-instance-pilote-externe-identifiable-et-atteignable.md`
  - `lib/presentation/pages/settings_page.dart`
  - `lib/presentation/widgets/selectors/language_selector.dart`
  - `assets/legal/mentions_legales.md`
  - `docs/PILOT_PAGES_DEPLOYMENT.md`
  - `pubspec.yaml`
  - `git log -5 --pretty=format:"%h %ad %s" --date=short`
  - `git log --stat -1 -- lib/presentation/pages/settings_page.dart`
  - `git log --stat -1 -- lib/presentation/widgets/selectors/language_selector.dart`

### Completion Notes List

- Story `6.2` creee en `ready-for-dev`.
- Garde-fou critique capture: l'artefact `5.3` ne doit pas etre traite comme preuve que le code officiel porte deja une `SettingsPage` pilote-ready.
- La story force une source de verite explicite pour les contenus de support pilote et borne clairement ce qui reste hors scope.

### File List

- `_bmad-output/implementation-artifacts/6-2-remplacer-les-points-de-contact-placeholders-par-un-support-pilote-reel.md`
