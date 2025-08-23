-- SOLUTION RAPIDE : Désactiver temporairement RLS sur custom_lists
-- Exécuter dans le dashboard Supabase SQL Editor

-- Désactiver RLS temporairement pour débloquer les suppressions
ALTER TABLE public.custom_lists DISABLE ROW LEVEL SECURITY;

-- Vérifier que RLS est désactivé
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'custom_lists';

-- Optionnel : Faire de même pour list_items si nécessaire
-- ALTER TABLE public.list_items DISABLE ROW LEVEL SECURITY;