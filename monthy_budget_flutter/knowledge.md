# Project knowledge

This file gives Codebuff context about your project: goals, commands, conventions, and gotchas.

## What is this?

**Orçamento Mensal** — a Flutter mobile app for Portuguese monthly budget management. Features include IRS tax calculations, grocery price tracking, shopping lists (real-time via Supabase), AI financial coaching (OpenAI), meal planning, expense tracking, savings goals, recurring expenses, and notifications. Supports 4 locales: PT, EN, ES, FR.

## Quickstart

- **Install deps:** `flutter pub get`
- **Run (debug):** `flutter run`
- **Analyze:** `flutter analyze`
- **Test:** `flutter test`
- **Build APK:** `flutter build apk`
- **Regenerate l10n:** `flutter gen-l10n`

## Architecture

- **lib/screens/** — Full-page screens (dashboard, grocery, shopping list, coach, meal planner, settings, auth, etc.)
- **lib/widgets/** — Reusable widgets, bottom sheets, cards, charts
- **lib/services/** — Data layer: each service handles load/save for one domain (Supabase or SharedPreferences)
- **lib/models/** — Immutable data classes (AppSettings, Product, ShoppingItem, etc.)
- **lib/data/tax/** — Country-specific tax systems (PT, ES, FR, UK) with a factory pattern
- **lib/utils/** — Pure calculation helpers (budget calculations, formatters, stress index)
- **lib/theme/** — AppColors (palette-aware) and AppTheme (light/dark)
- **lib/onboarding/** — Tour definitions using tutorial_coach_mark
- **lib/l10n/** — ARB localization files + generated output
- **assets/** — JSON data files (grocery prices, meal planner recipes/ingredients)
- **supabase/** — SQL schema definitions

### Data flow

State lives in `_AppHomeState` (lib/main.dart) and is passed down to screens via constructor params. Services talk to Supabase (household-scoped data) or SharedPreferences (local-only config). Shopping list uses Supabase Realtime streams.

## Conventions

- **Localization:** Template ARB is `app_pt.arb`. Output class is `S` (use `S.of(context).keyName`). After editing ARB files, run `flutter gen-l10n`.
- **Linting:** Uses `package:flutter_lints/flutter.yaml` (see analysis_options.yaml).
- **Colors:** Always use `AppColors.xxx(context)` helpers — never hardcode colors. Supports multiple palettes + dark mode.
- **Services pattern:** One service class per domain. Methods take `householdId` for multi-tenant scoping.
- **State management:** Lifted state in main.dart `_AppHomeState`, no external state management library (no Provider, Bloc, etc.).
- **Immutable models:** Use `const` constructors and `copyWith` methods.
- **Supabase config:** Copy `lib/config/supabase_config.dart.example` → `supabase_config.dart` with real credentials.

## Key dependencies

- `supabase_flutter` — Backend (auth, database, realtime)
- `fl_chart` — Charts/graphs
- `shared_preferences` — Local-only settings
- `tutorial_coach_mark` — Onboarding tours
- `flutter_local_notifications` — Scheduled notifications
- `pdf` + `printing` — PDF export
- `csv` + `share_plus` — CSV export & sharing

## Gotchas

- Dart SDK requires `^3.11.0`
- The l10n template is PT (not EN) — always add new keys to `app_pt.arb` first with `@key` descriptions, then to the other 3 ARBs.
- `supabase_config.dart` is gitignored — the example file must be copied manually.
- Shopping list uses Supabase Realtime subscriptions — changes propagate automatically.
- Recurring expenses auto-populate at month start via `populateMonthIfNeeded`.
