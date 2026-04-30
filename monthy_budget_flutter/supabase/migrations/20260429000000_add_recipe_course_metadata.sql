-- Add meal planner course metadata used by Supabase-first catalog loading.
-- Fixes #955

alter table if exists public.recipes
  add column if not exists is_complete_meal boolean default true,
  add column if not exists course_type text default 'mainCourse';
