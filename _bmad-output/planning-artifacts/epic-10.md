# Epic 10 : Consolidation Architecture Hexagonale & Correctifs RGPD

**Objectif :** Corriger les violations ADR-001 restantes après l'Épic 9, extraire les ports manquants (ConsentService, AuthService) vers `lib/domain/`, corriger les bugs RGPD confirmés en production, et progresser vers le domaine hermétique (0 import Supabase/Hive/Flutter dans `lib/domain/`).

**Source :** ADR-001 plan de migration Epic 10 (`docs/ADR/ADR-001-hexagonal.md`), rétro Épic 9 (2026-05-12), bugs confirmés par Thibaut en production.

**Pré-requis :** Epic 9 clôturé ✅ — ports HabitRepository, CustomListRepository, ListItemRepository dans `lib/domain/`.

---

## Epic 10 : Consolidation Architecture Hexagonale & Correctifs RGPD

### Story 10.1 : Corriger les bugs UX de revokeConsent (feedback visuel + redirection immédiate)

**As a** utilisateur,
**I want** que "Retirer mon consentement" me montre immédiatement un feedback visuel et me déconnecte sans avoir besoin de rafraîchir,
**so that** je sache que mon action a été prise en compte et que l'application reflète mon choix en temps réel.

**Contexte :** Deux bugs confirmés en production par Thibaut lors du test compte non-créateur (rétro Épic 9) :
- **Bug A** — Aucun feedback visuel après le tap "Retirer mon consentement" : l'utilisateur ne sait pas si l'action a réussi.
- **Bug B** — La redirection vers `ConsentGatePage` n'est pas immédiate : elle ne se déclenche qu'au refresh ou à la navigation suivante. `AuthWrapper` ne se re-évalue pas au changement d'état du consentement.

**Acceptance Criteria :**
1. Après tap "Retirer mon consentement" → snackbar ou dialog de confirmation affiché immédiatement ("Consentement retiré. Déconnexion en cours…")
2. `AuthWrapper` se re-évalue immédiatement après `revokeConsent()` — sans refresh, sans navigation
3. L'utilisateur est redirigé vers `ConsentGatePage` dans la même frame (ou au prochain frame) après confirmation
4. `puro flutter analyze --no-pub` → 0 nouvelle erreur
5. `puro flutter test --exclude-tags integration` → 0 régression

**Priorité :** 🔴 Haute — bug confirmé en production, impact confiance utilisateur et conformité RGPD

---

### Story 10.2 : Extraire IConsentRepository vers lib/domain/ports/ (ADR-001)

**As a** développeur,
**I want** que `ConsentService` ne dépende plus de `shared_preferences` directement dans `lib/domain/`,
**so that** le domaine reste hermétique (0 import infrastructure dans `lib/domain/`) conformément à ADR-001.

**Contexte :** `ConsentService` dans `lib/domain/` importe `shared_preferences` — violation directe de `lib/domain/CLAUDE.md`. Identifiée en review 8.2, non adressée en Épic 9 (absence de story). À traiter en priorité haute dans cet épic.

**Plan :**
- Créer `abstract class IConsentRepository` dans `lib/domain/ports/consent_repository.dart`
- Créer `class SharedPreferencesConsentRepository implements IConsentRepository` dans `lib/data/repositories/`
- `ConsentService` dépend uniquement de `IConsentRepository` (DIP)
- Provider Riverpod injecte `SharedPreferencesConsentRepository`

**Acceptance Criteria :**
1. `lib/domain/ports/consent_repository.dart` existe — interface sans import infrastructure
2. `ConsentService` n'importe plus `shared_preferences` ni aucun package infrastructure
3. `SharedPreferencesConsentRepository` dans `lib/data/repositories/` implémente `IConsentRepository`
4. `consentServiceProvider` injecte `SharedPreferencesConsentRepository` via DIP
5. `puro flutter analyze --no-pub` → 0 nouvelle erreur
6. `puro flutter test --exclude-tags integration` → 0 régression

**Priorité :** 🔴 Haute — violation ADR-001 active depuis story 7.7

---

### Story 10.3 : Extraire port IAuthService vers lib/domain/ports/

