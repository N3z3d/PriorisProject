# Epic 16 : RGPD Complet & Conformité

**Objectif :** Passer d'une conformité RGPD "minimale de pilote" à une conformité complète, condition non-négociable avant toute ouverture publique. Adresser les 4 axes restants identifiés en gap analysis : DPA Supabase non signé, pas de procédure de breach 72h, suppression de compte absente, bouton "Refuser" manquant au démarrage.

**Source :** Gap analysis 2026-05-13 + mémoire projet "Dette RGPD post story 7.7" — suppression auto compte + bouton Refuser obligatoires avant ouverture publique.

**Pré-requis :** Story 10.1 terminée (revokeConsent UX). Story 7.7 terminée (bases RGPD minimales).

**Budget estimé :** 0 € (Supabase inclut les outils de suppression, pas de service externe nécessaire)

**Responsable légal :** Thibaut Lambert — DPO auto-désigné (acceptable pour une startup en dessous de 250 salariés selon Art. 37 RGPD)

---

## Rappel — Périmètre couvert par story 7.7 (BASES RGPD)

Déjà implémenté :
- ✅ ConsentGatePage — consentement explicite au premier lancement
- ✅ revokeConsent — retrait du consentement depuis les Settings (bugs UX corrigés en 10.1)
- ✅ Politique de confidentialité accessible depuis l'app
- ✅ Durée de conservation des données documentée

**Ce qui reste (scope de cet epic) :**
- ❌ DPA Supabase non signé (Art. 28 — sous-traitant)
- ❌ Pas de procédure de breach notification 72h vers CNIL (Art. 33)
- ❌ Suppression de compte utilisateur — données irrécupérables (Art. 17)
- ❌ Bouton "Refuser le consentement" dès la ConsentGatePage (actuellement seulement "Accepter")
- ❌ Export des données utilisateur (Art. 20 — portabilité)

---

## Critères de sortie de l'Epic 16

- [ ] DPA Supabase signé et archivé (ou Supabase DPA accepté via Dashboard)
- [ ] Procédure de breach notification documentée dans `docs/runbooks/breach-notification.md`
- [ ] Suppression de compte : toutes les données utilisateur supprimées dans Supabase en < 30 jours
- [ ] ConsentGatePage propose clairement "Accepter" ET "Refuser"
- [ ] Export données disponible depuis les Settings (format JSON/CSV)

---

## Story 16.1 : DPA Supabase — Data Processing Agreement

**As a** Thibaut (responsable de traitement),
**I want** que le contrat de sous-traitance avec Supabase soit formalisé et archivé,
**so that** Prioris soit en conformité avec l'Art. 28 RGPD qui exige un DPA écrit avec tout sous-traitant traitant des données personnelles.

**Contexte :** Supabase propose un DPA standard téléchargeable depuis le Dashboard (Settings → Organization → Legal). Ce DPA couvre le traitement des données par Supabase en tant que sous-traitant. Il doit être signé (ou accepté électroniquement) et archivé par le responsable de traitement (Thibaut).

**Plan :**
1. Se connecter au Dashboard Supabase → Settings → Organization → Legal → télécharger/accepter le DPA
2. Archiver une copie signée dans `docs/legal/supabase-dpa-2026.pdf`
3. Vérifier que Supabase traite les données dans l'UE (région `eu-west-1` ou `eu-central-1`)
4. Si la région actuelle est hors UE → migrer vers une région EU ou ajouter des Clauses Contractuelles Types (SCCs)
5. Documenter dans `docs/legal/README.md` : liste des sous-traitants, pays, finalité

**Acceptance Criteria :**
1. DPA Supabase accepté électroniquement (preuve dans le Dashboard) OU signé et archivé en PDF
2. Région Supabase vérifiée — données hébergées dans l'UE ou SCCs documentées
3. `docs/legal/README.md` liste : Supabase (sous-traitant), région, finalité (stockage données app)
4. Aucun autre sous-traitant traitant des données personnelles non documenté

**Priorité :** 🔴 Haute — obligation légale Art. 28, risque CNIL en cas d'audit
**Effort estimé :** 1-2h (administratif, pas de code)

---

