# Story 10.18 : UX retrait consentement — proposer 3 choix au lieu de forcer la déconnexion

Status: backlog

## Story

En tant qu'utilisateur ayant tapé "Retirer mon consentement",
je veux voir un écran me proposant 3 options claires (Se déconnecter / Lire les conditions / Accepter les conditions),
afin de ne pas être forcé à me déconnecter et pouvoir choisir mon action librement.

## Acceptance Criteria

1. Après confirmation "Retirer" → un nouvel écran ou bottom sheet s'affiche avec 3 boutons :
   - **Se déconnecter** → logout complet → LoginPage
   - **Lire les conditions** → ouvre la PrivacyPolicyPage (ou modal)
   - **Accepter les conditions** → re-consent → retour à HomePage
2. Aucun snackbar de transition affiché (supprimé en story 10.1)
3. La navigation est cohérente (pas de stack pollué)
4. `puro flutter analyze --no-pub` → 0 nouvelle erreur
5. `puro flutter test --exclude-tags integration` → 0 régression

## Tasks / Subtasks

- [ ] **T1 — Décider de l'implémentation UI** (bottom sheet ou page dédiée ?)
  - [ ] T1.1 — Vérifier si ConsentGatePage peut être augmentée avec un bouton "Se déconnecter"
  - [ ] T1.2 — OU créer une page/modal `RevokeChoicePage` dédiée
  - [ ] T1.3 — Choisir l'approche selon la cohérence avec l'archi existante

- [ ] **T2 — Implémenter le flux 3 choix**
  - [ ] T2.1 — "Se déconnecter" → appel `authProvider.signOut()` → LoginPage
  - [ ] T2.2 — "Lire les conditions" → navigation vers PrivacyPolicyPage (ou webview CGU)
  - [ ] T2.3 — "Accepter les conditions" → appel `consentProvider.grant()` → HomePage

- [ ] **T3 — Supprimer/adapter le popUntil actuel**
  - [ ] T3.1 — Actuellement `revoke()` → `nav.popUntil(isFirst)` → ConsentGatePage
  - [ ] T3.2 — Remplacer par navigation vers le nouvel écran 3 choix

- [ ] **T4 — i18n** : ajouter les 3 clés dans les 4 ARB + gen-l10n

- [ ] **T5 — Tests et validation**
  - [ ] T5.1 — Tests unitaires des 3 actions
  - [ ] T5.2 — `puro flutter analyze --no-pub` → 0 erreur
  - [ ] T5.3 — `puro flutter test --exclude-tags integration` → 0 régression

## Dev Notes

### Question ouverte à trancher avant implémentation

**Que se passe-t-il si l'utilisateur ferme l'écran 3 choix sans choisir ?**
- Option A : reste sur l'écran 3 choix (bloquant — pas de back)
- Option B : retour à Settings (consentement retiré mais pas encore de choix)
- Option C : logout automatique après X secondes

À décider selon les contraintes RGPD (story 16-4 et 16-3 liées).

### Contexte story 10.1

Story 10.1 a implémenté :
- `revoke()` + `nav.popUntil(isFirst)` → ConsentGatePage (comportement temporaire acceptable)
- Snackbar supprimée (pas de message contradictoire)

Cette story remplace le `popUntil` par la navigation vers l'écran 3 choix.

### Lien avec RGPD

Les stories 16-3 (suppression compte Art.17) et 16-4 (bouton Refuser consent gate) traitent
le cas "utilisateur qui refuse définitivement". La story 10.18 traite le cas "utilisateur qui
a déjà consenti mais veut retirer son consentement depuis Settings".

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List

### Change Log
