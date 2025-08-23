-- FIX POLITIQUE RLS POUR SUPPRESSION
-- Exécuter dans le dashboard Supabase SQL Editor

-- Correction de la politique UPDATE pour permettre soft delete
DROP POLICY IF EXISTS "Users can update own lists" ON public.custom_lists;
CREATE POLICY "Users can update own lists" ON public.custom_lists
  FOR UPDATE USING (auth.uid() = user_id);

-- Ajout de la politique DELETE (même si on utilise soft delete)
CREATE POLICY "Users can delete own lists" ON public.custom_lists
  FOR DELETE USING (auth.uid() = user_id);

-- Même correction pour list_items
DROP POLICY IF EXISTS "Users can update own items" ON public.list_items;
CREATE POLICY "Users can update own items" ON public.list_items
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own items" ON public.list_items
  FOR DELETE USING (auth.uid() = user_id);

-- Vérification des politiques
SELECT schemaname, tablename, policyname, cmd, qual 
FROM pg_policies 
WHERE tablename IN ('custom_lists', 'list_items') 
ORDER BY tablename, cmd;