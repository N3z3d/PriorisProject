-- DEBUG COMPLET DU PROBLÈME RLS (VERSION CORRIGÉE)
-- Exécuter section par section dans Supabase SQL Editor

-- =====================================================
-- SECTION 1: ÉTAT ACTUEL DU SYSTÈME
-- =====================================================

-- 1.1 Vérifier l'utilisateur connecté
SELECT 
    auth.uid() as current_user_id,
    auth.email() as current_user_email,
    'User info retrieved' as status;

-- 1.2 Vérifier la table et ses données  
SELECT 
    id,
    user_id,
    user_email,
    title,
    is_deleted,
    created_at
FROM public.custom_lists 
WHERE user_id = auth.uid()
ORDER BY created_at DESC;

-- 1.3 Vérifier les politiques actuelles
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd as operation,
    permissive,
    roles,
    qual as using_condition,
    with_check as check_condition
FROM pg_policies 
WHERE tablename = 'custom_lists'
ORDER BY cmd;

-- 1.4 Vérifier que RLS est activé (VERSION CORRIGÉE)
SELECT 
    tablename, 
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE tablename = 'custom_lists';

-- 1.5 Vérifier via pg_class (alternative)
SELECT 
    c.relname as table_name,
    c.relrowsecurity as rls_enabled,
    c.relforcerowsecurity as rls_forced
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public' AND c.relname = 'custom_lists';

-- =====================================================
-- SECTION 2: TEST MANUEL DE SUPPRESSION
-- =====================================================

-- 2.1 Identifier l'ID de la liste problématique
SELECT 
    id,
    title,
    user_id,
    is_deleted,
    auth.uid() = user_id as is_owner
FROM public.custom_lists 
WHERE user_id = auth.uid()
ORDER BY created_at DESC;

-- 2.2 Tenter un UPDATE direct sur UNE liste (remplacer l'ID)
-- REMPLACER '8705e0f2-775a-4b9a-9d17-59bd53e1e475' par l'ID réel de vos logs
UPDATE public.custom_lists 
SET is_deleted = true 
WHERE id = '8705e0f2-775a-4b9a-9d17-59bd53e1e475' 
  AND user_id = auth.uid();

-- Vérifier le résultat
SELECT 
    id,
    title,
    is_deleted,
    user_id = auth.uid() as is_owner,
    'UPDATE test result' as status
FROM public.custom_lists 
WHERE id = '8705e0f2-775a-4b9a-9d17-59bd53e1e475';

-- =====================================================
-- SECTION 3: SOLUTION RADICALE - POLITIQUE SIMPLE
-- =====================================================

-- 3.1 Supprimer TOUTES les politiques existantes
DROP POLICY IF EXISTS "custom_lists_select_policy" ON public.custom_lists;
DROP POLICY IF EXISTS "custom_lists_insert_policy" ON public.custom_lists;
DROP POLICY IF EXISTS "custom_lists_update_policy" ON public.custom_lists;
DROP POLICY IF EXISTS "custom_lists_delete_policy" ON public.custom_lists;
DROP POLICY IF EXISTS "Users can view own lists" ON public.custom_lists;
DROP POLICY IF EXISTS "Users can create own lists" ON public.custom_lists;
DROP POLICY IF EXISTS "Users can update own lists" ON public.custom_lists;
DROP POLICY IF EXISTS "Users can delete own lists" ON public.custom_lists;
DROP POLICY IF EXISTS "allow_all_for_owner" ON public.custom_lists;

-- 3.2 Créer UNE politique ultra-simple pour tout
CREATE POLICY "owner_full_access" ON public.custom_lists
    FOR ALL 
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- 3.3 Vérifier la nouvelle politique
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd as operation,
    qual as using_condition,
    with_check as check_condition,
    'New policy created' as status
FROM pg_policies 
WHERE tablename = 'custom_lists';

-- =====================================================
-- SECTION 4: TEST FINAL
-- =====================================================

-- 4.1 Test de lecture (doit fonctionner)
SELECT 
    id,
    title,
    is_deleted,
    'READ test' as operation
FROM public.custom_lists 
WHERE user_id = auth.uid()
LIMIT 3;

-- 4.2 Test UPDATE avec nouvelle politique
UPDATE public.custom_lists 
SET is_deleted = false 
WHERE id = '8705e0f2-775a-4b9a-9d17-59bd53e1e475'
  AND user_id = auth.uid();

-- 4.3 Puis test soft delete
UPDATE public.custom_lists 
SET is_deleted = true 
WHERE id = '8705e0f2-775a-4b9a-9d17-59bd53e1e475'
  AND user_id = auth.uid();

-- 4.4 Vérifier le résultat final
SELECT 
    id,
    title,
    is_deleted,
    'FINAL SUCCESS!' as result
FROM public.custom_lists 
WHERE id = '8705e0f2-775a-4b9a-9d17-59bd53e1e475';

SELECT 'Script debugging terminé avec succès!' as final_status;