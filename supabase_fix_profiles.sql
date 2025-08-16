-- ===================================
-- CORRECTION PROFILES TABLE SUPABASE
-- ===================================

-- 1. Ajouter la colonne email à la table profiles existante
DO $$ 
BEGIN
    -- Ajouter email à profiles si elle n'existe pas
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='email') THEN
        ALTER TABLE public.profiles ADD COLUMN email TEXT;
    END IF;
    
    -- Ajouter user_email aux autres tables
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='custom_lists' AND column_name='user_email') THEN
        ALTER TABLE public.custom_lists ADD COLUMN user_email TEXT;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='list_items' AND column_name='user_email') THEN
        ALTER TABLE public.list_items ADD COLUMN user_email TEXT;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='habits' AND column_name='user_email') THEN
        ALTER TABLE public.habits ADD COLUMN user_email TEXT;
    END IF;
END $$;

-- 2. Remplir la colonne email des profiles existants
UPDATE public.profiles 
SET email = (
  SELECT email FROM auth.users 
  WHERE auth.users.id = profiles.id
)
WHERE email IS NULL;

-- 3. Mettre à jour les autres tables avec l'email
UPDATE public.custom_lists 
SET user_email = (
  SELECT email FROM auth.users 
  WHERE auth.users.id = custom_lists.user_id
)
WHERE user_email IS NULL;

UPDATE public.list_items 
SET user_email = (
  SELECT email FROM auth.users 
  WHERE auth.users.id = list_items.user_id
)
WHERE user_email IS NULL;

UPDATE public.habits 
SET user_email = (
  SELECT email FROM auth.users 
  WHERE auth.users.id = habits.user_id
)
WHERE user_email IS NULL;

-- 4. Créer la fonction de trigger corrigée
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (
    new.id,
    new.email,
    COALESCE(new.raw_user_meta_data->>'full_name', '')
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = COALESCE(EXCLUDED.full_name, public.profiles.full_name);
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Recréer le trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 6. Remplir les profils manquants pour les utilisateurs existants
INSERT INTO public.profiles (id, email, full_name)
SELECT 
  au.id,
  au.email,
  COALESCE(au.raw_user_meta_data->>'full_name', '')
FROM auth.users au
WHERE au.id NOT IN (SELECT id FROM public.profiles WHERE id IS NOT NULL)
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  full_name = COALESCE(EXCLUDED.full_name, public.profiles.full_name);

-- 7. Vérifier les résultats
SELECT 'Colonnes ajoutées avec succès !' as message;

-- Afficher les stats
SELECT 
  'auth.users' as table_name, 
  COUNT(*) as count 
FROM auth.users
UNION ALL
SELECT 
  'profiles' as table_name, 
  COUNT(*) as count 
FROM public.profiles
UNION ALL
SELECT 
  'custom_lists' as table_name, 
  COUNT(*) as count 
FROM public.custom_lists
UNION ALL
SELECT 
  'list_items' as table_name, 
  COUNT(*) as count 
FROM public.list_items;