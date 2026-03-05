# Test Database Setup for Functional Tests

This project uses Supabase. For functional/integration tests that touch backend data, use a local Supabase stack with dedicated test users and seed data.

## 1) Start local Supabase

```powershell
supabase start
```

## 2) Apply schema and catalog SQL

Run these in Supabase Studio (`http://127.0.0.1:54323`, SQL Editor) in this order:

1. `supabase/schema.sql`
2. `supabase/products.sql`
3. `supabase/functional_test_seed.sql`

`products.sql` is required before the seed because it adds `purchase_records.items_json`.

## 3) Create test auth users

Before running `supabase/functional_test_seed.sql`, create these users in Supabase Studio > `Authentication` > `Users`:

- `functional_admin@example.com`
- `functional_member@example.com`

Use any test password (for example `Passw0rd!123`).

The seed script links those users to a deterministic household id:

- `11111111-1111-1111-1111-111111111111`

and sets roles:

- `functional_admin@example.com` -> `admin`
- `functional_member@example.com` -> `member`

## 4) Point the app to local Supabase

Edit [supabase_config.dart](/C:/Users/lfrmo/Documents/monthy_budget/monthy_budget_flutter/lib/config/supabase_config.dart) for local runs:

```dart
const supabaseUrl = 'http://127.0.0.1:54321';
const supabaseAnonKey = '<anon-key-from-supabase-status>';
```

Get keys with:

```powershell
supabase status
```

## 5) Run tests

Unit + functional widget tests:

```powershell
flutter test
```

If you add DB-backed integration tests later (for example under `integration_test/`), run them against the same local stack after this setup.
