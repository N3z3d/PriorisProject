# 📋 Scripts SQL Supabase - Prioris

## 📁 Fichiers SQL disponibles

### 🏗️ `supabase_schema.sql`
**Schéma complet de la base de données**
- Tables : profiles, custom_lists, list_items, habits, habit_completions
- Policies RLS (Row Level Security)
- Triggers et fonctions
- **Usage** : Pour créer une nouvelle base de données complète

### ✉️ `supabase_update_emails.sql`
**Script de mise à jour pour ajouter les emails**
- Ajoute les colonnes email manquantes
- Remplit automatiquement les emails existants
- Crée les triggers pour nouveaux utilisateurs
- **Usage** : Pour mettre à jour une base existante avec support email

### 🧹 `supabase_cleanup.sql`
**Script de nettoyage complet**
- Supprime TOUTES les données utilisateur
- Garde la structure de la base
- Affiche un résumé des suppressions
- **Usage** : Pour vider complètement la base de données

## 🚀 Comment utiliser

1. **Nouvelle installation** → Utiliser `supabase_schema.sql`
2. **Mise à jour existante** → Utiliser `supabase_update_emails.sql`
3. **Nettoyage complet** → Utiliser `supabase_cleanup.sql`

## 📝 Instructions

1. Aller sur [supabase.com](https://supabase.com)
2. Ouvrir votre projet Prioris
3. Aller dans **SQL Editor**
4. Copier-coller le script souhaité
5. Cliquer sur **RUN**

## ⚠️ Attention

- `supabase_cleanup.sql` supprime TOUTES les données !
- Faire une sauvegarde avant les opérations importantes
- Les scripts sont idempotents (peuvent être exécutés plusieurs fois)