-- POLITIQUES RLS PROPRES ET COMPLÈTES
-- Exécuter dans le dashboard Supabase SQL Editor
-- 
-- Cette solution suit les meilleures pratiques Supabase :
-- 1. Politiques explicites pour chaque opération (SELECT, INSERT, UPDATE, DELETE)
-- 2. Conditions précises avec auth.uid()
-- 3. Gestion du soft delete avec is_deleted
-- 4. Sécurité par défaut (deny-by-default)

-- ==========================================
-- ÉTAPE 1: NETTOYER LES ANCIENNES POLITIQUES
-- ==========================================

-- Supprimer toutes les politiques existantes de custom_lists
DO $$ 
BEGIN
    -- Supprimer les politiques si elles existent
    DROP POLICY IF EXISTS "Users can view own lists" ON public.custom_lists;
    DROP POLICY IF EXISTS "Users can create own lists" ON public.custom_lists;
    DROP POLICY IF EXISTS "Users can update own lists" ON public.custom_lists;
    DROP POLICY IF EXISTS "Users can delete own lists" ON public.custom_lists;
    DROP POLICY IF EXISTS "custom_lists_select" ON public.custom_lists;
    DROP POLICY IF EXISTS "custom_lists_insert" ON public.custom_lists;
    DROP POLICY IF EXISTS "custom_lists_update" ON public.custom_lists;
    DROP POLICY IF EXISTS "custom_lists_delete" ON public.custom_lists;
    
    -- Pareil pour list_items
    DROP POLICY IF EXISTS "Users can view own items" ON public.list_items;
    DROP POLICY IF EXISTS "Users can create own items" ON public.list_items;
    DROP POLICY IF EXISTS "Users can update own items" ON public.list_items;
    DROP POLICY IF EXISTS "Users can delete own items" ON public.list_items;
END $$;

-- ==========================================
-- ÉTAPE 2: POLITIQUES RLS POUR CUSTOM_LISTS
-- ==========================================

-- Activer RLS (au cas où ce ne serait pas fait)
ALTER TABLE public.custom_lists ENABLE ROW LEVEL SECURITY;

-- Politique SELECT : Voir ses propres listes non supprimées
CREATE POLICY "custom_lists_select_policy" ON public.custom_lists
    FOR SELECT 
    USING (
        auth.uid() = user_id 
        AND (is_deleted = false OR is_deleted IS NULL)
    );

-- Politique INSERT : Créer des listes pour soi-même
CREATE POLICY "custom_lists_insert_policy" ON public.custom_lists
    FOR INSERT 
    WITH CHECK (
        auth.uid() = user_id
        AND auth.uid() IS NOT NULL
    );

-- Politique UPDATE : Modifier ses propres listes (y compris soft delete)
CREATE POLICY "custom_lists_update_policy" ON public.custom_lists
    FOR UPDATE 
    USING (
        auth.uid() = user_id 
        AND auth.uid() IS NOT NULL
    )
    WITH CHECK (
        auth.uid() = user_id 
        AND auth.uid() IS NOT NULL
    );

-- Politique DELETE : Supprimer ses propres listes (hard delete si nécessaire)
CREATE POLICY "custom_lists_delete_policy" ON public.custom_lists
    FOR DELETE 
    USING (
        auth.uid() = user_id 
        AND auth.uid() IS NOT NULL
    );

-- ==========================================
-- ÉTAPE 3: POLITIQUES RLS POUR LIST_ITEMS
-- ==========================================

-- Activer RLS
ALTER TABLE public.list_items ENABLE ROW LEVEL SECURITY;

-- Politique SELECT : Voir ses propres items non supprimés
CREATE POLICY "list_items_select_policy" ON public.list_items
    FOR SELECT 
    USING (
        auth.uid() = user_id 
        AND (is_deleted = false OR is_deleted IS NULL)
    );

-- Politique INSERT : Créer des items pour soi-même
CREATE POLICY "list_items_insert_policy" ON public.list_items
    FOR INSERT 
    WITH CHECK (
        auth.uid() = user_id
        AND auth.uid() IS NOT NULL
    );

-- Politique UPDATE : Modifier ses propres items (y compris soft delete)
CREATE POLICY "list_items_update_policy" ON public.list_items
    FOR UPDATE 
    USING (
        auth.uid() = user_id 
        AND auth.uid() IS NOT NULL
    )
    WITH CHECK (
        auth.uid() = user_id 
        AND auth.uid() IS NOT NULL
    );

-- Politique DELETE : Supprimer ses propres items (hard delete si nécessaire)
CREATE POLICY "list_items_delete_policy" ON public.list_items
    FOR DELETE 
    USING (
        auth.uid() = user_id 
        AND auth.uid() IS NOT NULL
    );

-- ==========================================
-- ÉTAPE 4: VÉRIFICATION DES POLITIQUES
-- ==========================================

-- Vérifier que RLS est activé
SELECT 
    tablename, 
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE tablename IN ('custom_lists', 'list_items')
AND schemaname = 'public';

-- Lister toutes les nouvelles politiques
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd as operation,
    qual as using_condition,
    with_check as check_condition
FROM pg_policies 
WHERE tablename IN ('custom_lists', 'list_items')
ORDER BY tablename, cmd;

-- Message de confirmation
SELECT 'Politiques RLS propres installées avec succès !' as status;