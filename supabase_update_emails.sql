-- ===================================
-- SCRIPT FINAL POUR AJOUTER EMAILS PARTOUT
-- COPIER-COLLER INTÉGRALEMENT DANS SUPABASE
-- ===================================

-- ÉTAPE 1: AJOUTER TOUTES LES COLONNES EMAIL MANQUANTES
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS email TEXT;
ALTER TABLE public.custom_lists ADD COLUMN IF NOT EXISTS user_email TEXT;
ALTER TABLE public.list_items ADD COLUMN IF NOT EXISTS user_email TEXT;
ALTER TABLE public.habits ADD COLUMN IF NOT EXISTS user_email TEXT;
ALTER TABLE public.habit_completions ADD COLUMN IF NOT EXISTS user_email TEXT;

-- ÉTAPE 2: REMPLIR TOUS LES EMAILS EXISTANTS
-- Remplir profiles.email
UPDATE public.profiles 
SET email = auth_users.email
FROM auth.users auth_users
WHERE public.profiles.id = auth_users.id
  AND public.profiles.email IS NULL;

-- Remplir custom_lists.user_email
UPDATE public.custom_lists 
SET user_email = auth_users.email
FROM auth.users auth_users
WHERE public.custom_lists.user_id = auth_users.id
  AND public.custom_lists.user_email IS NULL;

-- Remplir list_items.user_email
UPDATE public.list_items 
SET user_email = auth_users.email
FROM auth.users auth_users
WHERE public.list_items.user_id = auth_users.id
  AND public.list_items.user_email IS NULL;

-- Remplir habits.user_email
UPDATE public.habits 
SET user_email = auth_users.email
FROM auth.users auth_users
WHERE public.habits.user_id = auth_users.id
  AND public.habits.user_email IS NULL;

-- Remplir habit_completions.user_email
UPDATE public.habit_completions 
SET user_email = auth_users.email
FROM auth.users auth_users
WHERE public.habit_completions.user_id = auth_users.id
  AND public.habit_completions.user_email IS NULL;

-- ÉTAPE 3: CRÉER/RECRÉER LA FONCTION TRIGGER
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, created_at, updated_at)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = COALESCE(EXCLUDED.full_name, public.profiles.full_name),
    updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ÉTAPE 4: RECRÉER LE TRIGGER
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ÉTAPE 5: REMPLIR LES PROFILS MANQUANTS
INSERT INTO public.profiles (id, email, full_name, created_at, updated_at)
SELECT 
  au.id,
  au.email,
  COALESCE(au.raw_user_meta_data->>'full_name', ''),
  COALESCE(au.created_at, NOW()),
  NOW()
FROM auth.users au
LEFT JOIN public.profiles p ON au.id = p.id
WHERE p.id IS NULL
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  updated_at = NOW();

-- ÉTAPE 6: VÉRIFICATION FINALE
SELECT 'EMAILS AJOUTÉS AVEC SUCCÈS !' as message;

-- Afficher le résultat final
SELECT 
  'auth.users' as table_name, 
  COUNT(*) as total_records,
  COUNT(email) as emails_count
FROM auth.users
UNION ALL
SELECT 
  'profiles' as table_name, 
  COUNT(*) as total_records,
  COUNT(email) as emails_count
FROM public.profiles
UNION ALL
SELECT 
  'custom_lists' as table_name, 
  COUNT(*) as total_records,
  COUNT(user_email) as emails_count
FROM public.custom_lists
UNION ALL
SELECT 
  'list_items' as table_name, 
  COUNT(*) as total_records,
  COUNT(user_email) as emails_count
FROM public.list_items
UNION ALL
SELECT 
  'habits' as table_name, 
  COUNT(*) as total_records,
  COUNT(user_email) as emails_count
FROM public.habits;

-- ÉTAPE 7: AFFICHER LES EMAILS POUR VÉRIFICATION
SELECT 
  au.email as user_email,
  p.email as profile_email,
  COUNT(cl.id) as lists_count,
  COUNT(li.id) as items_count
FROM auth.users au
LEFT JOIN public.profiles p ON au.id = p.id
LEFT JOIN public.custom_lists cl ON au.id = cl.user_id
LEFT JOIN public.list_items li ON au.id = li.user_id
GROUP BY au.email, p.email
ORDER BY au.email;