-- Migration: Create recipes and recipe_ingredients tables for Supabase-first recipe loading
-- Issue: #575

-- Recipes table
CREATE TABLE IF NOT EXISTS public.recipes (
  id text PRIMARY KEY,
  name text NOT NULL,
  protein_id text,
  type text NOT NULL,
  complexity int NOT NULL DEFAULT 3,
  prep_minutes int NOT NULL DEFAULT 30,
  servings int NOT NULL DEFAULT 4,
  is_vegetarian boolean DEFAULT false,
  is_high_protein boolean DEFAULT false,
  is_low_carb boolean DEFAULT false,
  gluten_free boolean DEFAULT false,
  lactose_free boolean DEFAULT false,
  nut_free boolean DEFAULT true,
  shellfish_free boolean DEFAULT true,
  is_complete_meal boolean DEFAULT true,
  course_type text DEFAULT 'mainCourse',
  batch_cookable boolean DEFAULT false,
  max_batch_days int DEFAULT 2,
  is_portable boolean DEFAULT false,
  suitable_meal_types text[] DEFAULT '{lunch,dinner}',
  seasons text[] DEFAULT '{}',
  requires_equipment text[] DEFAULT '{}',
  nutrition jsonb,
  prep_steps text[] DEFAULT '{}',
  created_by uuid REFERENCES auth.users(id),
  is_community boolean DEFAULT false,
  locale text DEFAULT 'pt',
  created_at timestamptz DEFAULT now()
);

-- Recipe ingredients junction table
CREATE TABLE IF NOT EXISTS public.recipe_ingredients (
  recipe_id text REFERENCES public.recipes(id) ON DELETE CASCADE,
  ingredient_id text NOT NULL,
  quantity double precision NOT NULL,
  PRIMARY KEY (recipe_id, ingredient_id)
);

-- RLS policies
ALTER TABLE public.recipes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "read_all" ON public.recipes FOR SELECT USING (true);
CREATE POLICY "insert_own" ON public.recipes FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "update_own" ON public.recipes FOR UPDATE USING (auth.uid() = created_by);

ALTER TABLE public.recipe_ingredients ENABLE ROW LEVEL SECURITY;
CREATE POLICY "read_all" ON public.recipe_ingredients FOR SELECT USING (true);
CREATE POLICY "insert_own" ON public.recipe_ingredients FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM public.recipes WHERE id = recipe_id AND created_by = auth.uid())
);
