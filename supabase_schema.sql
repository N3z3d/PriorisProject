-- ===================================
-- PRIORIS DATABASE SCHEMA - SUPABASE
-- ===================================

-- Note: JWT secret is managed by Supabase automatically
-- No need to set it manually

-- ===================================
-- 1. PROFILES TABLE (extends auth.users)
-- ===================================
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT NOT NULL, -- Email de l'utilisateur récupéré depuis auth.users
  username TEXT UNIQUE,
  full_name TEXT,
  avatar_url TEXT,
  language TEXT DEFAULT 'fr',
  theme_preference TEXT DEFAULT 'light',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS Policies for profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

-- Fonction pour créer automatiquement un profil lors de l'inscription
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (
    new.id,
    new.email,
    COALESCE(new.raw_user_meta_data->>'full_name', '')
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger pour exécuter la fonction lors de l'inscription
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- ===================================
-- 2. CUSTOM LISTS TABLE
-- ===================================
CREATE TABLE public.custom_lists (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  user_email TEXT, -- Email pour faciliter le debug
  title TEXT NOT NULL,
  description TEXT,
  color INTEGER DEFAULT 0xFF2196F3,
  icon INTEGER DEFAULT 0xe5ca,
  list_type TEXT DEFAULT 'todo',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_deleted BOOLEAN DEFAULT FALSE
);

-- RLS Policies for custom_lists
ALTER TABLE public.custom_lists ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own lists" ON public.custom_lists
  FOR SELECT USING (auth.uid() = user_id AND is_deleted = FALSE);

CREATE POLICY "Users can create own lists" ON public.custom_lists
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own lists" ON public.custom_lists
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own lists" ON public.custom_lists
  FOR UPDATE USING (auth.uid() = user_id);

-- ===================================
-- 3. LIST ITEMS TABLE  
-- ===================================
CREATE TABLE public.list_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  user_email TEXT, -- Email pour faciliter le debug
  list_id UUID REFERENCES public.custom_lists(id) NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT,
  elo_score REAL DEFAULT 1200.0,
  is_completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE,
  due_date TIMESTAMP WITH TIME ZONE,
  notes TEXT,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_deleted BOOLEAN DEFAULT FALSE
);

-- RLS Policies for list_items
ALTER TABLE public.list_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own items" ON public.list_items
  FOR SELECT USING (auth.uid() = user_id AND is_deleted = FALSE);

CREATE POLICY "Users can create own items" ON public.list_items
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own items" ON public.list_items
  FOR UPDATE USING (auth.uid() = user_id);

-- ===================================
-- 4. HABITS TABLE
-- ===================================
CREATE TABLE public.habits (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  habit_type TEXT DEFAULT 'binary',
  category TEXT,
  target_value REAL,
  unit TEXT,
  color INTEGER DEFAULT 0xFF2196F3,
  icon INTEGER DEFAULT 0xe5ca,
  current_streak INTEGER DEFAULT 0,
  recurrence_type TEXT,
  interval_days INTEGER,
  weekdays TEXT[], -- Array de jours ['monday', 'tuesday', ...]
  times_target INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_deleted BOOLEAN DEFAULT FALSE
);

-- RLS Policies for habits
ALTER TABLE public.habits ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own habits" ON public.habits
  FOR SELECT USING (auth.uid() = user_id AND is_deleted = FALSE);

CREATE POLICY "Users can create own habits" ON public.habits
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own habits" ON public.habits
  FOR UPDATE USING (auth.uid() = user_id);

-- ===================================
-- 5. HABIT COMPLETIONS TABLE
-- ===================================
CREATE TABLE public.habit_completions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  habit_id UUID REFERENCES public.habits(id) NOT NULL,
  completion_date DATE NOT NULL,
  value REAL, -- Pour les habitudes quantitatives
  completed BOOLEAN DEFAULT TRUE, -- Pour les habitudes binaires
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Éviter les doublons
  UNIQUE(habit_id, completion_date)
);

-- RLS Policies for habit_completions
ALTER TABLE public.habit_completions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own completions" ON public.habit_completions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own completions" ON public.habit_completions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own completions" ON public.habit_completions
  FOR UPDATE USING (auth.uid() = user_id);

-- ===================================
-- 6. FUNCTIONS & TRIGGERS
-- ===================================

-- Fonction pour mettre à jour updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers pour updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_custom_lists_updated_at BEFORE UPDATE ON public.custom_lists 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_list_items_updated_at BEFORE UPDATE ON public.list_items 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_habits_updated_at BEFORE UPDATE ON public.habits 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ===================================
-- 7. INDEXES FOR PERFORMANCE
-- ===================================
CREATE INDEX idx_custom_lists_user_id ON public.custom_lists(user_id);
CREATE INDEX idx_list_items_user_id ON public.list_items(user_id);
CREATE INDEX idx_list_items_list_id ON public.list_items(list_id);
CREATE INDEX idx_habits_user_id ON public.habits(user_id);
CREATE INDEX idx_habit_completions_user_id ON public.habit_completions(user_id);
CREATE INDEX idx_habit_completions_habit_id ON public.habit_completions(habit_id);
CREATE INDEX idx_habit_completions_date ON public.habit_completions(completion_date);

-- ===================================
-- 8. PROFILE CREATION ON SIGNUP
-- ===================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, avatar_url)
  VALUES (new.id, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'avatar_url');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();