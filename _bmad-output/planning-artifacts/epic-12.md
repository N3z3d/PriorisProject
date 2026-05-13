# Epic 12 : Observabilité, Analytics & Admin Dashboard

**Objectif :** Doter Prioris d'une couche d'observabilité complète inspirée des standards big tech — error tracking (pattern Sentry/Crashlytics), product analytics événementiel (pattern Firebase/PostHog), dashboard admin Customer 360 (pattern Stripe), métriques infrastructure (pattern CloudWatch) et alertes sur anomalies. Passer d'un produit "aveugle" à un produit qui se pilote par la donnée.

**Philosophie :** Tout est un event avec des propriétés. Chaque agrégat est drill-downable jusqu'à l'utilisateur individuel. Tout est actionnable — pas seulement visible.

**Source :** Demande Thibaut 2026-05-13 — inspiration Amazon/Google/Facebook/Stripe sur ce qui se fait réellement dans le monitoring de produit en production.

**Pré-requis :** Epic 11 clôturé — domaine `app.prioris.fr` actif, CI/CD gates en place, branche `main` protégée.

---

## Piliers de l'Epic

| Pilier | Stories | Inspiration |
|--------|---------|-------------|
| **1 — Error Observability** | 12.1 → 12.2 | Sentry, Crashlytics (Google) |
| **2 — Product Analytics** | 12.3 → 12.6 | PostHog, Firebase Analytics, Facebook Scuba |
| **3 — Admin Dashboard** | 12.7 → 12.9 | Stripe Customer 360, Supabase Studio |
| **4 — Infra & Alertes** | 12.10 → 12.11 | Amazon CloudWatch, Datadog |

---

## Pilier 1 — Error Observability

### Story 12.1 : Intégrer Sentry — crash tracking et error observability

**As a** Thibaut (propriétaire produit),
**I want** voir en temps réel le taux de crash, les erreurs par page et les traces d'appel liées à un utilisateur précis,
**so that** je détecte et reproduis les bugs en production avant que les utilisateurs se plaignent.

**Contexte — pourquoi Sentry :**
Google Crashlytics (Firebase) et Sentry sont les deux références industrielles. Sentry est choisi ici car : SDK Flutter officiel et maintenu, hébergement EU disponible (RGPD), plan gratuit 5 000 errors/mois, interface de triage supérieure à Crashlytics, intégration GitHub pour lier les erreurs aux commits.

