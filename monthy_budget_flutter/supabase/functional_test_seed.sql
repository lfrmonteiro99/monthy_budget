-- Seed data for local functional/integration testing.
-- Prerequisite: create these users in Supabase Studio Auth first:
--   functional_admin@example.com
--   functional_member@example.com

-- Fixed household id so tests can use deterministic references.
insert into households (id, name)
values ('11111111-1111-1111-1111-111111111111', 'Functional Test Household')
on conflict (id) do update set name = excluded.name;

-- Attach the admin user to the household.
update profiles p
set household_id = '11111111-1111-1111-1111-111111111111',
    role = 'admin'
from auth.users u
where p.id = u.id
  and u.email = 'functional_admin@example.com';

-- Attach the member user to the same household.
update profiles p
set household_id = '11111111-1111-1111-1111-111111111111',
    role = 'member'
from auth.users u
where p.id = u.id
  and u.email = 'functional_member@example.com';

insert into household_settings (household_id, settings_json, updated_at)
values (
  '11111111-1111-1111-1111-111111111111',
  '{"setupWizardCompleted":true}',
  now()
)
on conflict (household_id) do update
set settings_json = excluded.settings_json,
    updated_at = excluded.updated_at;

insert into household_favorites (household_id, favorites_json, updated_at)
values (
  '11111111-1111-1111-1111-111111111111',
  '["Leite","Arroz","Banana"]',
  now()
)
on conflict (household_id) do update
set favorites_json = excluded.favorites_json,
    updated_at = excluded.updated_at;

insert into shopping_items (household_id, product_name, store, price, unit_price, checked)
values
  ('11111111-1111-1111-1111-111111111111', 'Leite', 'Test Store', 1.50, '1.50/L', false),
  ('11111111-1111-1111-1111-111111111111', 'Arroz', 'Test Store', 2.20, '2.20/kg', true);

insert into purchase_records (id, household_id, amount, item_count, purchased_at, items_json, created_at)
values
  ('seed-purchase-1', '11111111-1111-1111-1111-111111111111', 18.50, 6, now() - interval '14 day', '["Leite","Arroz","Frango"]', now())
on conflict (id) do update
set amount = excluded.amount,
    item_count = excluded.item_count,
    purchased_at = excluded.purchased_at,
    items_json = excluded.items_json,
    created_at = excluded.created_at;

insert into actual_expenses (id, household_id, category, amount, expense_date, description, month_key, created_at)
values
  ('seed-expense-1', '11111111-1111-1111-1111-111111111111', 'alimentacao', 120, current_date - interval '8 day', 'Weekly groceries', to_char(current_date, 'YYYY-MM'), now()),
  ('seed-expense-2', '11111111-1111-1111-1111-111111111111', 'habitacao', 700, current_date - interval '20 day', 'Rent', to_char(current_date, 'YYYY-MM'), now())
on conflict (id) do update
set category = excluded.category,
    amount = excluded.amount,
    expense_date = excluded.expense_date,
    description = excluded.description,
    month_key = excluded.month_key,
    created_at = excluded.created_at;
