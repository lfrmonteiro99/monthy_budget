# Supabase Multi-User Integration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace all SharedPreferences persistence with Supabase (PostgreSQL + Auth + RLS + Realtime) so multiple household members share one budget, shopping list, and meal plan in real time.

**Architecture:** Household-centric model — every row carries `household_id`. A `profiles` table links GoTrue Auth users to households and roles (`admin | member`). Settings mutations are admin-only. Shopping list is synced via Supabase Realtime channel. All other data loads once on app start and saves explicitly (last-write-wins).

**Tech Stack:** supabase_flutter ^2.8.0, Supabase free tier (PostgreSQL, GoTrue Auth, PostgREST + RLS, Realtime WebSocket)

---

## Pre-requisites (manual steps before coding)

1. Create a free Supabase project at https://supabase.com
2. Note down: **Project URL** and **anon public key** (Settings → API)
3. Run the SQL from Task 2 in the Supabase SQL Editor

---

### Task 1: Add supabase_flutter + config file

**Files:**
- Modify: `monthy_budget_flutter/pubspec.yaml`
- Modify: `monthy_budget_flutter/.gitignore`
- Create: `monthy_budget_flutter/lib/config/supabase_config.dart.example` (committed template)
- Create: `monthy_budget_flutter/lib/config/supabase_config.dart` (gitignored — your real credentials)

**Step 1: Add dependency to pubspec.yaml**

Add `supabase_flutter: ^2.8.0` under `dependencies:`, after the `http:` line:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  shared_preferences: ^2.5.0
  http: ^1.2.0
  fl_chart: ^0.70.2
  intl: ^0.20.0
  supabase_flutter: ^2.8.0   # ADD THIS
```

**Step 2: Gitignore the real config**

`lib/config/supabase_config.dart` is already in `.gitignore` — verify it's there:

```
# Supabase credentials — never commit the real config
lib/config/supabase_config.dart
```

**Step 3: Create the committed example template**

Create `monthy_budget_flutter/lib/config/supabase_config.dart.example`:

```dart
// Copy this file to supabase_config.dart and fill in your credentials.
// Dashboard → your project → Settings → API
const supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
const supabaseAnonKey = 'YOUR_ANON_PUBLIC_KEY';
```

This file IS committed — it documents what colleagues need to fill in.

**Step 4: Create the real config (not committed)**

Create `monthy_budget_flutter/lib/config/supabase_config.dart` (git will ignore it):

```dart
const supabaseUrl = 'https://YOUR_REAL_PROJECT.supabase.co';
const supabaseAnonKey = 'eyJ...your real anon key...';
```

Fill in your actual values from Supabase Dashboard → Settings → API.

**Step 5: Run pub get**

Run: `flutter pub get`

Expected: No errors, `pubspec.lock` updated with supabase_flutter.

---

### Task 2: SQL schema + RLS (paste into Supabase SQL Editor, run once)

**Files:**
- Create: `monthy_budget_flutter/supabase/schema.sql` (reference only — paste into Supabase dashboard)

**Step 1: Create schema.sql**

```sql
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
  id           text primary key,   -- keeps existing 'purchase_<ms>' format
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

-- ─── RLS ─────────────────────────────────────────────────

alter table households         enable row level security;
alter table profiles           enable row level security;
alter table household_settings enable row level security;
alter table shopping_items     enable row level security;
alter table purchase_records   enable row level security;
alter table household_favorites enable row level security;
alter table meal_plans         enable row level security;
alter table household_invites  enable row level security;

