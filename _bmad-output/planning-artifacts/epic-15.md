# Epic 15 : Notifications Push & Engagement

**Objectif :** Implémenter les rappels d'habitudes via push notifications — le levier de rétention le plus documenté sur les apps d'habitudes. John (PM) cite les données : les apps d'habitudes sans rappels perdent 60-70% de leurs utilisateurs actifs dans les 7 premiers jours. Condition préalable posée par Sally : le mode offline basique (Epic 14) doit être en place avant le premier déploiement de notifications en production.

**Source :** Party mode 2026-05-13 — John PM : "push notifications = priorité absolue après offline basique". Sally UX condition : "pas de notif en prod sans cache local fonctionnel."

**Pré-requis :** Epic 14 terminé (offline basique + cache local). RGPD opt-in story 16.4 terminée (consentement push).

**Budget estimé :** Firebase gratuit jusqu'à 10K notifications/jour (puis tarification FCM). Apple Push Notification Service (APNs) : inclus dans le compte développeur Apple (~99$/an si app native).

**Note plateforme :** Push notifications Flutter Web sur **iOS Safari < 16.4** ne sont **pas supportées**. Sur les navigateurs modernes (Chrome, Firefox, Edge, Safari 16.4+) le support est complet via Web Push API. Ce point a été soulevé par Mary (Risk Analyst) : valider la cible plateforme avant d'architechter le module.

---

## Décision plateforme à prendre AVANT de commencer cet epic

| Plateforme | Support Push | Contraintes |
|-----------|-------------|-------------|
| Flutter Web (Chrome/Firefox) | ✅ Web Push API | Nécessite HTTPS + permission |
| Flutter Web (Safari 16.4+) | ✅ Web Push | Nécessite iOS 16.4+ |
| Flutter Web (Safari < 16.4) | ❌ Non supporté | ~30% des utilisateurs iOS |
| Flutter Android (natif) | ✅ FCM | Nécessite app Google Play |
| Flutter iOS (natif) | ✅ APNs | Nécessite Apple Developer ($99/an) |

**Recommandation pour V1 pilote :** Cibler Flutter Web uniquement (Chrome/Firefox/Safari 16.4+) via Firebase Cloud Messaging Web SDK. Documenter la limitation Safari < 16.4 dans l'UI (message informatif).

---

## Critères de sortie de l'Epic 15

- [ ] Firebase Cloud Messaging intégré — push notifications reçues sur les navigateurs supportés
- [ ] Utilisateur peut activer/désactiver les rappels par habitude depuis les settings
- [ ] Rappel quotidien configurable — heure par défaut configurable par l'utilisateur
- [ ] Deep link notification → page de l'habitude concernée
- [ ] Opt-in explicite RGPD-compliant — pas de notification sans consentement
- [ ] Support plateforme documenté — message informatif sur Safari < 16.4

---

## Story 15.1 : Intégration Firebase Cloud Messaging (FCM) — infrastructure Web Push

**As a** développeur,
**I want** que l'infrastructure Firebase Cloud Messaging soit configurée pour Flutter Web,
**so that** les notifications push puissent être envoyées aux utilisateurs consentants.

**Contexte :** FCM Web SDK (firebase_messaging Flutter package) gère l'enregistrement du device token, la réception des messages en foreground/background, et la persistence des tokens dans Supabase pour l'envoi côté serveur.

**Plan :**
1. Créer un projet Firebase et activer Cloud Messaging
2. Ajouter `firebase_core` + `firebase_messaging` au `pubspec.yaml`
3. Configurer `firebase_options.dart` (FlutterFire CLI)
4. Implémenter le Service Worker `firebase-messaging-sw.js` pour les notifications background
5. Créer `PushNotificationRepository` dans `lib/data/repositories/` :
   - `getToken()` → FCM token
   - `saveTokenToSupabase(userId, token)` → table `push_tokens`
   - `deleteToken(userId)` → suppression au logout
6. Créer la table Supabase `push_tokens(user_id, token, platform, created_at)`
7. Tester en local : envoi manuel depuis Firebase Console → notification reçue