**Comportement attendu :**
- Chaque erreur Flutter non gérée (FlutterError, Dart errors) est capturée automatiquement
- Chaque erreur capturée inclut : stack trace, user ID (anonymisé — UUID Supabase, jamais l'email), version de l'app, page courante, breadcrumbs (dernier événements avant l'erreur)
- Les erreurs sont groupées par type dans le dashboard Sentry
- Métrique principale visible : **"Crash-free users %"** — cible > 99,5%
- L'email de l'utilisateur n'est jamais envoyé à Sentry (RGPD)

**Plan technique :**
1. Ajouter `sentry_flutter: ^8.x` dans `pubspec.yaml`
2. Initialiser Sentry dans `lib/core/bootstrap/app_initializer.dart` (avant `runApp`) avec DSN stocké dans `AppConfig` (variable d'environnement, pas hardcodé)
3. Wrapper `runApp` dans `runZonedGuarded` pour capturer les erreurs async Dart
4. Définir `FlutterError.onError = (details) => Sentry.captureException(details.exception, stackTrace: details.stack)`
5. Après login Supabase : appeler `Sentry.configureScope((scope) => scope.setUser(SentryUser(id: userId)))` — user ID uniquement, pas d'email
6. Après logout / revoke consent : `Sentry.configureScope((scope) => scope.setUser(null))`
7. Créer `lib/infrastructure/monitoring/sentry_service.dart` — abstraction de l'initialisation et de la configuration du scope
8. Ajouter DSN Sentry comme variable d'env GitHub Actions (`SENTRY_DSN`) et dans `AppConfig`

**Acceptance Criteria :**
1. `sentry_flutter` intégré — app démarre et se connecte à Sentry sans erreur
2. Une exception `throw Exception('test')` dans un bouton de debug → apparaît dans Sentry avec stack trace dans les 30 secondes
3. Le scope utilisateur est défini après login (user ID Supabase) et effacé après logout
4. L'email de l'utilisateur n'apparaît **jamais** dans les données Sentry (vérifié dans le dashboard)
5. Le DSN est lu depuis `AppConfig` / variable d'environnement — jamais hardcodé dans le code source
6. `puro flutter analyze --no-pub` → 0 nouvelle erreur
7. `puro flutter test --exclude-tags integration` → 0 régression

**Priorité :** 🔴 Haute — premier instrument de production, doit être actif dès le lancement
**Effort estimé :** 3-4h
**Dépendances :** Aucune (peut commencer dès Epic 11 clôturé)

---

### Story 12.2 : Configurer les alertes Sentry — seuils d'erreur et notifications

**As a** Thibaut (propriétaire produit),
**I want** recevoir un email automatique quand le taux d'erreurs dépasse un seuil ou qu'un nouveau crash touche plusieurs utilisateurs,
**so that** je sois informé proactivement sans surveiller Sentry manuellement.

**Contexte :** Sans alertes, Sentry n'est qu'un log. L'objectif est d'atteindre le pattern "zero-touch monitoring" : l'app m'alerte, pas l'inverse.

**Règles d'alerte à configurer dans Sentry :**

| Règle | Seuil | Destination |
|-------|-------|-------------|
| Nouveau problème jamais vu | Première occurrence | Email immédiat |
| Problème régression (résolu → réapparu) | 1 occurrence | Email immédiat |
| Volume d'erreurs — spike | > 10 events/heure sur un même issue | Email |
| Crash-free users chute | < 99% sur 24h | Email |
| Erreur critique (tag `level=fatal`) | N'importe quelle occurrence | Email immédiat |

**Acceptance Criteria :**
1. Les 5 règles d'alerte sont configurées dans le projet Sentry
2. Un test simulé (throw Exception depuis un bouton debug) déclenche une alerte dans les 5 minutes
3. Les alertes arrivent à `lambert.thibaut98@gmail.com`
4. Un runbook `docs/runbooks/error-response.md` documente : comment lire un Sentry issue, comment identifier l'utilisateur affecté, comment déployer un hotfix
5. La page Sentry est bookmarkée et référencée dans `docs/runbooks/error-response.md`

**Priorité :** 🟡 Moyenne — dépend de 12.1
**Effort estimé :** 1h (configuration UI Sentry, pas de code Flutter)
**Dépendances :** Story 12.1 complétée

---

## Pilier 2 — Product Analytics

### Story 12.3 : Intégrer PostHog — SDK Flutter et tracking des events clés

**As a** Thibaut (propriétaire produit),
**I want** que chaque action significative des utilisateurs soit trackée comme un event structuré,
**so that** je puisse construire des funnels, des rapports de rétention et des métriques d'adoption sur des données réelles.

**Contexte — pourquoi PostHog :**
PostHog est le seul outil open source qui combine en un seul produit ce que Facebook, Google et Stripe utilisent séparément : events (Mixpanel), feature flags (LaunchDarkly), session recording (Hotjar), funnels et cohortes (Amplitude). Hébergé sur EU Cloud → RGPD natif. Plan gratuit : 1 million d'events/mois. SDK Flutter officiel et maintenu.

**Philosophie event-based (pattern Facebook) :**
Chaque event = une action utilisateur + des propriétés contextuelles. Jamais de PII dans les propriétés (pas de noms de tâches, pas d'emails). User ID = UUID Supabase.

**Catalogue d'events à tracker :**

| Event | Déclencheur | Propriétés |
|-------|-------------|------------|
| `app_opened` | App launched / returned to foreground | `platform`, `app_version` |
| `user_signed_up` | Inscription Supabase réussie | `method` (email/google) |
| `user_signed_in` | Connexion réussie | `method` |
| `user_signed_out` | Déconnexion | — |
| `consent_accepted` | Consentement accordé | — |
| `consent_revoked` | Consentement retiré | — |
| `task_created` | Nouvelle tâche créée | `list_id` (anonymisé) |
| `task_completed` | Tâche marquée comme faite | — |
| `task_count_milestone` | Compteur tâches franchit seuil | `milestone` (5, 10, 25, 50) |
| `duel_started` | Duel chargé avec succès | — |
| `duel_choice_made` | Choix effectué dans un duel | — |
| `activation_event` | 10 tâches + 1er duel complété | `tasks_count`, `duels_count` |
| `habit_created` | Nouvelle habitude créée | `frequency` |
| `habit_marked_done` | Habitude marquée comme faite | — |
| `list_created` | Nouvelle liste créée | — |
| `onboarding_started` | Onboarding actif démarré | — |
| `onboarding_completed` | Onboarding terminé | `tasks_created`, `duels_completed` |
| `insight_viewed` | Page Insights ouverte | — |
| `settings_opened` | Page Paramètres ouverte | — |

**Plan technique :**
1. Ajouter `posthog_flutter: ^4.x` dans `pubspec.yaml`
2. Initialiser PostHog dans `lib/core/bootstrap/app_initializer.dart` avec API key et host EU (`https://eu.i.posthog.com`) stockés dans `AppConfig`
3. Créer `lib/infrastructure/monitoring/analytics_service.dart` — wrappeur du SDK PostHog exposant `track(String event, {Map<String, Object>? properties})` et `identify(String userId)` et `reset()`
4. Appeler `identify(userId)` après login Supabase
5. Appeler `reset()` après logout / revoke consent
6. Appeler `track('consent_revoked')` dans `ConsentNotifier.revoke()` avant le reset (pour le compter)
7. Injecter `AnalyticsService` via Riverpod provider dans les notifiers/pages concernés
8. Si consent = false (avant acceptation) → ne pas tracker (appeler `posthog.optOut()`)
9. Si consent = true → tracking actif (appeler `posthog.optIn()`)
10. Variable API key dans GitHub Actions secrets + `AppConfig`

**Acceptance Criteria :**
1. `posthog_flutter` intégré — app démarre sans erreur
2. Déclencher `task_created` dans l'app → l'event apparaît dans PostHog Live Events dans les 5 secondes
3. `identify` appelé après login → les events suivants sont liés au bon user ID dans PostHog
4. `reset` appelé après logout → les events suivants sont anonymes
5. Aucun PII (email, nom de tâche, contenu) dans les propriétés des events — vérifié dans PostHog Live Events
6. Si `consentProvider = data(false)` → PostHog en opt-out, aucun event envoyé
7. API key lue depuis `AppConfig` — jamais hardcodée
8. `puro flutter analyze --no-pub` → 0 nouvelle erreur
9. `puro flutter test --exclude-tags integration` → 0 régression

**Priorité :** 🔴 Haute — fondation des stories 12.4, 12.5, 12.6
**Effort estimé :** 4-6h
**Dépendances :** Aucune (parallèle à 12.1)

---

### Story 12.4 : Funnel d'activation — mesurer le chemin vers le moment de valeur

**As a** Thibaut (propriétaire produit),
**I want** voir à chaque étape combien d'utilisateurs avancent vers l'activation event (10 tâches + 1er duel),
**so that** j'identifie où les gens abandonnent et où concentrer les améliorations produit.

**Contexte — le KPI #1 de Prioris :**
L'activation event de Prioris est le moment où une tâche émerge comme priorité sans effort conscient de classement. Cela se produit après ~10 tâches + quelques duels. Ce funnel est l'équivalent de "7 amis en 10 jours" pour Facebook. Tout le reste du produit sert à amener l'utilisateur à ce moment.

**Funnel à créer dans PostHog :**

```
Étape 1 : user_signed_up
    ↓
Étape 2 : task_created (au moins 1)
    ↓
Étape 3 : task_count_milestone (milestone = 10)
    ↓
Étape 4 : duel_choice_made (au moins 1)
    ↓
Étape 5 : activation_event
```

**Métriques attendues :**
- Taux de conversion global (étape 1 → étape 5)
- Taux de conversion par étape (drop-off à chaque transition)
- Médiane du temps entre chaque étape
- Comparaison par cohorte d'inscription (semaine par semaine)

**Acceptance Criteria :**
1. Le funnel en 5 étapes est créé et sauvegardé dans PostHog (dashboard "Activation Funnel")
2. Le funnel affiche des données pour au moins 1 utilisateur test ayant parcouru toutes les étapes
3. Un document `docs/analytics/activation-funnel.md` explique : comment lire le funnel, les seuils cibles, les actions produit recommandées si un drop-off > 50% est détecté
4. L'event `activation_event` est déclenché exactement une fois par utilisateur (idempotent — pas à chaque session)

**Priorité :** 🔴 Haute — KPI #1 du produit
**Effort estimé :** 2h (configuration PostHog + doc + vérification event idempotent)
**Dépendances :** Story 12.3 complétée + données accumulées (≥ 5 utilisateurs test)

---

### Story 12.5 : Rétention D1 / D7 / D30 — mesurer si les utilisateurs reviennent

**As a** Thibaut (propriétaire produit),
**I want** voir pour chaque cohorte hebdomadaire d'inscrits quel % revient à J+1, J+7 et J+30,
**so that** je sache si l'app crée une habitude d'usage ou si les utilisateurs s'évaporent après la première session.

**Contexte — pattern industriel :**
La rétention cohortée est la métrique de santé produit la plus fiable dans l'industrie. Facebook maintient D30 > 60%, les apps de productivité B2C visent D7 > 30% comme signal de santé minimum. Sans cette métrique, on ne sait pas si on construit un vrai produit ou un one-shot.

**Rapport de rétention PostHog :**
- Méthode : "Retention" PostHog avec event de retour = `app_opened` ou `duel_choice_made`
- Granularité : cohortes hebdomadaires
- Fenêtre : D0 (inscription), D1, D3, D7, D14, D30
- Segmentation : cohortes avec vs sans activation event (test de l'hypothèse "les utilisateurs activés ont une meilleure rétention")

**Seuils de référence (à mesurer, pas à inventer) :**

| Signal | Interprétation |
|--------|----------------|
| D7 < 10% | Problème critique de rétention — revoir le produit de fond en comble |
| D7 10-25% | Rétention faible — améliorer l'onboarding et les notifications |
| D7 25-40% | Rétention correcte — optimiser les features |
| D7 > 40% | Rétention forte — scaler l'acquisition |

**Acceptance Criteria :**
1. Rapport de rétention sauvegardé dans PostHog (dashboard "Retention")
2. Le rapport affiche au moins 2 cohortes hebdomadaires avec données
3. Segmentation "avec activation event" vs "sans" visible dans le rapport
4. `docs/analytics/retention.md` documente : comment lire les cohortes, les seuils de référence, les actions recommandées par palier

**Priorité :** 🟡 Moyenne — nécessite 2-4 semaines de données post-12.3
**Effort estimé :** 1-2h (configuration PostHog + doc)
**Dépendances :** Story 12.3 complétée + ≥ 2 semaines de données

---

### Story 12.6 : Feature adoption — quelles fonctionnalités les utilisateurs utilisent vraiment

**As a** Thibaut (propriétaire produit),
**I want** voir quel % des utilisateurs actifs utilise chaque fonctionnalité principale (Prioriser, Habitudes, Insights),
**so that** je concentre les développements sur ce qui est réellement utilisé et abandonne ce qui ne l'est pas.

**Contexte — pattern Google/Facebook :**
Google Play Console et Facebook Insights montrent l'adoption par feature. La question n'est pas "est-ce qu'on a livré la feature" mais "est-ce que les utilisateurs s'en servent". Une feature utilisée par < 5% des actifs est un candidat à la suppression ou à la refonte.

**Métriques à construire dans PostHog (Insights) :**

| Métrique | Event | Fenêtre |
|----------|-------|---------|
| % actifs utilisant Prioriser | `duel_choice_made` | 7 jours glissants |
| % actifs utilisant Habitudes | `habit_marked_done` | 7 jours glissants |
| % actifs utilisant Insights | `insight_viewed` | 7 jours glissants |
| % actifs utilisant Listes | `list_created` OR `task_created` | 7 jours glissants |
| Fréquence médiane duels/user/semaine | `duel_choice_made` | 7 jours glissants |
| Fréquence médiane habits complétés/user/semaine | `habit_marked_done` | 7 jours glissants |

**Acceptance Criteria :**
1. Dashboard "Feature Adoption" sauvegardé dans PostHog avec les 6 métriques
2. Chaque métrique est calculée sur les utilisateurs actifs (au moins 1 `app_opened` dans les 7 derniers jours) — pas sur la totalité des inscrits
3. `docs/analytics/feature-adoption.md` documente : comment lire le dashboard, seuils d'alerte (< 5% = feature à risque), process de décision pour déprécier une feature

**Priorité :** 🟡 Moyenne — nécessite des données post-12.3
**Effort estimé :** 1-2h (configuration PostHog + doc)
**Dépendances :** Story 12.3 complétée + ≥ 1 semaine de données

---

## Pilier 3 — Admin Dashboard (Customer 360)

### Story 12.7 : Page admin Flutter — liste des utilisateurs avec recherche

**As a** Thibaut (admin),
**I want** accéder depuis l'app à une page protégée qui liste tous les utilisateurs inscrits avec leurs données clés,
**so that** je puisse répondre rapidement aux demandes de support et RGPD sans ouvrir Supabase Studio à chaque fois.

**Contexte — pattern Stripe :**
Stripe a le meilleur Customer Dashboard de l'industrie. Tu recherches un email → tu vois l'intégralité de l'historique de ce client. Pour Prioris, l'objectif est le même : chercher un utilisateur → voir tout → agir.

**Accès :**
- Route `/admin` dans `AppRoutes` — non exposée dans la navigation principale
- Accessible depuis `SettingsPage` uniquement si `supabase.auth.currentUser.userMetadata['role'] == 'admin'`
- Thibaut doit se setter manuellement `role = 'admin'` dans Supabase Dashboard → Authentication → Users → Edit user metadata
- En dehors de ce rôle, la route renvoie `403 / page non trouvée`

**Vue liste — colonnes :**

| Colonne | Source |
|---------|--------|
| Email | `auth.users.email` |
| Inscrit le | `auth.users.created_at` |
| Dernière connexion | `auth.users.last_sign_in_at` |
| Nb tâches | `COUNT(tasks WHERE user_id = ...)` |
| Nb habitudes | `COUNT(habits WHERE user_id = ...)` |
| Consentement | `shared_preferences` n'est pas queryable → boolean depuis `profiles` table si elle existe, sinon N/A |
| Actions | Bouton "Voir détail" |

**Fonctionnalités :**
- Barre de recherche par email (debounce 300ms)
- Tri par date d'inscription (desc par défaut)
- Pagination 20 utilisateurs par page
- Indicateur de chargement (skeleton)

**Sécurité — absolument obligatoire :**
- La route `/admin` vérifie le rôle côté Flutter AND utilise une Supabase RLS policy ou Supabase Edge Function admin-only pour les requêtes SQL
- Un utilisateur lambda qui tente de requêter `auth.users` directement depuis le client Flutter doit obtenir une erreur 403 — jamais les données

**Acceptance Criteria :**
1. Page `/admin` accessible uniquement si `user.userMetadata['role'] == 'admin'`
2. Un utilisateur sans rôle admin voit une page "Accès refusé" s'il tente `/admin`
3. La liste affiche email, date inscription, dernière connexion, nb tâches
4. Recherche par email filtre la liste en temps réel (debounce 300ms)
5. Pagination 20 par page fonctionnelle
6. Les requêtes admin sont protégées par RLS / Edge Function — jamais exposées à un client non-admin
7. `puro flutter analyze --no-pub` → 0 nouvelle erreur
8. `puro flutter test --exclude-tags integration` → 0 régression

**Priorité :** 🔴 Haute — nécessaire pour le support utilisateur et la conformité RGPD
**Effort estimé :** 6-8h
**Dépendances :** Aucune (parallèle aux stories PostHog/Sentry)

---

### Story 12.8 : Fiche utilisateur — Customer 360 et actions RGPD

**As a** Thibaut (admin),
**I want** cliquer sur un utilisateur et voir toutes ses données, son historique d'activité et pouvoir déclencher des actions RGPD directement,
**so that** je traite les demandes de suppression de compte, d'export de données et de support en moins de 2 minutes.

**Contexte — RGPD obligatoire :**
Le RGPD (Art. 15-17) oblige à répondre aux demandes d'accès et de suppression dans 30 jours. Sans admin dashboard, chaque demande prend 30-60 min de manipulation Supabase. Avec ce dashboard : 2 minutes.

**Vue fiche utilisateur — sections :**

**Section "Profil" :**
- Email, UUID, date d'inscription, dernière connexion, provider (email/google)
- Statut consentement (si stocké dans une `profiles` table) + date d'acceptation/révocation

**Section "Données" (compteurs) :**
- Nb tâches actives / complétées
- Nb habitudes actives / archivées
- Nb listes
- Nb duels effectués (si loggué)
- Nb jours actifs (sessions distinctes)

**Section "Actions RGPD" :**

| Action | Description | Confirmation requise |
|--------|-------------|---------------------|
| Exporter données | Génère un JSON de toutes les données de l'utilisateur (tâches, habitudes, listes, profil) et le télécharge | Non |
| Supprimer compte | Supprime toutes les données utilisateur + compte `auth.users` via Supabase Admin API | Oui — dialog avec saisie de l'email pour confirmer |
| Réinitialiser consentement | Met `privacy_consent_v1` à null (force l'affichage de `ConsentGatePage` à la prochaine connexion) | Oui |

**Acceptance Criteria :**
1. Fiche utilisateur affiche les 3 sections (Profil, Données, Actions RGPD)
2. "Exporter données" génère un fichier JSON téléchargeable contenant l'intégralité des données utilisateur (aucune donnée manquante)
3. "Supprimer compte" : dialog de confirmation avec saisie de l'email → si email correct → suppression complète → redirection vers la liste des utilisateurs
4. "Supprimer compte" : si l'utilisateur est l'admin lui-même → action bloquée avec message d'erreur
5. "Réinitialiser consentement" : dialog de confirmation → action logguée (audit trail)
6. Toutes les actions admin sont logguées dans une table `admin_audit_log` (user_id_admin, user_id_cible, action, timestamp)
7. `puro flutter analyze --no-pub` → 0 nouvelle erreur
8. `puro flutter test --exclude-tags integration` → 0 régression

**Priorité :** 🔴 Haute — conformité RGPD
**Effort estimé :** 6-8h
**Dépendances :** Story 12.7 complétée

---

### Story 12.9 : Utilisateurs actifs en temps réel — présence et activité live

**As a** Thibaut (admin),
**I want** voir combien d'utilisateurs sont connectés à l'application en ce moment et sur quelle page ils se trouvent,
**so that** j'aie une vue "live" de l'usage du produit et puisse corréler les pics de support avec les pics d'usage.

**Contexte — pattern Google Analytics Real-Time / Facebook Operational Dashboard :**
Google Analytics affiche "X utilisateurs actifs ces 30 dernières minutes" avec répartition par page. Facebook affiche le nombre de sessions actives par feature. Pour Prioris, l'objectif est d'avoir ce chiffre visible en temps réel dans le dashboard admin.

**Implémentation via Supabase Realtime Presence :**
- À l'ouverture de l'app (après consent = true), rejoindre un channel Supabase Realtime `presence:global`
- Chaque utilisateur publie un payload minimal : `{ userId: uuid, page: 'home' | 'prioriser' | 'habitudes' | 'listes' | 'insights' | 'settings' }`
- À la fermeture de l'app (`AppLifecycleState.detached`), quitter le channel
- Le dashboard admin souscrit au même channel et lit le `presenceState` pour afficher le count et la répartition par page

**Affichage dans le dashboard admin :**
- Compteur "X utilisateurs actifs maintenant" (mis à jour en temps réel)
- Répartition par page : "2 sur Prioriser, 1 sur Habitudes, etc."
- Timestamp "mis à jour il y a X secondes"

**Privacy :**
- La page courante est partagée mais pas les données de l'utilisateur (pas de tâches, pas de noms)
- Le channel Presence n'est lisible que par le rôle admin (RLS sur le channel)
- Opt-out si consent = false

**Acceptance Criteria :**
1. L'app rejoint le channel Presence après login + consent=true
2. L'app quitte le channel Presence après logout ou revoke consent
3. Le dashboard admin affiche le nombre d'utilisateurs actifs en temps réel (mis à jour < 5 secondes)
4. La répartition par page est visible dans le dashboard admin
5. Un utilisateur sans rôle admin ne peut pas lire le channel Presence admin
6. `puro flutter analyze --no-pub` → 0 nouvelle erreur
7. `puro flutter test --exclude-tags integration` → 0 régression

**Priorité :** 🟡 Moyenne
**Effort estimé :** 4-5h
**Dépendances :** Story 12.7 (pour l'UI admin) ; Supabase Realtime activé (inclus dans le plan gratuit)

---

## Pilier 4 — Infra & Alertes

### Story 12.10 : Métriques opérationnelles Supabase — santé de l'infrastructure

**As a** Thibaut (admin),
**I want** voir dans le dashboard admin les métriques clés de santé de la base de données et de l'API,
**so that** je détecte une dégradation ou une saturation avant qu'elle n'impacte les utilisateurs.

**Contexte — pattern CloudWatch / Datadog :**
Amazon CloudWatch et Datadog affichent en temps réel : CPU, mémoire, latence DB, taux d'erreurs API, taille des tables. Pour Prioris / Supabase, l'équivalent est accessible via des requêtes SQL sur les vues système PostgreSQL et via l'API Supabase.

**Métriques à afficher (via vues SQL Supabase) :**

```sql
-- Taille base de données
SELECT pg_size_pretty(pg_database_size(current_database())) AS db_size;

-- Nombre total d'utilisateurs inscrits
SELECT COUNT(*) AS total_users FROM auth.users;

-- Utilisateurs actifs aujourd'hui
SELECT COUNT(DISTINCT user_id) AS dau
FROM auth.sessions
WHERE created_at > now() - interval '24 hours';

-- Utilisateurs actifs cette semaine
SELECT COUNT(DISTINCT user_id) AS wau
FROM auth.sessions
WHERE created_at > now() - interval '7 days';

-- Nouveaux inscrits aujourd'hui
SELECT COUNT(*) AS new_users_today
FROM auth.users
WHERE created_at > now() - interval '24 hours';

-- Taille des tables principales
SELECT
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
LIMIT 10;
```

**Section "Métriques infra" dans le dashboard admin :**
- Taille DB (avec historique 7j si possible)
- DAU / WAU / MAU
- Nouveaux inscrits aujourd'hui / cette semaine
- Top 5 tables par taille
- Bouton "Refresh" manuel + auto-refresh 5 minutes

**Acceptance Criteria :**
1. Section "Métriques Infrastructure" visible dans le dashboard admin (story 12.7)
2. Toutes les métriques listées ci-dessus sont affichées avec leurs valeurs réelles
3. Les données sont accessibles uniquement via une Supabase Edge Function ou RLS policy admin — jamais via requête client non-sécurisée
4. Auto-refresh toutes les 5 minutes avec indicateur "mis à jour il y a X secondes"
5. `puro flutter analyze --no-pub` → 0 nouvelle erreur
6. `puro flutter test --exclude-tags integration` → 0 régression

**Priorité :** 🟡 Moyenne
**Effort estimé :** 3-4h
**Dépendances :** Story 12.7 complétée (UI admin existante)

---

### Story 12.11 : Alertes sur anomalies — détection automatique des dégradations

**As a** Thibaut (propriétaire produit),
**I want** recevoir une alerte email quand des anomalies sont détectées (chute du DAU, 0 inscriptions plusieurs jours de suite, spike d'erreurs),
**so that** je détecte une régression produit ou infrastructure sans surveiller les dashboards manuellement.

**Contexte — pattern Datadog Anomaly Detection / Facebook Alertes ODS :**
Les big tech utilisent des alertes basées sur des seuils relatifs (% de variation par rapport à la baseline) plutôt que des seuils absolus. Une chute de 50% du DAU par rapport à la semaine précédente est plus significative que "DAU < 10".

**Alertes à configurer :**

**Alertes PostHog (natives) :**
- `activation_event` count hebdomadaire chute > 40% vs semaine précédente → email
- `user_signed_up` = 0 pendant 3 jours consécutifs → email
- `duel_choice_made` count journalier chute > 50% vs baseline (moyenne 7j) → email

**Alertes Sentry (déjà couvertes en 12.2) :**
- Crash rate > 0.5%
- Nouveau crash critique

**Alerte infrastructure (cron GitHub Actions ou Supabase pg_cron) :**
- DAU aujourd'hui < 50% de la moyenne DAU des 7 derniers jours → email via Supabase Edge Function + sendgrid/resend
- DB size > 80% de la limite du plan → email
- 0 nouvelles sessions depuis 12h (indicateur d'incident potentiel) → email

**Runbook :**
- `docs/runbooks/alert-playbook.md` : table de correspondance alerte → cause probable → action recommandée

**Acceptance Criteria :**
1. Les 3 alertes PostHog sont configurées et actives dans le dashboard PostHog
2. L'alerte DAU est implémentée (cron ou pg_cron) et testée manuellement (simuler une chute)
3. L'alerte DB size > 80% est configurée
4. Toutes les alertes envoient à `lambert.thibaut98@gmail.com`
5. `docs/runbooks/alert-playbook.md` existe avec ≥ 5 scénarios documentés (alerte → cause → action)
6. Un test de l'alerte DAU est documenté dans le runbook (comment simuler, comment vérifier)

**Priorité :** 🟢 Basse — utile post-launch quand il y a suffisamment de données pour définir une baseline
**Effort estimé :** 3-4h
**Dépendances :** Stories 12.3 (PostHog actif) et 12.10 (métriques infra actives)

---

## Critères de clôture de l'Épic 12

**Error Observability :**
- [ ] Sentry actif — crash-free users % visible et > 99,5%
- [ ] Alertes Sentry configurées — test de déclenchement réussi
- [ ] `docs/runbooks/error-response.md` existe

**Product Analytics :**
- [ ] PostHog actif — Live Events montrent les events en temps réel
- [ ] Funnel d'activation en 5 étapes sauvegardé dans PostHog
- [ ] Rapport de rétention D1/D7/D30 sauvegardé dans PostHog
- [ ] Dashboard Feature Adoption sauvegardé dans PostHog
- [ ] Aucun PII dans les events PostHog ou Sentry (audit vérifié)

**Admin Dashboard :**
- [ ] Page `/admin` accessible uniquement par le rôle admin
- [ ] Liste utilisateurs avec recherche et pagination fonctionnelle
- [ ] Export données RGPD testé sur un compte réel
- [ ] Suppression compte testée sur un compte de test
- [ ] `admin_audit_log` remplit correctement toutes les actions admin
- [ ] Présence temps réel : count actifs affiché correctement

**Infra & Alertes :**
- [ ] Métriques Supabase (DAU, WAU, DB size) affichées dans le dashboard
- [ ] ≥ 3 alertes PostHog configurées et testées
- [ ] Alerte DAU anormalement bas configurée et testée
- [ ] `docs/runbooks/alert-playbook.md` existe

**Sécurité transverse :**
- [ ] Aucune donnée sensible exposée via une requête client non-sécurisée
- [ ] Toutes les routes admin sont protégées côté Flutter ET côté Supabase (double vérification)
- [ ] Opt-out analytics si consent = false — vérifié sur un compte test sans consentement

---

## Stack technique

| Outil | Usage | Coût |
|-------|-------|------|
| **Sentry** (EU Cloud) | Error tracking, crash rates | Gratuit < 5K errors/mois |
| **PostHog** (EU Cloud) | Events, funnels, rétention, adoption | Gratuit < 1M events/mois |
| **Supabase Realtime** | Présence utilisateurs actifs | Inclus dans plan actuel |
| **Supabase Edge Functions** | Requêtes admin sécurisées | Inclus |
| **GitHub Actions cron** | Alertes DAU / anomalies | Gratuit |
| **`sentry_flutter`** | SDK Flutter Sentry | Open source |
| **`posthog_flutter`** | SDK Flutter PostHog | Open source |

**Coût additionnel mensuel : 0 € (dans les limites des plans gratuits)**
Si croissance > 1M events/mois PostHog : ~0 → 450 €/mois (selon usage). À réévaluer.

---

## Ordre de développement recommandé

```
Sprint 1 : 12.1 (Sentry) + 12.3 (PostHog SDK)  ← fondations, peuvent être parallèles
Sprint 2 : 12.2 (Sentry alertes) + 12.4 (Funnel) + 12.7 (Admin liste)
Sprint 3 : 12.8 (Fiche user) + 12.9 (Temps réel) + 12.5 (Rétention)
Sprint 4 : 12.6 (Adoption) + 12.10 (Métriques infra) + 12.11 (Alertes anomalies)
```

---

*Épic créé le 2026-05-13 — inspiré des pratiques Amazon CloudWatch, Google Firebase/Crashlytics, Facebook Scuba/ODS, Stripe Customer Dashboard.*
