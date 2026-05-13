# Epic 14 : Mode Hors Ligne

**Objectif :** Permettre à Prioris de fonctionner sans connexion réseau — afficher les données depuis le cache local, mettre les actions en file d'attente, et synchroniser proprement au retour du réseau. Condition non-négociable posée par Sally (UX) avant tout déploiement des push notifications : "une notification qui ouvre un spinner blanc est pire que pas de notification du tout."

**Source :** Party mode 2026-05-13 — Sally UX + John PM convergence : offline basique précède push notifications. Séquence validée : CI/CD → migrations → offline basique → push notifications.

**Pré-requis :** Epic 13 story 13.1 clôturée (migrations Hive stables).

**Budget estimé :** 0 € (Hive inclus, `connectivity_plus` package Flutter gratuit)

---

## Philosophie — Offline "basique" vs "complet"

Le scope de cet epic est **offline basique** — pas un sync bidirectionnel complet avec résolution de conflits sophistiquée. L'objectif est :

1. **L'app s'ouvre sans réseau** — les données du dernier sync sont affichées
2. **Les actions ne disparaissent pas** — elles sont mises en queue et exécutées au retour du réseau
3. **L'utilisateur sait qu'il est hors ligne** — indicateur visuel clair

La résolution de conflits complexes (deux appareils modifient la même habitude hors ligne) est **hors scope** pour cet epic — elle relève d'une future Epic 18 si le besoin émerge.

---

## Critères de sortie de l'Epic 14

- [ ] L'app démarre sans réseau et affiche les données Hive — 0 spinner blanc, 0 écran vide
- [ ] Un indicateur visuel signale le mode hors ligne
- [ ] Les créations/modifications hors ligne sont sauvegardées localement et synchronisées au retour
- [ ] Les push notifications ouvrent une app fonctionnelle, même hors ligne
- [ ] `puro flutter test --exclude-tags integration` → 0 régression

---

## Story 14.1 : Cache lecture-seule des habitudes, listes et résultats de prioritisation

**As a** utilisateur,
**I want** voir mes habitudes et listes même sans connexion internet,
**so that** l'app soit utile dans le métro, l'avion, ou en zone blanche.

**Contexte :** Actuellement, `HabitRepository` et `CustomListRepository` font des appels Supabase à chaque chargement. Si le réseau est absent, les providers retournent un état d'erreur ou un état de chargement infini. La solution est d'utiliser Hive comme cache prioritaire en lecture : charger d'abord le cache local, puis rafraîchir depuis Supabase en arrière-plan si le réseau est disponible (pattern "cache-first, network-refresh").

**Plan :**
1. Modifier `HabitRepository` et `CustomListRepository` pour implémenter le pattern cache-first :
   - Lire depuis Hive → émettre immédiatement les données locales
   - Lancer la requête Supabase en parallèle → mettre à jour Hive + réémettre si différent
2. En cas d'erreur réseau → logguer silencieusement, garder les données Hive
3. Vérifier que `EloRepository` et `ListItemRepository` suivent le même pattern
4. Ajouter tests unitaires : `givenNoNetwork_whenLoadHabits_thenReturnsCachedData`

**Acceptance Criteria :**
1. Mode avion activé → l'app démarre et affiche les données de la dernière session
2. Mode avion activé → HomePage visible, listes visibles, résultats ELO visibles
3. 0 spinner blanc indéfini — au pire un indicateur "données locales"
4. Retour réseau → les données se rafraîchissent automatiquement en arrière-plan
5. `puro flutter analyze --no-pub` → 0 nouvelle erreur
6. `puro flutter test --exclude-tags integration` → 0 régression

**Priorité :** 🔴 Haute — cœur du mode offline
**Effort estimé :** 5-7 jours

---

## Story 14.2 : Indicateur visuel de connectivité dans l'UI

**As a** utilisateur,
**I want** un indicateur discret mais clair quand je suis hors ligne,
**so that** je comprenne pourquoi les données ne se rafraîchissent pas et que je sache que l'app fonctionne quand même.

**Contexte :** Sans indicateur, l'utilisateur ne sait pas si l'app est "lente" ou "hors ligne". L'UX cible : une bannière fine en haut de l'app (pattern iOS "No Internet Connection") qui apparaît quand la connectivité est perdue et disparaît au retour du réseau.

**Package recommandé :** `connectivity_plus` (pub.dev, 950+ pub points, maintenu par Flutter Community)

**Plan :**
1. Ajouter `connectivity_plus` aux dépendances
2. Créer un `ConnectivityProvider` (Riverpod) qui expose le statut de connexion
3. Créer un widget `OfflineBanner` (bannière fine, couleur warning, texte i18n "Mode hors ligne — données locales")
4. Intégrer `OfflineBanner` dans le scaffold racine de l'app (au-dessus de `HomePage` et des autres pages)
5. Animation : slide-down à l'apparition, slide-up à la disparition
6. Ajouter les clés i18n dans les 4 ARB (fr/en/de/es)