**Acceptance Criteria :**
1. Token FCM obtenu et sauvegardé dans Supabase à la première connexion avec consentement
2. Notification envoyée depuis Firebase Console → reçue dans le navigateur (Chrome)
3. Token supprimé de Supabase au logout
4. `puro flutter analyze --no-pub` → 0 erreur
5. Architecture hexagonale respectée : `PushNotificationRepository` derrière un port `IPushNotificationRepository` dans `lib/domain/`

**Priorité :** 🔴 Haute — fondation de toutes les autres stories de l'epic
**Effort estimé :** 3-4 jours

---

## Story 15.2 : Background isolate et réception des notifications hors app active

**As a** utilisateur,
**I want** recevoir les rappels d'habitudes même quand l'app n'est pas ouverte,
**so that** les notifications me parviennent à l'heure configurée sans avoir à garder l'app en premier plan.

**Contexte :** Flutter Web utilise un Service Worker pour les notifications background. Le handler `onBackgroundMessage` de `firebase_messaging` s'exécute dans un isolate séparé — sans accès au contexte Flutter habituel (pas de Riverpod, pas de BuildContext). C'est un cas particulier documenté dans la lib firebase_messaging.

**Plan :**
1. Implémenter `@pragma('vm:entry-point') Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message)` au top-level
2. Appeler `FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler)` dans `main()`
3. Dans le handler background : uniquement des opérations legères (log, update badge) — pas de Hive, pas de providers
4. Tester le background handler : app fermée → notification envoyée → reçue + affichée
5. Vérifier que le Service Worker est correctement enregistré dans `web/index.html`

**Acceptance Criteria :**
1. App fermée (onglet fermé) → notification FCM envoyée → notification apparaît dans le OS notification center
2. Clic sur la notification → l'app s'ouvre (ou se focus si déjà ouverte)
3. Background handler ne crash pas — 0 exception dans les logs Firebase
4. `puro flutter analyze --no-pub` → 0 erreur

**Priorité :** 🔴 Haute — sans background, les rappels ne fonctionnent qu'en foreground
**Effort estimé :** 2-3 jours

---

## Story 15.3 : Rappel quotidien configurable par habitude

**As a** utilisateur,
**I want** configurer un rappel quotidien pour chaque habitude à l'heure que je choisis,
**so that** je reçoive une notification à mon heure préférée me rappelant de compléter mon habitude.

**Contexte :** L'envoi des notifications est côté serveur — une Cloud Function Firebase (ou un cron Supabase Edge Function) qui interroge la table `push_tokens` et `habit_reminders`, et envoie les notifications FCM aux utilisateurs concernés à l'heure configurée.

**Plan :**
1. Créer table Supabase `habit_reminders(user_id, habit_id, reminder_time, enabled)`
2. Créer la page de configuration de rappel dans les Settings de chaque habitude
3. Créer une Supabase Edge Function `send-habit-reminders` déclenchée en cron toutes les heures :
   - Requête : `SELECT users WHERE reminder_time = current_hour AND enabled = true`
   - Envoi FCM via Admin SDK pour chaque token trouvé
4. Ajouter les clés i18n dans les 4 ARB
5. Tester le cycle complet : configuration → cron → notification reçue

