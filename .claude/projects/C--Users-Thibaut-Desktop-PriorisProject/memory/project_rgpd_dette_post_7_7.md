---
name: Dette RGPD post story 7.7
description: Fonctionnalités RGPD intentionnellement exclues de 7.7, à implémenter avant ouverture publique
type: project
---

Story 7.7 est scope pilote minimal. Trois points de dette intentionnelle :

1. **Suppression automatique de compte** — obligatoire avant production publique. Solution : Supabase Edge Function appelant l'Admin API (`service_role` côté serveur uniquement). C'est une story à part entière (epic 8+).

2. **Bouton "Refuser" sur ConsentGatePage** — obligatoire pour app publique (RGPD : refus aussi simple qu'acceptation). Implique logique de déconnexion si l'utilisateur refuse. Actuellement absent car pilote fermé.

3. **Consentement au moment de l'inscription** — optionnel, UX uniquement. La gate post-connexion actuelle est valide légalement. Non prioritaire.

**Why:** RGPD impose suppression effective et parité accepter/refuser dès ouverture publique.
**How to apply:** Proposer des stories dédiées avant tout passage hors pilote fermé.
