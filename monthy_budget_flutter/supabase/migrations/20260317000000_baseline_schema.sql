-- ============================================================================
-- Baseline schema documentation
-- Generated from service layer analysis on 2026-03-17
-- This file documents the known schema; the actual schema was created via
-- Supabase dashboard and incremental SQL scripts.
-- Run this only on a FRESH database; existing databases already have these tables.
-- ============================================================================

-- ─── Extensions ─────────────────────────────────────────────────────────────
create extension if not exists "pgcrypto";
create extension if not exists "vector";

-- ============================================================================
-- CORE TABLES
-- ============================================================================

-- Households: top-level tenant; all data is scoped to a household.
create table if not exists households (
  id           uuid primary key default gen_random_uuid(),
  name         text not null,
  created_at   timestamptz default now()
);

-- Profiles: extends auth.users, auto-created by trigger on signup.
create table if not exists profiles (
  id           uuid primary key references auth.users on delete cascade,
  email        text not null,
  household_id uuid references households(id),
  role         text not null default 'member'
                 check (role in ('admin', 'member')),
  created_at   timestamptz default now()
);

-- Auto-create profile row when a user signs up.
create or replace function handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into profiles (id, email)
  values (new.id, new.email);
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure handle_new_user();

-- Household settings (JSON blob per household).
create table if not exists household_settings (
  household_id uuid primary key references households(id) on delete cascade,
  settings_json text not null default '{}',
  updated_at   timestamptz default now()
);

-- Household invite codes for multi-user onboarding.
create table if not exists household_invites (
  id           uuid primary key default gen_random_uuid(),
  household_id uuid not null references households(id) on delete cascade,
  code         text not null unique,
  created_by   uuid not null references profiles(id),
  created_at   timestamptz default now(),
  expires_at   timestamptz default (now() + interval '7 days')
);

-- ============================================================================
-- SHOPPING
-- ============================================================================

-- Shopping list items.
create table if not exists shopping_items (
  id           uuid primary key default gen_random_uuid(),
  household_id uuid not null references households(id) on delete cascade,
  product_name text not null,
  store        text not null default '',
  price        numeric not null default 0,
  unit_price   text,
  checked      boolean not null default false,
  created_at   timestamptz default now(),
  updated_at   timestamptz default now()
);

-- Household favorite products (JSON array).
create table if not exists household_favorites (
  household_id  uuid primary key references households(id) on delete cascade,
  favorites_json text not null default '[]',
  updated_at    timestamptz default now()
);

-- Purchase history records (completed shopping trips).
create table if not exists purchase_records (
  id           text primary key,
  household_id uuid not null references households(id) on delete cascade,
  amount       numeric not null,
  item_count   int not null default 0,
  purchased_at timestamptz not null,
  items_json   text,
  created_at   timestamptz default now()
);

-- ============================================================================
-- PRODUCTS CATALOG (global, shared by all households)
-- ============================================================================

create table if not exists products (
  id           uuid primary key default gen_random_uuid(),
  name         text not null,
  category     text not null,
  avg_price    numeric not null default 0,
  unit         text not null default 'un'
);

-- ============================================================================
-- EXPENSES & BUDGETS
-- ============================================================================

-- Expense snapshots (planned/budgeted expenses per month).
create table if not exists expense_snapshots (
  id            uuid primary key default gen_random_uuid(),
  household_id  uuid not null references households(id) on delete cascade,
  month         text not null,
  expense_id    text not null,
  label         text not null,
  category      text not null,
  amount        double precision not null,
  enabled       boolean not null default true,
  created_at    timestamptz default now(),
  unique(household_id, month, expense_id)
);

-- Actual expenses (recorded transactions).
create table if not exists actual_expenses (
  id                   text primary key,
  household_id         uuid not null references households(id) on delete cascade,
  category             text not null,
  amount               double precision not null,
  expense_date         date not null,
  description          text,
  month_key            text not null,
  created_at           timestamptz default now(),
  attachment_urls      text[],
  location_lat         double precision,
  location_lng         double precision,
  location_address     text,
  recurring_expense_id text,
  is_from_recurring    boolean default false
);

create index if not exists idx_actual_expenses_month
  on actual_expenses(household_id, month_key);

-- Recurring expense templates.
-- Columns: id, household_id, category, amount, description, day_of_month, is_active
create table if not exists recurring_expenses (
  id            text primary key,
  household_id  uuid not null references households(id) on delete cascade,
  category      text not null,
  amount        double precision not null,
  description   text,
  day_of_month  int,
  is_active     boolean not null default true,
  created_at    timestamptz default now()
);

