-- ===================================
-- MISE À JOUR INCRÉMENTALE SUPABASE
-- ===================================

-- 1. Ajouter user_email aux tables existantes SI la colonne n'existe pas
DO $$ 
BEGIN
    -- Ajouter user_email à custom_lists
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='custom_lists' AND column_name='user_email') THEN
        ALTER TABLE public.custom_lists ADD COLUMN user_email TEXT;
    END IF;
    
    -- Ajouter user_email à list_items
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='list_items' AND column_name='user_email') THEN
        ALTER TABLE public.list_items ADD COLUMN user_email TEXT;
    END IF;
    
    -- Ajouter user_email à habits
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='habits' AND column_name='user_email') THEN
        ALTER TABLE public.habits ADD COLUMN user_email TEXT;
    END IF;
END $$;

-- 2. Mettre à jour les enregistrements existants avec l'email
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

-- 3. Créer la table profiles SI elle n'existe pas
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT NOT NULL,
  username TEXT UNIQUE,
  full_name TEXT,
  avatar_url TEXT,
  language TEXT DEFAULT 'fr',
  theme_preference TEXT DEFAULT 'light',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Activer RLS sur profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 5. Créer les policies SI elles n'existent pas
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'profiles' AND policyname = 'Users can view own profile') THEN
        CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'profiles' AND policyname = 'Users can update own profile') THEN
        CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);
    END IF;
END $$;

-- 6. Créer la fonction et le trigger
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (
    new.id,
    new.email,
    COALESCE(new.raw_user_meta_data->>'full_name', '')
  )
  ON CONFLICT (id) DO NOTHING; -- Éviter les erreurs si le profil existe déjà
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Supprimer le trigger s'il existe puis le recréer
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 7. Remplir les profils manquants pour les utilisateurs existants
INSERT INTO public.profiles (id, email, full_name)
SELECT 
  au.id,
  au.email,
  COALESCE(au.raw_user_meta_data->>'full_name', '')
FROM auth.users au
WHERE au.id NOT IN (SELECT id FROM public.profiles)
ON CONFLICT (id) DO NOTHING;

-- Message de confirmation
SELECT 'Mise à jour incrémentale terminée avec succès !' as message;