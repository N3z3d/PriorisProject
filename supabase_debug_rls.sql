-- DIAGNOSTIC ET CORRECTION RLS POUR SUPPRESSION
-- Exécuter dans le dashboard Supabase SQL Editor

-- 1. Vérifier les politiques actuelles
SELECT 
    schemaname, 
    tablename, 
    policyname, 
    cmd as operation,
    qual as condition,
    with_check
FROM pg_policies 
WHERE tablename = 'custom_lists'
ORDER BY cmd;

-- 2. Supprimer TOUTES les anciennes politiques
DROP POLICY IF EXISTS "Users can view own lists" ON public.custom_lists;
DROP POLICY IF EXISTS "Users can create own lists" ON public.custom_lists;
DROP POLICY IF EXISTS "Users can update own lists" ON public.custom_lists;
DROP POLICY IF EXISTS "Users can delete own lists" ON public.custom_lists;

-- 3. Recréer des politiques simples et permissives
-- SELECT Policy
CREATE POLICY "custom_lists_select" ON public.custom_lists
  FOR SELECT USING (auth.uid() = user_id);

-- INSERT Policy
CREATE POLICY "custom_lists_insert" ON public.custom_lists
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- UPDATE Policy (très permissive)
CREATE POLICY "custom_lists_update" ON public.custom_lists
  FOR UPDATE USING (auth.uid() = user_id);

-- DELETE Policy (au cas où)
CREATE POLICY "custom_lists_delete" ON public.custom_lists
  FOR DELETE USING (auth.uid() = user_id);

-- 4. Vérifier que RLS est activé
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'custom_lists';

-- 5. Vérifier les nouvelles politiques
SELECT 
    schemaname, 
    tablename, 
    policyname, 
    cmd as operation,
    qual as condition
FROM pg_policies 
WHERE tablename = 'custom_lists'
ORDER BY cmd;