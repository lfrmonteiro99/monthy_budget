# Playwright E2E

This directory contains browser-level smoke tests for the Flutter web app.

## Prerequisites

- Node.js 18+ with npm/npx available
- A running Flutter web instance for `monthy_budget_flutter`
- Test credentials exposed through environment variables when the flow requires authentication

## Environment variables

- `PLAYWRIGHT_BASE_URL`
  - Defaults to `http://127.0.0.1:7357`
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

## Notes

- CI only validates that the suite loads with `playwright test --list`.
- Runtime artifacts are written under `output/playwright/` and ignored by git.
- The repository CI uses Node 20 for Playwright validation.
