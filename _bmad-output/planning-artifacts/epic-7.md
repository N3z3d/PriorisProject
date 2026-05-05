# Epic 7 : Stabiliser le socle fonctionnel pour un pilote fiable

**Objectif :** Corriger les bugs critiques et lacunes UX découverts lors du test pilote post-Épic 6 (2026-04-22), résoudre la dette technique différée, et préparer Prioris pour un pilote externe crédible.

**Source :** Rétrospective Épic 6 (2026-04-22) + test utilisateur Thibaut post-clôture Épic 6.

---

## Epic 7 : Stabiliser le socle fonctionnel pour un pilote fiable

### Story 7.0 : Résoudre la dette technique différée (Épic 6)

**As a** développeur,
**I want** éliminer la duplication de logique et le couplage cross-layer hérités de l'Épic 6,
**so that** le code soit sain avant d'attaquer les bugs fonctionnels de l'Épic 7.

**Contexte :** Deux items différés lors de la code review de la story 6.4, documentés dans `deferred-work.md`. Doivent être résolus en premier dans l'Épic 7.

**Acceptance Criteria :**
1. La logique `_isSupabaseCallbackRoute` dans `app_routes.dart:81-87` est dédupliquée avec `_isSupabaseRouteLikeFragment` du stabilizer (extraction d'une constante ou helper partagé)
2. `WebAuthCallbackStabilizer._callbackWithoutSession` est exposé via un `StateProvider<bool>` Riverpod ; `LoginPage` ne lit plus directement un champ static infra
3. `flutter analyze` propre
4. Aucune régression sur les tests existants (20/20 verts)
5. `deferred-work.md` vidé ou archivé

**Priorité :** 🔵 Pré-requis (à faire en premier)

---

### Story 7.1 : Corriger le schema mismatch habits.category et sécuriser avec un test d'intégration Supabase

**As a** développeur,
**I want** corriger le schema mismatch entre le modèle Dart et le schéma Supabase réel sur la table `habits`,
**so that** la fonctionnalité habitudes soit opérationnelle en production et ne régresse plus.

**Contexte :** L'erreur `PostgrestException(message: Could not find the 'category' column of 'habits', code: PGRST204)` bloque complètement les habitudes en production. Découvert lors du test Thibaut post-clôture Épic 6.

**Acceptance Criteria :**
1. La colonne `category` est présente dans le schéma Supabase OU le modèle Dart est aligné sur le schéma réel sans la colonne
2. L'application habitudes fonctionne en production (création, lecture, mise à jour, suppression)
3. Un test d'intégration Supabase (base réelle) couvre le CRUD habitudes et valide la cohérence modèle/schéma
4. `flutter analyze` propre, `flutter build web` propre
5. Aucune régression sur les autres fonctionnalités

**Dette technique pré-story :** Résoudre les 2 items de `deferred-work.md` avant de toucher au code.

**Priorité :** 🔴 Bloquant

---

### Story 7.2 : Corriger l'Elo — calcul, persistance et rafraîchissement UI

**As a** utilisateur,
**I want** voir les scores Elo se mettre à jour correctement après chaque comparaison,
**so that** le classement des tâches reflète mes préférences réelles et que la fonctionnalité core du produit soit exploitable.

**Contexte :** Les scores Elo ne se mettent pas à jour après les comparaisons. Les lots ne changent pas. Fonctionnalité core non-fonctionnelle visuellement. Découvert lors du test Thibaut post-clôture Épic 6.

**Acceptance Criteria :**
1. Après une comparaison, le score Elo des deux tâches impliquées est recalculé et persisté en base
2. L'UI reflète le nouveau score immédiatement après comparaison (pas besoin de restart)
3. Le classement des tâches est trié par score Elo descendant
4. Les tests unitaires couvrent le calcul Elo (formule standard) et la persistance
5. Les tests d'intégration Supabase couvrent la mise à jour des scores

**Priorité :** 🔴 Bloquant

---

### Story 7.3 : Feedback visuel sur les opérations longues (progress, état, confirmation)

**As a** utilisateur,
**I want** voir un indicateur de progression clair lors des opérations longues (import massif, sync, etc.),
**so that** je sache que l'application travaille et comprenne l'état partiel si je quitte pendant l'opération.

**Contexte :** Un import de 300 éléments se fait sans aucun indicateur. Un refresh pendant l'import → 195/300 éléments importés sans notification de l'état partiel. Expérience utilisateur floue sur les opérations longues.

**Acceptance Criteria :**
1. Tout import ou opération > 1 seconde affiche un indicateur de progression (nombre/total ou spinner)
2. Si l'utilisateur quitte/rafraîchit pendant une opération, un message indique l'état partiel et le nombre d'éléments traités
3. Une confirmation explicite est affichée à la fin de l'opération (succès/échec + nombre traités)
4. L'indicateur respecte la charte UI existante (pas de nouveau composant custom si un existant convient)
5. Tests widget couvrant les états : démarrage, progression, complétion, interruption

**Priorité :** Haute

---

### Story 7.4 : Détection et gestion des doublons à l'ajout dans une liste

**As a** utilisateur,
**I want** être averti quand j'ajoute un élément déjà présent dans ma liste,
**so that** éviter les doublons accidentels et maintenir une liste propre.

**Contexte :** Aucune détection ni gestion des doublons à l'ajout. Gap fonctionnel découvert lors du test pilote.

**Acceptance Criteria :**
1. Lors de l'ajout d'un élément, si un doublon est détecté (même titre, case-insensitive), une alerte est affichée
2. L'utilisateur peut choisir d'ignorer l'alerte et ajouter quand même, ou annuler
3. La détection de doublon est rapide (client-side avant appel serveur si possible)
4. Le comportement est cohérent pour import massif (rapport de doublons détectés après import)
5. Tests unitaires sur la logique de détection, tests widget sur le flow UX

**Priorité :** Haute

---

### Story 7.5 : Améliorer les messages d'erreur et les états de chargement globaux

**As a** utilisateur,
**I want** voir des messages d'erreur clairs et des états de chargement cohérents dans toute l'application,
**so that** comprendre ce qui se passe quand quelque chose échoue ou charge.

**Contexte :** Identifié dans TODO_NEXT_DEVS.md (P0 tests fonctionnels liés aux états de chargement) et confirmé par le test pilote. Les erreurs Supabase s'affichent parfois en raw JSON.

**Acceptance Criteria :**
1. Toutes les erreurs API/Supabase sont interceptées et affichées avec un message utilisateur lisible (pas de raw JSON/stack trace)
2. Tous les états de chargement ont un indicateur visuel cohérent (spinner ou skeleton selon le composant)
3. Les erreurs de connectivité réseau ont un message dédié et une action de retry
4. Les messages d'erreur sont traduits en FR et EN (via i18n)
5. Tests widget couvrant les états d'erreur sur les composants principaux

**Priorité :** Moyenne

---

### Story 7.6 : Vérifier et compléter la couverture i18n FR/EN

**As a** utilisateur,
**I want** utiliser l'application entièrement en français ou en anglais sans textes hardcodés,
**so that** avoir une expérience localisée cohérente.

**Contexte :** L'infrastructure i18n existe (`app_fr.arb`, `app_en.arb`, `app_es.arb`, `app_de.arb`) et le sélecteur de langue est dans `SettingsPage`. Il ne faut pas créer from scratch — vérifier et compléter. TODO_NEXT_DEVS.md identifie des chaînes Habits hardcodées.

**Acceptance Criteria :**
1. Audit complet des chaînes hardcodées dans toute la codebase (grep systématique)
2. Toutes les chaînes UI visibles sont externalisées dans les fichiers `.arb`
3. FR et EN sont complets à 100% (ES et DE sont best-effort)
4. Le sélecteur de langue dans Settings fonctionne en runtime sans restart
5. Tests widget vérifiant que les clés i18n se résolvent dans les deux langues

**Priorité :** Moyenne

---

### Story 7.7 : Bases RGPD minimales

**As a** utilisateur,
**I want** pouvoir consentir à l'utilisation de mes données et demander leur suppression,
**so that** mes droits fondamentaux sur mes données personnelles soient respectés.

**Contexte :** Prioris collecte des données personnelles (tâches, habitudes) et s'ouvre à des utilisateurs externes. Une base RGPD minimale est requise avant tout élargissement du pilote.

**Acceptance Criteria :**
1. Une politique de confidentialité est accessible depuis l'application (lien ou page dédiée)
2. Un consentement explicite est demandé lors de la première utilisation (ou à la prochaine ouverture pour les utilisateurs existants)
3. Un utilisateur peut demander la suppression de son compte et de toutes ses données (email de contact ou formulaire)
4. Aucune donnée n'est partagée avec des tiers sans consentement explicite
5. La documentation légale est en FR (langue principale du pilote)

**Priorité :** Moyenne

---

### Story 7.8 : Insights — alimentation et exploitabilité

**As a** utilisateur,
**I want** consulter des insights pertinents sur mes habitudes et ma productivité,
**so that** comprendre mes patterns et m'améliorer.

**Contexte :** Le module Insights existe mais est en état vide, non alimenté. À traiter APRÈS que le socle 7.1-7.7 soit stabilisé.

**Acceptance Criteria :**
1. Le module Insights affiche au moins 3 métriques utiles basées sur les données réelles de l'utilisateur
2. Les métriques sont recalculées lors de chaque ouverture du module
3. L'absence de données affiche un état vide explicite avec un appel à l'action
4. Les insights respectent le design system existant
5. Tests unitaires sur le calcul des métriques

**Priorité :** Basse — après stabilisation du socle

---

## Critères de clôture de l'Epic 7

- [ ] Bugs critiques 7.1 et 7.2 résolus et validés en production
- [ ] Test utilisateur sur compte non-créateur réalisé avant clôture
- [ ] Test device mobile réel (pas seulement émulateur)
- [ ] `flutter analyze` propre
- [ ] `flutter build web` propre
- [ ] 0 régression sur les fonctionnalités Épic 1-6
- [ ] Dette technique deferred-work.md soldée