**Acceptance Criteria :**
1. Activation mode avion → bannière orange/jaune apparaît dans les 2 secondes
2. Désactivation mode avion → bannière disparaît dans les 2 secondes
3. Bannière traduite dans les 4 langues
4. La bannière ne masque pas le contenu principal (hauteur ≤ 28dp)
5. `puro flutter test` → 0 régression

**Priorité :** 🟡 Moyenne — UX essentielle pour accompagner le mode offline
**Effort estimé :** 2-3 jours

---

## Story 14.3 : File d'attente des actions hors ligne et synchronisation différée

**As a** utilisateur,
**I want** que mes actions (créer une habitude, marquer comme fait, modifier une liste) soient sauvegardées hors ligne et synchronisées automatiquement au retour du réseau,
**so that** je ne perde aucune donnée même si l'app est utilisée sans connexion.

**Contexte :** Les actions d'écriture (mutations Supabase) échouent silencieusement en mode offline actuellement. La solution est une `OutboxQueue` persistée dans Hive : chaque mutation échouée est ajoutée à la queue, qui est drainée dès le retour du réseau.

**Scope (actions concernées) :**
- Marquer une habitude comme faite
- Créer/modifier/supprimer une habitude
- Modifier l'ordre d'une liste
- Mettre à jour un score ELO après une session de prioritisation

**Plan :**
1. Créer `OutboxQueue` dans `lib/data/offline/` : Hive box avec les mutations pendantes
2. Modifier chaque repository pour écrire dans Hive immédiatement + ajouter à l'Outbox si hors ligne
3. Créer un `SyncService` qui drainne l'Outbox quand la connectivité est restaurée
4. Gérer les conflits basiques : la version Supabase est "truth of record" — l'outbox apporte les dernières modifications locales
5. Notification utilisateur si une action outbox échoue à la sync (ex: conflit ou erreur serveur)

**Acceptance Criteria :**
1. Mode avion → créer une habitude → retour réseau → habitude visible dans Supabase
2. Mode avion → marquer une habitude faite → retour réseau → statistique mise à jour
3. L'Outbox est persistée entre les redémarrages de l'app — les mutations survivent à un kill de l'app
4. En cas d'échec de sync → snackbar informatif (pas de perte silencieuse)
5. `puro flutter test --exclude-tags integration` → 0 régression

**Priorité :** 🟡 Moyenne — amélioration significative UX offline
**Effort estimé :** 7-10 jours

---

## Story 14.4 : Gestion des conflits de synchronisation (basique)

**As a** utilisateur,
**I want** que les conflits entre modifications locales et serveur soient résolus de façon prévisible,
**so that** je ne perde jamais de données silencieusement et que l'état affiché soit cohérent.

**Contexte :** Cas de conflit basique : l'utilisateur modifie une habitude hors ligne, mais pendant ce temps un autre appareil (ou Supabase elle-même) a modifié la même entrée. La stratégie "last-write-wins" avec timestamp est la plus simple et suffisante pour la V1.

**Stratégie retenue :** Last-write-wins par timestamp — la modification la plus récente gagne. En cas d'égalité : la version serveur prime.

**Plan :**
1. Ajouter un champ `updatedAt` sur toutes les entités locales Hive (si absent)
2. Lors de la sync Outbox : comparer `updatedAt` local vs `updated_at` Supabase
3. Si conflit détecté → appliquer la version la plus récente
4. Logger les conflits résolus dans un `ConflictLog` (Hive) pour debug
5. Documenter la stratégie dans `docs/adr/ADR-004-offline-conflict-strategy.md`

**Acceptance Criteria :**
1. Conflit créé manuellement → résolu automatiquement selon last-write-wins
2. Aucune perte de donnée silencieuse — toute résolution de conflit est loggée
3. `ADR-004-offline-conflict-strategy.md` documenté
4. `puro flutter test --exclude-tags integration` → 0 régression

**Priorité :** 🟢 Basse pour le pilote, mais nécessaire avant ouverture multi-appareils
**Effort estimé :** 3-5 jours

---

## Critères de clôture de l'Épic 14

- [ ] Mode avion → app fonctionnelle avec données en cache
- [ ] Indicateur offline visible et traduit dans les 4 langues
- [ ] Outbox persistée et drainée au retour du réseau
- [ ] ADR-004 (conflict strategy) documenté
- [ ] Les push notifications (Epic 15) peuvent être développées sans risque d'ouvrir un spinner blanc

---

*Épic créé le 2026-05-13 — suite party mode : Sally condition non-négociable "offline avant push notifications"*