-- Tracks which months have already been auto-populated from recurring templates.
create table if not exists recurring_expense_runs (
  household_id uuid not null references households(id) on delete cascade,
  month_key    text not null,
  created_at   timestamptz default now(),
  primary key (household_id, month_key)
);

-- Monthly budget targets per category.
-- Columns: id, household_id, category, amount, month_key
create table if not exists monthly_budgets (
  id           text primary key,
  household_id uuid not null references households(id) on delete cascade,
  category     text not null,
  amount       double precision not null,
  month_key    text not null,
  created_at   timestamptz default now(),
  unique(household_id, month_key, category)
);

-- Custom expense categories.
create table if not exists custom_categories (
  id           text primary key,
  household_id uuid not null references households(id) on delete cascade,
  name         text not null,
  icon_name    text,
  color_hex    text,
  sort_order   int not null default 0,
  created_at   timestamptz default now()
);

-- ============================================================================
-- SAVINGS GOALS
-- ============================================================================

-- Savings goals with target/current tracking.
create table if not exists savings_goals (
  id             text primary key,
  household_id   uuid not null references households(id) on delete cascade,
  name           text not null,
  target_amount  double precision not null,
  current_amount double precision not null default 0,
  deadline       date,
  color          text,
  is_active      boolean not null default true,
  created_at     timestamptz default now()
);

-- Individual contributions toward a savings goal.
create table if not exists savings_contributions (
  id                text primary key,
  household_id      uuid not null references households(id) on delete cascade,
  goal_id           text not null references savings_goals(id) on delete cascade,
  amount            double precision not null,
  contribution_date date not null,
  note              text,
  created_at        timestamptz default now()
);

-- ============================================================================
-- MEAL PLANNING
-- ============================================================================

-- Monthly meal plans (JSON blob).
create table if not exists meal_plans (
  household_id uuid not null references households(id) on delete cascade,
  month        int not null,
  year         int not null,
  plan_json    text not null,
  updated_at   timestamptz default now(),
  primary key (household_id, month, year)
);

-- Recipes catalog (global, community-shared).
create table if not exists recipes (
  id                  text primary key,
  name                text not null,
  protein_id          text,
  type                text not null,
  complexity          int not null default 3,
  prep_minutes        int not null default 30,
  servings            int not null default 4,
  is_vegetarian       boolean default false,
  is_high_protein     boolean default false,
  is_low_carb         boolean default false,
  gluten_free         boolean default false,
  lactose_free        boolean default false,
  nut_free            boolean default true,
  shellfish_free      boolean default true,
  batch_cookable      boolean default false,
  max_batch_days      int default 2,
  is_portable         boolean default false,
  suitable_meal_types text[] default '{lunch,dinner}',
  seasons             text[] default '{}',
  requires_equipment  text[] default '{}',
  nutrition           jsonb,
  prep_steps          text[] default '{}',
  created_by          uuid references auth.users(id),
  is_community        boolean default false,
  locale              text default 'pt',
  created_at          timestamptz default now()
);

-- Recipe ingredients junction table.
create table if not exists recipe_ingredients (
  recipe_id     text references recipes(id) on delete cascade,
  ingredient_id text not null,
  quantity      double precision not null,
  primary key (recipe_id, ingredient_id)
);

-- ============================================================================
-- MERCHANT REGISTRY
-- ============================================================================

-- NIF-based merchant lookup for receipt scanning.
-- Columns: nif, name, chain, category, confirmed_count, created_by
create table if not exists merchant_nif_registry (
  nif              text primary key,
  name             text not null,
  chain            text,
  category         text not null default 'outro',
  confirmed_count  int not null default 0,
  created_by       uuid references auth.users(id),
  created_at       timestamptz default now()
);

-- ============================================================================
-- AI COACH
-- ============================================================================

-- Coach insight cards saved per household.
create table if not exists household_coach_insights (
  id            text primary key,
  household_id  uuid not null references households(id) on delete cascade,
  content       text not null,
  stress_score  int not null default 0,
  created_at    timestamptz not null default now()
);