**As a** développeur,
**I want** que `AuthService` soit accessible via une interface `IAuthService` déclarée dans `lib/domain/ports/`,
**so that** le domaine et les services qui dépendent de l'authentification ne dépendent que de l'abstraction, pas de l'implémentation Supabase.

**Contexte :** ADR-001 plan Epic 10 — "Ports pour AuthService et ConsentService". Suite directe de 10.2.

**Acceptance Criteria :**
1. `abstract class IAuthService` dans `lib/domain/ports/auth_service.dart` — méthodes utilisées par le domaine uniquement
2. `AuthService` dans `lib/infrastructure/` implémente `IAuthService`
3. Les services domaine qui utilisent `AuthService` dépendent de `IAuthService`
4. `puro flutter analyze --no-pub` → 0 nouvelle erreur
5. `puro flutter test --exclude-tags integration` → 0 régression

**Priorité :** 🟡 Moyenne — suite de 10.2, plan ADR-001

---

### Story 10.4 : Corriger les violations imports lib/domain/services/ → lib/data/

**As a** développeur,
**I want** que les services dans `lib/domain/services/` n'importent plus depuis `lib/data/`,
**so that** la règle de dépendance hexagonale (`domain` ne dépend de rien) soit respectée dans tout `lib/domain/`.

**Contexte :** `lib/domain/services/core/custom_list_service.dart`, `lib/domain/services/persistence/adaptive_persistence_service.dart`, `lib/application/services/lists_persistence_service.dart` importent encore depuis `lib/data/`. Violations pré-existantes documentées en stories 9.3 et 9.4.

**Acceptance Criteria :**
1. Aucun fichier dans `lib/domain/` n'importe depuis `lib/data/` ou `lib/infrastructure/`
2. Les services domaine dépendent uniquement des ports (`IConsentRepository`, `IAuthService`, ports repository)
3. `grep -r "import.*data/" lib/domain/` → 0 résultat
4. `puro flutter analyze --no-pub` → 0 nouvelle erreur
5. `puro flutter test --exclude-tags integration` → 0 régression

**Priorité :** 🟡 Moyenne — pré-requis de l'Épic 11 (audit final)

---

### Story 10.5 : Tests domaine purs sans Supabase sur services migrés

**As a** développeur,
**I want** des tests unitaires pour les services domaine qui s'exécutent sans connexion Supabase ni Hive initialisé,
**so that** la suite de tests CI soit plus rapide et fiable, et que le domaine soit testable en isolation.

**Contexte :** ADR-001 plan Epic 10 — "Tests domaine purs sans Supabase sur services migrés". À réaliser après 10.2 et 10.3 (ports en place).

**Acceptance Criteria :**
1. Tests pour `ConsentService` utilisant un mock `IConsentRepository` — aucun appel SharedPreferences réel
2. Tests pour les services domaine clés (custom_list_service, etc.) avec mocks des ports
3. Ces tests s'exécutent sans tag `integration` et sans réseau
4. `puro flutter test --exclude-tags integration` → 0 régression, nouveaux tests verts

**Priorité :** 🟡 Moyenne — suite de 10.2/10.3

---

---

## Stories fonctionnelles — Bugs et UX (test utilisateur 2026-05-12)

> Source : retour d'utilisation Thibaut en conditions réelles — Paramètres, Listes, Prioriser, Habitudes, Insights.

---

### Story 10.7 : Corriger le chargement initial du duel (fail au premier chargement)

**As a** utilisateur,
**I want** que la page Prioriser charge le duel directement sans afficher "Impossible de charger le duel, réessayer",
**so that** je n'aie pas besoin de rafraîchir pour commencer à prioriser.

**Contexte :** En allant sur Prioriser, l'application affiche parfois "Impossible de charger le duel — Pas assez de tâches éligibles", alors que des tâches existent. Après actualisation, ça fonctionne. Le duel se charge donc bien — c'est un problème de timing ou d'état initial.

**Zones à investiguer :**
- Timing entre la récupération des listes et des tâches au chargement
- Conditions d'éligibilité évaluées avant que les données soient chargées
- État sélectionné des listes non encore disponible au premier build
- Race condition entre provider Riverpod et initialisation du duel
- Cache éventuel non encore peuplé au premier chargement

