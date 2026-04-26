-- Migration 003: Aligner le schema Supabase habits avec le modele Dart
-- Contexte: Story 7.1 — correction des mismatches schema/modele
--
-- Analyse complete (2026-04-23) :
--   Schema interroge via information_schema.columns
--   Compare avec Habit.toJson() (lib/domain/models/core/entities/habit.dart)
--
-- Instructions:
--   1. Supabase Dashboard → SQL Editor
--   2. Copier-coller ce fichier entier
--   3. Cliquer sur "Run"
--   4. Verifier avec : SELECT column_name, data_type, is_nullable FROM information_schema.columns WHERE table_name = 'habits' ORDER BY ordinal_position;
--
-- Rollback:
--   ALTER TABLE habits ALTER COLUMN color TYPE INTEGER;
--   ALTER TABLE habits ALTER COLUMN icon TYPE INTEGER;
--   ALTER TABLE habits ALTER COLUMN recurrence_type SET NOT NULL;


-- ============================================================
-- PHASE 1 : Colonnes manquantes (toutes idempotentes via IF NOT EXISTS)
-- ============================================================

-- Donnees de completion (Map<String,dynamic> Dart -> JSONB)
ALTER TABLE habits ADD COLUMN IF NOT EXISTS completions JSONB DEFAULT '{}';

-- Categorie (cause de l'erreur PGRST204 initiale)
ALTER TABLE habits ADD COLUMN IF NOT EXISTS category TEXT;

-- Habitude quantitative
ALTER TABLE habits ADD COLUMN IF NOT EXISTS target_value DOUBLE PRECISION;
ALTER TABLE habits ADD COLUMN IF NOT EXISTS unit TEXT;

-- Recurrence avancee
ALTER TABLE habits ADD COLUMN IF NOT EXISTS interval_days INTEGER;
ALTER TABLE habits ADD COLUMN IF NOT EXISTS weekdays JSONB;
ALTER TABLE habits ADD COLUMN IF NOT EXISTS times_target INTEGER;
ALTER TABLE habits ADD COLUMN IF NOT EXISTS monthly_day INTEGER;
ALTER TABLE habits ADD COLUMN IF NOT EXISTS quarter_month INTEGER;
ALTER TABLE habits ADD COLUMN IF NOT EXISTS yearly_month INTEGER;
ALTER TABLE habits ADD COLUMN IF NOT EXISTS yearly_day INTEGER;
ALTER TABLE habits ADD COLUMN IF NOT EXISTS hourly_interval INTEGER;

-- UI / UX
ALTER TABLE habits ADD COLUMN IF NOT EXISTS color BIGINT;
ALTER TABLE habits ADD COLUMN IF NOT EXISTS icon BIGINT;
ALTER TABLE habits ADD COLUMN IF NOT EXISTS current_streak INTEGER DEFAULT 0;

-- Multi-utilisateur
ALTER TABLE habits ADD COLUMN IF NOT EXISTS user_email TEXT;


-- ============================================================
-- PHASE 2 : Corrections de type et contraintes
-- ============================================================

-- color/icon : valeurs ARGB Dart depassent INTEGER 32-bit (ex: 0xFF2196F3 = 4 280 391 411)
-- Si les colonnes existent deja en INTEGER, les convertir
ALTER TABLE habits ALTER COLUMN color TYPE BIGINT;
ALTER TABLE habits ALTER COLUMN icon TYPE BIGINT;

-- recurrence_type : Dart envoie null pour les habitudes sans recurrence
-- NOT NULL violerait la contrainte quand recurrenceType est null dans le modele
ALTER TABLE habits ALTER COLUMN recurrence_type DROP NOT NULL;


-- ============================================================
-- Verification post-migration
-- ============================================================
-- SELECT column_name, data_type, is_nullable, column_default
-- FROM information_schema.columns
-- WHERE table_schema = 'public' AND table_name = 'habits'
-- ORDER BY ordinal_position;
