-- SUPABASE SCHEMA CORRECTED - Fix UUID types
-- Exécuter dans le dashboard Supabase

-- 1. Supprimer les tables existantes (ATTENTION: Perte de données!)
DROP TABLE IF EXISTS public.habit_completions CASCADE;
DROP TABLE IF EXISTS public.habits CASCADE;  
DROP TABLE IF EXISTS public.list_items CASCADE;
DROP TABLE IF EXISTS public.custom_lists CASCADE;

-- 2. Recréer avec les bons types UUID

-- ===================================
-- CUSTOM LISTS TABLE (UUID FIX)
-- ===================================
CREATE TABLE public.custom_lists (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,  -- FIX: UUID au lieu d'INTEGER
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  user_email TEXT, -- Email pour faciliter le debug
  title TEXT NOT NULL,  -- Supabase column name
  description TEXT,
  color INTEGER DEFAULT 4284900083, -- 0xFF2196F3 (Material Blue)
  icon INTEGER DEFAULT 58826, -- 0xe5ca (Material Icon)
  list_type TEXT DEFAULT 'CUSTOM',  -- Supabase column name
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),  -- Snake case
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),  -- Snake case
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

-- ===================================
-- LIST ITEMS TABLE (UUID FIX)
-- ===================================
CREATE TABLE public.list_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,  -- FIX: UUID au lieu d'INTEGER
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  user_email TEXT,
  list_id UUID REFERENCES public.custom_lists(id) NOT NULL,  -- UUID foreign key
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
-- FUNCTIONS & TRIGGERS
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
CREATE TRIGGER update_custom_lists_updated_at BEFORE UPDATE ON public.custom_lists 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_list_items_updated_at BEFORE UPDATE ON public.list_items 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ===================================
-- INDEXES FOR PERFORMANCE
-- ===================================
CREATE INDEX idx_custom_lists_user_id ON public.custom_lists(user_id);
CREATE INDEX idx_list_items_user_id ON public.list_items(user_id);
CREATE INDEX idx_list_items_list_id ON public.list_items(list_id);