**Acceptance Criteria :**
1. Si des tâches éligibles existent, le duel se charge directement — sans rafraîchissement manuel
2. L'état de chargement (spinner/skeleton) est affiché pendant la récupération des données
3. Le message d'erreur "Pas assez de tâches éligibles" n'apparaît que si aucune tâche éligible n'existe réellement
4. `puro flutter test --exclude-tags integration` → 0 régression

**Priorité :** 🔴 Haute — bug confirmé, impact direct sur le flux principal

---

### Story 10.8 : Mise à jour immédiate des cards après sauvegarde des listes sélectionnées

**As a** utilisateur,
**I want** que les cards de duel se recalculent immédiatement après avoir sauvegardé mes listes sélectionnées,
**so that** je voie directement des duels cohérents avec ma sélection sans avoir à cliquer ailleurs.

**Contexte :** Après avoir sélectionné uniquement la liste "Voyages à faire dans ma vie" et cliqué "Sauvegarder", les cards de Prioriser continuent de proposer des tâches d'autres listes. Ce n'est qu'après une interaction ultérieure que les cards se mettent à jour.

**Acceptance Criteria :**
1. Après sauvegarde des listes sélectionnées → les tâches éligibles sont immédiatement recalculées
2. Le duel courant est regénéré avec les nouvelles listes
3. Les cards obsolètes (hors listes sélectionnées) disparaissent immédiatement
4. Aucune interaction supplémentaire (clic, navigation, refresh) n'est nécessaire
5. `puro flutter test --exclude-tags integration` → 0 régression

**Priorité :** 🔴 Haute — bug de cohérence UI confirmé

---

### Story 10.9 : Corriger la chaîne "Marquer comme fait" → statistiques habitudes

**As a** utilisateur,
**I want** que marquer une habitude comme faite mette à jour immédiatement le streak, le pourcentage et le nombre de jours réussis,
**so that** je sache que mon action a été prise en compte et que mes progrès soient visibles.

**Contexte :** Après avoir cliqué "Marquer comme fait" sur plusieurs habitudes (Boire de l'eau, Faire du sport, etc.) : le pourcentage ne change pas, le nombre de jours réussis ne change pas, les statistiques restent figées, aucun retour visuel ne confirme l'action. L'utilisateur ne sait pas si l'action a fonctionné.

**Chaîne à vérifier :**
- Appel "Marquer comme fait" → enregistrement en base
- Mise à jour de l'état local Riverpod
- Recalcul du streak
- Recalcul du pourcentage de succès
- Recalcul du nombre de jours réussis
- Rafraîchissement de l'interface

**Acceptance Criteria :**
1. Après "Marquer comme fait" → le streak est recalculé et affiché immédiatement
2. Le pourcentage de succès se met à jour immédiatement
3. Le nombre de jours réussis se met à jour immédiatement
4. Un retour visuel confirme l'action (snackbar, animation ou changement d'état de la carte)
5. `puro flutter test --exclude-tags integration` → 0 régression

**Priorité :** 🔴 Haute — bug critique, le cœur fonctionnel des habitudes est cassé

---

### Story 10.10 : Corriger la mise à jour de la page Insights

**As a** utilisateur,
**I want** que la page Insights reflète mes actions récentes (habitudes complétées, tâches terminées, duels effectués),
**so that** j'aie une vision réelle de mes progrès.

**Contexte :** Après avoir marqué des habitudes comme faites et réalisé des tâches, la page Insights ne bouge pas. Les données réalisées dans l'application ne semblent pas alimenter les statistiques.

**Zones à investiguer :**
- Absence de données en base (actions non persistées)
- Mauvais calcul des métriques
- Cache non invalidé
- Refresh manquant sur la page Insights
- Requête incorrecte ou état frontend non mis à jour

**Données attendues dans Insights :**
- Habitudes complétées (streak, pourcentage, jours réussis)
- Tâches complétées
- Duels effectués
- Session quotidienne / hebdomadaire
- Progression globale

**Acceptance Criteria :**
1. Après avoir marqué des habitudes comme faites → Insights reflète les nouvelles données
2. Après avoir complété des tâches → Insights est mis à jour
3. Les métriques (quotidien, hebdomadaire, global) sont calculées correctement
4. `puro flutter test --exclude-tags integration` → 0 régression

**Priorité :** 🔴 Haute — page centrale de l'app inutile si les données ne se mettent pas à jour

---

