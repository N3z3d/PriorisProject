-- Migration 004: Table onboarding_state (etat d'onboarding lie au compte)
-- Contexte: Story 11.11 — deplacer l'etat d'onboarding du device (localStorage)
--   vers le compte, et supporter la relance apres dormance (> 90 jours).
--
-- Une ligne par utilisateur. Miroir du modele multi-utilisateur de `habits`
--   (RLS + policies user_id = auth.uid()). ON DELETE CASCADE sert aussi le
--   droit a l'oubli (lien epic-16 / story 8-2 revokeConsent).
--
-- Instructions:
--   1. Supabase Dashboard → SQL Editor
--   2. Copier-coller ce fichier entier
--   3. Cliquer sur "Run"
--   4. Verifier avec la requete de la section "Verification" ci-dessous
--
-- ⚠️ Appliquer cette migration AVANT de deployer le code : sans la table,
--    loadState() echoue en production.
--
-- Rollback:
--   DROP TABLE IF EXISTS onboarding_state;


-- ============================================================
-- PHASE 1 : Table (idempotente via IF NOT EXISTS)
-- ============================================================

CREATE TABLE IF NOT EXISTS onboarding_state (
  user_id      UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  completed_at TIMESTAMPTZ,
  last_seen_at TIMESTAMPTZ,
  updated_at   TIMESTAMPTZ DEFAULT now()
);


-- ============================================================
-- PHASE 2 : Row Level Security + policies (user_id = auth.uid())
-- ============================================================

ALTER TABLE onboarding_state ENABLE ROW LEVEL SECURITY;

-- Idempotence : Postgres ne supporte pas CREATE POLICY IF NOT EXISTS.
-- On retire puis recree (rejouable sans erreur).
DROP POLICY IF EXISTS onboarding_state_select_own ON onboarding_state;
CREATE POLICY onboarding_state_select_own
  ON onboarding_state FOR SELECT
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS onboarding_state_insert_own ON onboarding_state;
CREATE POLICY onboarding_state_insert_own
  ON onboarding_state FOR INSERT
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS onboarding_state_update_own ON onboarding_state;
CREATE POLICY onboarding_state_update_own
  ON onboarding_state FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());


-- ============================================================
-- Verification post-migration
-- ============================================================
-- SELECT column_name, data_type, is_nullable, column_default
-- FROM information_schema.columns
-- WHERE table_schema = 'public' AND table_name = 'onboarding_state'
-- ORDER BY ordinal_position;
--
-- SELECT policyname, cmd FROM pg_policies
-- WHERE tablename = 'onboarding_state';
