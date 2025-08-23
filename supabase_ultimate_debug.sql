-- DEBUG COMPLET DU PROBLÈME RLS
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

-- 1.4 Vérifier que RLS est activé
SELECT 
    tablename, 
    rowsecurity as rls_enabled,
    hasrls as rls_forced
FROM pg_tables 
WHERE tablename = 'custom_lists';

-- =====================================================
-- SECTION 2: TEST MANUEL DE SUPPRESSION
-- =====================================================

-- 2.1 Tenter un UPDATE direct (remplacer l'ID par celui qui échoue)
-- ATTENTION: Remplacer '8705e0f2-775a-4b9a-9d17-59bd53e1e475' par l'ID réel
UPDATE public.custom_lists 
SET is_deleted = true 
WHERE id = '8705e0f2-775a-4b9a-9d17-59bd53e1e475' 
  AND user_id = auth.uid();

-- Vérifier le résultat
SELECT 
    id,
    title,
    is_deleted,
    user_id = auth.uid() as is_owner
FROM public.custom_lists 
WHERE id = '8705e0f2-775a-4b9a-9d17-59bd53e1e475';

-- =====================================================
-- SECTION 3: SOLUTION RADICALE - NOUVELLES POLITIQUES
-- =====================================================

-- 3.1 Supprimer TOUTES les politiques
DROP POLICY IF EXISTS "custom_lists_select_policy" ON public.custom_lists;
DROP POLICY IF EXISTS "custom_lists_insert_policy" ON public.custom_lists;
DROP POLICY IF EXISTS "custom_lists_update_policy" ON public.custom_lists;
DROP POLICY IF EXISTS "custom_lists_delete_policy" ON public.custom_lists;

-- 3.2 Créer des politiques ultra-simples
CREATE POLICY "allow_all_for_owner" ON public.custom_lists
    FOR ALL 
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- 3.3 Vérifier les nouvelles politiques
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd as operation,
    qual as using_condition,
    with_check as check_condition
FROM pg_policies 
WHERE tablename = 'custom_lists';

-- =====================================================
-- SECTION 4: TEST FINAL
-- =====================================================

-- 4.1 Test UPDATE avec nouvelle politique
UPDATE public.custom_lists 
SET is_deleted = true 
WHERE id = '8705e0f2-775a-4b9a-9d17-59bd53e1e475';

-- 4.2 Vérifier le résultat final
SELECT 
    id,
    title,
    is_deleted,
    'SUCCESS - Politique fonctionne!' as result
FROM public.custom_lists 
WHERE id = '8705e0f2-775a-4b9a-9d17-59bd53e1e475';

SELECT 'Script terminé avec succès' as final_status;