## Story 16.2 : Procédure de breach notification 72h CNIL

**As a** Thibaut (responsable de traitement),
**I want** une procédure documentée pour notifier la CNIL dans les 72h en cas de violation de données,
**so that** Prioris respecte l'Art. 33 RGPD et que je sache quoi faire en cas d'incident.

**Contexte :** L'Art. 33 RGPD impose de notifier la CNIL dans les 72h d'une violation de données susceptible d'engendrer un risque pour les droits et libertés des personnes. Sans procédure documentée, la réaction en cas d'incident sera chaotique et probablement trop lente.

**Plan :**
1. Créer `docs/runbooks/breach-notification.md` avec :
   - Définition d'une "violation de données" selon le RGPD (pas uniquement les hacks)
   - Arbre de décision : est-ce un incident à notifier ?
   - Procédure étape par étape : 0h → 24h → 72h
   - URL de notification CNIL : `https://notifications.cnil.fr/`
   - Template de message CNIL (nature de la violation, catégories de données, mesures prises)
   - Contacts internes (Thibaut) et contacts Supabase (support DPA)
2. Tester mentalement le scénario : "la DB Supabase est compromise, qu'est-ce qu'on fait ?"
3. Documenter les contacts d'urgence Supabase (support@supabase.io, status.supabase.com)

**Acceptance Criteria :**
1. `docs/runbooks/breach-notification.md` existe et couvre les 4 étapes : détection → qualification → notification CNIL → communication utilisateurs
2. URL CNIL de notification présente dans le runbook
3. Template de notification CNIL réutilisable (variables à remplir : [date], [nature], [données], [mesures])
4. Délai 72h mis en évidence — pas enfouie dans le document

**Priorité :** 🔴 Haute — obligation légale Art. 33, amende jusqu'à 10M€ ou 2% CA mondial
**Effort estimé :** 2-3h (documentation)

---

## Story 16.3 : Suppression automatique de compte utilisateur (Art. 17 — droit à l'oubli)

**As a** utilisateur,
**I want** pouvoir supprimer définitivement mon compte et toutes mes données depuis l'app,
**so that** mon droit à l'effacement (Art. 17 RGPD) soit respecté sans avoir à contacter le support.

**Contexte :** Actuellement, l'utilisateur peut retirer son consentement (revokeConsent), mais ses données restent dans Supabase indéfiniment. Art. 17 RGPD impose la suppression effective de toutes les données sur demande. La suppression doit être totale : compte Auth Supabase, toutes les tables (habits, lists, elo_scores, sessions, push_tokens…), et les données locales Hive.

**Plan :**
1. Créer une Edge Function Supabase `delete-user-account` (service_role key) qui :
   - Supprime toutes les lignes dans chaque table associée à `user_id`
   - Supprime le compte Auth Supabase (`supabase.auth.admin.deleteUser(userId)`)
   - Retourne un log de confirmation
2. Créer un port `IAccountDeletionService` dans `lib/domain/`
3. Implémenter l'appel côté Flutter dans les Settings → "Supprimer mon compte"
4. Ajouter une dialog de confirmation OBLIGATOIRE avec saisie de mot de passe ou email
5. Après suppression : effacer Hive local, déconnecter l'utilisateur, rediriger vers ConsentGatePage
6. Envoyer un email de confirmation de suppression via Supabase Auth email templates

**Acceptance Criteria :**
1. Settings → "Supprimer mon compte" → dialog de confirmation avec double-validation
2. Confirmation → toutes les données supprimées de Supabase en < 24h
3. Données Hive locales effacées immédiatement
4. Email de confirmation de suppression envoyé à l'adresse du compte
5. Tentative de login après suppression → erreur "compte inexistant"
6. `puro flutter analyze --no-pub` → 0 erreur
7. Architecture hexagonale : Edge Function appelée via port `IAccountDeletionService`

**Priorité :** 🔴 Haute — obligation légale, condition de la mémoire projet "avant ouverture publique"
**Effort estimé :** 5-7 jours

---

## Story 16.4 : Bouton "Refuser" sur ConsentGatePage (privacy by design)

