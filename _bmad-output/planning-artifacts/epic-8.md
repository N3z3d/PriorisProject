# Epic 8 : Consolidation & Hardening

**Objectif :** Résoudre la dette qualité accumulée à l'issue de l'Épic 7 (67 tests en échec, RGPD incomplet, AC non implémenté, bugs connus) avant tout élargissement du pilote.

**Source :** Rétrospective Épic 7 (2026-04-28) — décision : épic de consolidation avant nouvelles features. Thibaut testera l'app après l'Épic 8 pour définir l'Épic 9.

---

## Epic 8 : Consolidation & Hardening

### Story 8.1 : Diagnostiquer et corriger les 67 tests en échec

**As a** développeur,
**I want** identifier et corriger les 67 tests en échec dans `DataMigrationService` et `ListsPersistenceService`,
**so that** la suite de tests soit saine et que les régressions futures soient détectables.

**Contexte :** Depuis l'Épic 7, 1843 tests passent mais 67 échouent sans jamais avoir été investigués. Chaque story Épic 7 notait "failures pré-existantes inchangées" sans diagnostic. `DataMigrationService` est un module sensible (données utilisateur). On ne sait pas si c'est du code cassé ou des tests invalides.

**Acceptance Criteria :**
1. Chaque échec est classifié : "code cassé" ou "test invalide / obsolète" avec justification
2. Les tests invalides/obsolètes sont supprimés ou corrigés pour refléter le comportement réel
3. Le code cassé identifié est corrigé
4. `flutter test --exclude-tags integration` → 0 échec
5. `flutter analyze --no-pub` propre
6. Aucune régression sur les 1843 tests précédemment verts

**Priorité :** 🔴 Haute — à traiter en premier

---

### Story 8.2 : Implémenter revokeConsent() — RGPD Art. 7.3

**As a** utilisateur,
**I want** pouvoir retirer mon consentement à tout moment aussi facilement que je l'ai donné,
**so that** mes droits RGPD sur le retrait du consentement soient respectés.

**Contexte :** Story 7.7 a implémenté les bases RGPD, mais `revokeConsent()` a été explicitement différé (`deferred-work.md` story 7.7). Le RGPD Art. 7.3 exige que le retrait soit aussi simple que l'octroi. Obligatoire avant toute ouverture publique large.

**Acceptance Criteria :**
1. `ConsentService` expose une méthode `revokeConsent()` qui efface les flags de consentement en local
2. Un bouton "Retirer mon consentement" est accessible depuis `SettingsPage`
3. Après retrait, l'utilisateur est redirigé vers `ConsentGatePage` à la prochaine ouverture
4. Le bouton est libellé et fonctionnel en FR et EN (i18n)
5. Tests unitaires `ConsentService.revokeConsent()` + tests widget `SettingsPage` (bouton visible et déclenche revoke)
6. `flutter analyze --no-pub` propre, aucune régression

**Priorité :** 🔴 Haute — obligatoire avant ouverture publique

---

### Story 8.3 : Détecter quit/refresh pendant import massif (AC2 story 7.3)

**As a** utilisateur,
**I want** être informé de l'état partiel de mon import si je quitte ou rafraîchis l'application en cours d'opération,
**so that** comprendre combien d'éléments ont été importés et ne pas perdre de données silencieusement.

**Contexte :** L'AC2 de la story 7.3 (feedback visuel) n'a pas été implémenté. Un refresh pendant un import de 300 éléments laissait 195/300 éléments importés sans notification. Le mécanisme de détection `AppLifecycleState` ou équivalent est requis.

**Acceptance Criteria :**
1. Si l'utilisateur quitte l'app (AppLifecycleState.paused/detached) pendant un import en cours, un message d'état est persisté (nombre d'éléments traités / total)
2. Au retour dans l'app, l'état partiel est affiché : "Import interrompu — X/Y éléments ajoutés"
3. Si l'utilisateur rafraîchit la page web pendant l'import, le message d'état partiel est affiché au rechargement (via localStorage ou équivalent)
4. Tests widget couvrant les scénarios : import complet, interruption mid-import, retour après interruption
5. `flutter analyze --no-pub` propre, aucune régression

**Priorité :** 🔴 Haute

---

### Story 8.4 : Corriger les bugs visuels connus (encodage, étoile, cartes)

**As a** utilisateur,
**I want** voir l'application afficher correctement le texte et les éléments visuels sans artefacts,
**so that** avoir une expérience utilisateur propre sur GitHub Pages et mobile.

