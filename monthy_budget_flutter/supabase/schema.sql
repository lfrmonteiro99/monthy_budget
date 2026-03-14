-- ─── Extensions ──────────────────────────────────────────
create extension if not exists "pgcrypto";

-- ─── Tables ──────────────────────────────────────────────

create table households (
  id           uuid primary key default gen_random_uuid(),
  name         text not null,
  created_at   timestamptz default now()
);

-- Extends auth.users (auto-created by trigger below)
create table profiles (
  id           uuid primary key references auth.users on delete cascade,
  email        text not null,
  household_id uuid references households(id),
  role         text not null default 'member'
               check (role in ('admin', 'member')),
  created_at   timestamptz default now()
);

-- Auto-create profile row when a user signs up
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

create table household_settings (
  household_id uuid primary key references households(id) on delete cascade,
  settings_json text not null default '{}',
  updated_at   timestamptz default now()
);

create table shopping_items (
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

create table purchase_records (
  id           text primary key,
  household_id uuid not null references households(id) on delete cascade,
  amount       numeric not null,
  item_count   int not null default 0,
  purchased_at timestamptz not null,
  created_at   timestamptz default now()
);

create table household_favorites (
  household_id  uuid primary key references households(id) on delete cascade,
  favorites_json text not null default '[]',
  updated_at    timestamptz default now()
);

create table meal_plans (
  household_id uuid not null references households(id) on delete cascade,
  month        int not null,
  year         int not null,
  plan_json    text not null,
  updated_at   timestamptz default now(),
  primary key (household_id, month, year)
);

create table household_invites (
  id           uuid primary key default gen_random_uuid(),
  household_id uuid not null references households(id) on delete cascade,
  code         text not null unique,
  created_by   uuid not null references profiles(id),
  created_at   timestamptz default now(),
  expires_at   timestamptz default (now() + interval '7 days')
);

create table custom_categories (
  id           text primary key,
  household_id uuid not null references households(id) on delete cascade,
  name         text not null,
  icon_name    text,
  color_hex    text,
  sort_order   int not null default 0,
  created_at   timestamptz default now()
);

-- ─── RLS ─────────────────────────────────────────────────

alter table households          enable row level security;
alter table profiles            enable row level security;
alter table household_settings  enable row level security;
alter table shopping_items      enable row level security;
alter table purchase_records    enable row level security;
alter table household_favorites enable row level security;
alter table meal_plans          enable row level security;
alter table household_invites   enable row level security;
alter table custom_categories   enable row level security;

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

-- households
create policy "read own household" on households
  for select using (id = my_household_id());

-- profiles
create policy "read household profiles" on profiles
  for select using (household_id = my_household_id() or id = auth.uid());
create policy "update own profile" on profiles
  for update using (id = auth.uid());

-- household_settings (write = admin only)
create policy "read settings" on household_settings
  for select using (household_id = my_household_id());
create policy "write settings admin" on household_settings
  for all using (household_id = my_household_id() and my_role() = 'admin');

-- shopping_items (all members)
create policy "read items"   on shopping_items for select using (household_id = my_household_id());
create policy "insert items" on shopping_items for insert with check (household_id = my_household_id());
create policy "update items" on shopping_items for update using (household_id = my_household_id());
create policy "delete items" on shopping_items for delete using (household_id = my_household_id());

-- purchase_records (all members)
create policy "read purchases"   on purchase_records for select using (household_id = my_household_id());
create policy "insert purchases" on purchase_records for insert with check (household_id = my_household_id());
create policy "delete purchases" on purchase_records for delete using (household_id = my_household_id());

-- household_favorites (all members)
create policy "read favorites"  on household_favorites for select using (household_id = my_household_id());
create policy "write favorites" on household_favorites for all   using (household_id = my_household_id());

-- meal_plans (all members)
create policy "read plans"  on meal_plans for select using (household_id = my_household_id());
create policy "write plans" on meal_plans for all   using (household_id = my_household_id());

-- household_invites (admin creates, household reads)
create policy "read invites"        on household_invites for select using (household_id = my_household_id());
create policy "create invite admin" on household_invites for insert with check (household_id = my_household_id() and my_role() = 'admin');

-- custom_categories (all members)
create policy "read categories"  on custom_categories for select using (household_id = my_household_id());
create policy "insert categories" on custom_categories for insert with check (household_id = my_household_id());
create policy "update categories" on custom_categories for update using (household_id = my_household_id());
create policy "delete categories" on custom_categories for delete using (household_id = my_household_id());

-- ─── Expense Snapshots ──────────────────────────────────────
create table expense_snapshots (
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

alter table expense_snapshots enable row level security;

create policy "read snapshots"   on expense_snapshots for select using (household_id = my_household_id());
create policy "insert snapshots" on expense_snapshots for insert with check (household_id = my_household_id());
create policy "update snapshots" on expense_snapshots for update using (household_id = my_household_id());

-- ─── Actual Expenses ──────────────────────────────────────
create table actual_expenses (
  id            text primary key,
  household_id  uuid not null references households(id) on delete cascade,
  category      text not null,
  amount        double precision not null,
  expense_date  date not null,
  description   text,
  month_key     text not null,
  created_at    timestamptz default now(),
  attachment_urls  text[],
  location_lat     double precision,
  location_lng     double precision,
  location_address text,
  recurring_expense_id text,
  is_from_recurring boolean default false
);

create index idx_actual_expenses_month on actual_expenses(household_id, month_key);

alter table actual_expenses enable row level security;

create policy "read actual_expenses" on actual_expenses
  for select using (household_id = my_household_id());
create policy "insert actual_expenses" on actual_expenses
  for insert with check (household_id = my_household_id());
create policy "update actual_expenses" on actual_expenses
  for update using (household_id = my_household_id());
create policy "delete actual_expenses" on actual_expenses
  for delete using (household_id = my_household_id());

-- ─── Realtime ─────────────────────────────────────────────
alter publication supabase_realtime add table shopping_items;
