# Playwright E2E

This directory contains browser-level smoke tests for the Flutter web app.

Current checked-in smoke specs:

- `auth-flow.smoke.spec.ts`
- `dashboard.smoke.spec.ts`
- `expense-tracker.smoke.spec.ts`
- `meal-planner-settings.smoke.spec.ts`
- `savings-goals.smoke.spec.ts`
- `shopping-list.smoke.spec.ts`

## Prerequisites

- Node.js 18+ with npm/npx available
- A running Flutter web instance for `monthy_budget_flutter`
- Test credentials exposed through environment variables when the flow requires authentication

## Environment variables

- `PLAYWRIGHT_BASE_URL`
  - Defaults to `http://127.0.0.1:7357`
- `SUPABASE_URL`
  - Required at Flutter web build time for a real authenticated run
- `SUPABASE_ANON_KEY`
  - Required at Flutter web build time for a real authenticated run
- `E2E_EMAIL`
  - Required for authenticated smoke tests
- `E2E_PASSWORD`
  - Required for authenticated smoke tests
- `PLAYWRIGHT_HEADLESS`
  - Set to `false` to see the browser

## Commands

```bash
npm ci
npm run e2e:install
npm run e2e:list
npm run e2e -- --grep "Meal planner settings smoke"
```

To run the authenticated suite locally, start a real Flutter web build first:

```bash
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 7357 \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key

E2E_EMAIL=you@example.com \
E2E_PASSWORD=your-password \
PLAYWRIGHT_BASE_URL=http://127.0.0.1:7357 \
npm run e2e
```

## Notes

- CI runs the authenticated smoke suite when `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `E2E_EMAIL`, and `E2E_PASSWORD` are available as repository secrets.
- If those secrets are unavailable for a given run, CI falls back to `playwright test --list` and emits a notice. This commonly happens on forked pull requests.
- Runtime artifacts are written under `output/playwright/` and ignored by git.
- The repository CI uses Node 20 for Playwright validation.