-- Stable helpers (run as the caller's role, not definer)
create or replace function my_household_id()
returns uuid language sql security definer stable as $$
  select household_id from profiles where id = auth.uid()
$$;

create or replace function my_role()
returns text language sql security definer stable as $$
  select role from profiles where id = auth.uid()
$$;

-- households: members can read their own
create policy "read own household" on households
  for select using (id = my_household_id());

-- profiles: read same household + own row
create policy "read household profiles" on profiles
  for select using (household_id = my_household_id() or id = auth.uid());
create policy "update own profile" on profiles
  for update using (id = auth.uid());

-- household_settings: read all members, write admin only
create policy "read settings" on household_settings
  for select using (household_id = my_household_id());
create policy "write settings admin" on household_settings
  for all using (household_id = my_household_id() and my_role() = 'admin');

-- shopping_items: all household members can CRUD
create policy "read items"   on shopping_items for select using (household_id = my_household_id());
create policy "insert items" on shopping_items for insert with check (household_id = my_household_id());
create policy "update items" on shopping_items for update using (household_id = my_household_id());
create policy "delete items" on shopping_items for delete using (household_id = my_household_id());

-- purchase_records: all members
create policy "read purchases"   on purchase_records for select using (household_id = my_household_id());
create policy "insert purchases" on purchase_records for insert with check (household_id = my_household_id());
create policy "delete purchases" on purchase_records for delete using (household_id = my_household_id());

-- favorites: all members
create policy "read favorites"  on household_favorites for select using (household_id = my_household_id());
create policy "write favorites" on household_favorites for all   using (household_id = my_household_id());

-- meal_plans: all members
create policy "read plans"  on meal_plans for select using (household_id = my_household_id());
create policy "write plans" on meal_plans for all   using (household_id = my_household_id());

-- invites: admin creates, same household reads
create policy "read invites"         on household_invites for select using (household_id = my_household_id());
create policy "create invite admin"  on household_invites for insert with check (household_id = my_household_id() and my_role() = 'admin');

-- ─── Realtime ─────────────────────────────────────────────
alter publication supabase_realtime add table shopping_items;
```

**Step 2: Run in Supabase**

Paste into Supabase Dashboard → SQL Editor → Run All.

Expected: Green success banner. Verify Tables: households, profiles, household_settings, shopping_items, purchase_records, household_favorites, meal_plans, household_invites all visible in Table Editor.

---

### Task 3: Update ShoppingItem model (add id field)

**Files:**
- Modify: `monthy_budget_flutter/lib/models/shopping_item.dart`

**Step 1: Add id + Supabase serialization**

Replace the entire file:

```dart
class ShoppingItem {
  final String id;       // UUID from Supabase; '' for items not yet persisted
  final String productName;
  final String store;
  final double price;
  final String? unitPrice;
  bool checked;

  ShoppingItem({
    this.id = '',
    required this.productName,
    required this.store,
    required this.price,
    this.unitPrice,
    this.checked = false,
  });

  // Legacy JSON (SharedPreferences keys stay intact during migration)
  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
        id: json['id'] as String? ?? '',
        productName: json['productName'] as String? ?? '',
        store: json['store'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        unitPrice: json['unitPrice'] as String?,
        checked: json['checked'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'productName': productName,
        'store': store,
        'price': price,
        if (unitPrice != null) 'unitPrice': unitPrice,
        'checked': checked,
      };

  // Supabase row → ShoppingItem
  factory ShoppingItem.fromSupabase(Map<String, dynamic> row) => ShoppingItem(
        id: row['id'] as String,
        productName: row['product_name'] as String,
        store: row['store'] as String? ?? '',
        price: (row['price'] as num?)?.toDouble() ?? 0,
        unitPrice: row['unit_price'] as String?,
        checked: row['checked'] as bool? ?? false,
      );

  // ShoppingItem → Supabase row (id omitted — server generates UUID)
  Map<String, dynamic> toSupabase(String householdId) => {
        'household_id': householdId,
        'product_name': productName,
        'store': store,
        'price': price,
        if (unitPrice != null) 'unit_price': unitPrice,
        'checked': checked,
      };
}
```

**Step 2: Verify compile**

Run: `flutter build apk --debug`

Expected: BUILD SUCCESSFUL (id has default `''`, existing call sites unaffected).

---

### Task 4: AuthService

**Files:**
- Create: `monthy_budget_flutter/lib/services/auth_service.dart`

**Step 1: Write AuthService**

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  String? get currentUserId => _client.auth.currentUser?.id;

  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp(String email, String password) async {
    await _client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
```

**Step 2: Verify compile**

Run: `flutter build apk --debug`

Expected: BUILD SUCCESSFUL

---

### Task 5: HouseholdService

**Files:**
- Create: `monthy_budget_flutter/lib/services/household_service.dart`

**Step 1: Write HouseholdService**

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class HouseholdProfile {
  final String householdId;
  final String householdName;
  final String role; // 'admin' | 'member'

  const HouseholdProfile({
    required this.householdId,
    required this.householdName,
    required this.role,
  });
}

class HouseholdService {
  final _client = Supabase.instance.client;

  /// Returns null if the current user has no household yet.
  Future<HouseholdProfile?> getProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final row = await _client
        .from('profiles')
        .select('household_id, role, households(name)')
        .eq('id', userId)
        .maybeSingle();

    if (row == null || row['household_id'] == null) return null;

    return HouseholdProfile(
      householdId: row['household_id'] as String,
      householdName:
          (row['households'] as Map<String, dynamic>)['name'] as String,
      role: row['role'] as String,
    );
  }

  /// Admin path: creates a new household and assigns current user as admin.
  Future<HouseholdProfile> createHousehold(String name) async {
    final userId = _client.auth.currentUser!.id;

    final hh = await _client
        .from('households')
        .insert({'name': name})
        .select()
        .single();

    final householdId = hh['id'] as String;

    await _client.from('profiles').update({
      'household_id': householdId,
      'role': 'admin',
    }).eq('id', userId);

    await _client.from('household_settings').insert({
      'household_id': householdId,
      'settings_json': '{}',
    });

    return HouseholdProfile(
        householdId: householdId, householdName: name, role: 'admin');
  }

  /// Member path: joins an existing household via 6-char invite code.
  Future<HouseholdProfile> joinHousehold(String inviteCode) async {
    final userId = _client.auth.currentUser!.id;

    final invite = await _client
        .from('household_invites')
        .select('household_id, households(name)')
        .eq('code', inviteCode.trim().toUpperCase())
        .gte('expires_at', DateTime.now().toIso8601String())
        .maybeSingle();

    if (invite == null) throw Exception('Código inválido ou expirado.');

    final householdId = invite['household_id'] as String;
    final householdName =
        (invite['households'] as Map<String, dynamic>)['name'] as String;

    await _client.from('profiles').update({
      'household_id': householdId,
      'role': 'member',
    }).eq('id', userId);

    return HouseholdProfile(
        householdId: householdId, householdName: householdName, role: 'member');
  }

  /// Admin only: generates and persists a 6-char invite code.
  Future<String> generateInviteCode(String householdId) async {
    final userId = _client.auth.currentUser!.id;
    final code = _randomCode();
    await _client.from('household_invites').insert({
      'household_id': householdId,
      'code': code,
      'created_by': userId,
    });
    return code;
  }

  String _randomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    var r = DateTime.now().microsecondsSinceEpoch;
    final buf = StringBuffer();
    for (int i = 0; i < 6; i++) {
      buf.write(chars[r % chars.length]);
      r = (r * 1664525 + 1013904223) & 0x7fffffff;
    }
    return buf.toString();
  }
}
```

**Step 2: Verify compile**

Run: `flutter build apk --debug`

Expected: BUILD SUCCESSFUL

---

### Task 6: LoginScreen

**Files:**
- Create: `monthy_budget_flutter/lib/screens/auth/login_screen.dart`

**Step 1: Write LoginScreen**

```dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;
  const LoginScreen({super.key, required this.onAuthenticated});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_isLogin) {
        await _auth.signIn(_emailCtrl.text.trim(), _passCtrl.text);
      } else {
        await _auth.signUp(_emailCtrl.text.trim(), _passCtrl.text);
      }
      widget.onAuthenticated();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_balance_wallet,
                  size: 64, color: Color(0xFF3B82F6)),
              const SizedBox(height: 8),
              Text(
                'Orçamento Mensal',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                _isLogin ? 'Entrar na conta' : 'Criar conta',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: const Color(0xFF64748B)),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Palavra-passe', border: OutlineInputBorder()),
                onSubmitted: (_) => _submit(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!,
                    style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(_isLogin ? 'Entrar' : 'Registar'),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin ? 'Criar conta nova' : 'Já tenho conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Step 2: Verify compile**

Run: `flutter build apk --debug`

Expected: BUILD SUCCESSFUL

---

### Task 7: HouseholdSetupScreen

**Files:**
- Create: `monthy_budget_flutter/lib/screens/auth/household_setup_screen.dart`

**Step 1: Write HouseholdSetupScreen**

```dart
import 'package:flutter/material.dart';
import '../../services/household_service.dart';

class HouseholdSetupScreen extends StatefulWidget {
  final void Function(HouseholdProfile profile) onSetupComplete;
  const HouseholdSetupScreen({super.key, required this.onSetupComplete});

  @override
  State<HouseholdSetupScreen> createState() => _HouseholdSetupScreenState();
}

class _HouseholdSetupScreenState extends State<HouseholdSetupScreen> {
  final _service = HouseholdService();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  bool _creating = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final HouseholdProfile profile;
      if (_creating) {
        final name = _nameCtrl.text.trim();
        if (name.isEmpty) throw Exception('Indica o nome do agregado.');
        profile = await _service.createHousehold(name);
      } else {
        profile = await _service.joinHousehold(_codeCtrl.text.trim());
      }
      widget.onSetupComplete(profile);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.people_outline,
                  size: 64, color: Color(0xFF3B82F6)),
              const SizedBox(height: 8),
              Text(
                'Configurar Agregado',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                      value: true,
                      label: Text('Criar'),
                      icon: Icon(Icons.add)),
                  ButtonSegment(
                      value: false,
                      label: Text('Entrar com código'),
                      icon: Icon(Icons.link)),
                ],
                selected: {_creating},
                onSelectionChanged: (s) => setState(() => _creating = s.first),
              ),
              const SizedBox(height: 20),
              if (_creating)
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nome do agregado',
                    hintText: 'ex: Família Silva',
                    border: OutlineInputBorder(),
                  ),
                )
              else
                TextField(
                  controller: _codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Código de convite',
                    hintText: 'XXXXXX',
                    border: OutlineInputBorder(),
                  ),
                ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!,
                    style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(_creating ? 'Criar Agregado' : 'Entrar no Agregado'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Step 2: Verify compile**

Run: `flutter build apk --debug`

Expected: BUILD SUCCESSFUL

---

### Task 8: AuthGate widget

**Files:**
- Create: `monthy_budget_flutter/lib/screens/auth/auth_gate.dart`

**Step 1: Write AuthGate**

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/household_service.dart';
import 'login_screen.dart';
import 'household_setup_screen.dart';

class AuthGate extends StatefulWidget {
  final Widget Function(HouseholdProfile profile) appBuilder;
  const AuthGate({super.key, required this.appBuilder});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _householdService = HouseholdService();
  HouseholdProfile? _profile;
  bool _loadingProfile = false;

  void _loadProfile() {
    if (_loadingProfile) return;
    _loadingProfile = true;
    _householdService.getProfile().then((p) {
      if (mounted) setState(() { _profile = p; _loadingProfile = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;

        // Not authenticated → Login
        if (session == null) {
          _profile = null; // reset on logout
          return LoginScreen(
            onAuthenticated: _loadProfile,
          );
        }

        // Authenticated but profile not loaded yet
        if (_profile == null && !_loadingProfile) {
          _loadProfile();
          return const Scaffold(
            backgroundColor: Color(0xFFF8FAFC),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (_loadingProfile) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8FAFC),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Authenticated but no household → Setup
        if (_profile == null) {
          return HouseholdSetupScreen(
            onSetupComplete: (profile) => setState(() => _profile = profile),
          );
        }

        // Fully ready
        return widget.appBuilder(_profile!);
      },
    );
  }
}
```

**Step 2: Verify compile**

Run: `flutter build apk --debug`

Expected: BUILD SUCCESSFUL

---

### Task 9: Update main.dart — Supabase init + AuthGate + householdId threading

**Files:**
- Modify: `monthy_budget_flutter/lib/main.dart`

**Step 1: Add imports**

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'services/household_service.dart';
import 'screens/auth/auth_gate.dart';
```

**Step 2: Make main async + initialize Supabase**

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const OrcamentoMensalApp());
}
```

**Step 3: Wrap AppHome with AuthGate**

In `OrcamentoMensalApp.build`, change `home:`:

```dart
home: AuthGate(
  appBuilder: (profile) => AppHome(
    householdId: profile.householdId,
    isAdmin: profile.role == 'admin',
  ),
),
```

**Step 4: Add householdId + isAdmin to AppHome**

```dart
class AppHome extends StatefulWidget {
  final String householdId;
  final bool isAdmin;
  const AppHome({super.key, required this.householdId, required this.isAdmin});
  ...
}
```

**Step 5: Thread householdId into _loadAll**

```dart
Future<void> _loadAll() async {
  final results = await Future.wait([
    _settingsService.load(widget.householdId),
    _groceryService.load(),
    _favoritesService.load(widget.householdId),
    _purchaseHistoryService.load(widget.householdId),
    _aiCoachService.loadApiKey(),
  ]);
  setState(() {
    _settings = results[0] as AppSettings;
    _groceryData = results[1] as GroceryData;
    _favorites = results[2] as List<String>;
    _purchaseHistory = results[3] as PurchaseHistory;
    _openAiApiKey = results[4] as String;
    _loaded = true;
  });
}
```

Note: `_shoppingList` is no longer loaded in `_loadAll` — the stream handles it (see Task 11).

**Step 6: Add stream subscription for shopping list**

```dart
late StreamSubscription<List<ShoppingItem>> _shoppingListSub;

@override
void initState() {
  super.initState();
  _shoppingListSub = _shoppingListService
      .stream(widget.householdId)
      .listen((items) => setState(() => _shoppingList = items));
  _loadAll();
}

@override
void dispose() {
  _shoppingListSub.cancel();
  super.dispose();
}
```

Remove `import 'dart:async';` if not already present — add it.

**Step 7: Pass householdId to services + isAdmin to screens**

- `_saveSettings`: calls `_settingsService.save(settings, widget.householdId)` and only if `widget.isAdmin`
- `_saveFavorites`: calls `_favoritesService.save(favorites, widget.householdId)`
- Both `SettingsScreen` navigations: add `isAdmin: widget.isAdmin`
- `MealPlannerScreen`: add `householdId: widget.householdId`
- `_finalizeShopping`: calls `_purchaseHistoryService.saveRecord(record, widget.householdId)`

**Step 8: Update shopping list mutations to use IDs**

```dart
void _addToShoppingList(ShoppingItem item) async {
  final exists = _shoppingList.any(
    (e) => e.productName == item.productName && e.store == item.store,
  );
  if (exists) return;
  await _shoppingListService.add(item, widget.householdId);
  // stream updates _shoppingList automatically
}

void _toggleShoppingItem(ShoppingItem item) async {
  await _shoppingListService.toggle(item.id, !item.checked);
}

void _removeShoppingItem(ShoppingItem item) async {
  await _shoppingListService.remove(item.id);
}

void _clearCheckedItems() async {
  await _shoppingListService.clearChecked(widget.householdId);
}
```

**Step 9: Verify compile**

Run: `flutter build apk --debug`

Expected: BUILD SUCCESSFUL (expect type errors if services not yet updated — fix as you go).

---

### Task 10: Rewrite SettingsService (Supabase)

**Files:**
- Modify: `monthy_budget_flutter/lib/services/settings_service.dart`

**Step 1: Rewrite file**

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_settings.dart';

class SettingsService {
  final _client = Supabase.instance.client;

  Future<AppSettings> load(String householdId) async {
    final row = await _client
        .from('household_settings')
        .select('settings_json')
        .eq('household_id', householdId)
        .maybeSingle();

    if (row == null) return const AppSettings();
    try {
      return AppSettings.fromJsonString(row['settings_json'] as String);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> save(AppSettings settings, String householdId) async {
    await _client.from('household_settings').upsert({
      'household_id': householdId,
      'settings_json': settings.toJsonString(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
```

**Step 2: Verify compile**

Run: `flutter build apk --debug`

Expected: BUILD SUCCESSFUL

---

### Task 11: Rewrite ShoppingListService (Supabase + Realtime)

**Files:**
- Modify: `monthy_budget_flutter/lib/services/shopping_list_service.dart`

**Step 1: Rewrite file**

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/shopping_item.dart';

class ShoppingListService {
  final _client = Supabase.instance.client;

  /// Realtime stream — automatically updates whenever the table changes.
  Stream<List<ShoppingItem>> stream(String householdId) {
    return _client
        .from('shopping_items')
        .stream(primaryKey: ['id'])
        .eq('household_id', householdId)
        .order('created_at')
        .map((rows) => rows.map((r) => ShoppingItem.fromSupabase(r)).toList());
  }

  /// Add a new item; returns the server-persisted item (with UUID id).
  Future<ShoppingItem> add(ShoppingItem item, String householdId) async {
    final row = await _client
        .from('shopping_items')
        .insert(item.toSupabase(householdId))
        .select()
        .single();
    return ShoppingItem.fromSupabase(row);
  }

  Future<void> toggle(String id, bool checked) async {
    await _client.from('shopping_items').update({
      'checked': checked,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> remove(String id) async {
    await _client.from('shopping_items').delete().eq('id', id);
  }

  Future<void> clearChecked(String householdId) async {
    await _client
        .from('shopping_items')
        .delete()
        .eq('household_id', householdId)
        .eq('checked', true);
  }
}
```

**Step 2: Verify compile**

Run: `flutter build apk --debug`

Expected: BUILD SUCCESSFUL. The old `load()`/`save()` methods are gone — main.dart now uses `stream()`.

---

### Task 12: Rewrite FavoritesService (Supabase)

**Files:**
- Modify: `monthy_budget_flutter/lib/services/favorites_service.dart`

**Step 1: Rewrite file**

```dart
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesService {
  final _client = Supabase.instance.client;

  Future<List<String>> load(String householdId) async {
    final row = await _client
        .from('household_favorites')
        .select('favorites_json')
        .eq('household_id', householdId)
        .maybeSingle();

    if (row == null) return [];
    try {
      return List<String>.from(jsonDecode(row['favorites_json'] as String));
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<String> favorites, String householdId) async {
    await _client.from('household_favorites').upsert({
      'household_id': householdId,
      'favorites_json': jsonEncode(favorites),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
```

**Step 2: Verify compile**

Run: `flutter build apk --debug`

Expected: BUILD SUCCESSFUL

---

### Task 13: Rewrite PurchaseHistoryService (Supabase)

**Files:**
- Modify: `monthy_budget_flutter/lib/services/purchase_history_service.dart`

**Step 1: Rewrite file**

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/purchase_record.dart';

class PurchaseHistoryService {
  final _client = Supabase.instance.client;

  Future<PurchaseHistory> load(String householdId) async {
    final rows = await _client
        .from('purchase_records')
        .select()
        .eq('household_id', householdId)
        .order('purchased_at', ascending: false);

    final records = rows
        .map((r) => PurchaseRecord(
              id: r['id'] as String,
              date: DateTime.parse(r['purchased_at'] as String),
              amount: (r['amount'] as num).toDouble(),
              itemCount: r['item_count'] as int,
            ))
        .toList();

    return PurchaseHistory(records: records);
  }

  Future<void> saveRecord(PurchaseRecord record, String householdId) async {
    await _client.from('purchase_records').upsert({
      'id': record.id,
      'household_id': householdId,
      'amount': record.amount,
      'item_count': record.itemCount,
      'purchased_at': record.date.toIso8601String(),
    });
  }
}
```

**Step 2: Verify compile**

Run: `flutter build apk --debug`

Expected: BUILD SUCCESSFUL

---

### Task 14: Rewrite MealPlannerService persistence layer (Supabase)

**Files:**
- Modify: `monthy_budget_flutter/lib/services/meal_planner_service.dart`
- Modify: `monthy_budget_flutter/lib/screens/meal_planner_screen.dart`

**Step 1: Replace load/save/clear in MealPlannerService**

Remove the old SharedPreferences `load()`, `save()`, `clear()` methods (lines 220–239).

Add Supabase equivalents:

```dart
Future<MealPlan?> load(String householdId, int month, int year) async {
  final client = Supabase.instance.client;
  final row = await client
      .from('meal_plans')
      .select('plan_json')
      .eq('household_id', householdId)
      .eq('month', month)
      .eq('year', year)
      .maybeSingle();

  if (row == null) return null;
  try {
    return MealPlan.fromJsonString(row['plan_json'] as String);
  } catch (_) {
    return null;
  }
}

Future<void> save(MealPlan plan, String householdId) async {
  final client = Supabase.instance.client;
  await client.from('meal_plans').upsert({
    'household_id': householdId,
    'month': plan.month,
    'year': plan.year,
    'plan_json': plan.toJsonString(),
    'updated_at': DateTime.now().toIso8601String(),
  });
}

Future<void> clear(String householdId, int month, int year) async {
  final client = Supabase.instance.client;
  await client
      .from('meal_plans')
      .delete()
      .eq('household_id', householdId)
      .eq('month', month)
      .eq('year', year);
}
```

Also remove `import 'package:shared_preferences/shared_preferences.dart';` from the file.

**Step 2: Update MealPlannerScreen**

Add `final String householdId;` to `MealPlannerScreen` widget.

Change all `_service.load()` calls to `_service.load(widget.householdId, month, year)`.

Change all `_service.save(plan)` calls to `_service.save(plan, widget.householdId)`.

Change all `_service.clear()` calls to `_service.clear(widget.householdId, plan.month, plan.year)`.

**Step 3: Pass householdId from main.dart**

In `main.dart` AppHome.build, update MealPlannerScreen:

```dart
MealPlannerScreen(
  settings: _settings,
  apiKey: _openAiApiKey,
  favorites: _favorites,
  onAddToShoppingList: _addToShoppingList,
  householdId: widget.householdId,   // ADD
),
```

**Step 4: Verify compile**

Run: `flutter build apk --debug`

Expected: BUILD SUCCESSFUL

---

### Task 15: Role-based UI guard + invite code in SettingsScreen

**Files:**
- Modify: `monthy_budget_flutter/lib/screens/settings_screen.dart`

**Step 1: Add isAdmin + householdId params**

```dart
class SettingsScreen extends StatefulWidget {
  // ... existing params ...
  final bool isAdmin;
  final String householdId;

  const SettingsScreen({
    // ... existing ...
    required this.isAdmin,
    required this.householdId,
  });
```

**Step 2: Disable all editable fields for non-admin**

On every `TextFormField` and `DropdownButtonFormField` that writes settings:

```dart
enabled: widget.isAdmin,
```

On every save button / submit handler, wrap with:

```dart
if (!widget.isAdmin) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Apenas o administrador pode alterar as definições.')),
  );
  return;
}
```

**Step 3: Add household section (admin only)**

At the bottom of the settings form body, add:

```dart
if (widget.isAdmin) ...[
  const Divider(height: 32),
  const Text('Agregado',
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
  const SizedBox(height: 8),
  ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.link, color: Color(0xFF3B82F6)),
    title: const Text('Gerar código de convite'),
    subtitle: _inviteCode != null
        ? SelectableText(_inviteCode!,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 4))
        : const Text('Partilha com membros do agregado'),
    trailing: IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: _generateInvite,
    ),
  ),
],
```

Add state + handler:

```dart
String? _inviteCode;

Future<void> _generateInvite() async {
  final code =
      await HouseholdService().generateInviteCode(widget.householdId);
  setState(() => _inviteCode = code);
}
```

Add import: `import '../services/household_service.dart';`

**Step 4: Update both SettingsScreen call sites in main.dart**

```dart
SettingsScreen(
  settings: _settings,
  onSave: _saveSettings,
  favorites: _favorites,
  onSaveFavorites: _saveFavorites,
  apiKey: _openAiApiKey,
  onSaveApiKey: _saveApiKey,
  isAdmin: widget.isAdmin,          // ADD
  householdId: widget.householdId,  // ADD
),
```

**Step 5: Verify compile**

Run: `flutter build apk --debug`

Expected: BUILD SUCCESSFUL

---

### Task 16: Remove SharedPreferences from migrated services + final build

**Files:**
- Modify: `monthy_budget_flutter/pubspec.yaml` (keep shared_preferences — still used by AiCoachService for API key)

**Step 1: Verify shared_preferences is still needed**

`AiCoachService` uses `SharedPreferences` for `openai_api_key` — this stays local, not household-shared. Keep `shared_preferences: ^2.5.0` in pubspec.yaml.

**Step 2: Run full test suite**

Run: `flutter test`

Expected: All 7 meal planner tests pass. (Tests call MealPlannerService.generate/nPessoas/monthlyFoodBudget which don't touch Supabase.)

**Step 3: Build release APK**

Run: `flutter build apk --release`

Expected: BUILD SUCCESSFUL
Output: `build/app/outputs/flutter-apk/app-release.apk`

**Step 4: Commit**

```bash
git add monthy_budget_flutter/lib monthy_budget_flutter/pubspec.yaml monthy_budget_flutter/pubspec.lock monthy_budget_flutter/supabase/
git commit -m "claude/budget-calculator-app-TFWgZ: add Supabase multi-user integration with Auth, households, RLS, and Realtime shopping list"
```

---

## Summary of changes

| File | Change |
|---|---|
| `pubspec.yaml` | + supabase_flutter |
| `supabase/schema.sql` | New — SQL for Supabase dashboard |
| `lib/config/supabase_config.dart` | New — URL + anon key |
| `lib/models/shopping_item.dart` | + id field, fromSupabase, toSupabase |
| `lib/services/auth_service.dart` | New |
| `lib/services/household_service.dart` | New |
| `lib/services/settings_service.dart` | Supabase-backed (+ householdId param) |
| `lib/services/shopping_list_service.dart` | Supabase + Realtime stream |
| `lib/services/favorites_service.dart` | Supabase-backed (+ householdId param) |
| `lib/services/purchase_history_service.dart` | Supabase-backed (+ householdId param) |
| `lib/services/meal_planner_service.dart` | Supabase persistence (+ householdId param) |
| `lib/screens/auth/login_screen.dart` | New |
| `lib/screens/auth/household_setup_screen.dart` | New |
| `lib/screens/auth/auth_gate.dart` | New |
| `lib/screens/settings_screen.dart` | + isAdmin guard + invite code |
| `lib/screens/meal_planner_screen.dart` | + householdId param |
| `lib/main.dart` | Supabase init + AuthGate + stream subscription |
