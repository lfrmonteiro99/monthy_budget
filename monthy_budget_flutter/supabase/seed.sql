-- ============================================================================
-- Seed data for local development
-- ============================================================================
-- Prerequisites:
--   1. Run migrations first (supabase db reset will do this automatically)
--   2. Create these test users in Supabase Studio Auth:
--        dev_admin@example.com  (password: testtest)
--        dev_member@example.com (password: testtest)
--
-- This file is executed automatically by `supabase db reset`.
-- ============================================================================

-- ─── Household ──────────────────────────────────────────────────────────────

insert into households (id, name)
values ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Dev Test Household')
on conflict (id) do update set name = excluded.name;

-- ─── Attach users to household ──────────────────────────────────────────────
-- These UPDATE statements only work after the test users have been created
-- via Auth and the on_auth_user_created trigger has fired.

update profiles p
set household_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    role = 'admin'
from auth.users u
where p.id = u.id
  and u.email = 'dev_admin@example.com';

update profiles p
set household_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    role = 'member'
from auth.users u
where p.id = u.id
  and u.email = 'dev_member@example.com';

-- ─── Household settings ─────────────────────────────────────────────────────

insert into household_settings (household_id, settings_json, updated_at)
values (
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  '{"setupWizardCompleted":true,"currency":"EUR","locale":"pt"}',
  now()
)
on conflict (household_id) do update
set settings_json = excluded.settings_json,
    updated_at = excluded.updated_at;

-- ─── Favorites ──────────────────────────────────────────────────────────────

insert into household_favorites (household_id, favorites_json, updated_at)
values (
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  '["Leite","Arroz","Banana","Ovos","Frango"]',
  now()
)
on conflict (household_id) do update
set favorites_json = excluded.favorites_json,
    updated_at = excluded.updated_at;

-- ─── Shopping items ─────────────────────────────────────────────────────────

insert into shopping_items (household_id, product_name, store, price, unit_price, checked)
values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Leite',           'Continente', 0.79, '0.79/L',  false),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Arroz 1kg',       'Pingo Doce', 1.29, '1.29/kg', false),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Peito de frango',  'Continente', 6.99, '6.99/kg', false),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Banana',          'Lidl',       1.29, '1.29/kg', true),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Ovos 12 un',      'Pingo Doce', 2.49, '2.49/pk', true);

-- ─── Actual expenses ────────────────────────────────────────────────────────

insert into actual_expenses (id, household_id, category, amount, expense_date, description, month_key)
values
  ('seed-exp-001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'alimentacao', 85.50,  current_date - interval '3 day',  'Compras semanais Continente',  to_char(current_date, 'YYYY-MM')),
  ('seed-exp-002', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'habitacao',   650.00, current_date - interval '15 day', 'Renda mensal',                 to_char(current_date, 'YYYY-MM')),
  ('seed-exp-003', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'transportes', 40.00,  current_date - interval '10 day', 'Passe mensal metro',           to_char(current_date, 'YYYY-MM')),
  ('seed-exp-004', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'alimentacao', 12.30,  current_date - interval '1 day',  'Almoco restaurante',           to_char(current_date, 'YYYY-MM')),
  ('seed-exp-005', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'saude',       25.00,  current_date - interval '7 day',  'Farmacia',                     to_char(current_date, 'YYYY-MM'))
on conflict (id) do update
set category = excluded.category,
    amount = excluded.amount,
    expense_date = excluded.expense_date,
    description = excluded.description,
    month_key = excluded.month_key;

-- ─── Recurring expenses ─────────────────────────────────────────────────────

insert into recurring_expenses (id, household_id, category, amount, description, day_of_month, is_active)
values
  ('seed-rec-001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'habitacao',    650.00, 'Renda mensal',        1,  true),
  ('seed-rec-002', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'transportes',  40.00,  'Passe mensal metro',  5,  true),
  ('seed-rec-003', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'servicos',     35.00,  'Internet fibra',      10, true)
on conflict (id) do update
set category = excluded.category,
    amount = excluded.amount,
    description = excluded.description,
    day_of_month = excluded.day_of_month,
    is_active = excluded.is_active;

-- ─── Monthly budget targets ─────────────────────────────────────────────────

insert into monthly_budgets (id, household_id, category, amount, month_key)
values
  ('seed-bud-001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'alimentacao', 400.00, to_char(current_date, 'YYYY-MM')),
  ('seed-bud-002', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'habitacao',   700.00, to_char(current_date, 'YYYY-MM')),
  ('seed-bud-003', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'transportes', 60.00,  to_char(current_date, 'YYYY-MM'))
on conflict (household_id, month_key, category) do update
set amount = excluded.amount;

-- ─── Purchase record ────────────────────────────────────────────────────────

insert into purchase_records (id, household_id, amount, item_count, purchased_at, items_json)
values
  ('seed-pur-001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 85.50, 8, now() - interval '3 day', '["Leite","Arroz","Frango","Banana","Ovos","Tomate","Cebola","Azeite"]')
on conflict (id) do update
set amount = excluded.amount,
    item_count = excluded.item_count,
    purchased_at = excluded.purchased_at,
    items_json = excluded.items_json;
