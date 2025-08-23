-- DIAGNOSTIC COMPLET DES POLITIQUES RLS
-- Exécuter dans le dashboard Supabase SQL Editor

-- 1. Vérifier si RLS est activé sur la table
SELECT 
    schemaname,
    tablename, 
    rowsecurity as rls_enabled,
    hasrls as rls_forced
FROM pg_tables 
WHERE tablename IN ('custom_lists', 'list_items');

-- 2. Lister toutes les politiques existantes
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
WHERE tablename IN ('custom_lists', 'list_items')
ORDER BY tablename, cmd;

-- 3. Vérifier la structure de la table
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'custom_lists'
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 4. Tester l'utilisateur actuel (à exécuter quand connecté)
SELECT 
    auth.uid() as current_user_id,
    auth.email() as current_user_email;