**Acceptance Criteria :**
1. Depuis la page d'une habitude → option "Rappel quotidien" avec time picker
2. Enregistrement de l'heure → sauvegardée dans `habit_reminders`
3. À l'heure configurée → notification "N'oubliez pas : [nom de l'habitude] !" reçue
4. Toggle "Désactiver le rappel" → plus de notification
5. UI traduite dans les 4 langues (fr/en/de/es)

**Priorité :** 🔴 Haute — feature cœur de la rétention
**Effort estimé :** 5-7 jours

---

## Story 15.4 : Deep links — notification → page contextuelle de l'habitude

**As a** utilisateur,
**I want** qu'un tap sur la notification m'amène directement à la page de l'habitude concernée,
**so that** l'action soit immédiate — pas de navigation manuelle pour trouver l'habitude.

**Contexte :** FCM permet d'envoyer des données dans le payload de notification (`data.habitId`, `data.route`). Au tap sur la notification, `firebase_messaging` expose le message dans `getInitialMessage()` (app fermée) et `onMessageOpenedApp` (app en background). Ces données doivent être routées vers le bon écran.

**Plan :**
1. Ajouter `habitId` dans le payload FCM envoyé par la Edge Function
2. Implémenter le handler `onMessageOpenedApp` dans `main()` → router vers `HabitDetailPage(habitId)`
3. Implémenter `getInitialMessage()` au démarrage → même routing si app lancée depuis notif
4. Tester les 3 scénarios : foreground tap, background tap, cold start tap

**Acceptance Criteria :**
1. App en foreground → tap notification → navigation vers la bonne habitude
2. App en background → tap notification → app focus + navigation vers la bonne habitude
3. App fermée → tap notification → app démarre sur la bonne habitude directement
4. Si l'habitId n'existe plus (habitude supprimée) → fall back vers HomePage

**Priorité :** 🟡 Moyenne — améliore significativement la conversion notif → action
**Effort estimé :** 2-3 jours

---

## Story 15.5 : Opt-in push notifications RGPD-compliant

**As a** utilisateur,
**I want** choisir explicitement si je veux recevoir des notifications push,
**so that** mon consentement soit respecté et que je puisse le retirer à tout moment.

**Contexte :** Le RGPD (et l'ePrivacy Directive) requiert un consentement explicite et granulaire pour les notifications push. Ce consentement est distinct du consentement de traitement des données (déjà géré par `ConsentGatePage`). Sur navigateur Web, la permission system push du navigateur est une double gate : l'app demande la permission, puis le navigateur affiche sa propre dialog.

**Plan :**
1. Créer un `PushConsentPage` ou une section dans Settings : "Notifications — Activer les rappels d'habitudes"
2. Expliquer clairement à quoi servent les notifications AVANT de demander la permission navigateur
3. Appeler `FirebaseMessaging.instance.requestPermission()` uniquement après consentement explicite dans l'UI
4. Stocker `push_consent: true/false` dans les préférences utilisateur (Hive + Supabase)
5. Permettre la révocation : Settings → Notifications → "Désactiver toutes les notifications"
6. Supprimer le token FCM de Supabase lors de la révocation

**Acceptance Criteria :**
1. La permission push navigateur n'est jamais demandée sans interaction explicite de l'utilisateur
2. Refus → aucune notification envoyée, aucun token sauvegardé dans Supabase
3. Révocation → token supprimé de Supabase dans les 24h
4. UI traduite dans les 4 langues
5. Comportement conforme Art. 6.1.a RGPD (consentement libre, spécifique, éclairé)

**Priorité :** 🔴 Haute — prérequis légal avant tout envoi de notification
**Effort estimé :** 2-3 jours

---

## Note — Push notifications sur Flutter Web vs iOS Safari

Si la base utilisateur migre vers l'app mobile (iOS/Android natif), une Epic 18 devra adresser :
- APNs (Apple Push Notification Service) — certificats Developer Account
- FCM Android — mise à jour du `AndroidManifest.xml`
- Background isolates natifs (différents du Web)

Cet epic couvre uniquement Flutter Web.

---

## Critères de clôture de l'Épic 15

- [ ] FCM intégré — token obtenu, sauvegardé, supprimé au logout
- [ ] Background notifications reçues avec app fermée
- [ ] Rappel quotidien configurable par habitude
- [ ] Tap notification → page de l'habitude directement
- [ ] Opt-in RGPD — permission jamais demandée sans consentement UI préalable
- [ ] Safari < 16.4 : message informatif dans les Settings ("Votre navigateur ne supporte pas les notifications")

---

*Épic créé le 2026-05-13 — John PM : "60-70% d'attrition sans rappels sur les apps d'habitudes." Sally condition : offline avant push.*