### Story 10.11 : Remplacer le recochage automatique des listes par une validation UX propre

**As a** utilisateur,
**I want** pouvoir décocher toutes les listes sans que l'application les recoche automatiquement,
**so that** je puisse choisir librement ma sélection sans frustration.

**Contexte :** Quand l'utilisateur décoche toutes les listes dans la sélection pour le duel, l'application recoche automatiquement toutes les listes. L'intention est d'éviter un état sans liste, mais l'UX est mauvaise — notamment quand on veut tout décocher pour sélectionner seulement 1 ou 2 listes spécifiques.

**Comportement attendu :**
- L'utilisateur peut décocher toutes les listes
- Le bouton "Sauvegarder" devient désactivé (grisé) si aucune liste n'est cochée
- Un message clair s'affiche : "Sélectionne au moins une liste pour pouvoir sauvegarder"
- Le recochage automatique est supprimé

**Acceptance Criteria :**
1. Décocher toutes les listes → aucun recochage automatique
2. Bouton "Sauvegarder" désactivé si 0 liste sélectionnée
3. Message d'aide affiché : minimum 1 liste requise
4. Sauvegarder avec ≥1 liste → comportement inchangé
5. `puro flutter test --exclude-tags integration` → 0 régression

**Priorité :** 🟡 Moyenne — UX gênante confirmée

---

### Story 10.12 : Rendre "Marquer comme fait" directement accessible sur la carte d'habitude

**As a** utilisateur,
**I want** pouvoir marquer une habitude comme faite directement depuis sa carte, sans passer par le menu 3 points,
**so that** l'action la plus fréquente soit la plus rapide d'accès et que "Supprimer" ne soit pas au même niveau.

**Contexte :** Actuellement "Marquer comme fait" est dans le menu 3 points avec "Modifier" et "Supprimer". Ce n'est pas pratique. Il y a aussi un risque de suppression accidentelle.

**Comportement attendu :**
- "Marquer comme fait" → bouton ou icône check visible directement sur la carte
- "Supprimer" → dans le menu 3 points, avec un dialog de confirmation obligatoire
- "Modifier" → dans le menu 3 points

**Acceptance Criteria :**
1. Bouton/icône "Marquer comme fait" visible directement sur la carte d'habitude
2. "Supprimer" requiert une confirmation explicite avant exécution
3. Actions fréquentes (marquer) séparées des actions dangereuses (supprimer)
4. Compatible mobile et desktop
5. `puro flutter test --exclude-tags integration` → 0 régression

**Priorité :** 🟡 Moyenne — UX importante, risque de suppression accidentelle

---

### Story 10.13 : Alternative desktop-friendly pour valider les tâches (swipe → bouton/checkbox)

**As a** utilisateur sur PC,
**I want** pouvoir valider une tâche via un bouton ou une checkbox, sans avoir à faire un geste de swipe,
**so that** l'application soit utilisable confortablement sur ordinateur.

**Contexte :** Sur mobile, le swipe pour valider une tâche est naturel. Sur PC, c'est peu pratique. Il manque une méthode alternative desktop-friendly.

**Comportement attendu :**
- Sur mobile : swipe reste disponible
- Sur desktop : bouton "Valider", checkbox ou icône check visible (au survol ou toujours visible)
- Les deux méthodes coexistent — le swipe n'est pas la seule option

**Acceptance Criteria :**
1. Une action de validation est accessible au clic/hover sur desktop (pas seulement au swipe)
2. Sur mobile, le swipe fonctionne toujours
3. Le comportement est cohérent avec le reste de l'interface
4. `puro flutter test --exclude-tags integration` → 0 régression

**Priorité :** 🟡 Moyenne — UX desktop à améliorer

---

### Story 10.14 : Compléter la couverture i18n — tous les textes fixes (EN/ES/DE)

**As a** utilisateur non francophone,
**I want** que tous les textes fixes de l'interface soient dans ma langue (EN, ES, DE),
**so that** l'application soit réellement utilisable dans toutes les langues supportées.

**Contexte :** Même quand l'application est en anglais, certains textes restent en français (ex: Privacy Policy). Les langues disponibles sont : français, anglais, espagnol, allemand. Les textes fixes d'interface doivent passer par le système i18n existant. Les contenus créés par l'utilisateur (noms de listes, etc.) ne doivent pas être touchés.

