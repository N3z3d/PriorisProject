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

- [ ] `ConsentService` n'importe plus `shared_preferences` dans `lib/domain/`
- [ ] `IConsentRepository` et `IAuthService` déclarés dans `lib/domain/ports/`
- [ ] `grep -r "import.*data/" lib/domain/` → 0 résultat
- [ ] Bugs `revokeConsent` corrigés et testés en production
- [ ] Tests domaine purs exécutables sans réseau
- [ ] `puro flutter analyze --no-pub` propre
- [ ] `puro flutter test --exclude-tags integration` → 0 régression
- [ ] ADR-001 statut confirmé : "En cours (Epic 10 clôturé)"

---

> **Note :** Cet épic est ouvert — d'autres stories peuvent être ajoutées avant le démarrage (cf. rétro Épic 9, Thibaut a confirmé des ajouts à venir).
