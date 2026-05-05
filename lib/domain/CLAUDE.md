# Règles Hexagonal Architecture — lib/domain/

Ce dossier est le **cœur du domaine**. Il ne connaît pas le monde extérieur.

## Imports interdits

Aucun fichier dans `lib/domain/` ne peut importer :

- `package:supabase_flutter` — Supabase est un détail d'infrastructure
- `package:hive` / `package:hive_flutter` — Hive est un détail de persistance
- `package:flutter` — sauf `package:flutter/foundation.dart` si strictement nécessaire
- `package:prioris/data/` — la couche data dépend du domaine, jamais l'inverse
- `package:prioris/infrastructure/` — idem
- `package:prioris/presentation/` — idem

## Ce qui appartient ici

- **Entités** (`domain/models/`) : objets métier purs (Habit, CustomList, ListItem…)
- **Ports** (`domain/*/repositories/`) : interfaces repository — déclarées ici, implémentées dans `data/`
- **Services domaine** (`domain/services/`) : logique métier pure, sans IO
- **Value objects**, **enums**, **exceptions** métier

## Ce qui n'appartient pas ici

- Implémentations concrètes de repositories (→ `lib/data/repositories/`)
- Appels réseau, SQL, localStorage (→ `lib/infrastructure/` ou `lib/data/`)
- Widgets Flutter, providers Riverpod (→ `lib/presentation/` ou `lib/data/providers/`)

## Règle de vérification

Avant de valider une story qui touche `lib/domain/` :
```
puro flutter analyze --no-pub
```
Aucun import interdit ne doit apparaître dans les fichiers modifiés.

> Référence complète : `docs/ADR/ADR-001-hexagonal.md`