**Contexte :** Trois bugs connus remontés lors des tests Épic 7, non résolus :
- **Encodage garble** : "0/7 jours réussis" s'affiche en caractères corrompus sur GitHub Pages — probablement un charset meta manquant dans `index.html`
- **Étoile inexpliquée** sur les cartes habitudes — origine inconnue, à investiguer
- **Cartes habitudes trop grandes** — panneau très volumineux, hors scope MVP Épic 6-7 mais bloque la lisibilité

**Acceptance Criteria :**
1. Les textes avec accents (FR) s'affichent correctement sur GitHub Pages (charset UTF-8 vérifié dans `web/index.html`)
2. L'étoile sur les cartes habitudes est expliquée (code source identifié) et supprimée si non intentionnelle
3. La hauteur des cartes habitudes est bornée (max-height + scroll interne ou layout compact) sans supprimer d'information
4. Tests visuels / widget sur les cartes habitudes pour détecter une régression de layout
5. `flutter build web` propre, `flutter analyze --no-pub` propre

**Priorité :** Moyenne

---

### Story 8.5 : Corriger formule calculateAveragePerDay et cast int→double Supabase

**As a** développeur,
**I want** corriger deux bugs de calcul dans `HabitCalculationService` et un `CastError` latent dans `Habit`,
**so that** les métriques d'habitudes soient correctes et l'app ne crashe pas sur des données Supabase légitimes.

**Contexte :**
- `calculateAveragePerDay` dans `HabitCalculationService` : la formule `(sum/n)*n == sum` est sémantiquement incorrecte (bug arithmétique identifié en review 7.8, non utilisé par InsightsPage mais potentiellement futur)
- `Habit.getSuccessRate()` et `getCurrentStreak()` : `(value as double)` lève `CastError` si Supabase retourne un `int` (JSON entier sans décimale)

**Acceptance Criteria :**
1. `calculateAveragePerDay` retourne la moyenne correcte (sum/n), couverte par tests unitaires incluant cas limites (n=0, valeurs négatives)
2. `Habit.getSuccessRate()` et `getCurrentStreak()` utilisent `(value as num).toDouble()` ou équivalent — aucun `CastError` sur des entiers Supabase
3. Tests unitaires ajoutés/mis à jour pour les deux corrections
4. Un test d'intégration vérifie que la lecture depuis Supabase d'une habitude avec `int` dans ces champs ne lève pas d'exception
5. `flutter analyze --no-pub` propre, aucune régression

**Priorité :** Moyenne

---

### Story 8.6 : Mettre à jour architecture.md et formaliser le template story

**As a** développeur,
**I want** que la documentation d'architecture reflète le code réel et que le template de story inclue la vérification compte non-créateur,
**so that** les futurs développeurs ne soient pas induits en erreur et que la procédure de clôture soit complète.

**Contexte :**
- `architecture.md` n'a pas été mis à jour depuis Épic 6, alors que la story 6.4 a introduit une déviation du router guard non documentée. Action item ouvert depuis deux rétrospectives consécutives.
- Le template Completion Notes ne contient pas de ligne "Test non-créateur" (Thibaut testera l'app avec un compte non-créateur à la clôture de chaque Epic).

**Acceptance Criteria :**
1. `architecture.md` documente la déviation router guard introduite en 6.4 (AuthWrapper vs route guard classique) et reflète l'état réel du code à l'issue de l'Épic 7
2. Le template de story (ou BMAD story template) contient une ligne dédiée "Test non-créateur" dans la section Completion Notes
3. La procédure de vérification mobile avec rate limit actif est documentée (dans `architecture.md` ou un fichier `docs/`)
4. Revue croisée : un autre développeur confirme que `architecture.md` est cohérent avec le code Épic 7

**Priorité :** Basse

---

## Critères de clôture de l'Epic 8

- [ ] `flutter test --exclude-tags integration` → 0 échec (story 8.1 résolue)
- [ ] `revokeConsent()` déployé et accessible depuis Settings (story 8.2)
- [ ] AC2 story 7.3 implémenté (story 8.3)
- [ ] Bugs visuels connus corrigés ou explicitement acceptés (story 8.4)
- [ ] Formule calculateAveragePerDay et cast int→double corrigés (story 8.5)
- [ ] architecture.md à jour, template story formalise test non-créateur (story 8.6)
- [ ] Test utilisateur Thibaut sur compte non-créateur réalisé avant clôture
- [ ] `flutter analyze --no-pub` propre
- [ ] `flutter build web` propre
- [ ] Déploiement GitHub Pages validé après clôture Epic 8