**Textes à vérifier dans toutes les langues :**
- Boutons et labels
- Messages d'erreur
- Textes d'aide
- Privacy Policy
- Textes des paramètres
- Toutes les pages (Habitudes, Prioriser, Listes, Insights, Settings)

**Acceptance Criteria :**
1. `grep -rn '"[A-Z]' lib/presentation/` → 0 chaîne hardcodée non localisée dans les fichiers modifiés
2. Privacy Policy disponible en EN, ES, DE
3. Tous les boutons, labels, messages d'erreur traduits dans les 4 langues
4. Les contenus utilisateur (noms de listes, titres de tâches) ne sont pas touchés
5. `puro flutter test --exclude-tags integration` → 0 régression

**Priorité :** 🟡 Moyenne — qualité produit pour utilisateurs non francophones

---

### Story 10.6 : Nettoyage dette technique — print(), InMemoryCustomListRepository, ISP

**As a** développeur,
**I want** supprimer les `print()` debug en production, aligner `InMemoryCustomListRepository` sur `extends` (comme les autres adapters), et nettoyer la surface doublée des sous-interfaces ISP,
**so that** le code soit cohérent et la dette documentée en Épic 9 soit soldée.

**Contexte :** Items deferred documentés en reviews 9.2, 9.3, 9.4 :
- `print()` debug dans `HabitsNotifier` (apparu dans 3 reviews)
- `InMemoryCustomListRepository` utilise `implements` au lieu de `extends` (incohérence avec Supabase/Hive)
- Sous-interfaces ISP de `CustomListRepository` ont 10 méthodes au lieu de 5 (doublons génériques + domaine)

**Acceptance Criteria :**
1. `grep -rn "print(" lib/data/providers/habits_state_provider.dart` → 0 résultat
2. `InMemoryCustomListRepository extends CustomListRepository` (pas `implements`)
3. Sous-interfaces ISP : méthodes génériques (`getAll`, `getById`, etc.) supprimées — seules les méthodes nommées domaine restent
4. `puro flutter analyze --no-pub` → 0 nouvelle erreur
5. `puro flutter test --exclude-tags integration` → 0 régression

**Priorité :** 🟢 Basse — dette documentée, non bloquante

---

## Critères de clôture de l'Epic 10

**Architecture hexagonale :**
- [ ] `ConsentService` n'importe plus `shared_preferences` dans `lib/domain/`
- [ ] `IConsentRepository` et `IAuthService` déclarés dans `lib/domain/ports/`
- [ ] `grep -r "import.*data/" lib/domain/` → 0 résultat
- [ ] Tests domaine purs exécutables sans réseau

**RGPD / revokeConsent :**
- [ ] Bugs revokeConsent (feedback visuel + redirection immédiate) corrigés et testés en production

**Bugs fonctionnels :**
- [ ] Chargement initial du duel fonctionne sans refresh
- [ ] Cards mises à jour immédiatement après sauvegarde des listes sélectionnées
- [ ] "Marquer comme fait" → statistiques habitudes (streak, %, jours) mises à jour immédiatement
- [ ] Page Insights reflète les actions réalisées

**UX :**
- [ ] Recochage automatique des listes supprimé — remplacé par validation propre
- [ ] "Marquer comme fait" directement accessible sur la carte d'habitude
- [ ] Confirmation obligatoire avant suppression d'habitude
- [ ] Alternative desktop pour valider les tâches

**i18n :**
- [ ] Tous les textes fixes traduits en EN, ES, DE (dont Privacy Policy)

**Qualité :**
- [ ] `puro flutter analyze --no-pub` propre
- [ ] `puro flutter test --exclude-tags integration` → 0 régression
- [ ] ADR-001 statut confirmé : "En cours (Epic 10 clôturé)"

---

## Note — UX/UI globale (hors scope Epic 10)

> Thibaut a noté que l'application n'est pas encore visuellement très soignée. Ce n'est **pas la priorité immédiate** — les bugs fonctionnels et les gros problèmes d'usage passent avant. Une refonte UX/UI complète est prévue dans un épic dédié ultérieur (Epic 11 ou 12) couvrant : apparence générale, cards, boutons, typographie, couleurs, animations, retours visuels, expérience desktop et mobile séparément.