**As a** utilisateur,
**I want** que la page de consentement initiale propose clairement "Accepter" ET "Refuser",
**so that** mon choix soit réel et non forcé, et que je puisse utiliser l'app en ayant refusé le traitement.

**Contexte :** Actuellement, `ConsentGatePage` affiche uniquement un bouton "Accepter" (ou équivalent). Le RGPD exige que le refus soit aussi facile que l'acceptation (Art. 7.3 + lignes directrices EDPB). Un bouton "Refuser" doit être présent dès le départ, avec les mêmes taille et prominence visuelle que "Accepter".

**Comportement attendu si refus :**
- L'utilisateur peut utiliser l'app en mode "données locales uniquement" (Hive) — pas de sync Supabase
- Pas d'inscription Supabase, pas de compte créé
- Les données locales restent sur l'appareil jusqu'à désinstallation ou effacement manuel
- L'utilisateur peut changer d'avis depuis les Settings

**Plan :**
1. Modifier `ConsentGatePage` : ajouter bouton "Refuser" avec même taille que "Accepter"
2. Texte "Refuser" → même taille/poids typographique qu'Accepter (pas de dark pattern)
3. En cas de refus : stocker `consent = false`, ne pas créer de session Supabase, afficher un mode "local only" minimal
4. Ajouter les clés i18n dans les 4 ARB
5. Mettre à jour les tests `consent_gate_page_test.dart`

**Acceptance Criteria :**
1. ConsentGatePage affiche "Accepter" ET "Refuser" avec même prominence visuelle
2. Tap "Refuser" → `consent = false` stocké → accès à un mode limité (ou logout propre)
3. Settings → possibilité de revenir accepter le consentement
4. Texte du bouton "Refuser" traduit dans les 4 langues
5. `puro flutter test --exclude-tags integration` → 0 régression

**Priorité :** 🔴 Haute — condition mémoire projet + EDPB Art. 7.3
**Effort estimé :** 3-4 jours

---

## Story 16.5 : Export des données utilisateur (Art. 20 — portabilité)

**As a** utilisateur,
**I want** télécharger l'ensemble de mes données personnelles dans un format lisible,
**so that** mon droit à la portabilité des données (Art. 20 RGPD) soit respecté.

**Contexte :** Art. 20 RGPD donne aux utilisateurs le droit de recevoir leurs données dans un format structuré, couramment utilisé, et lisible par machine (JSON ou CSV). La demande doit être traitée dans un délai d'un mois (Art. 12).

**Plan :**
1. Créer une Edge Function Supabase `export-user-data` :
   - Récupère toutes les données de l'utilisateur (habits, lists, elo_scores, sessions, consent_log)
   - Génère un fichier JSON structuré
   - Retourne le fichier en response ou l'envoie par email
2. Ajouter un bouton dans Settings → "Exporter mes données"
3. L'export déclenche l'Edge Function → téléchargement du JSON dans le navigateur
4. Format JSON documenté dans `docs/rgpd/data-export-schema.md`

**Acceptance Criteria :**
1. Settings → "Exporter mes données" → fichier JSON téléchargé dans le navigateur
2. Le JSON contient : profil, habitudes, listes, scores ELO, historique de sessions
3. Le JSON est valide (parseable) et documenté
4. `docs/rgpd/data-export-schema.md` décrit la structure du fichier
5. Délai d'export < 30 secondes pour un compte avec < 1000 habitudes

**Priorité :** 🟡 Moyenne — obligation légale mais délai d'un mois acceptable (pas urgent)
**Effort estimé :** 3-5 jours

---

## Critères de clôture de l'Épic 16

- [ ] DPA Supabase accepté et archivé dans `docs/legal/`
- [ ] `docs/runbooks/breach-notification.md` créé et complet
- [ ] Suppression de compte : données Supabase + Hive effacées sur demande
- [ ] ConsentGatePage : bouton "Refuser" aussi visible qu'"Accepter"
- [ ] Export JSON disponible depuis les Settings
- [ ] `docs/rgpd/` contient : DPA, breach runbook, data export schema, liste sous-traitants

---

*Épic créé le 2026-05-13 — gap analysis party mode. Mémoire projet : "suppression auto compte + bouton Refuser obligatoires avant ouverture publique."*