-- Coach conversation threads.
create table if not exists coach_threads (
  id            uuid primary key default gen_random_uuid(),
  household_id  uuid not null references households(id) on delete cascade,
  user_id       uuid not null references profiles(id) on delete cascade,
  title         text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- Individual messages within a coach thread.
create table if not exists coach_messages (
  id            uuid primary key default gen_random_uuid(),
  thread_id     uuid not null references coach_threads(id) on delete cascade,
  household_id  uuid not null references households(id) on delete cascade,
  user_id       uuid not null references profiles(id) on delete cascade,
  role          text not null check (role in ('system', 'user', 'assistant')),
  content       text not null,
  token_count   int,
  mode_used     text not null check (mode_used in ('eco', 'plus', 'pro')),
  created_at    timestamptz not null default now()
);

create index if not exists idx_coach_messages_thread_created
  on coach_messages(thread_id, created_at desc);

-- Long-term memory extracted from coach conversations.
create table if not exists coach_memories (
  id                uuid primary key default gen_random_uuid(),
  household_id      uuid not null references households(id) on delete cascade,
  user_id           uuid not null references profiles(id) on delete cascade,
  source_message_id uuid references coach_messages(id) on delete set null,
  type              text not null check (type in ('goal', 'habit', 'fact', 'preference', 'event', 'insight')),
  content           text not null,
  importance        int not null default 1 check (importance between 1 and 5),
  embedding         vector(1536),
  created_at        timestamptz not null default now(),
  expires_at        timestamptz
);

create index if not exists idx_coach_memories_user_created
  on coach_memories(user_id, created_at desc);

create index if not exists idx_coach_memories_embedding
  on coach_memories using ivfflat (embedding vector_cosine_ops) with (lists = 100);

-- Summarized conversation windows for coach context.
create table if not exists coach_memory_summaries (
  id            uuid primary key default gen_random_uuid(),
  thread_id     uuid not null references coach_threads(id) on delete cascade,
  household_id  uuid not null references households(id) on delete cascade,
  user_id       uuid not null references profiles(id) on delete cascade,
  summary       text not null,
  window_start  timestamptz not null,
  window_end    timestamptz not null,
  created_at    timestamptz not null default now()
);

create index if not exists idx_coach_summaries_thread_created
  on coach_memory_summaries(thread_id, created_at desc);

-- ============================================================================
-- HOUSEHOLD ACTIVITY EVENTS (audit trail)
-- ============================================================================

create table if not exists household_activity_events (
  id                 uuid primary key default gen_random_uuid(),
  household_id       uuid not null references households(id) on delete cascade,
  actor_user_id      uuid not null references profiles(id),
  actor_display_name text not null,
  domain             text not null check (domain in ('shopping', 'meals', 'expenses', 'pantry', 'settings')),
  action             text not null check (action in ('added', 'removed', 'swapped', 'updated', 'checked', 'unchecked')),
  subject_id         text not null default '',
  subject_label      text not null default '',
  metadata           jsonb not null default '{}',
  created_at         timestamptz default now()
);

create index if not exists idx_activity_household_created
  on household_activity_events (household_id, created_at desc);

create index if not exists idx_activity_household_domain_created
  on household_activity_events (household_id, domain, created_at desc);

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================

-- Helper: caller's household_id
create or replace function my_household_id()
returns uuid language sql security definer stable as $$
  select household_id from profiles where id = auth.uid()
$$;

-- Helper: caller's role
create or replace function my_role()
returns text language sql security definer stable as $$
  select role from profiles where id = auth.uid()
$$;

-- ─── Enable RLS on all tables ───────────────────────────────────────────────
alter table households                enable row level security;
alter table profiles                  enable row level security;
alter table household_settings        enable row level security;
alter table household_invites         enable row level security;
alter table shopping_items            enable row level security;
alter table household_favorites       enable row level security;
alter table purchase_records          enable row level security;
alter table products                  enable row level security;
alter table expense_snapshots         enable row level security;
alter table actual_expenses           enable row level security;
alter table recurring_expenses        enable row level security;
alter table recurring_expense_runs    enable row level security;
alter table monthly_budgets           enable row level security;
alter table custom_categories         enable row level security;
alter table savings_goals             enable row level security;
alter table savings_contributions     enable row level security;
alter table meal_plans                enable row level security;
alter table recipes                   enable row level security;
alter table recipe_ingredients        enable row level security;
alter table merchant_nif_registry     enable row level security;
alter table household_coach_insights  enable row level security;
alter table coach_threads             enable row level security;
alter table coach_messages            enable row level security;
alter table coach_memories            enable row level security;
alter table coach_memory_summaries    enable row level security;
alter table household_activity_events enable row level security;

-- ─── Policies: households ───────────────────────────────────────────────────
create policy "read own household" on households
  for select using (id = my_household_id());

-- ─── Policies: profiles ─────────────────────────────────────────────────────
create policy "read household profiles" on profiles
  for select using (household_id = my_household_id() or id = auth.uid());
create policy "update own profile" on profiles
  for update using (id = auth.uid());

-- ─── Policies: household_settings (admin write) ─────────────────────────────
create policy "read settings" on household_settings
  for select using (household_id = my_household_id());
create policy "write settings admin" on household_settings
  for all using (household_id = my_household_id() and my_role() = 'admin');

-- ─── Policies: household_invites ────────────────────────────────────────────
create policy "read invites" on household_invites
  for select using (household_id = my_household_id());
create policy "create invite admin" on household_invites
  for insert with check (household_id = my_household_id() and my_role() = 'admin');

-- ─── Policies: shopping_items ───────────────────────────────────────────────
create policy "read items"   on shopping_items for select using (household_id = my_household_id());
create policy "insert items" on shopping_items for insert with check (household_id = my_household_id());
create policy "update items" on shopping_items for update using (household_id = my_household_id());
create policy "delete items" on shopping_items for delete using (household_id = my_household_id());

-- ─── Policies: household_favorites ──────────────────────────────────────────
create policy "read favorites"  on household_favorites for select using (household_id = my_household_id());
create policy "write favorites" on household_favorites for all   using (household_id = my_household_id());

-- ─── Policies: purchase_records ─────────────────────────────────────────────
create policy "read purchases"   on purchase_records for select using (household_id = my_household_id());
create policy "insert purchases" on purchase_records for insert with check (household_id = my_household_id());
create policy "delete purchases" on purchase_records for delete using (household_id = my_household_id());

-- ─── Policies: products (read-only for authenticated) ───────────────────────
create policy "read products" on products for select to authenticated using (true);

-- ─── Policies: expense_snapshots ────────────────────────────────────────────
create policy "read snapshots"   on expense_snapshots for select using (household_id = my_household_id());
create policy "insert snapshots" on expense_snapshots for insert with check (household_id = my_household_id());
create policy "update snapshots" on expense_snapshots for update using (household_id = my_household_id());

-- ─── Policies: actual_expenses ──────────────────────────────────────────────
create policy "read actual_expenses"   on actual_expenses for select using (household_id = my_household_id());
create policy "insert actual_expenses" on actual_expenses for insert with check (household_id = my_household_id());
create policy "update actual_expenses" on actual_expenses for update using (household_id = my_household_id());
create policy "delete actual_expenses" on actual_expenses for delete using (household_id = my_household_id());

-- ─── Policies: recurring_expenses ───────────────────────────────────────────
create policy "read recurring_expenses"   on recurring_expenses for select using (household_id = my_household_id());
create policy "insert recurring_expenses" on recurring_expenses for insert with check (household_id = my_household_id());
create policy "update recurring_expenses" on recurring_expenses for update using (household_id = my_household_id());
create policy "delete recurring_expenses" on recurring_expenses for delete using (household_id = my_household_id());

-- ─── Policies: recurring_expense_runs ───────────────────────────────────────
create policy "read recurring_expense_runs"   on recurring_expense_runs for select using (household_id = my_household_id());
create policy "insert recurring_expense_runs" on recurring_expense_runs for insert with check (household_id = my_household_id());

-- ─── Policies: monthly_budgets ──────────────────────────────────────────────
create policy "read monthly_budgets"   on monthly_budgets for select using (household_id = my_household_id());
create policy "insert monthly_budgets" on monthly_budgets for insert with check (household_id = my_household_id());
create policy "update monthly_budgets" on monthly_budgets for update using (household_id = my_household_id());

-- ─── Policies: custom_categories ────────────────────────────────────────────
create policy "read categories"   on custom_categories for select using (household_id = my_household_id());
create policy "insert categories" on custom_categories for insert with check (household_id = my_household_id());
create policy "update categories" on custom_categories for update using (household_id = my_household_id());
create policy "delete categories" on custom_categories for delete using (household_id = my_household_id());

-- ─── Policies: savings_goals ────────────────────────────────────────────────
create policy "read savings_goals"   on savings_goals for select using (household_id = my_household_id());
create policy "insert savings_goals" on savings_goals for insert with check (household_id = my_household_id());
create policy "update savings_goals" on savings_goals for update using (household_id = my_household_id());
create policy "delete savings_goals" on savings_goals for delete using (household_id = my_household_id());

-- ─── Policies: savings_contributions ────────────────────────────────────────
create policy "read savings_contributions"   on savings_contributions for select using (household_id = my_household_id());
create policy "insert savings_contributions" on savings_contributions for insert with check (household_id = my_household_id());
create policy "delete savings_contributions" on savings_contributions for delete using (household_id = my_household_id());

-- ─── Policies: meal_plans ───────────────────────────────────────────────────
create policy "read plans"  on meal_plans for select using (household_id = my_household_id());
create policy "write plans" on meal_plans for all   using (household_id = my_household_id());

-- ─── Policies: recipes (global read, owner write) ───────────────────────────
create policy "read_all"    on recipes for select using (true);
create policy "insert_own"  on recipes for insert with check (auth.uid() = created_by);
create policy "update_own"  on recipes for update using (auth.uid() = created_by);

-- ─── Policies: recipe_ingredients ───────────────────────────────────────────
create policy "read_all" on recipe_ingredients for select using (true);
create policy "insert_own" on recipe_ingredients for insert with check (
  exists (select 1 from recipes where id = recipe_id and created_by = auth.uid())
);

-- ─── Policies: merchant_nif_registry ────────────────────────────────────────
create policy "read merchant_nif_registry" on merchant_nif_registry
  for select to authenticated using (true);
create policy "upsert merchant_nif_registry" on merchant_nif_registry
  for insert to authenticated with check (true);

-- ─── Policies: household_coach_insights ─────────────────────────────────────
create policy "read coach_insights"   on household_coach_insights for select using (household_id = my_household_id());
create policy "insert coach_insights" on household_coach_insights for insert with check (household_id = my_household_id());
create policy "delete coach_insights" on household_coach_insights for delete using (household_id = my_household_id());

-- ─── Policies: coach_threads ────────────────────────────────────────────────
create policy "read coach_threads"       on coach_threads for select using (household_id = my_household_id());
create policy "insert coach_threads"     on coach_threads for insert with check (household_id = my_household_id() and user_id = auth.uid());
create policy "update own coach_threads" on coach_threads for update using (household_id = my_household_id() and user_id = auth.uid());

-- ─── Policies: coach_messages ───────────────────────────────────────────────
create policy "read coach_messages"   on coach_messages for select using (household_id = my_household_id());
create policy "insert coach_messages" on coach_messages for insert with check (household_id = my_household_id() and user_id = auth.uid());

-- ─── Policies: coach_memories ───────────────────────────────────────────────
create policy "read coach_memories"       on coach_memories for select using (household_id = my_household_id());
create policy "insert coach_memories"     on coach_memories for insert with check (household_id = my_household_id() and user_id = auth.uid());
create policy "update own coach_memories" on coach_memories for update using (household_id = my_household_id() and user_id = auth.uid());

-- ─── Policies: coach_memory_summaries ───────────────────────────────────────
create policy "read coach_memory_summaries"   on coach_memory_summaries for select using (household_id = my_household_id());
create policy "insert coach_memory_summaries" on coach_memory_summaries for insert with check (household_id = my_household_id() and user_id = auth.uid());

-- ─── Policies: household_activity_events ────────────────────────────────────
create policy "read household activity"  on household_activity_events for select using (household_id = my_household_id());
create policy "insert household activity" on household_activity_events for insert with check (household_id = my_household_id());

-- ============================================================================
-- RPC FUNCTIONS
-- ============================================================================

-- Vector similarity search for coach memories.
create or replace function match_coach_memories(
  p_household_id uuid,
  p_user_id uuid,
  p_query_embedding vector(1536),
  p_limit int default 6
)
returns table (
  id uuid,
  content text,
  type text,
  importance int,
  score float
)
language sql
stable
security definer
set search_path = public
as $$
  select
    m.id,
    m.content,
    m.type,
    m.importance,
    1 - (m.embedding <=> p_query_embedding) as score
  from coach_memories m
  where m.household_id = p_household_id
    and m.user_id = p_user_id
    and m.embedding is not null
    and (m.expires_at is null or m.expires_at > now())
  order by m.embedding <=> p_query_embedding, m.importance desc
  limit greatest(1, least(coalesce(p_limit, 6), 20));
$$;

-- ============================================================================
-- REALTIME
-- ============================================================================

alter publication supabase_realtime add table shopping_items;
