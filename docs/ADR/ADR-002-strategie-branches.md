# ADR-002 — Stratégie de branches et discipline de commit

**Date :** 2026-07-10
**Statut :** Accepté
**Décideurs :** Thibaut Lambert
**Référence :** story `10-21-nettoyer-working-tree-et-branches-fin-epic-10`, issue de la code review de la story 10.20

---

## Contexte

Jusqu'à l'Epic 10, tout le travail s'est fait directement sur `main`, en commitant par intermittence.
À la clôture de l'Epic 10, l'état constaté était le suivant :

- le working tree portait **41 fichiers non commités**, mélangeant trois chantiers (story 10.18, story 10.20, gardes `mounted` du `DuelController`) ;
- trois fichiers de test vivants n'étaient **pas suivis par git**, donc invisibles dans `git diff HEAD` ;
- les stories 10.18 et 10.19 étaient marquées `done` alors que le code de 10.18 n'avait jamais atteint un commit ;
- les quatre fichiers ARB portaient simultanément les clés i18n de deux stories distinctes.

Conséquence directe : la code review de la story 10.20 a dû **reconstruire son périmètre à la main**, fichier par fichier, au lieu de lire un diff. Un diff bruité rend la review moins fiable et l'historique inexploitable pour un `git bisect` ou un rollback.

Cela viole la règle « Changements chirurgicaux » de `CLAUDE.md`.

## Décision

**Un commit sur `main` = une story.** Après merge, chaque story se traduit par exactement un commit sur `main`, ni plus ni moins.

1. `main` est la branche de référence. Elle doit rester déployable à tout moment.
2. Le travail d'une story se fait sur une branche dédiée nommée `story/<numero>-<slug-court>` (ex. `story/10-20-habitudes-quantitatives`). Cette branche peut porter plusieurs commits de travail en cours de route.
3. La branche est **squash-mergée** dans `main` quand la story passe à `done`, c'est-à-dire **après** sa code review — l'ensemble de la story devient ainsi un unique commit sur `main`. Une story en `review` n'est pas mergée.
4. **Exception intendance.** Les commits qui ne relèvent d'aucune story — maintenance (`chore:`), documentation (`docs:`), release (`release:`) — sont autorisés directement sur `main`, sans branche ni squash. La règle « un commit = une story » ne concerne que le travail de story.
5. Critère de merge, non négociable :
   - `puro flutter analyze --no-pub` ne dépasse pas la baseline d'erreurs connue (au 2026-07 : 97 erreurs) ;
   - `puro flutter test --exclude-tags integration` ne présente aucune nouvelle régression (baseline connue au 2026-07 : `clean_code_constraints` sur `list_detail_page.dart` — 515 lignes —, et le test `filterByDate` flaky) ;
   - les findings de la code review de type `[Review][Patch]` (correctif non ambigu) et `[Review][Decision]` (choix nécessitant un arbitrage humain) sont résolus. Cette taxonomie est celle du workflow de code review du projet.
6. Aucun fichier de test vivant ne reste hors du suivi git. `git status --porcelain` doit être vide à la fin d'une story.
7. Les messages de commit ne contiennent **aucun trailer d'outil d'IA** (`Co-Authored-By` et assimilés sont proscrits).

**Date d'effet.** Cette convention s'applique au travail **à partir de l'Epic 11**. Les trois commits de clôture de l'Epic 10 (10.18, 10.20, ADR-002) sont allés directement sur `main` sans branche : recréer rétroactivement une branche par story sur du travail déjà mélangé n'aurait rien apporté.

## Conséquences

**Positives.** Le diff d'une story est lisible sans reconstruction manuelle, donc la code review porte sur le bon périmètre. `git bisect` redevient exploitable. Un rollback de story est une opération locale.

**Négatives.** Quand deux stories touchent le même fichier partagé — le cas typique étant les quatre ARB de `lib/l10n/` —, la séparation coûte cher : il faut découper au hunk (`git add -p`) et **régénérer `app_localizations*.dart` à chaque étape** pour que chaque commit compile isolément. Travailler sur des branches distinctes depuis le départ évite ce coût, puisque le conflit se résout au merge plutôt qu'au découpage a posteriori.

## Note opératoire

**Vérification d'un commit isolé.** Ne jamais utiliser `git stash` pour comparer à une baseline quand le working tree est chargé : `git worktree add --detach <sha>` est sûr et n'expose pas au risque de perdre du travail non commité.

## Portée

Cet ADR fixe la **convention**. Son application technique côté GitHub — protection de `main`, checks obligatoires, interdiction du push direct — relève de la story `11-5-strategie-branching-main-develop-protection-branches` et n'est pas traitée ici.

Une branche `develop` n'est **pas** retenue à ce stade : le projet a un seul contributeur et un seul environnement de déploiement, `main` + branches de story suffit. La question sera rouverte si un second contributeur rejoint le projet.
